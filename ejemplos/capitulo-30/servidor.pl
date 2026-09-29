:- encoding(utf8).

% Capítulo 30 - Un servicio web: la familia del capítulo 29, por HTTP.
%
% Las reglas —padre/2, edad/2, abuelo/2, ficha/2— no dependen de HTTP. Los
% manejadores leen el pedido, llaman a las reglas y responden con JSON y un
% código de estado; responder/1 convierte los errores de las reglas en
% códigos 400 y 404. iniciar/1 arranca el servidor en un puerto libre de la
% máquina local, y detener/1 lo detiene.
%
% solo-local: SWISH no permite abrir puertos ni iniciar un servidor.
%
%?- iniciar(Puerto), detener(Puerto).
%
% thread_get_message/1: lo presenta el capítulo 37, con los hilos.

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(error)).

:- meta_predicate responder(0).

:- dynamic edad/2.

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(ana, eva).

% edad(Persona, Anios): la edad de Persona.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% --- Las reglas ------------------------------------------------------------

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  ficha(+Persona:atom, -Ficha:dict) is det.
%
%   Ficha es un dict con el nombre, la edad y los hijos de Persona.
%
%   @error existence_error(persona, Persona) si no se conoce su edad.
ficha(Persona, _{nombre: Persona, edad: Anios, hijos: Hijos}) :-
    (   edad(Persona, Anios)
    ->  findall(H, padre(Persona, H), Hijos)
    ;   existence_error(persona, Persona)
    ).

%!  cambiar_edad(+Persona:atom, +Anios:integer) is det.
%
%   Registra que Persona tiene Anios años.
%
%   @error type_error(nonneg, Anios) si Anios no es un entero no negativo.
%   @error existence_error(persona, Persona) si no se conoce a Persona.
cambiar_edad(Persona, Anios) :-
    must_be(nonneg, Anios),
    (   retract(edad(Persona, _))
    ->  assertz(edad(Persona, Anios))
    ;   existence_error(persona, Persona)
    ).

% --- Las rutas y los manejadores --------------------------------------------

:- http_handler(root(hola), hola, [method(get)]).
:- http_handler(root(personas/Nombre), persona(Nombre),
                [method(get), id(persona)]).
:- http_handler(root(nietos), nietos, [method(get)]).
:- http_handler(root(edades), edades, [method(post)]).

%!  hola(+Pedido) is det.
%
%   GET /hola?nombre=N: responde {"saludo": "Hola, N"}.
hola(Pedido) :-
    http_parameters(Pedido, [nombre(Nombre, [default(mundo)])]),
    format(string(Saludo), "Hola, ~w", [Nombre]),
    reply_json_dict(_{saludo: Saludo}).

%!  persona(+Nombre:atom, +Pedido) is det.
%
%   GET /personas/Nombre: responde la ficha de la persona, o 404.
persona(Nombre, _Pedido) :-
    responder(( ficha(Nombre, Ficha),
                reply_json_dict(Ficha) )).

%!  nietos(+Pedido) is det.
%
%   GET /nietos?abuelo=A: responde {"abuelo": A, "nietos": [...]}.
nietos(Pedido) :-
    http_parameters(Pedido, [abuelo(Abuelo, [atom])]),
    findall(N, abuelo(Abuelo, N), Nietos),
    reply_json_dict(_{abuelo: Abuelo, nietos: Nietos}).

%!  edades(+Pedido) is det.
%
%   POST /edades con {"nombre": N, "edad": E}: cambia la edad y responde la
%   ficha nueva con el código 201.
edades(Pedido) :-
    responder(( http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
                _{nombre: Nombre, edad: Anios} :< Datos,
                cambiar_edad(Nombre, Anios),
                ficha(Nombre, Ficha),
                reply_json_dict(Ficha, [status(201)]) )).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido. Si produce un error de tipo o
%   de dominio, responde 400; si es de existencia, 404; si falla, como
%   cuando al cuerpo le falta un campo, 400. Los demás errores siguen su
%   camino, y el servidor responde 500.
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

% --- El servidor -----------------------------------------------------------

%!  iniciar(?Puerto:integer) is det.
%
%   Arranca el servidor en Puerto de la máquina local; con Puerto libre,
%   elige uno que no esté en uso.
iniciar(Puerto) :-
    http_server([port(localhost:Puerto)]).

%!  detener(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener(Puerto) :-
    http_stop_server(Puerto, []).

% --- El programa -----------------------------------------------------------

:- use_module(library(main)).
:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(puerto, puerto, nonneg).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(puerto, "Puerto del servidor; sin la opción, uno libre").

%!  main(+Argv:list) is det.
%
%   swipl servidor.pl [--puerto=N]: arranca el servidor, escribe su dirección
%   en la primera línea de la salida y atiende pedidos hasta que el proceso
%   termina.
main(Argv) :-
    argv_options(Argv, _, Opciones),
    option(puerto(Puerto), Opciones, _),
    iniciar(Puerto),
    format("Servidor en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
