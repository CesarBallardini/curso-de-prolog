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

% ejecutar/6, instrucción por instrucción. La variable 0 de la cláusula
% es la celda 10.
test(ejecutar_primera, [true(L == [10-a])]) :-
    empty_assoc(A0),
    compilado:ejecutar(p(a), 10, 0, primera(1, 0), A0-[], A-_),
    assoc_to_list(A, L).

test(ejecutar_constante_liga, [true(L-R == [3-b]-[3])]) :-
    empty_assoc(A0),
    compilado:ejecutar(p('$v'(3)), 10, 5, constante(1, b), A0-[], A-R),
    assoc_to_list(A, L).

test(ejecutar_constante_distinta, [fail]) :-
    empty_assoc(A0),
    compilado:ejecutar(p(a), 10, 0, constante(1, b), A0-[], _).

test(ejecutar_otra, [true]) :-
    list_to_assoc([10-a], A0),
    compilado:ejecutar(p(a), 10, 0, otra(1, 0), A0-[], _).

test(ejecutar_otra_distinta, [fail]) :-
    list_to_assoc([10-a], A0),
    compilado:ejecutar(p(b), 10, 0, otra(1, 0), A0-[], _).

% Con una celda libre, estructura/4 construye el esqueleto renombrado;
% con un término compuesto, lo verifica y sigue con las instrucciones hijas.
test(ejecutar_construye, [true(L == [3-f('$v'(10))])]) :-
    empty_assoc(A0),
    compilado:ejecutar(p('$v'(3)), 10, 0,
                       estructura(1, f/1, [primera(1, 0)], f('$v'(0))),
                       A0-[], A-_),
    assoc_to_list(A, L).

test(ejecutar_verifica, [true(L == [10-c])]) :-
    empty_assoc(A0),
    compilado:ejecutar(p(f(c)), 10, 0,
                       estructura(1, f/1, [primera(1, 0)], f('$v'(0))),
                       A0-[], A-_),
    assoc_to_list(A, L).

test(ejecutar_otro_functor, [fail]) :-
    empty_assoc(A0),
    compilado:ejecutar(p(g(c)), 10, 0,
                       estructura(1, f/1, [primera(1, 0)], f('$v'(0))),
                       A0-[], _).

:- end_tests(compilado).
