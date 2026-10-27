:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(fallas).
:- use_module(modelos).

:- begin_tests(incremental).

test(diagnostico, [true]) :-
    es_diagnostico(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1]]).

test(no_diagnostico, [fail]) :-
    es_diagnostico(sumador, [[0, 0, 1]-[0, 1]], [[o1]]).

% Una observación correcta tiene el diagnóstico vacío.
test(vacio, [true]) :-
    es_diagnostico(sumador, [[0, 0, 1]-[1, 0]], []).

test(estado_de, [true(Ps == [[a]-desconocida, [b]-ok])]) :-
    maplist(incremental:estado_de([[a]]), [[a], [b]], Ps).

test(reducir, [true(D == [[m2, x1], [o1]])]) :-
    reducir(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1], [m2, x1], [o1]], D).

test(reducir_minimo, [true(D == [[m1, x1]])]) :-
    reducir(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1]], D).

test(probar_sacar, [true(D == [[m1, x1]])]) :-
    incremental:probar_sacar(sumador, [[0, 0, 1]-[0, 1]], [o1],
                             [[m1, x1], [o1]], D).

test(probar_no_sacar, [true(D == [[m1, x1]])]) :-
    incremental:probar_sacar(sumador, [[0, 0, 1]-[0, 1]], [m1, x1],
                             [[m1, x1]], D).

test(primero, [true(D == [[m2, x1], [o1]])]) :-
    siguiente_minimo(sumador, [[0, 0, 1]-[0, 1]], [], D).

test(segundo, [true(D == [[m1, x1]])]) :-
    siguiente_minimo(sumador, [[0, 0, 1]-[0, 1]], [[[m2, x1], [o1]]], D).

test(sin_mas, [fail]) :-
    siguiente_minimo(sumador, [[0, 0, 1]-[0, 1]],
                     [[[m1, x1]], [[m1, y1], [m2, x1]], [[m2, x1], [m2, y1]],
                      [[m2, x1], [o1]]], _).

% Dejar fuera [m2, x1] junto con [m1, x1] ya no deja un diagnóstico; [o1] sí.
test(excluir, [nondet, true(F == [[m1, x1], [o1]])]) :-
    findall(R, compuerta_en(sumador, R, _), Todas0),
    sort(Todas0, Todas),
    incremental:excluir([[[m1, x1]], [[m2, x1], [o1]]], sumador,
                        [[0, 0, 1]-[0, 1]], Todas, [], F).

test(minimos, [true(Ds == [[[m2, x1], [o1]], [[m1, x1]],
                           [[m2, x1], [m2, y1]], [[m1, y1], [m2, x1]]])]) :-
    minimos_incrementales(sumador, [[0, 0, 1]-[0, 1]], Ds).

test(minimos_correcta, [true(Ds == [[]])]) :-
    minimos_incrementales(sumador, [[0, 0, 1]-[1, 0]], Ds).

% Los mismos conjuntos que el filtro del modelo débil, sin presupuesto.
test(como_filtro, [forall(member(O, [[[0, 0, 1]-[0, 1]],
                                    [[1, 1, 1]-[0, 0]],
                                    [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]]])),
                   true(Ds == Rs)]) :-
    minimos_incrementales(sumador, O, Ds0),
    msort(Ds0, Ds),
    sospechosas(debil, sumador, O, 5, Rs).

test(sumador3, [true(Ds == Rs)]) :-
    O = [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]],
    minimos_incrementales(sumador3, O, Ds0),
    msort(Ds0, Ds),
    sospechosas(debil, sumador3, O, 3, Rs).

:- end_tests(incremental).
