:- encoding(utf8).

% Capítulo 68 - Versión 6: generalización basada en la explicación.
%
% ebg/5 prueba dos objetivos a la vez con las mismas reglas: el del
% ejemplo, con sus constantes, y una copia general, con variables en
% todos los argumentos. La prueba del ejemplo elige las reglas y los
% hechos; la copia general sigue las mismas reglas sin mirar los hechos,
% y así recibe solo las ligaduras que imponen las reglas. Donde la prueba
% llega a un objetivo operacional, o a un predefinido, la copia general
% de ese objetivo pasa a ser una condición. La regla aprendida tiene la
% copia general como cabeza y esas condiciones como cuerpo, una lista,
% como las cláusulas del capítulo 67, y se escribe con su mostrar/1.
%
% El criterio de operacionalidad es un argumento: la lista de predicados
% en los que la generalización se detiene. Por omisión son los que la
% descripción de un ejemplo contiene; un predicado definido por reglas
% también puede declararse operacional, y entonces la regla aprendida lo
% conserva sin desplegarlo.
%
% solo-local: carga archivos de otros capítulos.
%
%?- mostrar_aprendida(taza, taza1, taza(taza1)).
%?- mostrar_aprendida(familia, familia, abuelo(juan, luis)).

:- module(ebg,
          [ ebg/5,
            aprender/4,
            aprender_con/5,
            mostrar_aprendida/3,
            mostrar_aprendida_con/4,
            aplicar/4,
            reconocidas/3,
            reconocidas_de/2,
            costos/3,
            inferencias/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(explicacion).
:- reexport('../capitulo-67/subsuncion', [mostrar/1]).

%!  ebg(+T, +Ops:list, +Hs:list, +Meta, -Regla) is nondet.
%
%   Regla es la generalización de una prueba de Meta con la teoría T y
%   los hechos Hs, con los predicados de Ops como operacionales: un
%   término General :- Condiciones. Una respuesta por cada prueba.
ebg(T, Ops, Hs, Meta, (General :- Condiciones)) :-
    functor(Meta, Nombre, Aridad),
    functor(General, Nombre, Aridad),
    phrase(generalizar(T, Ops, Hs, Meta, General), Condiciones).

%!  generalizar(+T, +Ops:list, +Hs:list, +G, ?GG)// is nondet.
%
%   G se prueba con la teoría T y los hechos Hs, y GG, la copia general
%   de G, sigue las mismas reglas. La lista son las condiciones: las
%   copias generales de los objetivos predefinidos y operacionales en los
%   que la prueba se detiene.
generalizar(T, Ops, Hs, G, GG) -->
    (   { predefinido(G) }
    ->  { ejecutar(G) },
        [GG]
    ;   { functor(G, Nombre, Aridad),
          memberchk(Nombre/Aridad, Ops) }
    ->  { explicar(T, Hs, G, _) },
        [GG]
    ;   { regla(T, R),
          copy_term(R, (G :- Cuerpo)),
          copy_term(R, (GG :- CuerpoG)) },
        generalizar_cuerpo(T, Ops, Hs, Cuerpo, CuerpoG)
    ).

%!  generalizar_cuerpo(+T, +Ops:list, +Hs:list, +C, ?CG)// is nondet.
%
%   Generaliza cada objetivo de la conjunción C junto con el objetivo de
%   la misma posición en CG, de izquierda a derecha.
generalizar_cuerpo(T, Ops, Hs, C, CG) -->
    (   { C = (A, B) }
    ->  { CG = (AG, BG) },
        generalizar_cuerpo(T, Ops, Hs, A, AG),
        generalizar_cuerpo(T, Ops, Hs, B, BG)
    ;   { C == true }
    ->  []
    ;   generalizar(T, Ops, Hs, C, CG)
    ).

%!  aprender(+T, +E, +Meta, -Regla) is semidet.
%
%   Regla es la regla que se aprende de la primera prueba de Meta con la
%   teoría T y la descripción del ejemplo E, con los predicados
%   operacionales de T.
aprender(T, E, Meta, Regla) :-
    operacionales(T, Ops),
    aprender_con(T, Ops, E, Meta, Regla).

%!  aprender_con(+T, +Ops:list, +E, +Meta, -Regla) is semidet.
%
%   Como aprender/4, con el criterio de operacionalidad Ops.
aprender_con(T, Ops, E, Meta, Regla) :-
    hechos(E, Hs),
    once(ebg(T, Ops, Hs, Meta, Regla)).

%!  mostrar_aprendida(+T, +E, +Meta) is semidet.
%
%   Escribe como regla de Prolog la regla que aprender/4 aprende de Meta
%   con la teoría T y el ejemplo E.
mostrar_aprendida(T, E, Meta) :-
    aprender(T, E, Meta, Regla),
    mostrar(Regla).

%!  mostrar_aprendida_con(+T, +Ops:list, +E, +Meta) is semidet.
%
%   Como mostrar_aprendida/3, con el criterio de operacionalidad Ops.
mostrar_aprendida_con(T, Ops, E, Meta) :-
    aprender_con(T, Ops, E, Meta, Regla),
    mostrar(Regla).

%!  aplicar(+T, +Regla, +Hs:list, +Meta) is semidet.
%
%   La regla aprendida Regla prueba Meta con los hechos Hs: cada
%   condición se prueba con explicar/4 y la teoría T, que la resuelve
%   entre los hechos si es operacional en T y con las reglas si no lo es.
aplicar(T, Regla, Hs, Meta) :-
    copy_term(Regla, (Meta :- Condiciones)),
    condiciones(T, Hs, Condiciones),
    !.

%!  condiciones(+T, +Hs:list, +Cs:list) is nondet.
%
%   Todas las condiciones de Cs se prueban, con las mismas ligaduras.
condiciones(_, _, []).
condiciones(T, Hs, [C|Cs]) :-
    explicar(T, Hs, C, _),
    condiciones(T, Hs, Cs).

%!  reconocidas(+T, +Rs:list, -Tazas:list) is det.
%
%   Tazas son los objetos de la población que alguna de las reglas
%   aprendidas de Rs reconoce como tazas, probadas en el orden de Rs.
reconocidas(T, Rs, Tazas) :-
    poblacion(Os),
    findall(O, ( member(O-Hs, Os),
                 once(( member(R, Rs),
                        aplicar(T, R, Hs, taza(O)) )) ), Tazas).

%!  reconocidas_de(+Es:list, -Tazas:list) is det.
%
%   Tazas son los objetos de la población que reconocen las reglas
%   aprendidas de los ejemplos de Es, cada uno una taza de hechos/2.
reconocidas_de(Es, Tazas) :-
    findall(R, ( member(E, Es),
                 Meta =.. [taza, E],
                 aprender(taza, E, Meta, R) ), Rs),
    reconocidas(taza, Rs, Tazas).

%!  costos(-Teoria:integer, -Reglas:integer, -Una:integer) is det.
%
%   Inferencias que usa reconocer las tazas de la población: Teoria con
%   la teoría taza, Reglas con las reglas aprendidas de taza1 y taza2, y
%   Una con la regla aprendida de taza1 con liviano/1 operacional.
costos(Teoria, Reglas, Una) :-
    aprender(taza, taza1, taza(taza1), R1),
    aprender(taza, taza2, taza(taza2), R2),
    operacionales(taza, Ops),
    aprender_con(taza, [liviano/1|Ops], taza1, taza(taza1), R3),
    inferencias(clasificar_con_teoria(taza, _), Teoria),
    inferencias(reconocidas(taza, [R1, R2], _), Reglas),
    inferencias(reconocidas(taza, [R3], _), Una).

%!  inferencias(:Meta, -N:integer) is semidet.
%
%   N es la cantidad de inferencias que usa la primera prueba de Meta. Meta
%   se prueba una vez antes de medir, para que la carga automática de las
%   bibliotecas no entre en la cuenta.
inferencias(Meta, N) :-
    \+ \+ once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.
