:- encoding(utf8).

:- begin_tests(fichas).

test(hay_tres_fichas, all(F == [ficha(mascota(gato, felix), fecha(2021, 5, 3), ana),
                                ficha(mascota(perro, rocco), fecha(2019, 11, 20), luis),
                                ficha(mascota(gato, gaturro), fecha(2023, 2, 14), eva)])) :-
    registro(F).

test(los_gatos, all(N == [felix, gaturro])) :-
    registro(F),
    especie(F, gato),
    nombre_de(F, N).

test(rocco_nacio_en_2019, all(A == [2019])) :-
    registro(F),
    nombre_de(F, rocco),
    nacio_en(F, A).

test(las_mascotas_de_ana, all(N == [felix])) :-
    registro(F),
    propietario_de(F, ana),
    nombre_de(F, N).

% Extraer un componente es unificar con un término que deja libre el resto.
test(sacar_la_especie_sin_predicado, all(E == [gato])) :-
    ficha(mascota(E, _), _, _) = ficha(mascota(gato, felix), fecha(2021, 5, 3), ana).

test(no_hay_tortugas, [fail]) :-
    registro(F),
    especie(F, tortuga).

:- end_tests(fichas).
