:- encoding(utf8).

:- begin_tests(estrategias).

test(clave_lex, K == lex([7, 5, 3], 3)) :-
    clave_estrategia(lex, instanciacion(r, [3, 7, 5], 3, []), K).

test(clave_mea, K == mea(3, [7, 5, 3], 3)) :-
    clave_estrategia(mea, instanciacion(r, [3, 7, 5], 3, []), K).

test(mea_sin_patrones, K == mea(0, [], 0)) :-
    clave_estrategia(mea, instanciacion(r, [], 0, []), K).

% Recencia primero; con los mismos sellos, gana la lista más larga.
test(lex_recencia, N == b) :-
    preferida(lex, [instanciacion(a, [9, 1], 2, []),
                    instanciacion(b, [10], 1, [])], instanciacion(N, _, _, _)).

test(lex_mas_patrones, N == b) :-
    preferida(lex, [instanciacion(a, [9], 1, []),
                    instanciacion(b, [9, 4], 2, [])],
              instanciacion(N, _, _, _)).

test(lex_mas_condiciones, N == b) :-
    preferida(lex, [instanciacion(a, [9], 1, []),
                    instanciacion(b, [9], 2, [])],
              instanciacion(N, _, _, _)).

test(lex_empate, N == a) :-
    preferida(lex, [instanciacion(a, [9], 1, []),
                    instanciacion(b, [9], 1, [])],
              instanciacion(N, _, _, _)).

test(mea_primer_patron, N == a) :-
    preferida(mea, [instanciacion(a, [5, 2], 2, []),
                    instanciacion(b, [3, 9], 2, [])],
              instanciacion(N, _, _, _)).

test(claves, [L, M] == [[apilar-lex([5, 3], 4), apilar-lex([6, 4], 4)],
                        [apilar-mea(5, [5, 3], 4), apilar-mea(4, [6, 4], 4)]]) :-
    H = [sobre(a, piso), sobre(b, piso), sobre(d, piso),
         meta(apilar([b, c])), meta(apilar([a, d])), sobre(c, piso)],
    claves(lex, cajas, H, L),
    claves(mea, cajas, H, M).

% Con dos metas, LEX termina primero la más antigua y MEA la más reciente.
test(dos_metas, [Lex, Mea] == [[sobre(d, a), sobre(c, b)],
                               [sobre(c, b), sobre(d, a)]]) :-
    H = [sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso),
         meta(apilar([b, c])), meta(apilar([a, d]))],
    encadenar(cajas, lex, H, M1, nada_aplicable),
    encadenar(cajas, mea, H, M2, nada_aplicable),
    include(apilada, M1, Lex),
    include(apilada, M2, Mea).

test(ciclos, [O, L, M] == [4, 6, 6]) :-
    H = [sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso),
         meta(apilar([b, c])), meta(apilar([a, d]))],
    cantidad_de_ciclos(cajas, orden, H, O),
    cantidad_de_ciclos(cajas, lex, H, L),
    cantidad_de_ciclos(cajas, mea, H, M).

test(torre, M == [sobre(d, c), sobre(c, b), sobre(b, a), sobre(a, piso)]) :-
    encadenar(cajas, mea, [sobre(a, piso), sobre(b, piso), sobre(c, b),
                           sobre(d, c), meta(apilar([a, b, c, d]))], M,
              nada_aplicable).

%!  apilada(+Hecho) is semidet.
%
%   Hecho es sobre(Caja, X) con X distinto de piso.
apilada(sobre(_, X)) :-
    X \== piso.

:- end_tests(estrategias).
