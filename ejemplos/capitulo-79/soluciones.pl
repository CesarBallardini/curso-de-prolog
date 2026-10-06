:- encoding(utf8).

% Capítulo 79 - Soluciones de los ejercicios.
%
% Las tablas de consejos de los ejercicios 4, 9 y 11 son módulos propios:
% sus cláusulas se escriben aquí con el nombre del módulo delante, y
% mueve/2, meta/3 y jugadas/4 se toman de la biblioteca de krk.pl.
%
% solo-local: carga los archivos del capítulo; exporta también el intérprete,
% la verificación y la búsqueda, para consultarlos sin cargar otro archivo.
%
%?- por_que(krk, pos(blancas, 5-5, 1-1, 4-7)).

:- module(soluciones,
          [ por_que/2,
            azar/3,
            medir_en/4,
            politica_sin_memoria/2,
            cuantas/1,
            historia/4
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(reglas).
:- reexport(consejos).
:- use_module(krk, []).
:- use_module(corregida, []).
:- reexport(partida, [primera/2, resistente/2]).
:- use_module(partida).
:- use_module(finales).
:- reexport(verificar).
:- reexport(busqueda).

% --- Ejercicio 4: la búsqueda como consejo -------------------------------

% La tabla ciega tiene un solo consejo, mate_en_3: cualquier jugada de los
% dos bandos, sin perder la torre, hasta el tercer mate de las blancas.
ciega:consejo(mate_en_3, mate, no torre_perdida,
                 profundidad < 5 y legal, profundidad < 4 y legal).
ciega:mueve(P, B) :-
    krk:mueve(P, B).
ciega:meta(M, P, R) :-
    krk:meta(M, P, R).
ciega:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).

% --- Ejercicio 5: ¿por qué? ----------------------------------------------

%!  por_que(+Tabla, +Posicion) is semidet.
%
%   Escribe la regla de Tabla que se aplica en Posicion y, para cada
%   consejo de su lista hasta el primero satisfacible, si lo es. Falla si
%   ninguno lo es.
por_que(Tabla, Posicion) :-
    once(( Tabla:regla(Regla, si Condicion entonces Consejos),
           cumple(Tabla, Condicion, Posicion, Posicion) )),
    format("regla ~w~n", [Regla]),
    probar(Consejos, Tabla, Posicion).

%!  probar(+Consejos:list, +Tabla, +Posicion) is semidet.
%
%   Escribe, para cada consejo hasta el primero satisfacible, si lo es.
probar([C|Cs], Tabla, Posicion) :-
    (   satisfacible(Tabla, C, Posicion, juega(J, _))
    ->  notacion(J, T),
        format("  ~w: satisfacible, juega ~w~n", [C, T])
    ;   format("  ~w: no satisfacible~n", [C]),
        probar(Cs, Tabla, Posicion)
    ).

% --- Ejercicio 6: una defensa al azar ------------------------------------

%!  azar(+Semilla:integer, +Posicion, -Jugada) is semidet.
%
%   Jugada es una respuesta legal de las negras elegida con un paso del
%   generador congruencial del capítulo 77, a partir de Semilla y del código
%   de Posicion: la misma posición con la misma semilla da siempre la misma
%   respuesta.
azar(Semilla, Posicion, Jugada) :-
    findall(J, jugada(Posicion, J, _), Js),
    length(Js, N),
    N > 0,
    Posicion = pos(_, RB, T, RN),
    codigo(pos(blancas, RB, T, RN), C),
    X is (1103515245 * (Semilla + C) + 12345) mod 2147483648,
    I is (X >> 16) mod N,
    nth0(I, Js, Jugada).

%!  medir_en(+Tabla, :Defensa, +ReyNegro, -R) is det.
%
%   Como medir/3 de partida.pl, sobre las posiciones normales con el rey
%   negro en la casilla ReyNegro.
:- meta_predicate medir_en(+, 2, +, -).
medir_en(Tabla, Defensa, ReyNegro, r(Finales, Mayor)) :-
    posiciones(blancas, Ps),
    findall(F-N,
            ( member(P, Ps),
              P = pos(_, _, _, ReyNegro),
              partida(Tabla, Defensa, P, Js, F),
              include(de_blancas, Js, Bs),
              length(Bs, N) ),
            FNs),
    pairs_keys(FNs, Fs0),
    msort(Fs0, Fs),
    clumped(Fs, Finales),
    aggregate_all(max(N), member(mate-N, FNs), Mayor).

% de_blancas(E): el elemento E de una partida es una jugada de las blancas.
de_blancas(blancas(_, _)).

% --- Ejercicio 8: la política sin memoria --------------------------------

:- dynamic elige/3, asegura/3, cae/3.

% elige(T, C, C1), asegura(T, C, K), cae(T, C, K): como en verificar.pl,
% pero con un paso por jugada y sobre las posiciones normales.

%!  politica_sin_memoria(+Tabla, -R) is det.
%
%   R es r(Aseguradas, Total, Mayor) para la política que en cada jugada
%   pide un árbol nuevo a Tabla y juega solo su primera jugada, sobre las
%   posiciones normales. Calcula la tabla de finales si hace falta.
politica_sin_memoria(Tabla, r(Aseguradas, Total, Mayor)) :-
    (   nodo(_, _, _)
    ->  true
    ;   calcular
    ),
    retractall(elige(Tabla, _, _)),
    retractall(asegura(Tabla, _, _)),
    retractall(cae(Tabla, _, _)),
    forall(nodo(blancas, C, _), elegir(Tabla, C)),
    forall(( nodo(negras, C, []), decodificar(negras, C, P), jaque(P) ),
           assertz(cae(Tabla, C, 0))),
    propagar(Tabla, 1),
    aggregate_all(count, nodo(blancas, _, _), Total),
    aggregate_all(count, asegura(Tabla, _, _), Aseguradas),
    aggregate_all(max(K), asegura(Tabla, _, K), Mayor).

%!  elegir(+Tabla, +C:integer) is det.
%
%   Registra adónde lleva la primera jugada del árbol que Tabla da en la
%   posición de las blancas de código C.
elegir(Tabla, C) :-
    decodificar(blancas, C, P),
    (   estrategia(Tabla, P, _, juega(J, _))
    ->  jugada(P, J, S),
        (   ahogado(S)
        ->  C1 = fin(ahogado)
        ;   sucesora(S, C1)
        )
    ;   C1 = fin(sin_consejo)
    ),
    assertz(elige(Tabla, C, C1)).

%!  propagar(+Tabla, +K:integer) is det.
%
%   Marca las posiciones de las blancas desde las que la política da mate
%   en K jugadas y las de las negras que lo reciben en K, y sigue mientras
%   alguna cambie.
propagar(Tabla, K) :-
    findall(C,
            ( elige(Tabla, C, C1),
              \+ asegura(Tabla, C, _),
              cae(Tabla, C1, _) ),
            Ganan),
    forall(member(C, Ganan), assertz(asegura(Tabla, C, K))),
    findall(C,
            ( nodo(negras, C, Cs),
              Cs \== [],
              \+ cae(Tabla, C, _),
              \+ memberchk(captura, Cs),
              forall(member(C1, Cs), asegura(Tabla, C1, _)) ),
            Caen),
    forall(member(C, Caen), assertz(cae(Tabla, C, K))),
    (   Ganan == [],
        Caen == []
    ->  true
    ;   K1 is K + 1,
        propagar(Tabla, K1)
    ).

% --- Ejercicio 9: el encierro sin cuidar la torre ------------------------

sin_cuidado:regla(N, R) :-
    krk:regla(N, R).
sin_cuidado:consejo(encierro,
                    espacio_menor y torre_divide y no ahogado,
                    no torre_perdida,
                    profundidad = 0 y torre,
                    ninguna) :-
    !.
sin_cuidado:consejo(N, B, M, U, T) :-
    krk:consejo(N, B, M, U, T),
    N \== encierro.
sin_cuidado:mueve(P, B) :-
    krk:mueve(P, B).
sin_cuidado:meta(M, P, R) :-
    krk:meta(M, P, R).
sin_cuidado:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).

% --- Ejercicio 10: cuántas posiciones por longitud del mate --------------

%!  cuantas(-Pares:list) is det.
%
%   Pares tiene un par K-N por cada K de 1 a 16: N posiciones normales de
%   las blancas dan mate en K jugadas. Calcula la tabla si hace falta.
cuantas(Pares) :-
    (   nodo(_, _, _)
    ->  true
    ;   calcular
    ),
    findall(K-N,
            ( between(1, 16, K),
              aggregate_all(count,
                            ( nodo(blancas, C, _),
                              decodificar(blancas, C, P),
                              mate_en(P, K) ),
                            N) ),
            Pares).

% --- Ejercicio 11: la otra corrección ------------------------------------

meta_mejor:regla(N, R) :-
    krk:regla(N, R).
meta_mejor:consejo(N, B1, M, U, T) :-
    krk:consejo(N, B, M, U, T),
    (   memberchk(N, [acercamiento, mantener_espacio, dividir_en_2])
    ->  B1 = (B y no ahogado)
    ;   B1 = B
    ).
meta_mejor:mueve(P, B) :-
    krk:mueve(P, B).
meta_mejor:meta(M, P, R) :-
    krk:meta(M, P, R).
meta_mejor:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).

% --- Ejercicio 12: los árboles de una partida ----------------------------

%!  historia(+Tabla, :Defensa, +Posicion, -Consejos:list) is det.
%
%   Consejos son los consejos que dieron un árbol nuevo en la partida desde
%   Posicion, en orden. La partida se repite siguiendo los árboles, como lo
%   hace partida/5, para saber en qué jugadas empieza uno.
:- meta_predicate historia(+, 2, +, -).
historia(Tabla, Defensa, Posicion, Consejos) :-
    partida(Tabla, Defensa, Posicion, Jugadas, _),
    arboles(Jugadas, Tabla, Posicion, ninguno, Consejos).

%!  arboles(+Jugadas:list, +Tabla, +Posicion, +Arbol, -Consejos:list)
%!      is det.
%
%   Recorre Jugadas desde Posicion con Arbol, el árbol en curso o ninguno,
%   y reúne el consejo de cada árbol nuevo.
arboles([], _, _, _, []).
arboles([blancas(J, C)|Js], Tabla, P, Arbol, Consejos) :-
    (   Arbol = juega(J, A1)
    ->  Consejos = Cs
    ;   estrategia(Tabla, P, C, juega(J, A1)),
        Consejos = [C|Cs]
    ),
    once(jugada(P, J, P1)),
    (   Js = [negras(R)|Js1]
    ->  once(jugada(P1, R, P2)),
        (   A1 = responde(Ramas),
            memberchk(R-A2, Ramas)
        ->  true
        ;   A2 = ninguno
        ),
        arboles(Js1, Tabla, P2, A2, Cs)
    ;   Cs = []
    ).
