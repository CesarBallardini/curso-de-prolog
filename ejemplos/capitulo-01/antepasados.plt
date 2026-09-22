:- encoding(utf8).

:- begin_tests(antepasados).

test(tare_es_antepasado_de_isaac, [nondet]) :-
    antepasado(tare, isaac).

test(sara_es_antepasada_de_isaac, [nondet]) :-
    antepasado(sara, isaac).

% Primero los hijos, después los nietos: el orden resulta de evaluar las dos
% cláusulas de antepasado/2 en el orden en que están escritas.
test(descendientes_de_tare,
     all(D == [abraham, nacor, haran, isaac, lot, milca, isca])) :-
    antepasado(tare, D).

test(isaac_no_tiene_descendientes, [fail]) :-
    antepasado(isaac, _).

test(nadie_es_antepasado_de_tare, [fail]) :-
    antepasado(_, tare).

test(nadie_es_antepasado_de_si_mismo, [fail]) :-
    antepasado(haran, haran).

:- end_tests(antepasados).
