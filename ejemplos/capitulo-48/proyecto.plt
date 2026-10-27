:- encoding(utf8).

:- begin_tests(proyecto).

% Las tres partes quedan cargadas juntas, sin conflictos de nombres.
test(inversa_exacta, [true(E == 0)]) :-
    hilbert(4, racional, H),
    inversa(H, I),
    desvio(H, I, E).

test(inversa_flotante, [true(E > 1)]) :-
    hilbert(12, flotante, H),
    inversa(H, I),
    desvio(H, I, E).

test(simbolico, [true(F == [cos(t), -sin(t) * -sin(f), -sin(t) * cos(f), 0])]) :-
    rotacion(y, t, A),
    rotacion(x, f, B),
    producto_simbolico(A, B, [F|_]).

test(horario, [true(Ultimo == '10:21'-ermita_vieja)]) :-
    horario_con_carga(pradera_alta, ermita_vieja, 60, 8:00, H),
    last(H, Ultimo).

:- end_tests(proyecto).
