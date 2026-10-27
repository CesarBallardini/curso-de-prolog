:- encoding(utf8).

:- begin_tests(aerolinea).

% IB752 tiene dos tramos completos el 12/2: una sola respuesta.
test(vuelos_completos, all(T-D == ['IB752'-fecha(2023, 2, 12),
                                   'AR1132'-fecha(2023, 1, 15),
                                   'AR1132'-fecha(2023, 2, 20)])) :-
    vuelo_completo(T, D).

test(ib750_con_lugar, [fail]) :-
    vuelo_completo('IB750', fecha(2023, 1, 10)).

% Los tramos 1 y 3 empatan con 312: una sola respuesta.
test(minimo_con_empate, all(N == [312])) :-
    asientos_disponibles('IB750', fecha(2023, 1, 10), N).

test(minimo_cero, all(N == [0])) :-
    asientos_disponibles('IB752', fecha(2023, 2, 12), N).

test(no_es_el_minimo, [fail]) :-
    asientos_disponibles('IB750', fecha(2023, 1, 10), 350).

test(rutas, all(D-H == ['Bruselas'-'BsAs', 'Madrid'-'BsAs'])) :-
    ruta(D, H).

test(mas_popular, all(D-H == ['Madrid'-'BsAs'])) :-
    tramo_mas_popular(D, H).

test(bruselas_no, [fail]) :-
    tramo_mas_popular('Bruselas', 'BsAs').

test(fuera_del_periodo, [fail]) :-
    en_periodo(fecha(2023, 3, 3)).

test(ultimo_dia_del_periodo) :-
    en_periodo(fecha(2023, 2, 28)).

% Con el día primero, el orden estándar no sería el cronológico.
test(orden_de_las_fechas) :-
    fecha(2023, 1, 20) @< fecha(2023, 2, 3).

test(km_ib750, all(N == [12672])) :-
    cantidad_km('IB750', N).

test(km_de_todos, all(T-N == ['IB750'-12672, 'IB752'-11312,
                              'AR1132'-10040])) :-
    cantidad_km(T, N).

test(km_de_vuelo_ajeno, [fail]) :-
    cantidad_km('XX000', _).

:- end_tests(aerolinea).
