:- encoding(utf8).

:- begin_tests(soluciones_matriz).

test(det_hilbert, [true(D == 1r6048000)]) :-
    hilbert(4, racional, H),
    determinante(H, D).

test(det_intercambio, [true(D == -1)]) :-
    determinante([[0, 1], [1, 0]], D).

test(det_tres_filas, [true(D == -1)]) :-
    determinante([[0, 0, 1], [0, 1, 0], [1, 0, 0]], D).

test(det_singular, [true(D == 0)]) :-
    determinante([[1, 2], [2, 4]], D).

test(det_no_cuadrada, [error(domain_error(matriz_cuadrada, _))]) :-
    determinante([[1, 2]], _).

% Una matriz es invertible si y solo si su determinante no es 0.
test(det_e_inversa, [true(D =\= 0)]) :-
    A = [[2, 1, 0], [1, 3, 1], [0, 1, 4]],
    inversa(A, _),
    determinante(A, D).

test(resolver, [true(X == [4r5, 7r5])]) :-
    resolver([[2, 1], [1, 3]], [3, 5], X).

test(resolver_verifica, [true(B == [[3], [5]])]) :-
    resolver([[2, 1], [1, 3]], [3, 5], X),
    maplist([Xi, [Xi]]>>true, X, Columna),
    producto([[2, 1], [1, 3]], Columna, B).

test(resolver_singular, [fail]) :-
    resolver([[1, 2], [2, 4]], [1, 2], _).

test(suma, [true(C == [[4, 6]])]) :-
    suma([[1, 2]], [[3, 4]], C).

test(por_escalar, [true(B == [[2, 3]])]) :-
    por_escalar(1r2, [[4, 6]], B).

test(traza, [true(T == 5)]) :-
    traza([[1, 2], [3, 4]], T).

test(potencia, [true(P == [[89, 55], [55, 34]])]) :-
    potencia([[1, 1], [1, 0]], 10, P).

test(potencia_cero, [true(P == [[1, 0], [0, 1]])]) :-
    potencia([[1, 1], [1, 0]], 0, P).

test(productos, [true(N == 11)]) :-
    potencia([[1, 1], [1, 0]], 300, _, N).

test(fibonacci, [true(F == 222232244629420445529739893461909967206666939096499764990979600)]) :-
    fibonacci(300, F).

test(signos, [true(Es == [a * b, -(a * b), a - b * c, a + b, x])]) :-
    maplist(simplificar_signos,
            [-a * -b, a * -b, a + -(b * c), a - -b, -(-x)],
            Es).

test(rotaciones_z, [true(F == [cos(t) * cos(f) - sin(t) * sin(f),
                               cos(t) * sin(f) + sin(t) * cos(f), 0, 0])]) :-
    rotacion(z, t, A),
    rotacion(z, f, B),
    producto_con_signos(A, B, [F|_]).

test(det_vacia, [true(D == 1)]) :-
    det([], D).

test(det_dos, [true(D == -2)]) :-
    det([[1, 2], [3, 4]], D).

test(reducir_fila, [true(R == [-2])]) :-
    reducir_fila([1, 2], [3, 4], R).

test(reducir_fila_racional, [true(R == [1r2])]) :-
    reducir_fila([2, 1], [1, 1], R).

test(simplificar_signos_libre, [error(instantiation_error)]) :-
    simplificar_signos(_ * -b, _).

test(signos_anidados, [true(E == a * b * c)]) :-
    signos(-(-(a * b)) * c, E).

% Las reglas no son excluyentes: -a * -b reescribe con tres.
test(regla_signo, all(E == [a * b, -(-a * b), -(a * -b)])) :-
    regla_signo(-a * -b, E).

test(regla_signo_ninguna, [fail]) :-
    regla_signo(a * b, _).

:- end_tests(soluciones_matriz).
