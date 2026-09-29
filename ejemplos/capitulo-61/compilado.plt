:- encoding(utf8).

:- use_module(programas).

:- begin_tests(compilado).

test(suma, [true(S == 6)]) :-
    resolver(listas, suma([1, 2, 3], S)).

test(maximo, all(M == [4])) :-
    resolver(maximo, maximo(4, 3, M)).

test(nativas, [forall(member(N-Q, [ familia-antepasado(_, _),
                                     familia-abuelo(juan, _),
                                     listas-concatenar(_, _, [1, 2, 3]),
                                     listas-concatenar([a], [b], _),
                                     listas-invertir_hasta(6, _),
                                     listas-longitud_hasta(5, _),
                                     corte-primero(_, [x, y]),
                                     corte-suma_hasta(10, _),
                                     maximo-maximo(3, 3, _),
                                     maximo-maximo(3, 4, _)
                                   ])),
               true(Rs =@= Ns)]) :-
    findall(Q, resolver(N, Q), Rs),
    respuestas_nativas(N, Q, Ns).

% Las medidas de la máquina son las de la versión 5.
test(medir, [true(M == M5)]) :-
    medir(listas, suma_hasta(100, _), M),
    indice:medir(listas, suma_hasta(100, _), M5).

test(instrucciones,
     [true(C == '[|]'/2-cc(4, [ estructura(1, '[|]'/2,
                                           [primera(1, 0), primera(2, 1)],
                                           ['$v'(0)|'$v'(1)]),
                               primera(2, 2),
                               estructura(3, '[|]'/2,
                                           [otra(1, 0), primera(2, 3)],
                                           ['$v'(0)|'$v'(3)])
                             ],
                          ['$llamar'(concatenar/3,
                                     concatenar('$v'(1), '$v'(2), '$v'(3)))]))]) :-
    compilar_clausula_v6((concatenar([X|Xs], L, [X|Ys]) :-
                              concatenar(Xs, L, Ys)), C).

% Primera aparición dentro de una estructura construida, y otra después.
test(construida, [true(Rs =@= [f(W)-W])]) :-
    findall(Y-Z,
            almacen:resolver_clausulas(compilado, [(p(f(X), X) :- true)],
                                       p(Y, Z)),
            Rs).

test(indefinido, [error(existence_error(procedure, q/0))]) :-
    almacen:resolver_clausulas(compilado, [(p :- q)], p).

% Una variable repetida en la cabeza, y una estructura construida.
test(repetida, all(Z == [f(a)])) :-
    almacen:resolver_clausulas(compilado, [(p(X, f(X)) :- true)], p(a, Z)).

:- end_tests(compilado).
