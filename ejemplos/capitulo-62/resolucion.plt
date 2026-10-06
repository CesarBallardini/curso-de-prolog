:- encoding(utf8).

:- use_module(clausal).
:- ensure_loaded(verificador).

:- begin_tests(resolucion).

test(modus_ponens, [true(Pasos == [r(1, 2, [+q]), r(3, 4, [])])]) :-
    demostrar("(p → q) ∧ p → q", 5, prueba(_, Pasos)).

% La refutación más corta de la fórmula de Bratko tiene tres pasos.
test(bratko, [true(N == 3)]) :-
    demostrar("(a → b) ∧ (b → c) → (a → c)", 5, prueba(_, Pasos)),
    length(Pasos, N).

test(peirce, [true(N == 1)]) :-
    demostrar("((p → q) → p) → p", 5, prueba(_, Pasos)),
    length(Pasos, N).

% Un razonamiento por casos: la cláusula p ∨ q no es de Horn.
test(casos, [true(N == 3)]) :-
    demostrar("(p ∨ q) ∧ (p → r) ∧ (q → r) → r", 5, prueba(_, Pasos)),
    length(Pasos, N).

test(no_teorema, [fail]) :-
    demostrar("(p → q) → (q → p)", 10, _).

% Con un máximo menor que la refutación más corta, no hay refutación.
test(maximo, [fail]) :-
    demostrar("(a → b) ∧ (b → c) → (a → c)", 2, _).

% Cada prueba que el demostrador encuentra pasa el verificador.
test(verificadas, [forall(member(T, ["(p → q) ∧ p → q",
                                     "(a → b) ∧ (b → c) → (a → c)",
                                     "((p → q) → p) → p",
                                     "(p ∨ q) ∧ (p → r) ∧ (q → r) → r",
                                     "p ∨ ¬p",
                                     "(p ↔ q) ↔ (q ↔ p)"]))]) :-
    demostrar(T, 8, Prueba),
    verificar(Prueba).

test(resolventes, [true(Rs == [[+q, +r]])]) :-
    findall(R, resolvente([+p, +q], [-p, +r], R), Rs).

test(sin_tautologias, [fail]) :-
    resolvente([+p, +q], [-p, -q], _).

test(texto, [true(T == "q ∨ ¬p")]) :-
    clausula_texto([+q, -p], T).

test(texto_vacia, [true(T == "□")]) :-
    clausula_texto([], T).

test(texto_variables, [true(T == "¬hombre(A) ∨ mortal(A)")]) :-
    clausula_texto([-hombre(X), +mortal(X)], T).

% El conjunto de cuatro cláusulas de Hein se refuta en tres pasos.
test(refutar_hein, [true(P == [r(1, 2, [+q]), r(3, 4, [-q]), r(5, 6, [])])]) :-
    refutar([[-p, +q], [+p, +q], [-q, +p], [-p, -q]], 5, P).

test(refutar_vacia, [true(P == [])]) :-
    refutar([[]], 2, P).

test(refutar_satisfacible, [fail]) :-
    refutar([[+p], [+q]], 3, _).

% derivar/2 enumera todas las derivaciones de la longitud pedida.
test(derivar, all(P == [ [r(1, 2, [+q]), r(3, 4, [])],
                         [r(1, 3, [+p]), r(2, 4, [])]
                       ])) :-
    length(P, 2),
    resolucion:derivar(P, [[+p, +q], [-p], [-q]]).

test(derivar_uno, all(P == [[r(1, 2, [])]])) :-
    length(P, 1),
    resolucion:derivar(P, [[+p], [-p]]).

:- end_tests(resolucion).
