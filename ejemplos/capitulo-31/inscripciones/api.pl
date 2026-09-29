:- encoding(utf8).

% Capítulo 31 - Inscripciones, módulo api: el programa como servicio web.
%
% Cada ruta es un manejador corto: lee el pedido, llama a los predicados de
% los demás módulos —los mismos que usan la terminal y Python— y responde con
% JSON y un código de estado. El ranking y las materias usan las conversiones
% de puente, que producen dicts, y un dict es un objeto de JSON; el
% resultado de una inscripción se convierte aquí, porque puente escribe los
% booleanos con la notación de Janus, @(true), y JSON los escribe true.
% responder/1 convierte los errores en códigos.
%
%     GET  /alumnos                     los alumnos
%     GET  /alumnos/{legajo}            un alumno, o 404
%     GET  /materias                    las materias, con sus inscriptos
%     GET  /materias/{codigo}/promedio  el promedio de sus notas, o null
%     GET  /ranking                     el ranking
%     POST /inscripciones               {"legajo": L, "materia": M}
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_api(Puerto), detener_api(Puerto).

:- module(api,
          [ iniciar_api/1,
            iniciar_api/2,
            detener_api/1
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(datos).
:- use_module(reglas).
:- use_module(informes).
:- use_module(puente).

:- meta_predicate responder(0).

:- http_handler(root(alumnos), alumnos, [method(get)]).
:- http_handler(root(alumnos/Legajo), alumno(Legajo), [method(get)]).
:- http_handler(root(materias), materias, [method(get)]).
:- http_handler(root(materias/Codigo/promedio), promedio_http(Codigo),
                [method(get)]).
:- http_handler(root(ranking), ranking_http, [method(get)]).
:- http_handler(root(inscripciones), inscripciones, [method(post)]).

%!  iniciar_api(?Puerto:integer) is det.
%
%   Arranca el servicio en Puerto de la máquina local; con Puerto libre,
%   elige uno que no esté en uso.
iniciar_api(Puerto) :-
    http_server([port(localhost:Puerto)]).

%!  iniciar_api(?Puerto:integer, +Alcance:atom) is det.
%
%   Como iniciar_api/1, con Alcance local, que solo acepta pedidos de la
%   misma máquina, o publico, que los acepta de cualquier interfaz de red:
%   el que necesita el servicio dentro de un contenedor.
iniciar_api(Puerto, local) :-
    iniciar_api(Puerto).
iniciar_api(Puerto, publico) :-
    http_server([port(Puerto)]).

%!  detener_api(+Puerto:integer) is det.
%
%   Detiene el servicio de Puerto.
detener_api(Puerto) :-
    http_stop_server(Puerto, []).

% --- Los manejadores -------------------------------------------------------

%!  alumnos(+Pedido) is det.
%
%   GET /alumnos: la lista de los alumnos, en el orden de los hechos.
alumnos(_Pedido) :-
    findall(A, ( alumno(L, _, _, _), alumno_json(L, A) ), Alumnos),
    reply_json_dict(Alumnos).

%!  alumno(+Legajo:atom, +Pedido) is det.
%
%   GET /alumnos/Legajo: el alumno, o 404 si no existe. Un legajo que no es
%   un número es un error de tipo, y la respuesta es 400.
alumno(Texto, _Pedido) :-
    responder(( legajo(Texto, Legajo),
                (   alumno_json(Legajo, Alumno)
                ->  reply_json_dict(Alumno)
                ;   existence_error(alumno, Legajo)
                ) )).

%!  materias(+Pedido) is det.
%
%   GET /materias: las materias, con la cantidad de inscriptos.
materias(_Pedido) :-
    materias_py(Materias),
    reply_json_dict(Materias).

%!  promedio_http(+Codigo:atom, +Pedido) is det.
%
%   GET /materias/Codigo/promedio: {"codigo": C, "promedio": P}, con null
%   si la materia no tiene notas, o 404 si no existe.
promedio_http(Codigo, _Pedido) :-
    responder(( (   materia(Codigo, _, _)
                ->  true
                ;   existence_error(materia, Codigo)
                ),
                (   promedio_de_materia(Codigo, P)
                ->  Promedio = P
                ;   Promedio = null
                ),
                reply_json_dict(_{codigo: Codigo, promedio: Promedio}) )).

%!  ranking_http(+Pedido) is det.
%
%   GET /ranking: el ranking, de mayor a menor promedio.
ranking_http(_Pedido) :-
    ranking_py(Filas),
    reply_json_dict(Filas).

%!  inscripciones(+Pedido) is det.
%
%   POST /inscripciones con {"legajo": L, "materia": M}: inscribe al
%   alumno. Responde 201 si la inscripción se acepta; 404 si el alumno o la
%   materia no existen; 409, con el motivo, si las reglas la rechazan.
inscripciones(Pedido) :-
    responder(( http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
                _{legajo: Legajo, materia: Materia} :< Datos,
                inscribir(Legajo, Materia, Respuesta),
                resultado_json(Respuesta, Resultado, Codigo),
                reply_json_dict(Resultado, [status(Codigo)]) )).

%!  resultado_json(+Respuesta, -Resultado:dict, -Codigo:integer) is det.
%
%   Resultado es el cuerpo de la respuesta de inscribir/3, y Codigo su
%   código de estado: 201 si se acepta, 404 si el alumno o la materia no
%   existen, 409 si las reglas la rechazan por otro motivo.
resultado_json(aceptada, _{aceptada: true}, 201).
resultado_json(rechazada(Motivo), _{aceptada: false, motivo: Texto}, Codigo) :-
    term_string(Motivo, Texto),
    (   memberchk(Motivo, [alumno_inexistente, materia_inexistente])
    ->  Codigo = 404
    ;   Codigo = 409
    ).

% --- Auxiliares ------------------------------------------------------------

%!  alumno_json(+Legajo:integer, -Alumno:dict) is semidet.
%
%   Alumno es el dict del alumno Legajo. Falla si no existe.
alumno_json(Legajo, _{legajo: Legajo, nombre: N, carrera: C, ingreso: I}) :-
    alumno(Legajo, N, C, I).

%!  legajo(+Texto:atom, -Legajo:integer) is det.
%
%   Legajo es el número que escribe Texto, un segmento de la ruta.
%
%   @error type_error(integer, Texto) si Texto no es un entero.
legajo(Texto, Legajo) :-
    (   atom_number(Texto, Legajo),
        integer(Legajo)
    ->  true
    ;   type_error(integer, Texto)
    ).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido. Un error de tipo, de dominio o
%   de sintaxis responde 400; uno de existencia, 404; si Objetivo falla,
%   como cuando al cuerpo le falta un campo, 400. Los demás errores siguen
%   su camino, y el servidor responde 500.
responder(Objetivo) :-
    catch(( Objetivo
          ->  true
          ;   reply_json_dict(_{error: "pedido incompleto"}, [status(400)])
          ),
          error(Formal, _),
          responder_error(Formal)).

%!  responder_error(+Formal) is det.
%
%   Responde el error Formal con su código de estado.
responder_error(Formal) :-
    codigo_de_error(Formal, Codigo),
    !,
    format(string(Texto), "~w", [Formal]),
    reply_json_dict(_{error: Texto}, [status(Codigo)]).
responder_error(Formal) :-
    throw(error(Formal, _)).

%!  codigo_de_error(+Formal, -Codigo:integer) is semidet.
%
%   Codigo es el código de estado de HTTP del error Formal.
codigo_de_error(type_error(_, _), 400).
codigo_de_error(domain_error(_, _), 400).
codigo_de_error(syntax_error(_), 400).
codigo_de_error(existence_error(_, _), 404).
