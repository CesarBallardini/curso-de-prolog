:- encoding(utf8).

:- use_module('../capitulo-31/inscripciones/datos').
:- use_module('../capitulo-31/inscripciones/reglas', [ requisitos_de/2 as requisitos_31 ]).

:- begin_tests(requisitos).

% Sin tabla, log aparece dos veces: por pp y por ssl.
test(repetidos, [true(Rs == [pp, ssl, log, log, alg])]) :-
    findall(R, requisito_sin_tabla(bd, R), Rs).

test(sin_repetidos, [true(Rs == [alg, log, pp, ssl])]) :-
    findall(R, requisito(bd, R), Rs0),
    length(Rs0, 4),
    msort(Rs0, Rs).

test(de_bd, [true(Rs == [alg, log, pp, ssl])]) :-
    requisitos_de(bd, Rs).

test(sin_requisitos, [true(Rs == [])]) :-
    requisitos_de(am1, Rs).

% El mismo resultado que el módulo reglas del capítulo 31, materia por
% materia.
test(como_el_31, [forall(materia(M, _, _)), true(Rs == Rs31)]) :-
    requisitos_de(M, Rs),
    requisitos_31(M, Rs31).

test(materia_libre, [error(instantiation_error)]) :-
    requisitos_de(_, _).

% La relación inversa: las materias que tienen a log como requisito.
test(inversa, [true(Ms == [bd, pp, ssl])]) :-
    findall(M, requisito(M, log), Ms0),
    msort(Ms0, Ms).

:- end_tests(requisitos).
