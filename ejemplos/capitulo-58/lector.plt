:- encoding(utf8).

:- begin_tests(lector).

test(lexico, [true(Ts == [id(f), '(', id(x), ')', '->', '[', num(1), ',',
                          num(22), ']'])]) :-
    lexico("f (x) -> [1,22]", Ts).

test(caracter_extrano, [error(syntax_error(componente_lexico))]) :-
    lexico("x $ 1", _).

test(lambda, [true(E == lam(x, lam(y, ap(ap(id(+), id(x)), id(y)))))]) :-
    leer_expresion("fun x y -> x + y", E).

% La aplicación liga más que *, y * más que +.
test(precedencia, [true(E == ap(ap(id(+), ap(id(f), id(x))),
                                ap(ap(id(*), num(2)), num(3))))]) :-
    leer_expresion("f x + 2 * 3", E).

test(lista, [true(E == ap(ap(id(cons), num(1)),
                          ap(ap(id(cons), num(2)), id(nil))))]) :-
    leer_expresion("[1, 2]", E).

test(operador, [true(E == ap(id(+), num(1)))]) :-
    leer_expresion("(+) 1", E).

test(incompleta, [error(syntax_error(expresion))]) :-
    leer_expresion("x +", _).

test(definicion, [true(P == [def(f, lam(x, lam(y, id(x))))])]) :-
    leer_programa("f x y = x", P).

test(preludio, [true(N == 16)]) :-
    preludio_leido(P),
    length(P, N).

test(map, [true(V == [1, 4, 9])]) :-
    ejecutar("map (fun x -> x * x) [1, 2, 3]", V).

test(plegados, [true(A-B == 5050-[1, 2, 3])]) :-
    ejecutar("suma (hasta 1 100)", A),
    ejecutar("plegar_der (fun x a -> cons x a) [] [1, 2, 3]", B).

test(filtrar, [true(V == [2, 4, 6, 8, 10])]) :-
    ejecutar("filtrar (fun x -> mod x 2 = 0) (hasta 1 10)", V).

test(currificacion, [true(V == [6, 8])]) :-
    ejecutar("componer (map ((*) 2)) (filtrar (fun x -> x > 2)) \c
              [1, 2, 3, 4]", V).

% Una definición propia oculta a la del preludio.
test(propias, [true(V == 23)]) :-
    ejecutar("suma 2 3", "suma x y = x * 10 + y", V).

% La evaluación estricta de una lista infinita no termina.
test(infinita, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(ejecutar("tomar 3 (desde 1)", _),
                              1 000 000, R).

test(aplicacion, all(E == [ap(ap(id(f), id(x)), num(2))])) :-
    phrase(aplicacion(E), [id(f), id(x), num(2)]).

test(aplicacion_un_atomo, all(E == [id(f)])) :-
    phrase(aplicacion(E), [id(f)]).

test(resto_aplicacion_deja, [true(E-R == ap(id(f), num(1))-[+, num(2)])]) :-
    phrase(resto_aplicacion(id(f), E), [num(1), +, num(2)], R).

test(preludio_cada_texto, all(N == [])) :-
    preludio(T),
    \+ leer_programa(T, [_]),
    N = T.

:- end_tests(lector).
