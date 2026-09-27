:- encoding(utf8).

% Capítulo 31 - Inscripciones, módulo intercambio: el borde con los archivos.
%
% Es el único módulo que lee o escribe archivos. Lo que llega en CSV o en
% JSON se convierte en términos al leerlo, y lo que sale se escribe a partir
% de términos: los demás módulos no dependen de formatos. El estado se guarda
% como un término, el mismo que producen estado/1 y restaurar/1, y los
% ajustes se leen de un archivo con library(settings).
%
% Los archivos de ejemplo están en ../archivos/, con el alias archivos.
%
% solo-local: SWISH no admite módulos propios ni permite usar archivos.
%
%?- importar_alumnos(archivos('alumnos.csv'), Alumnos).
%?- escribir_ranking(user_output).

:- module(intercambio,
          [ importar_alumnos/2,
            importar_materias/2,
            alumnos_distintos/2,
            cargar_ajustes/1,
            guardar_estado/1,
            cargar_estado/1,
            exportar_notas/1,
            escribir_ranking/1,
            exportar_ranking/1
          ]).

:- use_module(library(csv)).
:- use_module(library(http/json)).
:- use_module(library(settings)).
:- use_module(datos).
:- use_module(informes).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   file_directory_name(Aqui, Capitulo),
   directory_file_path(Capitulo, archivos, Dir),
   asserta(user:file_search_path(archivos, Dir)).

%!  importar_alumnos(+Archivo, -Alumnos:list) is det.
%
%   Alumnos son los términos alumno(Legajo, Nombre, Carrera, Ingreso) de las
%   filas de Archivo, un CSV con una fila de encabezado.
importar_alumnos(Archivo, Alumnos) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    csv_read_file(Ruta, [_Encabezado|Alumnos],
                  [functor(alumno), arity(4), encoding(utf8)]).

%!  importar_materias(+Archivo, -Materias:list) is det.
%
%   Materias son los términos materia(Codigo, Nombre, Anio) de los objetos
%   de Archivo, un JSON con una lista de objetos.
importar_materias(Archivo, Materias) :-
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

%!  alumnos_distintos(+Archivo, -Distintos:list) is det.
%
%   Distintos son los alumnos de Archivo, un CSV, que no coinciden con
%   ningún hecho alumno/4 del programa.
alumnos_distintos(Archivo, Distintos) :-
    importar_alumnos(Archivo, Alumnos),
    exclude(es_alumno, Alumnos, Distintos).

%!  es_alumno(+Alumno) is semidet.
%
%   Alumno, un término alumno/4, coincide con un hecho del programa.
es_alumno(alumno(Legajo, Nombre, Carrera, Ingreso)) :-
    alumno(Legajo, Nombre, Carrera, Ingreso).

%!  cargar_ajustes(+Archivo) is det.
%
%   Cambia los ajustes del programa por los de Archivo, que tiene términos
%   setting(Modulo:Nombre, Valor). Los ajustes que no menciona conservan su
%   valor.
cargar_ajustes(Archivo) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    load_settings(Ruta).

%!  guardar_estado(+Archivo) is det.
%
%   Escribe en Archivo el estado del programa, las inscripciones, las
%   vacantes y el contador de operaciones, como un solo término.
guardar_estado(Archivo) :-
    estado(Estado),
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       portray_clause(Stream, Estado),
                       close(Stream)).

%!  cargar_estado(+Archivo) is det.
%
%   Reemplaza el estado del programa por el guardado en Archivo con
%   guardar_estado/1.
%
%   @error domain_error(archivo_de_estado, Archivo) si Archivo no tiene un
%          estado guardado.
cargar_estado(Archivo) :-
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       read_term(Stream, Estado, []),
                       close(Stream)),
    (   Estado = estado(_, _, _)
    ->  restaurar(Estado)
    ;   domain_error(archivo_de_estado, Archivo)
    ).

%!  exportar_notas(+Archivo) is det.
%
%   Escribe en Archivo un CSV con las notas, una fila legajo, materia, nota
%   por cada inscripción con nota, en orden.
exportar_notas(Archivo) :-
    findall(row(Legajo, Materia, Nota),
            inscripcion(Legajo, Materia, nota(Nota)),
            Filas),
    sort(Filas, Ordenadas),
    csv_write_file(Archivo, [row(legajo, materia, nota)|Ordenadas],
                   [encoding(utf8)]).

%!  escribir_ranking(+Stream) is det.
%
%   Escribe en Stream el ranking como una tabla: legajo, nombre y promedio,
%   en columnas alineadas.
escribir_ranking(Stream) :-
    ranking(Ranking),
    format(Stream, "~w~t~8|~w~t~20|~t~w~30|~n",
           ['Legajo', 'Nombre', 'Promedio']),
    forall(member(Legajo-Promedio, Ranking),
           ( alumno(Legajo, Nombre, _, _),
             format(Stream, "~w~t~8|~w~t~20|~t~2f~30|~n",
                    [Legajo, Nombre, Promedio]) )).

%!  exportar_ranking(+Archivo) is det.
%
%   Escribe el ranking, como lo escribe escribir_ranking/1, en Archivo.
exportar_ranking(Archivo) :-
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       escribir_ranking(Stream),
                       close(Stream)).
