:- encoding(utf8).

:- use_module(lector).
:- use_module(primer_orden).
:- ensure_loaded(verificador).

:- begin_tests(resolucion_fo).

test(socrates, [true(N == 2)]) :-
    demostrar_fo("∀x (hombre(x) → mortal(x)) ∧ hombre(socrates)
                  → mortal(socrates)", 5, prueba(_, Pasos)),
    length(Pasos, N).

test(bebedor, [true(Pasos =@= [r(1, 2, [])])]) :-
    demostrar_fo("∃x (bebe(x) → ∀y bebe(y))", 5, prueba(_, Pasos)).

% El barbero necesita dos factorizaciones: sin ellas, cada resolvente
% tiene dos literales.
test(barbero, [true(Tipos == [f, r, r])]) :-
    demostrar_fo("¬∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", 5,
                 prueba(_, Pasos)),
    maplist([P, T]>>functor(P, T, _), Pasos, Tipos).

test(barbero_sin_factor, [fail]) :-
    clausulas_fo_texto("¬¬∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", Cs),
    refutar_con(opciones(general, repetida, unify_with_occurs_check, no),
                Cs, 5, _).

% ∀x ∃y ama(x, y) no implica ∃y ∀x ama(x, y): con la comprobación de
% ocurrencia no hay refutación; sin ella, la unificación produce un
% término cíclico y una «refutación» que el verificador rechaza.
test(sin_ocurrencia, [fail]) :-
    demostrar_fo("(∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y)", 5, _).

test(ocurrencia_falsa, [true(Pasos = [r(1, 2, [])])]) :-
    clausulas_fo_texto("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", Cs),
    refutar_con(opciones(lineal, repetida, =, si), Cs, 5, Pasos),
    \+ verificar(prueba(Cs, Pasos)).

% La refutación general y la lineal: la lineal puede ser más larga.
test(lineal_mas_larga, [true(NG-NL == 3-4)]) :-
    clausulas_fo_texto("¬(∀x (p(x) ∨ q(x)) ∧ ∀x (p(x) ∨ ¬q(x))
                        ∧ ∀x (¬p(x) ∨ q(x)) → ∀x (p(x) ∧ q(x)))", Cs),
    refutar_con(opciones(general, repetida, unify_with_occurs_check, si),
                Cs, 6, PG),
    refutar_con(opciones(lineal, repetida, unify_with_occurs_check, si),
                Cs, 6, PL),
    length(PG, NG),
    length(PL, NL).

% Cada prueba, con cada combinación de opciones, pasa el verificador.
test(verificadas, [forall(( teorema(T),
                            member(E, [general, lineal]),
                            member(Fi, [repetida, subsumida])
                          ))]) :-
    leer_formula(T, F),
    clausulas_fo(no(F), Cs),
    refutar_con(opciones(E, Fi, unify_with_occurs_check, si), Cs, 6, Pasos),
    verificar(prueba(Cs, Pasos)).

% teorema(T): T escribe un teorema con una refutación corta.
teorema("∀x (hombre(x) → mortal(x)) ∧ hombre(socrates) → mortal(socrates)").
teorema("∃x (bebe(x) → ∀y bebe(y))").
teorema("¬∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))").
teorema("∃x ∀y ∀z ((p(y) → q(z)) → (p(x) → q(x)))").
teorema("(∃x p(x) → ∀x q(x)) → ∀x (p(x) → q(x))").
teorema("∀x (p(x) ∨ q(x)) ∧ ∀x (p(x) → r(x)) ∧ ∀x (q(x) → r(x))
         → ∀x r(x)").

test(subsume) :-
    subsume([+p(X, Y)], [+p(a, b), +q]),
    var(X), var(Y).

test(subsume_no, [fail]) :-
    subsume([+p(X, X)], [+p(a, b)]).

% Una cláusula no subsume a sus propios factores.
test(subsume_factor, [fail]) :-
    subsume([-p(X, X), -p(a, X)], [-p(a, a)]).

test(factor, [true(Fs =@= [[+p(a)], [+p(a)]])]) :-
    findall(F, factor(unify_with_occurs_check, [+p(_), +p(a)], F), Fs).

test(resolvente, [true(Rs =@= [[+q(a, _)]])]) :-
    findall(R, resolvente_fo(unify_with_occurs_check, [+p(a, _)],
                             [-p(X, Y), +q(X, Y)], R), Rs).

test(refutar_fo, [true(P == [r(1, 2, [+q]), r(3, 4, [])])]) :-
    refutar_fo([[+p(_)], [-p(a), +q], [-q]], 5, P).

test(refutar_fo_satisfacible, [fail]) :-
    refutar_fo([[+p(a)], [-p(b)]], 4, _).

% derivar/4 con la estrategia lineal: desde el segundo paso, cada uno usa
% la cláusula que agregó el anterior.
test(derivar_lineal, all(P == [ [r(1, 2, [+q]), r(3, 4, [])],
                                [r(1, 3, [+p(a)]), r(2, 4, [])]
                              ])) :-
    length(P, 2),
    resolucion_fo:derivar(opciones(lineal, repetida,
                                   unify_with_occurs_check, si),
                          P, [[+p(a), +q], [-p(a)], [-q]], ninguna).

% Con cuatro pasos sin factorización, la estrategia general admite 50
% derivaciones y la lineal 4; la primera de abajo no es lineal.
test(derivar_general, [true(Ng-Nl == 50-4)]) :-
    Cs = [[+p, +q], [-p, +r], [-q, +r], [-r]],
    aggregate_all(count,
                  ( length(P, 4),
                    resolucion_fo:derivar(opciones(general, repetida,
                                                   unify_with_occurs_check,
                                                   no),
                                          P, Cs, ninguna)
                  ),
                  Ng),
    aggregate_all(count,
                  ( length(P, 4),
                    resolucion_fo:derivar(opciones(lineal, repetida,
                                                   unify_with_occurs_check,
                                                   no),
                                          P, Cs, ninguna)
                  ),
                  Nl).

test(derivar_no_lineal, [fail]) :-
    resolucion_fo:derivar(opciones(lineal, repetida,
                                   unify_with_occurs_check, no),
                          [r(1, 2, [+q, +r]), r(1, 3, [+p, +r]),
                           r(3, 5, [+r]), r(4, 7, [])],
                          [[+p, +q], [-p, +r], [-q, +r], [-r]], ninguna).

test(centro_lineal, all(J == [4])) :-
    resolucion_fo:centro(lineal, 4, J).

test(centro_primero, [true(var(J))]) :-
    resolucion_fo:centro(lineal, ninguna, J).

test(centro_general, [true(var(J))]) :-
    resolucion_fo:centro(general, 4, J).

% opuestos/3 usa la unificación que recibe, y no deja alternativas
% pendientes con ninguno de los dos signos.
test(opuestos_sin_ocurrencia) :-
    resolucion_fo:opuestos(+p(X), -p(f(X)), =).

test(opuestos_con_ocurrencia, [fail]) :-
    resolucion_fo:opuestos(+p(X), -p(f(X)), unify_with_occurs_check).

test(opuestos_positivo, [true(B == a)]) :-
    resolucion_fo:opuestos(+p(a), -p(B), unify_with_occurs_check).

test(opuestos_negativo, [true(B == a)]) :-
    resolucion_fo:opuestos(-p(a), +p(B), unify_with_occurs_check).

:- end_tests(resolucion_fo).
