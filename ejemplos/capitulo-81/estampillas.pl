:- encoding(utf8).

% Capítulo 81 - Una colección de estampillas.
%
% Un sello es sello(Pais, Serie, Anio, Valor). Cada hecho album(Sellos)
% guarda una serie: sellos del mismo país y de la misma serie, en orden
% creciente de valor. Un patrón es un sello con variables:
% sello(_, castillos, _, _) son todos los sellos de la serie castillos.
%
% Versión 1: el álbum en la base de datos dinámica del capítulo 20, con
% las operaciones de Csenki: ver, vender y comprar por patrón.
% Versión 2: las mismas operaciones como relaciones entre un álbum y el
% siguiente, sin base de datos; las de la versión 1 quedan como una capa
% fina que lee el álbum, llama a la relación y lo guarda.
%
%?- coleccion(sello(_, _, _, 50), Sellos).
%?- coleccion(sello(_, _, Anio, _), between(1875, 1883, Anio), Sellos).
%?- insertar(sello(alemania, castillos, 1890, 30), [sello(alemania, castillos, 1885, 10), sello(alemania, castillos, 1879, 50)], Serie).
%?- album_actual(A0), vender(sello(_, poetas, 1978, _), A0, A).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- dynamic album/1.

% album(Sellos): Sellos es una serie del álbum, en orden de valor.
album([ sello(reino_unido, reina, 1965, 20),
        sello(reino_unido, reina, 1967, 50),
        sello(reino_unido, reina, 1963, 120)
      ]).
album([ sello(reino_unido, poetas, 1978, 19),
        sello(reino_unido, poetas, 1979, 20),
        sello(reino_unido, poetas, 1978, 22),
        sello(reino_unido, poetas, 1977, 40),
        sello(reino_unido, poetas, 1978, 100)
      ]).
album([ sello(alemania, kaiser, 1882, 5),
        sello(alemania, kaiser, 1879, 20),
        sello(alemania, kaiser, 1885, 50)
      ]).
album([ sello(alemania, castillos, 1885, 10),
        sello(alemania, castillos, 1879, 50),
        sello(alemania, castillos, 1885, 60)
      ]).

% --- Versión 1: el álbum en la base de datos -----------------------------

%!  coleccion(?Patron, -Sellos:list) is det.
%
%   Sellos son los sellos del álbum que unifican con Patron, serie por
%   serie y en el orden de cada serie. Patron no queda ligado.
coleccion(Patron, Sellos) :-
    findall(Patron, ( album(Serie), member(Patron, Serie) ), Sellos).

%!  coleccion(?Patron, :Condicion, -Sellos:list) is det.
%
%   Como coleccion/2, pero solo los sellos con los que, ligado Patron,
%   Condicion se cumple.
coleccion(Patron, Condicion, Sellos) :-
    findall(Patron,
            ( album(Serie),
              member(Patron, Serie),
              call(Condicion) ),
            Sellos).

%!  mostrar(?Patron) is det.
%
%   Escribe, uno por línea, los sellos del álbum que unifican con Patron.
mostrar(Patron) :-
    coleccion(Patron, Sellos),
    forall(member(S, Sellos), format("~w~n", [S])).

%!  quitar_todos(?Patron, +Sellos0:list, -Sellos:list) is det.
%
%   Sellos es Sellos0 sin los sellos que unifican con Patron, en el mismo
%   orden. Patron no queda ligado.
quitar_todos(Patron, Sellos0, Sellos) :-
    exclude(unifica(Patron), Sellos0, Sellos).

%!  unifica(?Patron, ?Sello) is semidet.
%
%   Patron y Sello unifican; ninguno de los dos queda ligado.
unifica(Patron, Sello) :-
    \+ Patron \= Sello.

%!  vender(?Patron) is det.
%
%   Quita del álbum todos los sellos que unifican con Patron, en todas las
%   series; una serie que queda vacía desaparece.
vender(Patron) :-
    findall(Serie, album(Serie), Series),
    maplist(vender_de(Patron), Series).

%!  vender_de(?Patron, +Serie:list) is det.
%
%   Reemplaza en el álbum la serie Serie por la misma serie sin los sellos
%   que unifican con Patron.
vender_de(Patron, Serie) :-
    quitar_todos(Patron, Serie, Resto),
    (   Resto == Serie
    ->  true
    ;   retract(album(Serie)),
        (   Resto == []
        ->  true
        ;   assertz(album(Resto))
        )
    ).

%!  misma_serie(+Sello1, +Sello2) is semidet.
%
%   Los dos sellos son del mismo país y de la misma serie.
misma_serie(sello(Pais, Serie, _, _), sello(Pais, Serie, _, _)).

%!  insertar(+Sello, +Serie0:list, -Serie:list) is semidet.
%
%   Serie es Serie0 con Sello agregado en el lugar que le da su valor.
%   Falla si Sello no es de la misma serie que los sellos de Serie0.
insertar(Sello, Serie0, Serie) :-
    en_orden(Serie0, Sello, Serie).

%!  en_orden(+Serie0:list, +Sello, -Serie:list) is semidet.
%
%   Lo mismo que insertar/3, con la lista primero, para que la indexación
%   distinga la lista vacía de la que no lo es.
en_orden([], Sello, [Sello]).
en_orden([S|Ss], Sello, Serie) :-
    misma_serie(Sello, S),
    Sello = sello(_, _, _, V),
    S = sello(_, _, _, V1),
    (   V =< V1
    ->  Serie = [Sello, S|Ss]
    ;   Serie = [S|Serie1],
        en_orden(Ss, Sello, Serie1)
    ).

%!  comprar(+Sello) is det.
%
%   Agrega Sello al álbum: en su serie, si el álbum ya la tiene, o en una
%   serie nueva.
comprar(Sello) :-
    (   album(Serie),
        Serie = [S|_],
        misma_serie(Sello, S)
    ->  insertar(Sello, Serie, Serie1),
        retract(album(Serie)),
        assertz(album(Serie1))
    ;   assertz(album([Sello]))
    ).

% --- Versión 2: el álbum como valor --------------------------------------

%!  album_actual(-Album:list) is det.
%
%   Album es la lista de las series de la base de datos, en su orden.
album_actual(Album) :-
    findall(Serie, album(Serie), Album).

%!  guardar(+Album:list) is det.
%
%   Reemplaza las series de la base de datos por las de Album.
guardar(Album) :-
    retractall(album(_)),
    forall(member(Serie, Album), assertz(album(Serie))).

%!  vender(?Patron, +Album0:list, -Album:list) is det.
%
%   Album es Album0 sin los sellos que unifican con Patron, sin las
%   series que quedan vacías.
vender(Patron, Album0, Album) :-
    maplist(quitar_todos(Patron), Album0, Album1),
    exclude(==([]), Album1, Album).

%!  comprar(+Sello, +Album0:list, -Album:list) is det.
%
%   Album es Album0 con Sello agregado en su serie, o en una serie nueva
%   al final si Album0 no la tiene.
comprar(Sello, Album0, Album) :-
    (   append(Antes, [Serie|Despues], Album0),
        Serie = [S|_],
        misma_serie(Sello, S)
    ->  insertar(Sello, Serie, Serie1),
        append(Antes, [Serie1|Despues], Album)
    ;   append(Album0, [[Sello]], Album)
    ).

%!  operar(+Operacion) is det.
%
%   Aplica al álbum de la base de datos Operacion, que es vender(Patron)
%   o comprar(Sello), a través de las relaciones de la versión 2.
operar(vender(Patron)) :-
    album_actual(A0),
    vender(Patron, A0, A),
    guardar(A).
operar(comprar(Sello)) :-
    album_actual(A0),
    comprar(Sello, A0, A),
    guardar(A).
