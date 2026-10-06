:- encoding(utf8).

% Capítulo 61 - Versión 7: la negación y el manejo de errores.
%
% \+ G se prueba con una segunda ejecución de la máquina, que empieza con
% la resolvente [G], la pila vacía y el almacén del momento, como el not
% de picoProlog, que llama otra vez al ciclo del intérprete. Si esa
% ejecución da una respuesta, \+ G falla; si termina sin ninguna, \+ G se
% cumple y la máquina sigue con el almacén de antes: las ligaduras que
% hizo la segunda ejecución se descartan.
%
% Un error de un paso, como una llamada a un predicado sin cláusulas o una
% expresión aritmética con una celda libre, se maneja como en Toy: si el
% programa objeto define error/1, la meta que produjo el error se
% reemplaza por error(Meta); si no lo define, el error sale de la máquina,
% como en las versiones anteriores. El resto es la máquina de corte.pl.
%
% solo-local: carga los módulos almacen y corte.
%
%?- resolver(soltero(X)).
%?- resolver(desconocido(X)).

:- module(negacion,
          [ resolver/1,
            resolver_programa/2,
            medir_programa/3
          ]).

:- use_module(library(assoc)).
:- use_module(programas).
:- use_module(almacen,
              [ resolver_clausulas/3,
                medir_clausulas/4,
                compilar/2
              ]).
:- use_module(corte, []).

% objeto(Nombre, Clausulas): los programas objeto de esta versión.
objeto(soltero,
       [ (persona(ana) :- true),
         (persona(luis) :- true),
         (persona(eva) :- true),
         (casado(luis) :- true),
         (soltero(X) :- persona(X), \+ casado(X))
       ]).
objeto(desconocido,
       [ (desconocido(X) :- sin_definir(X)),
         (desconocido(b) :- true),
         (siguiente(X, Y) :- Y is X + 1),
         (error(_) :- fail)
       ]).

%!  resolver(?Meta) is nondet.
%
%   Meta se prueba con el programa objeto de esta versión que define su
%   predicado, soltero o desconocido.
resolver(Meta) :-
    functor(Meta, Nombre, _),
    (   Nombre == soltero
    ->  resolver_programa(soltero, Meta)
    ;   resolver_programa(desconocido, Meta)
    ).

%!  resolver_programa(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba en esta versión con el programa objeto Nombre.
resolver_programa(Nombre, Meta) :-
    objeto(Nombre, Clausulas),
    resolver_clausulas(negacion, Clausulas, Meta).

%!  medir_programa(+Nombre:atom, +Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de la búsqueda completa de Meta con el
%   programa objeto Nombre, como las describe medir_con/4 de almacen.pl.
medir_programa(Nombre, Meta, Medidas) :-
    objeto(Nombre, Clausulas),
    medir_clausulas(negacion, Clausulas, Meta, Medidas).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de corte.pl, con \+ G y con los errores dirigidos a
%   error/1 cuando el programa objeto lo define.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = (\+ G)
    ->  negar(G, Metas, Tabla, Estado0, Resultado)
    ;   catch(corte:paso(Meta, Metas, Tabla, Estado0, Resultado),
              error(Error, Contexto),
              manejar(Error, Contexto, Meta, Metas, Tabla, Estado0,
                      Resultado))
    ).

%!  negar(+G, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Prueba \+ G con una segunda ejecución de la máquina desde el almacén
%   de Estado0. Resultado es falla(Estado) si G tiene una respuesta, y
%   sigue(Estado), con Metas y el almacén de Estado0, si no tiene
%   ninguna. Estado lleva las medidas y las celdas de las dos ejecuciones.
negar(G, Metas, Tabla, m(Ms, Pila, A, R, L0, M0), Resultado) :-
    once(almacen:ciclo(negacion, Tabla, m([G], [], A, [], L0, M0), Evento)),
    arg(1, Evento, m(_, _, _, _, L, M)),
    (   Evento = fin(_)
    ->  Resultado = sigue(m(Metas, Pila, A, R, L, M))
    ;   Resultado = falla(m(Ms, Pila, A, R, L, M))
    ).

%!  manejar(+Error, +Contexto, +Meta, +Metas:list, +Tabla, +Estado0,
%!          -Resultado) is det.
%
%   Si el programa objeto define error/1, la Meta que produjo el Error se
%   reemplaza por error(Meta); si no, el error se vuelve a lanzar.
manejar(Error, Contexto, Meta, Metas, Tabla, Estado0, Resultado) :-
    (   get_assoc(error/1, Tabla, _)
    ->  Estado0 = m(_, Pila, A, R, L, M),
        Resultado = sigue(m([error(Meta)|Metas], Pila, A, R, L, M))
    ;   throw(error(Error, Contexto))
    ).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   La vuelta atrás de corte.pl.
volver(Tabla, Estado0, Resultado) :-
    corte:volver(Tabla, Estado0, Resultado).
