:- encoding(utf8).

:- begin_tests(diccionario).

test(buscar_esta, true(V == 2)) :-
    buscar(b, [a-1, b-2|_], V).

test(buscar_agrega, true(D-V == [a-1, c-V|F]-V)) :-
    D = [a-1|F0],
    buscar(c, D, V),
    F0 = [_|F].

test(buscar_otro_valor, [fail]) :-
    buscar(a, [a-1|_], 2).

% memberchk/2 compara el par entero: agrega la clave repetida.
test(memberchk_repite, true(D = [a-1, a-2|_])) :-
    D = [a-1|_],
    memberchk(a-2, D).

test(buscar_despues_liga, true(V == 7)) :-
    buscar(x, D, V),
    buscar(x, D, 7).

test(codigos, true(C = [A, B, A])) :-
    codigos([el, gato, el], D, C),
    D = [el-A, gato-B|_].

test(codificar, true(C == [1, 2, 3, 1, 4])) :-
    codificar([el, gato, y, el, perro], C).

test(codificar_vacia, true(C == [])) :-
    codificar([], C).

test(arbol, true(A-V = t(b, 2, t(a, 1, _, _), _)-2)) :-
    buscar_arbol(b, A, 2),
    buscar_arbol(a, A, 1),
    buscar_arbol(b, A, V).

test(arbol_otro_valor, [fail]) :-
    buscar_arbol(b, A, 2),
    buscar_arbol(b, A, 3).

test(arbol_como_lista, true(C1 =@= C2)) :-
    mezcladas(300, Ks),
    append(Ks, Ks, Palabras),
    codigos(Palabras, _, C1),
    codigos_arbol(Palabras, _, C2).

test(mezcladas, true(N == 1000)) :-
    mezcladas(1000, Ks),
    sort(Ks, S),
    length(S, N).

% El árbol usa muchas menos inferencias que la lista.
test(arbol_menos_inferencias, true(IA * 10 < IL)) :-
    mezcladas(1000, Ks),
    statistics(inferences, I0),
    codigos(Ks, _, _),
    statistics(inferences, I1),
    codigos_arbol(Ks, _, _),
    statistics(inferences, I2),
    IL is I1 - I0,
    IA is I2 - I1.

% Con el final cerrado, una clave que no está no se puede agregar.
test(buscar_cerrado, [fail]) :-
    buscar(c, [a-1, b-2], _).

test(arbol_derecha, true(A = t(b, 2, _, t(c, 3, _, _)))) :-
    buscar_arbol(b, A, 2),
    buscar_arbol(c, A, 3).

test(codigos_arbol, true(C = [X, Y, X])) :-
    codigos_arbol([el, gato, el], _, C),
    X \== Y.

test(numerar, true(X-Y-F0 == 1-2-F0)) :-
    D = [a-X, b-Y|F0],
    numerar(D, 1),
    var(F0).

test(mezclar, true(K == 7919)) :-
    mezclar(1, K).

:- end_tests(diccionario).
