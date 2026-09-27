:- encoding(utf8).

% Capítulo 20 - Un sistema experto con encadenamiento hacia adelante.
%
% Los hechos conocidos están en hecho/1, un predicado dinámico. encadenar/0
% busca una regla cuyas condiciones se cumplen y cuya conclusión todavía no
% es un hecho, agrega la conclusión y vuelve a empezar, hasta que ninguna
% regla agrega nada. derivado/3 registra, para cada hecho agregado, la regla
% y las condiciones que lo produjeron.
%
%?- reiniciar, encadenar, hecho(abuelo(juan, N)).
%?- reiniciar, encadenar, derivado(abuelo(juan, sofia), Regla, Condiciones).

:- dynamic hecho/1, derivado/3.

% inicial(F): F es uno de los hechos con los que empieza la base.
inicial(padre(juan, ana)).
inicial(padre(juan, pedro)).
inicial(padre(pedro, luis)).
inicial(padre(pedro, eva)).
inicial(madre(marta, ana)).
inicial(madre(marta, pedro)).
inicial(madre(ana, sofia)).

% regla(Nombre, Condiciones, Conclusion): si se cumplen todas las
% Condiciones, Conclusion es un hecho.
regla(progenitor_p, [padre(P, H)],                   progenitor(P, H)).
regla(progenitor_m, [madre(M, H)],                   progenitor(M, H)).
regla(abuelo,       [padre(A, P), progenitor(P, N)], abuelo(A, N)).
regla(hermanos,     [progenitor(P, A), progenitor(P, B), A \== B],
                                                     hermanos(A, B)).
regla(antepasado_1, [progenitor(A, D)],              antepasado(A, D)).
regla(antepasado_2, [progenitor(A, H), antepasado(H, D)], antepasado(A, D)).

%!  reiniciar is det.
%
%   Deja en la base solo los hechos iniciales.
reiniciar :-
    retractall(hecho(_)),
    retractall(derivado(_, _, _)),
    forall(inicial(F), assertz(hecho(F))).

%!  encadenar is det.
%
%   Agrega a la base las conclusiones de las reglas, de a una, hasta que
%   ninguna regla produce un hecho nuevo.
encadenar :-
    (   regla(Nombre, Condiciones, Conclusion),
        maplist(se_cumple, Condiciones),
        \+ hecho(Conclusion)
    ->  assertz(hecho(Conclusion)),
        assertz(derivado(Conclusion, Nombre, Condiciones)),
        encadenar
    ;   true
    ).

%!  se_cumple(+Condicion) is nondet.
%
%   Condicion es un hecho de la base, o una comparación A \== B que se
%   cumple.
se_cumple(A \== B) :-
    A \== B.
se_cumple(Condicion) :-
    Condicion \= ( _ \== _ ),
    hecho(Condicion).
