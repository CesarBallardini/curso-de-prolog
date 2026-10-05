:- encoding(utf8).

:- begin_tests(perezoso).

test(infinita, [true(V == [1, 2, 3, 4, 5])]) :-
    ejecutar_perezoso(nombre, "tomar 5 (desde 1)", "", V).

test(fibs, [true(V == [0, 1, 1, 2, 3, 5, 8, 13])]) :-
    ejecutar_perezoso(nombre, "tomar 8 fibs", "", V).

% El elemento que no se usa no se evalúa.
test(sin_usar, [true(V == 1)]) :-
    ejecutar_perezoso(nombre, "cabeza [1, cabeza []]", "", V).

test(sea_sin_usar, [true(V == 3)]) :-
    ejecutar_perezoso(nombre, "sea x = cabeza [] en 3", "", V).

test(como_estricta, [true(V == [1, 4, 9])]) :-
    ejecutar_perezoso(nombre, "map (fun x -> x * x) [1, 2, 3]", "", V).

% Un punto fijo escrito en el propio lenguaje.
test(punto_fijo, [true(V == 120)]) :-
    ejecutar_perezoso(nombre, "y f 5",
                      "y g = (fun x -> g (x x)) (fun x -> g (x x)); \c
                       f fact n = si n = 0 entonces 1 \c
                       sino n * fact (n - 1)", V).

test(forzar_error, [error(type_error(lista_no_vacia, []))]) :-
    ejecutar_perezoso(nombre, "tomar 2 [1, cabeza []]", "", _).

test(valor_perezoso_lambda, [true(V == clausura(x, id(x), [y-p]))]) :-
    contexto(nombre, [], Ctx),
    valor_perezoso(lam(x, id(x)), [y-p], Ctx, V).

% El argumento queda como promesa: cons no la fuerza.
test(valor_perezoso_cons,
     [true(V == [promesa(num(1), []) | promesa(ap(id(cabeza), id(nil)), [])])]) :-
    contexto(nombre, [], Ctx),
    valor_perezoso(ap(ap(id(cons), num(1)), ap(id(cabeza), id(nil))), [],
                   Ctx, V).

test(prometer, [true(P == promesa(num(1), [x-q]))]) :-
    prometer(nombre, num(1), [x-q], P).

test(forzar, [true(V == 3)]) :-
    contexto(nombre, [], Ctx),
    forzar(promesa(ap(ap(id(+), num(1)), num(2)), []), Ctx, V).

% Una promesa por nombre no guarda su valor: forzarla no la cambia.
test(forzar_no_recuerda, [true(P == promesa(num(7), []))]) :-
    contexto(nombre, [], Ctx),
    P = promesa(num(7), []),
    forzar(P, Ctx, _).

:- end_tests(perezoso).
