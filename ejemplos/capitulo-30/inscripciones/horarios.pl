:- encoding(utf8).

% Capítulo 30 - Inscripciones, módulo horarios: el calendario de exámenes.
%
% Un modelo de restricciones: una variable por materia, los conflictos entre
% materias con alumnos en común, la capacidad de cada día.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- horario(5, 6, Horario).

:- module(horarios,
          [ horario/3,
            conflicto/2
          ]).

:- use_module(library(clpfd)).
:- use_module(datos).
:- use_module(informes).

%!  horario(+Dias:integer, +Capacidad:integer, -Horario:list(pair)) is nondet.
%
%   Horario son pares Materia-Dia, con días de 1 a Dias, tales que dos
%   materias con un alumno inscripto en común rinden en días distintos y la
%   cantidad de alumnos que rinden cada día no supera Capacidad.
horario(Dias, Capacidad, Horario) :-
    findall(M-_, materia(M, _, _), Horario),
    pairs_values(Horario, Ds),
    Ds ins 1..Dias,
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dias_distintos(Horario), Conflictos),
    numlist(1, Dias, Todos),
    maplist(capacidad_del_dia(Horario, Capacidad), Todos),
    label(Ds).

%!  conflicto(?M1:atom, ?M2:atom) is nondet.
%
%   M1 y M2 son materias distintas, M1 antes que M2 en orden alfabético, con
%   al menos un alumno inscripto en las dos. Una respuesta por par.
conflicto(M1, M2) :-
    materia(M1, _, _),
    materia(M2, _, _),
    M1 @< M2,
    once(( inscripcion(L, M1, _),
           inscripcion(L, M2, _) )).

%!  dias_distintos(+Horario:list(pair), +Conflicto:pair) is det.
%
%   Las dos materias de Conflicto tienen el examen en días distintos.
dias_distintos(Horario, M1-M2) :-
    memberchk(M1-D1, Horario),
    memberchk(M2-D2, Horario),
    D1 #\= D2.

%!  capacidad_del_dia(+Horario:list(pair), +Capacidad:integer, +Dia:integer)
%!      is det.
%
%   Los alumnos inscriptos en las materias que rinden el día Dia no son más
%   que Capacidad. Cada materia aporta sus inscriptos si su día es Dia: la
%   comparación se refleja en una variable 0 o 1.
capacidad_del_dia(Horario, Capacidad, Dia) :-
    maplist(rinde_ese_dia(Dia), Horario, Rinden),
    maplist(cantidad_de_inscriptos, Horario, Cantidades),
    scalar_product(Cantidades, Rinden, #=<, Capacidad).

%!  rinde_ese_dia(+Dia:integer, +MateriaDia:pair, -B) is det.
%
%   B es 1 si la materia rinde el día Dia, y 0 si no.
rinde_ese_dia(Dia, _-D, B) :-
    B #<==> (D #= Dia).

%!  cantidad_de_inscriptos(+MateriaDia:pair, -N:integer) is det.
%
%   N es la cantidad de alumnos inscriptos en la materia.
cantidad_de_inscriptos(M-_, N) :-
    inscriptos(M, Legajos),
    length(Legajos, N).
