:- encoding(utf8).

% Capítulo 65 - Ampliación: el programa pretendido.
%
% Flach da a la negación una semántica declarativa transformando el
% programa en otro, completo, que tiene un solo modelo. Con el supuesto de
% mundo cerrado, cwa/2 agrega la negación de cada átomo de la base de
% Herbrand que no se deduce; vale para programas sin negaciones. La
% compleción de Clark, que complecion_de/3 del capítulo 38 construye para
% un predicado, se aplica aquí al programa entero: completar/2 completa
% cada predicado definido y cada predicado que se usa sin definirse, que
% queda equivalente a falso. modelos/2 busca los modelos de la compleción
% entre todas las interpretaciones de Herbrand: el programa de Tweety
% tiene uno; el del sabio y el docente, con una recursión a través de la
% negación, ninguno.
%
% Los programas son listas de cláusulas Cabeza :- Cuerpo, con un hecho
% escrito Cabeza :- true, que se agregan a los de sld.pl con generado/2.
%
% solo-local: carga un archivo de otro capítulo.
%
%?- escribir_complecion(gusta).
%?- modelos(tweety, Ms).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- ensure_loaded('../capitulo-38/sld').

:- multifile generado/2.

% generado(Nombre, Clausulas): los programas de los ejemplos de Flach.
generado(gusta,
    [ (gusta(pedro, S) :- alumno_de(S, pedro)),
      (alumno_de(pablo, pedro) :- true)
    ]).
generado(gusta_mas,
    [ (gusta(pedro, S) :- alumno_de(S, pedro)),
      (alumno_de(pablo, pedro) :- true),
      (gusta(pablo, _) :- true)
    ]).
generado(tweety,
    [ (ave(tweety) :- true),
      (vuela(X) :- ave(X), \+ anormal(X))
    ]).
generado(sabio,
    [ (sabio(X) :- \+ docente(X)),
      (docente(pedro) :- sabio(pedro))
    ]).

%!  completar(+Nombre, -Formulas:list) is det.
%
%   Formulas es la compleción del programa Nombre: la definición
%   completada de cada predicado que aparece en él, en una cabeza o en un
%   cuerpo, en orden de aparición. Un predicado sin cláusulas queda
%   equivalente a falso.
completar(Nombre, Formulas) :-
    clausulas(Nombre, Clausulas),
    predicados(Clausulas, Predicados),
    maplist(complecion_de(Clausulas), Predicados, Formulas).

%!  predicados(+Clausulas:list, -Predicados:list) is det.
%
%   Predicados son los Nombre/Aridad de las cabezas y después los de los
%   cuerpos, sin repetidos.
predicados(Clausulas, Predicados) :-
    findall(N/A, ( member((H :- _), Clausulas), functor(H, N, A) ), Ps1),
    findall(N/A,
            ( member((_ :- B), Clausulas),
              conjuncion_lista(B, Ls),
              member(L, Ls),
              atomo(L, At),
              functor(At, N, A) ),
            Ps2),
    append(Ps1, Ps2, Ps),
    list_to_set(Ps, Predicados).

%!  atomo(+Literal, -Atomo) is det.
%
%   Atomo es Literal sin la negación.
atomo(\+ A, A) :-
    !.
atomo(A, A).

%!  escribir_complecion(+Nombre) is det.
%
%   Escribe una fórmula por línea de la compleción del programa Nombre,
%   con las variables como A, B, ...
escribir_complecion(Nombre) :-
    completar(Nombre, Formulas),
    forall(member(F, Formulas),
           \+ \+ ( numbervars(F, 0, _),
                   format("~p~n", [F]) )).

%!  universo(+Nombre, -Constantes:list) is det.
%
%   Constantes son los átomos que aparecen como argumentos en el programa
%   Nombre, ordenados.
universo(Nombre, Constantes) :-
    clausulas(Nombre, Clausulas),
    findall(C,
            ( member((H :- B), Clausulas),
              conjuncion_lista(B, Ls),
              member(L, [H|Ls]),
              atomo(L, At),
              compound(At),
              arg(_, At, C),
              atom(C) ),
            Cs),
    sort(Cs, Constantes).

%!  base(+Nombre, -Atomos:list) is det.
%
%   Atomos es la base de Herbrand del programa Nombre: cada predicado del
%   programa aplicado a cada combinación de constantes, ordenada.
base(Nombre, Atomos) :-
    clausulas(Nombre, Clausulas),
    predicados(Clausulas, Ps),
    universo(Nombre, Cs),
    findall(At,
            ( member(N/A, Ps),
              length(Args, A),
              maplist(elegir(Cs), Args),
              At =.. [N|Args] ),
            As),
    sort(As, Atomos).

%!  elegir(+Constantes:list, -C) is nondet.
%
%   C es una de las Constantes.
elegir(Constantes, C) :-
    member(C, Constantes).

%!  modelos(+Nombre, -Modelos:list) is det.
%
%   Modelos son las interpretaciones de Herbrand del programa Nombre, como
%   listas ordenadas de átomos verdaderos, que satisfacen su compleción.
modelos(Nombre, Modelos) :-
    completar(Nombre, Formulas),
    base(Nombre, Base),
    universo(Nombre, U),
    findall(I,
            ( subconjunto(Base, I),
              forall(member(F, Formulas), definicion_vale(F, I, U)) ),
            Modelos).

%!  subconjunto(+Lista:list, -Sub:list) is multi.
%
%   Sub es una sublista de Lista, en el mismo orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).

%!  definicion_vale(+Formula, +I:list, +U:list) is semidet.
%
%   La definición completada Formula, sii(Cabeza, Definicion), vale en la
%   interpretación I para todos los valores de las variables de Cabeza en
%   el universo U.
definicion_vale(sii(Cabeza, Definicion), I, U) :-
    term_variables(Cabeza, Xs),
    forall(maplist(elegir(U), Xs),
           verdad(sii(Cabeza, Definicion), I, U)).

%!  verdad(+Formula, +I:list, +U:list) is semidet.
%
%   Formula, sin variables libres salvo las de un existe/2, es verdadera
%   en la interpretación I, la lista de los átomos verdaderos, con las
%   variables cuantificadas tomando valores en el universo U.
verdad(sii(A, B), I, U) :-
    !,
    (   verdad(A, I, U)
    ->  verdad(B, I, U)
    ;   \+ verdad(B, I, U)
    ).
verdad(existe(Vs, F), I, U) :-
    !,
    \+ \+ ( maplist(elegir(U), Vs),
            verdad(F, I, U) ).
verdad((A ; B), I, U) :-
    !,
    (   verdad(A, I, U)
    ->  true
    ;   verdad(B, I, U)
    ).
verdad((A, B), I, U) :-
    !,
    verdad(A, I, U),
    verdad(B, I, U).
verdad(\+ A, I, U) :-
    !,
    \+ verdad(A, I, U).
verdad(true, _, _) :-
    !.
verdad(falso, _, _) :-
    !,
    fail.
verdad(X = Y, _, _) :-
    !,
    X == Y.
verdad(Atomo, I, _) :-
    memberchk(Atomo, I).

%!  modelo_minimo(+Nombre, -Modelo:list) is det.
%
%   Modelo son los átomos que se deducen del programa Nombre, que no tiene
%   negaciones: se agregan las cabezas de las instancias cuyos cuerpos ya
%   están en el modelo hasta que no aparece ninguna nueva.
modelo_minimo(Nombre, Modelo) :-
    clausulas(Nombre, Clausulas),
    universo(Nombre, U),
    deducir(Clausulas, U, [], Modelo).

%!  deducir(+Clausulas:list, +U:list, +M0:list, -M:list) is det.
%
%   M es el menor punto fijo que contiene a M0.
deducir(Clausulas, U, M0, M) :-
    findall(H,
            ( member(C, Clausulas),
              copy_term(C, (H :- B)),
              conjuncion_lista(B, Ls),
              maplist(en_modelo(M0), Ls),
              term_variables(H, Vs),
              maplist(elegir(U), Vs) ),
            Nuevos),
    append(M0, Nuevos, M1),
    sort(M1, M2),
    (   M2 == M0
    ->  M = M0
    ;   deducir(Clausulas, U, M2, M)
    ).

%!  en_modelo(+Modelo:list, ?Atomo) is nondet.
%
%   Atomo unifica con uno de los átomos del Modelo.
en_modelo(Modelo, Atomo) :-
    member(Atomo, Modelo).

%!  cwa(+Nombre, -Negados:list) is det.
%
%   Negados son los átomos de la base de Herbrand del programa Nombre que
%   no se deducen de él: lo que el supuesto de mundo cerrado agrega como
%   falso.
cwa(Nombre, Negados) :-
    base(Nombre, Base),
    modelo_minimo(Nombre, Modelo),
    subtract(Base, Modelo, Negados).
