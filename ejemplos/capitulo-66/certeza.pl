:- encoding(utf8).

% Capítulo 66 - Ampliación: evidencia a favor y en contra.
%
% Las reglas de la versión 1 solo dan evidencia a favor. en_contra/4
% agrega reglas que dan evidencia en contra: unas rayas negras hablan en
% contra de un guepardo, y unas manchas oscuras, en contra de un tigre.
% balance/4 sigue la propuesta que Rowe describe: combina por separado la
% evidencia a favor y la evidencia en contra, con el mismo método, y
% resta; el resultado va de -1, seguro que no, a 1, seguro que sí.
% factor/4 sigue a MYCIN y a Clam, el shell de Merritt: cada regla tiene
% un factor de certeza entre -1 y 1, la premisa vale el mínimo de sus
% condiciones y la regla no se aplica si la premisa no llega al umbral, y
% los aportes se combinan con la fórmula de tres casos según sus signos.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- tabla_balance(Filas).
%?- tabla_factor([0.2, 0.4, 0.6], Filas).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(evidencia).

% en_contra(Regla, Condicion, Meta, Fuerza): si Condicion, la Meta es
% falsa con probabilidad Fuerza.
en_contra(c1, rayas_negras, guepardo, 0.9).
en_contra(c2, manchas_oscuras, tigre, 0.9).
en_contra(c3, tiene_plumas, mamifero, 0.95).
en_contra(c4, vuela, avestruz, 0.95).

%!  contra(+Meta, +Observaciones:list, +Metodo, -P:float) is det.
%
%   P es el grado de la evidencia en contra de Meta: la combinación con o,
%   según Metodo, de lo que aporta cada regla de en_contra/4 con la
%   condición observada, redondeada a cuatro decimales.
contra(Meta, Observaciones, Metodo, P) :-
    findall(P1,
            ( en_contra(_, Condicion, Meta, F),
              member(Condicion-PC, Observaciones),
              y(Metodo, F, PC, P1) ),
            Ps),
    combinar(o, Metodo, Ps, P0),
    P is round(P0 * 10000) / 10000.0.

%!  balance(+Meta, +Observaciones:list, +Metodo, -B:float) is det.
%
%   B es el grado a favor de Meta menos el grado en contra, con cuatro
%   decimales.
balance(Meta, Observaciones, Metodo, B) :-
    grado(Meta, Observaciones, Metodo, A),
    contra(Meta, Observaciones, Metodo, C),
    B is round((A - C) * 10000) / 10000.0.

%!  factor(+Meta, +Observaciones:list, +Umbral:float, -F:float) is det.
%
%   F es el factor de certeza de Meta, entre -1 y 1, con cuatro
%   decimales: la combinación con cf_combinar/3 de los aportes de cada
%   regla a favor y en contra cuya premisa alcanza el Umbral, o 0.0 si no
%   se aplica ninguna. Una observación aporta su grado.
factor(Meta, Observaciones, Umbral, F) :-
    findall(A, aporte(Meta, Observaciones, Umbral, A), As),
    foldl(cf_combinar, As, 0.0, F0),
    F is round(F0 * 10000) / 10000.0.

%!  aporte(+Meta, +Observaciones:list, +Umbral:float, -A:float) is nondet.
%
%   A es lo que aporta a Meta una observación, una regla a favor, la
%   fuerza por la premisa, o una regla en contra, con signo negativo. La
%   premisa debe alcanzar el Umbral.
aporte(Meta, Observaciones, _, A) :-
    observable(Meta),
    member(Meta-A, Observaciones).
aporte(Meta, Observaciones, Umbral, A) :-
    regla(Regla, si Condiciones entonces Meta),
    premisa(Condiciones, Observaciones, Umbral, P),
    P >= Umbral,
    fuerza(Regla, F),
    A is F * P.
aporte(Meta, Observaciones, Umbral, A) :-
    en_contra(_, Condicion, Meta, F),
    premisa(Condicion, Observaciones, Umbral, P),
    P >= Umbral,
    A is -F * P.

%!  premisa(+Condicion, +Observaciones:list, +Umbral:float, -P:float)
%!      is semidet.
%
%   P es el factor de Condicion: el mínimo de una conjunción, 1.0 para una
%   comparación que se cumple, el grado de una observación, o el factor
%   de una conclusión intermedia. Falla si una observación no está o una
%   comparación no se cumple.
premisa(A y B, Observaciones, Umbral, P) :-
    !,
    premisa(A, Observaciones, Umbral, PA),
    premisa(B, Observaciones, Umbral, PB),
    P is min(PA, PB).
premisa(Comparacion, _, _, 1.0) :-
    comparacion(Comparacion),
    !,
    call(Comparacion).
premisa(Meta, Observaciones, _, P) :-
    observable(Meta),
    !,
    memberchk(Meta-P, Observaciones).
premisa(Meta, Observaciones, Umbral, P) :-
    factor(Meta, Observaciones, Umbral, P).

%!  cf_combinar(+X:float, +Y:float, -Z:float) is det.
%
%   Z combina dos factores de certeza, como en MYCIN: si los dos son
%   positivos, X + Y(1 - X); si los dos son negativos, el opuesto de
%   combinar sus opuestos; si tienen signos distintos,
%   (X + Y) / (1 - min(|X|, |Y|)).
cf_combinar(X, Y, Z) :-
    (   X >= 0, Y >= 0
    ->  Z is X + Y * (1 - X)
    ;   X < 0, Y < 0
    ->  Z is X + Y * (1 + X)
    ;   Z is (X + Y) / (1 - min(abs(X), abs(Y)))
    ).

% atardecer(Os): las observaciones del animal visto al atardecer en la
% versión 1.
atardecer([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
           manchas_oscuras-0.6, rayas_negras-0.3]).

%!  tabla_balance(-Filas:list) is det.
%
%   Filas tiene, por cada método, el término f(Metodo, Guepardo, Tigre),
%   con el balance de las dos hipótesis para el animal del atardecer.
tabla_balance(Filas) :-
    atardecer(Os),
    findall(f(M, G, T),
            ( member(M, [independiente, conservador, liberal]),
              balance(guepardo, Os, M, G),
              balance(tigre, Os, M, T) ),
            Filas).

%!  tabla_factor(+Umbrales:list, -Filas:list) is det.
%
%   Filas tiene, por cada umbral, el término f(Umbral, Guepardo, Tigre),
%   con el factor de certeza de las dos hipótesis para el animal del
%   atardecer.
tabla_factor(Umbrales, Filas) :-
    atardecer(Os),
    findall(f(U, G, T),
            ( member(U, Umbrales),
              factor(guepardo, Os, U, G),
              factor(tigre, Os, U, T) ),
            Filas).
