:- encoding(utf8).

:- begin_tests(partes).

test(functor_descompone, true(N/A == fecha/3)) :-
    functor(fecha(2026, 9, 27), N, A).

test(functor_construye, true(T =@= fecha(_, _, _))) :-
    functor(T, fecha, 3).

test(functor_atomo, true(N/A == ana/0)) :-
    functor(ana, N, A).

test(functor_libre, [error(instantiation_error)]) :-
    functor(_, _, 2).

% arg/3 con la posición libre enumera los argumentos.
test(arg_enumera, all(N-X == [1-2026, 2-9, 3-27])) :-
    arg(N, fecha(2026, 9, 27), X).

test(argumentos, true(Args == [2026, 9, 27])) :-
    argumentos(fecha(2026, 9, 27), Args).

test(argumentos_atomo, true(Args == [])) :-
    argumentos(ana, Args).

test(argumentos_libre, [error(instantiation_error)]) :-
    argumentos(_, _).

test(cambiar_argumento, true(T == fecha(2026, 10, 27))) :-
    cambiar_argumento(2, fecha(2026, 9, 27), 10, T).

% El término original no cambia.
test(cambiar_no_modifica, true(T0 == fecha(2026, 9, 27))) :-
    T0 = fecha(2026, 9, 27),
    cambiar_argumento(1, T0, 2027, _).

% Con el resultado ligado, se obtiene el argumento reemplazado.
test(cambiar_inverso, true(X == z)) :-
    cambiar_argumento(1, f(a, b), X, f(z, b)).

test(cambiar_fuera, [fail]) :-
    cambiar_argumento(4, fecha(2026, 9, 27), 10, _).

test(argumentos_univ, true(Args == [2026, 9, 27])) :-
    argumentos_univ(fecha(2026, 9, 27), Args).

test(argumentos_univ_atomo, true(Args == [])) :-
    argumentos_univ(ana, Args).

test(univ_construye, true(T == fecha(2026, 9, 27))) :-
    T =.. [fecha, 2026, 9, 27].

test(univ_libre, [error(instantiation_error)]) :-
    _ =.. _.

test(renombrar, true(T == dia(2026, 9, 27))) :-
    renombrar(fecha(2026, 9, 27), dia, T).

test(agregar_argumento, true(Meta == padre(juan, H))) :-
    agregar_argumento(padre(juan), H, Meta).

test(agregar_a_atomo, true(Meta == mujer(ana))) :-
    agregar_argumento(mujer, ana, Meta).

test(compound_cero, true(L == [])) :-
    compound_name_arguments(T, f, []),
    compound_name_arguments(T, f, L).

test(univ_cero, [error(domain_error(compound_non_zero_arity, _))]) :-
    compound_name_arguments(T, f, []),
    T =.. _.

test(compound_atomo, [error(type_error(compound, ana))]) :-
    compound_name_arguments(ana, _, _).

:- end_tests(partes).
