:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3
test(los_animales, all(X == [felix, gaturro, rocco])) :-
    animal(X).

% Ejercicio 4: juan y marta tienen dos nietos cada uno; una respuesta por nieto.
test(quienes_tienen_nieto, all(A == [juan, juan, marta, marta])) :-
    tiene_nieto(A).

% Ejercicio 7
test(quienes_pueden_entrar, all(P == [ana, pedro, luis, eva])) :-
    puede_entrar(P).

test(un_desconocido_no_entra, [fail]) :-
    puede_entrar(juan).

% Ejercicio 8
test(siete_es_impar, all(P == [impar])) :-
    paridad(7, P).

test(ocho_es_par, all(P == [par])) :-
    paridad(8, P).

% Ejercicio 9
test(el_que_tiene_gato_tiene_mascota, all(P == [ana, eva])) :-
    tiene_mascota(P).

test(nadie_es_padre_de_si_mismo, all(P == [ana, luis, eva])) :-
    no_es_padre_de_si_mismo(P).

% Ejercicio 16: llueve, de modo que no hay picnic y no se rema.
test(no_se_rema, [fail]) :-
    remar.

% Ejercicio 20
test(partir_una_lista, all(X-Y == [[]-[a, b], [a]-[b], [a, b]-[]])) :-
    concatenar(X, Y, [a, b]).

% Ejercicio 22
test(ningun_camino_de_e_a_b, [fail]) :-
    q(e, b).

% Ejercicio 23
test(los_que_no_tienen_mascota, all(P == [luis, eva])) :-
    sin_mascota(P).

test(ana_tiene_mascota, [fail]) :-
    sin_mascota(ana).

:- end_tests(soluciones).
