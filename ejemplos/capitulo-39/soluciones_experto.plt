:- encoding(utf8).

:- begin_tests(soluciones_experto).

test(guepardo, [true(A == deducido(guepardo, r7,
                                   deducido(carnivoro, r5,
                                            deducido(mamifero, r1,
                                                     observado(tiene_pelo))
                                            y observado(come_carne))
                                   y observado(color_leonado)
                                   y observado(manchas_oscuras)))]) :-
    como_tabulado(original,
                  [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
                  guepardo, A).

test(avestruz, [true(A == deducido(avestruz, r12,
                                   deducido(ave, r3, observado(tiene_plumas))
                                   y no vuela
                                   y observado(peso(90))
                                   y 90 > 50))]) :-
    como_tabulado(original, [tiene_plumas, peso(90)], avestruz, A).

% Con el ciclo de r4 y r13, las pruebas de ave son finitas: la que usa r3,
% y la que usa r4 con vuela deducido por r13 sin volver a usar ave no
% existe, porque r13 necesita ave.
test(ciclo, [true(As == [deducido(ave, r3, observado(tiene_plumas))])]) :-
    findall(A,
            arbol(vuela, [tiene_plumas, pone_huevos, peso(2)], ave, [], A),
            As).

% Una conclusión indefinida no tiene prueba.
test(indefinida, [fail]) :-
    como_tabulado(vuela, [tiene_plumas, nada, peso(30)], pinguino, _).

test(falsa, [fail]) :-
    como_tabulado(original, [tiene_pelo], guepardo, _).

:- end_tests(soluciones_experto).
