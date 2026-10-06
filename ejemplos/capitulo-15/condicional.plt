:- encoding(utf8).

% Las pruebas de los modos det y semidet no declaran nondet: plunit advierte
% si queda una alternativa pendiente, y con el condicional no queda ninguna.

:- begin_tests(condicional).

test(sofia_es_bebe, true(C == bebe)) :-
    categoria(sofia, C).

test(luis_es_chico, true(C == chico)) :-
    categoria(luis, C).

% Estabilidad: con la categoría ligada a un valor falso, falla. Es la consulta
% que clasificaba a sofía como adulta en la sección 9.5.
test(sofia_no_es_adulta, [fail]) :-
    categoria(sofia, adulto).

test(todas_las_categorias, all(P-C == [juan-adulto, ana-adulto, pedro-adulto,
                                       luis-chico, eva-chico, sofia-bebe])) :-
    categoria(P, C).

test(signo_negativo, true(S == negativo)) :-
    signo(-3, S).

test(signo_ligado_falso, [fail]) :-
    signo(-3, positivo).

% sacar/3 ya no deja la alternativa que el capítulo 14 registraba.
test(sacar_sin_alternativas, true(R == [b, a])) :-
    sacar(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(z, [a, b], _).

% sin_repetidos/2 ya no deja la alternativa del capítulo 9.
test(sin_repetidos_la_primera, true(R == [a, b, c])) :-
    sin_repetidos([a, b, a, c, b], R).

test(el_primer_mayor, true(P == juan)) :-
    primer_mayor_de_edad(P).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(presentar_con_edad, true(S == "ana (41 años)\n")) :-
    with_output_to(string(S), presentar(ana)).

test(presentar_sin_edad, true(S == "marta\n")) :-
    with_output_to(string(S), presentar(marta)).

:- end_tests(condicional).
