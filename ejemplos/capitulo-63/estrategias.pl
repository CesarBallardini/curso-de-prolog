:- encoding(utf8).

% Capítulo 63 - Versión 2: las estrategias LEX y MEA.
%
% Agrega dos claves a clave_estrategia/3. LEX prefiere la instanciación
% que usa los hechos más recientes: su clave es la lista de sus sellos de
% mayor a menor, y dos listas se comparan elemento por elemento; si una es
% prefijo de la otra, gana la más larga, la de la regla con más patrones.
% Después decide la cantidad de condiciones. MEA compara antes el sello
% del primer patrón de la regla, que suele ser una meta, y después sigue
% como LEX.
%
% solo-local: carga produccion.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- rastrear(cajas, mea, [sobre(a, piso), sobre(b, a)], M, R).
%?- clave_estrategia(lex, instanciacion(r, [3, 7, 5], 3, []), K).

:- ensure_loaded(produccion).

%!  clave_estrategia(+Estrategia, +Instanciacion, -Clave) is det.
%
%   Con lex, Clave es lex(Sellos, N): los sellos de mayor a menor y la
%   cantidad de condiciones. Con mea, Clave es mea(Primero, Sellos, N), con
%   el sello del primer patrón, o 0 si la regla no tiene patrones.
clave_estrategia(lex, instanciacion(_, Sellos, N, _), lex(Recientes, N)) :-
    sort(0, @>=, Sellos, Recientes).
clave_estrategia(mea, instanciacion(_, Sellos, N, _),
                 mea(Primero, Recientes, N)) :-
    primer_sello(Sellos, Primero),
    sort(0, @>=, Sellos, Recientes).

%!  claves(+Estrategia, +Programa, +Hechos:list, -Claves:list) is det.
%
%   Claves tiene un par Regla-Clave por cada instanciación del Programa en
%   la memoria con los Hechos, en el orden del conjunto de conflicto.
claves(Estrategia, Programa, Hechos, Claves) :-
    programa(Programa, Reglas),
    memoria_con(Hechos, Memoria),
    conjunto_conflicto(Reglas, Memoria, Instanciaciones),
    findall(Nombre-Clave,
            ( member(I, Instanciaciones),
              I = instanciacion(Nombre, _, _, _),
              clave_estrategia(Estrategia, I, Clave)
            ),
            Claves).

%!  primer_sello(+Sellos:list(integer), -Primero:integer) is det.
%
%   Primero es el primer elemento de Sellos, o 0 si Sellos es vacía.
primer_sello([], 0).
primer_sello([S|_], S).

% Un robot apila cajas en el orden de una lista, de abajo hacia arriba.
% Las metas están en la memoria: apilar(Lista) y despejar(Caja).
programa(cajas,
    [ apilada :: [meta(apilar([X, Y|R])), sobre(Y, X)]
           ---> [reemplazar(meta(apilar([X, Y|R])), meta(apilar([Y|R])))],
      apilar :: [meta(apilar([X, Y|R])), no(sobre(_, X)), no(sobre(_, Y)),
                 sobre(Y, Z)]
           ---> [reemplazar(sobre(Y, Z), sobre(Y, X)),
                 reemplazar(meta(apilar([X, Y|R])), meta(apilar([Y|R])))],
      despejar_base :: [meta(apilar([X, Y|_])), sobre(Z, X), {Z \== Y}]
           ---> [agregar(meta(despejar(Z)))],
      despejar_segunda :: [meta(apilar([_, Y|_])), sobre(Z, Y)]
           ---> [agregar(meta(despejar(Z)))],
      despejar_encima :: [meta(despejar(X)), sobre(Y, X)]
           ---> [agregar(meta(despejar(Y)))],
      bajar :: [meta(despejar(X)), no(sobre(_, X)), sobre(X, Y),
                {Y \== piso}]
           ---> [reemplazar(sobre(X, Y), sobre(X, piso)),
                 quitar(meta(despejar(X)))],
      despejada :: [meta(despejar(X)), no(sobre(_, X))]
           ---> [quitar(meta(despejar(X)))],
      terminada :: [meta(apilar([_]))]
           ---> [quitar(meta(apilar([_])))]
    ]).
