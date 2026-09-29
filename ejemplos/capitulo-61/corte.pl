:- encoding(utf8).

% Capítulo 61 - Versión 4: el corte.
%
% Al llamar a un predicado, la máquina anota la altura de la pila de puntos
% de elección, y cada ! del cuerpo de la cláusula elegida entra en la
% resolvente como '$corte'(Altura). Ejecutarlo es quitar de la pila los
% puntos de elección creados desde esa llamada: los de las metas del
% cuerpo anteriores al corte y el de las cláusulas que quedaban del
% predicado. Un ! en la consulta corta hasta la altura 0. El resto de la
% máquina es el de almacen.pl.
%
% solo-local: carga el módulo almacen.
%
%?- resolver(maximo, maximo(4, 3, M)).
%?- medir(corte, suma_hasta(100, S), M).

:- module(corte,
          [ resolver/2,
            medir/3,
            usar/6,
            cortar/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(programas).
:- use_module(almacen,
              [ resolver_con/3,
                medir_con/4,
                compilar/2,
                procedimiento/3,
                renombrar/3,
                unificar/5,
                marca/2,
                deshacer/3,
                contar_intento/2
              ]).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa objeto Nombre, que puede
%   tener cortes.
resolver(Nombre, Meta) :-
    resolver_con(corte, Nombre, Meta).

%!  medir(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de la búsqueda completa de Meta, como las
%   describe medir_con/4 de almacen.pl.
medir(Nombre, Meta, Medidas) :-
    medir_con(corte, Nombre, Meta, Medidas).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de almacen.pl, con el corte: '$corte'(Altura) corta hasta
%   Altura, ! corta hasta 0, y la llamada a un predicado anota la altura
%   de la pila para los cortes de su cuerpo.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = '$corte'(Altura)
    ->  cortar(Altura, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   Meta == !
    ->  cortar(0, Metas, Estado0, Estado),
        Resultado = sigue(Estado)
    ;   clase(Meta, usuario(_))
    ->  procedimiento(Tabla, Meta, Clausulas),
        Estado0 = m(_, Pila, _, _, _, _),
        length(Pila, Altura),
        llamar(Clausulas, Meta, Metas, Altura, Estado0, Resultado)
    ;   almacen:paso(Meta, Metas, Tabla, Estado0, Resultado)
    ).

%!  cortar(+Altura:integer, +Metas:list, +Estado0, -Estado) is det.
%
%   Estado sigue con Metas y deja en la pila solo los Altura puntos de
%   elección de más abajo. El rastro pierde las entradas que ya no hacen
%   falta.
cortar(Altura, Metas, m(_, Pila0, A, R0, L, M), m(Metas, Pila, A, R, L, M)) :-
    length(Pila0, N),
    K is max(0, N - Altura),
    length(Quitados, K),
    append(Quitados, Pila, Pila0),
    purgar(Pila, R0, R).

%!  purgar(+Pila:list, +Rastro0:list, -Rastro:list) is det.
%
%   Rastro es Rastro0 sin las entradas posteriores al último punto de
%   elección de la Pila cuyas celdas se crearon después de él: volver a
%   ese punto no tiene que borrarlas, porque la resolvente que guarda no
%   las usa.
purgar(Pila, Rastro0, Rastro) :-
    marca(Pila, Marca),
    largo_del_rastro(Pila, N),
    length(Rastro0, Largo),
    K is Largo - N,
    length(Recientes, K),
    append(Recientes, Viejas, Rastro0),
    include(anterior(Marca), Recientes, Quedan),
    append(Quedan, Viejas, Rastro).

%!  largo_del_rastro(+Pila:list, -N:integer) is det.
%
%   N es el largo del rastro al crearse el último punto de elección de la
%   Pila, o 0 si no hay ninguno.
largo_del_rastro([], 0).
largo_del_rastro([eleccion(_, _, N, _)|_], N).

%!  anterior(+Marca:integer, +Celda:integer) is semidet.
%
%   Celda es anterior a Marca.
anterior(Marca, Celda) :-
    Celda < Marca.

%!  llamar(+Clausulas:list, +Meta, +Metas:list, +Altura:integer,
%!         +Estado0, -Resultado) is det.
%
%   Como llamar/5 de almacen.pl; Altura es la altura de la pila al llamar
%   a Meta.
llamar([Clausula|Clausulas], Meta, Metas, Altura, Estado0, Resultado) :-
    contar_intento(Estado0, Estado1),
    (   Clausulas == []
    ->  Estado2 = Estado1
    ;   Estado1 = m(Ms, Pila, A, R, L, M),
        length(R, N),
        Estado2 = m(Ms, [eleccion([Meta|Metas], Clausulas, N, L)|Pila],
                    A, R, L, M)
    ),
    (   usar(Clausula, Meta, Metas, Altura, Estado2, Estado)
    ->  Resultado = sigue(Estado)
    ;   Clausulas == []
    ->  Resultado = falla(Estado1)
    ;   llamar(Clausulas, Meta, Metas, Altura, Estado1, Resultado)
    ).

%!  usar(+Clausula, +Meta, +Metas:list, +Altura:integer, +Estado0,
%!       -Estado) is semidet.
%
%   Como usar/5 de almacen.pl; cada ! del cuerpo entra en la resolvente
%   como '$corte'(Altura).
usar(cl(K, Cabeza, Cuerpo), Meta, Metas, Altura, m(_, Pila, A0, R0, L0, M),
     m(Metas1, Pila, A, R, L, M)) :-
    renombrar(L0, Cabeza, Cabeza1),
    marca(Pila, Marca),
    unificar(Meta, Cabeza1, Marca, A0-R0, A-R),
    maplist(instanciar(L0, Altura), Cuerpo, Cuerpo1),
    append(Cuerpo1, Metas, Metas1),
    L is L0 + K.

%!  instanciar(+Base:integer, +Altura:integer, +Meta0, -Meta) is det.
%
%   Meta es la meta Meta0 de un cuerpo, renombrada desde Base; un ! pasa a
%   ser '$corte'(Altura).
instanciar(Base, Altura, Meta0, Meta) :-
    (   Meta0 == !
    ->  Meta = '$corte'(Altura)
    ;   renombrar(Base, Meta0, Meta)
    ).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3 de almacen.pl; la altura de la llamada es la de la pila
%   sin el punto de elección.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).

%!  volver_desde(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3, con al menos un punto de elección en la pila.
volver_desde(Tabla, m(_, [Eleccion|Pila], A0, R0, L, M), Resultado) :-
    Eleccion = eleccion([Meta|Metas], Clausulas, N, _),
    deshacer(N, A0-R0, A-R),
    length(Pila, Altura),
    llamar(Clausulas, Meta, Metas, Altura, m([Meta|Metas], Pila, A, R, L, M),
           Resultado0),
    (   Resultado0 = falla(Estado)
    ->  volver(Tabla, Estado, Resultado)
    ;   Resultado = Resultado0
    ).
