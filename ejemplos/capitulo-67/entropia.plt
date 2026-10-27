:- encoding(utf8).

:- begin_tests(entropia).

% La entropía máxima coincide con el producto de la independencia.
test(comparar, [true(F == [f(0.9, 0.8, 0.7, 0.8, 0.72, 0.72),
                           f(0.7, 0.4, 0.1, 0.4, 0.28, 0.28),
                           f(0.5, 0.5, 0.0, 0.5, 0.25, 0.25),
                           f(0.2, 0.3, 0.0, 0.2, 0.06, 0.06)])]) :-
    comparar([0.9-0.8, 0.7-0.4, 0.5-0.5, 0.2-0.3], F).

test(maxima, [true(X == 0.28)]) :-
    y_maxima_entropia(0.7, 0.4, X).

test(fila, [true(F == f(0.5, 0.5, 0.0, 0.5, 0.25, 0.25))]) :-
    fila(0.5-0.5, F).

% Dos casos equiprobables dan un bit; cuatro, dos.
test(entropia_de, [true(H1-H2 =:= 1-2)]) :-
    entropia_de([0.5, 0.5], H1),
    entropia_de([0.25, 0.25, 0.25, 0.25], H2).

test(termino_cero, [true(H =:= 1.5)]) :-
    sumar_termino(0.0, 1.5, H).

test(casos, [true(Ps == [0.25, 0.25, 0.25, 0.25])]) :-
    casos(0.5, 0.5, 0.25, Ps).

% 0.7 + 0.4 - 1 no da exactamente 0.1 en punto flotante.
test(intervalo, [true(abs(I - 0.1) + abs(S - 0.4) < 1.0e-9)]) :-
    intervalo_y(0.7, 0.4, I, S).

% En los extremos del intervalo la entropía es menor que en el producto.
test(entropia_y) :-
    entropia_y(0.7, 0.4, 0.28, H),
    entropia_y(0.7, 0.4, 0.1, H1),
    entropia_y(0.7, 0.4, 0.4, H2),
    H > H1,
    H > H2.

test(ternaria, [true(abs(X - 0.25) < 1.0e-6)]) :-
    ternaria(100, 0.5, 0.5, 0.0, 0.5, X).

:- end_tests(entropia).
