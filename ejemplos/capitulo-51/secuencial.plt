:- encoding(utf8).

:- begin_tests(secuencial).

% El transductor da lo mismo que ejecutar/4 del capítulo 48.
test(paridad, [true(Ss == Es)]) :-
    Ps = [[1], [0], [0], [1], [1], [0]],
    once(transducir(circuito(paridad, [0]), Ps, Ss)),
    once(secuenciales:ejecutar(paridad, [0], Ps, Es)).

test(gray, [true(Ss == [[0, 0, 0], [1, 0, 0], [1, 1, 0]])]) :-
    once(transducir(circuito(contador_gray, [0, 0, 0]), [[], [], []], Ss)).

test(estados, [true(N == 8)]) :-
    numero_estados(circuito(contador_gray, [0, 0, 0]), N).

test(tabla, [true(T == automata(2, [0, 1],
                                [0-([[0]]:[[0]])-0, 0-([[1]]:[[1]])-1,
                                 1-([[0]]:[[1]])-1, 1-([[1]]:[[0]])-0]))]) :-
    tabla(circuito(paridad, [0]), T).

% 1 + 3 = 4, el bit menos significativo primero.
test(sumador, [true(Ss == [[0, 0, 1]])]) :-
    findall(S, transducir(sumador_serie, [[1, 1], [0, 1], [0, 0]], S), Ss).

test(desborde, [fail]) :-
    transducir(sumador_serie, [[1, 1], [1, 0], [0, 1]], _).

% Los pares de números de tres bits que suman 6: siete.
test(sumandos, [true(N == 7)]) :-
    findall(Ps, transducir(sumador_serie, Ps, [0, 1, 1]), L),
    length(L, N).

test(min_registro4, [true(N == 17)]) :-
    numero_estados(min(circuito(registro4, [0, 0, 0, 0])), N).

:- end_tests(secuencial).
