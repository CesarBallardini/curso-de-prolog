:- encoding(utf8).

:- begin_tests(soluciones).

test(clasificar, [true(Cs == [tautologia, contradiccion, contingente,
                              tautologia])]) :-
    maplist(clasificar, ["p ∨ ¬p", "p ∧ ¬p", "p → q", "(p → q) ∨ (q → p)"],
            Cs).

% La forma definicional crece en forma lineal: 3n cláusulas contra 2^n.
test(definicional, [forall(between(1, 8, N)),
                    true(D-E =:= (2 ** N)-(3 * N))]) :-
    comparar_def(N, D, E).

test(definicional_refuta) :-
    leer_formula("(p ∧ q) ∨ (p ∧ ¬q) → p", F),
    clausulas_def(no(F), Cs),
    refutar(Cs, 8, _).

% Una fórmula que no es un teorema sigue sin refutación.
test(definicional_no_teorema, [true(R == saturada)]) :-
    leer_formula("(p ∧ q) ∨ (r ∧ s) → p", F),
    clausulas_def(no(F), Cs),
    saturar(Cs, _, R).

test(primer_error_ninguno, [true(K == ninguno)]) :-
    primer_error(prueba([[-p, +q], [+p, +q], [+p, -q], [-p, -q]],
                        [r(1, 2, [+q]), r(3, 4, [-q]), r(5, 6, [])]), K).

test(primer_error, [true(K == 2)]) :-
    primer_error(prueba([[-p, +q], [+p, +q], [+p, -q], [-p, -q]],
                        [r(1, 2, [+q]), r(2, 4, [-q]), r(5, 6, [])]), K).

test(primer_error_incompleta, [true(K == incompleta)]) :-
    primer_error(prueba([[-p, +q], [+p, +q]], [r(1, 2, [+q])]), K).

% Skolemizar en el alcance da términos de un argumento.
test(alcance, [true(Cs =@= [[+ama(X, sk1(X))], [-ama(sk2(Y), Y)]])]) :-
    leer_formula("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", F),
    clausulas_alcance(F, Cs).

test(unitaria_horn, [true(N == 3)]) :-
    clausulas_texto("¬((a → b) ∧ (b → c) → (a → c))", Cs),
    refutar_unitaria(Cs, 5, P),
    length(P, N).

test(unitaria_hein, [fail]) :-
    refutar_unitaria([[-p, +q], [+p, +q], [+p, -q], [-p, -q]], 10, _).

test(decidir_teorema) :-
    decidir("((p → q) → p) → p", teorema(P)),
    verificar(P).

test(decidir_contraejemplo, [true(V == 0)]) :-
    decidir("(p → q) → (q → p)", contraejemplo(A)),
    leer_formula("(p → q) → (q → p)", F),
    valor_en(F, A, V).

test(saturar, [true(N-R == 4-refutada)]) :-
    palomar(2, F),
    clausulas_fo(no(F), Cs),
    saturar(Cs, N, R).

test(saturar_no_teorema, [true(R == saturada)]) :-
    clausulas_texto("¬((p → q) → (q → p))", Cs),
    saturar(Cs, _, R).

test(clasificar, [true(Cs == [tautologia, contradiccion, contingente])]) :-
    maplist(clasificar, ["p ∨ ¬p", "p ∧ ¬p", "p → q"], Cs).

% definir/5 da un átomo d(N) a cada conjunción y disyunción.
test(definir, [true(N-L-Cs == 2-(+d(0))-[ [-d(0), +d(1), -c],
                                         [-d(1), +a],
                                         [-d(1), +b]
                                       ])]) :-
    definir(o(y(at(a), at(b)), no(at(c))), 0, N, L, Cs).

test(definir_literal, [true(N-L-Cs == 3-(-a)-[])]) :-
    definir(no(at(a)), 3, N, L, Cs).

% La variable existencial depende de la universal que la rodea.
test(skolemizar_fnn, [true(N-H =@= 1-todo(X, at(p(X, sk0(X)))))]) :-
    skolemizar_fnn(todo(X0, existe(Y, at(p(X0, Y)))), [], 0, N, H).

test(skolemizar_fnn_afuera, [true(H =@= y(at(p(sk0)), todo(X, at(q(X)))))]) :-
    skolemizar_fnn(y(existe(Y, at(p(Y))), todo(X0, at(q(X0)))), [], 0, _, H).

% Con los dos padres unitarios, la derivación aparece una sola vez.
test(derivar_unitaria, all(P == [[r(1, 2, [])]])) :-
    length(P, 1),
    derivar_unitaria(P, [[+p], [-p]]).

test(derivar_unitaria_sin_unitarias, [fail]) :-
    length(P, 1),
    derivar_unitaria(P, [[+p, +q], [-p, -q]]).

test(subsumida, [true]) :-
    subsumida([+p, +q], [[+q], [+r]]).

test(no_subsumida, [fail]) :-
    subsumida([+p], [[+p, +q]]).

% El modelo no mínimo de Flach se descarta.
test(modelo_minimo, all(M == [[amable(maria), estudiante(maria),
                               gusta(pedro, maria)]])) :-
    modelo_minimo([ [+gusta(pedro, maria)],
                    [+estudiante(maria)],
                    [+docente(X), +amable(Y), -gusta(X, Y), -estudiante(Y)],
                    [+amable(Y1), -docente(X1), -gusta(X1, Y1)]
                  ], M).

test(es_modelo, [true]) :-
    es_modelo([[+p, -q], [+q]], [p, q]).

test(no_es_modelo, [fail]) :-
    es_modelo([[+p, -q], [+q]], [q]).

test(subconjunto_propio, all(S == [[a], [b], []])) :-
    subconjunto_propio([a, b], S).

test(subconjunto, all(S == [[a, b], [a], [b], []])) :-
    subconjunto([a, b], S).

% Quitar una fórmula por vez no alcanza: de [a, b, c] no se puede quitar
% ninguna sola, pero [c] es un modelo.
test(de_a_una, all(M == [[c]])) :-
    modelo_minimo([[+a, +c], [-a, +b], [-b, +a], [+c, -b]], M).

:- end_tests(soluciones).
