:- encoding(utf8).

:- begin_tests(variables).

test(ingenuo_una_vez, true(A == 4)) :-
    cuadrado(F),
    evaluar_en_ingenuo(F, 2, A).

% La primera aplicación liga X a 2; la segunda no puede ligarla a 3.
test(ingenuo_dos_veces, [fail]) :-
    cuadrado(F),
    evaluar_en_ingenuo(F, 2, _),
    evaluar_en_ingenuo(F, 3, _).

test(evaluar_en, true(A-B == 4-9)) :-
    cuadrado(F),
    evaluar_en(F, 2, A),
    evaluar_en(F, 3, B).

test(evaluar_en_no_liga, true(F =@= fn(X, X * X))) :-
    cuadrado(F),
    evaluar_en(F, 2, _).

% La copia conserva qué posiciones comparten una variable.
test(copy_term, true(C =@= f(A, _, A))) :-
    copy_term(f(X, _, X), C).

test(term_variables, true(Vs == [X, Y, Z])) :-
    term_variables(f(X, g(Y, X), Z), Vs).

test(variables_de, true(N == 2)) :-
    variables_de(f(X, g(_, X)), N).

test(variables_de_cerrado, true(N == 0)) :-
    variables_de(f(a, g(b)), N).

test(variante, [true]) :-
    f(_, _) =@= f(_, _).

test(no_variante, [fail]) :-
    f(X, X) =@= f(_, _).

% numbervars/3 liga las variables: después, X ya no puede ser ana.
test(numbervars_liga, [fail]) :-
    T = f(X),
    numbervars(T, 0, _),
    X = ana.

test(escribir_con_nombres, true(S == "f(A,g(B,A))\n")) :-
    with_output_to(string(S), escribir_con_nombres(f(X, g(_, X)))).

test(escribir_no_liga, true(X == ana)) :-
    with_output_to(string(_), escribir_con_nombres(f(X))),
    X = ana.

:- end_tests(variables).
