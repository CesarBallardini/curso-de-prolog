:- encoding(utf8).

% Capítulo 42 - Soluciones de los ejercicios 3 a 10 y 12 a 14.
%
% Carga las tablas académicas de universidad.pl y las de empleados y
% vuelos de recursion.pl.
%
% solo-local: carga otros dos archivos, y SWISH no carga archivos.
%
%?- aprobada_con_nombres(A, M, N).
%?- sin_inscripciones(L, N).
%?- correlativa_pendiente(L, M, R).
%?- nivel(Id, K).

:- ensure_loaded(universidad).
:- ensure_loaded(recursion).

% Ejercicio 3

%!  aprobada_con_nombres(?Alumno, ?Materia, ?Nota) is nondet.
%
%   El alumno de nombre Alumno aprobó la materia de nombre Materia con
%   Nota: la reunión de tres tablas.
aprobada_con_nombres(Alumno, Materia, Nota) :-
    inscripcion(L, M, Nota),
    integer(Nota),
    Nota >= 6,
    alumno(L, Alumno, _, _),
    materia(M, Materia, _).

% Ejercicio 4

%!  misma_carrera(?Nombre1, ?Nombre2, ?Carrera) is nondet.
%
%   Dos alumnos distintos de la misma Carrera, cada par una vez.
misma_carrera(Nombre1, Nombre2, Carrera) :-
    alumno(L1, Nombre1, Carrera, _),
    alumno(L2, Nombre2, Carrera, _),
    L1 < L2.

% Ejercicio 5

%!  en_am1_o_log(?Legajo) is nondet.
%
%   El alumno de Legajo está inscripto en am1 o en log: una respuesta por
%   inscripción, como UNION ALL.
en_am1_o_log(Legajo) :-
    inscripcion(Legajo, am1, _).
en_am1_o_log(Legajo) :-
    inscripcion(Legajo, log, _).

% Ejercicio 6

%!  sin_inscripciones(?Legajo, ?Nombre) is nondet.
%
%   El alumno de Legajo no tiene ninguna inscripción. alumno/4 liga Legajo
%   antes de la negación.
sin_inscripciones(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _),
    \+ inscripcion(Legajo, _, _).

% Ejercicio 7

%!  aprobo_primer_anio(?Legajo, ?Nombre) is nondet.
%
%   El alumno de Legajo aprobó todas las materias de primer año.
aprobo_primer_anio(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _),
    forall(materia(M, _, 1), aprobada(Legajo, M, _)).

% Ejercicio 8

%!  promedio_alumno(?Legajo, ?Promedio) is nondet.
%
%   Promedio de las notas del alumno de Legajo, sin las filas con null.
%   Un alumno sin ninguna nota no tiene promedio.
promedio_alumno(Legajo, Promedio) :-
    bagof(N, M^(inscripcion(Legajo, M, N), integer(N)), Notas),
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    Promedio is Suma / Cantidad.

% Ejercicio 9

%!  correlativa_pendiente(?Legajo, ?Materia, ?Requisito) is nondet.
%
%   El alumno de Legajo está inscripto en Materia sin haber aprobado
%   Requisito, una de sus correlativas.
correlativa_pendiente(Legajo, Materia, Requisito) :-
    inscripcion(Legajo, Materia, _),
    correlativa(Materia, Requisito),
    \+ aprobada(Legajo, Requisito, _).

% Ejercicio 10

%!  no_depende_de(?Nombre, +Jefe) is nondet.
%
%   El empleado Nombre tiene un jefe directo y no es Jefe, como en SQL,
%   donde jefe <> 1 no es verdadero cuando jefe es NULL.
no_depende_de(Nombre, Jefe) :-
    empleado(_, Nombre, _, _, J),
    J \== null,
    J \== Jefe.

% Ejercicio 12

%!  nivel(?Id, ?Nivel) is nondet.
%
%   Nivel es la cantidad de jefes que hay entre el empleado Id y la
%   directora, que tiene nivel 0.
nivel(Id, 0) :-
    empleado(Id, _, _, _, null).
nivel(Id, Nivel) :-
    jefe(Id, Jefe),
    nivel(Jefe, Nivel0),
    Nivel is Nivel0 + 1.

% Ejercicio 13

%!  viaje(+Origen, ?Destino, -Precio, +Tope) is nondet.
%
%   Precio es el precio de un viaje de Origen a Destino de a lo sumo Tope
%   vuelos, sin tabla: la cota hace terminar la recursión, como el
%   contador de tramos de la consulta SQL.
viaje(Origen, Destino, Precio, _) :-
    vuelo(Origen, Destino, _, Precio).
viaje(Origen, Destino, Precio, Tope) :-
    Tope > 1,
    vuelo(Origen, Escala, _, P1),
    Tope1 is Tope - 1,
    viaje(Escala, Destino, P2, Tope1),
    Precio is P1 + P2.

%!  tarifa_con_tope(+Origen, ?Destino, -Precio) is nondet.
%
%   El menor precio de cada destino entre los viajes de a lo sumo tantos
%   vuelos como aeropuertos hay.
tarifa_con_tope(Origen, Destino, Precio) :-
    aggregate_all(count, aeropuerto(_), Tope),
    setof(D, P^viaje(Origen, D, P, Tope), Destinos),
    member(Destino, Destinos),
    aggregate_all(min(P), viaje(Origen, Destino, P, Tope), Precio).

%!  aeropuerto(?A) is nondet.
%
%   A es origen o destino de algún vuelo, una vez cada uno.
aeropuerto(A) :-
    setof(X, aparece(X), As),
    member(A, As).

%!  aparece(?A) is nondet.
%
%   A es origen o destino de un vuelo, una vez por cada vuelo.
aparece(A) :-
    vuelo(A, _, _, _).
aparece(A) :-
    vuelo(_, A, _, _).

% Ejercicio 14

%!  aumentar(+Depto, +Porcentaje) is det.
%
%   Aumenta en Porcentaje el salario de cada empleado de Depto, con
%   división entera como en SQL.
aumentar(Depto, Porcentaje) :-
    forall(retract(empleado(Id, Nombre, Depto, Salario, Jefe)),
           ( Nuevo is Salario * (100 + Porcentaje) // 100,
             assertz(empleado(Id, Nombre, Depto, Nuevo, Jefe)) )).
