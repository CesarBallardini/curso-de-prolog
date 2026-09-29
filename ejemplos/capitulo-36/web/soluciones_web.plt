:- encoding(utf8).

% Pruebas de las soluciones 11, 12 y 13: un solo servidor, en un puerto
% libre, sirve las páginas, las rutas de JSON de Inscripciones y el
% servicio del Buscaminas; las páginas del tablero le piden los datos a él.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module('../../capitulo-31/buscaminas/servicio').
:- use_module('../../capitulo-31/buscaminas/partida').
:- use_module('../../capitulo-31/buscaminas/tablero').
:- use_module('../../capitulo-31/inscripciones/datos').
:- use_module(paginas_inscripciones, [iniciar_api/1, detener_api/1]).
:- use_module(tablero_web, [usar_servicio/1]).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y dirige las páginas del
%   tablero a él.
arrancar_para_pruebas :-
    iniciar_api(Puerto),
    format(atom(Base), "http://127.0.0.1:~w", [Puerto]),
    usar_servicio(Base),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_api(Puerto).

%!  url(+Ruta:atom, -Url:atom) is det.
%
%   Url es la dirección de Ruta en el servidor de las pruebas.
url(Ruta, Url) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]).

%!  pedir(+Ruta:atom, +Opciones:list, -Codigo:integer, -Final:atom,
%!        -Texto:string) is det.
%
%   Hace el pedido y sigue las redirecciones: Codigo, Final y Texto son el
%   código, la dirección y el cuerpo de la última respuesta.
pedir(Ruta, Opciones, Codigo, Final, Texto) :-
    url(Ruta, Url),
    setup_call_cleanup(
        http_open(Url, S, [ status_code(Codigo), final_url(Final)
                          | Opciones ]),
        read_string(S, _, Texto),
        close(S)).

%!  contiene(+Texto:string, +Parte:string) is semidet.
%
%   Parte aparece en Texto.
contiene(Texto, Parte) :-
    once(sub_string(Texto, _, _, _, Parte)).

:- begin_tests(soluciones_web, [ setup(arrancar_para_pruebas),
                                 cleanup(parar_despues_de_pruebas) ]).

test(cuerpo_alumno, true(P == p('Promedio: 8.50'))) :-
    cuerpo_alumno(101, [_, _, _, P]).

test(pagina_alumno, true(C == 200)) :-
    pedir('/pagina/alumnos/101', [], C, _, T),
    contiene(T, "<li>pp: cursando</li>"),
    contiene(T, "Carrera: sistemas").

test(alumno_inexistente, true(C-D == 404-404)) :-
    pedir('/pagina/alumnos/999', [], C, _, _),
    pedir('/pagina/alumnos/abc', [], D, _, _).

% La redirección lleva a la página de la materia, con el mensaje en la
% dirección y en la página; el alumno ya figura entre los inscriptos.
test(redireccion, true(C == 200)) :-
    estado(E),
    setup_call_cleanup(
        true,
        pedir('/pagina/inscribir',
              [method(post), post(form([legajo='104', materia=ssl]))],
              C, Final, T),
        restaurar(E)),
    once(sub_atom(Final, _, _, _, '/pagina/materias/ssl?mensaje=')),
    contiene(T, "Aceptada: 104 en ssl."),
    contiene(T, "<li>104 diego</li>").

test(materia_sin_mensaje, true(C == 200)) :-
    pedir('/pagina/materias/log', [], C, _, T),
    \+ contiene(T, "Aceptada").

% La página de la sugerencia dice lo mismo que sugerencia/2 sobre la misma
% partida: la de semilla 7, después de descubrir una celda sin minas
% vecinas.
test(sugerencia, true(C == 200)) :-
    nueva_partida(9, 9, 10, 7, P0),
    P0 = partida(Tablero, _, _, _),
    once(( between(1, 9, F), between(1, 9, Co), valor(Tablero, F-Co, 0) )),
    jugar(descubrir, F-Co, P0, P),
    (   sugerencia(P, SF-SC)
    ->  format(string(Esperado), "Celda segura: fila ~d, columna ~d",
               [SF, SC])
    ;   Esperado = "No hay ninguna celda segura a la vista"
    ),
    url('/partidas', Crear),
    http_post(Crear, json(_{filas: 9, columnas: 9, minas: 10, semilla: 7}),
              Nueva, [json_object(dict)]),
    format(atom(Jugada), "/partidas/~w/descubrir", [Nueva.id]),
    url(Jugada, UrlJugada),
    http_post(UrlJugada, json(_{fila: F, columna: Co}), _,
              [json_object(dict)]),
    format(atom(Ruta), "/juego/~w/sugerencia", [Nueva.id]),
    pedir(Ruta, [], C, _, T),
    contiene(T, Esperado),
    contiene(T, "value=\"Sugerencia\"").

test(texto_del_resultado, true(T == 'Rechazada: 103 en ssl, falta(log).')) :-
    texto_del_resultado(103, ssl-rechazada(falta(log)), T).

% En una partida nueva no hay ninguna celda segura a la vista: el servicio
% responde 404 y la página lo dice.
test(sin_sugerencia, true(C == 200)) :-
    url('/partidas', Crear),
    http_post(Crear, json(_{filas: 9, columnas: 9, minas: 10, semilla: 7}),
              Nueva, [json_object(dict)]),
    format(atom(Ruta), "/juego/~w/sugerencia", [Nueva.id]),
    pedir(Ruta, [], C, _, T),
    contiene(T, "No hay ninguna celda segura a la vista").

:- end_tests(soluciones_web).
