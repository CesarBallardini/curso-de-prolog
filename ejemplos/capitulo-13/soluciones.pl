:- encoding(utf8).

% Capítulo 13 - Soluciones de los ejercicios.
%
%?- nieto(luis, Quien).
%?- hermano(ana, Quien).

% --- Ejercicio 1 -----------------------------------------------------------

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% persona(P): P es una de las personas de la familia.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A, y es una persona registrada.
nieto(N, A) :-
    abuelo(A, N),
    persona(N).

% --- Ejercicio 6 -----------------------------------------------------------

%!  hermano(?A, ?B) is nondet.
%
%   A y B son hermanos: tienen el mismo padre y son personas distintas.
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.

% --- Ejercicios 8 y 11: los datos de Inscripciones -------------------------

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia es necesario aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Nota): el alumno cursó o cursa la materia;
% Nota es null mientras la cursa y todavía no tiene nota.
inscripcion(101, am1, 8).
inscripcion(101, alg, 9).
inscripcion(101, log, 10).
inscripcion(101, am2, 7).
inscripcion(101, pp,  null).
inscripcion(102, am1, 4).
inscripcion(102, log, 6).
inscripcion(102, alg, 2).
inscripcion(103, am1, 7).
inscripcion(103, alg, 5).
inscripcion(103, am2, null).
inscripcion(104, log, 9).
inscripcion(104, alg, 7).
inscripcion(104, pp,  8).
inscripcion(105, am1, null).
inscripcion(106, log, 3).
inscripcion(106, am1, 6).
