:- encoding(utf8).

% Capítulo 59 - El análisis comparado con el de library(prolog_xref).
%
% sin_llamadas_analisis/2 da los predicados que el programa define y ningún
% otro predicado llama, salvo los puntos de entrada. sin_llamadas_xref_de/2
% da lo mismo según prolog_xref, la biblioteca de referencias cruzadas del
% sistema: xref_source/2 lee cada archivo y registra lo que define, lo que
% exporta y lo que llama. sin_llamadas_xref/2 lo aplica a los archivos de
% un programa, por su nombre, y comparar/3 calcula los dos.
%
% prolog_xref conoce las metallamadas de las bibliotecas por los ganchos
% prolog:called_by/2 que ellas definen, y solo los de las bibliotecas que
% están cargadas; comparar/3 lee primero los archivos con leer_programa/3,
% que carga las que importan.
%
% solo-local: lee archivos y carga analisis.pl.
%
%?- comparar(inscripciones, Nuestros, DeXref).

:- ensure_loaded(analisis).
:- use_module(library(prolog_xref)).

%!  comparar(+Programa, -Nuestros:list, -DeXref:list) is det.
%
%   Nuestros y DeXref son los predicados sin llamadas del programa llamado
%   Programa según sin_llamadas_analisis/2 y según sin_llamadas_xref/2.
comparar(Programa, Nuestros, DeXref) :-
    sin_llamadas_analisis(Programa, Nuestros),
    sin_llamadas_xref(Programa, DeXref).

%!  sin_llamadas_analisis(+Programa, -Ps:list) is det.
%
%   Ps son los predicados definidos en el programa llamado Programa que no
%   son puntos de entrada y que ningún otro predicado llama, ordenados.
sin_llamadas_analisis(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    raices(Programa, Raices),
    definidos(Clausulas, Ds),
    findall(P, ( member(P, Ds),
                 \+ memberchk(P, Raices),
                 \+ ( llama_de(Clausulas, Q, P),
                      Q \== P ) ),
            Ps).

%!  sin_llamadas_xref_de(+Archivos:list, -Ps:list) is det.
%
%   Ps son los predicados definidos en Archivos que ningún módulo exporta
%   y que ningún otro predicado llama, según prolog_xref, ordenados. Una
%   cláusula para otro módulo, como prolog:message//1, no cuenta: la llama
%   el sistema.
sin_llamadas_xref_de(Archivos, Ps) :-
    forall(member(A, Archivos), xref_source(A, [silent(true)])),
    findall(N/Ar, ( member(A, Archivos),
                    xref_defined(A, Cabeza, local(_)),
                    Cabeza \= _:_,
                    \+ xref_exported(A, Cabeza),
                    \+ ( xref_called(_, Cabeza, Otro),
                         Otro \=@= Cabeza ),
                    functor(Cabeza, N, Ar) ),
            Ps0),
    sort(Ps0, Ps).

%!  sin_llamadas_xref(+Programa, -Ps:list) is det.
%
%   sin_llamadas_xref_de/2 sobre los archivos del programa llamado
%   Programa.
sin_llamadas_xref(Programa, Ps) :-
    archivos(Programa, Archivos),
    sin_llamadas_xref_de(Archivos, Ps).
