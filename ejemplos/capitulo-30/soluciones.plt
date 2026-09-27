:- encoding(utf8).

% Pruebas de las soluciones: el servidor, con las rutas de soluciones.pl,
% arranca en un puerto libre al empezar la unidad.

:- use_module(library(http/http_open)).
:- use_module(library(http/json)).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener(Puerto).

%!  base(-Base:atom) is det.
%
%   Base es la dirección del servidor de las pruebas.
base(Base) :-
    puerto_de_prueba(Puerto),
    format(atom(Base), "http://127.0.0.1:~w", [Puerto]).

%!  pedir(+Metodo:atom, +Ruta:atom, -Codigo:integer, -Cuerpo:string) is det.
%
%   Hace el pedido Metodo a Ruta; Cuerpo es el texto de la respuesta.
pedir(Metodo, Ruta, Codigo, Cuerpo) :-
    base(Base),
    atom_concat(Base, Ruta, Url),
    setup_call_cleanup(
        http_open(Url, Stream, [ method(Metodo), status_code(Codigo),
                                 request_header('Accept'='application/json') ]),
        read_string(Stream, _, Cuerpo),
        close(Stream)).

%!  json(+Ruta:atom, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace GET a Ruta y lee la respuesta como JSON.
json(Ruta, Codigo, Respuesta) :-
    pedir(get, Ruta, Codigo, Cuerpo),
    atom_json_dict(Cuerpo, Respuesta, []).

:- begin_tests(soluciones, [ setup(arrancar_para_pruebas),
                             cleanup(parar_despues_de_pruebas) ]).

% Ejercicio 1.
test(hijos, true(C-H == 200-["ana", "pedro"])) :-
    json('/hijos/juan', C, R),
    get_dict(hijos, R, H).

test(sin_hijos, true(H == [])) :-
    json('/hijos/eva', 200, R),
    get_dict(hijos, R, H).

% Ejercicio 3.
test(mayores, true(C-P == 200-["juan", "ana"])) :-
    json('/mayores?edad=40', C, R),
    get_dict(personas, R, P).

test(mayores_sin_edad, true(C == 400)) :-
    pedir(get, '/mayores', C, _).

test(mayores_edad_no_entera, true(C == 400)) :-
    pedir(get, '/mayores?edad=cuarenta', C, _).

% Ejercicio 4: la ruta GET sigue funcionando, y DELETE olvida.
test(olvidar, [ cleanup(assertz(edad(eva, 8))),
                true(Codigos == [200, 204, 404, 404]) ]) :-
    pedir(get, '/personas/eva', C1, _),
    pedir(delete, '/personas/eva', C2, Cuerpo),
    assertion(Cuerpo == ""),
    pedir(get, '/personas/eva', C3, _),
    pedir(delete, '/personas/eva', C4, _),
    Codigos = [C1, C2, C3, C4].

% Ejercicio 5: zoe no está en el servidor, y no aparece.
test(edades_remotas, true(P == [ana-41, luis-12])) :-
    base(Base),
    edades_remotas(Base, [ana, zoe, luis], P).

% Ejercicio 7: los métodos que la ruta no admite.
test(post_a_hola, true(C == 405)) :-
    pedir(post, '/hola', C, _).

test(get_a_edades, true(C == 405)) :-
    pedir(get, '/edades', C, _).

% Ejercicio 8.
test(cors, true(Origen == '*')) :-
    base(Base),
    atom_concat(Base, '/hola', Url),
    setup_call_cleanup(
        http_open(Url, Stream,
                  [ header(access_control_allow_origin, Origen),
                    request_header('Origin'='http://ejemplo.org') ]),
        read_string(Stream, _, _),
        close(Stream)).

% Ejercicio 9: el formato, no el valor, que cambia con el reloj.
test(hora, true(C == 200)) :-
    json('/hora', C, R),
    get_dict(hora, R, Hora),
    parse_time(Hora, iso_8601, _).

:- end_tests(soluciones).
