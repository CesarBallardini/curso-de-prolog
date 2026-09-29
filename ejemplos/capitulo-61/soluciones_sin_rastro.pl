:- encoding(utf8).

% Capítulo 61 - Solución del ejercicio 9: puntos de elección que guardan
% el almacén.
%
% El módulo sin_rastro es una versión de la máquina para ejecutar/5 de
% almacen.pl en la que el punto de elección guarda el almacén entero,
% guardado(Metas, Clausulas, Almacen), en lugar del largo del rastro y de
% la marca. Volver atrás es retomar ese almacén: el árbol AVL es
% persistente, y la versión guardada comparte sus nodos con las que siguen.
% Ninguna ligadura se anota: unificar/5 recibe la marca 0.
%
% solo-local: carga el módulo almacen.
%
%?- resolver(familia, antepasado(juan, D)).
%?- medir(listas, suma_hasta(100, S), M).

:- module(sin_rastro, [resolver/2, medir/3]).

:- use_module(programas).
:- use_module(almacen,
              [ resolver_con/3,
                medir_con/4,
                compilar/2,
                procedimiento/3,
                renombrar/3,
                unificar/5,
                ejecutar_predefinida/4,
                contar_intento/2
              ]).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Como resolver/2 de almacen.pl, sin rastro.
resolver(Nombre, Meta) :-
    resolver_con(sin_rastro, Nombre, Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Como medir/3 de almacen.pl, sin rastro.
medir(Nombre, Meta, Medidas) :-
    medir_con(sin_rastro, Nombre, Meta, Medidas).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de almacen.pl, con los predefinidos y las llamadas sin
%   rastro.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    clase(Meta, Clase),
    (   Clase = predefinida(M)
    ->  Estado0 = m(_, Pila, A0, R, L, Med),
        (   ejecutar_predefinida(M, 0, A0-R, A-R)
        ->  Resultado = sigue(m(Metas, Pila, A, R, L, Med))
        ;   Resultado = falla(Estado0)
        )
    ;   Clase = usuario(M)
    ->  procedimiento(Tabla, M, Clausulas),
        llamar(Clausulas, M, Metas, Estado0, Resultado)
    ;   almacen:paso(Meta, Metas, Tabla, Estado0, Resultado)
    ).

%!  llamar(+Clausulas:list, +Meta, +Metas:list, +Estado0, -Resultado)
%!      is det.
%
%   Como llamar/5 de almacen.pl; el punto de elección guarda el almacén.
llamar([Clausula|Clausulas], Meta, Metas, Estado0, Resultado) :-
    contar_intento(Estado0, Estado1),
    (   Clausulas == []
    ->  Estado2 = Estado1
    ;   Estado1 = m(Ms, Pila, A, R, L, M),
        Estado2 = m(Ms, [guardado([Meta|Metas], Clausulas, A)|Pila],
                    A, R, L, M)
    ),
    (   usar(Clausula, Meta, Metas, Estado2, Estado)
    ->  Resultado = sigue(Estado)
    ;   Clausulas == []
    ->  Resultado = falla(Estado1)
    ;   llamar(Clausulas, Meta, Metas, Estado1, Resultado)
    ).

%!  usar(+Clausula, +Meta, +Metas:list, +Estado0, -Estado) is semidet.
%
%   Como usar/5 de almacen.pl, sin anotar ligaduras.
usar(cl(K, Cabeza, Cuerpo), Meta, Metas, m(_, Pila, A0, R, L0, M),
     m(Metas1, Pila, A, R, L, M)) :-
    renombrar(L0, Cabeza, Cabeza1),
    unificar(Meta, Cabeza1, 0, A0-R, A-R),
    maplist(renombrar(L0), Cuerpo, Cuerpo1),
    append(Cuerpo1, Metas, Metas1),
    L is L0 + K.

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3 de almacen.pl: retoma el almacén guardado en el último
%   punto de elección.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).

%!  volver_desde(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3, con al menos un punto de elección en la pila.
volver_desde(Tabla, m(_, [Guardado|Pila], _, R, L, M), Resultado) :-
    Guardado = guardado([Meta|Metas], Clausulas, A),
    llamar(Clausulas, Meta, Metas, m([Meta|Metas], Pila, A, R, L, M),
           Resultado0),
    (   Resultado0 = falla(Estado)
    ->  volver(Tabla, Estado, Resultado)
    ;   Resultado = Resultado0
    ).
