:- encoding(utf8).

% Capítulo 67 - Versión 2: θ-subsunción y lgg de cláusulas.
%
% Una cláusula es un término Cabeza :- Cuerpo, con el cuerpo como lista de
% literales: el orden de los literales no cuenta. subsume/2 decide si
% una sustitución aplicada a la primera cláusula da una cabeza igual a la
% de la segunda y un cuerpo contenido en el de la segunda; para que la
% sustitución no toque la segunda cláusula, sus variables se congelan con
% numbervars/3, y todo ocurre dentro de una doble negación que deshace las
% ligaduras. lgg_clausula/3 generaliza las cabezas con lgg/5 de la
% versión 1 y después cada par de literales del mismo predicado, uno de
% cada cuerpo, con la misma sustitución inversa: así los literales
% comparten las variables de la cabeza.
%
%?- subsume((p(X) :- [q(X, Y)]), (p(a) :- [q(a, a), r(a)])).
%?- lgg_clausula((p(a) :- [q(a, b)]), (p(c) :- [q(c, d)]), C).

:- module(subsuncion,
          [ subsume/2,
            lgg_clausula/3,
            mismo_predicado/2,
            como_regla/2,
            mostrar/1
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(generalizar).

%!  subsume(@C1, @C2) is semidet.
%
%   La cláusula C1 θ-subsume a C2: una sustitución θ de las variables de
%   C1 hace la cabeza de C1 igual a la de C2 y cada literal del cuerpo de
%   C1 igual a uno del cuerpo de C2. Ninguna cláusula queda ligada.
subsume(C1, C2) :-
    \+ \+ ( copy_term(C1, (H1 :- B1)),
            copy_term(C2, (H2 :- B2)),
            numbervars(H2-B2, 0, _),
            H1 = H2,
            incluido(B1, B2) ).

%!  incluido(?Literales:list, +Cuerpo:list) is nondet.
%
%   Cada literal de Literales unifica con un literal de Cuerpo; una
%   respuesta por cada manera de elegirlos.
incluido([], _).
incluido([L|Ls], Cuerpo) :-
    member(L, Cuerpo),
    incluido(Ls, Cuerpo).

%!  lgg_clausula(+C1, +C2, -C) is det.
%
%   C es la lgg de las cláusulas C1 y C2 bajo θ-subsunción: la cabeza es
%   la lgg de las cabezas, y el cuerpo tiene la lgg de cada par de
%   literales del mismo predicado, sin repetidos, todas calculadas con la
%   misma sustitución inversa.
lgg_clausula((H1 :- B1), (H2 :- B2), (H :- B)) :-
    lgg(H1, H2, H, [], S0),
    pares(B1, B2, Pares),
    foldl(lgg_par, Pares, B0, S0, _),
    list_to_set(B0, B).

%!  pares(+B1:list, +B2:list, -Pares:list) is det.
%
%   Pares son los pares L1-L2 con L1 de B1 y L2 de B2 del mismo
%   predicado, en el orden de B1 y, para cada L1, en el de B2. Los
%   literales no se copian: conservan sus variables.
pares([], _, []).
pares([L1|B1], B2, Pares) :-
    include(mismo_predicado(L1), B2, Compatibles),
    maplist(par(L1), Compatibles, Pares1),
    append(Pares1, Pares2, Pares),
    pares(B1, B2, Pares2).

% par(L1, L2, L1-L2): arma el par.
par(L1, L2, L1-L2).

%!  lgg_par(+Par, -L, +S0:list, -S:list) is det.
%
%   L es la lgg de los dos literales del par, con la sustitución inversa
%   S0.
lgg_par(L1-L2, L, S0, S) :-
    lgg(L1, L2, L, S0, S).

%!  mismo_predicado(@L1, @L2) is semidet.
%
%   Los literales L1 y L2 tienen el mismo nombre y la misma aridad.
mismo_predicado(L1, L2) :-
    functor(L1, Nombre, Aridad),
    functor(L2, Nombre, Aridad).

%!  como_regla(+C, -R) is det.
%
%   R es la cláusula C escrita como regla de Prolog: el cuerpo es la
%   conjunción de los literales de la lista, o true si la lista está
%   vacía.
como_regla((H :- Ls), (H :- Cuerpo)) :-
    (   Ls == []
    ->  Cuerpo = true
    ;   Ls = [L|Resto],
        conjuncion(Resto, L, Cuerpo)
    ).

%!  conjuncion(+Ls:list, +L, -Conj) is det.
%
%   Conj es la conjunción de L seguido de los literales de Ls.
conjuncion([], L, L).
conjuncion([L2|Ls], L, (L, Conj)) :-
    conjuncion(Ls, L2, Conj).

%!  mostrar(+C) is det.
%
%   Escribe la cláusula C como regla de Prolog, con portray_clause/1.
mostrar(C) :-
    como_regla(C, R),
    portray_clause(R).
