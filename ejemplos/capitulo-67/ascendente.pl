:- encoding(utf8).

% Capítulo 67 - Versión 3: inducción ascendente con la lgg relativa.
%
% La lgg relativa (rlgg) de dos ejemplos positivos E1 y E2 respecto de un
% modelo M, una lista de átomos sin variables, es la lgg de las cláusulas
% E1 :- M y E2 :- M. El resultado tiene un literal por cada par de átomos
% del mismo predicado; se eliminan los literales sin variables, que son
% verdaderos en M, y los que no están enlazados con la cabeza por una
% cadena de variables compartidas. reducir/4 quita después cada literal
% cuya ausencia no hace cubrir un ejemplo negativo. La cobertura es
% extensional: un ejemplo está cubierto por una cláusula si la cabeza
% unifica con él y el cuerpo es verdadero en M.
%
% El algoritmo de cobertura prueba la rlgg de cada par de positivos
% todavía no cubiertos, se queda con la cláusula consistente que cubre
% más, quita los positivos cubiertos y repite. Los positivos que ninguna
% cláusula cubre quedan como hechos. extension/3 calcula qué átomos de la
% relación se deducen de la hipótesis junto con el conocimiento de fondo:
% el modelo mínimo del capítulo 38.
%
% solo-local: carga familia.pl, que carga archivos de otros capítulos.
%
%?- rlgg_de(abuelo, 1, 3, C), mostrar(C).
%?- aprender_asc(abuelo, H, N), maplist(mostrar, H).

:- module(ascendente,
          [ rlgg/4,
            rlgg_de/4,
            reducida_de/5,
            enlazados/3,
            cubre/3,
            cubre_alguno/3,
            reducir/4,
            ascendente/5,
            aprender_asc/3,
            extension/3,
            evaluar/5
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(subsuncion).
:- reexport(familia).

%!  rlgg(+E1, +E2, +M:list, -C) is det.
%
%   C es la lgg de E1 :- M y E2 :- M sin los literales sin variables, sin
%   la propia cabeza y sin los literales que no están enlazados con la
%   cabeza.
rlgg(E1, E2, M, (H :- B)) :-
    lgg_clausula((E1 :- M), (E2 :- M), (H :- B0)),
    exclude(ground, B0, B1),
    exclude(==(H), B1, B2),
    enlazados(H, B2, B).

%!  rlgg_de(+Relacion, +I:integer, +J:integer, -C) is det.
%
%   C es la rlgg de los ejemplos positivos número I y J de Relacion,
%   relativa al modelo de fondo de la familia.
rlgg_de(Relacion, I, J, C) :-
    ejemplos(Relacion, Pos, _),
    nth1(I, Pos, E1),
    nth1(J, Pos, E2),
    modelo_fondo(M),
    rlgg(E1, E2, M, C).

%!  reducida_de(+Relacion, +I:integer, +J:integer, +Orden, -C) is semidet.
%
%   C es rlgg_de/4 reducida con los negativos de Relacion, probando los
%   literales en el orden del cuerpo (Orden = directo) o en el inverso
%   (Orden = inverso). Falla si la rlgg cubre un negativo.
reducida_de(Relacion, I, J, Orden, C) :-
    rlgg_de(Relacion, I, J, (H :- B0)),
    ordenar(Orden, B0, B),
    ejemplos(Relacion, _, Negs),
    modelo_fondo(M),
    reducir((H :- B), Negs, M, C).

% ordenar(Orden, B0, B): B es B0 en el orden pedido.
ordenar(directo, B, B).
ordenar(inverso, B0, B) :-
    reverse(B0, B).

%!  enlazados(+H, +B0:list, -B:list) is det.
%
%   B son los literales de B0, en su orden, enlazados con la cabeza H: los
%   que comparten una variable con H o con otro literal enlazado.
enlazados(H, B0, B) :-
    term_variables(H, Vs0),
    cerrar_variables(B0, Vs0, Vs),
    include(comparte(Vs), B0, B).

%!  cerrar_variables(+B:list, +Vs0:list, -Vs:list) is det.
%
%   Vs son las variables de Vs0 más las de todo literal de B que comparte
%   una variable con ellas, repetido hasta que no se agrega ninguna.
cerrar_variables(B, Vs0, Vs) :-
    include(comparte(Vs0), B, Enlazados),
    term_variables(Vs0-Enlazados, Vs1),
    length(Vs0, N0),
    length(Vs1, N1),
    (   N1 =:= N0
    ->  Vs = Vs0
    ;   cerrar_variables(B, Vs1, Vs)
    ).

%!  comparte(+Vs:list, @L) is semidet.
%
%   El término L tiene alguna de las variables de Vs.
comparte(Vs, L) :-
    term_variables(L, LVs),
    member(V, LVs),
    member(W, Vs),
    V == W,
    !.

%!  cubre(+C, +E, +M:list) is semidet.
%
%   La cláusula C cubre el ejemplo E en forma extensional: la cabeza de C
%   unifica con E y todos los literales del cuerpo son verdaderos en M, con
%   una misma sustitución. Nada queda ligado.
cubre((H :- B), E, M) :-
    \+ \+ ( H = E,
            verdadero(B, M) ).

%!  verdadero(?B:list, +M:list) is nondet.
%
%   Cada literal de B unifica con un átomo de M.
verdadero([], _).
verdadero([L|Ls], M) :-
    member(L, M),
    verdadero(Ls, M).

%!  cubre_alguno(+C, +Negs:list, +M:list) is semidet.
%
%   La cláusula C cubre alguno de los ejemplos de Negs.
cubre_alguno(C, Negs, M) :-
    member(N, Negs),
    cubre(C, N, M),
    !.

%!  reducir(+C0, +Negs:list, +M:list, -C) is semidet.
%
%   C es la cláusula C0 sin los literales que se pueden quitar sin cubrir
%   un ejemplo de Negs, probados de a uno en el orden del cuerpo. Falla si
%   C0 ya cubre un ejemplo negativo.
reducir((H :- B0), Negs, M, (H :- B)) :-
    \+ cubre_alguno((H :- B0), Negs, M),
    quitar(B0, [], H, Negs, M, B).

%!  quitar(+Pendientes:list, +Guardados:list, +H, +Negs:list, +M:list,
%!         -B:list) is det.
%
%   B son los literales de Guardados, en orden inverso, seguidos de los de
%   Pendientes que no se pueden quitar: un literal se quita si la cláusula
%   con los guardados y los pendientes que le siguen no cubre ningún
%   negativo.
quitar([], Guardados, _, _, _, B) :-
    reverse(Guardados, B).
quitar([L|Ls], Guardados, H, Negs, M, B) :-
    reverse(Guardados, G),
    append(G, Ls, Sin),
    (   cubre_alguno((H :- Sin), Negs, M)
    ->  quitar(Ls, [L|Guardados], H, Negs, M, B)
    ;   quitar(Ls, Guardados, H, Negs, M, B)
    ).

%!  ascendente(+Pos:list, +Negs:list, +M:list, -H:list, -N:integer) is det.
%
%   H es la hipótesis que el algoritmo de cobertura construye con rlgg
%   para los ejemplos Pos y Negs, relativa al modelo M, y N es la cantidad
%   de cláusulas candidatas que calcula.
ascendente(Pos, Negs, M, H, N) :-
    cubrir(Pos, Negs, M, H, 0, N).

%!  cubrir(+Pos:list, +Negs:list, +M:list, -H:list, +N0:integer,
%!         -N:integer) is det.
%
%   H cubre los positivos Pos; N0 y N cuentan las candidatas.
cubrir([], _, _, [], N, N).
cubrir([P|Ps], Negs, M, H, N0, N) :-
    Pos = [P|Ps],
    candidatas(Pos, Negs, M, Candidatas, K),
    N1 is N0 + K,
    (   sort(1, @>=, Candidatas, [_-C|_])
    ->  exclude(cubierto(C, M), Pos, Resto),
        H = [C|H1],
        cubrir(Resto, Negs, M, H1, N1, N)
    ;   maplist(hecho, Pos, H),
        N = N1
    ).

%!  candidatas(+Pos:list, +Negs:list, +M:list, -Candidatas:list,
%!             -K:integer) is det.
%
%   Candidatas son los pares Cubiertos-C de cada rlgg C de dos ejemplos de
%   Pos que, reducida, no cubre ningún negativo, con la cantidad de
%   positivos que cubre; K es la cantidad de rlgg calculadas.
candidatas(Pos, Negs, M, Candidatas, K) :-
    findall(C0, ( append(_, [E1|Resto], Pos),
                  member(E2, Resto),
                  rlgg(E1, E2, M, C0) ),
            Rlggs),
    length(Rlggs, K),
    findall(Cubiertos-C,
            ( member(C0, Rlggs),
              reducir(C0, Negs, M, C),
              include(cubierto(C, M), Pos, Cs),
              length(Cs, Cubiertos) ),
            Candidatas).

% cubierto(C, M, E): la cláusula C cubre el ejemplo E en el modelo M.
cubierto(C, M, E) :-
    cubre(C, E, M).

% hecho(E, E :- []): un ejemplo sin cubrir queda como hecho.
hecho(E, (E :- [])).

%!  aprender_asc(+Relacion, -H:list, -N:integer) is det.
%
%   H es la hipótesis que la inducción ascendente construye para Relacion
%   con sus ejemplos y el modelo de fondo de la familia; N es la cantidad
%   de rlgg calculadas.
aprender_asc(Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(M),
    ascendente(Pos, Negs, M, H, N).

%!  extension(+Relacion, +H:list, -Atomos:list) is det.
%
%   Atomos son los átomos de Relacion en el modelo mínimo del
%   conocimiento de fondo junto con las cláusulas de H: lo que la
%   hipótesis permite deducir. Las cláusulas de H deben tener en el
%   cuerpo todas las variables de la cabeza.
extension(Relacion, H, Atomos) :-
    clausulas_fondo(Fondo),
    maplist(como_regla, H, Reglas),
    append(Fondo, Reglas, Programa),
    modelo_minimo_de(Programa, Modelo),
    include(de_relacion(Relacion), Modelo, Atomos).

% de_relacion(R, A): el átomo A es de la relación R.
de_relacion(Relacion, Atomo) :-
    functor(Atomo, Relacion, _).

%!  evaluar(+Relacion, +H:list, -Aciertos:integer,
%!          -FalsosPositivos:integer, -FalsosNegativos:integer) is det.
%
%   Compara la extensión de la hipótesis H con la definición esperada de
%   Relacion: Aciertos son los átomos en las dos, FalsosPositivos los que
%   H deduce y no se esperan, FalsosNegativos los esperados que H no
%   deduce.
evaluar(Relacion, H, Aciertos, FalsosPositivos, FalsosNegativos) :-
    extension(Relacion, H, Deducidos),
    ejemplos(Relacion, Pos, _),
    ord_intersection(Deducidos, Pos, Comunes),
    ord_subtract(Deducidos, Pos, Sobran),
    ord_subtract(Pos, Deducidos, Faltan),
    length(Comunes, Aciertos),
    length(Sobran, FalsosPositivos),
    length(Faltan, FalsosNegativos).
