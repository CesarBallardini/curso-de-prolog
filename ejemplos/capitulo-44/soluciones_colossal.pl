:- encoding(utf8).

% Capítulo 44 - Soluciones de los ejercicios 13, 14 y 15: un segundo
% personaje, las salas trampa del laberinto y los logros pendientes, sin
% modificar los archivos del capítulo.
%
% solo-local: carga los módulos del capítulo, y SWISH no admite módulos
% propios.
%
%?- trampa(S).
%?- iniciar_puntaje, jugada(ir(biblioteca), _), jugada(tomar(llave), _), logros_pendientes(Ls).

:- module(soluciones_colossal,
          [ trampa/1,
            logros_pendientes/1
          ]).

:- reexport(estado).
:- reexport(personajes).
:- reexport(puntaje).
:- reexport(laberinto).

% Ejercicio 13

personajes:ruta(perro, [taller, sotano]).

% Ejercicio 14

%!  trampa(?S) is nondet.
%
%   S es una sala del laberinto que se alcanza desde la entrada y desde la
%   cual la entrada no se alcanza.
trampa(S) :-
    explorar(entrada, Alcanzables),
    member(S, Alcanzables),
    explorar(S, DesdeS),
    \+ memberchk(entrada, DesdeS).

% Ejercicio 15

%!  logros_pendientes(-Logros:list) is det.
%
%   Logros son los pares H-Puntos de los logros que todavía no se
%   obtuvieron, en el orden de logro/2.
logros_pendientes(Logros) :-
    findall(H-N,
            ( puntaje:logro(H, N),
              \+ puntaje:logrado(H) ),
            Logros).
