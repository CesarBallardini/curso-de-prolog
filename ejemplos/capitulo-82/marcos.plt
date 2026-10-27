:- encoding(utf8).

:- begin_tests(marcos).

test(propio_guardado, [true(Vs == [transporte])]) :-
    findall(V, propio(vehiculo, uso, V), Vs).

test(propio_inverso, [true(Ps == [bateria, arranque])]) :-
    findall(P, propio(sistema_electrico, tiene_parte, P), Ps).

test(propio_edad, [true(Es == [11])]) :-
    findall(E, propio(rabbit_de_juan, edad, E), Es).

test(uso_heredado, [true(Us == [transporte])]) :-
    findall(U, tiene_valor(rabbit_de_juan_hoy, uso, U), Us).

test(edad_por_parte_de, [true(Es == [11])]) :-
    findall(E, tiene_valor(bateria_de_juan_hoy, edad, E), Es).

test(marca_por_parte_de, [true(Ms == [vw])]) :-
    findall(M, tiene_valor(bateria_de_juan, marca, M), Ms).

test(varios_valores_propios, [true(Ps == [bateria, arranque])]) :-
    findall(P, tiene_valor(sistema_electrico, tiene_parte, P), Ps).

test(sin_valor_termina, [true(Vs == [])]) :-
    findall(V, tiene_valor(auto, parte_de, V), Vs).

test(edad_sin_fabricado, [true(Vs == [])]) :-
    findall(V, tiene_valor(auto, edad, V), Vs).

test(propio_reemplaza, [true(Vs == [juan])]) :-
    findall(V, tiene_valor(rabbit_de_juan, propietario, V), Vs).

test(tiene_ranura, [nondet]) :-
    tiene_ranura(rabbit_de_juan_hoy, nombre).

test(ranuras, [true(Rs == [concesionarios, edad, es_un, extension, fabricado,
                           marca, modelo, nombre, peso, propietario,
                           propulsion, uso])]) :-
    ranuras(rabbit_de_juan, Rs).

test(ranuras_sin_marco, [true(Rs == [])]) :-
    ranuras(nada, Rs).

test(unidades, [true(U == anios)]) :-
    tiene_unidades(rabbit_de_juan_hoy, edad, U).

test(unidades_peso, [true(U == kilogramos)]) :-
    tiene_unidades(auto, peso, U).

test(sin_unidades, [fail]) :-
    tiene_unidades(auto, marca, _).

test(dentro_de_lo_posible, [fail]) :-
    fuera_de_lo_posible(rabbit_de_juan, _, _).

test(fuera_de_lo_posible, [all(R-V == [marca-fiat])]) :-
    fuera_de_lo_posible(auto_de_ana, R, V).

test(es_un_de, [true(Cs == [rabbit_de_juan, vw_rabbit, auto, vehiculo,
                            objeto_fisico])]) :-
    findall(C, es_un_de(rabbit_de_juan, C), Cs).

:- end_tests(marcos).
