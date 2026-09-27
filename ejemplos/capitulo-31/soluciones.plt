:- encoding(utf8).

% Pruebas de soluciones.pl.

:- begin_tests(bisiesto).

test(multiplo_de_4) :-
    bisiesto(2024).

test(no_multiplo_de_4, fail) :-
    bisiesto(2026).

test(multiplo_de_100, fail) :-
    bisiesto(1900).

test(multiplo_de_400) :-
    bisiesto(2000).

test(no_entero, error(type_error(integer, dos_mil))) :-
    bisiesto(dos_mil).

:- end_tests(bisiesto).
