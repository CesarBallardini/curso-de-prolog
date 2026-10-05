:- encoding(utf8).

:- begin_tests(conjuntiva).

% El bloque a tiene encima un bloque rojo; el b, no.
test(bloques, [true(Is == [instanciacion(libre, [2], 2,
                                         [agregar(libre_de_rojo(b))])])]) :-
    conjunto_conj(bloques, [bloque(a), bloque(b), sobre(c, a),
                            color(c, rojo)], Is).

% Quitar un hecho de la conjunción agrega la instanciación.
test(quitar_agrega,
     [true(Is == [instanciacion(libre, [1], 2,
                                [agregar(libre_de_rojo(a))])])]) :-
    cambios_conj(bloques, [bloque(a), sobre(c, a), color(c, rojo)],
                 [menos(color(c, rojo))], Is).

% Cada patrón por separado no bloquea: hace falta la combinación.
test(por_separado, [true(N == 1)]) :-
    conjunto_conj(bloques, [bloque(a), sobre(c, a), color(d, rojo)], Is),
    length(Is, N).

test(desde_cero) :-
    mismo_conjunto_conj(bloques,
                        [bloque(a), bloque(b), sobre(c, a), color(c, rojo),
                         sobre(d, b), color(d, azul), sobre(e, b)],
                        [mas(color(e, rojo)), menos(color(c, rojo)),
                         mas(color(c, rojo)), menos(sobre(e, b)),
                         menos(bloque(a))]).

% Dos combinaciones bloquean el mismo token: hay que quitar las dos.
test(dos_bloqueos, [true(L == [0, 0, 1])]) :-
    H = [bloque(a), sobre(c, a), color(c, rojo), sobre(d, a),
         color(d, rojo)],
    findall(N, ( member(Cs, [[], [menos(color(c, rojo))],
                            [menos(color(c, rojo)), menos(sobre(d, a))]]),
                 cambios_conj(bloques, H, Cs, Is),
                 length(Is, N) ),
            L).

% La red tiene un nodo negacion_conj con los dos nodos alfa.
test(red, [true(T == negacion_conj([2, 3]))]) :-
    red_conj(bloques, red(_, _, Betas, _)),
    get_assoc(2, Betas, beta(T, _, _, _, _)).

test(pasos_conj, [true(Ps == [alfa(p(X), []), no_todos([q(X), r(X)]),
                              no(s(X))])]) :-
    pasos_conj([p(X), no_todos([q(X), r(X)]), no(s(X))], Ps).

test(paso_conj, [true(P == alfa(p(a), []))]) :-
    paso_conj(p(a), P).

test(bloqueos, [true(N == 2)]) :-
    red_conj(bloques, Red),
    cargar(Red, [bloque(a), sobre(c, a), color(c, rojo), sobre(d, a),
                 color(d, rojo), sobre(e, a)], _, rete(Alfas, _, _)),
    Red = red(_, _, Betas, _),
    get_assoc(2, Betas, beta(negacion_conj(As), _, Prefijo, _, _)),
    bloqueos(As, Alfas, Prefijo, [alfa(bloque(a), [])], N).

test(combinacion, [true(L == [c, d])]) :-
    red_conj(bloques, Red),
    cargar(Red, [sobre(c, a), color(c, rojo), sobre(d, a), color(d, rojo),
                 sobre(e, a)], _, rete(Alfas, _, _)),
    findall(Y, combinacion([sobre(Y, a), color(Y, rojo)], [2, 3], Alfas), L0),
    msort(L0, L).

test(recontar_conj, [true(C-Cs == ([1]-([alfa(bloque(a), [])]-1))-
                                   [menos-([1]-[alfa(bloque(a), [])])])]) :-
    red_conj(bloques, Red),
    cargar(Red, [sobre(c, a), color(c, rojo)], _, rete(Alfas, _, _)),
    Red = red(_, _, Betas, _),
    get_assoc(2, Betas, beta(negacion_conj(As), _, Prefijo, _, _)),
    recontar_conj(As, Alfas, Prefijo, [1]-([alfa(bloque(a), [])]-0), C,
                  [], Cs).

% Sin hechos que lo bloqueen, el token pasa a la salida del nodo.
test(llega_conj, [true(S-B == [1]-bloque(b))]) :-
    red_conj(bloques, Red),
    Red = red(_, _, Betas, _),
    get_assoc(2, Betas, beta(negacion_conj(As), _, Prefijo, _, _)),
    rete_vacio(Red, R0),
    llega_conj(As, [1]-[alfa(bloque(b), [])], 2, Prefijo, Red, R0, R),
    tokens(2, R, [S-[alfa(B, []), no_todos(_)]]).

test(alfa_de_patron, [true(A == 2)]) :-
    red_conj(bloques, Red),
    alfa_de_patron(sobre(_, _), A, Red, _).

test(sucesor_de, [true(S == [5, 2])]) :-
    red_conj(bloques, red(_, Alfas0, _, _)),
    sucesor_de(5, 2, Alfas0, Alfas),
    get_assoc(2, Alfas, a(_, S)).

test(desde_cero_orden,
     [true(Is == [instanciacion(libre, [2], 2, [agregar(libre_de_rojo(b))]),
                  instanciacion(libre, [1], 2,
                                [agregar(libre_de_rojo(a))])])]) :-
    memoria_con([bloque(a), bloque(b)], M),
    desde_cero(bloques, M, Is).

test(cumple_conj, [fail]) :-
    memoria_con([sobre(c, a), color(c, rojo)], M),
    cumple_conj([no_todos([sobre(_, a), color(_, rojo)])], M, _).

test(todos, [nondet]) :-
    memoria_con([sobre(c, a), color(c, rojo)], M),
    todos([sobre(Y, a), color(Y, rojo)], M),
    \+ todos([sobre(_, b)], M).

% El ciclo de la red se ejecuta con la negación conjuntiva.
test(ciclo, [true(H == [libre_de_rojo(b), sobre(c, a), color(c, rojo),
                        bloque(b), bloque(a)])]) :-
    red_conj(bloques, Red),
    ejecutar_red(Red, orden, sin_traza,
                 [bloque(a), bloque(b), color(c, rojo), sobre(c, a)], _, M,
                 nada_aplicable),
    hechos(M, H).

:- end_tests(conjuntiva).
