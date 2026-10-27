:- encoding(utf8).

:- begin_tests(tipos).

%!  tipo_en(+Definiciones:string, +Texto:string, -Tipo:string) is semidet.
%
%   tipo_de/3 con las definiciones en el primer argumento, para maplist/3.
tipo_en(D, Texto, T) :-
    tipo_de(Texto, D, T).

test(map, true(T == "(a -> b) -> [a] -> [b]")) :-
    tipo_de("map", T).

test(componer, true(T == "(a -> b) -> (c -> a) -> c -> b")) :-
    tipo_de("componer", T).

test(fibs, true(T == "[entero]")) :-
    tipo_de("fibs", T).

test(numero, true(T == "entero")) :-
    tipo_de("1 + 2", T).

test(booleano, true(T == "booleano")) :-
    tipo_de("1 < 2", T).

test(lambda, true(T == "(a -> b) -> (c -> a) -> c -> b")) :-
    tipo_de("fun f g x -> f (g x)", T).

% Cada uso de map tiene su propia copia del tipo.
test(polimorfismo, true(T == "[[entero]]")) :-
    tipo_de("map (map (fun x -> x + 1)) [[1], [2, 3]]", T).

test(sea, true(T == "entero")) :-
    tipo_de("sea id = fun x -> x en id 1", T).

% Dentro de un «sea», el nombre tiene un solo tipo.
test(sea_monomorfico, fail) :-
    tipo_de("sea id = fun x -> x en si id verdadero entonces id 1 sino 2",
            _).

test(autoaplicacion, fail) :-
    tipo_de("fun x -> x x", _).

test(condicion_no_booleana, fail) :-
    tipo_de("si 1 entonces 2 sino 3", _).

test(ramas_distintas, fail) :-
    tipo_de("si verdadero entonces 1 sino []", _).

test(suma_booleano, fail) :-
    tipo_de("1 + verdadero", _).

test(sin_definir, fail) :-
    tipo_de("z 1", _).

% El tipo no ve los errores de ejecución: cabeza [] tiene tipo.
test(cabeza_vacia, true(T == "a")) :-
    tipo_de("cabeza []", T).

test(definiciones, true(T == "a -> [a]")) :-
    tipo_de("g", "g x = cons x []", T).

test(definicion_sin_tipo, fail) :-
    tipo_de("1", "f x = x x", _).

test(plegados, true(Ts == [ "(a -> a -> a) -> [a] -> a",
                            "(a -> b -> c -> c) -> c -> [a] -> [b] -> c",
                            "[entero] -> [entero] -> entero" ])) :-
    plegados(D),
    maplist(tipo_en(D),
            ["plegar1_der", "plegar2_der", "producto_interno"], Ts).

test(tipos_del_programa, true(N == 16)) :-
    preludio_leido(P),
    tipos_del_programa(P, G),
    length(G, N).

test(tipar_definicion, true(T == fn(entero, entero))) :-
    tipar_definicion(def(f, lam(x, id(x))), [], G),
    G = [f-T],
    T = fn(entero, _).

test(tipo_aplicacion, true(T == lista(entero))) :-
    tipo(ap(ap(id(cons), num(1)), id(nil)), [], [], T).

test(tipo_local, true(T == fn(A, A))) :-
    tipo(lam(x, id(x)), [], [], T),
    T = fn(A, _).

test(unificar_infinito, fail) :-
    unificar(A, fn(A, entero)).

test(mostrar_tipo, true(S == "(a -> b) -> [a] -> [b]")) :-
    mostrar_tipo(fn(fn(X, Y), fn(lista(X), lista(Y))), S).

test(mostrar_no_liga, true(var(X))) :-
    mostrar_tipo(fn(X, X), _).

:- end_tests(tipos).
