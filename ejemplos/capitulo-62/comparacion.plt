:- encoding(utf8).

:- use_module(lector).
:- use_module(primer_orden).

:- begin_tests(comparacion).

formula_de_prueba("(p → q) ∧ p → q", si).
formula_de_prueba("(a → b) ∧ (b → c) → (a → c)", si).
formula_de_prueba("((p → q) → p) → p", si).
formula_de_prueba("(p ∨ q) ∧ (p → r) ∧ (q → r) → r", si).
formula_de_prueba("(p ↔ q) ↔ (q ↔ p)", si).
formula_de_prueba("(p → q) → (q → p)", no).
formula_de_prueba("p ∨ q → p ∧ q", no).
formula_de_prueba("¬(p ∧ ¬p)", si).

% Los tres métodos dan el mismo veredicto.
test(acuerdo, [forall(( formula_de_prueba(T, Esperado),
                        member(M, [quine, clpb, resolucion(8)])
                      )),
               true(Veredicto == Esperado)]) :-
    leer_formula(T, F),
    (   tautologia(M, F)
    ->  Veredicto = si
    ;   Veredicto = no
    ).

test(contraejemplo, [true(As == [[p-0, q-1]])]) :-
    leer_formula("(p → q) → (q → p)", F),
    findall(A, contraejemplo(F, A), As).

test(sin_contraejemplo, [fail]) :-
    leer_formula("(p → q) ∧ p → q", F),
    contraejemplo(F, _).

% Cada contraejemplo hace falsa la fórmula con el método de Quine.
test(contraejemplos_correctos) :-
    leer_formula("p ∨ q → p ∧ q", F),
    forall(contraejemplo(F, A),
           ( foldl([At-B, G0, G]>>(comparacion:sustituir(G0, At, B, G)),
                   A, F, G1),
             comparacion:valor(G1, 0)
           )).

test(atomos, [true(As == [p, q, r])]) :-
    leer_formula("(q → p) ∧ r ∨ ¬q", F),
    atomos(F, As).

test(palomar_tamano, [true(N-M == 12-22)]) :-
    palomar(3, F),
    atomos(F, As),
    length(As, N),
    clausulas_fo(no(F), Cs),
    length(Cs, M).

test(palomar, [forall(member(N, [1, 2, 3, 4])),
               true(T == si)]) :-
    palomar(N, F),
    (   tautologia(clpb, F)
    ->  T = si
    ;   T = no
    ).

% Dos palomas, un agujero: las dos están en él, y no pueden estar las dos.
test(palomar_1, [true(F == no(y(y(at(en(1, 1)), at(en(2, 1))),
                                no(y(at(en(1, 1)), at(en(2, 1)))))))]) :-
    palomar(1, F).

test(tautologia_palomar, [forall(member(M, [quine, clpb, resolucion(12)]))]) :-
    tautologia_palomar(M, 2).

:- end_tests(comparacion).
