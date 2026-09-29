:- encoding(utf8).

:- begin_tests(marcos).

test(es_un, all(C == [procesador, componente, refrigerado])) :-
    es_un(procesador, C).

test(es_de_clase, true) :-
    es_de_clase(placa_de_video, componente).

test(no_es_de_clase, [fail]) :-
    es_de_clase(placa_de_video, refrigerado).

% El valor propio, el de la clase y el de la clase de la que hereda.
test(valores, [A, B, C] == [120, 65, 0]) :-
    valor_ranura(procesador, [consumo-120], consumo, A),
    valor_ranura(procesador, [], consumo, B),
    valor_ranura(fuente, [], consumo, C).

% Herencia múltiple: la ranura viene del segundo padre.
test(segundo_padre, V == si) :-
    valor_ranura(procesador, [], necesita_disipador, V).

test(sin_valor, [fail]) :-
    valor_ranura(placa, [], necesita_disipador, _).

test(consultar, [Z, P] == [am5, 0]) :-
    consultar(placa, [zocalo-am5], [zocalo-Z, precio-P]).

test(fijar, R == [consumo-70, precio-10]) :-
    fijar_ranura([consumo-65, precio-10], consumo, 70, R).

% El segundo es/3 del mismo objeto no agrega otro patrón.
test(traduccion, true(R =@= (r :: [objeto(_, C, Rs),
                                   {es_de_clase(C, placa),
                                    consultar(C, Rs, [zocalo-Z])},
                                   {es_de_clase(C, componente),
                                    consultar(C, Rs, [precio-P])}]
                              ---> [agregar(p(Z, P))]))) :-
    con_marcos([r :: [es(O, placa, [zocalo-Z1]),
                      es(O, componente, [precio-P1])]
                     ---> [agregar(p(Z1, P1))]], [R]).

test(poner, H == [objeto(p, procesador, [consumo-70])]) :-
    con_marcos([r :: [es(O, procesador, [])] ---> [poner(O, consumo, 70)]],
               [R]),
    memoria_con([objeto(p, procesador, [])], M0),
    conjunto_conflicto([R], M0, [instanciacion(_, _, _, Acciones)]),
    aplicar_acciones(Acciones, M0, M, seguir),
    hechos(M, H).

test(disipadores, all(C == [cpu_b])) :-
    encadenar(disipadores, lex,
              [objeto(cpu_a, procesador, [necesita_disipador-no]),
               objeto(cpu_b, procesador, []),
               objeto(gpu_a, placa_de_video, [])], M, nada_aplicable),
    member(requiere_disipador(C), M).

:- end_tests(marcos).
