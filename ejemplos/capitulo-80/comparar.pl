:- encoding(utf8).

% Capítulo 80 - Las versiones comparadas.
%
% Carga las cuatro maneras de etiquetar y mide, con call_time/2 de
% library(statistics), cuántas inferencias necesita cada una para
% encontrar todas las interpretaciones de un dibujo. También comprueba que
% todas encuentran las mismas, y que el filtrado de Waltz y la propagación
% de clpfd dejan posibles las mismas etiquetas para cada línea.
%
% solo-local: carga las versiones 2 a 5.
%
%?- medir(waltz, cubo, sin_borde, N, Inferencias).
%?- tabla_de_costos(escalera(4), borde, Filas).

:- ensure_loaded(generar).
:- ensure_loaded(restricciones).
:- ensure_loaded(waltz).
:- ensure_loaded(tablas).

%!  todas(+Version, +F, +Modo, -Ls:list) is det.
%
%   Ls son las interpretaciones del dibujo F que encuentra la Version,
%   ordenadas.
todas(Version, F, Modo, Ls) :-
    findall(L, etiquetar(Version, F, Modo, L), Ls0),
    msort(Ls0, Ls).

%!  etiquetar(+Version, +F, +Modo, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F según la Version:
%   generar, alfabetico, vecindad, waltz o clpfd.
etiquetar(generar, F, Modo, Ls) :-
    etiquetar_gyp(F, Modo, Ls).
etiquetar(alfabetico, F, Modo, Ls) :-
    etiquetar_por_uniones(F, Modo, alfabetico, Ls).
etiquetar(vecindad, F, Modo, Ls) :-
    etiquetar_por_uniones(F, Modo, vecindad, Ls).
etiquetar(waltz, F, Modo, Ls) :-
    etiquetar_waltz(F, Modo, Ls).
etiquetar(clpfd, F, Modo, Ls) :-
    etiquetar_clpfd(F, Modo, Ls).

%!  medir(+Version, +F, +Modo, -N:integer, -Inferencias:integer) is det.
%
%   La Version encuentra N interpretaciones del dibujo F con esa cantidad
%   de Inferencias.
medir(Version, F, Modo, N, Inferencias) :-
    call_time(aggregate_all(count, etiquetar(Version, F, Modo, _), N),
              Tiempo),
    get_dict(inferences, Tiempo, Inferencias).

%!  tabla_de_costos(+F, +Modo, -Filas:list) is det.
%
%   Filas son términos Version-N-Inferencias para las versiones que
%   terminan en dibujos grandes: alfabetico, vecindad, waltz y clpfd.
tabla_de_costos(F, Modo, Filas) :-
    findall(V-N-I,
            ( member(V, [alfabetico, vecindad, waltz, clpfd]),
              medir(V, F, Modo, N, I) ),
            Filas).

%!  mismas(+F, +Modo, +Versiones:list) is semidet.
%
%   Todas las Versiones encuentran las mismas interpretaciones de F.
mismas(F, Modo, [V|Vs]) :-
    todas(V, F, Modo, Ls),
    forall(member(V2, Vs), todas(V2, F, Modo, Ls)).

%!  posibles_waltz(+F, +Modo, -Posibles:list) is semidet.
%
%   Posibles son pares Linea-Es con las etiquetas que el filtrado deja
%   posibles para cada línea: las que le da alguna combinación que quedó en
%   el dominio de una de sus puntas.
posibles_waltz(F, Modo, Posibles) :-
    filtrar(F, Modo, D),
    lineas(F, Ls),
    maplist(posibles_de_linea(D), Ls, Posibles).

%!  posibles_de_linea(+D, +L, -Posibles) is det.
%
%   Posibles es L-Es, con Es las etiquetas de L en el dominio de su
%   primera punta, en el orden de codigo/2.
posibles_de_linea(D, A-B, (A-B)-Es) :-
    get_assoc(A, D, Cs),
    findall(E, ( codigo(E, _),
                 once(( member(C, Cs), memberchk((A-B)-E, C) )) ), Es).
