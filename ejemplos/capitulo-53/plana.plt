:- encoding(utf8).

:- begin_tests(plana).

test(maquina_i, [true(Fs == [0, 1, 0, 1, 0, 1, 0, 1, 0, 1])]) :-
    figuras(i, b, 10, Fs).

test(maquina_i_bis, [true(Fs == [0, 1, 0, 1, 0, 1, 0, 1, 0, 1])]) :-
    figuras(i_bis, b, 10, Fs).

test(maquina_ii, [true(Fs == [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])]) :-
    figuras(ii, b, 15, Fs).

test(cero_figuras, [true(Fs == [])]) :-
    figuras(ii, b, 0, Fs).

test(sin_fila, [fail]) :-
    figuras(ii, o, 1, _).

test(paso_ii, [true(Q-Ss == o-[schwa, schwa, 0, blanco, 0])]) :-
    cinta_vacia(C0),
    paso(ii, b, C0, Q, C, Fs),
    Fs == [0, 0],
    contenido(C, Ss).

test(leer_cabezal, [true(S == 0)]) :-
    cinta_vacia(C0),
    paso(ii, b, C0, _, C, _),
    leer(C, S).

test(cumple_libre, [true(X == x)]) :-
    cumple(simbolo(X), x).

test(cumple_blanco, [fail]) :-
    cumple(simbolo(_), blanco).

test(cumple_no, [fail]) :-
    cumple(no(x), x).

test(cumple_siempre) :-
    cumple(siempre, blanco).

test(contenido, [true(Ss == [1, blanco, x])]) :-
    contenido(c([blanco, 1, blanco], x, [blanco, blanco]), Ss).

test(operacion_figura, [true(C-Fs == c([], 1, [])-[1, z])]) :-
    plana:operacion(p(1), c([], blanco, []), C, Fs, [z]).

test(operacion_marca, [true(C-Fs == c([], x, [])-[z])]) :-
    plana:operacion(p(x), c([], blanco, []), C, Fs, [z]).

test(operacion_borrar, [true(C == c([a], blanco, [b]))]) :-
    plana:operacion(e, c([a], x, [b]), C, Fs, Fs).

test(operacion_izquierda_borde, [true(C == c([], blanco, [x]))]) :-
    plana:operacion(l, c([], x, []), C, Fs, Fs).

test(operacion_derecha, [true(C == c([x], 0, []))]) :-
    plana:operacion(r, c([], x, [0]), C, Fs, Fs).

test(operar_varias, [true(Ss-Fs == [0, blanco, 1]-[0, 1])]) :-
    operar([p(0), r, r, p(1)], c([], blanco, []), C, Fs, []),
    contenido(C, Ss).

:- end_tests(plana).
