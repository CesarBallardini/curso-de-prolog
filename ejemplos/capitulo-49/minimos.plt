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

:- end_tests(minimos).
