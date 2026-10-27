:- encoding(utf8).

:- begin_tests(modelos).

% Una respuesta por cada literal positivo de la primera cláusula violada.
test(proposicional, all(M == [[p, r, s], [q, r, s]])) :-
    modelo([[+p, +q], [-p, +r], [-q, +r], [-r, +s]], M).

test(insatisfacible, [fail]) :-
    modelo([[+p], [-p]], _).

% Los dos modelos mínimos del ejemplo de Flach.
test(flach, all(M == [ [adulto(pablo), casado(pablo), hombre(pablo),
                        tiene_esposa(pablo)],
                       [adulto(pablo), hombre(pablo), soltero(pablo)]
                     ])) :-
    modelo([ [+casado(X), +soltero(X), -hombre(X), -adulto(X)],
             [+tiene_esposa(Y), -casado(Y), -hombre(Y)],
             [+hombre(pablo)],
             [+adulto(pablo)]
           ], M).

% El primer modelo no es mínimo: docente(pedro) sobra.
test(no_minimo, all(M == [ [amable(maria), docente(pedro),
                            estudiante(maria), gusta(pedro, maria)],
                           [amable(maria), estudiante(maria),
                            gusta(pedro, maria)]
                         ])) :-
    modelo([ [+gusta(pedro, maria)],
             [+estudiante(maria)],
             [+docente(X), +amable(Y), -gusta(X, Y), -estudiante(Y)],
             [+amable(Y1), -docente(X1), -gusta(X1, Y1)]
           ], M).

% Una cláusula que no es de rango restringido produce un error.
test(rango, [error(domain_error(clausula_de_rango_restringido, _))]) :-
    modelo([[+hombre(X), +mujer(X)]], _).

% Con el predicado de dominio persona/1, la cláusula pasa a serlo.
test(dominio, all(M == [[hombre(pedro), mujer(maria), persona(maria),
                         persona(pedro)]])) :-
    modelo([ [+hombre(X), +mujer(X), -persona(X)],
             [+persona(maria)], [+persona(pedro)],
             [-hombre(maria)], [-mujer(pedro)]
           ], M).

test(signos, [true(N-P == [b, c]-[a])]) :-
    modelos:signos([+a, -b, -c], N, P).

test(violada, [true(P == [q])]) :-
    modelos:violada([-p, +q], [p], P).

test(no_violada, [fail]) :-
    modelos:violada([-p, +q], [p, q], _).

test(contramodelo, all(M == [[q]])) :-
    contramodelo("(p → q) → (q → p)", M).

test(contramodelo_tautologia, [fail]) :-
    contramodelo("p ∨ ¬p", _).

:- end_tests(modelos).
