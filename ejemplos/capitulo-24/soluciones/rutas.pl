:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 10: un alias para el directorio del
% proyecto.
%
% file_search_path/2 define proyecto como alias del directorio de los
% módulos: proyecto(datos) es el archivo datos.pl de ese directorio.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- alumno(101, Nombre, _, _).

:- multifile user:file_search_path/2.

:- prolog_load_context(directory, Aqui),
   atom_concat(Aqui, '/../inscripciones', Directorio),
   assertz(user:file_search_path(proyecto, Directorio)).

:- use_module(proyecto(datos)).
