:- encoding(utf8).

:- begin_tests(negacion).

test(soltero, all(X == [ana, eva])) :-
    resolver(soltero(X)).

% Las respuestas son las de Prolog con las mismas cláusulas.
test(nativas, [forall(member(Cs-Q, [ [(p(a) :- true), (p(b) :- true),
                                      (q(X) :- \+ p(X))]-q(c),
                                     [(p(a) :- true)]-(\+ \+ p(_)),
                                     [(p(1) :- true), (p(2) :- true),
                                      (r(X) :- p(X), \+ (p(Y), Y > X))]-r(_)
                                   ])),
               true(Rs =@= Ns)]) :-
    findall(Q, almacen:resolver_clausulas(negacion, Cs, Q), Rs),
    nativas(Cs, Q, Ns).

% Las ligaduras de la segunda ejecución se descartan.
test(doble_negacion, all(Z == [c])) :-
    almacen:resolver_clausulas(negacion, [(p(a) :- true)],
                               (\+ \+ p(Z), Z = c)).

% Un corte dentro de la negación no corta las alternativas de afuera.
test(corte_adentro, all(X == [a, b])) :-
    almacen:resolver_clausulas(negacion,
                               [(p(a) :- true), (p(b) :- true),
                                (q(_) :- fail)],
                               (p(X), \+ (q(X), !))).

% Con error/1, una llamada sin cláusulas pasa a error(Meta), que aquí
% falla; la segunda cláusula sigue.
test(desconocido, all(X == [b])) :-
    resolver(desconocido(X)).

% Una celda libre en una expresión aritmética también pasa a error/1.
test(aritmetica, [fail]) :-
    resolver(siguiente(_, _)).

% Sin error/1, el error sale de la máquina.
test(sin_error, [error(existence_error(procedure, q/1))]) :-
    almacen:resolver_clausulas(negacion, [(p(X) :- q(X))], p(_)).

% error/1 recibe la meta que produjo el error, con sus celdas: aquí liga
% la variable de q(X).
test(meta_del_error, all(Z == [7])) :-
    almacen:resolver_clausulas(negacion,
                               [(p(X) :- q(X)), (error(q(Y)) :- Y = 7)],
                               p(Z)).

% La segunda ejecución cuenta sus pasos y sus celdas.
test(medir, [true(R-P == 2-8)]) :-
    medir_programa(soltero, soltero(_), M),
    memberchk(respuestas-R, M),
    memberchk(pasos-P, M).

nativas(Clausulas, Meta, Respuestas) :-
    in_temporary_module(Modulo,
                        forall(member(C, Clausulas), assertz(Modulo:C)),
                        findall(Meta, Modulo:Meta, Respuestas)).

:- end_tests(negacion).
