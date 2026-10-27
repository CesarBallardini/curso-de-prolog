:- encoding(utf8).

:- begin_tests(riesgo).

%!  revisitado(-K) is det.
%
%   El conocimiento de la sección «The Wumpus World Revisited» de Russell y
%   Norvig: brisa en (1, 2) y en (2, 1).
revisitado(K) :-
    conocer(4, [1-1-[], 1-2-[brisa], 2-1-[brisa]], K).

test(mundos, [true(L == 5)]) :-
    revisitado(K),
    mundos_pozos(K, M),
    length(M, L).

% Las probabilidades del libro: 0,31 y 0,86, que son 9/29 y 25/29.
test(pozo_13, [true(abs(P - 9 / 29) < 1.0e-9)]) :-
    revisitado(K),
    probabilidad_pozo(K, 1-3, P).

test(pozo_22, [true(abs(P - 25 / 29) < 1.0e-9)]) :-
    revisitado(K),
    probabilidad_pozo(K, 2-2, P).

test(pozo_lejos, [true(P =:= 0.2)]) :-
    revisitado(K),
    probabilidad_pozo(K, 4-4, P).

test(visitada, [true(P =:= 0)]) :-
    revisitado(K),
    probabilidad_pozo(K, 1-2, P).

test(wumpus, [true(P =:= 0.5)]) :-
    conocer(4, [1-1-[hedor]], K),
    probabilidad_wumpus(K, 2-1, P).

% Pozo con probabilidad 5/9 y wumpus con 1/2: 1 - 4/9 * 1/2 = 7/9.
test(riesgo, [true(abs(R - 7 / 9) < 1.0e-9)]) :-
    conocer(4, [1-1-[hedor, brisa]], K),
    riesgo(K, 1-2, R).

test(disparo, [true(D-Dir == (1-1)-este)]) :-
    conocer(4, [1-1-[hedor]], K),
    disparo(K, D, Dir).

test(sin_flecha, [fail]) :-
    conocer(4, [1-1-[hedor]], c(N, C, Vs, O, _, W, P)),
    disparo(c(N, C, Vs, O, no, W, P), _, _).

% Donde el agente prudente sale sin el oro, la flecha le abre el camino.
test(flecha, [true(F-P == salio(si)-973)]) :-
    mundo_sembrado(2, M),
    jugar_con_riesgo(M, 0.5, final(F, P, As)),
    memberchk(disparar(norte), As).

test(medir, [true(R == r(2, 0, 8, 192))]) :-
    numlist(1, 10, Ss),
    medir(prudente, Ss, R).

test(peso, [true(abs(W - 0.16) < 1.0e-9)]) :-
    riesgo:peso(2, [x], W).

test(peso_sin_pozos, [true(abs(W - 0.512) < 1.0e-9)]) :-
    riesgo:peso(3, [], W).

:- end_tests(riesgo).
