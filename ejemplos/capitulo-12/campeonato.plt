:- encoding(utf8).

:- begin_tests(campeonato).

test(victoriosos) :-
    jugadores_victoriosos(Js),
    assertion(Js == ["Karacic", "Estrada", "Mendy"]).

test(messi_perdio_uno, [fail]) :-
    victorioso("Messi").

test(los_victoriosos_uno_por_uno, all(J == ["Karacic", "Estrada", "Mendy"])) :-
    victorioso(J).

test(partidos_ordenados) :-
    partidos_jugados(Ps),
    assertion(Ps == [[1, qatar, ecuador], [8, argentina, arabia],
                     [18, qatar, senegal], [21, tunez, australia],
                     [35, ecuador, senegal], [39, polonia, argentina],
                     [50, argentina, australia], [61, argentina, croacia]]).

test(argentina_gano_el_61, [nondet]) :-
    gano(argentina, 61).

test(argentina_no_gano_el_8, [fail]) :-
    gano(argentina, 8).

:- end_tests(campeonato).
