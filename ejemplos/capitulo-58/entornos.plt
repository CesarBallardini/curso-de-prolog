:- encoding(utf8).

:- begin_tests(entornos).

test(map, [true(V == [1, 4, 9])]) :-
    ejemplo(ap(ap(id(map), id(cuadrado)), id(l)), [l-[1, 2, 3]], V).

test(primitiva, [true(V == 3)]) :-
    evaluar(ap(ap(id(+), num(1)), num(2)), [], [], V).

% A la primitiva aplicada a un argumento le falta uno.
test(parcial, [true(V == prim(+, 1, [1]))]) :-
    evaluar(ap(id(+), num(1)), [], [], V).

% La clausura guarda el entorno en el que se evaluó la lambda.
test(clausura, [true(V == clausura(x, ap(ap(id(+), id(x)), id(n)),
                                   [n-10]))]) :-
    evaluar(lam(x, ap(ap(id(+), id(x)), id(n))), [n-10], [], V).

test(captura, [true(V == [11, 12])]) :-
    ejemplo(ap(ap(id(sumar_a_todos), num(10)), id(l)), [l-[1, 2]], V).

test(invertir, [true(V == [3, 2, 1])]) :-
    ejemplo(ap(id(invertir), id(l)), [l-[1, 2, 3]], V).

% Un dato del entorno no vuelve a evaluarse.
test(dato, [true(V == [[inc]])]) :-
    ejemplo(ap(ap(id(map), lam(x, ap(ap(id(cons), id(x)), id(nil)))),
               id(l)),
            [l-[inc]], V).

% El primer par del entorno oculta a los demás.
test(oculta, [true(V == 1)]) :-
    evaluar(sea(x, num(1), id(x)), [x-2], [], V).

test(sin_definir, [error(existence_error(identificador, z))]) :-
    evaluar(id(z), [], [], _).

test(no_funcion, [error(type_error(funcion, 1))]) :-
    evaluar(ap(num(1), num(2)), [], [], _).

test(cabeza_vacia, [error(type_error(lista_no_vacia, []))]) :-
    evaluar(ap(id(cabeza), id(nil)), [], [], _).

test(no_booleano, [error(type_error(booleano, 0))]) :-
    evaluar(si(num(0), num(1), num(2)), [], [], _).

test(aplicar_clausura, [true(V == 11)]) :-
    aplicar(clausura(x, ap(ap(id(+), id(x)), id(n)), [n-10]), 1, [], V).

test(aplicar_primitiva_parcial, [true(V == prim(*, 1, [3]))]) :-
    aplicar(prim(*, 2, []), 3, [], V).

test(aplicar_primitiva_completa, [true(V == 12)]) :-
    aplicar(prim(*, 1, [3]), 4, [], V).

test(aplicar_no_funcion, [error(type_error(funcion, [1]))]) :-
    aplicar([1], 2, [], _).

test(rama, all(E == [a])) :-
    rama(verdadero, a, b, E).

:- end_tests(entornos).
