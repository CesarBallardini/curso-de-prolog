:- encoding(utf8).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module('../../capitulo-31/buscaminas/partida').
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module(inscripciones_xpce, [ventana_inscripciones/1]).

:- begin_tests(soluciones_xpce).

% Las pruebas de los predicados puros corren en cualquier Prolog; las de
% las ventanas, solo donde hay XPCE (ejercicios 8, 9 y 10).

%!  hay_xpce is semidet.
%
%   XPCE está disponible y puede crear objetos.
hay_xpce :-
    exists_source(library(pce)),
    catch(get(@(pce), version, _), _, fail).

%!  sin_cambios(:Objetivo) is semidet.
%
%   Ejecuta Objetivo y restaura después los datos de Inscripciones.
sin_cambios(Objetivo) :-
    estado(E),
    setup_call_cleanup(true, Objetivo, restaurar(E)).

%!  elemento(+Ventana, +Nombre:atom, -Objeto) is det.
%
%   Objeto es el elemento Nombre del diálogo de Ventana.
elemento(Ventana, Nombre, Objeto) :-
    get(Ventana, member, dialog, D),
    get(D, member, Nombre, Objeto).

%!  filas(+Ventana, +Lista:atom, -N:integer) is det.
%
%   N es la cantidad de líneas de la lista Lista de Ventana.
filas(Ventana, Lista, N) :-
    get(Ventana, member, Lista, Browser),
    get(Browser, members, Filas),
    get(Filas, size, N).

test(sugerencia, true(T == "Celda segura: fila 3, columna 2")) :-
    partida_con_minas(4, 4, [1-1, 3-3], P0),
    jugar(descubrir, 1-4, P0, P),
    texto_de_sugerencia(P, T).

test(sin_sugerencia, true(T == "No hay ninguna celda segura a la vista")) :-
    partida_con_minas(3, 3, [1-1], P),
    texto_de_sugerencia(P, T).

test(inscriptos, true(L-V == ["101  ana", "102  bruno", "104  diego",
                              "106  facundo"]-[])) :-
    lineas_de_inscriptos(log, L),
    lineas_de_inscriptos(bd, V).

% Ejercicio 8: el clic en 1-4 descubre una región; el ítem del menú
% escribe la celda segura en el rótulo.
test(item_sugerencia, [ condition(hay_xpce),
                        cleanup(send(V, destroy)),
                        true(R == 'Celda segura: fila 3, columna 2') ]) :-
    partida_con_minas(4, 4, [1-1, 3-3], P),
    ventana_con_sugerencia(P, V),
    get(V, member, tablero, Tablero),
    get(Tablero, member, c_1_4, Boton),
    send(Boton, execute),
    get(V, member, controles, Controles),
    get(Controles, member, menu_bar, Barra),
    get(Barra, member, juego, Juego),
    get(Juego, member, sugerencia, Item),
    get(Item, message, Mensaje),
    send(Mensaje, execute),
    get(Controles, member, estado, Rotulo),
    get(Rotulo, selection, R).

% Ejercicio 9: al elegir una materia, el menú reenvía su mensaje con la
% selección, como lo hace XPCE con un clic.
test(lista_de_inscriptos, [ condition(hay_xpce),
                            cleanup(send(V, destroy)),
                            true(N == [5, 4, 0, 1]) ]) :-
    ventana_con_inscriptos(V),
    filas(V, inscriptos, N1),
    elemento(V, materia, Menu),
    get(Menu, message, Mensaje),
    send(Menu, selection, log),
    send(Mensaje, forward, log),
    filas(V, inscriptos, N2),
    send(Menu, selection, ssl),
    send(Mensaje, forward, ssl),
    filas(V, inscriptos, N3),
    elemento(V, legajo, Campo),
    send(Campo, selection, '104'),
    elemento(V, inscribir, Boton),
    sin_cambios(( send(Boton, execute),
                  filas(V, inscriptos, N4) )),
    N = [N1, N2, N3, N4].

% Ejercicio 10: el rechazo, sin cambiar los datos.
test(rechazo_en_la_ventana,
     [ condition(hay_xpce),
       cleanup(send(V, destroy)),
       true(R == 'Inscripción rechazada: 103 en ssl, falta(log)') ]) :-
    ventana_inscripciones(V),
    elemento(V, legajo, Campo),
    send(Campo, selection, '103'),
    elemento(V, materia, Menu),
    send(Menu, selection, ssl),
    elemento(V, inscribir, Boton),
    sin_cambios(send(Boton, execute)),
    elemento(V, resultado, Rotulo),
    get(Rotulo, selection, R).

:- end_tests(soluciones_xpce).
