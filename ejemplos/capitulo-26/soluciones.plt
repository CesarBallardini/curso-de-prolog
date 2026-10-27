:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(division_por_cero, [error(evaluation_error(zero_divisor))]) :-
    _ is 1/0.

test(no_evaluable, [error(type_error(evaluable, a/0))]) :-
    _ is a + 1.

% atom_length/2 acepta un número, y lo convierte en texto.
test(atom_length_de_un_numero, true(L == 3)) :-
    atom_length(123, L).

% Ejercicio 3
test(leer_nota, true(N == 7)) :-
    leer_nota("7", N).

test(leer_nota_fuera_de_rango, [error(domain_error(nota, "11"))]) :-
    leer_nota("11", _).

test(leer_nota_no_texto, [error(type_error(text, 7))]) :-
    leer_nota(7, _).

% Ejercicio 4
test(seguro_falla, true(R == falla)) :-
    seguro(member(3, [1, 2]), R).

test(seguro_error, true(R == error(evaluation_error(zero_divisor)))) :-
    seguro(_ is 1/0, R).

test(seguro_ok, true(R == ok)) :-
    seguro(member(1, [1, 2]), R).

% Ejercicio 5
test(promedio_vacio, true(P == sin_datos)) :-
    promedio_seguro([], P).

test(promedio, true(P =:= 7.5)) :-
    promedio_seguro([6, 9], P).

test(promedio_otro_error, [error(type_error(evaluable, a/0))]) :-
    promedio_seguro([6, a], _).

% Ejercicio 6
test(rango, true(L == [3, 4, 5])) :-
    rango(3, 5, L).

test(rango_invertido, [error(domain_error(rango, 5-3))]) :-
    rango(5, 3, _).

% Ejercicio 7
test(primera_linea, true(L == "uno")) :-
    primera_linea("uno\ndos", L).

test(primera_linea_vacia, true(L == "")) :-
    primera_linea("", L).

% Ejercicio 8
test(mensaje, true(L == ['La nota ~w no es válida: debe ser un entero de 1 \c
                          a 10'-[11]])) :-
    once(phrase(prolog:message(nota_invalida(11)), L)).

% Ejercicio 9
test(telefono, true(T == "2234567890")) :-
    limpiar_telefono("(223) 456-7890", T).

test(telefono_corto, [error(domain_error(telefono, cantidad_de_digitos(9)))]) :-
    limpiar_telefono("223.456.789", _).

test(telefono_area, [error(domain_error(telefono, codigo_de_area('1')))]) :-
    limpiar_telefono("123-456-7890", _).

test(telefono_letras, [error(domain_error(telefono, letras))]) :-
    limpiar_telefono("223-abc-7890", _).

% Ejercicio 14: catch/3 es transparente al retroceso.
test(catch_y_retroceso, all(X == [1, 2, 3])) :-
    catch(member(X, [1, 2, 3]), _, true).

:- end_tests(soluciones).
