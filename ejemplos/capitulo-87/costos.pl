:- encoding(utf8).

% Capítulo 87 - Las mediciones que el capítulo imprime.
%
% inferencias/2 cuenta las inferencias de una meta, y en_banda/2 dice si
% una medición está a menos de un 10 % de la cifra impresa, como en el
% capítulo 85. dos_veces/3 mide el análisis de unas preguntas con las
% tablas vacías y otra vez con las tablas llenas: la segunda vez,
% analisis/2 de lemas.pl ya no llama al analizador morfológico del
% capítulo 53. Antes de medir, las preguntas se analizan una vez y las
% tablas se vacían: así la primera medición no incluye el costo de
% preparar los índices de los predicados, que se paga una sola vez.
%
% solo-local: carga módulos.
%
%?- dos_veces(["¿Cuántos alumnos de sistemas aprobaron álgebra?"], N1, N2).

:- module(costos,
          [ inferencias/2,
            en_banda/2,
            dos_veces/3
          ]).

:- use_module(gramatica).

:- meta_predicate inferencias(0, -).

%!  inferencias(:Meta, -N:integer) is det.
%
%   N es la cantidad de inferencias de la primera solución de Meta.
inferencias(Meta, N) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.

%!  en_banda(+N:integer, +Impresa:integer) is semidet.
%
%   N está a menos de un 10 % de Impresa.
en_banda(N, Impresa) :-
    abs(N - Impresa) =< Impresa / 10.

%!  dos_veces(+Textos:list, -Primera:integer, -Segunda:integer) is det.
%
%   Primera son las inferencias de analizar todas las preguntas Textos con
%   las tablas vacías, y Segunda las de analizarlas otra vez.
dos_veces(Textos, Primera, Segunda) :-
    analizar_todas(Textos),
    abolish_all_tables,
    inferencias(analizar_todas(Textos), Primera),
    inferencias(analizar_todas(Textos), Segunda).

%!  analizar_todas(+Textos:list) is det.
%
%   Analiza cada pregunta de Textos.
analizar_todas(Textos) :-
    forall(member(T, Textos), analizar(T, _)).
