:- encoding(utf8).

% Capítulo 59 - Versión 4: revisiones de estilo sobre los términos leídos.
%
% revisar/2 recorre lo que leer_archivo/2 devuelve y produce un aviso por
% cada problema, aviso(Posicion, Tipo, Detalle), en el orden del archivo:
%
%   singular(Nombre)      la variable Nombre aparece una sola vez en la
%                         cláusula: suele ser un error de escritura;
%   repetida(Nombre)      la variable Nombre empieza con _, lo que anuncia
%                         que aparece una vez, y aparece más;
%   separadas(PI)         las cláusulas de PI no están juntas;
%   sin_encabezado(PI)    PI tiene alguna regla y ningún comentario %! antes
%                         de su primera cláusula;
%   sin_comentario(PI)    PI es solo hechos y no tiene ningún comentario
%                         antes del primero.
%
% Los dos últimos son las convenciones del curso para documentar.
% revisar_texto_de/2 revisa un programa escrito como texto, y
% revisar_texto/2, uno de los textos que texto/2 nombra.
%
% solo-local: lee archivos y carga leer.pl.
%
%?- revisar_texto(borrador, Avisos).
%?- singulares((p(X) :- q(Z), r(W, W)), ['X'=X, 'Z'=Z, '_W'=W], Avisos).

:- ensure_loaded(leer).

:- multifile texto/2.

%!  revisar_archivos(+Archivos:list, -Avisos:list) is det.
%
%   Avisos son los avisos de todos los Archivos, archivo por archivo.
revisar_archivos(Archivos, Avisos) :-
    maplist(revisar_archivo, Archivos, Avisos0),
    append(Avisos0, Avisos).

%!  revisar_archivo(+Archivo, -Avisos:list) is det.
%
%   Avisos son los avisos de Archivo, en el orden del archivo.
revisar_archivo(Archivo, Avisos) :-
    leer_archivo(Archivo, Leidos),
    revisar(Leidos, Avisos).

%!  texto(+Nombre, -Texto:string) is semidet.
%
%   Texto es el programa, escrito como texto, que se llama Nombre. Falla si
%   no hay un texto con ese nombre. El borrador es un borrador del programa
%   de notas, con defectos de estilo.
texto(borrador, Texto) :-
    Lineas = [ "% notas(A, Ns): el alumno A tiene las notas Ns.",
               "notas(ana, [8, 9, 10]).",
               "",
               "promedio(Ns, P) :-",
               "    suma(Ns, S),",
               "    length(Ns, L),",
               "    P is S / Largo.",
               "",
               "%!  suma(+Ns:list, -S:number) is det.",
               "%",
               "%   S es la suma de los números de Ns.",
               "suma([], 0).",
               "notas(bruno, [4, 6]).",
               "suma([N|Ns], S) :-",
               "    suma(Ns, _S0),",
               "    S is _S0 + N."
             ],
    atomic_list_concat(Lineas, '\n', Atomo),
    atom_string(Atomo, Texto).

%!  revisar_texto_de(+Texto:string, -Avisos:list) is det.
%
%   Avisos son los avisos del programa escrito en Texto; la posición de
%   cada uno es texto:Linea.
revisar_texto_de(Texto, Avisos) :-
    setup_call_cleanup(open_string(Texto, Stream),
                       leer_terminos(Stream, texto, Leidos),
                       close(Stream)),
    revisar(Leidos, Avisos).

%!  revisar_texto(+Nombre, -Avisos:list) is det.
%
%   revisar_texto_de/2 sobre el texto llamado Nombre.
revisar_texto(Nombre, Avisos) :-
    texto(Nombre, Texto),
    revisar_texto_de(Texto, Avisos).

%!  revisar(+Leidos:list, -Avisos:list) is det.
%
%   Avisos son los avisos de los términos Leidos de un archivo, ordenados
%   por línea.
revisar(Leidos, Avisos) :-
    findall(A, ( member(leido(T, P, Ns, _), Leidos),
                 singulares(T, Ns, As),
                 member(A0, As),
                 A0 = aviso(_, Tipo, Detalle),
                 A = aviso(P, Tipo, Detalle) ),
            Singulares),
    separadas(Leidos, Separadas),
    documentacion(Leidos, Documentacion),
    append([Singulares, Separadas, Documentacion], Todos),
    predsort(por_linea, Todos, Avisos).

%!  por_linea(-Orden, +A, +B) is det.
%
%   Compara dos avisos por su línea, y después por su tipo y detalle.
por_linea(Orden, aviso(_:L1, T1, D1), aviso(_:L2, T2, D2)) :-
    compare(Orden0, L1, L2),
    (   Orden0 == (=)
    ->  compare(Orden, T1-D1, T2-D2)
    ;   Orden = Orden0
    ).

%!  singulares(+Termino, +Nombres:list, -Avisos:list) is det.
%
%   Avisos son los avisos de las variables de Termino, que se llaman como
%   dice Nombres: singular para una variable con nombre que aparece una
%   sola vez, repetida para una que empieza con _ y aparece más. La
%   posición de cada aviso queda libre.
singulares(Termino, Nombres, Avisos) :-
    phrase(ocurrencias(Termino), Ocurrencias),
    findall(aviso(_, Tipo, Nombre),
            ( member(Nombre = V, Nombres),
              veces(Ocurrencias, V, N),
              tipo_de_variable(Nombre, N, Tipo) ),
            Avisos).

%!  tipo_de_variable(+Nombre:atom, +N:integer, -Tipo) is semidet.
%
%   Una variable Nombre que aparece N veces merece un aviso de tipo Tipo.
tipo_de_variable(Nombre, 1, singular) :-
    \+ sub_atom(Nombre, 0, _, _, '_').
tipo_de_variable(Nombre, N, repetida) :-
    N > 1,
    sub_atom(Nombre, 0, _, _, '_').

%!  ocurrencias(+Termino)// is det.
%
%   Describe la lista de las variables de Termino, una vez por cada lugar
%   donde aparecen, de izquierda a derecha.
ocurrencias(T) -->
    (   { var(T) }
    ->  [T]
    ;   { compound(T) }
    ->  { compound_name_arguments(T, _, Argumentos) },
        ocurrencias_lista(Argumentos)
    ;   []
    ).

%!  ocurrencias_lista(+Terminos:list)// is det.
%
%   Describe las ocurrencias de variables de cada término de la lista.
ocurrencias_lista([]) -->
    [].
ocurrencias_lista([T|Ts]) -->
    ocurrencias(T),
    ocurrencias_lista(Ts).

%!  veces(+Ocurrencias:list, +V, -N:integer) is det.
%
%   N es la cantidad de veces que la variable V está en Ocurrencias.
veces(Ocurrencias, V, N) :-
    include(==(V), Ocurrencias, Iguales),
    length(Iguales, N).

%!  clausula_leida(+Leidos:list, -Leido, -PI) is nondet.
%
%   Leido es un término de Leidos que es una cláusula, o una regla de
%   gramática, del predicado PI.
clausula_leida(Leidos, Leido, PI) :-
    member(Leido, Leidos),
    Leido = leido(T, _, _, _),
    T \= (:- _),
    cabeza_de(T, Cabeza),
    indicador(Cabeza, PI).

%!  cabeza_de(+Termino, -Cabeza) is det.
%
%   Cabeza es la cabeza de la cláusula o regla de gramática Termino, sin
%   módulo, con los dos argumentos que agrega la traducción de gramática;
%   en una regla con pushback, como p, [a] --> q, la cabeza es la de p.
cabeza_de(T, Cabeza) :-
    (   T = (C0 --> _)
    ->  (   C0 = (C1, _)
        ->  true
        ;   C1 = C0
        ),
        sin_calificar(C1, C2),
        C2 =.. Partes0,
        append(Partes0, [_, _], Partes),
        Cabeza =.. Partes
    ;   cabeza_cuerpo(T, C0, _),
        sin_calificar(C0, Cabeza)
    ).

%!  sin_calificar(+C0, -C) is det.
%
%   C es C0 sin la calificación de módulo.
sin_calificar(C0, C) :-
    (   C0 = _:C1
    ->  sin_calificar(C1, C)
    ;   C = C0
    ).

%!  separadas(+Leidos:list, -Avisos:list) is det.
%
%   Avisos tiene un aviso separadas(PI) por cada predicado cuyas cláusulas
%   no son consecutivas entre las cláusulas del archivo, en la posición
%   de cada tramo que aparece lejos del primero. Las directivas no cuentan,
%   y un predicado declarado discontiguous, multifile o dynamic no merece
%   aviso: el sistema tampoco lo advierte.
separadas(Leidos, Avisos) :-
    findall(PI-P, clausula_leida(Leidos, leido(_, P, _, _), PI), Pares),
    findall(PI, ( member(leido((:- D), _, _, _), Leidos),
                  D =.. [Declaracion, E],
                  memberchk(Declaracion, [discontiguous, multifile, dynamic]),
                  lista_de_especificaciones(E, PIs0),
                  member(PI0, PIs0),
                  sin_calificar(PI0, PI) ),
            Declarados),
    tramos(Pares, Tramos),
    findall(aviso(P, separadas, PI),
            ( append(Antes, [PI-P|_], Tramos),
              memberchk(PI-_, Antes),
              \+ memberchk(PI, Declarados) ),
            Avisos).

%!  tramos(+Pares:list, -Tramos:list) is det.
%
%   Tramos son los pares PI-Posicion de Pares que empiezan un tramo de
%   cláusulas consecutivas del mismo predicado.
tramos([], []).
tramos([PI-P|Pares], [PI-P|Tramos]) :-
    saltar(Pares, PI, Resto),
    tramos(Resto, Tramos).

%!  saltar(+Pares:list, +PI, -Resto:list) is det.
%
%   Resto es Pares sin las cláusulas de PI con las que empieza.
saltar([], _, []).
saltar([Q-P|Pares], PI, Resto) :-
    (   Q == PI
    ->  saltar(Pares, PI, Resto)
    ;   Resto = [Q-P|Pares]
    ).

%!  documentacion(+Leidos:list, -Avisos:list) is det.
%
%   Avisos tiene un aviso por cada predicado del archivo que no está
%   documentado como el curso pide: sin_encabezado si tiene alguna regla y
%   ningún comentario %! antes de su primera cláusula; sin_comentario si es
%   solo hechos y no tiene comentario antes del primero.
documentacion(Leidos, Avisos) :-
    findall(PI, clausula_leida(Leidos, _, PI), PIs0),
    list_to_set(PIs0, PIs),
    findall(Aviso,
            ( member(PI, PIs),
              once(clausula_leida(Leidos, leido(_, P, _, Cs), PI)),
              aviso_de_documentacion(Leidos, PI, P, Cs, Aviso) ),
            Avisos).

%!  aviso_de_documentacion(+Leidos, +PI, +P, +Comentarios, -Aviso) is semidet.
%
%   Aviso es el aviso sobre la documentación de PI, cuya primera cláusula
%   está en P y va precedida por Comentarios. Falla si no hace falta.
aviso_de_documentacion(Leidos, PI, P, Comentarios, Aviso) :-
    (   tiene_regla(Leidos, PI)
    ->  \+ ( member(C, Comentarios),
             sub_string(C, 0, _, _, "%!") ),
        Aviso = aviso(P, sin_encabezado, PI)
    ;   Comentarios == [],
        Aviso = aviso(P, sin_comentario, PI)
    ).

%!  tiene_regla(+Leidos:list, +PI) is semidet.
%
%   Alguna cláusula de PI en Leidos es una regla, o una regla de gramática
%   cuyo cuerpo no es solo una lista de terminales.
tiene_regla(Leidos, PI) :-
    clausula_leida(Leidos, leido(T, _, _, _), PI),
    (   T = (_ --> Cuerpo),
        \+ is_list(Cuerpo)
    ;   T = (_ :- Cuerpo),
        Cuerpo \== true
    ),
    !.
