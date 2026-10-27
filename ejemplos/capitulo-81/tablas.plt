:- encoding(utf8).

:- begin_tests(tablas).

test(posibles_cubo,
     [true(Ps == [(a-b)-[mas], (a-c)-[mas], (a-d)-[mas],
                  (b-e)-[menos, der], (b-g)-[menos, izq],
                  (c-e)-[menos, izq], (c-f)-[menos, der],
                  (d-f)-[menos, izq], (d-g)-[menos, der]])]) :-
    posibles_clpfd(cubo, sin_borde, Ps).

test(modelo_con_borde_sin_etiquetar,
     [true(Vs == [1, 1, 1, 3, 4, 4, 3, 4, 3])]) :-
    modelo_clpfd(cubo, borde, Pares),
    pairs_values(Pares, Vs).

test(poiuyt_con_borde, [fail]) :-
    modelo_clpfd(poiuyt, borde, _).

test(cantidades, [true(Ns == [4, 15, 4, 0])]) :-
    findall(N, ( member(F, [cubo, bloques, escalon, poiuyt]),
                 interpretaciones_clpfd(F, sin_borde, N) ), Ns).

test(cubo_con_borde,
     [true(Ls == [(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
                  (c-e)-izq, (c-f)-der, (d-f)-izq, (d-g)-der])]) :-
    once(etiquetar_clpfd(cubo, borde, Ls)).

test(fijar_codigo, [true(V == 3)]) :-
    fijar_codigo([(a-b)-V], (a-b)-der).

test(tabla) :-
    Pares = [(a-b)-X, (a-c)-Y],
    tabla(Pares, u(a, ele, [b, c])),
    X = 1,
    Y == 3.

test(variable_de_linea, [true(V == x)]) :-
    variable_de_linea([(a-b)-x], b, a, V).

test(codigo_global, [true(Cs == [3, 4])]) :-
    codigo_global(a, b, der, C1),
    codigo_global(b, a, der, C2),
    Cs = [C1, C2].

test(etiquetas_posibles, [true(P == (a-b)-[mas, izq])]) :-
    V in 1 \/ 4,
    etiquetas_posibles((a-b)-V, P).

test(decodificar, [true(P == (a-b)-menos)]) :-
    decodificar((a-b)-2, P).

test(escribir_posibles, [true(T == "ab: [mas]
ac: [mas]
ad: [mas]
")]) :-
    with_output_to(string(T0), escribir_posibles(cubo, borde)),
    sub_string(T0, 0, 30, _, T).

:- end_tests(tablas).
