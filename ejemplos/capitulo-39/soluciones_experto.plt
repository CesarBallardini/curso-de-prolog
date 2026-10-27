:- encoding(utf8).

:- begin_tests(soluciones_experto).

test(ciclo_no_estratificado, [fail]) :-
    estratos(herbivoros(ciclo), _).

test(ciclo, [true(P == [herbivoro/0-carnivoro/0])]) :-
    ciclos_negativos(herbivoros(ciclo), P).

test(indefinidos, [true(C-H == indefinido-indefinido)]) :-
    valor(con_hechos(herbivoros(ciclo), [tiene_pelo]), carnivoro, C),
    valor(con_hechos(herbivoros(ciclo), [tiene_pelo]), herbivoro, H).

% Si come carne, r5 decide: el ciclo no deja nada indefinido.
test(come_carne, [true(C-H == verdadero-falso)]) :-
    Programa = con_hechos(herbivoros(ciclo), [tiene_pelo, come_carne]),
    valor(Programa, carnivoro, C),
    valor(Programa, herbivoro, H).

test(corregida, [true(S == [1-[avestruz/0, herbivoro/0, pinguino/0],
                            2-[puede_volar/0]])]) :-
    estratos(herbivoros(corregida), [_|S]).

test(corregida_valores, [true(C-H == falso-verdadero)]) :-
    valor(con_hechos(herbivoros(corregida), [tiene_pelo]), carnivoro, C),
    valor(con_hechos(herbivoros(corregida), [tiene_pelo]), herbivoro, H).

% Con la lista: la corrección sin observaciones no concluye herbivoro.
test(corregida_de_lista, [true(H == falso)]) :-
    con_herbivoros(corregida, Cs),
    valor_de(Cs, herbivoro, H).

test(version_desconocida, [error(type_error(_, otra))]) :-
    con_herbivoros(otra, _).

:- end_tests(soluciones_experto).
