:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(preguntas).

espacio_de_tres(EV) :-
    secuencia(esfera_roja, [A, B, C|_]),
    eliminar([A, B, C], EV).

test(positivo, [true(K == positivo)]) :-
    espacio_de_tres(EV),
    clasificar(EV, pieza(esfera, rojo, chico, metal), K).

test(negativo, [true(K == negativo)]) :-
    espacio_de_tres(EV),
    clasificar(EV, pieza(cubo, verde, chico, metal), K).

test(desconocido, [true(K == desconocido)]) :-
    espacio_de_tres(EV),
    clasificar(EV, pieza(esfera, azul, grande, metal), K).

test(sin_ejemplos, [true(K == desconocido)]) :-
    inicial(EV),
    clasificar(EV, pieza(esfera, azul, grande, metal), K).

test(votos, [true(S-N == 1-2)]) :-
    espacio_de_tres(EV),
    votos(EV, pieza(esfera, azul, grande, metal), S, N).

% La clase conocida coincide con la de todos los conceptos del espacio.
test(clasificar_segun_votos, [true]) :-
    espacio_de_tres(EV),
    forall(instancia(I),
           ( clasificar(EV, I, K),
             votos(EV, I, S, N),
             (   K == positivo
             ->  N =:= 0
             ;   K == negativo
             ->  S =:= 0
             ;   S > 0,
                 N > 0
             ) )).

test(objetivo, [true(E1-E2 == pos(pieza(cubo, rojo, chico, metal))-
                              neg(pieza(cubo, azul, chico, metal)))]) :-
    objetivo(pieza(_, rojo, _, _), pieza(cubo, rojo, chico, metal), E1),
    objetivo(pieza(_, rojo, _, _), pieza(cubo, azul, chico, metal), E2).

test(primer_positivo, [true(I == pieza(esfera, verde, chico, metal))]) :-
    primer_positivo(pieza(_, verde, _, metal), I).

test(activo, [true(N-C =@= 5-pieza(_, verde, _, metal))]) :-
    activo(pieza(_, verde, _, metal), Ps, convergio(C)),
    length(Ps, N).

test(pasivo, [true(N-C =@= 18-pieza(_, verde, _, metal))]) :-
    pasivo(pieza(_, verde, _, metal), N, convergio(C)).

% El aprendiz activo aprende cada concepto del lenguaje con un ejemplo
% por atributo, y llega al concepto enseñado.
test(activo_todos, [true]) :-
    forall(( concepto(C),
             C \== vacio ),
           ( activo(C, Ps, convergio(D)),
             length(Ps, 5),
             D =@= C )).

test(ruido, [true(E == colapso)]) :-
    secuencia(esfera_roja, Ejs),
    append(Ejs, [neg(pieza(esfera, rojo, grande, madera))], Ruido),
    eliminar(Ruido, EV),
    estado(EV, E).

:- end_tests(preguntas).
