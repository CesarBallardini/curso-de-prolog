:- encoding(utf8).

% Capítulo 66 - Versión 2: cotas conservadora y liberal.
%
% El grado que da la independencia depende de una suposición que casi
% nunca se verifica. Los métodos conservador y liberal dan las cotas: el
% grado más bajo y el más alto compatibles con los grados de las partes,
% sin suponer nada sobre cómo se relacionan. intervalo/4 da las dos cotas;
% estimaciones/2 las muestra junto a la estimación independiente, que
% siempre queda entre ellas; domina/3 dice cuándo una hipótesis supera a
% otra con cualquier método, porque la cota inferior de una pasa la
% superior de la otra.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- intervalo(mamifero, [tiene_pelo-0.6, da_leche-0.6], I, S).
%?- estimaciones([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
%?-               manchas_oscuras-0.6, rayas_negras-0.3], E).
%?- caso(2, Os), seguras(Os, Gs), domina(Gs, cebra, H).

:- module(cotas,
          [ intervalo/4,
            estimaciones/2,
            domina/3
          ]).

:- use_module(library(lists)).
:- use_module(library(pairs)).
:- reexport(evidencia).

%!  intervalo(+Meta, +Observaciones:list, -Inf:float, -Sup:float) is det.
%
%   Inf y Sup son los grados de Meta con los métodos conservador y liberal:
%   las cotas de lo que puede valer su grado.
intervalo(Meta, Observaciones, Inf, Sup) :-
    grado(Meta, Observaciones, conservador, Inf),
    grado(Meta, Observaciones, liberal, Sup).

%!  estimaciones(+Observaciones:list, -Filas:list) is det.
%
%   Filas tiene un término H-e(Inf, P, Sup) por cada hipótesis H con cota
%   superior mayor que 0: sus dos cotas y, entre ellas, su grado con el
%   método independiente. Están de mayor a menor P.
estimaciones(Observaciones, Filas) :-
    findall(P-(H-e(Inf, P, Sup)),
            ( hipotesis(H),
              intervalo(H, Observaciones, Inf, Sup),
              Sup > 0,
              grado(H, Observaciones, independiente, P) ),
            Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_values(Ordenados, Filas).

%!  domina(+Observaciones:list, ?H1, ?H2) is nondet.
%
%   La hipótesis H1 tiene más grado que H2 con cualquier método: la cota
%   inferior de H1 es mayor que la cota superior de H2.
domina(Observaciones, H1, H2) :-
    hipotesis(H1),
    intervalo(H1, Observaciones, Inf1, _),
    Inf1 > 0,
    hipotesis(H2),
    H2 \== H1,
    intervalo(H2, Observaciones, _, Sup2),
    Inf1 > Sup2.
