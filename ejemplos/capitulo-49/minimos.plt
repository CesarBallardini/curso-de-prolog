:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(fallas).

:- begin_tests(minimos).

test(por_filtro, [true(N == 14)]) :-
    por_filtro(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds),
    length(Ds, N).

% Con un presupuesto igual a la cantidad de compuertas, el resultado es el
% del filtro.
test(presupuesto_total, [true(Ds1 == Ds2)]) :-
    por_filtro(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds1),
    minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 5, Ds2).

test(presupuesto_dos, [true(Ds1 == Ds2)]) :-
    por_filtro(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds1),
    minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds2).

% Los más simples son las fallas dobles de la versión 1.
test(mas_simples, [true(Ds == Fs)]) :-
    mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds),
    findall(F, k_fallas(sumador, [[1, 1, 1]-[0, 0]], 2, F), Fs0),
    sort(Fs0, Fs).

test(sin_fallas, [true(Ds == [[]])]) :-
    mas_simples(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 1]], Ds).

test(sumador3, [true(Ds == [[[s1, m2, x1]-invertida],
                            [[s1, m2, x1]-pegada(1)]])]) :-
    mas_simples(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], Ds).

test(minimos_sumador3, [true(N == 26)]) :-
    minimos(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], 2, Ds),
    length(Ds, N).

test(rutas, [true(Rs == [[m1, y1], [o1]])]) :-
    rutas([[o1]-invertida, [m1, y1]-pegada(0)], Rs).

% Un diagnóstico con más compuertas que otro no es mínimo; uno con las
% mismas compuertas y otros estados no lo excluye.
test(minimo_superconjunto, [fail]) :-
    minimos:minimo([[[a]-x], [[a]-x, [b]-y]], [[a]-x, [b]-y]).

test(minimo_mismas_rutas, [true]) :-
    minimos:minimo([[[a]-x], [[a]-y]], [[a]-y]).

test(minimo_ok_no_cuenta, [true]) :-
    minimos:minimo([[[b]-y]], [[a]-x]).

test(en_falla, [true(N == 1)]) :-
    minimos:en_falla([[a]-ok, [b]-pegada(1)|_], N).

test(en_falla_vacio, [true(N == 0)]) :-
    minimos:en_falla(_, N).

test(acotada_cero, [fail]) :-
    acotada(fuerte, 0, _, [g], and, [1, 1], 0).

test(acotada_uno, all(S == [[[g]-pegada(0)], [[g]-invertida]])) :-
    acotada(fuerte, 1, S, [g], and, [1, 1], 0),
    cerrar(S).

test(diagnostico_k, all(D == [[[m1, x1]-pegada(1)], [[m1, x1]-invertida]])) :-
    diagnostico_k(fuerte, sumador, [[0, 0, 1]-[0, 1]], 1, D).

test(observar_k_cero, [fail]) :-
    minimos:observar_k(fuerte, 0, sumador, _, [0, 0, 1]-[0, 1]).

test(sin_explicacion, [fail]) :-
    mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], _).

:- end_tests(minimos).
