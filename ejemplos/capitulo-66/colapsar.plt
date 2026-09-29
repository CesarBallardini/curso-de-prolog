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

:- end_tests(colapsar).
