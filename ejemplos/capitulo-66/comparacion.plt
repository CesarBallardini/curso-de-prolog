:- encoding(utf8).

:- begin_tests(comparacion).

test(dracula_indefinido, [true(V-W == indefinido-indefinido)]) :-
    valor(vuela_tabulada(dracula), V),
    valor(no_vuela_tabulada(dracula), W).

test(bien_fundada, [true(R == resultado([], [pinguino]))]) :-
    diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).

test(rebatible, [true(Rs == [presumiblemente_si, presumiblemente_no,
                             presumiblemente_no])]) :-
    findall(R,
            ( member(M, [pinguino, avestruz, vuela]),
              respuesta([especificidad], M, R) ),
            Rs).

test(ave, [true(R == definitivamente_si)]) :-
    respuesta([especificidad], ave, R).

:- end_tests(comparacion).
