:- encoding(utf8).

% Capítulo 60 - Versión 1: la memoria en la base de datos dinámica.
%
% La memoria de trabajo es el predicado dinámico hecho/1. Cada ciclo busca,
% en el orden del programa, el primer módulo cuyas condiciones se cumplen,
% ejecuta sus acciones con assertz/1 y retract/1, y vuelve a empezar. El
% ciclo termina con parar(R) o cuando ningún módulo se puede aplicar.
%
% solo-local: carga programas.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- ejecutar(mcd, [numero(25), numero(10), numero(15), numero(30)], M, R).

:- ensure_loaded(programas).

:- dynamic hecho/1.

%!  ejecutar(+Programa, +Hechos0:list, -Hechos:list, -Resultado) is det.
%
%   Ejecuta el Programa con la memoria inicial Hechos0. Hechos es la
%   memoria al terminar, y Resultado el término de parar/1, o
%   nada_aplicable si el ciclo terminó porque ningún módulo se aplicaba.
ejecutar(Programa, Hechos0, Hechos, Resultado) :-
    programa(Programa, Modulos),
    retractall(hecho(_)),
    forall(member(F, Hechos0), assertz(hecho(F))),
    ciclo(Modulos, Resultado),
    findall(F, hecho(F), Hechos).

%!  ciclo(+Modulos:list, -Resultado) is det.
%
%   Aplica el primer módulo de Modulos cuyas condiciones se cumplen, y
%   repite hasta que un módulo para o ninguno se puede aplicar.
ciclo(Modulos, Resultado) :-
    (   member(Modulo, Modulos),
        copy_term(Modulo, _ :: Condiciones ---> Acciones),
        satisface(Condiciones)
    ->  acciones(Acciones, Fin),
        (   Fin = parar(R)
        ->  Resultado = R
        ;   ciclo(Modulos, Resultado)
        )
    ;   Resultado = nada_aplicable
    ).

%!  satisface(+Condiciones:list) is nondet.
%
%   La memoria cumple todas las Condiciones, en orden de izquierda a
%   derecha; sus variables quedan ligadas a los hechos que las cumplen.
satisface([]).
satisface([C|Cs]) :-
    condicion(C),
    satisface(Cs).

%!  condicion(+Condicion) is nondet.
%
%   La memoria cumple Condicion: {Meta} se prueba con Prolog, no(F) pide
%   que ningún hecho unifique con F, y un patrón F, un hecho que unifique.
condicion({Meta}) :-
    call(Meta).
condicion(no(F)) :-
    \+ hecho(F).
condicion(F) :-
    patron(F),
    hecho(F).

%!  acciones(+Acciones:list, -Fin) is det.
%
%   Ejecuta las Acciones en orden. Fin es parar(R) si una de ellas es
%   parar(R), que deja sin ejecutar las siguientes, o seguir si ninguna lo
%   es.
acciones([], seguir).
acciones([A|As], Fin) :-
    (   A = parar(R)
    ->  Fin = parar(R)
    ;   accion(A),
        acciones(As, Fin)
    ).

%!  accion(+Accion) is det.
%
%   Ejecuta una acción que no es parar/1 sobre la memoria.
accion({Meta}) :-
    once(Meta).
accion(agregar(F)) :-
    assertz(hecho(F)).
accion(quitar(F)) :-
    once(retract(hecho(F))).
accion(reemplazar(F, G)) :-
    once(retract(hecho(F))),
    assertz(hecho(G)).
