:- encoding(utf8).

% Capítulo 68 - Soluciones de los ejercicios 12 y 13: el orden de los
% positivos en la disyunción y el costo de incorporar las reglas.
%
% solo-local: carga generalizaciones.pl e incorporar.pl, que cargan
% archivos de otros capítulos.
%
%?- disyunciones(esferas_y_cubos_verdes, Ds), length(Ds, N).
%?- costos_incorporar(Recorrer, Teoria, Segunda).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(generalizaciones).
:- use_module(incorporar).
:- use_module(ebg, [inferencias/2, clasificar_con_teoria/2]).
:- use_module(teorias, [poblacion/1]).

%!  disyunciones(+Nombre, -Ds:list) is det.
%
%   Ds son las disyunciones distintas que da disyuncion_de/2 con cada
%   orden de los positivos de la secuencia Nombre, seguidos de los
%   negativos.
disyunciones(Nombre, Ds) :-
    ejemplos_de(Nombre, Ejs),
    findall(pos(I), member(pos(I), Ejs), Pos),
    findall(neg(I), member(neg(I), Ejs), Negs),
    findall(D, ( permutation(Pos, Pos1),
                 append(Pos1, Negs, Ejs1),
                 disyuncion_de(Ejs1, D) ), Ds0),
    sin_variantes(Ds0, Ds).

%!  sin_variantes(+Ts:list, -Us:list) is det.
%
%   Us son los términos de Ts sin variantes repetidas, en el orden de su
%   primera aparición.
sin_variantes([], []).
sin_variantes([T|Ts], [T|Us]) :-
    exclude(=@=(T), Ts, Ts1),
    sin_variantes(Ts1, Us).

%!  costos_incorporar(-Recorrer:integer, -Teoria:integer,
%!      -Segunda:integer) is det.
%
%   Inferencias que usa reconocer las tazas de la población: Recorrer con
%   recorrer/2, que empieza sin reglas; Teoria con la teoría sola; y
%   Segunda en una segunda pasada, con las reglas que dejó la primera.
costos_incorporar(Recorrer, Teoria, Segunda) :-
    inferencias(recorrer(taza, _), Recorrer),
    inferencias(clasificar_con_teoria(taza, _), Teoria),
    recorrer(taza, _),
    poblacion(Os),
    inferencias(maplist(reconocer(taza), Os, _), Segunda).
