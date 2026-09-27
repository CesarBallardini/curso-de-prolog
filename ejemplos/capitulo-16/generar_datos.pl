:- encoding(utf8).

% Capítulo 16 - Datos generados: 5 000 alumnos y 25 000 inscripciones.
%
% Para medir un programa hacen falta datos del tamaño en que se va a usar. Este
% archivo los genera con assertz/1, que agrega hechos durante la ejecución (el
% capítulo 20 lo presenta; aquí solo sirve para crear los datos de prueba). Los
% datos son siempre los mismos: cada alumno y cada nota se calculan a partir de
% su número, sin azar.
%
%?- generar(5000), comparar(alumno_2500, bd).

:- dynamic alumno/4, inscripcion/3.

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(bd,  bases_de_datos, 3).

%!  generar(+N:integer) is det.
%
%   Reemplaza los datos por N alumnos, con una inscripción a cada materia.
%   El alumno K se llama alumno_K, y su nota en la materia de posición M es
%   1 + (K + 3 * M) mod 10.
generar(N) :-
    retractall(alumno(_, _, _, _)),
    retractall(inscripcion(_, _, _)),
    forall(between(1, N, K), agregar_alumno(K)).

%!  agregar_alumno(+K:integer) is det.
%
%   Agrega el alumno K y sus inscripciones.
agregar_alumno(K) :-
    atom_concat(alumno_, K, Nombre),
    assertz(alumno(K, Nombre, sistemas, 2024)),
    forall(nth1(M, [am1, alg, log, am2, bd], Materia),
           ( Nota is 1 + (K + 3 * M) mod 10,
             assertz(inscripcion(K, Materia, nota(Nota))) )).

%!  aprobada_lenta(?Nombre:atom, ?Materia:atom) is nondet.
%
%   El alumno llamado Nombre aprobó Materia. Recorre primero las
%   inscripciones y después busca el alumno de cada una.
aprobada_lenta(Nombre, Materia) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    Nota >= 6,
    alumno(Legajo, Nombre, _, _).

%!  aprobada_rapida(?Nombre:atom, ?Materia:atom) is nondet.
%
%   La misma relación, con el orden de los objetivos invertido: primero el
%   alumno, que el nombre selecciona, y después sus inscripciones.
aprobada_rapida(Nombre, Materia) :-
    alumno(Legajo, Nombre, _, _),
    inscripcion(Legajo, Materia, nota(Nota)),
    Nota >= 6.

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa Objetivo hasta agotar todas sus
%   respuestas: el costo de la relación completa, y no solo de la primera.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    forall(Objetivo, true),
    statistics(inferences, I1),
    I is I1 - I0.

%!  comparar(+Nombre:atom, +Materia:atom) is det.
%
%   Escribe las inferencias que usa cada versión para Nombre y Materia,
%   hasta agotar las respuestas.
comparar(Nombre, Materia) :-
    inferencias(aprobada_lenta(Nombre, Materia), Lenta),
    inferencias(aprobada_rapida(Nombre, Materia), Rapida),
    format("aprobada_lenta: ~D inferencias~n", [Lenta]),
    format("aprobada_rapida: ~D inferencias~n", [Rapida]).
