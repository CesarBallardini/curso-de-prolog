:- encoding(utf8).

:- use_module(semantica38).

:- begin_tests(estratos).

test(dependencias, [true(As == [p/0-q/0-pos, p/0-r/0-neg, q/0-p/0-pos])]) :-
    dependencias([(p :- q, \+ r), (q :- p), (r :- s), (s :- true)], As).

% r/0 no depende de ningún predicado con reglas: s/0 es un hecho.
test(componentes, [true(Cs == [[r/0], [p/0, q/0]])]) :-
    componentes([(p :- q, \+ r), (q :- p), (r :- s), (s :- true)], Cs).

test(componentes_grafo, [true(Cs == [[camino/2], [inalcanzable/2]])]) :-
    clausulas(grafo, Ps),
    componentes(Ps, Cs).

test(ciclos_negativos, [true(Ps == [gana/2-gana/2])]) :-
    clausulas(juego, Cs),
    ciclos_negativos(Cs, Ps).

test(ciclos_como_capitulo38,
     [true(Ps == [avestruz/0-vuela/0, pinguino/0-vuela/0,
                  vuela/0-avestruz/0, vuela/0-pinguino/0])]) :-
    clausulas(base(vuela), Cs),
    ciclos_negativos(Cs, Ps).

test(estratificado, [true(Ps == [])]) :-
    clausulas(grafo, Cs),
    ciclos_negativos(Cs, Ps).

test(evaluar, [true(M-C == [p, r, s]-costo(3, 2))]) :-
    evaluar([(s :- true), (r :- s), (p :- \+ q), (q :- \+ r)], M, C).

% El mismo modelo que modelo_estandar_de/2 del capítulo 38.
test(como_capitulo38, [forall(member(P, [lluvia, caminos, grafo,
                                         base(original),
                                         base(puede_volar)]))]) :-
    clausulas(P, Cs),
    evaluar(Cs, M, _),
    modelo_estandar_de(Cs, M38),
    M == M38.

test(grafo, [true(C == costo(5, 20))]) :-
    clausulas(grafo, Cs),
    evaluar(Cs, _, C).

test(evaluar_base, [true(As == [q(a)])]) :-
    evaluar_base([(p(a) :- true), (q(X) :- p(X))], B, _),
    findall(q(X), motor:en_base(q(X), B), As).

test(no_estratificado,
     [error(domain_error(programa_estratificado, [r/0-r/0]))]) :-
    evaluar([(r :- \+ r)], _, _).

test(no_seguro,
     [error(domain_error(datalog_seguro, negacion_libre(\+ q(_))))]) :-
    evaluar([(p(X) :- \+ q(X), r(X))], _, _).

:- end_tests(estratos).
