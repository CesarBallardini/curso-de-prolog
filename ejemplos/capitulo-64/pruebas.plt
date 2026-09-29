:- encoding(utf8).

:- begin_tests(pruebas).

% La conjunción se separa, y las dos pruebas solo miran el hecho de q/2.
test(agrupar) :-
    pasos_con_pruebas([p(X), q(X, Y), {Y > 2, X \== Y}], P),
    P == [alfa(p(X), []), alfa(q(X, Y), [Y > 2, X \== Y])].

% Minimo viene de una condición anterior y no aparece en objeto/3: la
% prueba se queda en la red beta.
test(no_se_mueve) :-
    pasos_con_pruebas([pedido(M), objeto(N, C), {C >= M}], P),
    P == [alfa(pedido(M), []), alfa(objeto(N, C), []), {C >= M}].

test(tamano, [A, B, C] == [29, 43, 58]) :-
    red_con_pruebas(configurador, Red),
    medidas_red(Red, A, B, C).

test(iguales, forall(( member(E, [orden, lex, mea]),
                       member(K, [0, 100]) ))) :-
    pedido_ampliado(K, H),
    iguales_con_pruebas(configurador, E, H).

test(familia) :-
    familia(H),
    iguales_con_pruebas(familia, mea, H).

test(cajas) :-
    iguales_con_pruebas(cajas, lex, [meta(apilar([a, b, c])),
                                     sobre(a, piso), sobre(b, piso),
                                     sobre(c, a)]).

test(tokens, T == 8) :-
    red_con_pruebas(configurador, Red),
    pedido_ampliado(400, H),
    tokens_guardados(Red, H, T).

% Solo los ciclos 6 y 8, los que empiezan y terminan la fase de la
% memoria, cuestan más con 400 memorias agregadas; los demás cuestan lo
% mismo, inferencia por inferencia.
test(ciclos, Distintos == [6, 8]) :-
    red_con_pruebas(configurador, Red),
    pedido_ampliado(0, H0),
    pedido_ampliado(400, H),
    perfil_red(Red, mea, H0, F0),
    perfil_red(Red, mea, H, F),
    findall(N, ( member(ciclo(N, I0), F0), member(ciclo(N, I), F),
                 I =\= I0 ), Distintos).

:- end_tests(pruebas).
