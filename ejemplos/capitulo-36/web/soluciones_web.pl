:- encoding(utf8).

% Capítulo 36 - Soluciones de los ejercicios 11, 12 y 13: la página de un
% alumno, el formulario con redirección y la sugerencia en el tablero.
%
% El módulo carga las páginas de web/ y les agrega rutas. Las del ejercicio
% 12 reemplazan dos rutas de paginas_inscripciones.pl con la opción
% priority(1) de http_handler/3: entre dos manejadores de la misma ruta,
% se usa el de prioridad mayor.
%
%     GET  /pagina/alumnos/{legajo}          ejercicio 11
%     POST /pagina/inscribir                 ejercicio 12: 303 a la materia
%     GET  /pagina/materias/{codigo}         ejercicio 12: con ?mensaje=
%     GET  /juego/{id}/sugerencia            ejercicio 13
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- cuerpo_alumno(101, C).

:- module(soluciones_web,
          [ cuerpo_alumno/2,
            texto_del_resultado/3,
            cuerpo_con_sugerencia/4
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(http/html_write)).
:- use_module(library(uri)).
:- use_module(paginas_inscripciones).
:- use_module(tablero_web).
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module('../../capitulo-31/inscripciones/reglas').
:- use_module('../../capitulo-31/inscripciones/informes').

:- http_handler(root(pagina/alumnos/Legajo), pagina_alumno(Legajo),
                [method(get)]).
:- http_handler(root(pagina/inscribir), inscribir_y_volver,
                [method(post), priority(1)]).
:- http_handler(root(pagina/materias/Codigo), materia_con_mensaje(Codigo),
                [method(get), priority(1)]).
:- http_handler(root(juego/Id/sugerencia), pagina_sugerencia(Id),
                [method(get)]).

% --- Ejercicio 11 -----------------------------------------------------------

%!  pagina_alumno(+Texto:atom, +Pedido) is det.
%
%   GET /pagina/alumnos/Texto: la página del alumno, o 404 si Texto no es
%   el legajo de un alumno.
pagina_alumno(Texto, Pedido) :-
    (   atom_number(Texto, Legajo),
        integer(Legajo),
        cuerpo_alumno(Legajo, Cuerpo)
    ->  reply_html_page(title(Texto), Cuerpo)
    ;   http_404([], Pedido)
    ).

%!  cuerpo_alumno(+Legajo:integer, -Cuerpo) is semidet.
%
%   Cuerpo es la página del alumno Legajo: nombre, carrera, materias con su
%   estado y promedio. Falla si el alumno no existe.
cuerpo_alumno(Legajo, [ h1([Legajo, ' ', Nombre]),
                        p(['Carrera: ', Carrera]),
                        ul(Items),
                        p(Promedio)
                      ]) :-
    alumno(Legajo, Nombre, Carrera, _),
    indice_por_alumno(Indice),
    materias_de(Indice, Legajo, Materias),
    findall(li([Materia, ': ', Texto]),
            ( member(Materia-Estado, Materias),
              texto_de_estado(Estado, Texto) ),
            Items),
    (   promedio_de_alumno(Legajo, P)
    ->  format(atom(Promedio), "Promedio: ~2f", [P])
    ;   Promedio = 'Promedio: sin notas'
    ).

%!  texto_de_estado(+Estado, -Texto:atom) is det.
%
%   Texto describe el estado de una inscripción.
texto_de_estado(nota(N), Texto) :-
    !,
    format(atom(Texto), "nota ~d", [N]).
texto_de_estado(Estado, Estado).

% --- Ejercicio 12 -----------------------------------------------------------

%!  inscribir_y_volver(+Pedido) is det.
%
%   POST /pagina/inscribir: inscribe y responde 303 a la página de la
%   materia, con el resultado en el parámetro mensaje.
inscribir_y_volver(Pedido) :-
    http_parameters(Pedido, [ legajo(Legajo, [integer]),
                              materia(Materia, [atom]) ]),
    inscribir(Legajo, Materia, Resultado),
    texto_del_resultado(Legajo, Materia-Resultado, Texto),
    uri_query_components(Consulta, [mensaje=Texto]),
    format(atom(Destino), "/pagina/materias/~w?~w", [Materia, Consulta]),
    http_redirect(see_other, Destino, Pedido).

%!  texto_del_resultado(+Legajo:integer, +Inscripcion:pair, -Texto:atom)
%!      is det.
%
%   Texto describe el resultado de una inscripción, como en
%   cuerpo_resultado/3.
texto_del_resultado(Legajo, Materia-aceptada, Texto) :-
    !,
    format(atom(Texto), "Aceptada: ~w en ~w.", [Legajo, Materia]).
texto_del_resultado(Legajo, Materia-rechazada(Motivo), Texto) :-
    format(atom(Texto), "Rechazada: ~w en ~w, ~w.", [Legajo, Materia, Motivo]).

%!  materia_con_mensaje(+Codigo:atom, +Pedido) is det.
%
%   GET /pagina/materias/Codigo, con el parámetro opcional mensaje debajo
%   del título; 404 si la materia no existe.
materia_con_mensaje(Codigo, Pedido) :-
    http_parameters(Pedido, [mensaje(Mensaje, [optional(true)])]),
    (   cuerpo_materia(Codigo, [Titulo|Resto])
    ->  (   var(Mensaje)
        ->  Cuerpo = [Titulo|Resto]
        ;   Cuerpo = [Titulo, p(Mensaje)|Resto]
        ),
        reply_html_page(title(Codigo), Cuerpo)
    ;   http_404([], Pedido)
    ).

% --- Ejercicio 13 -----------------------------------------------------------

%!  pagina_sugerencia(+Id:atom, +Pedido) is det.
%
%   GET /juego/Id/sugerencia: el tablero con la celda segura que da el
%   servicio, o con el aviso de que no hay ninguna.
pagina_sugerencia(Id, _Pedido) :-
    servicio(Base),
    format(atom(Tablero), "~w/partidas/~w", [Base, Id]),
    format(atom(Pregunta), "~w/partidas/~w/sugerencia", [Base, Id]),
    leer_json(Tablero, _, Respuesta),
    leer_json(Pregunta, Codigo, Celda),
    (   Codigo == 200
    ->  format(atom(Mensaje), "Celda segura: fila ~w, columna ~w",
               [Celda.fila, Celda.columna])
    ;   Mensaje = 'No hay ninguna celda segura a la vista'
    ),
    cuerpo_con_sugerencia(Id, Respuesta, Mensaje, Cuerpo),
    reply_html_page(title('Buscaminas'), Cuerpo).

%!  leer_json(+Url:atom, -Codigo:integer, -Dict:dict) is det.
%
%   Pide Url con GET; Codigo es el código de estado y Dict el JSON de la
%   respuesta.
leer_json(Url, Codigo, Dict) :-
    setup_call_cleanup(http_open(Url, S, [status_code(Codigo)]),
                       json_read_dict(S, Dict),
                       close(S)).

%!  cuerpo_con_sugerencia(+Id, +Respuesta:dict, +Mensaje:atom, -Cuerpo)
%!      is det.
%
%   Cuerpo es la página del tablero de cuerpo_tablero/3, con el botón
%   Sugerencia, un formulario que se envía con GET, y el Mensaje debajo.
cuerpo_con_sugerencia(Id, Respuesta, Mensaje, Cuerpo) :-
    cuerpo_tablero(Id, Respuesta, Tablero),
    format(atom(Accion), "/juego/~w/sugerencia", [Id]),
    append(Tablero,
           [ form([action(Accion), method(get)],
                  input([type(submit), value('Sugerencia')])),
             p(Mensaje)
           ],
           Cuerpo).
