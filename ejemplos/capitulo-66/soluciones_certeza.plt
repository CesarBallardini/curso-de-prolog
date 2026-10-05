:- encoding(utf8).

:- begin_tests(soluciones_certeza).

% Las rayas de grado 0,3 no llegan al umbral de c1.
test(atardecer, [true(F-T == 0.476-(-0.3699))]) :-
    atardecer(Os),
    factor_con_umbrales(guepardo, Os, 0.2, F),
    factor_con_umbrales(tigre, Os, 0.2, T).

% Con rayas de grado 0,5, c1 se aplica y el resultado es el de factor/4.
test(rayas_fuertes, [true(F == G)]) :-
    Os = [tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
          manchas_oscuras-0.6, rayas_negras-0.5],
    factor_con_umbrales(guepardo, Os, 0.2, F),
    factor(guepardo, Os, 0.2, G).

% Con poca evidencia de carne, la premisa de r7 vale 0,4 y no llega a su
% umbral de 0,5; las rayas de 0,5 sí llegan al de c1.
test(umbral_r7, [true(L == [-0.45])]) :-
    Os = [tiene_pelo-0.9, come_carne-0.5, color_leonado-0.8,
          manchas_oscuras-0.6, rayas_negras-0.5],
    findall(A, aporte_con_umbral(guepardo, Os, 0.2, A), L0),
    maplist([X, Y]>>(Y is round(X * 10000) / 10000.0), L0, L).

test(umbral_de, [true(A-B == 0.5-0.2)]) :-
    umbral_de(r7, 0.2, A),
    umbral_de(r1, 0.2, B).

:- end_tests(soluciones_certeza).
