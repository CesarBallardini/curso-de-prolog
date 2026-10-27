:- encoding(utf8).

:- use_module(lector).
:- use_module(clausal).

:- begin_tests(primer_orden).

test(socrates, [true(Cs =@= [[+mortal(X), -hombre(X)], [+hombre(socrates)],
                             [-mortal(socrates)]])]) :-
    clausulas_fo_texto("¬(∀x (hombre(x) → mortal(x)) ∧ hombre(socrates)
                         → mortal(socrates))", Cs).

% La variable existencial que sigue a una universal pasa a ser una función
% de ella.
test(bebedor, [true(Cs =@= [[+bebe(X)], [-bebe(sk1(X))]])]) :-
    clausulas_fo_texto("¬∃x (bebe(x) → ∀y bebe(y))", Cs).

% Sin universales antes, es una constante.
test(barbero, [true(Cs =@= [[-afeita(Y, Y), -afeita(sk1, Y)],
                            [+afeita(Z, Z), +afeita(sk1, Z)]])]) :-
    clausulas_fo_texto("∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", Cs).

test(prenexa, [true(P-M =@= [todo(X), existe(Y)]-at(ama(X, Y)))]) :-
    leer_formula("∀x ∃y ama(x, y)", F),
    prenexa(F, P, M).

test(skolem, [true(M =@= at(r(X, sk1(X), Z, sk2(X, Z))))]) :-
    leer_formula("∀x ∃y ∀z ∃w r(x, y, z, w)", F),
    prenexa(F, P, M),
    skolemizar(P, 1, N),
    assertion(N == 3).

% ↔ duplica su subfórmula; sin renombrar, dos cuantificadores ligarían la
% misma variable.
test(sin_renombrar, [true(X == Y)]) :-
    leer_formula("(∀x p(x)) ↔ q", F),
    fnn(F, y(o(existe(X, _), _), o(todo(Y, _), _))).

test(renombrar, [true(X \== Y)]) :-
    leer_formula("(∀x p(x)) ↔ q", F),
    fnn(F, G),
    renombrar(G, y(o(existe(X, _), _), o(todo(Y, _), _))).

% Sin cuantificadores, coincide con la forma clausal de la versión 2.
test(proposicional, [true(Cs1 == Cs2)]) :-
    leer_formula("¬((a → b) ∧ (b → c) → (a → c))", F),
    clausulas_fo(F, Cs0),
    msort(Cs0, Cs1),
    clausulas(F, Cs2).

:- end_tests(primer_orden).
