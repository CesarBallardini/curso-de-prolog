:- encoding(utf8).

:- begin_tests(capitulo41).

test(a_estrella, [true(C-K == 8-10)]) :-
    buscar(mejor(a_estrella),
           capitulo41:puzzle([2, 4, 3, 7, 1, 5, 0, 8, 6], manhattan), _, C, K).

test(sin_visitados, [true(C == 8)]) :-
    buscar_sin_visitados(mejor(a_estrella),
                         capitulo41:puzzle([2, 4, 3, 7, 1, 5, 0, 8, 6],
                                           manhattan),
                         _, C, _).

test(ida, [true(C == 8)]) :-
    ida_estrella(capitulo41:puzzle([2, 4, 3, 7, 1, 5, 0, 8, 6], manhattan),
                 _, C, _).

test(otro_modulo, [true(P-C == [norte, norte]-2)]) :-
    buscar(anchura, prueba41:linea(2), P, C, _).

:- end_tests(capitulo41).

prueba41:inicial(linea(_), 0).
prueba41:meta(linea(N), N).
prueba41:sucesor(linea(_), X, norte, Y, 1) :-
    Y is X + 1.
prueba41:heuristica(linea(N), X, H) :-
    H is N - X.
