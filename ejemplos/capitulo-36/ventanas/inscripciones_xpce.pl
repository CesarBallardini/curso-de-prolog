:- encoding(utf8).

% Capítulo 36 - La ventana de Inscripciones en XPCE, sobre los módulos del
% capítulo 31.
%
% Un formulario con el legajo, la materia y el botón Inscribir; el ranking
% en una lista; el menú Archivo exporta el ranking y cierra la ventana. Los
% predicados que la ventana llama, mensaje_de_inscripcion/3 y
% lineas_de_ranking/1, no dependen de XPCE y se prueban en cualquier
% Prolog.
%
% solo-local: SWISH no tiene XPCE ni admite módulos propios.
%
%?- abrir_inscripciones.

:- module(inscripciones_xpce,
          [ mensaje_de_inscripcion/3,
            lineas_de_ranking/1,
            ventana_inscripciones/1,
            abrir_inscripciones/0
          ]).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module('../../capitulo-31/inscripciones/reglas').
:- use_module('../../capitulo-31/inscripciones/informes').
:- use_module('../../capitulo-31/inscripciones/intercambio').

%!  mensaje_de_inscripcion(+Legajo:atom, +Materia:atom, -Mensaje:string)
%!      is det.
%
%   Inscribe al alumno Legajo, escrito como texto, en Materia con
%   inscribir/3, y Mensaje dice el resultado. Un legajo que no es un número
%   no llega a inscribir/3.
mensaje_de_inscripcion(Legajo, Materia, Mensaje) :-
    (   atom_number(Legajo, L),
        integer(L)
    ->  inscribir(L, Materia, Resultado),
        texto_del_resultado(Resultado, L, Materia, Mensaje)
    ;   format(string(Mensaje), "El legajo '~w' no es un número", [Legajo])
    ).

%!  texto_del_resultado(+Resultado, +Legajo:integer, +Materia:atom,
%!                      -Mensaje:string) is det.
%
%   Mensaje describe el Resultado de inscribir/3.
texto_del_resultado(aceptada, L, Materia, Mensaje) :-
    format(string(Mensaje), "Inscripción aceptada: ~d en ~w", [L, Materia]).
texto_del_resultado(rechazada(Motivo), L, Materia, Mensaje) :-
    format(string(Mensaje), "Inscripción rechazada: ~d en ~w, ~w",
           [L, Materia, Motivo]).

%!  lineas_de_ranking(-Lineas:list(string)) is det.
%
%   Lineas son las filas del ranking: legajo, nombre y promedio.
lineas_de_ranking(Lineas) :-
    ranking(Ranking),
    findall(Linea,
            ( member(Legajo-Promedio, Ranking),
              alumno(Legajo, Nombre, _, _),
              format(string(Linea), "~d  ~w~t~16|~2f",
                     [Legajo, Nombre, Promedio]) ),
            Lineas).

%!  abrir_inscripciones is det.
%
%   Abre la ventana.
abrir_inscripciones :-
    ventana_inscripciones(Ventana),
    send(Ventana, open).

%!  ventana_inscripciones(-Ventana) is det.
%
%   Ventana es un frame de XPCE, todavía sin abrir: el menú Archivo, el
%   formulario de inscripción y la lista del ranking.
ventana_inscripciones(Ventana) :-
    new(Ventana, frame('Inscripciones')),
    send(Ventana, append, new(D, dialog)),
    send(D, append, new(Barra, menu_bar)),
    send(Barra, append, new(Archivo, popup(archivo))),
    send_list(Archivo, append,
              [ menu_item(exportar_ranking,
                          message(@(prolog), exportar, Ventana,
                                  'ranking.txt')),
                menu_item(salir, message(Ventana, destroy))
              ]),
    send(D, append, text_item(legajo, '')),
    send(D, append, new(Materias, menu(materia, cycle))),
    forall(materia(Codigo, _, _), send(Materias, append, Codigo)),
    send(D, append,
         button(inscribir, message(@(prolog), inscribir_desde, Ventana))),
    send(D, append, label(resultado, '')),
    send(new(Lista, browser), below, D),
    send(Lista, name, ranking),
    mostrar_ranking(Ventana).

%!  inscribir_desde(+Ventana) is det.
%
%   Responde al botón Inscribir: lee el formulario, llama a
%   mensaje_de_inscripcion/3 y muestra el mensaje.
inscribir_desde(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, legajo, Campo),
    get(Campo, selection, Legajo),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    mensaje_de_inscripcion(Legajo, Materia, Mensaje),
    mostrar_resultado(Ventana, Mensaje).

%!  exportar(+Ventana, +Archivo) is det.
%
%   Responde a Archivo > Exportar ranking: escribe el ranking en Archivo
%   con exportar_ranking/1, del capítulo 27, y lo informa.
exportar(Ventana, Archivo) :-
    exportar_ranking(Archivo),
    format(string(Mensaje), "Ranking exportado a ~w", [Archivo]),
    mostrar_resultado(Ventana, Mensaje).

%!  mostrar_resultado(+Ventana, +Mensaje:string) is det.
%
%   Pone Mensaje en el rótulo del resultado.
mostrar_resultado(Ventana, Mensaje) :-
    get(Ventana, member, dialog, D),
    get(D, member, resultado, Rotulo),
    atom_string(Atomo, Mensaje),
    send(Rotulo, selection, Atomo).

%!  mostrar_ranking(+Ventana) is det.
%
%   Llena la lista de Ventana con lineas_de_ranking/1.
mostrar_ranking(Ventana) :-
    get(Ventana, member, ranking, Lista),
    send(Lista, clear),
    lineas_de_ranking(Lineas),
    forall(member(Linea, Lineas),
           ( atom_string(Atomo, Linea),
             send(Lista, append, Atomo) )).
