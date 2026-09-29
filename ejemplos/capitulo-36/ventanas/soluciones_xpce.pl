:- encoding(utf8).

% Capítulo 36 - Soluciones de los ejercicios 8 y 9: la sugerencia en la
% ventana del Buscaminas y los inscriptos en la de Inscripciones.
%
% Las dos ventanas se construyen con los predicados de buscaminas_xpce.pl
% e inscripciones_xpce.pl y se amplían con send/3: un ítem más en el menú
% Juego, una lista más debajo del formulario. Lo que se muestra lo calculan
% predicados puros, texto_de_sugerencia/2 y lineas_de_inscriptos/2, que se
% prueban en cualquier Prolog.
%
% solo-local: SWISH no tiene XPCE ni admite módulos propios.
%
%?- lineas_de_inscriptos(log, L).

:- module(soluciones_xpce,
          [ texto_de_sugerencia/2,
            lineas_de_inscriptos/2,
            ventana_con_sugerencia/2,
            ventana_con_inscriptos/1
          ]).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module(buscaminas_xpce).
:- use_module(inscripciones_xpce).
:- use_module('../../capitulo-31/buscaminas/partida').
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module('../../capitulo-31/inscripciones/informes').

% --- Ejercicio 8 ------------------------------------------------------------

%!  texto_de_sugerencia(+Partida, -Texto:string) is det.
%
%   Texto dice la celda segura que da sugerencia/2, o que no hay ninguna.
texto_de_sugerencia(Partida, Texto) :-
    (   sugerencia(Partida, F-C)
    ->  format(string(Texto), "Celda segura: fila ~d, columna ~d", [F, C])
    ;   Texto = "No hay ninguna celda segura a la vista"
    ).

%!  ventana_con_sugerencia(+Partida, -Ventana) is det.
%
%   Ventana es la del Buscaminas con el ítem sugerencia en el menú Juego.
ventana_con_sugerencia(Partida, Ventana) :-
    ventana_con_partida(Partida, Ventana),
    get(Ventana, member, controles, Controles),
    get(Controles, member, menu_bar, Barra),
    get(Barra, member, juego, Juego),
    send(Juego, append,
         menu_item(sugerencia, message(@(prolog), sugerir, Ventana))).

%!  sugerir(+Ventana) is det.
%
%   Responde al ítem sugerencia: escribe en el rótulo el texto de
%   texto_de_sugerencia/2 para la partida de Ventana.
sugerir(Ventana) :-
    partida_de(Ventana, Partida),
    texto_de_sugerencia(Partida, Texto),
    atom_string(Atomo, Texto),
    get(Ventana, member, controles, Controles),
    get(Controles, member, estado, Rotulo),
    send(Rotulo, selection, Atomo).

% --- Ejercicio 9 ------------------------------------------------------------

%!  lineas_de_inscriptos(+Materia:atom, -Lineas:list(string)) is det.
%
%   Lineas son los inscriptos en Materia, con el legajo y el nombre.
lineas_de_inscriptos(Materia, Lineas) :-
    inscriptos(Materia, Legajos),
    findall(Linea,
            ( member(Legajo, Legajos),
              alumno(Legajo, Nombre, _, _),
              format(string(Linea), "~d  ~w", [Legajo, Nombre]) ),
            Lineas).

%!  ventana_con_inscriptos(-Ventana) is det.
%
%   Ventana es la de Inscripciones con una lista más, inscriptos, que
%   muestra los inscriptos de la materia elegida. El menú de materias y el
%   botón Inscribir la actualizan.
ventana_con_inscriptos(Ventana) :-
    ventana_inscripciones(Ventana),
    get(Ventana, member, dialog, D),
    get(Ventana, member, ranking, Ranking),
    send(new(Lista, browser), right, Ranking),
    send(Lista, name, inscriptos),
    get(D, member, materia, Menu),
    send(Menu, message, message(@(prolog), mostrar_inscriptos, Ventana)),
    get(D, member, inscribir, Boton),
    send(Boton, message, message(@(prolog), inscribir_y_mostrar, Ventana)),
    mostrar_inscriptos(Ventana).

%!  mostrar_inscriptos(+Ventana) is det.
%
%   Llena la lista inscriptos con los de la materia elegida en el menú.
mostrar_inscriptos(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    get(Ventana, member, inscriptos, Lista),
    send(Lista, clear),
    lineas_de_inscriptos(Materia, Lineas),
    forall(member(Linea, Lineas),
           ( atom_string(Atomo, Linea),
             send(Lista, append, Atomo) )).

%!  inscribir_y_mostrar(+Ventana) is det.
%
%   Responde al botón Inscribir como la ventana original, y después
%   actualiza la lista de inscriptos.
inscribir_y_mostrar(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, legajo, Campo),
    get(Campo, selection, Legajo),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    mensaje_de_inscripcion(Legajo, Materia, Mensaje),
    atom_string(Atomo, Mensaje),
    get(D, member, resultado, Rotulo),
    send(Rotulo, selection, Atomo),
    mostrar_inscriptos(Ventana).
