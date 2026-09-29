:- encoding(utf8).

:- begin_tests(soluciones_pato).

test(pato, [true(R-S == definitivamente_no-definitivamente_si)]) :-
    respuesta([especificidad], pinguino(pato), R),
    respuesta([especificidad], vuela(pato), S).

% pinguino(pingu) pide que vuela(pingu) no se derive, y vuela(pingu) pide
% que pinguino(pingu) no se derive.
test(pingu_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(respuesta([especificidad], pinguino(pingu), _),
                              200000, R).

:- end_tests(soluciones_pato).
