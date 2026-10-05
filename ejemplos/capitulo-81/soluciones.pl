:- encoding(utf8).

% Capítulo 81 - Soluciones de los ejercicios.
%
% Carga triangulo.pl, moleculas.pl, estampillas.pl, transito.pl,
% marcos.pl y rimas.pl sin modificarlos. Los problemas nuevos del
% triángulo se resuelven con buscar/5 del capítulo 40, que triangulo.pl
% reexporta: se escriben user:Problema, y sus inicial/2, meta/2 y
% sucesor/5 están en este archivo. La molécula del ejercicio 6 se agrega a
% molecula/3, que es multifile.
%
% solo-local: carga otros archivos.
%
%?- terminar_en(1, Saltos, K).
%?- cuenta_desde(1, N).
%?- triangulo4(2, Saltos).
%?- conflictos(auto, C).

:- use_module(triangulo).
:- ensure_loaded(moleculas).
:- ensure_loaded(estampillas).
:- ensure_loaded(transito).
:- ensure_loaded(marcos).
:- ensure_loaded(rimas).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(pairs)).

% --- Los problemas del triángulo para buscar/5 --------------------------

%!  inicial(+Problema, -T) is det.
%
%   T es la posición de partida de Problema: en_su_agujero(V) y
%   bloqueada(V, K) empiezan con el agujero V vacío.
inicial(en_su_agujero(V), T) :-
    inicio(V, T).
inicial(bloqueada(V, _), T) :-
    inicio(V, T).

%!  meta(+Problema, +T) is semidet.
%
%   Con en_su_agujero(V), T tiene una sola clavija, en el agujero V. Con
%   bloqueada(_, K), T tiene K clavijas y ningún salto.
meta(en_su_agujero(V), T) :-
    clavijas(T, 1),
    arg(V, T, 1).
meta(bloqueada(_, K), T) :-
    clavijas(T, K),
    \+ salto(_, T, _).

%!  sucesor(+Problema, +T0, -Salto, -T, -Costo:integer) is nondet.
%
%   Salto lleva de T0 a T, con costo 1, en los dos problemas.
sucesor(en_su_agujero(_), T0, S, T, 1) :-
    salto(S, T0, T).
sucesor(bloqueada(_, _), T0, S, T, 1) :-
    salto(S, T0, T).

% --- Ejercicio 2: terminar en el agujero del comienzo -------------------

%!  terminar_en(+Vacio:integer, -Saltos:list, -Expandidos:integer)
%!      is semidet.
%
%   Saltos empieza con el agujero Vacio sin clavija y deja una sola, en
%   ese mismo agujero; Expandidos son las posiciones que expandió la
%   búsqueda en profundidad con registro de visitados.
terminar_en(Vacio, Saltos, Expandidos) :-
    buscar(profundidad, user:en_su_agujero(Vacio), Saltos, _, Expandidos).

% --- Ejercicio 3: posiciones bloqueadas --------------------------------

%!  bloqueo(+Vacio:integer, +K:integer, -Saltos:list) is semidet.
%
%   Saltos empieza con el agujero Vacio sin clavija y deja K clavijas sin
%   ningún salto posible.
bloqueo(Vacio, K, Saltos) :-
    buscar(profundidad, user:bloqueada(Vacio, K), Saltos, _, _).

%!  mayor_bloqueo(+Vacio:integer, -K:integer) is det.
%
%   K es la mayor cantidad de clavijas que pueden quedar sin ningún salto
%   posible, empezando con el agujero Vacio sin clavija.
mayor_bloqueo(Vacio, K) :-
    once(( between(1, 13, I),
           K is 14 - I,
           bloqueo(Vacio, K, _) )).

% --- Ejercicio 4: contar las soluciones ---------------------------------

%!  cuenta_desde(+Vacio:integer, -N:integer) is det.
%
%   N es la cantidad de soluciones, sucesiones de saltos que dejan una
%   sola clavija, cuando se empieza con el agujero Vacio sin clavija.
cuenta_desde(Vacio, N) :-
    inicio(Vacio, T),
    cuenta(T, N).

%!  cuenta(+T, -N:integer) is det.
%
%   N es la cantidad de soluciones desde la posición T. Las imágenes de
%   una posición tienen las mismas, así que la tabla se lleva por formas.
cuenta(T, N) :-
    forma(T, F),
    cuenta_forma(F, N).

:- table cuenta_forma/2.

%!  cuenta_forma(+F, -N:integer) is det.
%
%   cuenta/2 para una forma: 1 con una sola clavija; si no, la suma de
%   las soluciones desde cada posición que deja un salto.
cuenta_forma(F, N) :-
    (   clavijas(F, 1)
    ->  N = 1
    ;   aggregate_all(sum(K), ( salto(_, F, T), cuenta(T, K) ), N)
    ).

% --- Ejercicio 5: el triángulo de diez agujeros -------------------------

%!  agujero4(?N:integer, ?F:integer, ?C:integer) is nondet.
%
%   El agujero N, de 1 a 10, es el C-ésimo de la fila F, de 1 a 4.
agujero4(N, F, C) :-
    between(1, 4, F),
    between(1, F, C),
    N is F * (F - 1) // 2 + C.

%!  linea4(?A:integer, ?B:integer, ?C:integer) is nondet.
%
%   A, B y C son tres agujeros seguidos en línea recta en el triángulo de
%   cuatro filas.
linea4(A, B, C) :-
    agujero4(A, F, K),
    member(DF-DK, [0-1, 1-0, 1-1]),
    F1 is F + DF,
    K1 is K + DK,
    F2 is F1 + DF,
    K2 is K1 + DK,
    agujero4(B, F1, K1),
    agujero4(C, F2, K2).

%!  salto4(+P0:list, -Salto, -P:list) is nondet.
%
%   P0 y P son los conjuntos ordenados de los agujeros con clavija antes y
%   después de Salto, s(De, Sobre, Hasta).
salto4(P0, s(De, Sobre, Hasta), P) :-
    (   linea4(De, Sobre, Hasta)
    ;   linea4(Hasta, Sobre, De)
    ),
    ord_memberchk(De, P0),
    ord_memberchk(Sobre, P0),
    \+ ord_memberchk(Hasta, P0),
    list_to_ord_set([De, Sobre], Saltadas),
    ord_subtract(P0, Saltadas, P1),
    ord_add_element(P1, Hasta, P).

%!  triangulo4(+Vacio:integer, -Saltos:list) is nondet.
%
%   Saltos resuelve el triángulo de diez agujeros que empieza con el
%   agujero Vacio sin clavija.
triangulo4(Vacio, Saltos) :-
    numlist(1, 10, Todos),
    ord_del_element(Todos, Vacio, P),
    resolver4(P, Saltos).

%!  resolver4(+P:list, -Saltos:list) is nondet.
%
%   Saltos lleva del conjunto de clavijas P a una sola clavija.
resolver4([_], []).
resolver4(P0, [S|Ss]) :-
    P0 = [_, _|_],
    salto4(P0, S, P),
    resolver4(P, Ss).

% --- Ejercicio 6: el naftaleno ----------------------------------------

molecula(naftaleno,
         [ carbono-[c1, c2, c3, c4, c5, c6, c7, c8, c9, c10],
           hidrogeno-[h1, h2, h3, h4, h5, h6, h7, h8]
         ],
         [ c1-c2, c2-c3, c3-c4, c4-c9, c9-c10, c10-c1,
           c9-c5, c5-c6, c6-c7, c7-c8, c8-c10,
           c1-h1, c2-h2, c3-h3, c4-h4, c5-h5, c6-h6, c7-h7, c8-h8 ]).

% --- Ejercicio 7: el valor de la colección ------------------------------

%!  valor_total(?Patron, -Total:integer) is det.
%
%   Total es la suma de los valores de los sellos del álbum que unifican
%   con Patron.
valor_total(Patron, Total) :-
    coleccion(Patron, Sellos),
    foldl(sumar_valor, Sellos, 0, Total).

%!  sumar_valor(+Sello, +T0:integer, -T:integer) is det.
%
%   T es T0 más el valor de Sello.
sumar_valor(sello(_, _, _, V), T0, T) :-
    T is T0 + V.

%!  por_pais(-Pares:list) is det.
%
%   Pares tiene un par Pais-Total por cada país del álbum, en orden, con
%   el valor total de sus sellos.
por_pais(Pares) :-
    coleccion(sello(_, _, _, _), Sellos),
    findall(P, member(sello(P, _, _, _), Sellos), Paises0),
    sort(Paises0, Paises),
    findall(P-T,
            ( member(P, Paises),
              valor_total(sello(P, _, _, _), T) ),
            Pares).

% --- Ejercicio 9: dos luces a la vez -----------------------------------

%!  conflictos(+Quien, -Conflictos:list) is det.
%
%   Conflictos son las situaciones con dos luces para los autos, de tipos
%   distintos, en las que accion/3 da a Quien detenerse y también una
%   acción que avanza, con Frenar si o no. Cada conflicto es
%   Luz1+Luz2-Frenar-Acciones.
conflictos(Quien, Conflictos) :-
    findall(luz(T1, E1)+luz(T2, E2)-F-As,
            ( vehicular(T1, E1),
              vehicular(T2, E2),
              T1 @< T2,
              member(F, [si, no]),
              situacion(luz(T1, E1), F, S0),
              S = [luz(T2, E2)|S0],
              findall(A, accion(S, Quien, A), As),
              memberchk(detenerse, As),
              once(( member(A1, As),
                     A1 \== detenerse,
                     A1 \== detenerse_y_avanzar )) ),
            Conflictos).

%!  cuenta_conflictos(+Quien, -N:integer, -K:integer) is det.
%
%   N es la cantidad de conflictos de Quien, y K la de aquellos en los que
%   la primera acción, la que elige decision/3, no es detenerse.
cuenta_conflictos(Quien, N, K) :-
    conflictos(Quien, Conflictos),
    length(Conflictos, N),
    aggregate_all(count,
                  ( member(_-_-[A|_], Conflictos),
                    A \== detenerse ),
                  K).

% --- Ejercicio 10: el peatón de Rowe -----------------------------------

%!  peaton_v3(+Situacion:list, ?Accion) is nondet.
%
%   Como peaton/2, pero la señal de paso deja cruzar cediendo el paso
%   también cuando está intermitente, como pide el ejemplo de Rowe.
peaton_v3(S, A) :-
    (   peaton(S, A)
    ;   paso_peaton(S, intermitente),
        A = ceder_y_avanzar
    ).

%!  accion_v3(+Situacion:list, +Quien, ?Accion) is nondet.
%
%   Como accion/3, con peaton_v3/2 en lugar de peaton/2.
accion_v3(S, auto, A) :-
    accion(S, auto, A).
accion_v3(S, peaton, A) :-
    (   peaton_v3(S, _)
    ->  peaton_v3(S, A)
    ;   \+ senales_peaton(S),
        \+ verde_de_frente(S)
    ->  accion(S, auto, A)
    ;   A = avanzar
    ).

% --- Ejercicio 11: las partes heredadas --------------------------------

%!  partes(+Objeto, -Partes:list) is det.
%
%   Partes son las partes del marco Objeto: las propias y las de las
%   clases más generales por es_un, sin repetir y en orden.
partes(O, Partes) :-
    findall(P,
            ( es_un_de(O, Clase),
              propio(Clase, tiene_parte, P) ),
            Ps),
    sort(Ps, Partes).

% --- Ejercicio 12: un hombre fue a segar --------------------------------

%!  esqueleto(+N:integer, -Lista:list) is det.
%
%   Lista es [N, N-1, ..., 1].
esqueleto(N, Lista) :-
    numlist(1, N, Ascendente),
    reverse(Ascendente, Lista).

%!  estrofa_segar(+N:integer, -Lineas:list) is semidet.
%
%   Lineas son los versos de la estrofa N, de 1 a 99, de la canción en la
%   que N hombres fueron a segar: el tercer verso cuenta hacia atrás desde
%   N hasta un hombre y su perro.
estrofa_segar(N, [L1, L2, L3, L4]) :-
    hombres(N, Hombres0),
    mayuscula_inicial(Hombres0, Hombres),
    numero_gramatical(N, Num),
    fue(Num, Fue),
    format(string(L1), "~w ~w a segar,", [Hombres, Fue]),
    format(string(L2), "~w a segar un prado;", [Fue]),
    esqueleto(N, Cuenta),
    maplist(hombres, Cuenta, Grupos),
    atomic_list_concat(Grupos, ', ', Lista0),
    mayuscula_inicial(Lista0, Lista),
    format(string(L3), "~w y su perro", [Lista]),
    format(string(L4), "~w a segar un prado.", [Fue]).

%!  hombres(+N:integer, -Texto:string) is semidet.
%
%   Texto es «un hombre», «dos hombres» y así.
hombres(N, Texto) :-
    ante_sustantivo(N, Numero),
    (   N =:= 1
    ->  format(string(Texto), "~w hombre", [Numero])
    ;   format(string(Texto), "~w hombres", [Numero])
    ).

% fue(Num, Verbo): el verbo ir en pasado, en singular y en plural.
fue(singular, "fue").
fue(plural, "fueron").
