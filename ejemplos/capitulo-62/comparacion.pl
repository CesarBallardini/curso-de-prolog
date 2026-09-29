:- encoding(utf8).

% Capítulo 62 - Versión 7: tres maneras de decidir la lógica
% proposicional.
%
% Para una fórmula sin cuantificadores hay procedimientos que siempre
% terminan. El método de Quine separa casos: una fórmula es una tautología
% si lo es con su primer átomo verdadero y con su primer átomo falso, y
% así hasta que no quedan átomos. library(clpb) traduce la fórmula a un
% diagrama de decisión binario y decide con taut/2; si la fórmula no es
% una tautología, sat/1 y labeling/1 dan una asignación que la hace falsa.
% El demostrador por resolución de la versión 6 completa la comparación,
% y palomar/2 construye la familia de fórmulas con que se miden los tres.
%
% solo-local: carga los módulos lector, primer_orden y resolucion_fo, y
% SWISH no admite módulos propios.
%
%?- leer_formula("(p → q) → (q → p)", F), contraejemplo(F, A).
%?- tautologia_palomar(clpb, 3).

:- module(comparacion,
          [ tautologia/2,
            contraejemplo/2,
            palomar/2,
            tautologia_palomar/2,
            atomos/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(clpb)).
:- reexport(resolucion_fo).

%!  tautologia(+Metodo, +F) is semidet.
%
%   La fórmula sin cuantificadores F es una tautología según el Metodo:
%   quine, clpb o resolucion(Max), una refutación lineal de ¬F de a lo
%   sumo Max pasos.
tautologia(quine, F) :-
    atomos(F, As),
    quine(As, F).
tautologia(clpb, F) :-
    booleana(F, E, _),
    taut(E, 1).
tautologia(resolucion(Max), F) :-
    clausulas_fo(no(F), Cs),
    refutar_fo(Cs, Max, _).

%!  atomos(+F, -As:list) is det.
%
%   As es la lista ordenada de las fórmulas atómicas de F.
atomos(F, As) :-
    phrase(atomos_de(F), As0),
    sort(As0, As).

%!  atomos_de(+F)// is det.
%
%   Las fórmulas atómicas de F, con repeticiones.
atomos_de(at(A)) -->
    [A].
atomos_de(val(_)) -->
    [].
atomos_de(no(F)) -->
    atomos_de(F).
atomos_de(y(A, B)) -->
    atomos_de(A),
    atomos_de(B).
atomos_de(o(A, B)) -->
    atomos_de(A),
    atomos_de(B).
atomos_de(si(A, B)) -->
    atomos_de(A),
    atomos_de(B).
atomos_de(sii(A, B)) -->
    atomos_de(A),
    atomos_de(B).

% --- El método de Quine --------------------------------------------------

%!  quine(+As:list, +F) is semidet.
%
%   F es verdadera con todos los valores de los átomos As, que son todos
%   los que tiene: con el primero verdadero y con el primero falso.
quine([], F) :-
    valor(F, 1).
quine([A|As], F) :-
    sustituir(F, A, 1, F1),
    quine(As, F1),
    sustituir(F, A, 0, F0),
    quine(As, F0).

%!  sustituir(+F0, +A, +V, -F) is det.
%
%   F es F0 con la fórmula atómica A reemplazada por el valor V, 0 o 1.
sustituir(at(B), A, V, G) :-
    (   A == B
    ->  G = val(V)
    ;   G = at(B)
    ).
sustituir(val(W), _, _, val(W)).
sustituir(no(F), A, V, no(G)) :-
    sustituir(F, A, V, G).
sustituir(y(F1, F2), A, V, y(G1, G2)) :-
    sustituir(F1, A, V, G1),
    sustituir(F2, A, V, G2).
sustituir(o(F1, F2), A, V, o(G1, G2)) :-
    sustituir(F1, A, V, G1),
    sustituir(F2, A, V, G2).
sustituir(si(F1, F2), A, V, si(G1, G2)) :-
    sustituir(F1, A, V, G1),
    sustituir(F2, A, V, G2).
sustituir(sii(F1, F2), A, V, sii(G1, G2)) :-
    sustituir(F1, A, V, G1),
    sustituir(F2, A, V, G2).

%!  valor(+F, -V) is det.
%
%   V, 0 o 1, es el valor de F, una fórmula sin átomos.
valor(val(V), V).
valor(no(F), V) :-
    valor(F, W),
    V is 1 - W.
valor(y(A, B), V) :-
    valor(A, VA),
    valor(B, VB),
    V is min(VA, VB).
valor(o(A, B), V) :-
    valor(A, VA),
    valor(B, VB),
    V is max(VA, VB).
valor(si(A, B), V) :-
    valor(A, VA),
    valor(B, VB),
    V is max(1 - VA, VB).
valor(sii(A, B), V) :-
    valor(A, VA),
    valor(B, VB),
    (   VA =:= VB
    ->  V = 1
    ;   V = 0
    ).

% --- library(clpb) -------------------------------------------------------

%!  booleana(+F, -E, -Vars:list) is det.
%
%   E es la expresión de library(clpb) que corresponde a F, con una
%   variable por fórmula atómica; Vars es la lista de pares Átomo-Variable.
booleana(F, E, Vars) :-
    atomos(F, As),
    pairs_keys_values(Vars, As, _),
    expresion(F, Vars, E).

%!  expresion(+F, +Vars:list, -E) is det.
%
%   E es la expresión de library(clpb) de F, con las variables de Vars.
expresion(at(A), Vars, X) :-
    memberchk(A-X, Vars).
expresion(no(F), Vars, ~E) :-
    expresion(F, Vars, E).
expresion(y(A, B), Vars, EA * EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(o(A, B), Vars, EA + EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(si(A, B), Vars, EA =< EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(sii(A, B), Vars, EA =:= EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).

%!  contraejemplo(+F, -Asignacion:list) is nondet.
%
%   Asignacion, una lista de pares Átomo-Valor, hace falsa la fórmula sin
%   cuantificadores F. Si F es una tautología, no hay ninguna.
contraejemplo(F, Asignacion) :-
    booleana(F, E, Asignacion),
    sat(~E),
    pairs_values(Asignacion, Vs),
    labeling(Vs).

% --- El principio del palomar --------------------------------------------

%!  palomar(+N:integer, -F) is det.
%
%   F afirma que N + 1 palomas no caben en N agujeros, uno por paloma:
%   no puede ser que cada paloma esté en algún agujero y que ningún
%   agujero tenga dos palomas. La fórmula atómica en(I, J) dice que la
%   paloma I está en el agujero J. F es una tautología para todo N.
palomar(N, no(y(Todas, Ninguno))) :-
    N1 is N + 1,
    numlist(1, N1, Palomas),
    numlist(1, N, Agujeros),
    findall(D,
            ( member(I, Palomas),
              findall(at(en(I, J)), member(J, Agujeros), Ds),
              disyuncion(Ds, D)
            ),
            Cada),
    conjuncion(Cada, Todas),
    findall(no(y(at(en(I, J)), at(en(K, J)))),
            ( member(J, Agujeros),
              member(I, Palomas),
              member(K, Palomas),
              I < K
            ),
            Pares),
    conjuncion(Pares, Ninguno).

%!  tautologia_palomar(+Metodo, +N:integer) is semidet.
%
%   El Metodo demuestra que N + 1 palomas no caben en N agujeros.
tautologia_palomar(Metodo, N) :-
    palomar(N, F),
    tautologia(Metodo, F).

%!  disyuncion(+Fs:list, -F) is det.
%
%   F es la disyunción de las fórmulas Fs, una lista no vacía.
disyuncion([F|Fs], D) :-
    foldl([G, A, o(A, G)]>>true, Fs, F, D).

%!  conjuncion(+Fs:list, -F) is det.
%
%   F es la conjunción de las fórmulas Fs, una lista no vacía.
conjuncion([F|Fs], C) :-
    foldl([G, A, y(A, G)]>>true, Fs, F, C).
