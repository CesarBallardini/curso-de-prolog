:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(generalizaciones).

test(condiciones_de, [true(Cs == [forma=esfera, color=rojo, material=madera])]) :-
    condiciones_de(pieza(esfera, rojo, _, madera), Cs).

test(condiciones_de_libre, [true(Cs == [])]) :-
    condiciones_de(pieza(_, _, _, _), Cs).

test(comunes, [true(Cs == [color=rojo])]) :-
    comunes([forma=esfera, color=rojo], [color=rojo, forma=cubo], Cs).

% Quitar condiciones da lo mismo que la generalización de la versión 2.
test(comunes_igual_lgg, [true]) :-
    forall(( member(I1, [pieza(esfera, rojo, chico, madera),
                         pieza(cubo, verde, grande, metal)]),
             member(I2, [pieza(esfera, azul, chico, metal),
                         pieza(cubo, rojo, grande, madera)]) ),
           ( condiciones_de(I1, Cs1),
             condiciones_de(I2, Cs2),
             comunes(Cs1, Cs2, Cs),
             unidireccional:generalizacion(I1, I2, G),
             condiciones_de(G, Cs) )).

test(esta_en, [true]) :-
    generalizaciones:esta_en([a=1, b=2], b=2).

test(clase, all(V == [esfera, cilindro])) :-
    clase(V, redondeada).

test(subir_igual, [true(G == rojo)]) :-
    subir(rojo, rojo, G).

test(subir_clase, [true(G == redondeada)]) :-
    subir(esfera, cilindro, G).

test(subir_desde_clase, [true(G == frio)]) :-
    subir(frio, azul, G).

test(subir_variable, [true(var(G))]) :-
    subir(esfera, cubo, G).

test(subir_sin_clase, [true(var(G))]) :-
    subir(chico, grande, G).

test(clase_o_valor, [true(K1-K2 == calido-calido)]) :-
    generalizaciones:clase_o_valor(rojo, K1),
    generalizaciones:clase_o_valor(calido, K2).

test(generalizacion_jerarquia, [true(S =@= pieza(redondeada, rojo, _, madera))]) :-
    generalizacion_jerarquia(pieza(esfera, rojo, chico, madera),
                             pieza(cilindro, rojo, grande, madera), S).

test(generalizacion_jerarquia_vacio,
     [true(S == pieza(cubo, azul, chico, metal))]) :-
    generalizacion_jerarquia(vacio, pieza(cubo, azul, chico, metal), S).

test(subir_con, [true(S == pieza(cubo, azul, chico, metal))]) :-
    generalizaciones:subir_con(pieza(cubo, azul, chico, metal), vacio, S).

test(cubre_jerarquia, [true]) :-
    cubre_jerarquia(pieza(redondeada, calido, _, madera),
                    pieza(cilindro, rojo, chico, madera)).

test(cubre_jerarquia_no, [fail]) :-
    cubre_jerarquia(pieza(redondeada, _, _, _), pieza(cubo, rojo, chico, madera)).

test(cubre_jerarquia_vacio, [fail]) :-
    cubre_jerarquia(vacio, pieza(cubo, rojo, chico, madera)).

test(cubre_valor, [nondet]) :-
    generalizaciones:cubre_valor(frio, verde),
    generalizaciones:cubre_valor(_, verde),
    \+ generalizaciones:cubre_valor(calido, verde).

test(especifico_jerarquia, [true(S =@= pieza(redondeada, rojo, _, madera))]) :-
    especifico_jerarquia(redondas_rojas, S).

test(especifico_jerarquia_colapso, [true(S == colapso)]) :-
    especifico_jerarquia(rojo_o_esfera, S).

test(ejemplos_de, [true(N1-N2 == 5-4)]) :-
    ejemplos_de(esfera_roja, E1),
    ejemplos_de(redondas_rojas, E2),
    length(E1, N1),
    length(E2, N2).

test(disyuncion_memoriza, [true(D == [pieza(esfera, verde, chico, madera),
                                      pieza(cubo, rojo, chico, madera)])]) :-
    disyuncion(rojo_o_esfera, D).

test(disyuncion, [true(D =@= [pieza(esfera, _, _, _),
                               pieza(cubo, verde, grande, metal)])]) :-
    disyuncion(esferas_y_cubos_verdes, D).

test(disyuncion_de, [true(D == [pieza(cubo, verde, chico, madera)])]) :-
    disyuncion_de([pos(pieza(cubo, verde, chico, madera))], D).

% Con un concepto conjuntivo, la disyunción tiene un solo disyunto.
test(disyuncion_conjuntiva, [true(D =@= [pieza(esfera, rojo, _, _)])]) :-
    disyuncion(esfera_roja, D).

test(agregar_positivo_nuevo, [true(D == [pieza(cubo, rojo, chico, metal),
                                          pieza(esfera, rojo, chico, metal)])]) :-
    generalizaciones:agregar_positivo([pieza(cilindro, rojo, chico, metal)],
                                pieza(esfera, rojo, chico, metal),
                                [pieza(cubo, rojo, chico, metal)], D).

test(cubre_disyuncion, [true]) :-
    cubre_disyuncion([pieza(esfera, _, _, _), pieza(cubo, verde, _, _)],
                     pieza(cubo, verde, chico, madera)).

test(cubre_disyuncion_no, [fail]) :-
    cubre_disyuncion([pieza(esfera, _, _, _), pieza(cubo, verde, _, _)],
                     pieza(cubo, rojo, chico, madera)).

:- end_tests(generalizaciones).
