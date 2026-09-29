:- encoding(utf8).

:- begin_tests(proyecto).

% Las dos mitades del proyecto responden sobre el mismo caso.
test(las_dos_mitades, [true(H-P == avestruz-0.9)]) :-
    caso(3, Os),
    identificar_compilado(Os, H),
    seguras(Os, Gs),
    grado(H, Gs, independiente, P).

:- end_tests(proyecto).
