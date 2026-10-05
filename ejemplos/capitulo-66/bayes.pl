:- encoding(utf8).

% Capítulo 66 - Ampliación: la regla de Bayes.
%
% bayes/4 obtiene la probabilidad de A dado B a partir de la inversa, la
% de B dado A, y de las probabilidades de A y de B. inconsistencias/5
% busca, entre cuatro probabilidades dadas por una persona, las
% desigualdades de Rowe que no se cumplen. posterior/3 aplica la regla a
% los animales: con la frecuencia de cada uno entre los que se consultan y
% las observaciones que presenta un animal típico de cada clase, da la
% probabilidad de cada animal dadas unas observaciones, suponiendo que
% cada observación se registra mal con una probabilidad Error y que los
% errores son independientes.
%
%?- bayes(1.0, 0.02, 0.05, P).
%?- posterior([manchas_oscuras], 0.01, R).
%?- posterior([tiene_pelo, manchas_oscuras, cuello_largo], 0.01, R).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

%!  bayes(+PBdadoA:float, +PA:float, +PB:float, -PAdadoB:float) is det.
%
%   PAdadoB es p(A dado B) = p(B dado A) p(A) / p(B), con cuatro
%   decimales. Error de dominio si PB no es positiva.
bayes(PBdadoA, PA, PB, PAdadoB) :-
    must_be(number, PB),
    (   PB > 0
    ->  true
    ;   domain_error(probabilidad_positiva, PB)
    ),
    P is PBdadoA * PA / PB,
    PAdadoB is round(P * 10000) / 10000.0.

%!  inconsistencias(+PA:float, +PB:float, +PAdadoB:float, +PBdadoA:float,
%!                  -Fallas:list) is det.
%
%   Fallas son las condiciones que no se cumplen entre las cuatro
%   probabilidades: las cuatro desigualdades de Rowe, por su número, y la
%   igualdad p(A dado B) p(B) = p(B dado A) p(A), como igualdad.
inconsistencias(PA, PB, PAdadoB, PBdadoA, Fallas) :-
    AB is PAdadoB * PB,
    BA is PBdadoA * PA,
    findall(F,
            ( condicion(F, PA, PB, PAdadoB, PBdadoA, AB, BA),
              \+ cumple(F, PA, PB, PAdadoB, PBdadoA, AB, BA) ),
            Fallas).

%!  condicion(-F, +PA, +PB, +PAdadoB, +PBdadoA, +AB, +BA) is multi.
%
%   F es una de las cinco condiciones: 1 a 4 y igualdad.
condicion(F, _, _, _, _, _, _) :-
    member(F, [1, 2, 3, 4, igualdad]).

%!  cumple(+F, +PA, +PB, +PAdadoB, +PBdadoA, +AB, +BA) is semidet.
%
%   La condición F se cumple. AB es p(A dado B) p(B) y BA es
%   p(B dado A) p(A), que deben ser iguales salvo redondeo.
cumple(1, PA, _, _, _, AB, _) :-
    PA >= AB.
cumple(2, _, _, _, PBdadoA, AB, _) :-
    PBdadoA >= AB.
cumple(3, _, PB, _, _, _, BA) :-
    PB >= BA.
cumple(4, _, _, PAdadoB, _, _, BA) :-
    PAdadoB >= BA.
cumple(igualdad, _, _, _, _, AB, BA) :-
    abs(AB - BA) < 1.0e-9.

% frecuencia(H, F): de cada 100 animales que se consultan, F son H.
frecuencia(guepardo, 10).
frecuencia(tigre, 10).
frecuencia(jirafa, 5).
frecuencia(cebra, 15).
frecuencia(pinguino, 40).
frecuencia(avestruz, 20).

% presenta(H, O): un animal típico de la clase H presenta la observación O.
presenta(guepardo, tiene_pelo).
presenta(guepardo, da_leche).
presenta(guepardo, come_carne).
presenta(guepardo, color_leonado).
presenta(guepardo, manchas_oscuras).
presenta(tigre, tiene_pelo).
presenta(tigre, da_leche).
presenta(tigre, come_carne).
presenta(tigre, color_leonado).
presenta(tigre, rayas_negras).
presenta(jirafa, tiene_pelo).
presenta(jirafa, da_leche).
presenta(jirafa, tiene_cascos).
presenta(jirafa, cuello_largo).
presenta(jirafa, manchas_oscuras).
presenta(cebra, tiene_pelo).
presenta(cebra, da_leche).
presenta(cebra, tiene_cascos).
presenta(cebra, rayas_negras).
presenta(pinguino, tiene_plumas).
presenta(pinguino, pone_huevos).
presenta(pinguino, no_vuela).
presenta(pinguino, nada).
presenta(avestruz, tiene_plumas).
presenta(avestruz, pone_huevos).
presenta(avestruz, no_vuela).

%!  verosimilitud(+H, +O, +Error:float, -P:float) is det.
%
%   P es la probabilidad de registrar la observación O en un animal de la
%   clase H: 1 - Error si lo presenta, Error si no.
verosimilitud(H, O, Error, P) :-
    (   presenta(H, O)
    ->  P is 1 - Error
    ;   P = Error
    ).

%!  conjunta(+Observaciones:list, +Error:float, ?H, -P:float) is nondet.
%
%   P es la probabilidad de que el animal sea H y se registren las
%   Observaciones: la frecuencia de H por la verosimilitud de cada una.
conjunta(Observaciones, Error, H, P) :-
    frecuencia(H, F),
    foldl(por_verosimilitud(H, Error), Observaciones, F / 100, P0),
    P is P0.

%!  por_verosimilitud(+H, +Error:float, +O, +P0, -P) is det.
%
%   P es P0 por la verosimilitud de O en H.
por_verosimilitud(H, Error, O, P0, P) :-
    verosimilitud(H, O, Error, V),
    P is P0 * V.

%!  posterior(+Observaciones:list, +Error:float, -Ranking:list) is det.
%
%   Ranking tiene un par H-P por animal, de mayor a menor P: la
%   probabilidad de H dadas las Observaciones, por la regla de Bayes, con
%   cuatro decimales. El denominador, la probabilidad de las
%   Observaciones, es la suma de las conjuntas de todos los animales.
posterior(Observaciones, Error, Ranking) :-
    findall(H-P, conjunta(Observaciones, Error, H, P), Pares),
    pairs_values(Pares, Ps),
    sum_list(Ps, Total),
    maplist(normalizar(Total), Pares, Normalizados),
    sort(2, @>=, Normalizados, Ranking).

%!  normalizar(+Total:float, +Par, -Normalizado) is det.
%
%   Normalizado es H-P/Total, con cuatro decimales.
normalizar(Total, H-P, H-Q) :-
    Q is round(P / Total * 10000) / 10000.0.
