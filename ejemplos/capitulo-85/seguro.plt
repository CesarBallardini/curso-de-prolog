:- encoding(utf8).

:- begin_tests(seguro).

test(literales, [true(Ls == [p(X), \+ q(X), X > 1])]) :-
    literales((p(X), \+ q(X), X > 1), Ls).

test(literales_true, [true(Ls == [])]) :-
    literales(true, Ls).

test(comparacion, [true(Cs == [a < b, a =\= b])]) :-
    findall(C, ( member(C, [a < b, p(a), a =\= b, \+ a]), comparacion(C) ),
            Cs).

test(seguro_camino) :-
    seguro([ (arco(a, b) :- true),
             (camino(X, Y) :- arco(X, Y)),
             (camino(X, Y) :- camino(X, Z), arco(Z, Y)) ]).

% Cada problema, en el orden de la cláusula.
test(negacion_y_cabeza,
     [true(Ps =@= [negacion_libre(\+ q(Y)), cabeza_libre(r(Y))])]) :-
    problemas([(r(Y) :- \+ q(Y))], Ps).

test(funcion, [true(Ps =@= [funcion(f(Z))])]) :-
    problemas([(s(f(Z)) :- q(Z))], Ps).

test(funcion_negada, [true(Ps =@= [funcion(g(Z))])]) :-
    problemas([(s(Z) :- q(Z), \+ r(g(Z)))], Ps).

test(cabeza_libre, [true(Ps =@= [cabeza_libre(t(X, Y))])]) :-
    problemas([(t(X, Y) :- q(X))], Ps).

test(hecho_con_variables, [true(Ps =@= [cabeza_libre(p(X))])]) :-
    problemas([(p(X) :- true)], Ps).

test(comparacion_antes, [true(Ps =@= [comparacion_libre(X > 3)])]) :-
    problemas([(v(X) :- X > 3, q(X))], Ps).

test(aritmetica_libre, [true(Ps =@= [aritmetica_libre(Y is X + 1)])]) :-
    problemas([(u(Y) :- Y is X + 1, q(X))], Ps).

% is/2 liga su lado izquierdo: la cabeza queda ligada.
test(aritmetica_liga) :-
    seguro([(u(Y) :- q(X), Y is X + 1)]).

test(no_seguro, [fail]) :-
    seguro([(p(X) :- \+ q(X))]).

:- end_tests(seguro).
