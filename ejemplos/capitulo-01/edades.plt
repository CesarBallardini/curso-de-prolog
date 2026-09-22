:- encoding(utf8).

:- begin_tests(edades).

test(sofia_es_bebe, all(E == [bebe])) :-
    etapa(sofia, E).

test(luis_es_chico, all(E == [chico])) :-
    etapa(luis, E).

test(juan_es_adulto, all(E == [adulto])) :-
    etapa(juan, E).

% Cada persona pertenece a una sola etapa: las condiciones son excluyentes.
test(una_sola_etapa, all(P-E == [juan-adulto, ana-adulto, pedro-adulto,
                                 luis-chico, eva-chico, sofia-bebe])) :-
    edad(P, _),
    etapa(P, E).

test(nadie_sin_edad, [fail]) :-
    etapa(rocco, _).

:- end_tests(edades).
