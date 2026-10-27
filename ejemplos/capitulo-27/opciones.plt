:- encoding(utf8).

:- begin_tests(opciones).

test(hijos_de_juan, set(H == [ana, pedro])) :-
    padre(juan, H).

test(excepcion, throws(mi_error)) :-
    throw(mi_error).

test(enteros_sin_limite, condition(current_prolog_flag(bounded, false))) :-
    X is 2^100,
    X > 2^64.

test(hijos_de_eva, blocked('pendiente')) :-
    padre(eva, _).

test(juan_padre_de_luis, fixme('caso conocido')) :-
    padre(juan, luis).

:- end_tests(opciones).
