:- encoding(utf8).

% Capítulo 48 - Soluciones de los ejercicios 2 a 9 y 11.
%
% Los circuitos se agregan a los del módulo circuitos, y los secuenciales a
% los del módulo secuenciales, con cláusulas multifile.
%
% solo-local: carga los módulos del proyecto, y SWISH no admite módulos
% propios.
%
%?- resta_correcta.
%?- equivalentes(mux, mux_nand).
%?- findall(Es, detecta(sumador, [m2, x1], 0, Es), Ess).
%?- ejecutar(detector, [0, 0], [[1], [0], [1], [0], [1], [1], [0], [1]], Ss).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(yall)).
:- use_module(circuitos).
:- use_module(formulas).
:- use_module(verificar).
:- use_module(secuenciales).
:- use_module(estados).

:- multifile circuitos:circuito/3, circuitos:componente/5.
:- multifile secuenciales:secuencial/3.

% Ejercicio 2

% El préstamo es 1 cuando a es 0 y b es 1.
circuitos:circuito(semirrestador, [a, b], [d, p]).
circuitos:componente(semirrestador, x1, xor, [a, b], [d]).
circuitos:componente(semirrestador, i1, inv, [a], [na]).
circuitos:componente(semirrestador, y1, and, [na, b], [p]).

circuitos:circuito(restador, [a, b, pi], [d, po]).
circuitos:componente(restador, r1, semirrestador, [a, b], [t, p1]).
circuitos:componente(restador, r2, semirrestador, [t, pi], [d, p2]).
circuitos:componente(restador, o1, or, [p1, p2], [po]).

circuitos:circuito(restador3, [a0, a1, a2, b0, b1, b2], [d0, d1, d2, p]).
circuitos:componente(restador3, r0, semirrestador, [a0, b0], [d0, p0]).
circuitos:componente(restador3, r1, restador, [a1, b1, p0], [d1, p1]).
circuitos:componente(restador3, r2, restador, [a2, b2, p1], [d2, p]).

%!  resta_correcta is semidet.
%
%   Para todo par de números X e Y de 0 a 7, restador3 da X - Y módulo 8, y
%   el préstamo final es 1 si X es menor que Y.
resta_correcta :-
    forall(( between(0, 7, X), between(0, 7, Y) ),
           ( bits3(X, [A0, A1, A2]),
             bits3(Y, [B0, B1, B2]),
             once(simular(restador3, [A0, A1, A2, B0, B1, B2],
                          [D0, D1, D2, P])),
             D0 + 2 * D1 + 4 * D2 =:= (X - Y) mod 8,
             (   X < Y
             ->  P =:= 1
             ;   P =:= 0
             )
           )).

%!  bits3(+N:integer, -Bits:list) is det.
%
%   Bits son los tres bits de N, el menos significativo primero.
bits3(N, [B0, B1, B2]) :-
    B0 is N /\ 1,
    B1 is (N >> 1) /\ 1,
    B2 is (N >> 2) /\ 1.

% Ejercicio 3

circuitos:circuito(mux, [s, a, b], [z]).
circuitos:componente(mux, i1, inv, [s], [ns]).
circuitos:componente(mux, y1, and, [ns, a], [u]).
circuitos:componente(mux, y2, and, [s, b], [v]).
circuitos:componente(mux, o1, or, [u, v], [z]).

circuitos:circuito(mux_nand, [s, a, b], [z]).
circuitos:componente(mux_nand, n1, nand, [s, s], [ns]).
circuitos:componente(mux_nand, n2, nand, [ns, a], [u]).
circuitos:componente(mux_nand, n3, nand, [s, b], [v]).
circuitos:componente(mux_nand, n4, nand, [u, v], [z]).

% Ejercicio 4

circuitos:circuito(inv_nand, [a], [z]).
circuitos:componente(inv_nand, n1, nand, [a, a], [z]).

circuitos:circuito(and_nand, [a, b], [z]).
circuitos:componente(and_nand, n1, nand, [a, b], [t]).
circuitos:componente(and_nand, n2, nand, [t, t], [z]).

circuitos:circuito(or_nand, [a, b], [z]).
circuitos:componente(or_nand, n1, nand, [a, a], [na]).
circuitos:componente(or_nand, n2, nand, [b, b], [nb]).
circuitos:componente(or_nand, n3, nand, [na, nb], [z]).

circuitos:circuito(inv1, [a], [z]).
circuitos:componente(inv1, g1, inv, [a], [z]).

circuitos:circuito(and1, [a, b], [z]).
circuitos:componente(and1, g1, and, [a, b], [z]).

circuitos:circuito(or1, [a, b], [z]).
circuitos:componente(or1, g1, or, [a, b], [z]).

% Ejercicio 5

%!  pegada(+Falla:list, +Valor, +Ruta:list, ?Tipo, ?Entradas:list, ?Salida)
%!      is nondet.
%
%   La conducta de un circuito en el que la compuerta de ruta Falla da
%   siempre Valor; las demás cumplen su tabla.
pegada(Falla, Valor, Ruta, Tipo, Entradas, Salida) :-
    (   Ruta == Falla
    ->  Salida = Valor
    ;   tabla(Tipo, Entradas, Salida)
    ).

%!  detecta(+Circuito, +Falla:list, +Valor, -Entradas:list) is nondet.
%
%   Con Entradas, Circuito con la compuerta Falla pegada a Valor da otras
%   salidas que Circuito sin fallas.
detecta(Circuito, Falla, Valor, Entradas) :-
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Entradas),
    maplist(bit, Entradas),
    once(simular(Circuito, Entradas, Salidas)),
    once(simular(pegada(Falla, Valor), Circuito, Entradas, ConFalla)),
    Salidas \== ConFalla.

% Ejercicio 6

%!  minterminos(+Circuito, +Salida, -Productos:list(list)) is det.
%
%   Productos tiene un producto por cada fila de la tabla de verdad de
%   Circuito en la que Salida vale 1, con un literal por entrada.
minterminos(Circuito, Salida, Productos) :-
    circuito(Circuito, Nombres, Salidas),
    nth1(I, Salidas, Salida),
    !,
    tabla_de_verdad(Circuito, Filas),
    findall(P,
            ( member(Es-Ss, Filas),
              nth1(I, Ss, 1),
              maplist(literal, Nombres, Es, P0),
              sort(P0, P) ),
            Productos0),
    sort(Productos0, Productos).

%!  literal(+Nombre, +Valor, -Literal) is det.
%
%   Literal es Nombre si Valor es 1, y ~Nombre si es 0.
literal(Nombre, 1, Nombre).
literal(Nombre, 0, ~Nombre).

% Ejercicio 7

%!  simplificar_consenso(+Productos:list(list), -Simples:list(list)) is det.
%
%   Simples es Productos simplificada y cerrada por consenso: agregar los
%   consensos de todos los pares y simplificar, hasta que no cambia.
simplificar_consenso(Productos, Simples) :-
    simplificar(Productos, Ps0),
    cerrar(Ps0, Simples).

%!  cerrar(+Productos:list(list), -Cerrados:list(list)) is det.
%
%   Productos está simplificada; Cerrados es el punto fijo del consenso.
cerrar(Ps0, Ps) :-
    findall(C,
            ( member(P, Ps0),
              member(Q, Ps0),
              consenso(P, Q, C) ),
            Cs),
    append(Ps0, Cs, Ps1),
    simplificar(Ps1, Ps2),
    (   Ps2 == Ps0
    ->  Ps = Ps0
    ;   cerrar(Ps2, Ps)
    ).

%!  consenso(+P:list, +Q:list, -C:list) is nondet.
%
%   C es el consenso de los productos P y Q: P tiene un nombre X, Q tiene
%   ~X, y la unión de los demás literales no es contradictoria.
consenso(P, Q, C) :-
    member(X, P),
    atom(X),
    memberchk(~X, Q),
    ord_del_element(P, X, P1),
    ord_del_element(Q, ~X, Q1),
    ord_union(P1, Q1, C),
    \+ ( member(Y, C), atom(Y), memberchk(~Y, C) ).

% Ejercicio 8

secuenciales:secuencial(contador2, contador2_c, 2).

% Con e = 1 el contador suma 1; con e = 0, n0 = b0 y n1 = b1.
circuitos:circuito(contador2_c, [e, b0, b1], [b0, b1, n0, n1]).
circuitos:componente(contador2_c, x1, xor, [b0, e], [n0]).
circuitos:componente(contador2_c, y1, and, [b0, e], [c]).
circuitos:componente(contador2_c, x2, xor, [b1, c], [n1]).

% Ejercicio 9

secuenciales:secuencial(detector, detector_c, 2).

% El estado es [q1, q2]: la entrada anterior y la de antes. La salida es 1
% si x = 1, q1 = 0 y q2 = 1; el estado siguiente es [x, q1].
circuitos:circuito(detector_c, [x, q1, q2], [z, x, q1]).
circuitos:componente(detector_c, i1, inv, [q1], [nq1]).
circuitos:componente(detector_c, y1, and, [x, nq1], [t]).
circuitos:componente(detector_c, y2, and, [t, q2], [z]).

%!  detector_correcto is semidet.
%
%   En todo arco alcanzable del detector, la salida es 1 solo si la
%   entrada es 1.
detector_correcto :-
    siempre(detector, [0, 0], [_, [X], [Z], _]>>(Z =< X)).

% Ejercicio 11

% gi = ai * bi, pi = ai # bi; c1 = g0, c2 = g1 + p1 * g0,
% c = g2 + p2 * g1 + p2 * p1 * g0.
circuitos:circuito(sumador3_anticipado, [a0, a1, a2, b0, b1, b2],
                   [s0, s1, s2, c]).
circuitos:componente(sumador3_anticipado, ga0, and, [a0, b0], [g0]).
circuitos:componente(sumador3_anticipado, ga1, and, [a1, b1], [g1]).
circuitos:componente(sumador3_anticipado, ga2, and, [a2, b2], [g2]).
circuitos:componente(sumador3_anticipado, xp0, xor, [a0, b0], [s0]).
circuitos:componente(sumador3_anticipado, xp1, xor, [a1, b1], [p1]).
circuitos:componente(sumador3_anticipado, xp2, xor, [a2, b2], [p2]).
circuitos:componente(sumador3_anticipado, xs1, xor, [p1, g0], [s1]).
circuitos:componente(sumador3_anticipado, yc1, and, [p1, g0], [t1]).
circuitos:componente(sumador3_anticipado, oc1, or, [g1, t1], [c2]).
circuitos:componente(sumador3_anticipado, xs2, xor, [p2, c2], [s2]).
circuitos:componente(sumador3_anticipado, yc2, and, [p2, g1], [t2]).
circuitos:componente(sumador3_anticipado, yc3, and, [p2, p1], [t3]).
circuitos:componente(sumador3_anticipado, yc4, and, [t3, g0], [t4]).
circuitos:componente(sumador3_anticipado, oc2, or, [g2, t2], [t5]).
circuitos:componente(sumador3_anticipado, oc3, or, [t5, t4], [c]).

%!  profundidad(+Ruta:list, +Tipo, +Entradas:list(integer), -P:integer)
%!      is det.
%
%   Una conducta más: cada cable lleva la cantidad de compuertas que hay
%   en el camino más largo desde una entrada, y cada entrada, 0.
profundidad(_Ruta, _Tipo, Entradas, P) :-
    max_list(Entradas, P0),
    P is P0 + 1.
