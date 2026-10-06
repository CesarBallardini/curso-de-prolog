:- encoding(utf8).

% Capítulo 67 - Un programa con acumulador: reverse/3 de abajo hacia
% arriba.
%
% Flach excluye las tautologías exigiendo que cada literal del cuerpo
% tenga menos variables que la cabeza, y esa restricción excluye también
% los programas con acumulador, como reverse/3. La versión 3 no la usa:
% conserva los literales enlazados con la cabeza. Con los ejemplos de
% reverse/3, eso deja pasar cláusulas que se apoyan en un ejemplo más
% grande que el que explican. bien_fundada/2 exige que un literal
% recursivo tenga como primer argumento una parte propia del primer
% argumento de la cabeza: la recursión desciende, y la cláusula no puede
% contenerse a sí misma.
%
% solo-local: carga ascendente.pl, que carga archivos de otros capítulos.
%
%?- aprender_reverse(rlgg, H), maplist(mostrar, H).
%?- aprender_reverse(rlgg_bien_fundada, H), maplist(mostrar, H).
%?- aprender_reverse(rlgg_bien_fundada, H), invertir(H, [1, 2, 3, 4], R).

:- module(acumulador,
          [ ejemplos_reverse/2,
            parte_propia/2,
            bien_fundada/2,
            rlgg_bien_fundada/4,
            cobertura/6,
            aprender_reverse/2,
            invertir/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- reexport(ascendente).
:- use_module(recursion, [probar/4]).

%!  ejemplos_reverse(-Pos:list, -Negs:list) is det.
%
%   Pos y Negs son los ejemplos de reverse(L, A, R): R es la inversa de L
%   seguida de A. Los positivos forman cadenas completas, de la lista
%   entera hasta la vacía.
ejemplos_reverse(Pos, Negs) :-
    Pos = [ reverse([1, 2], [], [2, 1]), reverse([2], [1], [2, 1]),
            reverse([], [2, 1], [2, 1]),
            reverse([a], [], [a]), reverse([], [a], [a]),
            reverse([1, 2, 3], [], [3, 2, 1]), reverse([2, 3], [1], [3, 2, 1]),
            reverse([3], [2, 1], [3, 2, 1]), reverse([], [3, 2, 1], [3, 2, 1])
          ],
    Negs = [ reverse([1, 2], [], [1, 2]), reverse([a], [], []),
             reverse([], [a], []), reverse([1], [2], [1, 2]),
             reverse([], [1], [2])
           ].

%!  parte_propia(@S, @T) is semidet.
%
%   S es un subtérmino de T distinto de T: un argumento de T o una parte
%   propia de uno. Se compara con ==, sin unificar.
parte_propia(S, T) :-
    compound(T),
    arg(_, T, A),
    (   A == S
    ->  true
    ;   parte_propia(S, A)
    ),
    !.

%!  bien_fundada(+H, +L) is semidet.
%
%   El literal L del cuerpo de una cláusula de cabeza H no es recursivo, o
%   lo es y su primer argumento es una parte propia del primer argumento
%   de H.
bien_fundada(H, L) :-
    (   functor(H, Nombre, Aridad),
        functor(L, Nombre, Aridad)
    ->  arg(1, H, X),
        arg(1, L, Y),
        parte_propia(Y, X)
    ;   true
    ).

%!  rlgg_bien_fundada(+E1, +E2, +M:list, -C) is det.
%
%   C es la rlgg/4 de E1 y E2 sin los literales recursivos que no
%   descienden por el primer argumento.
rlgg_bien_fundada(E1, E2, M, (H :- B)) :-
    rlgg(E1, E2, M, (H :- B0)),
    include(bien_fundada(H), B0, B).

%!  cobertura(:Generalizar, +Pos:list, +Negs:list, +M:list, -H:list,
%!            -N:integer) is det.
%
%   El algoritmo de cobertura de la versión 3 con la generalización de dos
%   ejemplos Generalizar, rlgg o rlgg_bien_fundada: elige la cláusula
%   reducida que cubre más positivos, quita los que cubre y repite. N es
%   la cantidad de generalizaciones calculadas.
cobertura(Generalizar, Pos, Negs, M, H, N) :-
    cubrir_con(Pos, Generalizar, Negs, M, H, N).

%!  cubrir_con(+Pos:list, :Generalizar, +Negs:list, +M:list, -H:list,
%!             -N:integer) is det.
%
%   cobertura/6 con los positivos como primer argumento.
cubrir_con([], _, _, _, [], 0).
cubrir_con([P|Ps], Generalizar, Negs, M, H, N) :-
    Pos = [P|Ps],
    findall(K-C,
            ( append(_, [E1|Resto], Pos),
              member(E2, Resto),
              call(Generalizar, E1, E2, M, C0),
              reducir(C0, Negs, M, C),
              include(cubre_en(C, M), Pos, Cs),
              length(Cs, K) ),
            Candidatas),
    length(Pos, L),
    N0 is L * (L - 1) // 2,
    (   sort(1, @>=, Candidatas, [_-C|_])
    ->  exclude(cubre_en(C, M), Pos, Quedan),
        H = [C|H1],
        cubrir_con(Quedan, Generalizar, Negs, M, H1, N1),
        N is N0 + N1
    ;   findall((E :- []), member(E, Pos), H),
        N = N0
    ).

%!  cubre_en(+C, +M:list, +E) is semidet.
%
%   La cláusula C cubre el ejemplo E en el modelo M.
cubre_en(C, M, E) :-
    cubre(C, E, M).

%!  aprender_reverse(:Generalizar, -H:list) is det.
%
%   H es la hipótesis de cobertura/6 para los ejemplos de reverse/3, con
%   los positivos como modelo.
aprender_reverse(Generalizar, H) :-
    ejemplos_reverse(Pos, Negs),
    sort(Pos, M),
    cobertura(Generalizar, Pos, Negs, M, H, _).

%!  invertir(+H:list, +L:list, -R:list) is nondet.
%
%   R es la inversa de L según las cláusulas de reverse/3 de H, probada
%   con el intérprete con límite de profundidad de la versión 5.
invertir(H, L, R) :-
    length(L, N),
    D is N + 2,
    probar(D, H, [], reverse(L, [], R)).
