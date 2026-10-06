:- encoding(utf8).

:- begin_tests(cuantificadores).

% Las dos lecturas de «todo alumno lee un libro».
test(dos_lecturas, [true(Fs =@= [todo(X, alumno(X),
                                      alguno(Y, libro(Y), leer(X, Y))),
                                 alguno(Y2, libro(Y2),
                                        todo(X2, alumno(X2), leer(X2, Y2)))])]) :-
    findall(F, phrase(oracion_logica_es(F),
                      ["todo", "alumno", "lee", "un", "libro"]), Fs).

test(una_lectura, [true(Fs =@= [alguno(X, alumno(X), dormir(X))])]) :-
    findall(F, phrase(oracion_logica_en(F), ["a", "student", "sleeps"]), Fs).

% Las dos lecturas se generan con la misma oración: la ambigüedad pasa a
% la traducción.
test(genera_la_misma_oracion, [true(L == [["todo", "alumno", "lee", "un",
                                           "libro"]])]) :-
    findall(Ps, phrase(oracion_logica_es(alguno(Y, libro(Y),
                                                todo(X, alumno(X),
                                                     leer(X, Y)))),
                       Ps),
            L).

test(no_confunde_variables, [fail]) :-
    phrase(oracion_logica_es(todo(X, alumno(X), alguno(Y, libro(Y),
                                                       leer(Y, X)))),
           ["todo", "alumno", "lee", "un", "libro"]).

test(traducciones, [true(Ts == [["every", "student", "reads", "a",
                                 "book"]])]) :-
    traducciones_logicas(["todo", "alumno", "lee", "un", "libro"], Ts).

test(al_castellano, [true(Ts == [["todo", "gato", "ve", "una", "casa"]])]) :-
    traducciones_logicas(["every", "cat", "sees", "a", "house"], Ts).

test(genero, all(E == [["toda", "casa", "tiene", "un", "gato"],
                       ["toda", "casa", "tiene", "un", "gato"]])) :-
    en_es_logica(["every", "house", "has", "a", "cat"], E).

test(es_en, all(E == [["every", "house", "has", "a", "cat"],
                      ["every", "house", "has", "a", "cat"]])) :-
    es_en_logica(["toda", "casa", "tiene", "un", "gato"], E).

test(genero_mal, [fail]) :-
    phrase(oracion_logica_es(_), ["todo", "casa", "duerme"]).

test(alcance_invierte, [true(F =@= alguno(Y, libro(Y),
                                          todo(X, alumno(X), leer(X, Y))))]) :-
    alcance(todo(X0, alumno(X0), alguno(Y0, libro(Y0), leer(X0, Y0))), F),
    F = alguno(_, _, _).

test(alcance_un_cuantificador, all(F =@= [alguno(X, gato(X), dormir(X))])) :-
    alcance(alguno(X1, gato(X1), dormir(X1)), F).

test(misma_formula_libre, [true(F == g(a))]) :-
    misma_formula(g(a), F).

test(misma_formula_variante) :-
    misma_formula(f(X, Y), f(A, B)),
    X == A,
    Y == B.

test(misma_formula_distinta, [fail]) :-
    misma_formula(f(X, Y, X), f(_, Y, Y)).

test(oracion_es_q, all(F =@= [alguno(X, gato(X), dormir(X))])) :-
    phrase(oracion_es_q(F), ["un", "gato", "duerme"]).

test(sn_es_q, all(R =@= [X^todo(X, casa(X), p(X))])) :-
    phrase(sn_es_q((Z^p(Z))^S), ["toda", "casa"]),
    R = Z^S.

test(sv_es_q, [nondet, true(P =@= X^alguno(Y, libro(Y), leer(X, Y)))]) :-
    phrase(sv_es_q(P), ["lee", "un", "libro"]).

test(oracion_en_q, all(F =@= [todo(X, gato(X), dormir(X))])) :-
    phrase(oracion_en_q(F), ["every", "cat", "sleeps"]).

test(sn_en_q, all(R =@= [X^alguno(X, libro(X), p(X))])) :-
    phrase(sn_en_q((Z^p(Z))^S), ["a", "book"]),
    R = Z^S.

test(sv_en_q, [nondet, true(P =@= X^dormir(X))]) :-
    phrase(sv_en_q(P), ["sleeps"]).

test(lecturas, [true(Vs == [verdadera, falsa])]) :-
    lecturas(["todo", "alumno", "lee", "un", "libro"], Ls),
    pairs_values(Ls, Vs).

test(verdadera) :-
    verdadera(alguno(X, alumno(X), leer(X, rayuela))).

test(falsa, [fail]) :-
    verdadera(todo(X, libro(X), leer(ana, X))).

test(valor, [true(V-F == falsa-todo(X, libro(X), leer(ana, X)))]) :-
    F = todo(X, libro(X), leer(ana, X)),
    valor(F, V).

:- end_tests(cuantificadores).
