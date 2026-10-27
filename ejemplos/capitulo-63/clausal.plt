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

% fnn_no/2 lleva la negación hacia adentro, conectivo por conectivo.
test(fnn_no, [true(Gs == [ no(at(p)),
                           at(p),
                           o(no(at(p)), no(at(q))),
                           y(no(at(p)), at(q)),
                           y(at(p), no(at(q))),
                           o(y(at(p), no(at(q))), y(no(at(p)), at(q)))
                         ])]) :-
    maplist(clausal:fnn_no,
            [ at(p), no(at(p)), y(at(p), at(q)), o(at(p), no(at(q))),
              si(at(p), at(q)), sii(at(p), at(q))
            ],
            Gs).

% Los cuantificadores pasan a sus duales.
test(fnn_no_cuantificador, [true(G =@= existe(X, no(at(p(X)))))]) :-
    clausal:fnn_no(todo(X, at(p(X))), G).

test(fnc_distribuye, [true(Cs == [[+a, +c], [+b, +c]])]) :-
    fnc(o(y(at(a), at(b)), at(c)), Cs).

% La conjunción reúne las cláusulas; una contradicción da dos unitarias.
test(fnc_contradiccion, [true(Cs == [[+p], [-p]])]) :-
    fnc(y(at(p), no(at(p))), Cs).

% Una disyunción tautológica no deja cláusulas.
test(fnc_tautologica, [true(Cs == [])]) :-
    fnc(o(at(p), no(at(p))), Cs).

test(fnc_cuantificador,
     [error(type_error(formula_sin_cuantificadores, _))]) :-
    fnc(todo(X, at(p(X))), _).

:- end_tests(clausal).
