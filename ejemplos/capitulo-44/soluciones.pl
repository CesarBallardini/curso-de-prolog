:- encoding(utf8).

% Capítulo 44 - Soluciones de los ejercicios 4, 5, 6, 7, 9, 11 y 12. Cada
% una extiende la aventura sin modificar los archivos del capítulo: usa lo
% que exportan, y algunos no terminales de lenguaje.pl calificados con el
% módulo.
%
% solo-local: carga los módulos del capítulo, y SWISH no admite módulos
% propios.
%
%?- iniciar, ejecutar_varias("biblioteca y tomar la llave", S).

:- module(soluciones,
          [ entender_con_origen/2,
            ejecutar_varias/2,
            partida_con_limite/2,
            ejecutar_con_todo/2,
            guardar_con_formato/1,
            cargar_con_formato/1,
            menu_por_inicial/3,
            partida_con_deshacer/1
          ]).

:- reexport(juego).

% Ejercicio 4

%!  entender_con_origen(+Texto:string, -Orden) is det.
%
%   Como entender/2, pero una orden de tomar puede nombrar el recipiente
%   de donde sale el objeto: «sacar la lente del baúl». Esa lectura exige
%   que el objeto esté en el recipiente.
entender_con_origen(Texto, Orden) :-
    palabras(Texto, Palabras),
    (   phrase(tomar_de(O), Palabras)
    ->  Orden = tomar(O)
    ;   entender(Texto, Orden)
    ).

%!  tomar_de(?O)// is nondet.
%
%   Una orden de tomar O seguida del recipiente que lo contiene.
tomar_de(O) -->
    lenguaje:verbo(tomar),
    lenguaje:cosa(O),
    origen(R),
    { esta_en(O, R) }.

%!  origen(?R)// is nondet.
%
%   El recipiente R precedido de de o del.
origen(R) -->
    [del],
    lenguaje:nombrada(R),
    { nombre(R, m, _) }.
origen(R) -->
    [de],
    lenguaje:cosa(R).

% Ejercicio 5

%!  ejecutar_varias(+Texto:string, -Salida:string) is det.
%
%   Ejecuta las órdenes de Texto separadas por y, en orden, hasta la
%   primera que no se entiende o que un impedimento bloquea; Salida son
%   las respuestas de las que se intentaron.
ejecutar_varias(Texto, Salida) :-
    palabras(Texto, Palabras),
    segmentos(Palabras, Segmentos),
    maplist(texto_de_palabras, Segmentos, Textos),
    respuestas_en_orden(Textos, Respuestas),
    atomic_list_concat(Respuestas, ' ', Atomo),
    atom_string(Atomo, Salida).

%!  segmentos(+Palabras:list, -Segmentos:list(list)) is det.
%
%   Segmentos son los tramos de Palabras separados por la palabra y.
segmentos(Palabras, [Segmento|Segmentos]) :-
    (   append(Segmento, [y|Resto], Palabras)
    ->  segmentos(Resto, Segmentos)
    ;   Segmento = Palabras,
        Segmentos = []
    ).

%!  texto_de_palabras(+Palabras:list(atom), -Texto:string) is det.
%
%   Texto son Palabras separadas por blancos.
texto_de_palabras(Palabras, Texto) :-
    atomic_list_concat(Palabras, ' ', Atomo),
    atom_string(Atomo, Texto).

%!  respuestas_en_orden(+Textos:list(string), -Respuestas:list(string))
%!      is det.
%
%   Ejecuta las órdenes Textos hasta la primera bloqueada, incluida.
respuestas_en_orden([], []).
respuestas_en_orden([T|Ts], [R|Rs]) :-
    entender(T, Orden),
    (   (   Orden == no_entendido
        ;   impedimento(Orden, _)
        )
    ->  responder(Orden, R),
        Rs = []
    ;   responder(Orden, R),
        respuestas_en_orden(Ts, Rs)
    ).

% Ejercicio 6

%!  partida_con_limite(+In, +Maximo:integer) is det.
%
%   Como partida/1, pero termina con «Se terminó el tiempo.» después de
%   Maximo órdenes sin ganar.
partida_con_limite(In, Maximo) :-
    partida_con_limite(In, Maximo, 0).

%!  partida_con_limite(+In, +Maximo:integer, +Hechas:integer) is det.
%
%   Sigue la partida cuando ya se ejecutaron Hechas órdenes.
partida_con_limite(In, Maximo, Hechas) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   entender(Linea, Orden)
    ),
    responder(Orden, Texto),
    format("~w~n", [Texto]),
    Hechas1 is Hechas + 1,
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   Hechas1 >= Maximo
    ->  format("Se terminó el tiempo.~n")
    ;   partida_con_limite(In, Maximo, Hechas1)
    ).

% Ejercicio 7

%!  ejecutar_con_todo(+Texto:string, -Salida:string) is det.
%
%   Como ejecutar/2, y además entiende «tomar todo» con cualquier forma
%   del verbo tomar.
ejecutar_con_todo(Texto, Salida) :-
    palabras(Texto, Palabras),
    (   append(Verbo, [todo], Palabras),
        lenguaje:forma(tomar, Verbo)
    ->  tomar_todo(Salida)
    ;   ejecutar(Texto, Salida)
    ).

%!  tomar_todo(-Salida:string) is det.
%
%   Toma cada objeto que se puede tomar; Salida son las respuestas.
tomar_todo(Salida) :-
    findall(O, tomable(O), Os0),
    sort(Os0, Os),
    (   Os == []
    ->  Salida = "No hay nada para tomar."
    ;   maplist([O, T]>>responder(tomar(O), T), Os, Textos),
        atomic_list_concat(Textos, ' ', Atomo),
        atom_string(Atomo, Salida)
    ).

%!  tomable(?O) is nondet.
%
%   O es un objeto al alcance que se puede llevar y no está en el
%   inventario.
tomable(O) :-
    al_alcance(O),
    objeto(O),
    \+ fijo(O),
    \+ esta_en(O, jugador).

% Ejercicio 9

%!  guardar_con_formato(+Archivo) is det.
%
%   Como guardar/1, con el hecho formato(aventura, 1) en la primera línea.
guardar_con_formato(Archivo) :-
    instantanea(Hechos),
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(H, [formato(aventura, 1)|Hechos]),
               portray_clause(Out, H)),
        close(Out)).

%!  cargar_con_formato(+Archivo) is det.
%
%   Como cargar/1, pero produce un error de dominio, sin cambiar el
%   estado, si Archivo no empieza con formato(aventura, 1).
cargar_con_formato(Archivo) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        partidas:leer_terminos(In, Terminos),
        close(In)),
    (   Terminos = [formato(aventura, 1)|Hechos]
    ->  restablecer(Hechos)
    ;   domain_error(partida_con_formato_1, Archivo)
    ).

% Ejercicio 11

%!  menu_por_inicial(+In, +Opciones:list, -Valor) is det.
%
%   Como menu/3, pero se elige escribiendo la inicial de la opción.
%   Produce un error de dominio si dos opciones empiezan con la misma
%   letra: una de las dos no se podría elegir.
menu_por_inicial(In, Opciones, Valor) :-
    maplist(inicial, Opciones, Iniciales),
    (   sort(Iniciales, Distintas),
        same_length(Iniciales, Distintas)
    ->  elegir_por_inicial(In, Opciones, Iniciales, Valor)
    ;   domain_error(iniciales_distintas, Opciones)
    ).

%!  elegir_por_inicial(+In, +Opciones:list, +Iniciales:list, -Valor) is det.
%
%   Muestra Opciones y lee iniciales de In hasta que una es de ellas.
elegir_por_inicial(In, Opciones, Iniciales, Valor) :-
    forall(member(opcion(Texto, _), Opciones),
           format("~w~n", [Texto])),
    format("Elige una opción por su inicial: "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   normalize_space(string(Respuesta), Linea),
        inicial(opcion(Respuesta, _), I),
        nth1(N, Iniciales, I)
    ->  nth1(N, Opciones, opcion(_, Valor))
    ;   format("La respuesta no es una de las iniciales.~n"),
        elegir_por_inicial(In, Opciones, Iniciales, Valor)
    ).

%!  inicial(+Opcion, -I:atom) is semidet.
%
%   I es la primera letra del texto de Opcion, en minúscula. Falla si el
%   texto está vacío.
inicial(opcion(Texto, _), I) :-
    sub_atom(Texto, 0, 1, _, Letra),
    downcase_atom(Letra, I).

% Ejercicio 12

%!  partida_con_deshacer(+In) is det.
%
%   Como partida/1, y además entiende «deshacer», que vuelve al estado
%   anterior a la última orden que lo cambió.
partida_con_deshacer(In) :-
    partida_con_deshacer(In, []).

%!  partida_con_deshacer(+In, +Pila:list) is det.
%
%   Sigue la partida con Pila, las instantáneas anteriores a cada orden
%   que cambió el estado, la más reciente primero.
partida_con_deshacer(In, Pila0) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   palabras(Linea, [deshacer])
    ->  Orden = deshacer
    ;   entender(Linea, Orden)
    ),
    turno(Orden, Pila0, Pila, Texto),
    format("~w~n", [Texto]),
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   partida_con_deshacer(In, Pila)
    ).

%!  turno(+Orden, +Pila0:list, -Pila:list, -Texto:string) is det.
%
%   Ejecuta Orden y da su texto; Pila es Pila0 con la instantánea anterior
%   si Orden cambió el estado, o sin la última si Orden es deshacer.
turno(Orden, Pila0, Pila, Texto) :-
    (   Orden == deshacer
    ->  (   Pila0 = [Anterior|Pila]
        ->  restablecer(Anterior),
            responder(mirar, Vista),
            string_concat("Orden deshecha. ", Vista, Texto)
        ;   Pila = [],
            Texto = "No hay nada para deshacer."
        )
    ;   instantanea(Antes),
        responder(Orden, Texto),
        instantanea(Despues),
        (   Antes == Despues
        ->  Pila = Pila0
        ;   Pila = [Antes|Pila0]
        )
    ).
