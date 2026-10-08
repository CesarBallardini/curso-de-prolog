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

% Ejercicio 15: una respuesta por aparición, en los dos modos del
% encabezado, y las mismas respuestas que select/4.
test(reemplazo, all(L == [[a, z, c, b], [a, b, c, z]])) :-
    reemplazo(b, [a, b, c, b], z, L).

test(reemplazo_inverso, all(L == [[a, b, c]])) :-
    reemplazo(b, L, z, [a, z, c]).

test(reemplazo_sin_aparicion, [fail]) :-
    reemplazo(q, [a, b], z, _).

test(reemplazo_con_dos_apariciones, all(L == [[x, a, b], [b, a, x]])) :-
    reemplazo(b, [b, a, b], x, L).

test(select_con_dos_apariciones, all(L == [[x, a, b], [b, a, x]])) :-
    select(b, [b, a, b], x, L).

% Ejercicio 16: $ poda como el corte y además exige que el resto de la
% cláusula tenga éxito una vez; con la salida ligada a un valor falso, el
% resto falla y $ lo informa como error. En mal_maximo_d/3, $ no se ejecuta.
test(maximo_d_libre, true(M == 3)) :-
    maximo_d(3, 1, M).

test(maximo_d_segunda_clausula, true(M == 3)) :-
    maximo_d(1, 3, M).

test(maximo_d_ligado_correcto) :-
    maximo_d(3, 1, 3).

test(maximo_d_ligado_falso_es_error,
     [error(determinism_error(maximo_d/3, det, fail, guard))]) :-
    maximo_d(3, 1, 1).

test(mal_maximo_d_ligado_falso_se_cumple) :-
    mal_maximo_d(3, 1, 1).

:- end_tests(soluciones).
