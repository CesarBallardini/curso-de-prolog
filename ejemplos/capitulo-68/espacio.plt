:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(espacio).

test(instancias, [true(N == 36)]) :-
    aggregate_all(count, instancia(_), N).

test(conceptos, [true(N == 145)]) :-
    aggregate_all(count, concepto(_), N).

test(instancia_sin_variables, [true]) :-
    forall(instancia(I), ground(I)).

test(cubre, [true]) :-
    cubre(pieza(esfera, _, _, madera), pieza(esfera, rojo, chico, madera)).

test(no_cubre, [fail]) :-
    cubre(pieza(esfera, _, _, madera), pieza(cubo, rojo, chico, madera)).

test(vacio_no_cubre, [fail]) :-
    instancia(I),
    cubre(vacio, I).

test(cubre_no_liga, [true(C =@= pieza(_, rojo, _, _))]) :-
    C = pieza(_, rojo, _, _),
    cubre(C, pieza(cubo, rojo, chico, metal)).

test(generaliza_vacio, [true]) :-
    forall(concepto(C), generaliza(C, vacio)).

test(generaliza_orden, [true]) :-
    generaliza(pieza(_, rojo, _, _), pieza(esfera, rojo, _, _)),
    \+ generaliza(pieza(esfera, rojo, _, _), pieza(_, rojo, _, _)).

% Un concepto cubre tantas instancias como el producto de la cantidad de
% valores de sus atributos libres.
test(cobertura_de_un_concepto, [true(N == 6)]) :-
    aggregate_all(count, ( instancia(I),
                           cubre(pieza(esfera, _, chico, _), I) ), N).

test(consistente, [true]) :-
    secuencia(esfera_roja, Ejs),
    consistente(pieza(esfera, rojo, _, _), Ejs).

test(inconsistente, [fail]) :-
    secuencia(esfera_roja, Ejs),
    consistente(pieza(_, rojo, _, _), Ejs).

test(version_sin_ejemplos, [true(N == 145)]) :-
    version([], V),
    length(V, N).

test(version_final, [true(V =@= [pieza(esfera, rojo, _, _)])]) :-
    secuencia(esfera_roja, Ejs),
    version(Ejs, V).

test(tamanos, [true(Ns == [145, 16, 15, 3, 2, 1])]) :-
    secuencia(esfera_roja, Ejs),
    findall(N, ( between(0, 5, K),
                 length(P, K),
                 append(P, _, Ejs),
                 version(P, V),
                 length(V, N) ), Ns).

test(colapso, [true(V == [])]) :-
    secuencia(rojo_o_esfera, Ejs),
    version(Ejs, V).

test(bordes_iniciales, [true(M-X =@= [vacio]-[pieza(_, _, _, _)])]) :-
    version([], V),
    minimos(V, M),
    maximos(V, X).

test(bordes_dos, [true(X =@= [pieza(_, _, _, madera), pieza(_, _, chico, _),
                              pieza(_, rojo, _, _),
                              pieza(esfera, _, _, _)])]) :-
    secuencia(esfera_roja, [E1, E2|_]),
    version([E1, E2], V),
    maximos(V, X).

test(conjunto, [true(C =@= [pieza(esfera, _, _, _), pieza(_, rojo, _, _)])]) :-
    conjunto([pieza(esfera, _, _, _), pieza(_, rojo, _, _),
              pieza(esfera, _, _, _)], C).

test(tamanos_nombre, [true(Ns == [145, 16, 15, 3, 2, 1])]) :-
    tamanos(esfera_roja, Ns).

test(bordes_enumerados, [true(S-G =@= [pieza(esfera, rojo, _, _)]-
                                      [pieza(_, rojo, _, _),
                                       pieza(esfera, _, _, _)])]) :-
    bordes_enumerados(esfera_roja, 3, S, G).

test(prefijos, [true(N == 6)]) :-
    aggregate_all(count, prefijo(esfera_roja, _, _), N).

:- end_tests(espacio).
