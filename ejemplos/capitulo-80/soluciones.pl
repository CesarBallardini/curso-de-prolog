:- encoding(utf8).

% Capítulo 80 - Soluciones de los ejercicios.
%
% Carga comparar.pl, que carga las versiones 2 a 5, y agrega dos dibujos a
% los de figuras.pl, que declara punto/4 y segmento/3 como multifile.
%
% solo-local: carga comparar.pl.
%
%?- combinaciones(cubo, sin_borde, inicial, N).
%?- etiquetar_apoyado(cubo, [d-g], Ls).

:- ensure_loaded(comparar).
:- discontiguous punto/4, segmento/3.

% Ejercicio 2

%!  posibles_en(?Tipo, ?I:integer, -Es:list) is nondet.
%
%   Es son las etiquetas que la línea I de una unión de Tipo tiene en
%   alguna entrada del catálogo, ordenadas.
posibles_en(Tipo, I, Es) :-
    setof(E, Ls^( union_posible(Tipo, Ls), nth1(I, Ls, E) ), Es).

% Ejercicio 3

%!  combinaciones(+F, +Modo, +Momento, -N:integer) is semidet.
%
%   N es el producto de los tamaños de los dominios del dibujo F en el
%   Momento, inicial o filtrado.
combinaciones(F, Modo, Momento, N) :-
    tamanos(F, Modo, Momento, Ts),
    pairs_values(Ts, Ns),
    foldl(producto, Ns, 1, N).

%!  producto(+X:integer, +P0:integer, -P:integer) is det.
%
%   P es P0 multiplicado por X.
producto(X, P0, P) :-
    P is P0 * X.

% Ejercicio 4

%!  etiquetar_apoyado(+F, +Apoyadas:list, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F, sin la condición de borde,
%   en la que cada línea A-B de Apoyadas es cóncava.
etiquetar_apoyado(F, Apoyadas, Lineas) :-
    problema(F, sin_borde, Lineas, Uniones0),
    maplist(apoyar(Lineas), Apoyadas),
    ordenar(vecindad, F, Uniones0, Uniones),
    maplist(elegir, Uniones).

%!  apoyar(+Lineas:list, +Par) is semidet.
%
%   La línea entre las puntas de Par = A-B es cóncava en Lineas.
apoyar(Lineas, A-B) :-
    linea(A, B, L),
    memberchk(L-menos, Lineas).

% Ejercicio 5: dos cubos separados, el segundo corrido 80 a la derecha.

punto(dos_cubos, P, X, Y) :-
    punto(cubo, P, X, Y).
punto(dos_cubos, P, X, Y) :-
    copia(P0, P),
    punto(cubo, P0, X0, Y),
    X is X0 + 80.

segmento(dos_cubos, A, B) :-
    segmento(cubo, A0, B0),
    (   A = A0,
        B = B0
    ;   copia(A0, A),
        copia(B0, B)
    ).

%!  copia(?P0, ?P) is nondet.
%
%   P es el punto del segundo cubo que corresponde al punto P0 del primero.
copia(P0, P) :-
    member(P0-P, [a-h, b-i, c-j, d-k, e-l, f-m, g-n]).

% Ejercicio 6

%!  ambiguas(+F, +Modo, -Ls:list) is det.
%
%   Ls son las líneas del dibujo F que tienen etiquetas distintas en
%   distintas interpretaciones.
ambiguas(F, Modo, Ls) :-
    todas(waltz, F, Modo, Todas),
    lineas(F, Lineas),
    include(ambigua_en(Todas), Lineas, Ls).

%!  ambigua_en(+Todas:list, +L) is semidet.
%
%   La línea L tiene al menos dos etiquetas en las interpretaciones Todas.
ambigua_en(Todas, L) :-
    findall(E, ( member(Ls, Todas), memberchk(L-E, Ls) ), Es0),
    sort(Es0, [_, _|_]).

% Ejercicio 7

%!  etiquetar_por_catalogo(+F, +Modo, -Lineas:list) is nondet.
%
%   Como etiquetar_por_uniones/4, eligiendo primero las uniones cuyo tipo
%   tiene menos entradas en el catálogo.
etiquetar_por_catalogo(F, Modo, Lineas) :-
    problema(F, Modo, Lineas, Uniones0),
    map_list_to_pairs(entradas, Uniones0, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Uniones),
    maplist(elegir, Uniones).

%!  entradas(+U, -N:integer) is det.
%
%   N es la cantidad de entradas del catálogo para el tipo de la unión U.
entradas(u(_, Tipo, _), N) :-
    cantidad(Tipo, N),
    !.

%!  medir_catalogo(+F, +Modo, -N:integer, -Inferencias:integer) is det.
%
%   El orden por catálogo encuentra N interpretaciones del dibujo F con
%   esa cantidad de Inferencias, medidas en una segunda ejecución.
medir_catalogo(F, Modo, N, Inferencias) :-
    Meta = aggregate_all(count, etiquetar_por_catalogo(F, Modo, _), N),
    call(Meta),
    call_time(Meta, Tiempo),
    get_dict(inferences, Tiempo, Inferencias).

% Ejercicio 8

%!  crecimiento(+Version, +Ns:list, -Filas:list) is det.
%
%   Filas son pares N-Inferencias de la Version en escalera(N) sin borde,
%   para cada N de Ns, medidas en una segunda ejecución.
crecimiento(Version, Ns, Filas) :-
    findall(N-I,
            ( member(N, Ns),
              medir(Version, escalera(N), sin_borde, _, _),
              medir(Version, escalera(N), sin_borde, _, I) ),
            Filas).

% Ejercicio 9

%!  pasos(+F, +Modo, -N:integer, -Uniones:list) is semidet.
%
%   N es la cantidad de reducciones de dominio que hace el filtrado del
%   dibujo F, y Uniones las uniones que se redujeron al menos una vez.
pasos(F, Modo, N, Uniones) :-
    inicio(F, Modo, Vecinos, D0),
    assoc_to_keys(D0, Cola),
    propagar(Cola, Vecinos, D0, _, Pasos),
    length(Pasos, N),
    pairs_keys(Pasos, Us),
    sort(Us, Uniones).

% Ejercicio 10: un prisma triangular apoyado sobre una cara rectangular.

punto(prisma, p, 0, 0).
punto(prisma, q, 40, 0).
punto(prisma, r, 20, 30).
punto(prisma, q2, 55, 10).
punto(prisma, r2, 35, 40).

segmento(prisma, p, q).
segmento(prisma, q, r).
segmento(prisma, r, p).
segmento(prisma, q, q2).
segmento(prisma, q2, r2).
segmento(prisma, r2, r).

% Ejercicio 11

% union_cambiada(Tipo, Etiquetas): el catálogo con la flecha de contorno
% escrita en otro orden.
union_cambiada(flecha, [mas, der, izq]).
union_cambiada(Tipo, Ls) :-
    union_posible(Tipo, Ls),
    Ls \== [der, mas, izq].

%!  etiquetar_cambiado(+F, +Modo, -Lineas:list) is nondet.
%
%   Como etiquetar_por_uniones/4 con el orden por vecindad, con el
%   catálogo cambiado.
etiquetar_cambiado(F, Modo, Lineas) :-
    problema(F, Modo, Lineas, Uniones0),
    ordenar(vecindad, F, Uniones0, Uniones),
    maplist(elegir_cambiada, Uniones).

%!  elegir_cambiada(+U) is nondet.
%
%   Como elegir/1, con las entradas de union_cambiada/2.
elegir_cambiada(u(_, Tipo, Vistas)) :-
    union_cambiada(Tipo, Locales),
    maplist(vista, Vistas, Locales).
