:- encoding(utf8).

:- begin_tests(refutadores).

test(tweety, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], vuela(tweety), R).

% El refutador socava la regla de las aves, y no concluye lo contrario.
test(ave_enferma, [true(R == sin_conclusion)]) :-
    respuesta([especificidad], vuela(coco), R).

% Superman no es un ave: el refutador de las aves enfermas no lo alcanza.
test(superman, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], vuela(superman), R).

test(opus, [true(R == presumiblemente_no)]) :-
    respuesta([especificidad], vuela(opus), R).

% La regla de los pingüinos queda socavada, pero sigue derrotando a la de
% las aves.
test(folio, [true(R == sin_conclusion)]) :-
    respuesta([especificidad], vuela(folio), R).

test(mundo_cerrado, [true(R-S == definitivamente_si-presumiblemente_no)]) :-
    respuesta([especificidad], anillada(tweety), R),
    respuesta([especificidad], anillada(opus), S).

test(auto_sano, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], arranca(auto1), R).

test(auto_observado, [true(R-S == definitivamente_no-presumiblemente_si)]) :-
    respuesta([especificidad], arranca(auto2), R),
    respuesta([especificidad], bien(auto2, bateria), S).

test(sin_criterio, [true(R == sin_conclusion)]) :-
    respuesta([], vuela(opus), R).

% La regla de los pingüinos, socavada, sigue derrotando a la de las aves:
% no la anticipa ninguna regla superior.
test(folio_con_anticipacion, [true(R == sin_conclusion)]) :-
    respuesta([anticipacion, especificidad], vuela(folio), R).

:- end_tests(refutadores).
