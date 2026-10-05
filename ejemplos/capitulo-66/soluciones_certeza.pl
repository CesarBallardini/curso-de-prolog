:- encoding(utf8).

% Capítulo 66 - Solución del ejercicio 13: un umbral por regla.
%
% Merritt propone, en su ejercicio 3.4, que una regla pueda tener su
% propio umbral, que reemplaza al general. umbral_regla/2 lo declara para
% algunas reglas; factor_con_umbrales/4 es factor/4 con ese umbral en las
% reglas que lo tienen.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- atardecer(Os), factor_con_umbrales(guepardo, Os, 0.2, F).

:- ensure_loaded(certeza).

% umbral_regla(Regla, U): la Regla se aplica solo si su premisa llega a U.
umbral_regla(c1, 0.4).
umbral_regla(r7, 0.5).

%!  umbral_de(+Regla, +General:float, -U:float) is det.
%
%   U es el umbral de la Regla: el propio, si lo tiene, o el General.
umbral_de(Regla, General, U) :-
    (   umbral_regla(Regla, U0)
    ->  U = U0
    ;   U = General
    ).

%!  factor_con_umbrales(+Meta, +Observaciones:list, +General:float,
%!                      -F:float) is det.
%
%   F es el factor de certeza de Meta como en factor/4, con el umbral de
%   cada regla dado por umbral_de/3. Las conclusiones intermedias se
%   evalúan con el umbral General.
factor_con_umbrales(Meta, Observaciones, General, F) :-
    findall(A, aporte_con_umbral(Meta, Observaciones, General, A), As),
    foldl(cf_combinar, As, 0.0, F0),
    F is round(F0 * 10000) / 10000.0.

%!  aporte_con_umbral(+Meta, +Observaciones:list, +General:float, -A:float)
%!      is nondet.
%
%   A es como en aporte/4, con el umbral propio de cada regla.
aporte_con_umbral(Meta, Observaciones, _, A) :-
    observable(Meta),
    member(Meta-A, Observaciones).
aporte_con_umbral(Meta, Observaciones, General, A) :-
    regla(Regla, si Condiciones entonces Meta),
    premisa(Condiciones, Observaciones, General, P),
    umbral_de(Regla, General, U),
    P >= U,
    fuerza(Regla, F),
    A is F * P.
aporte_con_umbral(Meta, Observaciones, General, A) :-
    en_contra(Regla, Condicion, Meta, F),
    premisa(Condicion, Observaciones, General, P),
    umbral_de(Regla, General, U),
    P >= U,
    A is -F * P.
