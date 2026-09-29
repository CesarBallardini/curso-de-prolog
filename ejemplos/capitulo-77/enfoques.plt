:- encoding(utf8).

:- begin_tests(enfoques).

%!  aima(-K) is det.
%
%   El conocimiento de la figura 7.4 de Russell y Norvig.
aima(K) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K).

%!  dos_hedores(-K) is det.
%
%   Hedor en (1, 3) y en (2, 2): el wumpus está en (2, 3), la única vecina
%   común sin visitar.
dos_hedores(K) :-
    conocer(4, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], K).

test(aima, [true(Ss == [[2-2], [2-2], [2-2], [2-2], [2-2], [2-2]])]) :-
    aima(K),
    findall(S, ( member(E, [mundos, reglas, datalog, resolucion, clpb, clpfd]),
                  seguras_con(E, K, S) ), Ss).

test(completos, [true(Ss == [[1-4, 2-1, 3-2], [1-4, 2-1, 3-2],
                             [1-4, 2-1, 3-2]])]) :-
    dos_hedores(K),
    findall(S, ( member(E, [mundos, clpb, clpfd]),
                  seguras_con(E, K, S) ), Ss).

% Las reglas solo ubican al wumpus cuando un hedor tiene una sola
% candidata.
test(incompletos, [true(Ss == [[2-1], [2-1]])]) :-
    dos_hedores(K),
    findall(S, ( member(E, [reglas, datalog]),
                  seguras_con(E, K, S) ), Ss).

test(instantaneas, [true(N == 19)]) :-
    instantaneas([1, 2, 3], Ks),
    length(Ks, N).

test(comparar, [true(S-D == 38-0)]) :-
    instantaneas([1, 2, 3], Ks),
    comparar(reglas, Ks, r(S, D, _)).

:- end_tests(enfoques).
