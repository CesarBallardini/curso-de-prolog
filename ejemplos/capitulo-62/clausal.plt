:- encoding(utf8).

:- use_module(lector).

:- begin_tests(clausal).

test(modus_ponens, [true(Cs == [[+p], [+q, -p], [-q]])]) :-
    clausulas_texto("¬((p → q) ∧ p → q)", Cs).

test(bratko, [true(Cs == [[+a], [+b, -a], [+c, -b], [-c]])]) :-
    clausulas_texto("¬((a → b) ∧ (b → c) → (a → c))", Cs).

test(no_sii, [true(Cs == [[+p, +q], [-p, -q]])]) :-
    clausulas_texto("¬(p ↔ q)", Cs).

% Una tautología no deja ninguna cláusula; una contradicción deja dos
% cláusulas unitarias opuestas.
test(tautologia, [true(Cs == [])]) :-
    clausulas_texto("p ∨ ¬p", Cs).

test(contradiccion, [true(Cs == [[+p], [-p]])]) :-
    clausulas_texto("p ∧ ¬p", Cs).

% La negación queda solo delante de las fórmulas atómicas.
test(fnn, [true(G == y(o(at(p), at(q)), no(at(r))))]) :-
    leer_formula("¬(¬(p ∨ q) ∨ r)", F),
    fnn(F, G).

% Bajo una negación, cada cuantificador cambia por su dual.
test(fnn_cuantificadores, [true(G =@= existe(X, todo(Y, no(at(p(X, Y))))))]) :-
    leer_formula("¬∀x ∃y p(x, y)", F),
    fnn(F, G).

% La distribución multiplica las cláusulas: 2^n para n conjunciones.
test(crecimiento, [true(N == 16)]) :-
    clausulas_texto("a1 ∧ b1 ∨ a2 ∧ b2 ∨ a3 ∧ b3 ∨ a4 ∧ b4", Cs),
    length(Cs, N).

test(cuantificador, [error(type_error(formula_sin_cuantificadores, _))]) :-
    clausulas_texto("∀x p(x)", _).

test(tautologica) :-
    tautologica([+p, +q, -p]).

test(no_tautologica, [fail]) :-
    tautologica([+p, -q]).

:- end_tests(clausal).
