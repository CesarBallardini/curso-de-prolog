:- encoding(utf8).

% Capítulo 68 - Versión 7: incorporar las reglas aprendidas.
%
% Luger y Stubblefield proponen, como ejercicio, que la generalización
% basada en la explicación agregue a la base cada regla que aprende, para
% usarla en las consultas siguientes. reconocer/3 prueba primero las
% reglas aprendidas; si ninguna reconoce el objeto, lo explica con la
% teoría, generaliza la explicación y guarda la regla con assertz/1. La
% teoría solo se usa con los objetos que son tazas por una razón nueva.
%
% solo-local: carga ebg.pl, que carga archivos de otros capítulos.
%
%?- recorrer(taza, Usos).
%?- aprendidas(taza, Rs), length(Rs, N).

:- module(incorporar,
          [ reconocer/3,
            recorrer/2,
            aprendidas/2,
            olvidar/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(ebg).

:- dynamic aprendida/2.

%!  olvidar(+T) is det.
%
%   Quita las reglas aprendidas de la teoría T.
olvidar(T) :-
    retractall(aprendida(T, _)).

%!  aprendidas(+T, -Rs:list) is det.
%
%   Rs son las reglas aprendidas de la teoría T, en el orden en que se
%   aprendieron.
aprendidas(T, Rs) :-
    findall(R, aprendida(T, R), Rs).

%!  reconocer(+T, +Objeto, -Como) is det.
%
%   Objeto es un par O-Hechos. Como es regla si una regla aprendida de T
%   reconoce a O como taza, teoria si hizo falta la teoría (y la regla
%   que se aprende de la explicación queda guardada), y no si O no es una
%   taza.
reconocer(T, O-Hs, Como) :-
    Meta = taza(O),
    (   aprendida(T, R),
        aplicar(T, R, Hs, Meta)
    ->  Como = regla
    ;   operacionales(T, Ops),
        once(ebg(T, Ops, Hs, Meta, R))
    ->  assertz(aprendida(T, R)),
        Como = teoria
    ;   Como = no
    ).

%!  recorrer(+T, -Usos:list) is det.
%
%   Olvida las reglas de T y reconoce, en orden, los objetos de la
%   población. Usos es la lista de pares Como-Cantidad: cuántos objetos se
%   reconocieron con una regla, cuántos con la teoría y cuántos no son
%   tazas.
recorrer(T, Usos) :-
    olvidar(T),
    poblacion(Os),
    maplist(reconocer(T), Os, Comos),
    findall(C-N, ( member(C, [regla, teoria, no]),
                   aggregate_all(count, member(C, Comos), N) ),
            Usos).
