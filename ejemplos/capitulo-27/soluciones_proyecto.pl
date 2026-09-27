:- encoding(utf8).

% Capítulo 27 - Soluciones de los ejercicios 12 a 15: el proyecto.
%
% Carga los módulos del proyecto que usan las soluciones. Como el módulo
% intercambio, estos predicados son del borde: leen y escriben archivos, y
% llaman a los predicados del núcleo.
%
% solo-local: SWISH no admite módulos propios ni permite usar archivos.
%
%?- escribir_materias(user_output).

:- use_module(library(csv)).
:- use_module(library(error)).
:- use_module(inscripciones/datos).
:- use_module(inscripciones/informes).
:- use_module(inscripciones/intercambio).

% --- Ejercicio 12 -----------------------------------------------------------

%!  guardar_hechos(+Archivo) is det.
%
%   Escribe en Archivo el estado del programa como hechos, uno por línea:
%   las inscripciones, las vacantes y el contador de operaciones.
guardar_hechos(Archivo) :-
    estado(estado(Inscripciones, Vacantes, Operaciones)),
    append(Inscripciones, Vacantes, Hechos0),
    append(Hechos0, [operaciones(Operaciones)], Hechos),
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       forall(member(H, Hechos), portray_clause(Stream, H)),
                       close(Stream)).

%!  cargar_hechos(+Archivo) is det.
%
%   Reemplaza el estado del programa por los hechos de Archivo, escrito con
%   guardar_hechos/1.
%
%   @error domain_error(archivo_de_hechos, Archivo) si Archivo tiene otros
%          términos, o no tiene exactamente un contador de operaciones.
cargar_hechos(Archivo) :-
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       leer_hechos(Stream, Hechos),
                       close(Stream)),
    partition(es_inscripcion, Hechos, Inscripciones, Resto),
    partition(es_vacantes, Resto, Vacantes, Otros),
    (   Otros = [operaciones(N)]
    ->  restaurar(estado(Inscripciones, Vacantes, N))
    ;   domain_error(archivo_de_hechos, Archivo)
    ).

%!  leer_hechos(+Stream, -Hechos:list) is det.
%
%   Hechos son los términos que quedan en Stream.
leer_hechos(Stream, Hechos) :-
    read_term(Stream, Hecho, []),
    (   Hecho == end_of_file
    ->  Hechos = []
    ;   Hechos = [Hecho|Resto],
        leer_hechos(Stream, Resto)
    ).

%!  es_inscripcion(+Termino) is semidet.
%
%   Termino es un hecho inscripcion/3.
es_inscripcion(inscripcion(_, _, _)).

%!  es_vacantes(+Termino) is semidet.
%
%   Termino es un hecho vacantes/2.
es_vacantes(vacantes(_, _)).

% --- Ejercicio 13 -----------------------------------------------------------

%!  exportar_inscriptos(+Materia:atom, +Archivo) is det.
%
%   Escribe en Archivo un CSV con los inscriptos en Materia, en orden de
%   legajo: legajo, nombre y estado, que es la nota o cursando.
exportar_inscriptos(Materia, Archivo) :-
    findall(row(Legajo, Nombre, Valor),
            ( inscripcion(Legajo, Materia, Estado),
              alumno(Legajo, Nombre, _, _),
              valor_de_estado(Estado, Valor) ),
            Filas0),
    sort(Filas0, Filas),
    csv_write_file(Archivo, [row(legajo, nombre, estado)|Filas],
                   [encoding(utf8)]).

%!  valor_de_estado(+Estado, -Valor) is det.
%
%   Valor es lo que se escribe en el CSV para Estado: la nota, o cursando.
valor_de_estado(nota(N), N).
valor_de_estado(cursando, cursando).

% --- Ejercicio 14 -----------------------------------------------------------

%!  importar_notas(+Archivo) is det.
%
%   Registra las notas de Archivo, un CSV legajo, materia, nota con una fila
%   de encabezado: cada nota reemplaza la inscripción que el alumno tenía en
%   la materia. Valida todas las filas antes de registrar la primera: si una
%   es incorrecta, no se registra ninguna.
%
%   @error existence_error(alumno, Legajo) o existence_error(materia,
%          Materia) si no existen.
%   @error type_error(between(1, 10), Nota) si la nota no es válida.
importar_notas(Archivo) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    csv_read_file(Ruta, [_Encabezado|Filas], [encoding(utf8)]),
    maplist(validar_fila, Filas),
    maplist(registrar_fila, Filas).

%!  validar_fila(+Fila) is det.
%
%   Fila, row(Legajo, Materia, Nota), tiene un alumno y una materia que
%   existen y una nota válida.
validar_fila(row(Legajo, Materia, Nota)) :-
    (   alumno(Legajo, _, _, _)
    ->  true
    ;   existence_error(alumno, Legajo)
    ),
    (   materia(Materia, _, _)
    ->  true
    ;   existence_error(materia, Materia)
    ),
    must_be(between(1, 10), Nota).

%!  registrar_fila(+Fila) is det.
%
%   Registra la nota de Fila, row(Legajo, Materia, Nota), en lugar de la
%   inscripción anterior del alumno en la materia, si tenía una.
registrar_fila(row(Legajo, Materia, Nota)) :-
    ignore(quitar_inscripcion(Legajo, Materia, _)),
    agregar_inscripcion(Legajo, Materia, nota(Nota)).

% --- Ejercicio 15 -----------------------------------------------------------

%!  escribir_materias(+Stream) is det.
%
%   Escribe en Stream una tabla con cada materia: código, nombre, año,
%   cantidad de inscriptos y promedio de sus notas, o un guion si no tiene
%   ninguna.
escribir_materias(Stream) :-
    format(Stream, "~w~t~8|~w~t~24|~w~t~30|~t~w~42|~t~w~52|~n",
           ['Código', 'Nombre', 'Año', 'Inscriptos', 'Promedio']),
    forall(materia(Codigo, Nombre, Anio),
           ( inscriptos(Codigo, Legajos),
             length(Legajos, Cantidad),
             promedio_texto(Codigo, Promedio),
             format(Stream, "~w~t~8|~w~t~24|~w~t~30|~t~d~42|~t~w~52|~n",
                    [Codigo, Nombre, Anio, Cantidad, Promedio]) )).

%!  promedio_texto(+Materia:atom, -Texto:atom) is det.
%
%   Texto es el promedio de Materia con dos decimales, o un guion si la
%   materia no tiene notas.
promedio_texto(Materia, Texto) :-
    (   promedio_de_materia(Materia, Promedio)
    ->  format(atom(Texto), "~2f", [Promedio])
    ;   Texto = '-'
    ).
