:- encoding(utf8).

% Pruebas de las soluciones de los ejercicios 10 a 12: el servicio, con las
% rutas de soluciones_proyecto.pl, arranca en un puerto libre.

:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(inscripciones/datos).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servicio en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_api(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servicio de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_api(Puerto).

%!  pedir(+Metodo:atom, +Ruta:atom, -Codigo:integer, -Cuerpo:string) is det.
%
%   Hace el pedido Metodo a Ruta; Cuerpo es el texto de la respuesta.
pedir(Metodo, Ruta, Codigo, Cuerpo) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]),
    setup_call_cleanup(
        http_open(Url, Stream, [ method(Metodo), status_code(Codigo),
                                 request_header('Accept'='application/json') ]),
        read_string(Stream, _, Cuerpo),
        close(Stream)).

%!  json(+Ruta:atom, -Codigo:integer, -Respuesta) is det.
%
%   Hace GET a Ruta y lee la respuesta como JSON.
json(Ruta, Codigo, Respuesta) :-
    pedir(get, Ruta, Codigo, Cuerpo),
    atom_json_dict(Cuerpo, Respuesta, []).

:- begin_tests(soluciones_proyecto, [ setup(arrancar_para_pruebas),
                                      cleanup(parar_despues_de_pruebas) ]).

% Ejercicio 10.
test(ranking_limitado, true(C-N == 200-2)) :-
    json('/ranking?limite=2', C, Filas),
    length(Filas, N).

test(ranking_sin_limite, true(N == 5)) :-
    json('/ranking', 200, Filas),
    length(Filas, N).

test(limite_mayor_que_el_ranking, true(N == 5)) :-
    json('/ranking?limite=99', 200, Filas),
    length(Filas, N).

test(limite_cero, true(C == 400)) :-
    pedir(get, '/ranking?limite=0', C, _).

% Ejercicio 11: el alumno 101, con cuatro notas y una materia en curso.
test(materias_del_alumno, true(C-N-Cursando == 200-5-["pp"])) :-
    json('/alumnos/101/materias', C, Materias),
    length(Materias, N),
    findall(M, ( member(D, Materias),
                 get_dict(estado, D, "cursando"),
                 get_dict(materia, D, M) ),
            Cursando).

test(materias_de_alumno_inexistente, true(C == 404)) :-
    pedir(get, '/alumnos/999/materias', C, _).

% La ruta del capítulo sigue funcionando junto a la nueva.
test(alumno_sigue, true(C == 200)) :-
    pedir(get, '/alumnos/101', C, _).

% Ejercicio 12.
test(baja, [ setup(estado(E)), cleanup(restaurar(E)),
             true(Codigos == [204, 404]) ]) :-
    pedir(delete, '/inscripciones/101/pp', C1, Cuerpo),
    assertion(Cuerpo == ""),
    pedir(delete, '/inscripciones/101/pp', C2, _),
    Codigos = [C1, C2].

:- end_tests(soluciones_proyecto).
