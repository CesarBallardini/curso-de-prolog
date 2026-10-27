:- encoding(utf8).

:- begin_tests(soluciones_experto).

test(preguntables, true(Ps == [color_leonado, come_carne, cuello_largo,
                               da_leche, manchas_oscuras, nada, no_vuela,
                               pone_huevos, rayas_negras, tiene_cascos,
                               tiene_pelo, tiene_plumas, vuela])) :-
    preguntables(Ps).

% Ninguna conclusión es preguntable.
test(sin_conclusiones, [true]) :-
    preguntables(Ps),
    forall(regla(_, si _ entonces C), \+ memberchk(C, Ps)).

test(atomos, true(As == [a, b])) :-
    atomos(f(b, g(a, 1), [a]), As).

:- end_tests(soluciones_experto).
