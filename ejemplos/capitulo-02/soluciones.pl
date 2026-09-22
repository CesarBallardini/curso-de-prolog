:- encoding(utf8).

% Capítulo 2 - Soluciones de los ejercicios.
%
% La base del capítulo, con los hechos que piden agregar los ejercicios 1 y 10,
% y las relaciones nuevas de los ejercicios 7 y 12.
%
%?- padre(Quien, sofia).
%?- regala(Quien, Que, ana).

% --- La base del capítulo -------------------------------------------------
varon(juan).
varon(pedro).
varon(luis).
% Ejercicio 10: para que sofia tenga padre es necesario indicar quién es.
varon(diego).

mujer(marta).
mujer(ana).
mujer(eva).
% Ejercicio 1: "Sofía es mujer".
mujer(sofia).

padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).
% Ejercicio 10.
padre(diego, sofia).

% Ejercicio 1: "Marta es la madre de Ana".
madre(marta, ana).
madre(marta, pedro).
madre(eva, sofia).

% Ejercicio 1: "a Luis le gusta el fútbol".
gusta(luis, futbol).
gusta(juan, futbol).
gusta(ana, prolog).
gusta(eva, prolog).
gusta(sofia, dibujar).

% --- Ejercicio 7: una relación de tres argumentos -------------------------
% regala(Quien, Que, AQuien): Quien le regala Que a AQuien.
regala(juan, libro, ana).
regala(ana, pelota, luis).
regala(marta, planta, eva).

% --- Ejercicio 12: una base que no es una familia -------------------------
% cursa(P, M): P cursa la materia M.
cursa(ana, logica).
cursa(ana, algebra).
cursa(luis, logica).
cursa(eva, analisis).

% dicta(D, M): D dicta la materia M.
dicta(garcia, logica).
dicta(garcia, algebra).
dicta(pereyra, analisis).

% --- Ejercicio 13: representar enunciados como hechos ---------------------
% nacio_en(P, A): P nació en el año A.
nacio_en(ana, 1985).

% horas_semanales(M, H): la materia M tiene H horas por semana.
horas_semanales(logica, 4).

% companiero(A, B): A y B son compañeros de trabajo.
% La relación es simétrica, y por eso se escriben los dos hechos: Prolog no
% deduce uno del otro.
companiero(ana, luis).
companiero(luis, ana).
