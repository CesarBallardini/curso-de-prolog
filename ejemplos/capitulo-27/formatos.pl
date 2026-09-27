:- encoding(utf8).

% Capítulo 27 - Formatos: CSV, JSON, ajustes y tablas con format/2.
%
% Los datos llegan en un formato ajeno a Prolog y se convierten en términos
% apenas se leen: filas de CSV en alumno/4, objetos de JSON en materia/3. El
% resto del programa trabaja solo con términos.
%
% solo-local: el sandbox de SWISH no permite leer ni escribir archivos.
%
%?- alumnos_csv(archivos('alumnos.csv'), Alumnos).
%?- materias_json(archivos('materias.json'), Materias).
%?- tabla([101-ana-8.5, 104-diego-8]).

:- use_module(library(csv)).
:- use_module(library(http/json)).
:- use_module(library(settings)).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, archivos, Dir),
   asserta(user:file_search_path(archivos, Dir)).

:- setting(nota_minima, between(1, 10), 6, 'Nota mínima para aprobar').

%!  alumnos_csv(+Archivo, -Alumnos:list) is det.
%
%   Alumnos son los términos alumno(Legajo, Nombre, Carrera, Ingreso) de las
%   filas de Archivo, un CSV con una fila de encabezado, que se descarta.
alumnos_csv(Archivo, Alumnos) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    csv_read_file(Ruta, [_Encabezado|Alumnos],
                  [functor(alumno), arity(4), encoding(utf8)]).

%!  materias_json(+Archivo, -Materias:list) is det.
%
%   Materias son los términos materia(Codigo, Nombre, Anio) de los objetos
%   de Archivo, un JSON con una lista de objetos.
materias_json(Archivo, Materias) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       json_read_dict(Stream, Objetos,
                                      [value_string_as(atom)]),
                       close(Stream)),
    maplist(objeto_materia, Objetos, Materias).

%!  objeto_materia(+Objeto:dict, -Materia) is det.
%
%   Materia es el término materia/3 con los datos de Objeto.
objeto_materia(Objeto, materia(Codigo, Nombre, Anio)) :-
    _{codigo: Codigo, nombre: Nombre, anio: Anio} :< Objeto.

%!  materia_objeto(+Materia, -Objeto:dict) is det.
%
%   Objeto es el dict con los datos del término materia/3 Materia.
materia_objeto(materia(Codigo, Nombre, Anio),
               _{codigo: Codigo, nombre: Nombre, anio: Anio}).

%!  materias_a_json(+Materias:list, -Texto:string) is det.
%
%   Texto es la lista de Materias, términos materia/3, escrita como JSON.
materias_a_json(Materias, Texto) :-
    maplist(materia_objeto, Materias, Objetos),
    atom_json_dict(Texto, Objetos, [as(string), width(0)]).

%!  notas_csv(+Archivo, +Notas:list) is det.
%
%   Escribe en Archivo un CSV con una fila de encabezado y una fila por cada
%   término Legajo-Materia-Nota de Notas.
notas_csv(Archivo, Notas) :-
    maplist(fila_nota, Notas, Filas),
    csv_write_file(Archivo, [row(legajo, materia, nota)|Filas],
                   [encoding(utf8)]).

%!  fila_nota(+Nota, -Fila) is det.
%
%   Fila es la fila de CSV del término Legajo-Materia-Nota.
fila_nota(Legajo-Materia-Nota, row(Legajo, Materia, Nota)).

%!  aprueba(+Nota:integer) is semidet.
%
%   Nota alcanza la nota mínima, que es un ajuste del programa.
aprueba(Nota) :-
    setting(nota_minima, Minima),
    Nota >= Minima.

%!  tabla(+Filas:list) is det.
%
%   Escribe Filas, términos Legajo-Nombre-Promedio, como una tabla con
%   columnas alineadas y un encabezado.
tabla(Filas) :-
    format("~w~t~8|~w~t~20|~t~w~30|~n", ['Legajo', 'Nombre', 'Promedio']),
    forall(member(Legajo-Nombre-Promedio, Filas),
           format("~w~t~8|~w~t~20|~t~2f~30|~n",
                  [Legajo, Nombre, Promedio])).
