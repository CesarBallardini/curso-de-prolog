:- encoding(utf8).

:- begin_tests(facetas).

% Sin precio propio, el de la memoria se calcula; el cálculo de memoria
% oculta el valor por omisión de componente.
test(calculado, [true(P == 48)]) :-
    valor_con_facetas(memoria, [gb-16], precio, P).

test(propio, [true(P == 40)]) :-
    valor_con_facetas(memoria, [gb-16, precio-40], precio, P).

test(por_omision, [true(P == 0)]) :-
    valor_con_facetas(placa, [], precio, P).

test(sin_valor, [fail]) :-
    valor_con_facetas(placa, [], color, _).

test(faceta_calculo, [true(P == 24)]) :-
    faceta(memoria, [gb-8], precio, P).

test(faceta_omision, [true(C == 5)]) :-
    faceta(memoria, [gb-8], consumo, C).

test(consultar_facetas, [true(G-P == 8-24)]) :-
    consultar_facetas(memoria, [gb-8], [gb-G, precio-P]).

test(consultar_faceta, [true(P == 24)]) :-
    consultar_faceta(memoria, [gb-8], precio-P).

% El demonio de gb quita el precio propio.
test(demonio_gb, [true(R == [gb-32])]) :-
    poner_con_demonios(memoria, [gb-16, precio-40], gb, 32, R).

% El demonio de precio, heredado de componente, rechaza un negativo.
test(demonio_precio, [error(domain_error(precio_no_negativo, -3))]) :-
    poner_con_demonios(placa, [], precio, -3, _).

test(sin_demonio, [true(R == [consumo-10])]) :-
    poner_con_demonios(placa, [], consumo, 10, R).

test(condicion_con_facetas,
     [true(C == {es_de_clase(a, b), consultar_facetas(a, [], [])})]) :-
    condicion_con_facetas({es_de_clase(a, b), consultar(a, [], [])}, C).

test(acciones_con_facetas,
     [true(As == [{poner_con_demonios(c, r0, gb, 4, r1)},
                  reemplazar(objeto(o, c, r0), objeto(o, c, r1))])]) :-
    acciones_con_facetas([{fijar_ranura(r0, gb, 4, r1)},
                          reemplazar(objeto(o, c, r0), objeto(o, c, r1))],
                         As).

test(con_facetas, [true(N == 2)]) :-
    programa(ampliar_memoria, Rs),
    length(Rs, N).

test(regla_con_facetas, [true(Cs == [p])]) :-
    regla_con_facetas(r :: [p] ---> [q], r :: Cs ---> _).

% Las dos memorias pasan a 32 GB; la de precio propio pierde ese precio.
test(ampliar, [true(Ps == [precio(mem_a, 32, 96), precio(mem_b, 32, 96)])]) :-
    encadenar(ampliar_memoria, orden,
              [objeto(mem_a, memoria, [gb-8]),
               objeto(mem_b, memoria, [gb-16, precio-40]),
               pedido_memoria(32)], M, nada_aplicable),
    findall(precio(O, G, P), member(precio(O, G, P), M), Ps0),
    msort(Ps0, Ps).

:- end_tests(facetas).
