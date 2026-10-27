:- encoding(utf8).

:- begin_tests(llamadas).

test(mostrar, [true(Qs == [notas/2, promedio/2, mediana/2, format/2])]) :-
    llamadas(notas, mostrar/1, Qs).

% Un hecho no llama a nada.
test(hecho, [true(Qs == [])]) :-
    llamadas(notas, notas/2, Qs).

% La consulta inversa: quién llama a promedio/2.
test(quien_llama, [true(Ps == [mejor/1, mostrar/1, varianza/2])]) :-
    findall(P, llama(notas, P, promedio/2), Ps0),
    sort(Ps0, Ps).

% mejor/1 se llama solo dentro de forall/2, y desvio2/3 solo dentro de
% maplist/3: sin las metallamadas, esos arcos no aparecen.
test(metallamadas, [nondet]) :-
    clausulas(notas, Cs),
    llama_de(Cs, informe/0, mejor/1),
    llama_de(Cs, varianza/2, desvio2/3).

% La negación también se atraviesa: promedo/2 está dentro de \+.
test(negacion, [nondet]) :-
    llama(notas, mejor/1, promedo/2).

test(control, [true(Ps == [a/0, b/0, c/0, d/0, findall/3, e/1])]) :-
    metas((a, (b -> c ; \+ d), findall(X, e(X), _)), Ms),
    maplist(indicador, Ms, Ps).

% maplist/3 agrega dos argumentos a su clausura; call/3, dos.
test(clausuras, [true(Ps == [maplist/3, f/3, call/3, h/2])]) :-
    metas((maplist(f(1), _, _), call(h, 1, 2)), Ms),
    maplist(indicador, Ms, Ps).

% Las variables cuantificadas con ^ se quitan antes de buscar la meta.
test(cuantificadas, [true(Ps == [bagof/3, g/2])]) :-
    metas(bagof(Y, Z^g(Y, Z), _), Ms),
    maplist(indicador, Ms, Ps).

% Una metallamada con la meta en una variable no agrega nada.
test(meta_libre, [true(Ms == [call(G)])]) :-
    metas(call(G), Ms).

test(arcos, [true(N == 38)]) :-
    clausulas(notas, Cs),
    arcos(Cs, Arcos),
    length(Arcos, N).

test(definidos, [true(N == 12)]) :-
    clausulas(notas, Cs),
    definidos(Cs, Ps),
    length(Ps, N).

test(extra, [true(L == [call-0-0, call-2-2, maplist-1-1, maplist-3-3,
                        foldl-3-3, include-2-1])]) :-
    findall(N-K-E, ( member(N, [call, maplist, foldl, include]),
                     member(K, [0, 1, 2, 3]),
                     extra(N, K, E),
                     ( N == call -> K mod 2 =:= 0 ; true ),
                     ( N == maplist -> K mod 2 =:= 1 ; true ) ),
            L).

% En sentido inverso: las metallamadas que agregan un argumento a una meta
% con dos argumentos después del primero.
test(extra_inversa, all(N == [include, exclude])) :-
    extra(N, 2, 1).

test(extra_foldl_corto, [fail]) :-
    extra(foldl, 2, _).

% true no es una meta; la negación y la disyunción se atraviesan, y la meta
% de findall/3 sigue a la metallamada.
test(metas_de, [true(Ps == [p/1, findall/3, q/1])]) :-
    phrase(metas_de((true, p(_) ; \+ findall(Y, q(Y), _))), Ms),
    maplist(indicador, Ms, Ps).

% Con P libre, una respuesta por predicado definido; un hecho no llama.
test(llamadas_de, all(P-Qs == [p/0-[q/0, r/0], q/0-[r/0], r/0-[]])) :-
    llamadas_de([(p :- q, r), (q :- r), r], P, Qs).

% Una llamada repetida aparece una sola vez.
test(llamadas_de_repetida, [true(Qs == [q/0])]) :-
    llamadas_de([(p :- q, q), (p :- q)], p/0, Qs).

test(llamadas_de_no_definido, [fail]) :-
    llamadas_de([(p :- q)], q/0, _).

test(meta_argumento_forall, all(G-E == [a-0, b-0])) :-
    meta_argumento(forall(a, b), G, E).

test(meta_argumento_maplist, all(G-E == [f-2])) :-
    meta_argumento(maplist(f, x, y), G, E).

:- end_tests(llamadas).
