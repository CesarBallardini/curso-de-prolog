:- encoding(utf8).

% Capítulo 82 - Versión 2: guardar contraseñas.
%
% El servicio de Inscripciones del capítulo 30 va a pedir a cada alumno
% su contraseña. La versión ingenua guarda el resumen SHA-256 de cada
% contraseña: no guarda la contraseña, pero quien obtiene la tabla la
% ataca probando un diccionario de contraseñas comunes o, si son cortas,
% todas las combinaciones, y dos alumnos con la misma contraseña tienen el
% mismo resumen. La versión segura guarda un registro con sal aleatoria y
% un costo de miles de iteraciones (PBKDF2-SHA512), con
% crypto_password_hash/3: cada intento del atacante cuesta lo mismo que
% esas iteraciones, y cada registro hay que atacarlo por separado.
%
% solo-local: carga resumenes.pl, que lee archivos.
%
%?- tabla_simple(T), atacar_diccionario(T, H).
%?- huella_simple(sol, Hex), fuerza_bruta(Hex, 3, C).
%?- registrar(tango, 10, R), comprobar(tango, R).

:- module(claves,
          [ usuario/2,
            diccionario/1,
            huella_simple/2,
            tabla_simple/1,
            atacar_diccionario/2,
            clave_corta/2,
            fuerza_bruta/3,
            registrar/3,
            comprobar/2,
            atacar_registro/3
          ]).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(resumenes, [resumen/2]).

% usuario(Legajo, Clave): la contraseña que eligió el alumno Legajo. Un
% servicio real no tiene esta tabla; aquí la usan las pruebas y el ataque.
usuario(101, '123456').
usuario(102, tango).
usuario(103, 'Vq7#mz!Lr2').
usuario(104, '123456').
usuario(105, sol).
usuario(106, inscripciones).

% diccionario(Claves): contraseñas frecuentes, en el orden en que un
% atacante las prueba.
diccionario(['123456', password, '12345678', qwerty, admin, tango,
             futbol, inscripciones, river, boca]).

%!  huella_simple(+Clave, -Hex:atom) is det.
%
%   Hex es el resumen SHA-256 de Clave, sin sal ni iteraciones.
huella_simple(Clave, Hex) :-
    resumen(Clave, Hex).

%!  tabla_simple(-Tabla:list) is det.
%
%   Tabla son los pares Legajo-Hex de la versión ingenua: el resumen de la
%   contraseña de cada usuario.
tabla_simple(Tabla) :-
    findall(L-H, ( usuario(L, C), huella_simple(C, H) ), Tabla).

%!  atacar_diccionario(+Tabla:list, -Halladas:list) is det.
%
%   Halladas son los pares Legajo-Clave de Tabla cuya contraseña está en
%   el diccionario: el resumen de cada palabra se calcula una sola vez y
%   se compara con todos los de la tabla.
atacar_diccionario(Tabla, Halladas) :-
    diccionario(Palabras),
    findall(H-P, ( member(P, Palabras), huella_simple(P, H) ), Resumenes),
    findall(L-P, ( member(L-H, Tabla), memberchk(H-P, Resumenes) ),
            Halladas).

%!  clave_corta(+Largo:integer, -Clave:atom) is nondet.
%
%   Clave es una palabra de Largo letras minúsculas, de la a a la z; las
%   enumera todas, en orden alfabético.
clave_corta(Largo, Clave) :-
    length(Codigos, Largo),
    maplist(minuscula, Codigos),
    atom_codes(Clave, Codigos).

%!  minuscula(-Codigo:integer) is multi.
%
%   Codigo es el de una letra minúscula de la a a la z.
minuscula(C) :-
    between(0'a, 0'z, C).

%!  fuerza_bruta(+Hex:atom, +Largo:integer, -Clave:atom) is semidet.
%
%   Clave es la primera palabra de Largo minúsculas cuyo resumen simple es
%   Hex. Prueba las 26^Largo palabras hasta encontrarla.
fuerza_bruta(Hex, Largo, Clave) :-
    once(( clave_corta(Largo, Clave),
           huella_simple(Clave, Hex) )).

%!  registrar(+Clave, +Costo:integer, -Registro:atom) is det.
%
%   Registro guarda Clave con PBKDF2-SHA512, una sal aleatoria de 16 bytes
%   y 2^Costo iteraciones. Lleva el algoritmo, las iteraciones y la sal,
%   todo lo necesario para comprobarla después.
registrar(Clave, Costo, Registro) :-
    crypto_password_hash(Clave, Registro,
                         [algorithm('pbkdf2-sha512'), cost(Costo)]).

%!  comprobar(+Clave, +Registro:atom) is semidet.
%
%   Clave es la contraseña guardada en Registro: se recalcula con la sal y
%   las iteraciones del registro, y se compara.
comprobar(Clave, Registro) :-
    crypto_password_hash(Clave, Registro).

%!  atacar_registro(+Registro:atom, +Palabras:list, -Clave) is semidet.
%
%   Clave es la primera de Palabras que comprobar/2 acepta para Registro.
atacar_registro(Registro, Palabras, Clave) :-
    member(Clave, Palabras),
    comprobar(Clave, Registro),
    !.
