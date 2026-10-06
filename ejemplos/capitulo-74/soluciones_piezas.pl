:- encoding(utf8).

% Capítulo 74 - Solución del ejercicio 13: la ayuda etapa por etapa.
%
% solo-local: carga piezas.pl, que carga etapas.pl.
%
%?- por_etapa(resolver, 50, Sin), por_etapa(resolver_con_ayuda, 50, Con).

:- ensure_loaded(piezas).

%!  por_etapa(+Metodo, +Semillas:integer, -Pares:list(pair)) is det.
%
%   Pares tiene un par E-N por etapa: N son los cuartos de vuelta que
%   Metodo usa en la etapa E, sumados sobre las mezclas de 25 giros de
%   las semillas 1 a Semillas.
por_etapa(Metodo, Semillas, Pares) :-
    findall(Pasos, ( between(1, Semillas, S),
                     mezcla(S, 25, Ms),
                     resuelto(C),
                     aplicar(Ms, C, C1),
                     call(Metodo, C1, Pasos) ),
            Todas),
    append(Todas, Pasos),
    findall(E-N, ( etapa(E, _),
                   aggregate_all(sum(L), ( member(paso(E, _, G), Pasos),
                                           length(G, L) ), N) ),
            Pares).
