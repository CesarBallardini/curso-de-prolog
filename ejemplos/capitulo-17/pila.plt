:- encoding(utf8).

% Las inferencias no dependen de la máquina, pero sí del contexto de la
% llamada (plunit agrega algunas): las pruebas fijan cotas, no valores exactos.

:- begin_tests(pila).

test(longitud_de_mil, true(N == 1000)) :-
    numlist(1, 1000, L),
    longitud(L, N).

test(longitud_acc_de_mil, true(N == 1000)) :-
    numlist(1, 1000, L),
    longitud_acc(L, N).

test(las_dos_vueltas_coinciden, true(R1 == R2)) :-
    numlist(1, 100, L),
    reversa(L, R1),
    reversa_acc(L, R2).

% Con mil elementos, append/3 en cada paso cuesta unas quinientas veces más:
% unas 500 000 inferencias contra unas 1 000.
test(costo_de_reversa, true(I > 400000)) :-
    numlist(1, 1000, L),
    inferencias(reversa(L, _), I).

test(costo_de_reversa_acc, true(I < 2000)) :-
    numlist(1, 1000, L),
    inferencias(reversa_acc(L, _), I).

:- end_tests(pila).
