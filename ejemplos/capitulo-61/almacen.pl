:- encoding(utf8).

% Capítulo 61 - Versión 3: puntos de elección, almacén y rastro.
%
% Las variables del programa objeto dejan de ser variables de Prolog. Un
% término del programa objeto es un término de Prolog sin variables, en el
% que la variable número N es la celda '$v'(N); el functor '$v'/1 queda
% reservado para la máquina. El almacén, un árbol AVL de library(assoc),
% guarda el valor de cada celda ligada, y unificar/5 es la unificación
% escrita en Prolog, sin prueba de ocurrencia. Cada cláusula se traduce una
% vez: sus variables se numeran desde 0, y usarla es sumarles la primera
% celda libre.
%
% Un punto de elección guarda la resolvente de la llamada, las cláusulas
% que faltan probar, el largo del rastro y la primera celda libre. El
% rastro anota cada celda ligada que existía antes del último punto de
% elección; volver atrás es borrar del almacén esas ligaduras. La máquina
% no copia nada al crear una alternativa: la resolvente es un término sin
% variables, y el punto de elección la comparte.
%
% ejecutar/5 es el ciclo de la máquina, con la versión como parámetro: el
% módulo que se le pasa define paso/5 y volver/3. Este módulo define los
% suyos, y las versiones 4 y 5 cargan este archivo y definen otros.
%
% solo-local: carga el módulo programas.
%
%?- resolver(familia, abuelo(juan, N)).
%?- medir(listas, suma_hasta(100, S), M).
%?- compilar_meta(concatenar(X, Y, [a]), Q, N).

:- module(almacen,
          [ resolver/2,
            medir/3,
            resolver_con/3,
            resolver_clausulas/3,
            medir_con/4,
            medir_clausulas/4,
            ejecutar/5,
            paso/5,
            compilar/2,
            compilar_clausula/2,
            compilar_meta/3,
            procedimiento/3,
            renombrar/3,
            desreferenciar/3,
            unificar/5,
            ligar/5,
            reconstruir/3,
            ejecutar_predefinida/4,
            marca/2,
            deshacer/3,
            contar_intento/2
          ]).

:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(programas).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa objeto Nombre: una
%   respuesta por cada demostración, en el orden de Prolog.
resolver(Nombre, Meta) :-
    resolver_con(almacen, Nombre, Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de la búsqueda completa de Meta con el programa
%   objeto Nombre, como las describe medir_con/4.
medir(Nombre, Meta, Medidas) :-
    medir_con(almacen, Nombre, Meta, Medidas).

%!  resolver_con(+Version:atom, +Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con el programa objeto Nombre en la máquina de la
%   Version, el módulo que define paso/5 y volver/3.
resolver_con(Version, Nombre, Meta) :-
    programa(Nombre, Clausulas),
    resolver_clausulas(Version, Clausulas, Meta).

%!  resolver_clausulas(+Version:atom, +Clausulas:list, ?Meta) is nondet.
%
%   Meta se prueba con las Clausulas, de la forma Cabeza :- Cuerpo, en la
%   máquina de la Version. Si al dar una respuesta no quedan puntos de
%   elección, la respuesta es la última y no deja alternativas.
resolver_clausulas(Version, Clausulas, Meta) :-
    compilar_meta(Meta, Consulta, Libre),
    ejecutar(Version, Clausulas, Consulta, Libre, Evento),
    respuesta(Evento, m(_, _, Almacen, _, _, _)),
    reconstruir(Consulta, Almacen, Meta).

%!  respuesta(+Evento, -Estado) is semidet.
%
%   Estado es el estado de la máquina al dar una respuesta.
respuesta(respuesta(Estado), Estado).
respuesta(ultima(Estado), Estado).

%!  medir_con(+Version:atom, +Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son los pares respuestas-R, pasos-P, intentos-I, metas-M,
%   elecciones-E, rastro-T y celdas-C de la búsqueda completa de Meta con
%   el programa objeto Nombre en la máquina de la Version: R respuestas, P
%   metas tomadas de la resolvente, I cabezas de cláusula unificadas o
%   intentadas, y como máximo M metas en la resolvente, E puntos de
%   elección y T celdas en el rastro; C celdas usadas en total.
medir_con(Version, Nombre, Meta, Medidas) :-
    programa(Nombre, Clausulas),
    medir_clausulas(Version, Clausulas, Meta, Medidas).

%!  medir_clausulas(+Version:atom, +Clausulas:list, +Meta, -Medidas:list)
%!      is det.
%
%   Como medir_con/4, con las Clausulas del programa en lugar de su nombre.
medir_clausulas(Version, Clausulas, Meta,
                [ respuestas-R, pasos-P, intentos-I, metas-M, elecciones-E,
                  rastro-T, celdas-C
                ]) :-
    compilar_meta(Meta, Consulta, Libre),
    findall(Evento, ejecutar(Version, Clausulas, Consulta, Libre, Evento),
            Eventos),
    exclude(es_fin, Eventos, Respuestas),
    length(Respuestas, R),
    last(Eventos, Ultimo),
    arg(1, Ultimo, m(_, _, _, _, C, med(P, I, M, E, T))).

%!  es_fin(+Evento) is semidet.
%
%   Evento es el fin de la búsqueda.
es_fin(fin(_)).

%!  ejecutar(+Version:atom, +Clausulas:list, +Consulta, +Libre:integer,
%!           -Evento) is multi.
%
%   Evento es, en orden, respuesta(Estado) por cada respuesta de la
%   Consulta, ya traducida, que deja puntos de elección, ultima(Estado) si
%   la última no deja ninguno, o fin(Estado) al agotar la búsqueda. Libre
%   es la primera celda que la Consulta no usa.
ejecutar(Version, Clausulas, Consulta, Libre, Evento) :-
    Version:compilar(Clausulas, Tabla),
    cuerpo_lista(Consulta, Metas),
    empty_assoc(Almacen),
    ciclo(Version, Tabla, m(Metas, [], Almacen, [], Libre, med(0, 0, 0, 0, 0)),
          Evento).

%!  ciclo(+Version:atom, +Tabla, +Estado, -Evento) is multi.
%
%   Evento es lo que ocurre al hacer funcionar la máquina desde el Estado.
%   El estado es m(Metas, Pila, Almacen, Rastro, Libre, Medidas).
ciclo(Version, Tabla, Estado0, Evento) :-
    medir_estado(Estado0, Estado),
    Estado = m(Metas, _, _, _, _, _),
    ciclo(Metas, Version, Tabla, Estado, Evento).

%!  ciclo(+Metas:list, +Version:atom, +Tabla, +Estado, -Evento) is multi.
%
%   Con la resolvente vacía hay una respuesta; si no, un paso sobre la
%   primera meta, y si el paso falla, se vuelve atrás.
ciclo([], Version, Tabla, Estado, Evento) :-
    Estado = m(_, Pila, _, _, _, _),
    exito(Pila, Version, Tabla, Estado, Evento).
ciclo([Meta|Metas], Version, Tabla, Estado0, Evento) :-
    contar_paso(Estado0, Estado1),
    Version:paso(Meta, Metas, Tabla, Estado1, Resultado),
    seguir(Resultado, Version, Tabla, Evento).

%!  seguir(+Resultado, +Version:atom, +Tabla, -Evento) is multi.
%
%   Sigue el ciclo con el estado de sigue(Estado), o vuelve atrás desde el
%   de falla(Estado).
seguir(sigue(Estado), Version, Tabla, Evento) :-
    ciclo(Version, Tabla, Estado, Evento).
seguir(falla(Estado), Version, Tabla, Evento) :-
    retroceder(Version, Tabla, Estado, Evento).

%!  exito(+Pila:list, +Version:atom, +Tabla, +Estado, -Evento) is multi.
%
%   Evento es la respuesta del Estado; si la Pila tiene puntos de elección,
%   después siguen los eventos de volver atrás.
exito([], _, _, Estado, ultima(Estado)).
exito([_|_], Version, Tabla, Estado, Evento) :-
    (   Evento = respuesta(Estado)
    ;   retroceder(Version, Tabla, Estado, Evento)
    ).

%!  retroceder(+Version:atom, +Tabla, +Estado, -Evento) is multi.
%
%   Vuelve al último punto de elección; si no hay ninguno, la búsqueda
%   termina.
retroceder(Version, Tabla, Estado0, Evento) :-
    Version:volver(Tabla, Estado0, Resultado),
    (   Resultado = sigue(Estado)
    ->  ciclo(Version, Tabla, Estado, Evento)
    ;   Resultado = fin(Estado),
        Evento = fin(Estado)
    ).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Resultado es sigue(Estado), con el estado de la máquina después de
%   probar Meta, la primera meta de la resolvente, seguida de Metas; o
%   falla(Estado), si Meta falla, con las medidas al día.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    clase(Meta, Clase),
    paso_clase(Clase, Metas, Tabla, Estado0, Resultado).

%!  paso_clase(+Clase, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5, con la meta ya clasificada. Esta versión no conoce el
%   corte: ! es una llamada a un predicado !/0 que no está definido.
paso_clase(verdad, Metas, _, m(_, P, A, R, L, M),
           sigue(m(Metas, P, A, R, L, M))).
paso_clase(conjuncion(X, Y), Metas, _, m(_, P, A, R, L, M),
           sigue(m([X, Y|Metas], P, A, R, L, M))).
paso_clase(corte, Metas, Tabla, Estado0, Resultado) :-
    paso_clase(usuario(!), Metas, Tabla, Estado0, Resultado).
paso_clase(predefinida(Meta), Metas, _, Estado0, Resultado) :-
    Estado0 = m(_, Pila, A0, R0, L, M),
    marca(Pila, Marca),
    (   ejecutar_predefinida(Meta, Marca, A0-R0, A-R)
    ->  Resultado = sigue(m(Metas, Pila, A, R, L, M))
    ;   Resultado = falla(Estado0)
    ).
paso_clase(usuario(Meta), Metas, Tabla, Estado0, Resultado) :-
    procedimiento(Tabla, Meta, Clausulas),
    llamar(Clausulas, Meta, Metas, Estado0, Resultado).

%!  llamar(+Clausulas:list, +Meta, +Metas:list, +Estado0, -Resultado)
%!      is det.
%
%   Prueba las Clausulas en orden con Meta, seguida de Metas. Antes de
%   usar una cláusula que no es la última, apila un punto de elección con
%   las que quedan. Resultado es sigue(Estado) con la primera cuya cabeza
%   unifica, o falla(Estado) si no hay ninguna.
llamar([Clausula|Clausulas], Meta, Metas, Estado0, Resultado) :-
    contar_intento(Estado0, Estado1),
    (   Clausulas == []
    ->  Estado2 = Estado1
    ;   apilar(eleccion([Meta|Metas], Clausulas), Estado1, Estado2)
    ),
    (   usar(Clausula, Meta, Metas, Estado2, Estado)
    ->  Resultado = sigue(Estado)
    ;   Clausulas == []
    ->  Resultado = falla(Estado1)
    ;   llamar(Clausulas, Meta, Metas, Estado1, Resultado)
    ).

%!  apilar(+Eleccion, +Estado0, -Estado) is det.
%
%   Estado tiene arriba de su pila el punto de elección
%   eleccion(Metas, Clausulas), completado con el largo del rastro y la
%   primera celda libre.
apilar(eleccion(Metas, Clausulas), m(Ms, Pila, A, R, L, M),
       m(Ms, [eleccion(Metas, Clausulas, N, L)|Pila], A, R, L, M)) :-
    length(R, N).

%!  usar(+Clausula, +Meta, +Metas:list, +Estado0, -Estado) is semidet.
%
%   Usa la Clausula, cl(K, Cabeza, Cuerpo) con K variables, para resolver
%   Meta: renombra la cabeza con las celdas libres, la unifica con Meta y
%   pone el cuerpo, renombrado, delante de Metas. Falla si la cabeza no
%   unifica.
usar(cl(K, Cabeza, Cuerpo), Meta, Metas, m(_, Pila, A0, R0, L0, M),
     m(Metas1, Pila, A, R, L, M)) :-
    renombrar(L0, Cabeza, Cabeza1),
    marca(Pila, Marca),
    unificar(Meta, Cabeza1, Marca, A0-R0, A-R),
    maplist(renombrar(L0), Cuerpo, Cuerpo1),
    append(Cuerpo1, Metas, Metas1),
    L is L0 + K.

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Resultado es sigue(Estado), con el estado de la máquina después de
%   volver al último punto de elección y usar una de las cláusulas que
%   guardaba; si ninguna sirve, vuelve al anterior. Sin puntos de
%   elección, Resultado es fin(Estado0).
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).

%!  volver_desde(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3, con al menos un punto de elección en la pila.
volver_desde(Tabla, m(_, [Eleccion|Pila], A0, R0, L, M), Resultado) :-
    Eleccion = eleccion([Meta|Metas], Clausulas, N, _),
    deshacer(N, A0-R0, A-R),
    llamar(Clausulas, Meta, Metas, m([Meta|Metas], Pila, A, R, L, M),
           Resultado0),
    (   Resultado0 = falla(Estado)
    ->  volver(Tabla, Estado, Resultado)
    ;   Resultado = Resultado0
    ).

%!  marca(+Pila:list, -Marca:integer) is det.
%
%   Marca es la primera celda libre al crearse el último punto de
%   elección, o 0 si no hay ninguno. Las celdas anteriores a la marca son
%   las que el rastro debe anotar al ligarlas.
marca([], 0).
marca([eleccion(_, _, _, Marca)|_], Marca).

%!  deshacer(+N:integer, +Estado0, -Estado) is det.
%
%   Estado, un par Almacen-Rastro, resulta de Estado0 al borrar las
%   ligaduras de las celdas anotadas en el rastro después de sus N
%   primeras entradas.
deshacer(N, A0-R0, A-R) :-
    length(R0, Largo),
    K is Largo - N,
    quitar(K, R0, A0, R, A).

%!  quitar(+K:integer, +Rastro0:list, +Almacen0, -Rastro:list, -Almacen)
%!      is det.
%
%   Quita K entradas del rastro y borra del almacén sus ligaduras.
quitar(K, R0, A0, R, A) :-
    (   K =:= 0
    ->  R = R0,
        A = A0
    ;   R0 = [Celda|R1],
        del_assoc(Celda, A0, _, A1),
        K1 is K - 1,
        quitar(K1, R1, A1, R, A)
    ).

%!  contar_paso(+Estado0, -Estado) is det.
%
%   Estado cuenta un paso más.
contar_paso(m(Metas, Pila, A, R, L, med(P0, I, M, E, T)),
            m(Metas, Pila, A, R, L, med(P, I, M, E, T))) :-
    P is P0 + 1.

%!  medir_estado(+Estado0, -Estado) is det.
%
%   Estado anota el tamaño de la resolvente, de la pila y del rastro, si
%   superan los máximos.
medir_estado(m(Metas, Pila, A, R, L, med(P, I, M0, E0, T0)),
             m(Metas, Pila, A, R, L, med(P, I, M, E, T))) :-
    length(Metas, NM),
    M is max(M0, NM),
    length(Pila, NE),
    E is max(E0, NE),
    length(R, NT),
    T is max(T0, NT).

%!  contar_intento(+Estado0, -Estado) is det.
%
%   Estado cuenta un intento más de usar una cláusula.
contar_intento(m(Ms, P, A, R, L, med(Pa, I0, M, E, T)),
               m(Ms, P, A, R, L, med(Pa, I, M, E, T))) :-
    I is I0 + 1.

%!  compilar(+Clausulas:list, -Tabla) is det.
%
%   Tabla asocia a cada indicador Nombre/Aridad la lista de sus cláusulas,
%   en el orden del programa, traducidas por compilar_clausula/2.
compilar(Clausulas, Tabla) :-
    maplist(compilar_clausula, Clausulas, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    list_to_assoc(Grupos, Tabla).

%!  compilar_clausula(+Clausula, -Par) is det.
%
%   Par es Nombre/Aridad-cl(K, Cabeza, Cuerpo): la Clausula, de la forma
%   Cabeza0 :- Cuerpo0, con sus K variables numeradas desde 0 y el cuerpo
%   como una lista de metas.
compilar_clausula((Cabeza0 :- Cuerpo0), Nombre/Aridad-cl(K, Cabeza, Cuerpo)) :-
    copy_term((Cabeza0 :- Cuerpo0), (Cabeza :- Cuerpo1)),
    term_variables((Cabeza :- Cuerpo1), Variables),
    numerar(Variables, 0, K),
    functor(Cabeza, Nombre, Aridad),
    cuerpo_lista(Cuerpo1, Cuerpo).

%!  compilar_meta(+Meta, -Consulta, -K:integer) is det.
%
%   Consulta es Meta con sus K variables reemplazadas por las celdas 0 a
%   K - 1.
compilar_meta(Meta, Consulta, K) :-
    copy_term(Meta, Consulta),
    term_variables(Consulta, Variables),
    numerar(Variables, 0, K).

%!  numerar(+Variables:list, +I0:integer, -I:integer) is det.
%
%   Liga cada una de las Variables a una celda, desde '$v'(I0); I es la
%   primera celda que queda sin usar.
numerar([], I, I).
numerar(['$v'(I0)|Variables], I0, I) :-
    I1 is I0 + 1,
    numerar(Variables, I1, I).

%!  cuerpo_lista(+Cuerpo, -Metas:list) is det.
%
%   Metas son las metas de la conjunción Cuerpo, en orden, sin true.
cuerpo_lista(Cuerpo, Metas) :-
    cuerpo_lista(Cuerpo, Metas, []).

%!  cuerpo_lista(+Cuerpo, -Metas:list, ?Resto:list) is det.
%
%   Como cuerpo_lista/2, con la lista diferencia Metas-Resto.
cuerpo_lista(Cuerpo, Metas, Resto) :-
    (   Cuerpo == true
    ->  Metas = Resto
    ;   Cuerpo = (A, B)
    ->  cuerpo_lista(A, Metas, Medio),
        cuerpo_lista(B, Medio, Resto)
    ;   Metas = [Cuerpo|Resto]
    ).

%!  procedimiento(+Tabla, +Meta, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas del predicado de Meta. Un predicado sin
%   cláusulas produce un error de existencia, como en Prolog.
procedimiento(Tabla, Meta, Clausulas) :-
    functor(Meta, Nombre, Aridad),
    (   get_assoc(Nombre/Aridad, Tabla, Clausulas)
    ->  true
    ;   existence_error(procedure, Nombre/Aridad)
    ).

%!  renombrar(+Base:integer, +Termino0, -Termino) is det.
%
%   Termino es Termino0 con cada celda '$v'(I) reemplazada por
%   '$v'(Base + I).
renombrar(Base, Termino0, Termino) :-
    (   Termino0 = '$v'(I)
    ->  N is Base + I,
        Termino = '$v'(N)
    ;   atomic(Termino0)
    ->  Termino = Termino0
    ;   compound_name_arguments(Termino0, Nombre, Args0),
        maplist(renombrar(Base), Args0, Args),
        compound_name_arguments(Termino, Nombre, Args)
    ).

%!  desreferenciar(+Termino0, +Almacen, -Termino) is det.
%
%   Termino es Termino0 si no es una celda ligada; si lo es, el resultado
%   de desreferenciar su valor.
desreferenciar(Termino0, Almacen, Termino) :-
    (   Termino0 = '$v'(N),
        get_assoc(N, Almacen, Valor)
    ->  desreferenciar(Valor, Almacen, Termino)
    ;   Termino = Termino0
    ).

%!  unificar(+X, +Y, +Marca:integer, +Estado0, -Estado) is semidet.
%
%   Unifica X e Y. Estado, un par Almacen-Rastro, agrega a Estado0 las
%   ligaduras necesarias; las de las celdas anteriores a Marca quedan
%   anotadas en el rastro. Falla si X e Y no unifican. No hace la prueba
%   de ocurrencia.
unificar(X0, Y0, Marca, Estado0, Estado) :-
    Estado0 = Almacen-_,
    desreferenciar(X0, Almacen, X),
    desreferenciar(Y0, Almacen, Y),
    (   X == Y
    ->  Estado = Estado0
    ;   X = '$v'(N)
    ->  ligar(N, Y, Marca, Estado0, Estado)
    ;   Y = '$v'(N)
    ->  ligar(N, X, Marca, Estado0, Estado)
    ;   compound(X),
        compound(Y),
        compound_name_arity(X, Nombre, Aridad),
        compound_name_arity(Y, Nombre, Aridad),
        compound_name_arguments(X, Nombre, Xs),
        compound_name_arguments(Y, Nombre, Ys),
        foldl(unificar_argumento(Marca), Xs, Ys, Estado0, Estado)
    ).

%!  unificar_argumento(+Marca:integer, +X, +Y, +Estado0, -Estado)
%!      is semidet.
%
%   unificar/5 con los argumentos en el orden de foldl/5.
unificar_argumento(Marca, X, Y, Estado0, Estado) :-
    unificar(X, Y, Marca, Estado0, Estado).

%!  ligar(+N:integer, +Valor, +Marca:integer, +Estado0, -Estado) is det.
%
%   Liga la celda N a Valor en el almacén, y la anota en el rastro si es
%   anterior a Marca.
ligar(N, Valor, Marca, Almacen0-Rastro0, Almacen-Rastro) :-
    put_assoc(N, Almacen0, Valor, Almacen),
    (   N < Marca
    ->  Rastro = [N|Rastro0]
    ;   Rastro = Rastro0
    ).

%!  reconstruir(+Termino0, +Almacen, -Termino) is det.
%
%   Termino es el término de Prolog que representa Termino0 con las
%   ligaduras del Almacen: cada celda libre es una variable de Prolog, la
%   misma en todas sus apariciones.
reconstruir(Termino0, Almacen, Termino) :-
    reconstruir(Almacen, _, Termino0, Termino).

%!  reconstruir(+Almacen, ?Celdas:list, +Termino0, -Termino) is det.
%
%   Como reconstruir/3; Celdas es una lista abierta de pares N-Variable,
%   un diccionario incompleto de las celdas libres ya encontradas.
reconstruir(Almacen, Celdas, Termino0, Termino) :-
    desreferenciar(Termino0, Almacen, Termino1),
    (   Termino1 = '$v'(N)
    ->  memberchk(N-Termino, Celdas)
    ;   atomic(Termino1)
    ->  Termino = Termino1
    ;   compound_name_arguments(Termino1, Nombre, Args0),
        maplist(reconstruir(Almacen, Celdas), Args0, Args),
        compound_name_arguments(Termino, Nombre, Args)
    ).

%!  ejecutar_predefinida(+Meta, +Marca:integer, +Estado0, -Estado)
%!      is semidet.
%
%   Ejecuta la meta predefinida Meta sobre el almacén. X = Y es la
%   unificación de la máquina; X is E evalúa E, reconstruida, y unifica
%   X con el valor; las demás se reconstruyen y las ejecuta Prolog.
ejecutar_predefinida(Meta, Marca, Estado0, Estado) :-
    Estado0 = Almacen-_,
    (   Meta = (X = Y)
    ->  unificar(X, Y, Marca, Estado0, Estado)
    ;   Meta = (X is E)
    ->  reconstruir(E, Almacen, E1),
        Valor is E1,
        unificar(X, Valor, Marca, Estado0, Estado)
    ;   reconstruir(Meta, Almacen, Meta1),
        ejecutar(Meta1),
        Estado = Estado0
    ).
