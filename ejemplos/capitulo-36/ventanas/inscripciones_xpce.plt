:- encoding(utf8).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module('../../capitulo-31/inscripciones/datos').

:- begin_tests(inscripciones_xpce).

% Las pruebas del núcleo corren en cualquier Prolog; las de la ventana,
% solo donde hay XPCE. Cada prueba que inscribe deja los datos como
% estaban.

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

test(ranking, true(L == ["101  ana        8.50", "104  diego      8.00",
                         "103  carla      6.00", "106  facundo    4.50",
                         "102  bruno      4.00"])) :-
    lineas_de_ranking(L).

test(aceptada, true(M == "Inscripción aceptada: 104 en ssl")) :-
    sin_cambios(mensaje_de_inscripcion('104', ssl, M)).

test(rechazada, true(M == "Inscripción rechazada: 103 en ssl, falta(log)")) :-
    sin_cambios(mensaje_de_inscripcion('103', ssl, M)).

test(no_es_numero, true(M == "El legajo 'abc' no es un número")) :-
    sin_cambios(mensaje_de_inscripcion(abc, ssl, M)).

% Un legajo con decimales tampoco llega a inscribir/3.
test(no_es_entero, true(M == "El legajo '104.5' no es un número")) :-
    sin_cambios(mensaje_de_inscripcion('104.5', ssl, M)).

% La inscripción aceptada queda en los datos.
test(aceptada_inscribe, true(L == [104])) :-
    sin_cambios(( mensaje_de_inscripcion('104', ssl, _),
                  informes:inscriptos(ssl, L) )).

test(ventana, [ condition(hay_xpce),
                cleanup(send(V, destroy)),
                true(X == [5, '101  ana        8.50', 'Inscripción aceptada: \c
                                                   104 en ssl']) ]) :-
    ventana_inscripciones(V),
    get(V, member, ranking, Lista),
    get(Lista, members, Filas),
    get(Filas, size, N),
    get(Filas, head, Primera),
    get(Primera, key, Texto),
    elemento(V, legajo, Campo),
    send(Campo, selection, '104'),
    elemento(V, materia, Menu),
    send(Menu, selection, ssl),
    elemento(V, inscribir, Boton),
    sin_cambios(send(Boton, execute)),
    elemento(V, resultado, Rotulo),
    get(Rotulo, selection, R),
    X = [N, Texto, R].

test(exportar, [ condition(hay_xpce),
                 cleanup(( send(V, destroy), delete_file(Archivo) )),
                 true(Primera == "Legajo  Nombre        Promedio") ]) :-
    ventana_inscripciones(V),
    tmp_file_stream(text, Archivo, S),
    close(S),
    inscripciones_xpce:exportar(V, Archivo),
    read_file_to_string(Archivo, Contenido, []),
    split_string(Contenido, "\n", "", [Primera|_]).

:- end_tests(inscripciones_xpce).
