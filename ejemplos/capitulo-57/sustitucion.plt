:- encoding(utf8).

:- begin_tests(sustitucion).

test(map, [true(V == [1, 4, 9])]) :-
    valor(map@[cuadrado, [1, 2, 3]], V).

% Aplicar a dos argumentos de una vez o de a uno da lo mismo.
test(currificada, [true(V1-V2 == 3-3)]) :-
    valor(suma@[1]@[2], V1),
    valor(suma@[1, 2], V2).

test(aplicacion_parcial, [true(V == [2, 3, 4])]) :-
    valor(map@[inc, [1, 2, 3]], V).

test(plegar, [true(V == 120)]) :-
    valor(plegar_izq@[producto, 1, [1, 2, 3, 4, 5]], V).

test(invertir, [true(V == [3, 2, 1])]) :-
    valor(invertir@[[1, 2, 3]], V).

test(factorial, [true(V == 3628800)]) :-
    valor(factorial@[10], V).

% El cuerpo de la lambda usa N, que la sustitución reemplaza por 10.
test(lambda_con_parametro, [true(V == [11, 12])]) :-
    valor(sumar_a_todos@[10, [1, 2]], V).

% Un átomo sin definición es un constructor.
test(constructor, [true(V == [par@[1], par@[2]])]) :-
    valor(map@[par, [1, 2]], V).

% La copia desconecta la variable libre Z de la consulta.
test(variable_libre, [true(var(W))]) :-
    valor(lambda(Y, par@[Y, Z])@[1], R),
    Z = 5,
    R = par@[1, W].

% El dato inc vuelve a evaluarse y se convierte en una función.
test(dato_reevaluado, [true(V = [[lambda(_, _)]])]) :-
    valor(map@[lambda(X, [X]), [inc]], V).

% Un parámetro que es un patrón falla si el argumento no unifica.
test(patron, [fail]) :-
    valor(cabeza@[[]], _).

:- end_tests(sustitucion).
