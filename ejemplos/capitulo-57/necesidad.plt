:- encoding(utf8).

:- begin_tests(necesidad).

test(primos, [true(V == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29])]) :-
    ejecutar_perezoso(necesidad, "tomar 10 primos", "", V).

test(fibs, [true(V == 12586269025)]) :-
    ejecutar_perezoso(necesidad, "nesimo 50 fibs", "", V).

test(ciclica, [true(V == [1, 1, 1])]) :-
    ejecutar_perezoso(necesidad, "tomar 3 unos", "unos = cons 1 unos", V).

% La promesa guarda su valor en la variable de su tercer argumento.
test(memo, [true(M == 3)]) :-
    contexto(necesidad, [], Ctx),
    prometer(necesidad, ap(ap(id(+), num(1)), num(2)), [], P),
    forzar(P, Ctx, _),
    P = memo(_, _, M).

% Por necesidad cuesta mucho menos que por nombre.
test(mas_barato) :-
    medir(nombre, I1),
    medir(necesidad, I2),
    I2 * 10 < I1.

medir(Modo, I) :-
    statistics(inferences, I0),
    ejecutar_perezoso(Modo, "nesimo 15 fibs", "", _),
    statistics(inferences, I1),
    I is I1 - I0.

test(prometer_necesidad) :-
    prometer(necesidad, num(1), [], P),
    assertion(P = memo(num(1), [], M)),
    assertion(var(M)).

% La primera vez que se fuerza, la promesa liga su valor.
test(forzar_liga, [true(M == 5)]) :-
    contexto(necesidad, [], Ctx),
    P = memo(ap(ap(id(+), num(2)), num(3)), [], M),
    forzar(P, Ctx, _).

% Con el valor ya ligado, la expresión no vuelve a evaluarse: cabeza de la
% lista vacía produciría un error.
test(forzar_recuerda, [true(V == 9)]) :-
    contexto(necesidad, [], Ctx),
    forzar(memo(ap(id(cabeza), id(nil)), [], 9), Ctx, V).

:- end_tests(necesidad).
