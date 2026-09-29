:- encoding(utf8).

:- begin_tests(reescribir).

test(con_condicion, true(C =@= (regla(X, W * W, W ^ 2) :- con(X, W)))) :-
    expandir_regla((W * W ~> W ^ 2 si con(W)), C).

test(condiciones, true(C =@= (regla(X, U * W, W) :- con(X, W), libre(X, U),
                                                 U \== 0))) :-
    expandir_regla((U * W ~> W si con(W), libre(U), U \== 0), C).

test(sin_condicion, true(C =@= regla(_, 0 + W, W))) :-
    expandir_regla((0 + W ~> W), C).

test(otro_termino, [fail]) :-
    expandir_regla(p(a), _).

cambia(_, a, b).

test(reescribir, all(E == [f(b, g(a)), f(a, g(b))])) :-
    reescribir(cambia, x, f(a, g(a)), E).

test(raiz_primero, all(E == [b, f(b)])) :-
    member(E0, [a, f(a)]),
    reescribir(cambia, x, E0, E).

test(nada, [fail]) :-
    reescribir(cambia, x, f(c), _).

test(con, [true]) :-
    con(x, 2 * sin(x)).

test(con_falla, [fail]) :-
    con(x, 2 * sin(y)).

test(libre, [true]) :-
    libre(x, 2 * sin(y)).

test(libre_falla, [fail]) :-
    libre(x, x).

:- end_tests(reescribir).
