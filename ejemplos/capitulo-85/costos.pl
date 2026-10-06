:- encoding(utf8).

% Capítulo 85 - Las mediciones que el capítulo imprime.
%
% Carga el motor, las aplicaciones y retrogrado.pl, del que exporta
% restar/2, rondas/3 y retrogrado/3, y da dos predicados para medir:
% inferencias/2 cuenta las inferencias de una meta, y en_banda/2 dice si
% una medición está a menos de un 10 % de la cifra impresa. Las pruebas de
% costos.plt verifican cada cifra que el capítulo da de una medición: las
% cantidades de pasos, derivaciones, tablas, hechos mágicos y arcos, que
% no dependen de la máquina, con su valor exacto; las inferencias, que
% cambian de una versión de SWI-Prolog a otra, dentro de la banda.
%
% solo-local: carga otros archivos.
%
%?- inferencias(modelo(cadena(40), _, _), N).

:- module(costos,
          [ inferencias/2,
            en_banda/2,
            restar/2,
            rondas/3,
            retrogrado/3
          ]).

:- reexport(datalog).
:- reexport(tablas, [tablas/3, programa/3, magia/4]).
:- reexport(wumpus, [comparar/2, programa_wumpus/2, conocer/3]).
:- reexport(marcos, [consulta_marcos/3]).
:- reexport(metricas, [consulta_metricas/4]).
:- ensure_loaded(retrogrado).

:- meta_predicate inferencias(0, -).

%!  inferencias(:Meta, -N:integer) is det.
%
%   N es la cantidad de inferencias que usa Meta. Meta se resuelve una vez
%   antes de contar: la primera llamada a un predicado cuesta algo más,
%   porque SWI-Prolog prepara entonces sus índices.
inferencias(Meta, N) :-
    once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.

%!  en_banda(+Medido:number, +Impreso:number) is semidet.
%
%   Medido difiere de Impreso en menos del 10 % de Impreso.
en_banda(Medido, Impreso) :-
    abs(Medido - Impreso) =< 0.1 * Impreso.
