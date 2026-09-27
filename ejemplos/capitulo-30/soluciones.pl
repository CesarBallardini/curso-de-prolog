:- encoding(utf8).

% Capítulo 30 - Soluciones de los ejercicios 1, 3, 4, 5, 8 y 9.
%
% Carga servidor.pl y cliente.pl, y agrega rutas al servidor. Las rutas de
% los ejercicios 4 y 8 reemplazan a las de servidor.pl: una ruta sin partes
% variables se reemplaza declarándola otra vez; una con partes variables se
% borra antes por su identificador, id(persona).
%
% solo-local: SWISH no permite abrir puertos ni iniciar un servidor.
%
%?- iniciar(Puerto), detener(Puerto).

:- ensure_loaded(servidor).
:- ensure_loaded(cliente).
:- use_module(library(http/http_cors)).
:- use_module(library(settings)).

% --- Ejercicio 1 ------------------------------------------------------------

:- http_handler(root(hijos/Nombre), hijos(Nombre), [method(get)]).

%!  hijos(+Nombre:atom, +Pedido) is det.
%
%   GET /hijos/Nombre: {"nombre": Nombre, "hijos": [...]}.
hijos(Nombre, _Pedido) :-
    findall(H, padre(Nombre, H), Hijos),
    reply_json_dict(_{nombre: Nombre, hijos: Hijos}).

% --- Ejercicio 3 ------------------------------------------------------------

:- http_handler(root(mayores), mayores, [method(get)]).

%!  mayores(+Pedido) is det.
%
%   GET /mayores?edad=N: las personas de más de N años. Sin el parámetro, o
%   con uno que no es un entero, el servidor responde 400.
mayores(Pedido) :-
    http_parameters(Pedido, [edad(Minima, [integer])]),
    findall(P, ( edad(P, Anios), Anios > Minima ), Personas),
    reply_json_dict(_{edad: Minima, personas: Personas}).

% --- Ejercicio 4 ------------------------------------------------------------

:- http_delete_handler(id(persona)).
:- http_handler(root(personas/Nombre), persona_u_olvido(Nombre),
                [methods([get, delete]), id(persona)]).

%!  persona_u_olvido(+Nombre:atom, +Pedido) is det.
%
%   GET /personas/Nombre, como persona/2; DELETE /personas/Nombre olvida la
%   edad de la persona y responde 204, sin cuerpo, o 404 si no la conocía.
persona_u_olvido(Nombre, Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   Metodo == delete
    ->  responder(olvidar(Nombre))
    ;   persona(Nombre, Pedido)
    ).

%!  olvidar(+Nombre:atom) is det.
%
%   Olvida la edad de Nombre y responde 204.
%
%   @error existence_error(persona, Nombre) si no se conoce.
olvidar(Nombre) :-
    (   retract(edad(Nombre, _))
    ->  throw(http_reply(no_content))
    ;   existence_error(persona, Nombre)
    ).

% --- Ejercicio 5 ------------------------------------------------------------

%!  edades_remotas(+Base:atom, +Personas:list(atom), -Pares:list(pair))
%!      is det.
%
%   Pares son los pares Persona-Edad de las Personas que están en el servidor
%   de Base, en el mismo orden.
edades_remotas(Base, Personas, Pares) :-
    convlist(edad_remota(Base), Personas, Pares).

%!  edad_remota(+Base:atom, +Persona:atom, -Par:pair) is semidet.
%
%   Par es Persona-Edad según el servidor de Base. Falla si no la conoce.
edad_remota(Base, Persona, Persona-Edad) :-
    ficha_remota(Base, Persona, Ficha),
    get_dict(edad, Ficha, Edad).

% --- Ejercicio 8 ------------------------------------------------------------

:- set_setting(http:cors, [*]).
:- http_handler(root(hola), hola_con_cors, [method(get)]).

%!  hola_con_cors(+Pedido) is det.
%
%   GET /hola, como hola/1, con el encabezado de CORS que permite llamarla
%   desde páginas de cualquier origen.
hola_con_cors(Pedido) :-
    cors_enable,
    hola(Pedido).

% --- Ejercicio 9 ------------------------------------------------------------

:- http_handler(root(hora), hora, [method(get)]).

%!  hora(+Pedido) is det.
%
%   GET /hora: {"hora": Texto}, la fecha y la hora del servidor en el
%   formato ISO 8601, como "2026-09-25T14:03:07-03:00".
hora(_Pedido) :-
    get_time(Ahora),
    format_time(string(Texto), '%FT%T%:z', Ahora),
    reply_json_dict(_{hora: Texto}).
