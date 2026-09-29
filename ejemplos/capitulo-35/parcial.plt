:- encoding(utf8).

:- begin_tests(parcial).

test(cubo, true(R =@= (Y1 is X * 1, Y2 is X * Y1, Y is X * Y2))) :-
    parcial(potencia(s(s(s(cero))), X, Y), control_potencia, R).

test(cero, true(Y == 1)) :-
    parcial(potencia(cero, _, Y), control_potencia, R),
    assertion(R == true).

% Sin el exponente no hay nada que desplegar: la llamada queda.
test(sin_exponente, true(R == potencia(N, X, Y))) :-
    parcial(potencia(N, X, Y), control_potencia, R).

% El residuo calcula lo mismo que potencia/3.
test(residuo, true(Y == 125)) :-
    parcial(potencia(s(s(s(cero))), X, Y), control_potencia, R),
    X = 5,
    call(R).

test(conjuncion, true(R == (a, b))) :-
    parcial((true, a, true, b), control_potencia, R).

test(unificacion, true(X-R == 1-true)) :-
    parcial(X = 1, control_potencia, R).

% La acción dejar(R) reemplaza la llamada por R, sin desplegarla.
test(dejar, true(R =@= (Y is X * 1, mostrar(Y)))) :-
    parcial((potencia(s(cero), X, Y), escribir(Y)),
            [M, A]>>( M = escribir(T)
                    ->  A = dejar(mostrar(T))
                    ;   control_potencia(M, A) ),
            R).

% conjuncion/3 agrupa a la derecha y quita el true que sobra.
test(agrupada, true(R == (a, b, c))) :-
    conjuncion((a, b), c, R0),
    conjuncion(R0, true, R).

% Un residuo por cada combinación de cláusulas desplegadas: con un control
% que despliega siempre, una respuesta por exponente.
test(una_por_clausula,
     true(Pares =@= [ cero-true,
                      s(cero)-(_ is 2 * 1),
                      s(s(cero))-(Y is 2 * 1, _ is 2 * Y) ])) :-
    findnsols(3, N-R,
              parcial(potencia(N, 2, _),
                      [potencia(_, _, _), desplegar]>>true, R),
              Pares),
    !.

:- end_tests(parcial).
