:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(unidireccional).

test(mas_general_de_todos, [true(T =@= pieza(_, _, _, _))]) :-
    mas_general_de_todos(T).

test(generalizacion_vacio, [true(S == pieza(cubo, rojo, chico, metal))]) :-
    generalizacion(vacio, pieza(cubo, rojo, chico, metal), S).

test(generalizacion_lgg, [true(S =@= pieza(esfera, _, chico, _))]) :-
    generalizacion(pieza(esfera, rojo, chico, _),
                   pieza(esfera, azul, chico, metal), S).

test(especializaciones, [true(N == 6)]) :-
    aggregate_all(count,
                  especializacion(pieza(_, _, _, _),
                                  pieza(cilindro, verde, grande, metal), _),
                  N).

% Ninguna especialización cubre la instancia, y todas son más
% específicas que el concepto de partida.
test(especializacion_correcta, [true]) :-
    G = pieza(esfera, _, _, _),
    I = pieza(esfera, rojo, chico, madera),
    forall(especializacion(G, I, H),
           ( \+ cubre(H, I),
             generaliza(G, H),
             \+ generaliza(H, G) )).

test(especializacion_no_liga, [true(G =@= pieza(esfera, _, _, _))]) :-
    G = pieza(esfera, _, _, _),
    forall(especializacion(G, pieza(esfera, rojo, chico, madera), _),
           true).

test(especifico, [true(S =@= [pieza(esfera, rojo, _, _)])]) :-
    secuencia(esfera_roja, Ejs),
    especifico(Ejs, S).

test(general, [true(G =@= [pieza(esfera, rojo, _, _)])]) :-
    secuencia(esfera_roja, Ejs),
    general(Ejs, G).

test(general_dos, [true(G =@= [pieza(esfera, _, _, _), pieza(_, rojo, _, _),
                               pieza(_, _, chico, _),
                               pieza(_, _, _, madera)])]) :-
    secuencia(esfera_roja, [E1, E2|_]),
    general([E1, E2], G).

% Cada búsqueda da, en cada prefijo, los mínimos o los máximos del
% espacio de versiones calculado por enumeración.
test(igual_a_enumerar, [true]) :-
    secuencia(esfera_roja, Ejs),
    forall(( append(P, _, Ejs) ),
           ( version(P, V),
             minimos(V, Mi0),
             maximos(V, Ma0),
             conjunto(Mi0, Mi),
             conjunto(Ma0, Ma),
             especifico(P, S0),
             general(P, G0),
             conjunto(S0, S),
             conjunto(G0, G),
             S =@= Mi,
             G =@= Ma )).

test(colapso, [true(S-G == []-[])]) :-
    secuencia(rojo_o_esfera, Ejs),
    especifico(Ejs, S),
    general(Ejs, G).

test(mostrar, [true(Salida == "pieza(esfera, _, chico, _)\n")]) :-
    with_output_to(string(Salida),
                   mostrar_conceptos([pieza(esfera, _, chico, _)])).

test(una_direccion, [true(S-G =@= [pieza(esfera, rojo, _, _)]-
                                  [pieza(esfera, _, _, _),
                                   pieza(_, rojo, _, _)])]) :-
    una_direccion(esfera_roja, 3, S, G).

:- end_tests(unidireccional).
