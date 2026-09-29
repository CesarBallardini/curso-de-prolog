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

:- end_tests(llamadas).
