:- encoding(utf8).

:- begin_tests(lector).

test(precedencia, [true(F == si(y(no(at(p)), at(q)), o(at(r), at(s))))]) :-
    leer_formula("¬p ∧ q → r ∨ s", F).

% Los símbolos ASCII dan el mismo término que los de la lógica.
test(ascii, [true(F1 == F2)]) :-
    leer_formula("~p & q -> r | s <-> t", F1),
    leer_formula("¬p ∧ q → r ∨ s ↔ t", F2).

test(implicacion_derecha, [true(F == si(at(p), si(at(q), at(r))))]) :-
    leer_formula("p → q → r", F).

test(conjuncion_izquierda, [true(F == y(y(at(p), at(q)), at(r)))]) :-
    leer_formula("p ∧ q ∧ r", F).

% El cuantificador alcanza solo a la fórmula que lo sigue.
test(alcance, [true(F =@= si(todo(X, at(p(X))), at(q(x))))]) :-
    leer_formula("∀x p(x) → q(x)", F).

test(variables, [true(F =@= todo(X, existe(Y, at(ama(X, f(Y, c))))))]) :-
    leer_formula("todo x existe y ama(x, f(y, c))", F).

% Dos cuantificadores sobre el mismo nombre ligan variables distintas.
test(sombra, [true(X \== Y)]) :-
    leer_formula("∀x (p(x) ∧ ∃x q(x))", todo(X, y(_, existe(Y, _)))).

test(error_incompleta, [error(syntax_error(formula(_)))]) :-
    leer_formula("p ∧", _).

test(error_sii, [error(syntax_error(formula(_)))]) :-
    leer_formula("p ↔ q ↔ r", _).

test(escritura, [true(T == "(p → q) ∧ ¬(r ∨ s) → t")]) :-
    leer_formula("((p -> q) & ~(r | s)) -> t", F),
    formula_texto(F, T).

test(escritura_variables,
     [true(T == "∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))")]) :-
    leer_formula("existe b todo p (afeita(b, p) <-> ~afeita(p, p))", F),
    formula_texto(F, T).

% Leer lo escrito da una variante de la fórmula original.
test(ida_y_vuelta, [forall(member(T, ["p ∧ (q ∧ r)", "(p → q) → r",
                                      "(p ↔ q) ↔ r", "¬∀x ∃y p(x, y)",
                                      "p ∨ q ∧ r → ¬s"])),
                    true(F2 =@= F1)]) :-
    leer_formula(T, F1),
    formula_texto(F1, T1),
    leer_formula(T1, F2).

:- end_tests(lector).
