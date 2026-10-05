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

test(valor_aplicacion_lambda, [true(V == 5)]) :-
    valor_aplicacion(lambda(X, suma@[X, 1]), f, [4], V).

test(valor_aplicacion_constructor, [true(V == par@[2, 3])]) :-
    valor_aplicacion(par, par, [suma@[1, 1], 3], V).

test(aplicar_lambdas_sin_argumentos, [true(V == lambda(x, x))]) :-
    aplicar_lambdas([], lambda(x, x), V).

test(aplicar_lambdas_dos, [true(V == 7)]) :-
    aplicar_lambdas([3, 4], lambda(X, lambda(Y, suma@[X, Y])), V).

% Cada aplicación copia la lambda: la original queda sin ligar.
test(aplicar_lambdas_copia, [true(var(X))]) :-
    L = lambda(X, suma@[X, 1]),
    aplicar_lambdas([1], L, _).

test(anidar_lambdas, [true(L == lambda(a, lambda(b, cuerpo)))]) :-
    anidar_lambdas([a, b], cuerpo, L).

test(elegir, all(E == [si])) :-
    elegir(verdadero, si, no, E).

test(elegir_otro, fail) :-
    elegir(talvez, si, no, _).

% G*F aplica F y después G.
test(composicion, [true(V == 25)]) :-
    valor(cuadrado_del_siguiente@[4], V).

test(composicion_orden, [true(V1-V2 == 16-10)]) :-
    valor((cuadrado*inc)@[3], V1),
    valor((inc*cuadrado)@[3], V2).

test(composicion_triple, [true(V == 9)]) :-
    valor((cuadrado*inc*inc)@[1], V).

% Una composición es una función como cualquier otra: map la recibe.
test(composicion_en_map, [true(V == [4, 9, 16])]) :-
    valor(cuadrados_de_siguientes@[[1, 2, 3]], V).

test(composicion_es_lambda, [true(F = lambda(_, _))]) :-
    valor(cuadrado*inc, F).

:- end_tests(sustitucion).
