:- encoding(utf8).

:- begin_tests(maquina).

test(abuelo, all(N == [luis])) :-
    resolver(indice, familia, abuelo(juan, N)).

test(versiones, [ forall(member(V, [ resolvente, alternativas, almacen,
                                      corte, indice
                                    ]))
                ]) :-
    igual_que_prolog(V, listas, concatenar(_, _, [a, b])).

test(archivo, all(D == [abraham, nacor, haran, isaac, lot, milca, isca])) :-
    ejecutar_archivo(ejemplos('capitulo-06/antepasados'),
                     antepasado(tare, D)).

test(recorrer, [true(N == 3)]) :-
    ejecutar_archivo(ejemplos('capitulo-07/recorrer'), largo([a, b, c], N)).

test(tabla, [true(sub_string(S, _, _, _, "indice   listas"))]) :-
    with_output_to(string(S),
                   tabla_de_medidas([indice-listas-suma_hasta(10, _)])).

:- end_tests(maquina).
