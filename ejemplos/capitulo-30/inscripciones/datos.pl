:- encoding(utf8).

% Capítulo 30 - Inscripciones, módulo datos: los hechos y el estado.
%
% Los alumnos, las materias, las correlatividades y las inscripciones. Los
% predicados dinámicos se consultan desde los demás módulos, pero solo este
% módulo los modifica: los otros llaman a agregar_inscripcion/3,
% quitar_inscripcion/3, cambiar_vacantes/2 y contar_operacion/0. La nota
% mínima es un ajuste de library(settings), con 6 como valor por omisión.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- alumno(101, Nombre, Carrera, Ingreso).

:- module(datos,
          [ alumno/4,
            materia/3,
            correlativa/2,
            inscripcion/3,
            nota_minima/1,
            vacantes/2,
            operaciones/1,
            agregar_inscripcion/3,
            quitar_inscripcion/3,
            cambiar_vacantes/2,
            contar_operacion/0,
            estado/1,
            restaurar/1,
            comprobar_datos/0
          ]).

:- use_module(library(settings)).

:- dynamic inscripcion/3, vacantes/2, operaciones/1.

% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia se debe aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Estado): el alumno se inscribió en la materia;
% Estado es cursando, o nota(N) con la nota final N, de 1 a 10.
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
inscripcion(101, log, nota(10)).
inscripcion(101, am2, nota(7)).
inscripcion(101, pp,  cursando).
inscripcion(102, am1, nota(4)).
inscripcion(102, log, nota(6)).
inscripcion(102, alg, nota(2)).
inscripcion(103, am1, nota(7)).
inscripcion(103, alg, nota(5)).
inscripcion(103, am2, cursando).
inscripcion(104, log, nota(9)).
inscripcion(104, alg, nota(7)).
inscripcion(104, pp,  nota(8)).
inscripcion(105, am1, cursando).
inscripcion(106, log, nota(3)).
inscripcion(106, am1, nota(6)).

:- setting(nota_minima, between(1, 10), 6,
           'Nota mínima para aprobar una materia').

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia: el valor del ajuste
%   nota_minima, que un archivo de ajustes puede cambiar.
nota_minima(N) :-
    setting(nota_minima, N).

% vacantes(Materia, N): quedan N lugares en la materia.
vacantes(am1, 30).
vacantes(alg, 30).
vacantes(log, 0).
vacantes(am2, 25).
vacantes(pp,  25).
vacantes(ssl, 20).
vacantes(bd,  15).

% operaciones(N): se realizaron N operaciones de inscripción o de baja.
operaciones(0).

%!  agregar_inscripcion(+Legajo:integer, +Materia:atom, +Estado) is det.
%
%   Registra la inscripción del alumno Legajo en Materia, con Estado.
agregar_inscripcion(Legajo, Materia, Estado) :-
    assertz(inscripcion(Legajo, Materia, Estado)).

%!  quitar_inscripcion(+Legajo:integer, +Materia:atom, +Estado) is semidet.
%
%   Quita la inscripción del alumno Legajo en Materia con Estado. Falla si no
%   existe.
quitar_inscripcion(Legajo, Materia, Estado) :-
    retract(inscripcion(Legajo, Materia, Estado)).

%!  cambiar_vacantes(+Materia:atom, +Cambio:integer) is det.
%
%   Suma Cambio a las vacantes de Materia.
cambiar_vacantes(Materia, Cambio) :-
    retract(vacantes(Materia, N0)),
    N is N0 + Cambio,
    assertz(vacantes(Materia, N)).

%!  contar_operacion is det.
%
%   Suma uno al contador de operaciones.
contar_operacion :-
    retract(operaciones(N0)),
    N is N0 + 1,
    assertz(operaciones(N)).

%!  estado(-Estado) is det.
%
%   Estado reúne los datos que cambian durante la ejecución: las
%   inscripciones, las vacantes y el contador de operaciones.
estado(estado(Inscripciones, Vacantes, Operaciones)) :-
    findall(inscripcion(L, M, E), inscripcion(L, M, E), Inscripciones),
    findall(vacantes(M, N), vacantes(M, N), Vacantes),
    operaciones(Operaciones).

%!  restaurar(+Estado) is det.
%
%   Reemplaza los datos que cambian durante la ejecución por los de Estado,
%   obtenido antes con estado/1.
restaurar(estado(Inscripciones, Vacantes, Operaciones)) :-
    retractall(inscripcion(_, _, _)),
    retractall(vacantes(_, _)),
    retractall(operaciones(_)),
    maplist(assertz, Inscripciones),
    maplist(assertz, Vacantes),
    assertz(operaciones(Operaciones)).

%!  comprobar_datos is det.
%
%   Escribe una advertencia por cada inscripción de un alumno o de una
%   materia que no existen. Se ejecuta al cargar el programa.
comprobar_datos :-
    forall(( inscripcion(L, M, _),
             \+ ( alumno(L, _, _, _),
                  materia(M, _, _) ) ),
           print_message(warning, inscripcion_sin_datos(L, M))).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los mensajes propios de Inscripciones.
prolog:message(inscripcion_sin_datos(L, M)) -->
    [ 'Inscripción de ~w en ~w: el alumno o la materia no existen'-[L, M] ].
