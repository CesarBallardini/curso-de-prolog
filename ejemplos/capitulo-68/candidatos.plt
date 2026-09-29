:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(candidatos).

test(inicial, [true(EV =@= ev([vacio], [pieza(_, _, _, _)]))]) :-
    inicial(EV).

test(final, [true(EV =@= ev([pieza(esfera, rojo, _, _)],
                            [pieza(esfera, rojo, _, _)]))]) :-
    secuencia(esfera_roja, Ejs),
    eliminar(Ejs, EV).

test(converge, [true(C =@= pieza(esfera, rojo, _, _))]) :-
    secuencia(esfera_roja, Ejs),
    eliminar(Ejs, EV),
    estado(EV, convergio(C)).

test(abierto, [true(E == abierto)]) :-
    secuencia(esfera_roja, [E1, E2, E3|_]),
    eliminar([E1, E2, E3], EV),
    estado(EV, E).

test(colapsa, [true(E == colapso)]) :-
    secuencia(rojo_o_esfera, Ejs),
    eliminar(Ejs, EV),
    estado(EV, E).

% En cada prefijo, los bordes son los mínimos y los máximos del espacio
% de versiones de la versión 1, y los conceptos entre ellos son
% exactamente los consistentes.
test(igual_a_enumerar, [true]) :-
    secuencia(esfera_roja, Ejs),
    forall(append(P, _, Ejs),
           ( version(P, V),
             length(V, N),
             minimos(V, Mi0),
             maximos(V, Ma0),
             conjunto(Mi0, Mi),
             conjunto(Ma0, Ma),
             eliminar(P, EV),
             EV = ev(S, G),
             S =@= Mi,
             G =@= Ma,
             entre_bordes(EV, N) )).

test(entre_bordes, [true(Ns == [16, 15, 3, 2, 1])]) :-
    secuencia(esfera_roja, Ejs),
    findall(N, ( append(P, _, Ejs),
                 P \== [],
                 eliminar(P, EV),
                 entre_bordes(EV, N) ), Ns).

% Los bordes no dependen del orden de los ejemplos.
test(orden, [true(EV1 =@= EV2)]) :-
    secuencia(esfera_roja, Ejs),
    reverse(Ejs, Inv),
    eliminar(Ejs, EV1),
    eliminar(Inv, EV2).

test(traza, [true(sub_string(Salida, _, _, 0,
                             "converge en pieza(esfera, rojo, _, _)\n"))]) :-
    with_output_to(string(Salida), traza(esfera_roja)).

test(extra_se_quitan, [true(N == 4)]) :-
    con_extra(3, true),
    aggregate_all(count, atributo(_, _), N).

test(extra_conceptos, [true(N == 577)]) :-
    con_extra(1, aggregate_all(count, concepto(_), N)).

test(comparar, [true(B < E)]) :-
    comparar(2, B, E).

test(eliminar_de, [true(EV =@= ev([pieza(esfera, rojo, _, _)],
                                  [pieza(esfera, _, _, _),
                                   pieza(_, rojo, _, _)]))]) :-
    eliminar_de(esfera_roja, 3, EV).

:- end_tests(candidatos).
