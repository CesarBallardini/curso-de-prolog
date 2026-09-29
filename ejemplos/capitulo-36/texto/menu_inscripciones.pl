:- encoding(utf8).

% Capítulo 36 - El menú de Inscripciones a pantalla completa, sobre los
% módulos datos e informes del capítulo 31.
%
% Un menú es menu(N, Vista): N es la materia elegida, contada desde 1, y
% Vista es materias, inscriptos o salir. pantalla_menu/2 es el modelo de
% pantalla y paso_menu/3 la respuesta a una tecla; los dos son puros.
%
% solo-local: SWISH no admite módulos propios ni tiene una terminal.
%
%?- pantalla_menu(menu(3, inscriptos), L).

:- module(menu_inscripciones,
          [ pantalla_menu/2,
            paso_menu/3,
            bucle_menu/3,
            menu_de_materias/0
          ]).

:- meta_predicate
    bucle_menu(1, +, -).

:- use_module(pantalla).
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module('../../capitulo-31/inscripciones/informes').

%!  menu_de_materias is det.
%
%   Muestra el menú en la terminal y lo recorre con las teclas.
menu_de_materias :-
    con_pantalla(bucle_menu(get_single_char, menu(1, materias), _)).

%!  bucle_menu(:Siguiente, +Menu0, -Menu) is det.
%
%   Dibuja Menu0 y, hasta que la vista sea salir, lee una tecla de
%   Siguiente y la aplica.
bucle_menu(_, menu(N, salir), menu(N, salir)) :-
    !.
bucle_menu(Siguiente, Menu0, Menu) :-
    pantalla_menu(Menu0, Lineas),
    dibujar(Lineas),
    leer_tecla(Siguiente, Tecla),
    paso_menu(Tecla, Menu0, Menu1),
    bucle_menu(Siguiente, Menu1, Menu).

%!  materias(-Materias:list(pair)) is det.
%
%   Materias son los pares Codigo-Nombre, en el orden de los hechos.
materias(Materias) :-
    findall(Codigo-Nombre, materia(Codigo, Nombre, _), Materias).

%!  paso_menu(+Tecla, +Menu0, -Menu) is det.
%
%   Menu es Menu0 después de Tecla. En la lista de materias, las flechas
%   mueven la selección, Enter muestra los inscriptos y q sale; en los
%   inscriptos, Enter y q vuelven a la lista. El fin de la entrada sale.
paso_menu(fin, menu(N, _), menu(N, salir)) :-
    !.
paso_menu(Tecla, menu(N0, materias), menu(N, Vista)) :-
    !,
    materias(Materias),
    length(Materias, Cantidad),
    en_la_lista(Tecla, N0, Cantidad, N, Vista).
paso_menu(Tecla, menu(N, inscriptos), menu(N, materias)) :-
    memberchk(Tecla, [enter, letra(q)]),
    !.
paso_menu(_, Menu, Menu).

%!  en_la_lista(+Tecla, +N0:integer, +Cantidad:integer, -N:integer,
%!              -Vista:atom) is det.
%
%   N y Vista resultan de Tecla en la lista de Cantidad materias.
en_la_lista(arriba, N0, _, N, materias) :-
    !,
    N is max(1, N0 - 1).
en_la_lista(abajo, N0, Cantidad, N, materias) :-
    !,
    N is min(Cantidad, N0 + 1).
en_la_lista(enter, N, _, N, inscriptos) :-
    !.
en_la_lista(letra(q), N, _, N, salir) :-
    !.
en_la_lista(_, N, _, N, materias).

%!  pantalla_menu(+Menu, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Menu: la lista de materias con la elegida
%   marcada, o los inscriptos de la elegida con su promedio.
pantalla_menu(menu(N, Vista), Lineas) :-
    pantalla_vista(Vista, N, Lineas).

%!  pantalla_vista(+Vista:atom, +N:integer, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Vista con la materia N elegida.
pantalla_vista(materias, N, Lineas) :-
    materias(Materias),
    foldl(linea_de_materia(N), Materias, Filas, 1, _),
    caja("Materias", Filas, Caja),
    append(Caja, ["Flechas: elegir  Enter: inscriptos  q: salir"], Lineas).
pantalla_vista(inscriptos, N, Lineas) :-
    materias(Materias),
    nth1(N, Materias, Codigo-Nombre),
    inscriptos(Codigo, Legajos),
    (   Legajos == []
    ->  Filas = ["Sin inscriptos"]
    ;   maplist(linea_de_inscripto(Codigo), Legajos, Filas)
    ),
    (   promedio_de_materia(Codigo, P)
    ->  format(string(Promedio), "Promedio: ~2f", [P])
    ;   Promedio = "Promedio: sin notas"
    ),
    format(string(Titulo), "Inscriptos en ~w", [Nombre]),
    append(Filas, ["", Promedio], Contenido),
    caja(Titulo, Contenido, Caja),
    append(Caja, ["Enter o q: volver"], Lineas).

%!  linea_de_materia(+Elegida:integer, +Materia:pair, -Linea:string,
%!                   +N0:integer, -N:integer) is det.
%
%   Linea muestra la materia número N0, con > si es la Elegida, y la
%   cantidad de inscriptos. N es N0 + 1.
linea_de_materia(Elegida, Codigo-Nombre, Linea, N0, N) :-
    N is N0 + 1,
    (   N0 =:= Elegida
    ->  Marca = ">"
    ;   Marca = " "
    ),
    inscriptos(Codigo, Legajos),
    length(Legajos, Cantidad),
    format(string(Linea), "~w ~w~t~6|~w~t~22|~t~d~25|",
           [Marca, Codigo, Nombre, Cantidad]).

%!  linea_de_inscripto(+Materia:atom, +Legajo:integer, -Linea:string) is det.
%
%   Linea muestra el legajo, el nombre y el estado del alumno en Materia.
linea_de_inscripto(Materia, Legajo, Linea) :-
    alumno(Legajo, Nombre, _, _),
    once(inscripcion(Legajo, Materia, Estado)),
    (   Estado = nota(Nota)
    ->  format(string(Texto), "nota ~d", [Nota])
    ;   Texto = Estado
    ),
    format(string(Linea), "~d ~w~t~14|~w", [Legajo, Nombre, Texto]).
