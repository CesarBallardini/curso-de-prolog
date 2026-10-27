:- encoding(utf8).

% Pruebas de eco.pl: el núcleo; el programa completo lo prueba el ejercicio
% 7, en soluciones.plt.

:- begin_tests(eco).

test(invertir, true(L == [tres, dos, uno])) :-
    invertir([uno, dos, tres], L).

test(invertir_vacia, true(L == [])) :-
    invertir([], L).

:- end_tests(eco).
