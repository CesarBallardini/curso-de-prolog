:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(colapsar).

test(guepardo, [true(Pss == [[tiene_pelo, come_carne, color_leonado,
                              manchas_oscuras],
                             [da_leche, come_carne, color_leonado,
                              manchas_oscuras]])]) :-
    findall(Ps, colapsada(guepardo, Ps), Pss).

% La comparación queda unida a la observación que liga su variable.
test(avestruz, [true(Ps =@= [tiene_plumas, no_vuela, peso(X) y X > 50])]) :-
    once(colapsada(avestruz, Ps)).

test(cuantas, [true(N-M == 12-14)]) :-
    colapsadas(Rs),
    length(Rs, N),
    preguntas(Ps),
    length(Ps, M).

% Colapsar no cambia lo que se prueba: una hipótesis se prueba con las
% observaciones de un caso si y solo si alguna regla colapsada se cumple.
test(equivalentes, [forall(( caso(_, Os), hipotesis(H) ))]) :-
    (   identificar(Os, H)
    ->  once(( colapsada(H, Ps),
               forall(member(P, Ps), se_cumple(P, Os)) ))
    ;   \+ ( colapsada(H, Ps),
             forall(member(P, Ps), se_cumple(P, Os)) )
    ).

% se_cumple/2 no liga la pregunta.
test(sin_ligar, [true(var(X))]) :-
    se_cumple(peso(X) y X > 50, [peso(90)]).

% desplegar/2 reemplaza mamifero por el cuerpo de cada una de sus reglas.
test(desplegar, [true(Ls == [[tiene_pelo, come_carne],
                             [da_leche, come_carne]])]) :-
    findall(L, colapsar:desplegar(mamifero y come_carne, L), Ls).

test(desplegar_observable, [true(Ls == [[tiene_pelo]])]) :-
    findall(L, colapsar:desplegar(tiene_pelo, L), Ls).

% agrupar/2 une cada comparación con la observación anterior.
test(agrupar, [true(Ps =@= [a, peso(X) y X > 50, b])]) :-
    colapsar:agrupar([a, peso(X), X > 50, b], Ps).

test(agrupar_sin_comparaciones, [true(Ps == [a, b])]) :-
    colapsar:agrupar([a, b], Ps).

:- end_tests(colapsar).
