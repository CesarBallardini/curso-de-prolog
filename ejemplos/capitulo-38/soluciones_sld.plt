:- encoding(utf8).

:- begin_tests(soluciones_sld).

test(refutacion_c, [true(Rs =@= [[conexion(a, c)],
                                 [conexion(a, Z), enlace(Z, c)],
                                 [enlace(a, W), enlace(W, c)],
                                 [enlace(b, c)],
                                 []])]) :-
    once(refutacion(izquierda, enlaces, [conexion(a, c)], 4, Rs)).

test(refutaciones_x, [true(Xs == [b, c])]) :-
    findall(X, refutacion(izquierda, enlaces, [conexion(a, X)], 4, _), Xs).

test(abuelo_de_luis, [true(A1-A2 == arbol([[abuelo(juan, luis)]], 6, 2, 0)-
                                    arbol([[abuelo(juan, luis)]], 4, 0, 0))]) :-
    arbol_sld(izquierda, familia, [abuelo(_, luis)], 5, A1),
    arbol_sld(derecha, familia, [abuelo(_, luis)], 5, A2).

test(complecion_gana,
     [true(F =@= sii(gana(J, X), existe([Y], (mueve(J, X, Y), \+ gana(J, Y)))))]) :-
    complecion(juego(j2), gana/2, F).

test(complecion_mueve,
     [true(F =@= sii(mueve(J, X, Y), ( J = j2, X = a, Y = b
                                     ; J = j2, X = b, Y = a
                                     ; J = j2, X = b, Y = c
                                     ; J = j2, X = c, Y = d )))]) :-
    complecion(juego(j2), mueve/3, F).

test(refutacion_de_lista, [nondet, true(Rs == [[p], [q], []])]) :-
    refutacion_de(izquierda, [(p :- q), (q :- true)], [p], 2, Rs).

test(complecion_r, [true(F == sii(r, \+ r))]) :-
    complecion_de([(r :- \+ r)], r/0, F).

test(mostrar, [true(S == "sii(padre(A,B),(A=juan,B=ana;A=juan,B=pedro;A=pedro,B=luis))\nsii(abuelo(A,B),existe([C],(padre(A,C),padre(C,B))))\n")]) :-
    with_output_to(string(S), mostrar_complecion(familia)).

:- end_tests(soluciones_sld).
