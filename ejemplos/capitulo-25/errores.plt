:- encoding(utf8).

:- begin_tests(errores).

test(edad_de, true(E == 41)) :-
    edad_de(ana, E).

% Una persona sin edad es un error de existencia, no una falla.
test(persona_inexistente, [error(existence_error(persona, zoe))]) :-
    edad_de(zoe, _).

test(persona_libre, [error(instantiation_error)]) :-
    edad_de(_, _).

% edad/2, en cambio, falla: es un hecho, y no hay ninguno para zoe.
test(edad_falla, [fail]) :-
    edad(zoe, _).

test(meses, true(M == 36)) :-
    meses(3, M).

% must_be/2 de SWI-Prolog 9 informa un valor fuera del dominio como
% type_error, también cuando el tipo base es el correcto.
test(meses_negativo, [error(type_error(nonneg, -1))]) :-
    meses(-1, _).

test(meses_no_numero, [error(type_error(nonneg, tres))]) :-
    meses(tres, _).

test(leer_edad, true(E == 41)) :-
    leer_edad("41", E).

test(leer_no_numero, [error(domain_error(edad, "cuarenta"))]) :-
    leer_edad("cuarenta", _).

test(leer_fuera_de_rango, [error(domain_error(edad, "200"))]) :-
    leer_edad("200", _).

test(leer_no_entero, [error(domain_error(edad, "4.5"))]) :-
    leer_edad("4.5", _).

% number_string/2 falla con un texto que no es un número; number_codes/2
% produce un error de sintaxis.
test(number_string_falla, [fail]) :-
    number_string(_, "cuarenta").

test(number_codes_error, [error(syntax_error(_))]) :-
    number_codes(_, `cuarenta`).

test(por_omision, true(V == 0)) :-
    con_valor_por_omision(edad_de(zoe), 0, V).

test(con_valor, true(V == 41)) :-
    con_valor_por_omision(edad_de(ana), 0, V).

% Solo se captura el error de existencia: los demás se propagan.
test(otros_errores_se_propagan, [error(instantiation_error)]) :-
    con_valor_por_omision(edad_de(_), 0, _).

:- end_tests(errores).
