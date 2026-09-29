:- encoding(utf8).

% Capítulo 30 - Soluciones de los ejercicios 10, 11 y 12: el proyecto.
%
% Carga el programa, con el módulo api, y agrega o reemplaza rutas. La ruta
% /ranking se reemplaza declarándola otra vez.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_api(Puerto), detener_api(Puerto).

:- ensure_loaded(inscripciones/inscripciones).
:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).

% --- Ejercicio 10 -----------------------------------------------------------

:- http_handler(root(ranking), ranking_limitado, [method(get)]).

%!  ranking_limitado(+Pedido) is det.
%
%   GET /ranking?limite=N: las N primeras filas del ranking; sin el
%   parámetro, todas. Un límite que no es un entero entre 1 y 1000 responde
%   400. Sin el parámetro, Limite queda libre: var/1, que el capítulo 32
%   presenta, lo distingue.
ranking_limitado(Pedido) :-
    http_parameters(Pedido,
                    [limite(Limite, [between(1, 1000), optional(true)])]),
    ranking_py(Filas),
    (   var(Limite)
    ->  Elegidas = Filas
    ;   length(Filas, Total),
        Cantidad is min(Limite, Total),
        length(Elegidas, Cantidad),
        append(Elegidas, _, Filas)
    ),
    reply_json_dict(Elegidas).

% --- Ejercicio 11 -----------------------------------------------------------

:- http_handler(root(alumnos/Legajo/materias), materias_del_alumno(Legajo),
                [method(get)]).

%!  materias_del_alumno(+Texto:atom, +Pedido) is det.
%
%   GET /alumnos/L/materias: las materias del alumno L, cada una con su nota
%   o con el estado cursando; 404 si el alumno no existe.
materias_del_alumno(Texto, _Pedido) :-
    (   atom_number(Texto, Legajo),
        alumno(Legajo, _, _, _)
    ->  indice_por_alumno(Indice),
        materias_de(Indice, Legajo, Pares),
        maplist(materia_json, Pares, Materias),
        reply_json_dict(Materias)
    ;   reply_json_dict(_{error: "alumno inexistente"}, [status(404)])
    ).

%!  materia_json(+Par:pair, -Materia:dict) is det.
%
%   Materia es el dict del par Materia-Estado.
materia_json(Materia-nota(N), _{materia: Materia, nota: N}).
materia_json(Materia-cursando, _{materia: Materia, estado: cursando}).

% --- Ejercicio 12 -----------------------------------------------------------

:- http_handler(root(inscripciones/Legajo/Materia),
                baja(Legajo, Materia), [method(delete)]).

%!  baja(+Texto:atom, +Materia:atom, +Pedido) is det.
%
%   DELETE /inscripciones/L/M: da de baja al alumno L en la materia M y
%   responde 204, sin cuerpo; 404 si no la cursa.
baja(Texto, Materia, _Pedido) :-
    (   atom_number(Texto, Legajo),
        dar_de_baja(Legajo, Materia)
    ->  throw(http_reply(no_content))
    ;   reply_json_dict(_{error: "no la cursa"}, [status(404)])
    ).
