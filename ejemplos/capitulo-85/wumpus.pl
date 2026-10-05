:- encoding(utf8).

% Capítulo 85 - Las reglas de seguridad del mundo del Wumpus, evaluadas
% por el motor.
%
% El capítulo 77 escribió las reglas de seguridad del agente como un
% programa Datalog, programa_datalog/2 en enfoques.pl, y lo evaluó con
% modelo_estandar_de/2 del capítulo 38. Aquí el mismo programa, sin
% cambios, se evalúa con evaluar/3, componente por componente. comparar/3
% mide las dos evaluaciones sobre las mismas instantáneas del agente:
% las celdas que prueban seguras, en cuántas instantáneas difieren las dos
% respuestas y las inferencias de cada una.
%
% solo-local: carga módulos de otros capítulos.
%
%?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), seguras_motor(K, S).
%?- comparar([1, 2, 3], R).

:- module(wumpus,
          [ programa_wumpus/2,
            seguras_motor/2,
            seguras_capitulo38/2,
            comparar/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- reexport('../capitulo-77/enfoques', [conocer/3, seguras_con/3]).
:- use_module('../capitulo-77/enfoques', [instantaneas/2]).
:- reexport(estratos, [componentes/2, evaluar/3]).
:- use_module(semantica38).

%!  programa_wumpus(+K, -Clausulas:list) is det.
%
%   Clausulas son los hechos de la cueva y del conocimiento K y las reglas
%   de seguridad: programa_datalog/2 del capítulo 77.
programa_wumpus(K, Clausulas) :-
    enfoques:programa_datalog(K, Clausulas).

%!  seguras_motor(+K, -Seguras:list) is det.
%
%   Seguras son, en orden, las celdas sin visitar que las reglas de
%   seguridad prueban seguras con el conocimiento K del capítulo 77,
%   evaluadas con evaluar/3.
seguras_motor(K, Seguras) :-
    programa_wumpus(K, Clausulas),
    evaluar(Clausulas, Modelo, _),
    celdas_seguras(Modelo, Seguras).

%!  seguras_capitulo38(+K, -Seguras:list) is det.
%
%   Las mismas Seguras, con modelo_estandar_de/2 del capítulo 38.
seguras_capitulo38(K, Seguras) :-
    programa_wumpus(K, Clausulas),
    modelo_estandar_de(Clausulas, Modelo),
    celdas_seguras(Modelo, Seguras).

%!  celdas_seguras(+Modelo:list, -Seguras:list) is det.
%
%   Seguras son, en orden, las celdas X-Y de los átomos segura(N) de
%   Modelo, con N = 10 * X + Y.
celdas_seguras(Modelo, Seguras) :-
    findall(C,
            ( member(segura(N), Modelo),
              enfoques:celda_numero(C, N) ),
            Cs),
    sort(Cs, Seguras).

%!  comparar(+Semillas:list, -Resultado) is det.
%
%   Resultado es r(Seguras, Distintas, I38, IMotor) sobre las instantáneas
%   de instantaneas/2 con esas Semillas: las celdas que el motor prueba
%   seguras en total, en cuántas instantáneas su respuesta difiere de la
%   del capítulo 38, y las inferencias de cada evaluación.
comparar(Semillas, r(Seguras, Distintas, I38, IMotor)) :-
    instantaneas(Semillas, Ks),
    inferencias(maplist(seguras_capitulo38, Ks, S38), I38),
    inferencias(maplist(seguras_motor, Ks, SMotor), IMotor),
    maplist(length, SMotor, Ls),
    sum_list(Ls, Seguras),
    aggregate_all(count,
                  ( nth1(I, S38, A), nth1(I, SMotor, B), A \== B ),
                  Distintas).

%!  inferencias(:Meta, -N:integer) is det.
%
%   N es la cantidad de inferencias que usa Meta, que se resuelve una vez.
inferencias(Meta, N) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.
