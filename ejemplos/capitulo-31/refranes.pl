:- encoding(utf8).

% Capítulo 31 - Datos dentro del programa construido.
%
%     swipl refranes.pl [N]
%
% Al cargarse, lee archivos/refranes.txt y guarda cada línea como un hecho
% refran/2. qsave_program/2 guarda los hechos con el resto del programa: el
% programa construido no necesita el archivo. Sin argumentos escribe todos
% los refranes; con N, el refrán número N.
%
% solo-local: SWISH no lee archivos ni ejecuta programas con argumentos.
%
%?- refran(1, Texto).

:- use_module(library(main)).
:- use_module(library(readutil)).

:- initialization(main, main).

:- dynamic refran/2.

%!  cargar_refranes(+Archivo) is det.
%
%   Reemplaza los hechos refran/2 por las líneas no vacías de Archivo,
%   numeradas desde 1.
cargar_refranes(Archivo) :-
    retractall(refran(_, _)),
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas),
    forall(nth1(N, Lineas, Linea),
           assertz(refran(N, Linea))).

% Se ejecuta al cargar el archivo, y por lo tanto al construir el programa.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, 'archivos/refranes.txt', Archivo),
   cargar_refranes(Archivo).

%!  main(+Argv:list) is det.
%
%   Escribe el refrán número N, o todos si no recibe argumentos. Termina con
%   el código 1 si no hay un refrán con ese número.
main([]) :-
    forall(refran(_, Texto), writeln(Texto)).
main([Argumento]) :-
    (   atom_number(Argumento, N),
        refran(N, Texto)
    ->  writeln(Texto)
    ;   format(user_error, "No hay un refrán número ~w.~n", [Argumento]),
        halt(1)
    ).
