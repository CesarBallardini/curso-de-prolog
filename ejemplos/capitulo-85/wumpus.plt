:- encoding(utf8).

:- begin_tests(wumpus).

%!  aima(-K) is det.
%
%   El conocimiento de la figura 7.4 de Russell y Norvig.
aima(K) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K).

test(aima, [true(S == [2-2])]) :-
    aima(K),
    seguras_motor(K, S).

test(como_capitulo38, [true(S == S38)]) :-
    aima(K),
    seguras_motor(K, S),
    seguras_capitulo38(K, S38).

% Con dos hedores, las reglas no ubican al wumpus, como en el capítulo 77.
test(dos_hedores, [true(S == [2-1])]) :-
    conocer(4, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], K),
    seguras_motor(K, S),
    seguras_con(datalog, K, S).

test(comparar, [true(Seguras-Distintas == 38-0)]) :-
    comparar([1, 2, 3], r(Seguras, Distintas, I38, IMotor)),
    IMotor < I38.

test(programa_wumpus, [true(N == 76)]) :-
    aima(K),
    programa_wumpus(K, Cs),
    length(Cs, N).

:- end_tests(wumpus).
