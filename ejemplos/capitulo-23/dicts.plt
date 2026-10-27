:- encoding(utf8).

:- begin_tests(dicts).

test(edad_de_ana, true(E == 41)) :-
    persona(ana, D),
    get_dict(edad, D, E).

test(notacion_funcional, true(E == 41)) :-
    persona(ana, D),
    E = D.edad.

test(cumple_anios, true(E0-E == 41-42)) :-
    persona(ana, D0),
    cumple_anios(D0, D),
    get_dict(edad, D0, E0),
    get_dict(edad, D, E).

test(etiqueta, true(T == persona)) :-
    persona(ana, D),
    is_dict(D, T).

test(mayores, true(L == [juan, ana])) :-
    mayores(L).

% Una clave que no existe produce un error con la notación funcional.
test(clave_inexistente, [error(existence_error(key, altura, _), _)]) :-
    persona(ana, D),
    _ = D.altura.

test(presentar, true(T == "buenas, ana (41)")) :-
    presentar(ana, [saludo(buenas)], T).

test(presentar_por_omision, true(T == "hola, ana (41)")) :-
    presentar(ana, [], T).

test(presentar_sin_edad, true(T == "hola, eva")) :-
    presentar(eva, [con_edad(false)], T).

:- end_tests(dicts).
