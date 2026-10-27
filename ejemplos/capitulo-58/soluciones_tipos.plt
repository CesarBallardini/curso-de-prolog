:- encoding(utf8).

:- begin_tests(soluciones_tipos).

test(plegados, true(Ts == [ "(a -> a -> a) -> [a] -> a",
                            "(a -> b -> c -> c) -> c -> [a] -> [b] -> c",
                            "[entero] -> entero",
                            "entero" ])) :-
    maplist(tipo_con_plegados,
            ["plegar1_der", "plegar2_der", "maximo", "maximo []"], Ts).

test(plegado_sin_tipo, fail) :-
    tipo_con_plegados("maximo [verdadero, 1]", _).

test(polimorfico, true(T == "entero")) :-
    tipo_ml_de("sea id = fun x -> x en \c
                si id verdadero entonces id 1 sino 2", T).

% Con tipo/4, el mismo «sea» no tiene tipo.
test(monomorfico, fail) :-
    tipo_de("sea id = fun x -> x en \c
             si id verdadero entonces id 1 sino 2", _).

% Una variable del parámetro no se generaliza: f no puede ser a la vez
% una función de enteros y de booleanos.
test(no_generaliza_parametro, fail) :-
    tipo_ml_de("fun f -> sea g = f en si g verdadero entonces g 1 sino 2",
               _).

% Un parámetro sin esquema conserva su tipo, sin ligarlo a un esquema.
test(parametro, true(T == "a -> a")) :-
    tipo_ml_de("fun x -> x", T).

test(como_antes, true(T == "(a -> b) -> [a] -> [b]")) :-
    tipo_ml_de("map", T).

% La variable de un parámetro se comparte; las demás se renuevan.
test(instanciar) :-
    instanciar(fn(A, B), [x-A], T),
    T = fn(A2, B2),
    assertion(A2 == A),
    assertion(B2 \== B).

test(es_esquema) :-
    es_esquema(x-esquema(fn(_, _))).

test(no_es_esquema, fail) :-
    es_esquema(x-_).

:- end_tests(soluciones_tipos).
