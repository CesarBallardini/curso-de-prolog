:- encoding(utf8).

% Capítulo 62 - Versión 3: resolución proposicional con profundización
% iterativa.
%
% Una fórmula es un teorema si su negación, en forma clausal, lleva a la
% cláusula vacía. refutar/3 busca la refutación más corta: length/2
% propone listas de pasos de longitud 0, 1, 2… hasta un máximo, y cada
% paso agrega a la lista de cláusulas un resolvente nuevo de dos cláusulas
% anteriores. La refutación es un dato: prueba(Clausulas, Pasos), donde
% cada paso r(I, J, R) dice que la cláusula siguiente, R, es un resolvente
% de las cláusulas número I y J. escribir_prueba/1 la escribe con una
% línea por cláusula.
%
% solo-local: carga los módulos lector y clausal, y SWISH no admite
% módulos propios.
%
%?- demostrar("(a → b) ∧ (b → c) → (a → c)", 5, P).
%?- demostrar("(a → b) ∧ (b → c) → (a → c)", 5, P), escribir_prueba(P).

:- module(resolucion,
          [ demostrar/3,
            refutar/3,
            resolvente/3,
            escribir_prueba/1,
            clausula_texto/2
          ]).

:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(lector).
:- use_module(clausal).

%!  demostrar(+Texto, +Max:integer, -Prueba) is semidet.
%
%   Prueba es una refutación de a lo sumo Max pasos de la negación de la
%   fórmula que Texto escribe, una fórmula sin cuantificadores. La
%   refutación es la más corta. Falla si no hay ninguna de Max pasos o
%   menos.
demostrar(Texto, Max, prueba(Clausulas, Pasos)) :-
    leer_formula(Texto, F),
    clausulas(no(F), Clausulas),
    refutar(Clausulas, Max, Pasos).

%!  refutar(+Clausulas:list, +Max:integer, -Pasos:list) is semidet.
%
%   Pasos es la lista más corta de pasos de resolución, de a lo sumo Max,
%   que lleva de las Clausulas, sin variables, a la cláusula vacía.
refutar(Clausulas, Max, Pasos) :-
    between(0, Max, N),
    length(Pasos, N),
    derivar(Pasos, Clausulas),
    !.

%!  derivar(?Pasos:list, +Clausulas:list) is nondet.
%
%   Pasos, una lista de longitud conocida, lleva de Clausulas a una lista
%   que contiene la cláusula vacía. Cada paso agrega al final un
%   resolvente que no estaba.
derivar([], Clausulas) :-
    memberchk([], Clausulas).
derivar([r(I, J, R)|Pasos], Clausulas) :-
    nth1(J, Clausulas, C2),
    nth1(I, Clausulas, C1),
    I < J,
    resolvente(C1, C2, R),
    \+ memberchk(R, Clausulas),
    append(Clausulas, [R], Clausulas1),
    derivar(Pasos, Clausulas1).

%!  resolvente(+C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de las cláusulas C1 y C2, sin variables: C1 tiene
%   un literal y C2 su opuesto, y R reúne los demás literales de las dos.
%   Un resolvente tautológico no se produce.
resolvente(C1, C2, R) :-
    select(L1, C1, R1),
    opuesto(L1, L2),
    selectchk(L2, C2, R2),
    ord_union(R1, R2, R),
    \+ tautologica(R).

%!  opuesto(+L, -M) is det.
%
%   M es el literal opuesto de L.
opuesto(+A, -A).
opuesto(-A, +A).

%!  escribir_prueba(+Prueba) is det.
%
%   Escribe la Prueba con una línea por cláusula: su número, la cláusula,
%   y de dónde sale, una premisa o un resolvente de dos anteriores.
escribir_prueba(prueba(Clausulas, Pasos)) :-
    forall(nth1(I, Clausulas, C),
           escribir_linea(I, C, premisa)),
    length(Clausulas, N),
    forall(nth1(K, Pasos, Paso),
           ( I is N + K,
             paso_clausula(Paso, C, Origen),
             escribir_linea(I, C, Origen)
           )).

%!  paso_clausula(+Paso, -C:list, -Origen) is det.
%
%   C es la cláusula que agrega Paso, y Origen dice de dónde sale.
paso_clausula(r(I, J, C), C, resolvente(I, J)).
paso_clausula(f(I, C), C, factor(I)).

%!  escribir_linea(+I:integer, +C:list, +Origen) is det.
%
%   Escribe la línea de la cláusula número I.
escribir_linea(I, C, Origen) :-
    clausula_texto(C, Texto),
    origen_texto(Origen, O),
    format("~t~w.~4|  ~w~t~36|  ~w~n", [I, Texto, O]).

%!  origen_texto(+Origen, -Texto:string) is det.
%
%   Texto describe el Origen de una cláusula.
origen_texto(premisa, "premisa").
origen_texto(resolvente(I, J), T) :-
    format(string(T), "resolvente de ~w y ~w", [I, J]).
origen_texto(factor(I), T) :-
    format(string(T), "factor de ~w", [I]).

%!  clausula_texto(+C:list, -Texto:string) is det.
%
%   Texto escribe la cláusula C como una disyunción de literales, con ¬
%   para la negación; la cláusula vacía se escribe □. Las variables se
%   escriben A, B, C…
clausula_texto([], "□").
clausula_texto([L|Ls], Texto) :-
    copy_term([L|Ls], C),
    numbervars(C, 0, _),
    maplist(literal_texto, C, Ts),
    atomic_list_concat(Ts, ' ∨ ', A),
    atom_string(A, Texto).

%!  literal_texto(+L, -Texto:string) is det.
%
%   Texto escribe el literal L.
literal_texto(+A, T) :-
    format(string(T), "~W", [A, [numbervars(true), spacing(next_argument)]]).
literal_texto(-A, T) :-
    format(string(T), "¬~W", [A, [numbervars(true), spacing(next_argument)]]).
