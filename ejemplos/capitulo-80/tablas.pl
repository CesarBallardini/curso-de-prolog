:- encoding(utf8).

% Capítulo 80 - Versión 5: las uniones como tablas de library(clpfd).
%
% Cada línea es una variable entera de 1 a 4, una por etiqueta, y cada
% unión es una restricción tuples_in/2: la tabla de las combinaciones de su
% tipo, ya escritas con las etiquetas vistas desde la primera punta de
% cada línea. clpfd quita de cada variable los valores que no aparecen en
% ninguna fila de la tabla compatible con los dominios de las demás, y lo
% repite cada vez que un dominio cambia: es el filtrado de Waltz hecho por
% la biblioteca. El etiquetado del final busca entre lo que queda.
%
% solo-local: carga dibujo.pl.
%
%?- posibles_clpfd(cubo, sin_borde, Posibles).
%?- etiquetar_clpfd(cubo, borde, Lineas).

:- ensure_loaded(dibujo).
:- use_module(library(clpfd)).

% codigo(E, N): la etiqueta E se representa con el entero N.
codigo(mas, 1).
codigo(menos, 2).
codigo(der, 3).
codigo(izq, 4).

%!  modelo_clpfd(+F, +Modo, -Pares:list) is semidet.
%
%   Pares son pares Linea-V, con V la variable entera de cada línea del
%   dibujo F, después de plantear todas las restricciones. Falla si la
%   propagación ya descubre que no hay interpretación.
modelo_clpfd(F, Modo, Pares) :-
    lineas(F, Ls),
    pairs_keys_values(Pares, Ls, Vs),
    Vs ins 1..4,
    fijas(F, Modo, Fijas),
    maplist(fijar_codigo(Pares), Fijas),
    uniones(F, Us),
    maplist(tabla(Pares), Us).

%!  fijar_codigo(+Pares:list, +Fija) is semidet.
%
%   La variable de la línea de Fija vale el código de su etiqueta.
fijar_codigo(Pares, L-E) :-
    memberchk(L-V, Pares),
    codigo(E, C),
    V #= C.

%!  tabla(+Pares:list, +U) is semidet.
%
%   Plantea la restricción de la unión U = u(P, Tipo, Ks): las variables de
%   sus líneas forman una fila de la tabla de su tipo.
tabla(Pares, u(P, Tipo, Ks)) :-
    maplist(variable_de_linea(Pares, P), Ks, Vs),
    findall(Fila,
            ( union_posible(Tipo, Locales),
              maplist(codigo_global(P), Ks, Locales, Fila) ),
            Filas),
    tuples_in([Vs], Filas).

%!  variable_de_linea(+Pares:list, +P, +K, -V) is det.
%
%   V es la variable de la línea entre P y K.
variable_de_linea(Pares, P, K, V) :-
    linea(P, K, L),
    memberchk(L-V, Pares).

%!  codigo_global(+P, +K, +Local, -C) is det.
%
%   C es el código de la etiqueta de la línea de P a K, vista desde la
%   primera punta de la línea, cuando la unión P la ve como Local.
codigo_global(P, K, Local, C) :-
    (   P @< K
    ->  E = Local
    ;   inversa(Local, E)
    ),
    codigo(E, C).

%!  posibles_clpfd(+F, +Modo, -Posibles:list) is semidet.
%
%   Posibles son pares Linea-Es, con Es las etiquetas que la propagación
%   deja posibles para cada línea del dibujo F, sin etiquetar.
posibles_clpfd(F, Modo, Posibles) :-
    modelo_clpfd(F, Modo, Pares),
    maplist(etiquetas_posibles, Pares, Posibles).

%!  etiquetas_posibles(+Par, -Posibles) is det.
%
%   Posibles es L-Es, con Es las etiquetas cuyo código está en el dominio
%   de la variable de L.
etiquetas_posibles(L-V, L-Es) :-
    fd_dom(V, Dominio),
    findall(E, ( codigo(E, C), C in Dominio ), Es).

%!  etiquetar_clpfd(+F, +Modo, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F, como pares Linea-Etiqueta.
etiquetar_clpfd(F, Modo, Lineas) :-
    modelo_clpfd(F, Modo, Pares),
    pairs_values(Pares, Vs),
    labeling([ff], Vs),
    maplist(decodificar, Pares, Lineas).

%!  decodificar(+Par, -ParEtiqueta) is det.
%
%   Reemplaza el código del par L-C por su etiqueta.
decodificar(L-C, L-E) :-
    codigo(E, C).

%!  interpretaciones_clpfd(+F, +Modo, -N:integer) is det.
%
%   N es la cantidad de interpretaciones del dibujo F.
interpretaciones_clpfd(F, Modo, N) :-
    aggregate_all(count, etiquetar_clpfd(F, Modo, _), N).

%!  escribir_posibles(+F, +Modo) is semidet.
%
%   Escribe, una por renglón, cada línea del dibujo F con las etiquetas que
%   la propagación de clpfd deja posibles.
escribir_posibles(F, Modo) :-
    posibles_clpfd(F, Modo, Ps),
    forall(member((A-B)-Es, Ps), format("~w~w: ~w~n", [A, B, Es])).
