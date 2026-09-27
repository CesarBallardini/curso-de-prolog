:- encoding(utf8).

% Capítulo 31 - Solución del ejercicio 4: las materias dentro del programa.
%
%     swipl materias.pl codigo
%
% Al cargarse, lee archivos/materias.json y guarda cada materia como un
% hecho materia/3; el programa construido no necesita el archivo. Escribe
% el nombre de la materia del código que recibe, y termina con el código 1
% si no hay ninguna con ese código.
%
% solo-local: SWISH no lee archivos ni ejecuta programas con argumentos.
%
%?- materia(log, Nombre, Anio).

:- use_module(library(main)).
:- use_module(library(http/json)).

:- initialization(main, main).

:- dynamic materia/3.

%!  cargar_materias(+Archivo) is det.
%
%   Reemplaza los hechos materia/3 por las materias del arreglo JSON de
%   Archivo, cada una con su código, su nombre y su año.
cargar_materias(Archivo) :-
    retractall(materia(_, _, _)),
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       json_read_dict(Stream, Materias,
                                      [value_string_as(atom)]),
                       close(Stream)),
    forall(member(M, Materias),
           ( _{codigo: Codigo, nombre: Nombre, anio: Anio} :< M,
             assertz(materia(Codigo, Nombre, Anio)) )).

% Se ejecuta al cargar el archivo, y por lo tanto al construir el programa.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, 'archivos/materias.json', Archivo),
   cargar_materias(Archivo).

%!  main(+Argv:list) is det.
%
%   Escribe el nombre de la materia de código Argv. Termina con el código 1
%   si no hay una materia con ese código, y con 2 si Argv no es un solo
%   argumento.
main([Codigo]) :-
    !,
    (   materia(Codigo, Nombre, _)
    ->  format("~w~n", [Nombre])
    ;   format(user_error, "No hay una materia con el código ~w.~n",
               [Codigo]),
        halt(1)
    ).
main(_) :-
    format(user_error, "Uso: swipl materias.pl codigo~n", []),
    halt(2).
