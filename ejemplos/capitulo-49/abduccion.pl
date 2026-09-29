:- encoding(utf8).

% Capítulo 49 - Versión 2: el intérprete abductivo.
%
% abducir/2 es el intérprete vainilla del capítulo 33 con una clase más de
% objetivos: estado(Componente, Estado) no se prueba con reglas, se supone.
% Los supuestos forman un diccionario incompleto (capítulo 34): un
% componente tiene un solo estado, y el mismo diccionario sirve a todas las
% compuertas y a todas las observaciones. La teoría son los hechos
% regla(Cabeza, Cuerpo): la salida de una compuerta según su estado, en
% el modelo de fallas fuerte de la versión 1.
%
% La conducta abductiva/6 hace de simular/4 un intérprete abductivo del
% circuito: cada compuerta supone su estado.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- abducir(salida(fuerte, [g], and, [1, 1], 0), S).
%?- diagnostico(fuerte, sumador, [[0, 0, 1]-[0, 1]], D).

:- module(abduccion,
          [ abducir/2,
            abductiva/6,
            explicar/4,
            diagnostico/4,
            cerrar/1,
            fallas/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(yall)).
:- reexport(fallas).

:- ensure_loaded('../capitulo-34/diccionario').

:- multifile regla/2.

%!  abducir(+Meta, ?Supuestos:list) is nondet.
%
%   Meta se prueba con las reglas de la teoría, suponiendo los estados que
%   hagan falta. Supuestos es un diccionario incompleto de pares
%   Componente-Estado: los estados supuestos hasta ahora, y los que la
%   prueba agrega.
abducir(true, _).
abducir((A, B), Supuestos) :-
    abducir(A, Supuestos),
    abducir(B, Supuestos).
abducir(estado(Componente, Estado), Supuestos) :-
    buscar(Componente, Supuestos, Estado).
abducir(Meta, Supuestos) :-
    regla(Meta, Cuerpo),
    abducir(Cuerpo, Supuestos).

%!  regla(?Cabeza, ?Cuerpo) is nondet.
%
%   La teoría: Cabeza es verdadera si lo es Cuerpo. salida(Modelo, Ruta,
%   Tipo, Entradas, Salida) es la salida de la compuerta Ruta; en el modelo
%   fuerte, su estado es ok, pegada(V) o invertida. Los hechos que calcula
%   Prolog, tabla/3 y negacion/2, entran como reglas de cuerpo vacío.
regla(salida(_, Ruta, Tipo, Es, S), (estado(Ruta, ok), tabla(Tipo, Es, S))).
regla(salida(fuerte, Ruta, _, _, V), (bit(V), estado(Ruta, pegada(V)))).
regla(salida(fuerte, Ruta, Tipo, Es, S),
      (estado(Ruta, invertida), tabla(Tipo, Es, S0), negacion(S0, S))).
regla(tabla(Tipo, Es, S), true) :-
    tabla(Tipo, Es, S).
regla(bit(B), true) :-
    bit(B).
regla(negacion(B, N), true) :-
    negacion(B, N).

%!  abductiva(+Modelo, ?Supuestos:list, +Ruta:list, ?Tipo, ?Entradas:list,
%!      ?Salida) is nondet.
%
%   La conducta abductiva de una compuerta: su salida en el Modelo, con el
%   estado que Supuestos le asigna o que la prueba le supone.
abductiva(Modelo, Supuestos, Ruta, Tipo, Entradas, Salida) :-
    abducir(salida(Modelo, Ruta, Tipo, Entradas, Salida), Supuestos).

%!  explicar(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Supuestos:list(pair)) is nondet.
%
%   Supuestos asigna un estado a cada compuerta de Circuito, de modo que el
%   circuito reproduce todas las Observaciones Entradas-Salidas.
explicar(Modelo, Circuito, Observaciones, Supuestos) :-
    maplist(observar(Modelo, Circuito, Supuestos), Observaciones),
    cerrar(Supuestos).

%!  observar(+Modelo, +Circuito, ?Supuestos:list, +Observacion:pair)
%!      is nondet.
%
%   Circuito reproduce la Observacion Entradas-Salidas con los Supuestos.
observar(Modelo, Circuito, Supuestos, Entradas-Salidas) :-
    simular(abductiva(Modelo, Supuestos), Circuito, Entradas, Salidas).

%!  cerrar(?Dic:list) is det.
%
%   Dic, un diccionario incompleto, queda cerrado: su final es [].
cerrar([]) :-
    !.
cerrar([_|Resto]) :-
    cerrar(Resto).

%!  diagnostico(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Fallas:list(pair)) is nondet.
%
%   Fallas son los pares Ruta-Estado de las compuertas que no están en ok
%   en una explicación de las Observaciones, ordenados por ruta.
diagnostico(Modelo, Circuito, Observaciones, Fallas) :-
    explicar(Modelo, Circuito, Observaciones, Supuestos),
    fallas(Supuestos, Fallas).

%!  fallas(+Supuestos:list(pair), -Fallas:list(pair)) is det.
%
%   Fallas son los pares de Supuestos cuyo estado no es ok, ordenados.
fallas(Supuestos, Fallas) :-
    exclude([_-Estado]>>(Estado == ok), Supuestos, Fallas0),
    msort(Fallas0, Fallas).
