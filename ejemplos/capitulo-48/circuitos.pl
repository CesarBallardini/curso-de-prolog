:- encoding(utf8).

% Capítulo 48 - Versión 2: el circuito como dato.
%
% Un circuito se describe con hechos que el programa puede examinar:
%
%   circuito(Nombre, Entradas, Salidas)
%       la interfaz: Entradas y Salidas son listas de nombres de cables;
%   componente(Circuito, Id, Tipo, Entradas, Salidas)
%       un componente de Circuito, identificado por Id dentro de él. Tipo
%       es una compuerta de tabla/3 o el nombre de otro circuito; Entradas
%       y Salidas son listas de nombres de cables de Circuito.
%
% simular/4 recorre la descripción y le da a cada compuerta un significado,
% el del cierre Conducta: el de su tabla de verdad con normal/4, otro en
% las versiones siguientes. La ruta de una compuerta es la lista de
% identificadores que llevan hasta ella desde el circuito exterior.
% circuito/3 y componente/5 admiten cláusulas en otros archivos.
%
% solo-local: es un módulo, carga compuertas.pl, y SWISH no admite módulos
% propios.
%
%?- simular(sumador, [1, 1, 0], Ss).
%?- tabla_de_verdad(xor_nand, Filas).
%?- compuerta_en(sumador, Ruta, Tipo).

:- module(circuitos,
          [ circuito/3,
            componente/5,
            tabla/3,
            bit/1,
            simular/3,
            simular/4,
            normal/4,
            tabla_de_verdad/2,
            compuerta_en/3,
            compuertas/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).

:- ensure_loaded(compuertas).

:- multifile circuito/3, componente/5.

%!  tabla(?Tipo, ?Entradas:list, ?Salida) is nondet.
%
%   Salida es la salida de la compuerta Tipo con las Entradas, según su
%   tabla de verdad: las de la versión 1.
tabla(inv, [A], S) :- inv(A, S).
tabla(and, [A, B], S) :- and(A, B, S).
tabla(or, [A, B], S) :- or(A, B, S).
tabla(xor, [A, B], S) :- xor(A, B, S).
tabla(nand, [A, B], S) :- nand(A, B, S).
tabla(nor, [A, B], S) :- nor(A, B, S).

% bit(B): B es un valor lógico.
bit(0).
bit(1).

% El circuito del capítulo 23: cuatro compuertas NAND.
circuito(xor_nand, [x, y], [z]).
componente(xor_nand, g1, nand, [x, y], [t]).
componente(xor_nand, g2, nand, [x, t], [u]).
componente(xor_nand, g3, nand, [y, t], [v]).
componente(xor_nand, g4, nand, [u, v], [z]).

circuito(semisumador, [a, b], [s, c]).
componente(semisumador, x1, xor, [a, b], [s]).
componente(semisumador, y1, and, [a, b], [c]).

circuito(sumador, [a, b, ci], [s, co]).
componente(sumador, m1, semisumador, [a, b], [t, c1]).
componente(sumador, m2, semisumador, [t, ci], [s, c2]).
componente(sumador, o1, or, [c1, c2], [co]).

% Tres bits, el menos significativo primero: a0 y b0.
circuito(sumador3, [a0, a1, a2, b0, b1, b2], [s0, s1, s2, c]).
componente(sumador3, m0, semisumador, [a0, b0], [s0, c0]).
componente(sumador3, s1, sumador, [a1, b1, c0], [s1, c1]).
componente(sumador3, s2, sumador, [a2, b2, c1], [s2, c]).

circuito(biestable, [s, r], [q, qn]).
componente(biestable, n1, nand, [s, qn], [q]).
componente(biestable, n2, nand, [r, q], [qn]).

%!  simular(+Circuito, ?Entradas:list, ?Salidas:list) is nondet.
%
%   Salidas son los valores de las salidas de Circuito con los valores
%   Entradas, cada compuerta según su tabla de verdad.
simular(Circuito, Entradas, Salidas) :-
    simular(normal, Circuito, Entradas, Salidas).

%!  normal(+Ruta:list, ?Tipo, ?Entradas:list, ?Salida) is nondet.
%
%   La conducta de una compuerta que funciona: la de su tabla.
normal(_Ruta, Tipo, Entradas, Salida) :-
    tabla(Tipo, Entradas, Salida).

:- meta_predicate simular(4, +, ?, ?).

%!  simular(:Conducta, +Circuito, ?Entradas:list, ?Salidas:list) is nondet.
%
%   Salidas son los valores de las salidas de Circuito con los valores
%   Entradas, cuando cada compuerta cumple call(Conducta, Ruta, Tipo,
%   EntradasCompuerta, Salida), con Ruta la ruta de la compuerta.
simular(Conducta, Circuito, Entradas, Salidas) :-
    simular_en(Conducta, [], Circuito, Entradas, Salidas).

%!  simular_en(:Conducta, +Ruta:list, +Circuito, ?Entradas, ?Salidas)
%!      is nondet.
%
%   Como simular/4, para el circuito que está en Ruta dentro del
%   exterior: un cable es una variable, y cada componente, una meta.
simular_en(Conducta, Ruta, Circuito, Entradas, Salidas) :-
    circuito(Circuito, NEntradas, NSalidas),
    cables(Circuito, Cables),
    valores(Cables, NEntradas, Entradas),
    valores(Cables, NSalidas, Salidas),
    findall(c(Id, Tipo, Es, Ss),
            componente(Circuito, Id, Tipo, Es, Ss),
            Componentes),
    maplist(activar(Conducta, Ruta, Cables), Componentes).

%!  cables(+Circuito, -Cables:list(pair)) is det.
%
%   Cables tiene un par Nombre-Valor por cada cable de Circuito, con el
%   Valor libre.
cables(Circuito, Cables) :-
    circuito(Circuito, Es, Ss),
    findall(N,
            ( member(N, Es)
            ; member(N, Ss)
            ; componente(Circuito, _, _, CEs, CSs),
              ( member(N, CEs) ; member(N, CSs) )
            ),
            Nombres0),
    sort(Nombres0, Nombres),
    pairs_keys(Cables, Nombres).

%!  valores(+Cables:list(pair), +Nombres:list, ?Valores:list) is semidet.
%
%   Valores son los valores de los cables Nombres.
valores(Cables, Nombres, Valores) :-
    maplist(valor(Cables), Nombres, Valores).

%!  valor(+Cables:list(pair), +Nombre, ?Valor) is semidet.
%
%   Valor es el valor del cable Nombre.
valor(Cables, Nombre, Valor) :-
    memberchk(Nombre-Valor, Cables).

%!  activar(:Conducta, +Ruta:list, +Cables:list(pair), +Componente)
%!      is nondet.
%
%   El componente c(Id, Tipo, Entradas, Salidas) se cumple con los valores
%   de Cables: un circuito se simula con su propia descripción; una
%   compuerta, con Conducta.
activar(Conducta, Ruta, Cables, c(Id, Tipo, NEs, NSs)) :-
    valores(Cables, NEs, Es),
    valores(Cables, NSs, Ss),
    append(Ruta, [Id], RutaId),
    (   circuito(Tipo, _, _)
    ->  simular_en(Conducta, RutaId, Tipo, Es, Ss)
    ;   Ss = [S],
        call(Conducta, RutaId, Tipo, Es, S)
    ).

%!  tabla_de_verdad(+Circuito, -Filas:list(pair)) is det.
%
%   Filas tiene un par Entradas-Salidas por cada combinación de valores de
%   las entradas de Circuito, en orden binario creciente, y uno por cada
%   estado estable si una combinación tiene varios.
tabla_de_verdad(Circuito, Filas) :-
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Entradas),
    findall(Entradas-Salidas,
            ( maplist(bit, Entradas),
              simular(Circuito, Entradas, Salidas) ),
            Filas).

%!  compuerta_en(+Circuito, -Ruta:list, -Tipo) is nondet.
%
%   Ruta es la ruta de una compuerta de tipo Tipo dentro de Circuito, a
%   cualquier profundidad.
compuerta_en(Circuito, Ruta, Tipo) :-
    componente(Circuito, Id, T, _, _),
    (   circuito(T, _, _)
    ->  compuerta_en(T, Ruta0, Tipo),
        Ruta = [Id|Ruta0]
    ;   Ruta = [Id],
        Tipo = T
    ).

%!  compuertas(+Circuito, -N:integer) is det.
%
%   N es la cantidad de compuertas de Circuito, a cualquier profundidad.
compuertas(Circuito, N) :-
    aggregate_all(count, compuerta_en(Circuito, _, _), N).
