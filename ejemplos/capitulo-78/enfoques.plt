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

% sin_wumpus/2 y wumpus_en/2 en la figura 7.4: el hedor de (1, 2) tiene
% una sola candidata, (1, 3).
test(sin_wumpus_vecina) :-
    aima(K),
    enfoques:sin_wumpus(K, 2-2).

test(sin_wumpus_por_ubicacion) :-
    aima(K),
    enfoques:sin_wumpus(K, 3-1).

test(sin_wumpus_candidata, [fail]) :-
    aima(K),
    enfoques:sin_wumpus(K, 1-3).

test(wumpus_en, [true(W == 1-3)]) :-
    aima(K),
    enfoques:wumpus_en(K, W).

% Con dos hedores, ninguno tiene una sola candidata: las reglas no lo
% ubican.
test(wumpus_en_dos_hedores, [fail]) :-
    dos_hedores(K),
    enfoques:wumpus_en(K, _).

test(reglas_datalog, [true(N == 7)]) :-
    enfoques:reglas_datalog(Rs),
    length(Rs, N).

test(segura_por_resolucion) :-
    aima(K),
    enfoques:clausulas_primer_orden(K, B),
    enfoques:segura_por_resolucion(B, 2-2).

test(no_segura_por_resolucion, [fail]) :-
    aima(K),
    enfoques:clausulas_primer_orden(K, B),
    enfoques:segura_por_resolucion(B, 3-1).

test(segura_por_clpb) :-
    aima(K),
    enfoques:formula(K, F),
    enfoques:segura_por_clpb(F, 2-2).

test(no_segura_por_clpb, [fail]) :-
    aima(K),
    enfoques:formula(K, F),
    enfoques:segura_por_clpb(F, 1-3).

test(mundo_con_pozo) :-
    aima(K),
    enfoques:mundo_con(K, pozo, 3-1).

test(mundo_sin_pozo, [fail]) :-
    aima(K),
    enfoques:mundo_con(K, pozo, 2-2).

test(mundo_con_wumpus) :-
    aima(K),
    enfoques:mundo_con(K, wumpus, 1-3).

test(mundo_sin_wumpus, [fail]) :-
    aima(K),
    enfoques:mundo_con(K, wumpus, 2-2).

:- end_tests(enfoques).
