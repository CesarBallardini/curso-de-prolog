:- encoding(utf8).

% Capítulo 67 - Soluciones de los ejercicios 2 a 11.
%
% Carga la versión 5, que reexporta las anteriores, y agrega los
% predicados que piden los ejercicios. Los que modifican un predicado
% interno de una versión lo hacen sobre una copia con otro nombre.
%
% solo-local: carga módulos del capítulo, que cargan archivos de otros
% capítulos.
%
%?- lgg_lista([abuelo(juan, eva), abuelo(juan, luis), abuelo(pedro, sofia)], G).
%?- aprender_asc_corta(abuelo, H, N).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(recursion).

% Ejercicio 2

%!  lgg_lista(+Ts:list, -G) is det.
%
%   G es la lgg de todos los términos de la lista no vacía Ts: la lgg del
%   primero con el segundo, la de ese resultado con el tercero, y así.
lgg_lista([T|Ts], G) :-
    foldl(lgg_con, Ts, T, G).

% lgg_con(T, G0, G): G es la lgg de G0 y T.
lgg_con(T, G0, G) :-
    lgg(G0, T, G).

% Ejercicio 3

%!  reducida(+C0, -C) is det.
%
%   C es la cláusula C0 sin los literales redundantes: se quita un
%   literal si la cláusula actual subsume a la que queda sin él. C y C0
%   se subsumen mutuamente.
reducida((H :- B0), (H :- B)) :-
    sin_redundantes(B0, [], H, B).

%!  sin_redundantes(+Pendientes:list, +Guardados:list, +H, -B:list) is det.
%
%   B son los Guardados, en orden inverso, seguidos de los Pendientes que
%   no son redundantes.
sin_redundantes([], Guardados, _, B) :-
    reverse(Guardados, B).
sin_redundantes([L|Ls], Guardados, H, B) :-
    reverse(Guardados, G),
    append(G, [L|Ls], Actual),
    append(G, Ls, Sin),
    (   subsume((H :- Actual), (H :- Sin))
    ->  sin_redundantes(Ls, Guardados, H, B)
    ;   sin_redundantes(Ls, [L|Guardados], H, B)
    ).

% Ejercicio 4

%!  reducir_corta(+C0, +Negs:list, +M:list, -C) is semidet.
%
%   C es la más corta de las reducciones de C0 con el cuerpo en su orden y
%   en el inverso; la primera, si tienen la misma longitud. Falla si C0
%   cubre un negativo.
reducir_corta((H :- B0), Negs, M, C) :-
    reducir((H :- B0), Negs, M, C1),
    reverse(B0, B1),
    reducir((H :- B1), Negs, M, C2),
    C1 = (_ :- L1),
    C2 = (_ :- L2),
    length(L1, N1),
    length(L2, N2),
    (   N2 < N1
    ->  C = C2
    ;   C = C1
    ).

%!  aprender_asc_corta(+Relacion, -H:list, -N:integer) is det.
%
%   aprender_asc/3 con reducir_corta/4 en lugar de reducir/4.
aprender_asc_corta(Relacion, H, N) :-
    aprender_asc_con(reducir_corta, Relacion, H, N).

%!  aprender_asc_con(:Reducir, +Relacion, -H:list, -N:integer) is det.
%
%   aprender_asc/3 con el predicado Reducir, llamado como
%   call(Reducir, C0, Negs, M, C), en lugar de reducir/4.
aprender_asc_con(Reducir, Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(M),
    cubrir_con(Pos, Reducir, Negs, M, H, 0, N).

%!  cubrir_con(+Pos:list, :Reducir, +Negs:list, +M:list, -H:list,
%!             +N0:integer, -N:integer) is det.
%
%   El algoritmo de cobertura de la versión 3, con Reducir.
cubrir_con([], _, _, _, [], N, N).
cubrir_con([P|Ps], Reducir, Negs, M, H, N0, N) :-
    Pos = [P|Ps],
    findall(C0, ( append(_, [E1|Resto], Pos),
                  member(E2, Resto),
                  rlgg(E1, E2, M, C0) ),
            Rlggs),
    length(Rlggs, K),
    N1 is N0 + K,
    findall(Cubiertos-C,
            ( member(C0, Rlggs),
              call(Reducir, C0, Negs, M, C),
              include(cubre_en(C, M), Pos, Cs),
              length(Cs, Cubiertos) ),
            Candidatas),
    (   sort(1, @>=, Candidatas, [_-C|_])
    ->  exclude(cubre_en(C, M), Pos, Resto),
        H = [C|H1],
        cubrir_con(Resto, Reducir, Negs, M, H1, N1, N)
    ;   findall((E :- []), member(E, Pos), H),
        N = N1
    ).

% cubre_en(C, M, E): la cláusula C cubre el ejemplo E en el modelo M.
cubre_en(C, M, E) :-
    cubre(C, E, M).

% Ejercicio 6

% nuevos(Hechos): tomas, hijo de juan y marta, en el modelo de fondo.
nuevos([varon(tomas), padre(juan, tomas), madre(marta, tomas),
        progenitor(juan, tomas), progenitor(marta, tomas)]).

%!  modelo_con_tomas(-M:list) is det.
%
%   M es el modelo de fondo con los hechos de tomas, ordenado.
modelo_con_tomas(M) :-
    modelo_fondo(M0),
    nuevos(Nuevos),
    append(M0, Nuevos, M1),
    sort(M1, M).

%!  hermano_con_tomas(-Pos:list, -H:list, -N:integer) is det.
%
%   Pos son los positivos de hermano/2 en la familia con tomas, y H la
%   hipótesis de ascendente/5 para ellos; N es la cantidad de rlgg.
hermano_con_tomas(Pos, H, N) :-
    modelo_con_tomas(M),
    personas_de(M, Personas),
    findall(hermano(A, B),
            ( member(varon(A), M),
              member(progenitor(P, A), M),
              member(progenitor(P, B), M),
              A \== B ),
            Pos0),
    sort(Pos0, Pos),
    findall(hermano(A, B),
            ( member(A, Personas),
              member(B, Personas),
              \+ memberchk(hermano(A, B), Pos) ),
            Negs),
    ascendente(Pos, Negs, M, H, N).

%!  rlgg_con_distintos(-Hechos:integer, -Literales:integer) is det.
%
%   Hechos es la cantidad de átomos del modelo con tomas y los hechos
%   distintos(X, Y) de cada par de personas distintas, y Literales la de
%   literales enlazados de la rlgg de hermano(pedro, ana) y
%   hermano(pedro, tomas) en ese modelo.
rlgg_con_distintos(Hechos, Literales) :-
    modelo_con_tomas(M0),
    personas_de(M0, Personas),
    findall(distintos(X, Y),
            ( member(X, Personas),
              member(Y, Personas),
              X \== Y ),
            Distintos),
    append(M0, Distintos, M1),
    sort(M1, M),
    length(M, Hechos),
    rlgg(hermano(pedro, ana), hermano(pedro, tomas), M, (_ :- B)),
    length(B, Literales).

%!  personas_de(+M:list, -Personas:list) is det.
%
%   Personas son las que el modelo M declara varón o mujer, ordenadas.
personas_de(M, Personas) :-
    findall(P, ( member(varon(P), M)
               ; member(mujer(P), M) ),
            Ps),
    sort(Ps, Personas).

% Ejercicio 7

%!  generadas_sin_poda(+E, +Negs:list, +M:list, +L:list, +D:integer,
%!                     -N:integer) is det.
%
%   N es la cantidad de cláusulas que genera la búsqueda de la versión 4
%   desde la cláusula más general de E, con profundidad D, sin descartar
%   las que dejan de cubrir E: se detiene en la primera consistente que
%   cubre E.
generadas_sin_poda(E, Negs, M, L, D, N) :-
    functor(E, Nombre, Aridad),
    functor(H, Nombre, Aridad),
    sin_poda(D, (H :- []), E, Negs, M, L, _, 0, N).

%!  sin_poda(+D:integer, +C, +E, +Negs:list, +M:list, +L:list, -R,
%!           +N0:integer, -N:integer) is det.
%
%   buscar/6 de la versión 4 sin el filtro de los hijos.
sin_poda(D, C, E, Negs, M, L, R, N0, N) :-
    (   cubre(C, E, M),
        \+ cubre_alguno(C, Negs, M)
    ->  R = encontrada(C),
        N = N0
    ;   D > 0
    ->  findall(S, refinar(L, C, S), Hijos),
        length(Hijos, K),
        N1 is N0 + K,
        D1 is D - 1,
        sin_poda_en(Hijos, D1, E, Negs, M, L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).

% sin_poda_en(Cs, D, E, Negs, M, L, R, N0, N): sin_poda/9 sobre cada
% cláusula de Cs hasta encontrar una.
sin_poda_en([], _, _, _, _, _, ninguna, N, N).
sin_poda_en([C|Cs], D, E, Negs, M, L, R, N0, N) :-
    sin_poda(D, C, E, Negs, M, L, R1, N0, N1),
    (   R1 = encontrada(_)
    ->  R = R1,
        N = N1
    ;   sin_poda_en(Cs, D, E, Negs, M, L, R, N1, N)
    ).

% Ejercicio 10

%!  verdadero_ordenado(?B:list, +M:list) is nondet.
%
%   Como verdadero/2 de la versión 3, pero prueba primero el literal que
%   unifica con menos átomos de M (el primero, si empatan), y falla en
%   cuanto uno no unifica con ninguno.
verdadero_ordenado([], _).
verdadero_ordenado([L|Ls], M) :-
    findall(K-I, ( nth1(I, [L|Ls], Literal),
                   aggregate_all(count, member(Literal, M), K) ),
            Cuentas),
    min_member(Kmin-Imin, Cuentas),
    Kmin > 0,
    nth1(Imin, [L|Ls], Elegido, Resto),
    member(Elegido, M),
    verdadero_ordenado(Resto, M).

%!  cubre_ordenado(+C, +E, +M:list) is semidet.
%
%   cubre/3 con verdadero_ordenado/2.
cubre_ordenado((H :- B), E, M) :-
    \+ \+ ( H = E,
            verdadero_ordenado(B, M) ).

%!  reducir_ordenado(+C0, +Negs:list, +M:list, -C) is semidet.
%
%   reducir/4 de la versión 3 con cubre_ordenado/3.
reducir_ordenado((H :- B0), Negs, M, (H :- B)) :-
    \+ cubre_algun_ordenado((H :- B0), Negs, M),
    quitar_ordenado(B0, [], H, Negs, M, B).

% cubre_algun_ordenado(C, Negs, M): C cubre algún ejemplo de Negs.
cubre_algun_ordenado(C, Negs, M) :-
    member(N, Negs),
    cubre_ordenado(C, N, M),
    !.

% quitar_ordenado(Pendientes, Guardados, H, Negs, M, B): quitar/6 de la
% versión 3 con cubre_ordenado/3.
quitar_ordenado([], Guardados, _, _, _, B) :-
    reverse(Guardados, B).
quitar_ordenado([L|Ls], Guardados, H, Negs, M, B) :-
    reverse(Guardados, G),
    append(G, Ls, Sin),
    (   cubre_algun_ordenado((H :- Sin), Negs, M)
    ->  quitar_ordenado(Ls, [L|Guardados], H, Negs, M, B)
    ;   quitar_ordenado(Ls, Guardados, H, Negs, M, B)
    ).

% Ejercicio 11

%!  mejor_en_haz(+K:integer, +E, +Pos:list, +Negs:list, +M:list, +L:list,
%!               +Max:integer, -R, +N0:integer, -N:integer) is det.
%
%   Como mejor_clausula/9, pero solo se refinan las K cláusulas de cada
%   nivel que cubren más ejemplos de Pos.
mejor_en_haz(K, E, Pos, Negs, M, L, Max, R, N0, N) :-
    functor(E, Nombre, Aridad),
    functor(H, Nombre, Aridad),
    haz(0, K, Max, [(H :- [])], E-Pos-Negs-M-L, R, N0, N).

%!  haz(+D:integer, +K:integer, +Max:integer, +Frontera:list, +Problema,
%!      -R, +N0:integer, -N:integer) is det.
%
%   nivel/7 de la versión 5 con la frontera recortada a K cláusulas. Las
%   consistentes se buscan entre todas las cláusulas del nivel, antes de
%   recortarlo.
haz(D, K, Max, Frontera, E-Pos-Negs-M-L, R, N0, N) :-
    exclude(cubre_algun_negativo(Negs, M), Frontera, Consistentes),
    (   Consistentes = [_|_]
    ->  mejores(Consistentes, Pos, M, [C|_]),
        R = encontrada(C),
        N = N0
    ;   D < Max
    ->  mejores(Frontera, Pos, M, Ordenadas),
        primeros(K, Ordenadas, Haz),
        findall(S, ( member(C0, Haz),
                     refinar(L, C0, S) ),
                Todos),
        length(Todos, T),
        N1 is N0 + T,
        include(cubre_ej(E, M), Todos, Siguiente),
        D1 is D + 1,
        haz(D1, K, Max, Siguiente, E-Pos-Negs-M-L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).

% cubre_algun_negativo(Negs, M, C): C cubre un ejemplo de Negs.
cubre_algun_negativo(Negs, M, C) :-
    cubre_alguno(C, Negs, M).

% cubre_ej(E, M, C): la cláusula C cubre el ejemplo E.
cubre_ej(E, M, C) :-
    cubre(C, E, M).

%!  mejores(+Cs:list, +Pos:list, +M:list, -Ordenadas:list) is det.
%
%   Ordenadas son las cláusulas de Cs de la que cubre más ejemplos de Pos
%   a la que cubre menos; las que cubren lo mismo, en su orden.
mejores(Cs, Pos, M, Ordenadas) :-
    findall(P-C, ( member(C, Cs),
                   include(cubre_en(C, M), Pos, Cubiertos),
                   length(Cubiertos, P) ),
            Pares),
    sort(1, @>=, Pares, Ordenados),
    findall(C, member(_-C, Ordenados), Ordenadas).

%!  primeros(+K:integer, +Xs:list, -Ys:list) is det.
%
%   Ys son los primeros K elementos de Xs, o todos si son menos.
primeros(K, Xs, Ys) :-
    length(Xs, N),
    (   N =< K
    ->  Ys = Xs
    ;   length(Ys, K),
        append(Ys, _, Xs)
    ).

%!  aprender_haz(+K:integer, +Relacion, -H:list, -N:integer) is det.
%
%   aprender_rec/3 con la búsqueda en haz de ancho K.
aprender_haz(K, Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(Fondo),
    ord_union(Fondo, Pos, M),
    lenguaje(L0),
    append(L0, [Relacion/2], L),
    cubrir_haz(Pos, K, Negs, M, L, H, 0, N).

%!  cubrir_haz(+Pos:list, +K:integer, +Negs:list, +M:list, +L:list,
%!             -H:list, +N0:integer, -N:integer) is det.
%
%   El algoritmo de cobertura de la versión 5 con mejor_en_haz/10.
cubrir_haz([], _, _, _, _, [], N, N).
cubrir_haz([E|Es], K, Negs, M, L, [C|H], N0, N) :-
    mejor_en_haz(K, E, Es, Negs, M, L, 3, R, N0, N1),
    (   R = encontrada(C)
    ->  exclude(cubre_en(C, M), Es, Resto)
    ;   C = (E :- []),
        Resto = Es
    ),
    cubrir_haz(Resto, K, Negs, M, L, H, N1, N).

%!  reducir_antepasado(:Reducir, -C) is semidet.
%
%   C es la rlgg de antepasado(juan, luis) y antepasado(pedro, sofia),
%   con los positivos en el modelo, reducida con Reducir.
reducir_antepasado(Reducir, C) :-
    ejemplos(antepasado, Pos, Negs),
    modelo_fondo(Fondo),
    ord_union(Fondo, Pos, M),
    rlgg(antepasado(juan, luis), antepasado(pedro, sofia), M, C0),
    call(Reducir, C0, Negs, M, C).
