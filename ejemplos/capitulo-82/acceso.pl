:- encoding(utf8).

% Capítulo 82 - Versión 3: el servicio de Inscripciones con sesiones.
%
% Agrega dos rutas al servicio del capítulo 30, que se carga sin cambios:
%
%     POST /sesion             {"legajo": L, "clave": C}: la ficha, o 401
%     POST /mis-inscripciones  {"materia": M}, con la cabecera
%                              Authorization: Bearer <ficha>; 401 sin ficha
%                              válida
%
% El servicio guarda de cada alumno solo el registro de su contraseña,
% hecho con registrar/3 de claves.pl y costo 12, y su secreto de las
% fichas se genera al cargar el módulo: al reiniciar el servicio, las
% fichas emitidas antes dejan de valer. El legajo de la inscripción sale
% de la ficha, no del cuerpo del pedido: un alumno solo se inscribe a sí
% mismo.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_sesion(102, tango, 1700000000, F).
%?- iniciar_api(Puerto), detener_api(Puerto).

:- module(acceso,
          [ credencial/2,
            iniciar_sesion/4,
            ficha_del_pedido/3
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- reexport('../capitulo-30/inscripciones/api').
:- use_module('../capitulo-30/inscripciones/reglas', [inscribir/3]).
:- use_module(claves, [comprobar/2]).
:- use_module(fichas).

:- http_handler(root(sesion), sesion, [method(post)]).
:- http_handler(root('mis-inscripciones'), mis_inscripciones,
                [method(post)]).

:- dynamic secreto/1.

:- nuevo_secreto(S), assertz(secreto(S)).

%!  duracion(-Segundos:integer) is det.
%
%   Una ficha vale durante Segundos desde que se emite: una hora.
duracion(3600).

% credencial(Legajo, Registro): el registro de la contraseña del alumno
% Legajo, PBKDF2-SHA512 con 2^12 iteraciones y sal propia.
credencial(101, '$pbkdf2-sha512$t=4096$r5+9X4kyyEqLeQuN8LJVhg$8zRNtSyEN0mMEkxosARBfpyf4MBISAl+JswdyFxvVfg/jt37tJmedVfFCvZmLrYN36FgiISzRnmcOunr8QZmoQ').
credencial(102, '$pbkdf2-sha512$t=4096$5rTH5Mc88Jdic5TNexrvMA$mMGzXZa63QaMEDC3EmPl39xoRvyV8XUp7GwtHL56EWrp+A1644QgfW6xoaYgbsr4aL385+F7gz57iXujRQqOSw').
credencial(103, '$pbkdf2-sha512$t=4096$lPAOzoEEUGUc5R63SXa/yw$KtWtNYiZLf6a67PJudKRtyHLbyxqR20QVGjWs+jkVTGZvOuF/InEUS/DxdO2/dmTshjEjVCqKwMHd9giEPhgZw').
credencial(104, '$pbkdf2-sha512$t=4096$+MNcpTSSzv1ACXAlKY5MFg$O6LzghC9DlPvjt8u9z6kPzdlE6vfHaGiaUcIoEQybc/9VLOYlCkSjJTxF58DUJXt3Xswiuj9XEMJ566Z0/9s6A').
credencial(105, '$pbkdf2-sha512$t=4096$6ZqMcr2yWpSdHvAjLoVgPA$g0owl1O8XL3OC7QXIzmE/T3AZykkQUbsX5S9M2gAuqbW0agnN5aC5+ZJ2J6521tTkfLnVy1IJ/6U11lYXhDXHA').
credencial(106, '$pbkdf2-sha512$t=4096$lnDk+Odnd2C/Iac28LOB3g$ZtdTdT0qkpCTZC6vueqdPzx4dAyKo2gMYSiUb/Y6e4d3UnjVLt7J1QP3uwDE0bg3v7fBcmYMJjJ34kNNUKYVPg').

%!  iniciar_sesion(+Legajo:integer, +Clave, +Ahora:number, -Ficha:atom)
%!      is semidet.
%
%   Ficha autoriza a Legajo durante una hora desde Ahora, si Clave es su
%   contraseña. Falla si el legajo no tiene credencial o la clave no es la
%   suya.
iniciar_sesion(Legajo, Clave, Ahora, Ficha) :-
    credencial(Legajo, Registro),
    comprobar(Clave, Registro),
    secreto(Secreto),
    duracion(D),
    Vence is truncate(Ahora) + D,
    emitir(Secreto, Legajo, Vence, Ficha).

%!  ficha_del_pedido(+Pedido:list, +Ahora:number, -Legajo:integer)
%!      is semidet.
%
%   Pedido lleva la cabecera Authorization: Bearer con una ficha válida
%   en el instante Ahora, y Legajo es el alumno que la ficha autoriza.
ficha_del_pedido(Pedido, Ahora, Legajo) :-
    memberchk(authorization(Valor), Pedido),
    atom_concat('Bearer ', Ficha, Valor),
    secreto(Secreto),
    validar(Secreto, Ficha, Ahora, Legajo).

% --- Los manejadores -------------------------------------------------------

%!  sesion(+Pedido) is det.
%
%   POST /sesion con {"legajo": L, "clave": C}: responde 200 con la ficha
%   si la clave es la del alumno, y 401 en cualquier otro caso, sin decir
%   si falló el legajo o la clave.
sesion(Pedido) :-
    http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
    get_time(Ahora),
    (   _{legajo: Legajo, clave: Clave} :< Datos,
        integer(Legajo),
        iniciar_sesion(Legajo, Clave, Ahora, Ficha)
    ->  reply_json_dict(_{ficha: Ficha})
    ;   reply_json_dict(_{error: "credenciales incorrectas"},
                        [status(401)])
    ).

%!  mis_inscripciones(+Pedido) is det.
%
%   POST /mis-inscripciones con {"materia": M}: inscribe en M al alumno
%   de la ficha, con los códigos de POST /inscripciones; 401 si el pedido
%   no trae una ficha válida.
mis_inscripciones(Pedido) :-
    get_time(Ahora),
    (   ficha_del_pedido(Pedido, Ahora, Legajo)
    ->  http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
        (   _{materia: Materia} :< Datos
        ->  inscribir(Legajo, Materia, Respuesta),
            api:resultado_json(Respuesta, Resultado, Codigo),
            reply_json_dict(Resultado, [status(Codigo)])
        ;   reply_json_dict(_{error: "pedido incompleto"}, [status(400)])
        )
    ;   reply_json_dict(_{error: "ficha ausente, alterada o vencida"},
                        [status(401)])
    ).
