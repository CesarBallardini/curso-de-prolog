:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(cotas).

test(intervalo, [true(I-S == 0.55-1.0)]) :-
    intervalo(mamifero, [tiene_pelo-0.6, da_leche-0.6], I, S).

test(estimaciones, [true(E == [guepardo-e(0.0, 0.1851, 0.6),
                               tigre-e(0.0, 0.098, 0.3)])]) :-
    estimaciones([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
                  manchas_oscuras-0.6, rayas_negras-0.3], E).

% La estimación independiente queda siempre entre las dos cotas.
test(entre_cotas, [forall(( member(G, [0.3, 0.6, 0.9]),
                            member(Meta, [mamifero, carnivoro, ungulado,
                                          guepardo, tigre, jirafa, cebra]) ))]) :-
    findall(O-G, ( observable(O), ground(O) ), Os),
    intervalo(Meta, Os, I, S),
    grado(Meta, Os, independiente, P),
    I =< P,
    P =< S.

% Con observaciones seguras, la hipótesis probada domina a las demás.
test(domina, [true(Hs == [guepardo, tigre, jirafa, pinguino, avestruz])]) :-
    caso(2, Os),
    seguras(Os, Gs),
    findall(H, domina(Gs, cebra, H), Hs).

% Con observaciones inciertas, ninguna domina: los intervalos se cruzan.
test(no_domina, [fail]) :-
    domina([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
            manchas_oscuras-0.6, rayas_negras-0.3], _, _).

:- end_tests(cotas).
