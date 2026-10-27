:- encoding(utf8).

% Capítulo 12 - Sección 12.2: aprobación de materias.
%
% "Aprobó todas las materias de la carrera" se escribe como "no tiene
% ninguna materia de la carrera sin aprobar": para todo x, P equivale a
% no existe x tal que no P.
%
%?- exigencias_cumplidas(ingenieria_civil, Nombre).
%?- exigencias_cumplidas(ingenieria_quimica, "Romina Montalbán").

% estudiante(nombre(N), legajo(L)): el estudiante N tiene el legajo L.
estudiante(nombre("Romina Montalbán"), legajo(2490)).
estudiante(nombre("Daniel Hernández"), legajo(2310)).
estudiante(nombre("Lucía Ferreyra"), legajo(2575)).

% materia_carrera(carrera(C), materia(M)): la carrera C exige la materia M.
materia_carrera(carrera(ingenieria_civil), materia(analisis)).
materia_carrera(carrera(ingenieria_civil), materia(algebra)).
materia_carrera(carrera(ingenieria_civil), materia(materiales)).
materia_carrera(carrera(ingenieria_quimica), materia(analisis)).
materia_carrera(carrera(ingenieria_quimica), materia(quimica_general)).
materia_carrera(carrera(ingenieria_quimica), materia(termodinamica)).

% materia_aprobada(legajo(L), carrera(C), materia(M)): el estudiante de
% legajo L aprobó la materia M en la carrera C.
materia_aprobada(legajo(2490), carrera(ingenieria_quimica), materia(analisis)).
materia_aprobada(legajo(2490), carrera(ingenieria_quimica),
                 materia(quimica_general)).
materia_aprobada(legajo(2490), carrera(ingenieria_quimica),
                 materia(termodinamica)).
materia_aprobada(legajo(2310), carrera(ingenieria_civil), materia(analisis)).
materia_aprobada(legajo(2310), carrera(ingenieria_civil), materia(algebra)).
materia_aprobada(legajo(2575), carrera(ingenieria_civil), materia(analisis)).
materia_aprobada(legajo(2575), carrera(ingenieria_civil), materia(algebra)).
materia_aprobada(legajo(2575), carrera(ingenieria_civil), materia(materiales)).

%!  exigencias_cumplidas(+Carrera, ?Nombre) is nondet.
%
%   El estudiante Nombre aprobó todas las materias de Carrera: no tiene
%   ninguna materia de Carrera sin aprobar. Carrera debe llegar ligada.
exigencias_cumplidas(Carrera, Nombre) :-
    estudiante(nombre(Nombre), legajo(L)),
    \+ materia_no_aprobada(Carrera, L, _).

%!  materia_no_aprobada(+Carrera, +L, ?M) is nondet.
%
%   M es una materia de Carrera que el estudiante de legajo L no aprobó.
materia_no_aprobada(Carrera, L, M) :-
    materia_carrera(carrera(Carrera), materia(M)),
    \+ materia_aprobada(legajo(L), carrera(Carrera), materia(M)).
