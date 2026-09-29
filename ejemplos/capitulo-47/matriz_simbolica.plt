:- encoding(utf8).

:- begin_tests(matriz_simbolica).

test(sin_simplificar, [true(P == [[0 + a * x + b * y], [0 + c * x + d * y]])]) :-
    producto_sin_simplificar([[a, b], [c, d]], [[x], [y]], P).

test(simplificado, [true(P == [[a * x + b * y], [c * x + d * y]])]) :-
    producto_simbolico([[a, b], [c, d]], [[x], [y]], P).

% Con números, el producto simbólico simplificado es el numérico.
test(como_el_numerico, [true(P == C)]) :-
    A = [[1, 2], [3, 4]],
    B = [[5, 6], [7, 8]],
    producto(A, B, C),
    producto_simbolico(A, B, P).

test(rotaciones, [true(P == [ [cos(t), -sin(t) * -sin(f), -sin(t) * cos(f), 0],
                              [0, cos(f), sin(f), 0],
                              [sin(t), cos(t) * -sin(f), cos(t) * cos(f), 0],
                              [0, 0, 0, 1] ])]) :-
    rotacion(y, t, A),
    rotacion(x, f, B),
    producto_simbolico(A, B, P).

% El simplificador elimina los productos por 0 y por 1: R * I es R.
test(identidad_neutra, [true(P == R)]) :-
    rotacion(z, a, R),
    identidad(4, I),
    producto_simbolico(R, I, P).

:- end_tests(matriz_simbolica).
