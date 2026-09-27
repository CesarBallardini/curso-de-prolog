:- encoding(utf8).

% Pruebas del módulo api (capítulo 30): el servicio arranca en un puerto
% libre al empezar la unidad; cada prueba lo llama por HTTP, y las que
% inscriben restauran el estado.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).
:- use_module(datos).

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

%!  url(+Ruta:atom, -Url:atom) is det.
%
%   Url es la dirección de Ruta en el servicio de las pruebas.
url(Ruta, Url) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]).

%!  obtener(+Ruta:atom, -Codigo:integer, -Respuesta) is det.
%
%   Hace GET a Ruta; Codigo es el código de estado y Respuesta el JSON.
obtener(Ruta, Codigo, Respuesta) :-
    url(Ruta, Url),
    setup_call_cleanup(
        http_open(Url, Stream,
                  [ status_code(Codigo),
                    request_header('Accept'='application/json') ]),
        json_read_dict(Stream, Respuesta),
        close(Stream)).

%!  inscribir_por_http(+Cuerpo:dict, -Codigo:integer, -Respuesta:dict)
%!      is det.
%
%   Hace POST /inscripciones con Cuerpo como JSON.
inscribir_por_http(Cuerpo, Codigo, Respuesta) :-
    url('/inscripciones', Url),
    http_post(Url, json(Cuerpo), Respuesta,
              [ status_code(Codigo), json_object(dict),
                request_header('Accept'='application/json') ]).

:- begin_tests(api, [ setup(arrancar_para_pruebas),
                      cleanup(parar_despues_de_pruebas) ]).

test(alumnos, true(C-N-Primero == 200-7-"ana")) :-
    obtener('/alumnos', C, Alumnos),
    length(Alumnos, N),
    [A|_] = Alumnos,
    Primero = A.nombre.

test(alumno, true(C-Carrera == 200-"sistemas")) :-
    obtener('/alumnos/101', C, A),
    Carrera = A.carrera.

test(alumno_inexistente, true(C == 404)) :-
    obtener('/alumnos/999', C, _).

test(legajo_no_numerico, true(C == 400)) :-
    obtener('/alumnos/abc', C, _).

test(promedio, true(C-P == 200-6.25)) :-
    obtener('/materias/am1/promedio', C, R),
    P = R.promedio.

test(promedio_sin_notas, true(C-P == 200-null)) :-
    obtener('/materias/ssl/promedio', C, R),
    P = R.promedio.

test(materia_inexistente, true(C == 404)) :-
    obtener('/materias/quimica/promedio', C, _).

test(ranking, true(C-Primero == 200-101)) :-
    obtener('/ranking', C, [F|_]),
    Primero = F.legajo.

test(inscripcion_aceptada, [ setup(estado(E)), cleanup(restaurar(E)),
                             true(C-A-Inscriptos == 201-true-1) ]) :-
    inscribir_por_http(_{legajo: 104, materia: ssl}, C, R),
    A = R.aceptada,
    obtener('/materias', _, Materias),
    member(M, Materias),
    M.codigo == "ssl",
    !,
    Inscriptos = M.inscriptos.

test(inscripcion_rechazada, true(C-Motivo == 409-"sin_vacantes")) :-
    inscribir_por_http(_{legajo: 105, materia: log}, C, R),
    Motivo = R.motivo.

test(alumno_inexistente_al_inscribir, true(C == 404)) :-
    inscribir_por_http(_{legajo: 999, materia: log}, C, _).

test(legajo_de_otro_tipo, true(C == 400)) :-
    inscribir_por_http(_{legajo: "cien", materia: log}, C, _).

test(cuerpo_incompleto, true(C == 400)) :-
    inscribir_por_http(_{legajo: 104}, C, _).

:- end_tests(api).
