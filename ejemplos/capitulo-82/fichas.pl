:- encoding(utf8).

% Capítulo 82 - Versión 3: la autenticidad con un secreto compartido.
%
% Un código de autenticación de mensajes (HMAC) es un resumen que depende
% de los datos y de una clave secreta: sin la clave no se puede calcular,
% y quien la tiene comprueba que los datos no cambiaron y que los preparó
% alguien que también la tiene. El servicio de Inscripciones lo usa para
% sus fichas de sesión: después de comprobar la contraseña, entrega una
% ficha Legajo.Vence.Mac, y en cada pedido siguiente recalcula el Mac en
% lugar de volver a pedir la contraseña. Los Mac se comparan en tiempo
% constante, para no revelar con la demora cuántos caracteres coinciden.
%
%?- mac(secreto, "101.1800000000", M).
%?- emitir(secreto, 101, 1800000000, F), validar(secreto, F, 1700000000, L).

:- module(fichas,
          [ mac/3,
            nuevo_secreto/1,
            emitir/4,
            validar/4,
            iguales/2
          ]).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  mac(+Secreto, +Datos, -Mac:atom) is det.
%
%   Mac es el HMAC-SHA256 de Datos con la clave Secreto, en hexadecimal.
mac(Secreto, Datos, Mac) :-
    crypto_data_hash(Datos, M, [algorithm(sha256), hmac(Secreto)]),
    Mac = M.

%!  nuevo_secreto(-Secreto:atom) is det.
%
%   Secreto son 32 bytes aleatorios, criptográficamente fuertes, escritos
%   en hexadecimal.
nuevo_secreto(Secreto) :-
    crypto_n_random_bytes(32, Bytes),
    hex_bytes(Secreto, Bytes).

%!  emitir(+Secreto, +Legajo:integer, +Vence:integer, -Ficha:atom) is det.
%
%   Ficha autoriza al alumno Legajo hasta el instante Vence, en segundos
%   desde 1970: es Legajo.Vence.Mac, con Mac el HMAC de Legajo.Vence.
emitir(Secreto, Legajo, Vence, Ficha) :-
    format(atom(Datos), "~d.~d", [Legajo, Vence]),
    mac(Secreto, Datos, Mac),
    atomic_list_concat([Datos, Mac], '.', Ficha).

%!  validar(+Secreto, +Ficha, +Ahora:number, -Legajo:integer) is semidet.
%
%   Ficha tiene la forma Legajo.Vence.Mac, Mac es el HMAC de Legajo.Vence
%   con Secreto y Ahora es anterior a Vence. Falla con una ficha alterada,
%   firmada con otro secreto, vencida o mal formada.
validar(Secreto, Ficha, Ahora, Legajo) :-
    atomic_list_concat([L, V, Mac], '.', Ficha),
    atom_number(L, Legajo0),
    integer(Legajo0),
    atom_number(V, Vence),
    integer(Vence),
    atomic_list_concat([L, V], '.', Datos),
    mac(Secreto, Datos, Esperado),
    iguales(Mac, Esperado),
    Ahora < Vence,
    Legajo = Legajo0.

%!  iguales(+A:atom, +B:atom) is semidet.
%
%   A y B tienen los mismos caracteres. Si tienen la misma longitud, la
%   comparación examina todos los caracteres aunque el primero ya difiera:
%   acumula el o exclusivo de cada par y al final exige que sea 0, de modo
%   que lo que tarda no depende de dónde está la primera diferencia.
iguales(A, B) :-
    atom_codes(A, Cs),
    atom_codes(B, Ds),
    same_length(Cs, Ds),
    foldl(diferencia, Cs, Ds, 0, D),
    D =:= 0.

%!  diferencia(+C:integer, +D:integer, +Acc0:integer, -Acc:integer) is det.
%
%   Acc acumula en Acc0 los bits en que difieren los códigos C y D.
diferencia(C, D, Acc0, Acc) :-
    Acc is Acc0 \/ (C xor D).
