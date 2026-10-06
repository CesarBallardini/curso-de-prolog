:- encoding(utf8).

:- begin_tests(yale).

% Después de la espera y el disparo, Johnnie presumiblemente no está vivo.
test(disparo, [true(R == presumiblemente_no)]) :-
    situacion([espera, disparo], S),
    respuesta([especificidad], vale(vivo, S), R).

test(historia, [true(H == [inicio-definitivamente_si-definitivamente_no,
                           espera-presumiblemente_si-presumiblemente_no,
                           disparo-presumiblemente_no-presumiblemente_si])]) :-
    historia([especificidad], [espera, disparo], H).

% Sin la especificidad, la persistencia y la regla causal se derrotan.
test(sin_especificidad, [true(R == sin_conclusion)]) :-
    situacion([espera, disparo], S),
    respuesta([], vale(vivo, S), R).

% La persistencia lleva la muerte a las situaciones siguientes.
test(despues_del_disparo, [true(R == presumiblemente_si)]) :-
    situacion([disparo, espera], S),
    respuesta([especificidad], vale(muerto, S), R).

% El arma sigue cargada después de la espera.
test(cargada, [true(R == presumiblemente_si)]) :-
    situacion([espera], S),
    respuesta([especificidad], vale(cargada, S), R).

test(situacion, [true(S == result(b, result(a, s0)))]) :-
    situacion([a, b], S).

test(despues, [true(S == result(e, s0))]) :-
    despues(e, s0, S).

:- end_tests(yale).
