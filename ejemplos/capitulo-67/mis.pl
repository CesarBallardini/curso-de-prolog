:- encoding(utf8).

% Capítulo 67 - Inducción descendente incremental, con tipos.
%
% Los ejemplos llegan de a uno. Si un positivo no se deduce de la
% hipótesis, se busca con profundidad creciente una cláusula que lo cubra
% y no cubra los negativos vistos; si un negativo se deduce, se busca en
% su prueba una cláusula falsa y se la quita. Después de cada cambio se
% vuelven a procesar todos los ejemplos vistos. Es el esquema del sistema
% MIS de Shapiro, en la versión de Flach.
%
% Los argumentos tienen tipos: elemento o lista. Un refinamiento une dos
% variables del mismo tipo, reemplaza una variable de tipo lista por [] o
% por [X|Y], o agrega un literal cuyas variables son algunas de la
% cláusula, no todas. Así se pueden aprender relaciones entre listas, como
% append/3, que la versión 4 no puede expresar.
%
% solo-local: carga subsuncion.pl y usa variables globales para contar.
%
%?- aprender_mis(concatenar, H, T).
%?- aprender_mis(numerales, H, T).
%?- mostrar_mis(concatenar).

:- module(mis,
          [ literal/3,
            termino/3,
            refinar_tipado/3,
            buscar_tipada/6,
            probar_arbol/5,
            clausula_falsa/3,
            mis/4,
            aprender_mis/3,
            mostrar_mis/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- reexport(subsuncion, [mostrar/1]).

% --- El lenguaje de cada problema --------------------------------------------

% literal(P, L, Ts): en el problema P se puede usar el literal L, con los
% tipos Ts para sus variables.
literal(concatenar, append(X, Y, Z), [lista(X), lista(Y), lista(Z)]).
literal(numerales, listnum(X, Y), [lista(X), lista(Y)]).
literal(numerales, num(X, Y), [elemento(X), elemento(Y)]).

% termino(P, T, Ts): en el problema P, una variable de tipo T se puede
% reemplazar por el término de T, con los tipos Ts para sus variables.
termino(_, lista([]), []).
termino(_, lista([X|Y]), [elemento(X), lista(Y)]).

% fondo(P, A): el átomo A es un hecho del conocimiento de fondo de P.
fondo(numerales, num(1, uno)).
fondo(numerales, num(2, dos)).
fondo(numerales, num(3, tres)).
fondo(numerales, num(4, cuatro)).

% ejemplos(P, Ejs): la sucesión de ejemplos del problema P, en el orden en
% que llegan.
ejemplos(concatenar,
         [ pos(append([], [c, d], [c, d])),
           neg(append([], [a, b], [b, a])),
           neg(append([a, b], [c], [c])),
           neg(append([a], [c, d], [b, c, d])),
           neg(append([a], [c, d], [a, b, d])),
           pos(append([a], [c, d], [a, c, d]))
         ]).
ejemplos(numerales,
         [ pos(listnum([], [])),
           neg(listnum([uno], [uno])),
           neg(listnum([1, dos], [uno, dos])),
           pos(listnum([1], [uno])),
           neg(listnum([cuatro, dos], [4, dos])),
           pos(listnum([cuatro], [4]))
         ]).

% --- Refinamientos con tipos -----------------------------------------------------

%!  refinar_tipado(+P, +Nodo0, -Nodo) is nondet.
%
%   Nodo0 y Nodo son términos n(Clausula, Tipos), con Tipos la lista de
%   las variables de la cláusula con su tipo. Nodo es un refinamiento de
%   Nodo0 en el lenguaje de P, en este orden: un literal más con algunas
%   de las variables de la cláusula, dos variables del mismo tipo unidas,
%   o una variable reemplazada por un término de su tipo. Nodo0 no queda
%   ligado.
refinar_tipado(P, Nodo0, n((H :- B), Ts)) :-
    copy_term(Nodo0, n((H :- B0), Ts)),
    literal(P, L, TsL),
    length(TsL, NL),
    length(Ts, N),
    NL < N,
    elegir_variables(TsL, Ts),
    L \== H,
    \+ ( member(Otro, B0),
         Otro == L ),
    append(B0, [L], B).
refinar_tipado(_, Nodo0, n(C, Ts)) :-
    copy_term(Nodo0, n(C, Ts0)),
    append(Antes, [T|Despues], Ts0),
    append(Medio, [T2|Final], Despues),
    T =.. [Tipo, X],
    T2 =.. [Tipo, Y],
    X = Y,
    append([Antes, [T|Medio], Final], Ts).
refinar_tipado(P, Nodo0, n(C, Ts)) :-
    copy_term(Nodo0, n(C, Ts0)),
    select(T, Ts0, Resto),
    termino(P, T, TsNuevos),
    append(Resto, TsNuevos, Ts).

%!  elegir_variables(+TsL:list, +Ts:list) is nondet.
%
%   Une cada variable tipada de TsL con una variable distinta de Ts, del
%   mismo tipo.
elegir_variables([], _).
elegir_variables([T|TsL], Ts) :-
    select(T2, Ts, Resto),
    T =.. [Tipo, X],
    T2 =.. [Tipo, Y],
    X = Y,
    elegir_variables(TsL, Resto).

% --- La búsqueda de una cláusula ----------------------------------------------

%!  cubre_ext(+P, +C, +Vistos:list, +E) is semidet.
%
%   La cláusula C cubre el ejemplo E en forma extensional: la cabeza
%   unifica con E y cada literal del cuerpo es un positivo de Vistos o un
%   hecho de fondo de P. Nada queda ligado.
cubre_ext(P, (H :- B), Vistos, E) :-
    \+ \+ ( H = E,
            forall(member(L, B),
                   (   memberchk(pos(L), Vistos)
                   ;   fondo(P, L)
                   )) ).

%!  buscar_tipada(+P, +E, +Vistos:list, +Max:integer, -C,
%!                -N:integer) is semidet.
%
%   C es la primera cláusula, en profundidad creciente hasta Max
%   refinamientos, que cubre E y ningún negativo de Vistos; N es la
%   cantidad de nodos generados. Falla si no la hay.
buscar_tipada(P, E, Vistos, Max, C, N) :-
    functor(E, Nombre, Aridad),
    functor(H, Nombre, Aridad),
    once(literal(P, H, Ts)),
    between(0, Max, D),
    nb_setval(mis_nodos, 0),
    buscar_d(D, P, E, Vistos, n((H :- []), Ts), C),
    !,
    nb_getval(mis_nodos, N).

%!  buscar_d(+D:integer, +P, +E, +Vistos:list, +Nodo, -C) is nondet.
%
%   Búsqueda en profundidad desde Nodo con a lo sumo D refinamientos.
buscar_d(_, P, E, Vistos, n(C, _), C) :-
    cubre_ext(P, C, Vistos, E),
    \+ ( member(neg(N), Vistos),
         cubre_ext(P, C, Vistos, N) ).
buscar_d(D, P, E, Vistos, Nodo, C) :-
    D > 0,
    D1 is D - 1,
    refinar_tipado(P, Nodo, Hijo),
    nb_getval(mis_nodos, K),
    K1 is K + 1,
    nb_setval(mis_nodos, K1),
    buscar_d(D1, P, E, Vistos, Hijo, C).

% --- La prueba y la cláusula falsa ---------------------------------------------

%!  probar_arbol(+D:integer, +P, +H:list, +Meta, -Arbol) is nondet.
%
%   Meta se deduce de las cláusulas de H y de los hechos de fondo de P con
%   a lo sumo D pasos con cláusulas de H; Arbol es la prueba: fondo(Meta)
%   o regla(Meta, C, Hijos), con C la cláusula usada.
probar_arbol(_, P, _, Meta, fondo(Meta)) :-
    fondo(P, Meta).
probar_arbol(D, P, H, Meta, regla(Meta, C, Hijos)) :-
    D > 0,
    D1 is D - 1,
    member(C, H),
    copy_term(C, (Meta :- Cuerpo)),
    maplist(probar_arbol(D1, P, H), Cuerpo, Hijos).

%!  clausula_falsa(+Arbol, +Vistos:list, -X) is det.
%
%   X es una cláusula de la prueba Arbol que es falsa: su cuerpo, en esa
%   prueba, tiene solo hechos de fondo y positivos de Vistos, y su cabeza
%   no es un positivo. X es ok si la prueba no tiene una.
clausula_falsa(fondo(_), _, ok).
clausula_falsa(regla(Meta, C, Hijos), Vistos, X) :-
    (   memberchk(pos(Meta), Vistos)
    ->  X = ok
    ;   foldl(primera_falsa(Vistos), Hijos, ok, X0),
        (   X0 == ok
        ->  X = C
        ;   X = X0
        )
    ).

%!  primera_falsa(+Vistos:list, +Arbol, +X0, -X) is det.
%
%   X es X0 si ya es una cláusula falsa; si no, la de Arbol.
primera_falsa(Vistos, Arbol, X0, X) :-
    (   X0 == ok
    ->  clausula_falsa(Arbol, Vistos, X)
    ;   X = X0
    ).

% --- El ciclo de los ejemplos ------------------------------------------------------

%!  mis(+P, +Ejemplos:list, -H:list, -Traza:list) is semidet.
%
%   H es la hipótesis para los Ejemplos de P, procesados en orden; Traza
%   son los cambios, en orden: agregada(C) o quitada(C). Falla si un
%   positivo no tiene cláusula con a lo sumo 4 refinamientos.
mis(P, Ejemplos, H, Traza) :-
    once(procesar(P, Ejemplos, [], [], H, Traza, [])).

%!  procesar(+P, +Ejs:list, +Vistos:list, +H0:list, -H:list,
%!           -Traza:list, ?Resto:list) is semidet.
%
%   Procesa los ejemplos Ejs con la hipótesis H0, después de los Vistos
%   (el más reciente primero). Traza-Resto es la lista de los cambios.
procesar(_, [], _, H, H, T, T).
procesar(P, [Ej|Ejs], Vistos, H0, H, T0, T) :-
    procesar_uno(P, Ej, Vistos, H0, H1, T0, T1),
    procesar(P, Ejs, [Ej|Vistos], H1, H, T1, T).

%!  procesar_uno(+P, +Ej, +Vistos:list, +H0:list, -H:list, -Traza:list,
%!               ?Resto:list) is semidet.
%
%   H es la hipótesis después de ver Ej: igual a H0 si la clasifica bien;
%   si no, generalizada o especializada, y vuelta a probar con Ej y todos
%   los ejemplos vistos, del más reciente al más antiguo.
procesar_uno(P, pos(E), Vistos, H0, H, T0, T) :-
    (   deducido(P, H0, E)
    ->  H = H0,
        T0 = T
    ;   buscar_tipada(P, E, [pos(E)|Vistos], 4, C, _),
        T0 = [agregada(C)|T1],
        procesar(P, [pos(E)|Vistos], [], [C|H0], H, T1, T)
    ).
procesar_uno(P, neg(E), Vistos, H0, H, T0, T) :-
    (   once(probar_arbol(10, P, H0, E, Arbol))
    ->  clausula_falsa(Arbol, Vistos, C),
        C \== ok,
        once(select(C, H0, H1)),
        T0 = [quitada(C)|T1],
        procesar(P, [neg(E)|Vistos], [], H1, H, T1, T)
    ;   H = H0,
        T0 = T
    ).

%!  deducido(+P, +H:list, +E) is semidet.
%
%   E se deduce de H y del fondo de P en a lo sumo 10 pasos.
deducido(P, H, E) :-
    once(probar_arbol(10, P, H, E, _)).

%!  aprender_mis(+P, -H:list, -Traza:list) is semidet.
%
%   H y Traza son las de mis/4 con los ejemplos del problema P.
aprender_mis(P, H, Traza) :-
    ejemplos(P, Ejs),
    mis(P, Ejs, H, Traza).

%!  mostrar_mis(+P) is semidet.
%
%   Escribe los cambios de aprender_mis/3 para el problema P, uno por
%   línea, y después la hipótesis, como reglas de Prolog.
mostrar_mis(P) :-
    aprender_mis(P, H, Traza),
    forall(member(Cambio, Traza),
           ( Cambio =.. [Accion, C],
             format("~w: ", [Accion]),
             mostrar(C) )),
    format("Hipótesis:~n"),
    forall(member(C, H), mostrar(C)).
