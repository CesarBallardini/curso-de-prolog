:- encoding(utf8).

% Capítulo 42 - Prolog y SQL: consultas recursivas.
%
% Las tablas empleados y vuelos de schema.sql como hechos. La cadena de
% jefes es un árbol; los vuelos forman un grafo con un ciclo (aep -> cor ->
% aep). Las mismas preguntas que WITH RECURSIVE: con reglas recursivas, con
% tablas, y con una evaluación de abajo hacia arriba que itera como SQLite.
%
%?- superior(8, J).
%?- destino(aep, D).
%?- iteraciones(aep, Is).
%?- tarifa(ros, D, P).

:- dynamic empleado/5, vuelo/4.

% empleado(Id, Nombre, Depto, Salario, Jefe): la tabla empleados. Jefe es
% null en la directora, que no tiene jefe.
empleado(1, marta,   dir,    900000, null).
empleado(2, jorge,   ventas, 500000, 1).
empleado(3, lucia,   it,     650000, 1).
empleado(4, pablo,   ventas, 350000, 2).
empleado(5, sofia,   ventas, 380000, 2).
empleado(6, tomas,   it,     420000, 3).
empleado(7, valeria, it,     450000, 3).
empleado(8, nicolas, it,     300000, 7).
empleado(9, irene,   rrhh,   400000, 1).

% vuelo(Origen, Destino, Aerolinea, Precio): la tabla vuelos.
vuelo(ros, aep, ar, 50).
vuelo(aep, cor, ar, 70).
vuelo(cor, aep, fb, 60).
vuelo(aep, mdz, ar, 90).
vuelo(cor, mdz, fb, 55).
vuelo(mdz, brc, ar, 120).
vuelo(aep, brc, fb, 110).
vuelo(aep, ush, ar, 150).
vuelo(cor, sla, fb, 80).
vuelo(igr, aep, ar, 95).

%!  jefe(?Empleado, ?Jefe) is nondet.
%
%   Jefe es el jefe directo de Empleado: la columna jefe sin los null.
jefe(Empleado, Jefe) :-
    empleado(Empleado, _, _, _, Jefe),
    Jefe \== null.

%!  superior(?Empleado, ?Superior) is nondet.
%
%   Superior es el jefe de Empleado, o un superior de su jefe.
superior(Empleado, Superior) :-
    jefe(Empleado, Superior).
superior(Empleado, Superior) :-
    jefe(Empleado, Jefe),
    superior(Jefe, Superior).

%!  superior_izq(?Empleado, ?Superior) is nondet.
%
%   La misma relación con la recursión a la izquierda, en el orden de la
%   consulta SQL: da las respuestas y, al pedir más, no termina.
superior_izq(Empleado, Superior) :-
    jefe(Empleado, Superior).
superior_izq(Empleado, Superior) :-
    superior_izq(Empleado, Intermedio),
    jefe(Intermedio, Superior).

%!  destino_sin_tabla(+Origen, -Destino) is nondet.
%
%   Destino se alcanza desde Origen con uno o más vuelos. Por el ciclo
%   entre aep y cor, repite respuestas sin fin.
destino_sin_tabla(Origen, Destino) :-
    vuelo(Origen, Destino, _, _).
destino_sin_tabla(Origen, Destino) :-
    vuelo(Origen, Escala, _, _),
    destino_sin_tabla(Escala, Destino).

:- table destino/2.

%!  destino(?Origen, ?Destino) is nondet.
%
%   La misma relación, tabulada: cada destino una vez, y termina.
destino(Origen, Destino) :-
    vuelo(Origen, Destino, _, _).
destino(Origen, Destino) :-
    destino(Origen, Escala),
    vuelo(Escala, Destino, _, _).

%!  iteraciones(+Origen, -Iteraciones) is det.
%
%   Iteraciones es la lista de las filas nuevas de cada paso de una
%   evaluación de abajo hacia arriba de los destinos de Origen: el primer
%   paso es la parte no recursiva, y cada paso siguiente une con vuelos
%   solo las filas nuevas del anterior. Termina cuando un paso no agrega
%   nada.
iteraciones(Origen, [Base|Resto]) :-
    findall(D, vuelo(Origen, D, _, _), Ds),
    sort(Ds, Base),
    iterar(Base, Base, Resto).

%!  iterar(+Nuevas, +Vistas, -Iteraciones) is det.
%
%   Nuevas son las filas del último paso y Vistas todas las obtenidas,
%   ambas conjuntos ordenados.
iterar([], _, []).
iterar([N|Ns], Vistas, [Nuevas|Resto]) :-
    findall(D, ( member(X, [N|Ns]), vuelo(X, D, _, _) ), Ds),
    sort(Ds, Obtenidas),
    ord_subtract(Obtenidas, Vistas, Nuevas),
    ord_union(Vistas, Nuevas, Vistas1),
    iterar(Nuevas, Vistas1, Resto).

:- table tarifa(_, _, min).

%!  tarifa(?Origen, ?Destino, -Precio) is nondet.
%
%   Precio es el menor precio de un viaje de Origen a Destino, con uno o
%   más vuelos. La tabla guarda solo el mínimo para cada par, así que el
%   ciclo no agrega respuestas: Precio debe llegar libre.
tarifa(Origen, Destino, Precio) :-
    vuelo(Origen, Destino, _, Precio).
tarifa(Origen, Destino, Precio) :-
    tarifa(Origen, Escala, P1),
    vuelo(Escala, Destino, _, P2),
    Precio is P1 + P2.
