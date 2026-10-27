:- encoding(utf8).

:- begin_tests(soluciones_complecion).

test(modelo_unico, [true(L == [gusta-[alumno_de(pablo, pedro),
                                      gusta(pedro, pablo)],
                               amistoso-ninguno,
                               tautologia-varios(2)])]) :-
    findall(N-M,
            ( member(N, [gusta, amistoso, tautologia]),
              modelo_unico(N, M) ),
            L).

% Un programa sin negaciones: el único modelo de la compleción es el
% modelo mínimo.
test(antepasados, [true(M == Min)]) :-
    completo(antepasados, M),
    modelo_minimo(antepasados, Min).

test(no_completo, [fail]) :-
    completo(amistoso, _).

test(existencial, [true(F =@= sii(antepasado(X, Y),
                                  (progenitor(X, Y) ;
                                   existe([Z], (progenitor(X, Z),
                                                antepasado(Z, Y))))))]) :-
    completar(antepasados, Fs),
    member(F, Fs),
    F = sii(antepasado(_, _), _).

:- end_tests(soluciones_complecion).
