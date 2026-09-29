:- encoding(utf8).

% Capítulo 51 - Versión 4: el autómata mínimo.
%
% Dos estados de un autómata determinista son distinguibles si alguna
% palabra lleva a uno a un estado final y al otro no. La relación se
% define por inducción: son distinguibles si uno es final y el otro no, o
% si un mismo símbolo los lleva a dos estados distinguibles. Es una
% relación recursiva sobre un grafo con ciclos, y está tabulada.
%
% Los estados que no son distinguibles aceptan las mismas palabras y se
% pueden fundir: min(M) tiene por estados las clases de estados
% indistinguibles del determinista de M, y es el autómata determinista
% completo con menos estados que acepta el lenguaje de M.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- numero_estados(det(pares_a), N).
%?- tabla(min(pares_a), T).
%?- distinguibles(det(pares_a), [e0], [e2], W).

:- module(minimizar,
          [ distinguible/3,
            distinguible_directo/3,
            distinguibles/4,
            clase/3
          ]).

:- use_module(library(lists)).
:- reexport(construcciones).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

% pares_a acepta las palabras sobre {a, b} con una cantidad par de a:
% cuenta las a módulo 4, con dos estados donde bastaría uno, y tiene un
% estado, e4, al que no se llega desde el inicial.
automatas:alfabeto(pares_a, [a, b]).
automatas:inicial(pares_a, e0).
automatas:final(pares_a, e0).
automatas:final(pares_a, e2).
automatas:final(pares_a, e4).
automatas:delta(pares_a, e0, a, e1).
automatas:delta(pares_a, e1, a, e2).
automatas:delta(pares_a, e2, a, e3).
automatas:delta(pares_a, e3, a, e0).
automatas:delta(pares_a, e4, a, e1).
automatas:delta(pares_a, E, b, E) :-
    member(E, [e0, e1, e2, e3, e4]).

:- table distinguible/3.

%!  distinguible(+A, ?P, ?Q) is nondet.
%
%   Los estados alcanzables P y Q del autómata determinista y completo A
%   son distinguibles: una palabra lleva a uno a un estado final y al otro
%   no. La primera cláusula es la palabra vacía; la segunda agrega un
%   símbolo delante de una palabra que distingue los estados siguientes.
distinguible(A, P, Q) :-
    alcanzable(A, P),
    alcanzable(A, Q),
    (   final(A, P)
    ->  \+ final(A, Q)
    ;   final(A, Q)
    ).
distinguible(A, P, Q) :-
    distinguible(A, P1, Q1),
    predecesor(A, P1, S, P),
    predecesor(A, Q1, S, Q).

:- table arcos/2, predecesor/4.

%!  arcos(+A, -Arcos:list) is det.
%
%   Arcos son las transiciones P-S-P1 que salen de los estados
%   alcanzables de A.
arcos(A, Arcos) :-
    findall(P-S-P1, ( alcanzable(A, P), delta(A, P, S, P1) ), Arcos).

%!  predecesor(+A, +P1, ?S, ?P) is nondet.
%
%   El autómata A pasa de P a P1 leyendo S, y P es alcanzable. Tabulada:
%   para cada P1, las transiciones que llegan a él se buscan una vez.
predecesor(A, P1, S, P) :-
    arcos(A, Arcos),
    member(P-S-P1, Arcos).

:- table distinguible_directo/3.

%!  distinguible_directo(+A, ?P, ?Q) is nondet.
%
%   La misma relación que distinguible/3, con la segunda cláusula escrita
%   directamente: por cada par distinguible nuevo, recorre todas las
%   transiciones de todos los estados alcanzables dos veces.
distinguible_directo(A, P, Q) :-
    alcanzable(A, P),
    alcanzable(A, Q),
    (   final(A, P)
    ->  \+ final(A, Q)
    ;   final(A, Q)
    ).
distinguible_directo(A, P, Q) :-
    distinguible_directo(A, P1, Q1),
    alcanzable(A, P),
    delta(A, P, S, P1),
    alcanzable(A, Q),
    delta(A, Q, S, Q1).

%!  distinguibles(+A, +P, +Q, -W:list) is semidet.
%
%   W es una de las palabras más cortas que distingue los estados P y Q
%   del autómata determinista A: desde uno lleva a un estado final y desde
%   el otro no.
distinguibles(A, P, Q, W) :-
    distinguible(A, P, Q),
    length(W, _),
    lleva(A, P, W, P1),
    lleva(A, Q, W, Q1),
    (   final(A, P1)
    ->  \+ final(A, Q1)
    ;   final(A, Q1)
    ),
    !.

%!  lleva(+A, +P, ?W:list, -P1) is nondet.
%
%   El autómata determinista A pasa de P a P1 leyendo W.
lleva(_A, P, [], P).
lleva(A, P, [S|W], P1) :-
    delta(A, P, S, P2),
    lleva(A, P2, W, P1).

%!  clase(+A, +P, -C:list) is det.
%
%   C es la lista ordenada de los estados alcanzables de A que P no
%   distingue, P incluido: su clase de equivalencia.
clase(A, P, C) :-
    findall(Q, ( alcanzable(A, Q), \+ distinguible(A, P, Q) ), C0),
    sort(C0, C).

% min(M): el cociente del determinista de M por la relación de
% indistinguibles. Un estado es una clase; las transiciones de una clase
% son las de cualquiera de sus elementos, la primera.

automatas:alfabeto(min(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(min(M), C0) :-
    inicial(det(M), D0),
    clase(det(M), D0, C0).
automatas:final(min(M), C) :-
    alcanzable(min(M), C),
    C = [D|_],
    final(det(M), D).
automatas:delta(min(M), [D|_], S, C1) :-
    delta(det(M), D, S, D1),
    clase(det(M), D1, C1).
