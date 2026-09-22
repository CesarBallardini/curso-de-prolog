:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 2
test(los_animales, all(X == [felix, gaturro, rocco])) :-
    animal(X).

% Ejercicio 4
test(quienes_pueden_entrar, all(P == [ana, pedro, luis, eva])) :-
    puede_entrar(P).

test(un_desconocido_no_entra, [fail]) :-
    puede_entrar(juan).

% Ejercicio 5
test(siete_es_impar, all(P == [impar])) :-
    paridad(7, P).

test(ocho_es_par, all(P == [par])) :-
    paridad(8, P).

% Ejercicio 7
test(los_que_no_tienen_mascota, all(P == [luis, eva])) :-
    sin_mascota(P).

test(ana_tiene_mascota, [fail]) :-
    sin_mascota(ana).

% Ejercicio 10
test(el_que_tiene_gato_tiene_mascota, all(P == [ana, eva])) :-
    tiene_mascota(P).

test(nadie_es_padre_de_si_mismo, all(P == [ana, luis, eva])) :-
    no_es_padre_de_si_mismo(P).

:- end_tests(soluciones).
