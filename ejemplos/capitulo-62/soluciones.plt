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

:- end_tests(soluciones).
