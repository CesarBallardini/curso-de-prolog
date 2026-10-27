:- encoding(utf8).

:- begin_tests(memoria).

test(vacia, M == mt(0, [])) :-
    memoria_vacia(M).

% Un hecho repetido conserva el sello de su primera aparición.
test(conjunto, M == mt(2, [2-b, 1-a])) :-
    memoria_con([a, b, a], M).

test(afirmar_nuevo, M == mt(3, [3-c, 2-b, 1-a])) :-
    memoria_con([a, b], M0),
    afirmar(c, M0, M).

test(afirmar_repetido, M == M0) :-
    memoria_con([a, b], M0),
    afirmar(a, M0, M).

% Quitar un hecho no atrasa el reloj: el que vuelve recibe un sello nuevo.
test(retirar_y_volver, M == mt(3, [3-a, 2-b])) :-
    memoria_con([a, b], M0),
    retirar(a, M0, M1),
    afirmar(a, M1, M).

test(retirar_ausente, [fail]) :-
    memoria_con([a], M),
    retirar(b, M, _).

test(elementos, all(S-H == [3-c, 2-b, 1-a])) :-
    memoria_con([a, b, c], M),
    elemento(S, H, M).

test(hechos, H == [p(2), p(1)]) :-
    memoria_con([p(1), p(2)], M),
    hechos(M, H).

:- end_tests(memoria).
