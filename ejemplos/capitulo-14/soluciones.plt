:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3: una prueba por modo de sacar(+X, +L, -R) is semidet, y los
% casos límite. Una respuesta como mucho, pero la implementación deja una
% alternativa pendiente (la segunda cláusula), y por eso las pruebas que se
% cumplen declaran nondet; los capítulos 15 y 16 muestran cómo quitarla.
test(sacar_la_primera_aparicion, [nondet, true(R == [b, a])]) :-
    sacar(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(z, [a, b], _).

test(sacar_con_resultado_ligado, [nondet]) :-
    sacar(a, [a, b, a], [b, a]).

% Ejercicio 4
test(el_nieto_de_ana, all(N == [eva])) :-
    abuelo(ana, N).

% Ejercicio 5: el modo -S y el modo +S, con un valor verdadero y uno falso.
test(signo_negativo, true(S == negativo)) :-
    signo(-3, S).

test(signo_cero, true(S == cero)) :-
    signo(0, S).

test(signo_positivo, true(S == positivo)) :-
    signo(5, S).

test(signo_ligado_verdadero) :-
    signo(-3, negativo).

test(signo_ligado_falso, [fail]) :-
    signo(-3, positivo).

test(signo_ligado_falso_en_cero, [fail]) :-
    signo(0, positivo).

% Ejercicio 7
test(aprobadas_de_ana, all(M == [am1, alg, log, am2])) :-
    aprobadas_de(101, M).

test(quienes_aprobaron_logica, all(L == [101, 102])) :-
    aprobadas_de(L, log).

test(bruno_no_aprobo_algebra, [fail]) :-
    aprobadas_de(102, alg).

% Ejercicio 8: las dos representaciones responden lo mismo.
test(vencidos_por_defecto, all(P == [p3])) :-
    vencido_por_defecto(P).

test(vencidos, all(P == [p3])) :-
    vencido(P).

% Ejercicio 12: iguala/2 liga variables; mismo_termino/2 no lo haría.
test(iguala_liga) :-
    iguala(X, a),
    X == a.

:- end_tests(soluciones).
