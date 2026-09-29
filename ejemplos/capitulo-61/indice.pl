:- encoding(utf8).

% Capítulo 61 - Versión 5: indexación por el primer argumento.
%
% Al traducir el programa, cada cláusula recibe una clave calculada con el
% primer argumento de su cabeza: el átomo o número, si es una constante;
% Nombre/Aridad, si es un término compuesto; libre, si es una variable o
% el predicado no tiene argumentos. Al llamar, la máquina calcula la misma
% clave con el primer argumento de la meta, ya desreferenciado, y salta
% las cláusulas cuya clave es incompatible: su cabeza no puede unificar.
% Las cláusulas que se guardan en un punto de elección también se filtran,
% así que si no queda ninguna compatible no hay punto de elección. El
% corte y el resto de la máquina son los de corte.pl y almacen.pl.
%
% solo-local: carga los módulos almacen y corte.
%
%?- resolver(listas, suma_hasta(10, S)).
%?- medir(listas, suma_hasta(100, S), M).

:- module(indice,
          [ resolver/2,
            medir/3,
            clave/2,
            clave_actual/3,
            siguiente/4
          ]).

:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(pairs)).
:- use_module(programas).
:- use_module(almacen,
              [ resolver_con/3,
                medir_con/4,
                compilar/2 as compilar_sin_claves,
                procedimiento/3,
                desreferenciar/3,
                deshacer/3,
                contar_intento/2
              ]).
:- use_module(corte, [usar/6, cortar/4]).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa objeto Nombre, en la
%   máquina con corte e indexación.
resolver(Nombre, Meta) :-
    resolver_con(indice, Nombre, Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de la búsqueda completa de Meta, como las
%   describe medir_con/4 de almacen.pl.
medir(Nombre, Meta, Medidas) :-
    medir_con(indice, Nombre, Meta, Medidas).

%!  compilar(+Clausulas:list, -Tabla) is det.
%
%   Como compilar/2 de almacen.pl, con cada cláusula en un par
%   Clave-Clausula.
compilar(Clausulas, Tabla) :-
    compilar_sin_claves(Clausulas, Tabla0),
    map_assoc(con_claves, Tabla0, Tabla).

%!  con_claves(+Clausulas:list, -Pares:list) is det.
%
%   Pares son las Clausulas, en orden, cada una con su clave.
con_claves(Clausulas, Pares) :-
    maplist(con_clave, Clausulas, Pares).

%!  con_clave(+Clausula, -Par) is det.
%
%   Par es Clave-Clausula, con la clave del primer argumento de la cabeza.
con_clave(cl(K, Cabeza, Cuerpo), Clave-cl(K, Cabeza, Cuerpo)) :-
    clave(Cabeza, Clave).

%!  clave(+Meta, -Clave) is det.
%
%   Clave es la clave del primer argumento de Meta, un término sin
%   variables de Prolog: libre si es una celda o si Meta no tiene
%   argumentos, el mismo término si es atómico, y Nombre/Aridad si es
%   compuesto.
clave(Meta, Clave) :-
    (   compound(Meta)
    ->  arg(1, Meta, Primero),
        clave_de(Primero, Clave)
    ;   Clave = libre
    ).

%!  clave_de(+Termino, -Clave) is det.
%
%   Clave es la clave del Termino, como la describe clave/2.
clave_de(Termino, Clave) :-
    (   Termino = '$v'(_)
    ->  Clave = libre
    ;   atomic(Termino)
    ->  Clave = Termino
    ;   compound_name_arity(Termino, Nombre, Aridad),
        Clave = Nombre/Aridad
    ).

%!  compatibles(+Clave1, +Clave2) is semidet.
%
%   Las claves no descartan que los términos unifiquen.
compatibles(Clave1, Clave2) :-
    (   Clave1 == libre
    ->  true
    ;   Clave2 == libre
    ->  true
    ;   Clave1 == Clave2
    ).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de corte.pl, con las cláusulas filtradas por la clave de
%   Meta.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = '$corte'(Altura)
    ->  cortar(Altura, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   Meta == !
    ->  cortar(0, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   clase(Meta, usuario(_))
    ->  procedimiento(Tabla, Meta, Pares),
        Estado0 = m(_, Pila, _, _, _, _),
        length(Pila, Altura),
        llamar(Pares, Meta, Metas, Altura, Estado0, Resultado)
    ;   almacen:paso(Meta, Metas, Tabla, Estado0, Resultado)
    ).

%!  llamar(+Pares:list, +Meta, +Metas:list, +Altura:integer, +Estado0,
%!         -Resultado) is det.
%
%   Como llamar/6 de corte.pl, con las cláusulas de los Pares
%   Clave-Clausula que tienen una clave compatible con la de Meta.
%   Resultado es falla(Estado) si no hay ninguna que sirva.
llamar(Pares0, Meta, Metas, Altura, Estado0, Resultado) :-
    Estado0 = m(_, _, Almacen, _, _, _),
    clave_actual(Meta, Almacen, Clave),
    (   siguiente(Pares0, Clave, Clausula, Pares)
    ->  contar_intento(Estado0, Estado1),
        (   Pares == []
        ->  Estado2 = Estado1
        ;   Estado1 = m(Ms, Pila, A, R, L, M),
            length(R, N),
            Estado2 = m(Ms, [eleccion([Meta|Metas], Pares, N, L)|Pila],
                        A, R, L, M)
        ),
        (   usar(Clausula, Meta, Metas, Altura, Estado2, Estado)
        ->  Resultado = sigue(Estado)
        ;   Pares == []
        ->  Resultado = falla(Estado1)
        ;   llamar(Pares, Meta, Metas, Altura, Estado1, Resultado)
        )
    ;   Resultado = falla(Estado0)
    ).

%!  clave_actual(+Meta, +Almacen, -Clave) is det.
%
%   Clave es la clave de Meta con su primer argumento desreferenciado en
%   el Almacen.
clave_actual(Meta, Almacen, Clave) :-
    (   compound(Meta)
    ->  arg(1, Meta, Primero0),
        desreferenciar(Primero0, Almacen, Primero),
        clave_de(Primero, Clave)
    ;   Clave = libre
    ).

%!  siguiente(+Pares0:list, +Clave, -Clausula, -Pares:list) is semidet.
%
%   Clausula es la primera de Pares0 con una clave compatible con Clave, y
%   Pares lo que sigue, desde la próxima compatible, o [] si no hay otra.
%   Falla si ninguna es compatible.
siguiente([Clave0-Clausula0|Pares0], Clave, Clausula, Pares) :-
    (   compatibles(Clave0, Clave)
    ->  Clausula = Clausula0,
        saltar(Pares0, Clave, Pares)
    ;   siguiente(Pares0, Clave, Clausula, Pares)
    ).

%!  saltar(+Pares0:list, +Clave, -Pares:list) is det.
%
%   Pares es Pares0 desde el primer par con una clave compatible con
%   Clave, o [] si no hay ninguno.
saltar([], _, []).
saltar([Clave0-Clausula|Pares0], Clave, Pares) :-
    (   compatibles(Clave0, Clave)
    ->  Pares = [Clave0-Clausula|Pares0]
    ;   saltar(Pares0, Clave, Pares)
    ).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3 de corte.pl, con las cláusulas filtradas.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).

%!  volver_desde(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3, con al menos un punto de elección en la pila.
volver_desde(Tabla, m(_, [Eleccion|Pila], A0, R0, L, M), Resultado) :-
    Eleccion = eleccion([Meta|Metas], Pares, N, _),
    deshacer(N, A0-R0, A-R),
    length(Pila, Altura),
    llamar(Pares, Meta, Metas, Altura, m([Meta|Metas], Pila, A, R, L, M),
           Resultado0),
    (   Resultado0 = falla(Estado)
    ->  volver(Tabla, Estado, Resultado)
    ;   Resultado = Resultado0
    ).
