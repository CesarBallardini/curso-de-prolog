:- encoding(utf8).

% Capítulo 38 - Soluciones de los ejercicios 1, 2, 3, 9, 10, 11, 12, 13 y
% 14: modelos, base de Herbrand, estratos, semántica bien fundada, modelos
% estables y evaluación semi-ingenua. Usa los evaluadores de semantica.pl,
% y nombra con generado/2 los programas que construye como datos.
%
% solo-local: carga semantica.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- modelos(lluvia, [calle_mojada, llueve, riego], Ms).
%?- base_herbrand(lluvia, B).
%?- bien_fundado(paridad, V, I).
%?- estables_de([(p :- \+ q), (q :- \+ p)], Ms).

:- ensure_loaded(semantica).

:- multifile generado/2.

%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de estas soluciones: paridad, juego(Juego) (los
%   movimientos de Juego solamente), alcanzables(N) y cadena_doble(N).
generado(paridad, Clausulas) :-
    paridad(Clausulas).
generado(juego(Juego), Clausulas) :-
    del_juego(Juego, Clausulas).
generado(alcanzables(N), Clausulas) :-
    alcanzables(N, Clausulas).
generado(cadena_doble(N), Clausulas) :-
    cadena_doble(N, Clausulas).

%!  modelos_de(+Clausulas:list, +Atomos:list, -Modelos:list) is det.
%
%   Modelos son los subconjuntos de Atomos que son modelos de Clausulas,
%   cada uno ordenado, en el orden en que subconjunto/2 los genera.
modelos_de(Clausulas, Atomos, Modelos) :-
    findall(I,
            ( subconjunto(Atomos, I),
              es_modelo_de(Clausulas, I) ),
            Modelos).

%!  modelos(+Programa, +Atomos:list, -Modelos:list) is det.
%
%   modelos_de/3 con las cláusulas del programa llamado Programa.
modelos(Programa, Atomos, Modelos) :-
    clausulas(Programa, Clausulas),
    modelos_de(Clausulas, Atomos, Modelos).

%!  subconjunto(+Conjunto:list, -Sub:list) is multi.
%
%   Sub es un subconjunto de Conjunto, con los elementos en el mismo orden.
%   Una respuesta por subconjunto: primero los que tienen el primer
%   elemento.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).

%!  minimales(+Modelos:list, -Minimales:list) is det.
%
%   Minimales son los de Modelos que no contienen estrictamente a ningún
%   otro de Modelos.
minimales(Modelos, Minimales) :-
    include(minimal(Modelos), Modelos, Minimales).

%!  minimal(+Modelos:list, +M:list) is semidet.
%
%   Ningún otro de Modelos está contenido en M.
minimal(Modelos, M) :-
    \+ ( member(N, Modelos),
         N \== M,
         ord_subset(N, M) ).

%!  base_herbrand_de(+Clausulas:list, -Base:list) is det.
%
%   Base es la base de Herbrand de Clausulas, un programa sin functores: los
%   átomos que se forman con sus predicados y sus constantes, ordenados.
base_herbrand_de(Clausulas, Base) :-
    findall(C, ( member(Clausula, Clausulas),
                 constante(Clausula, C) ),
            Cs0),
    sort(Cs0, Constantes),
    findall(P, ( member(Clausula, Clausulas),
                 atomo_de(Clausula, A),
                 indicador(A, P) ),
            Ps0),
    sort(Ps0, Predicados),
    findall(Atomo,
            ( member(Nombre/Aridad, Predicados),
              length(Argumentos, Aridad),
              maplist(elegida(Constantes), Argumentos),
              Atomo =.. [Nombre|Argumentos] ),
            Base0),
    sort(Base0, Base).

%!  base_herbrand(+Programa, -Base:list) is det.
%
%   Base es la base de Herbrand del programa llamado Programa.
base_herbrand(Programa, Base) :-
    clausulas(Programa, Clausulas),
    base_herbrand_de(Clausulas, Base).

%!  atomo_de(+Clausula, -Atomo) is nondet.
%
%   Atomo es la cabeza de Clausula o un átomo de su cuerpo, positivo o
%   negado; las comparaciones no cuentan.
atomo_de(Cabeza :- _, Cabeza).
atomo_de(_ :- Cuerpo, Atomo) :-
    conjuncion_lista(Cuerpo, Literales),
    member(Literal, Literales),
    (   Literal = (\+ Atomo)
    ->  true
    ;   atomo(Literal),
        Atomo = Literal
    ).

%!  constante(+Clausula, -C) is nondet.
%
%   C es un argumento sin variables de un átomo de Clausula.
constante(Clausula, C) :-
    atomo_de(Clausula, Atomo),
    Atomo =.. [_|Argumentos],
    member(C, Argumentos),
    atomic(C).

%!  elegida(+Constantes:list, -C) is nondet.
%
%   C es una de Constantes.
elegida(Constantes, C) :-
    member(C, Constantes).

%!  paridad(-Clausulas:list) is det.
%
%   Clausulas es el programa del ejercicio 10: par/1 sobre los números del
%   0 al 6, con sigue/2.
paridad(Clausulas) :-
    findall(sigue(M, N) :- true,
            ( between(1, 6, N),
              M is N - 1 ),
            Hechos),
    append([ [ (par(0) :- true),
               (par(N) :- sigue(M, N), \+ par(M)) ],
             Hechos ],
           Clausulas).

%!  alternancia_de(+Clausulas:list, -Pasos:list) is det.
%
%   Pasos son los pares V-P del punto fijo alternado, desde V vacío: los
%   verdaderos de cada paso y los posibles que se calculan con ellos, hasta
%   que los verdaderos no cambian.
alternancia_de(Clausulas, Pasos) :-
    alternancia_de(Clausulas, [], Pasos).

%!  alternancia_de(+Clausulas:list, +V0:list, -Pasos:list) is det.
%
%   Pasos son los pares V-P del punto fijo alternado, desde los verdaderos
%   V0.
alternancia_de(Clausulas, V0, [V0-P0|Pasos]) :-
    reducido(Clausulas, V0, P0),
    reducido(Clausulas, P0, V1),
    (   V1 == V0
    ->  Pasos = []
    ;   alternancia_de(Clausulas, V1, Pasos)
    ).

%!  alternancia(+Programa, -Pasos:list) is det.
%
%   alternancia_de/2 con las cláusulas del programa llamado Programa.
alternancia(Programa, Pasos) :-
    clausulas(Programa, Clausulas),
    alternancia_de(Clausulas, Pasos).

%!  estables_de(+Clausulas:list, -Modelos:list) is det.
%
%   Modelos son los modelos estables de Clausulas: los M tales que el
%   modelo reducido con las negaciones evaluadas contra M es M. Los
%   candidatos son los subconjuntos de lo posible, reducido(Clausulas, [],
%   P).
estables_de(Clausulas, Modelos) :-
    reducido(Clausulas, [], Posibles),
    findall(M,
            ( subconjunto(Posibles, M),
              reducido(Clausulas, M, M) ),
            Modelos).

%!  estables(+Programa, -Modelos:list) is det.
%
%   Modelos son los modelos estables del programa llamado Programa.
estables(Programa, Modelos) :-
    clausulas(Programa, Clausulas),
    estables_de(Clausulas, Modelos).

%!  del_juego(+Juego, -Clausulas:list) is det.
%
%   Clausulas son las del programa juego con los movimientos de Juego
%   solamente.
del_juego(Juego, Clausulas) :-
    clausulas(juego, Todas),
    exclude(de_otro_juego(Juego), Todas, Clausulas).

%!  de_otro_juego(+Juego, +Clausula) is semidet.
%
%   Clausula es un movimiento de un juego distinto de Juego.
de_otro_juego(Juego, mueve(Otro, _, _) :- true) :-
    Otro \== Juego.

%!  alcanzables(+N:integer, -Clausulas:list) is det.
%
%   Clausulas son las de alcanza/1, los nodos a los que se llega desde el 0,
%   sobre los N arcos en fila de cadena/2.
alcanzables(N, Clausulas) :-
    cadena(N, Cadena),
    include(es_arco, Cadena, Arcos),
    append(Arcos,
           [ (alcanza(Y) :- arco(0, Y)),
             (alcanza(Y) :- alcanza(Z), arco(Z, Y)) ],
           Clausulas).

%!  es_arco(+Clausula) is semidet.
%
%   Clausula es un hecho arco/2.
es_arco(arco(_, _) :- true).

%!  semi_ingenua_estricta_de(+Clausulas:list, +I0:list, -M:list,
%!                            -Costo) is det.
%
%   El mismo M que semi_ingenua_de/4, sin derivaciones repetidas: en cada
%   paso, una derivación se cuenta en la primera posición del cuerpo que usa
%   un átomo nuevo. Los átomos anteriores se toman de los viejos, y los
%   posteriores de todos.
semi_ingenua_estricta_de(Clausulas, I0, M, Costo) :-
    derivar(Clausulas, I0, I0, Cabezas),
    length(Cabezas, D),
    sort(Cabezas, T),
    ord_subtract(T, I0, Nuevos),
    ord_union(I0, Nuevos, I1),
    estricta(Clausulas, I0, I1, Nuevos, M, costo(1, D), Costo).

%!  semi_ingenua_estricta(+Programa, +I0:list, -M:list, -Costo) is det.
%
%   semi_ingenua_estricta_de/4 con las cláusulas del programa llamado
%   Programa.
semi_ingenua_estricta(Programa, I0, M, Costo) :-
    clausulas(Programa, Clausulas),
    semi_ingenua_estricta_de(Clausulas, I0, M, Costo).

%!  estricta(+Clausulas:list, +Viejos:list, +I:list, +Nuevos:list, -M:list,
%!           +Costo0, -Costo) is det.
%
%   Continúa la evaluación estricta desde I: Viejos es la interpretación del
%   paso anterior, y Nuevos los átomos que ese paso agregó. Costo0 es el
%   costo acumulado hasta aquí, y Costo el total al llegar a M.
estricta(Clausulas, Viejos, I, Nuevos, M, costo(P0, D0), Costo) :-
    (   Nuevos == []
    ->  M = I,
        Costo = costo(P0, D0)
    ;   findall(Cabeza,
                ( member(Cabeza :- Cuerpo, Clausulas),
                  conjuncion_lista(Cuerpo, Literales),
                  append(Antes, [Literal|Despues], Literales),
                  atomo(Literal),
                  member(Literal, Nuevos),
                  viejos(Antes, Viejos, I),
                  cumple_todos(Despues, I),
                  must_be(ground, Cabeza) ),
                Cabezas),
        length(Cabezas, D),
        P is P0 + 1,
        D1 is D0 + D,
        sort(Cabezas, T),
        ord_subtract(T, I, Nuevos1),
        ord_union(I, Nuevos1, I1),
        estricta(Clausulas, I, I1, Nuevos1, M, costo(P, D1), Costo)
    ).

%!  viejos(+Literales:list, +Viejos:list, +I:list) is nondet.
%
%   Cada uno de Literales es verdadero con sus átomos en Viejos; los
%   negados se evalúan contra I.
viejos([], _, _).
viejos([L|Ls], Viejos, I) :-
    cumple(L, Viejos, I),
    viejos(Ls, Viejos, I).

%!  cadena_doble(+N:integer, -Clausulas:list) is det.
%
%   Clausulas son los N arcos en fila de cadena/2 con camino/2 definido por
%   dos llamadas recursivas.
cadena_doble(N, Clausulas) :-
    cadena(N, Cadena),
    include(es_arco, Cadena, Arcos),
    append(Arcos,
           [ (camino(X, Y) :- arco(X, Y)),
             (camino(X, Y) :- camino(X, Z), camino(Z, Y)) ],
           Clausulas).
