:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(evidencia).

% Una regla con una condición: la fuerza de r1 por el grado observado.
test(una_regla, [true(P =:= 0.81)]) :-
    grado(mamifero, [tiene_pelo-0.9], independiente, P).

% Las observaciones seguras del caso 1: 0.9 * 0.8 * 0.85.
test(caso_seguro, [true(P =:= 0.612)]) :-
    caso(1, Os),
    seguras(Os, Gs),
    grado(guepardo, Gs, independiente, P).

% Dos reglas para la misma conclusión, con los tres métodos.
test(dos_reglas, [true(Ps == [0.8022, 0.55, 1.0])]) :-
    findall(P, ( member(M, [independiente, conservador, liberal]),
                 grado(mamifero, [tiene_pelo-0.6, da_leche-0.6], M, P) ),
            Ps).

% Sin nada que la apoye, una conclusión tiene grado 0.
test(sin_apoyo, [true(P =:= 0.0)]) :-
    grado(cebra, [tiene_plumas-1.0], independiente, P).

% Los neutros: y de nada es 1.0 y o de nada es 0.0.
test(neutros, [true(Y-O == 1.0-0.0)]) :-
    combinar(y, conservador, [], Y),
    combinar(o, liberal, [], O).

% La comparación sobre un valor observado: peso(90) cumple P > 50.
test(comparacion, [true(R == [0.9-avestruz])]) :-
    caso(3, Os),
    seguras(Os, Gs),
    ranking(Gs, independiente, R).

test(ranking, [true(R == [0.1851-guepardo, 0.098-tigre])]) :-
    ranking([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
             manchas_oscuras-0.6, rayas_negras-0.3], independiente, R).

% Las fórmulas binarias son conmutativas y asociativas.
test(asociativas, [forall(( metodo(M), member(Op, [y, o]),
                            member(A, [0.0, 0.3, 0.8, 1.0]),
                            member(B, [0.2, 0.5, 1.0]),
                            member(C, [0.1, 0.6, 0.9]) ))]) :-
    call(Op, M, A, B, AB),
    call(Op, M, AB, C, P1),
    call(Op, M, B, C, BC),
    call(Op, M, A, BC, P2),
    call(Op, M, B, A, BA),
    abs(P1 - P2) < 1.0e-9,
    abs(AB - BA) < 1.0e-9.

:- end_tests(evidencia).
