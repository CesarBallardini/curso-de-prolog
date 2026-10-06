:- encoding(utf8).

% Capítulo 86 - Las mediciones que el capítulo imprime.
%
% inferencias/2 cuenta las inferencias que usa la meta compilada de una
% consulta para dar todas sus filas; numeros/1 crea la tabla numeros con
% los enteros de 1 a N, para medir una reunión de tamaño conocido. Las
% pruebas de costos.plt verifican cada cifra que el capítulo da de una
% medición, dentro de una banda del 10 %, porque las inferencias cambian
% de una versión de SWI-Prolog a otra.
%
% solo-local: carga los módulos del capítulo y modifica la base.
%
%?- inferencias("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'", N).

:- module(costos,
          [ inferencias/2,
            en_banda/2,
            numeros/1
          ]).

:- reexport(minisql).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  inferencias(+Texto, -N:integer) is det.
%
%   N es la cantidad de inferencias que usa la meta compilada de la
%   consulta Texto para dar todas sus filas. La meta se ejecuta una vez
%   antes de contar, para que SWI-Prolog prepare sus índices.
inferencias(Texto, N) :-
    traducir(Texto, _, Fila-Meta),
    findall(Fila, Meta, _),
    statistics(inferences, I0),
    findall(Fila, Meta, _),
    statistics(inferences, I1),
    N is I1 - I0.

%!  en_banda(+Medido:number, +Impreso:number) is semidet.
%
%   Medido difiere de Impreso en menos del 10 % de Impreso.
en_banda(Medido, Impreso) :-
    abs(Medido - Impreso) =< 0.1 * Impreso.

%!  numeros(+N:integer) is det.
%
%   Crea la tabla numeros, con la columna n, y le agrega los enteros de 1
%   a N con un INSERT.
numeros(N) :-
    sql("CREATE TABLE numeros (n INTEGER)", _),
    numlist(1, N, Ns),
    maplist([I, T]>>format(atom(T), "(~d)", [I]), Ns, Filas),
    atomic_list_concat(Filas, ', ', Valores),
    atom_concat('INSERT INTO numeros VALUES ', Valores, Insert),
    sql(Insert, _).
