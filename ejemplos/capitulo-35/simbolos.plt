:- encoding(utf8).

:- begin_tests(simbolos).

test(adelante, true(C == [saltar(2), sumar])) :-
    ensamblar([saltar(fin), sumar, etiqueta(fin)], C).

test(atras, true(C == [sumar, saltar(0)])) :-
    ensamblar([etiqueta(inicio), sumar, saltar(inicio)], C).

test(cuenta, true(C == [ apilar(3), guardar(n), cargar(n),
                         saltar_si_cero(11), cargar(n), escribir,
                         cargar(n), apilar(1), restar, guardar(n),
                         saltar(2) ])) :-
    programa(cuenta, P),
    ensamblar(P, C).

% Antes de verificar la tabla, un salto hacia una etiqueta sin marca deja
% la dirección libre.
test(tabla_incompleta, true(T-C = [fin-D|_]-[saltar(D), sumar])) :-
    phrase(codigo([saltar(fin), sumar], 0, T), C).

test(sin_marca, [error(existence_error(etiqueta, fin))]) :-
    ensamblar([saltar(fin), sumar], _).

test(marca_repetida, [fail]) :-
    ensamblar([etiqueta(a), sumar, etiqueta(a)], _).

% Dos marcas seguidas tienen la misma dirección: el ensamblado no falla.
test(marca_seguida, true(C == [sumar])) :-
    ensamblar([etiqueta(a), etiqueta(a), sumar], C).

test(sin_etiquetas, true(C == [apilar(1), escribir])) :-
    ensamblar([apilar(1), escribir], C).

% Cada línea tiene la dirección en cuatro columnas y la instrucción.
test(listar, true([Primera, Ultima] == ["0   apilar(3)", "10  saltar(2)"])) :-
    with_output_to(string(S), listar(cuenta)),
    split_string(S, "\n", "", Lineas),
    Lineas = [Primera|_],
    once(append(_, [Ultima, ""], Lineas)).

% Una instrucción que simple/1 no reconoce hace fallar el ensamblado.
test(instruccion_desconocida, [fail]) :-
    ensamblar([multiplicar], _).

test(etiquetas_definidas, true) :-
    etiquetas_definidas([a-0, b-3|_]).

test(mostrar, true(S == "5   sumar\n6   escribir\n")) :-
    with_output_to(string(S), mostrar([sumar, escribir], 5)).

:- end_tests(simbolos).
