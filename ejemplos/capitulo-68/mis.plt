:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(mis).

raiz(n((append(X, Y, Z) :- []), [lista(X), lista(Y), lista(Z)])).

% La raíz de append/3 tiene 9 refinamientos: 3 uniones de dos variables y
% 6 reemplazos de una variable por [] o por [_|_]; ningún literal, porque
% append/3 usaría las tres variables.
test(refinar_tipado_raiz, [true(N == 9)]) :-
    raiz(R),
    aggregate_all(count, refinar_tipado(concatenar, R, _), N).

test(refinar_tipado_no_liga, [true(R =@= R0)]) :-
    raiz(R),
    copy_term(R, R0),
    forall(refinar_tipado(concatenar, R, _), true).

test(refinar_tipado_literal, [nondet]) :-
    N0 = n((append([X|Xs], Y, [X|Zs]) :- []),
           [elemento(X), lista(Xs), lista(Y), lista(Zs)]),
    refinar_tipado(concatenar, N0, n(C, _)),
    C =@= (append([A|As], B, [A|Cs]) :- [append(As, B, Cs)]).

% Un elemento no se reemplaza por una lista.
test(refinar_tipado_tipos, [true(Cs =@= [(num(A, A) :- [])])]) :-
    findall(C, refinar_tipado(numerales,
                              n((num(X, Y) :- []), [elemento(X), elemento(Y)]),
                              n(C, _)),
            Cs).

test(elegir_variables, all(X-Y == [a-b, b-a])) :-
    mis:elegir_variables([lista(X), lista(Y)], [lista(a), lista(b),
                                                 elemento(c)]).

test(buscar_tipada_raiz, [true(C-N =@= (append(_, _, _) :- [])-0)]) :-
    buscar_tipada(concatenar, append([], [c], [c]), [], 4, C, N).

test(buscar_tipada_base, [true(C =@= (append([], A, A) :- []))]) :-
    buscar_tipada(concatenar, append([], [c], [c]),
                  [neg(append([], [a, b], [b, a])),
                   neg(append([a, b], [c], [c]))], 4, C, _).

test(buscar_tipada_sin_resultado, [fail]) :-
    buscar_tipada(concatenar, append([], [c], [c]),
                  [neg(append([], [c], [c]))], 2, _, _).

test(probar_arbol_fondo, [nondet, true(T == fondo(num(1, uno)))]) :-
    probar_arbol(10, numerales, [], num(1, uno), T).

test(probar_arbol_regla, [nondet, true(R-H =@= (append([], A, A) :- [])-[])]) :-
    probar_arbol(10, concatenar,
                 [(append([], X, X) :- []),
                  (append([Y|Ys], Z, [Y|Ws]) :- [append(Ys, Z, Ws)])],
                 append([a], [b], [a, b]),
                 regla(_, _, [regla(_, R, H)])).

test(probar_arbol_limite, [fail]) :-
    probar_arbol(1, concatenar,
                 [(append([], X, X) :- []),
                  (append([Y|Ys], Z, [Y|Ws]) :- [append(Ys, Z, Ws)])],
                 append([a], [b], [a, b]), _).

test(clausula_falsa, [true(F =@= (append(_, A, A) :- []))]) :-
    H = [(append(_, Q, Q) :- [])],
    once(probar_arbol(10, concatenar, H, append([a, b], [c], [c]), T)),
    clausula_falsa(T, [], F).

% Si la cabeza es un positivo visto, la cláusula no se acusa.
test(clausula_falsa_ok, [true(F == ok)]) :-
    H = [(append(_, Q, Q) :- [])],
    once(probar_arbol(10, concatenar, H, append([], [c], [c]), T)),
    clausula_falsa(T, [pos(append([], [c], [c]))], F).

test(clausula_falsa_fondo, [true(F == ok)]) :-
    clausula_falsa(fondo(num(1, uno)), [], F).

test(concatenar, [true(H =@= [(append([A|B], C, [A|D]) :- [append(B, C, D)]),
                               (append([], E, E) :- [])])]) :-
    aprender_mis(concatenar, H, _).

test(concatenar_traza, [true(Ts == [agregada, quitada, agregada, quitada,
                                    agregada, agregada])]) :-
    aprender_mis(concatenar, _, T),
    maplist(functor_de, T, Ts).

functor_de(T, F) :-
    functor(T, F, _).

test(numerales, [true(H =@= [(listnum([A|B], [C|D]) :- [listnum(B, D),
                                                        num(C, A)]),
                              (listnum([E|F], [G|I]) :- [listnum(F, I),
                                                        num(E, G)]),
                              (listnum([], _) :- [])])]) :-
    aprender_mis(numerales, H, _).

test(mis_vacia, [true(H-T == []-[])]) :-
    mis(concatenar, [], H, T).

% Un negativo sin hipótesis no cambia nada.
test(mis_negativo, [true(H-T == []-[])]) :-
    mis(concatenar, [neg(append([], [a], []))], H, T).

test(mostrar_mis, [true(Ls == ["agregada: append(_, _, _).",
                               "quitada: append(_, _, _).",
                               "agregada: append(_, A, A).",
                               "quitada: append(_, A, A).",
                               "agregada: append([], A, A).",
                               "agregada: append([A|B], C, [A|D]) :-",
                               "    append(B, C, D).",
                               "Hipótesis:",
                               "append([A|B], C, [A|D]) :-",
                               "    append(B, C, D).",
                               "append([], A, A).", ""])]) :-
    with_output_to(string(S), mostrar_mis(concatenar)),
    split_string(S, "\n", "", Ls).

:- end_tests(mis).
