:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(soluciones_interactivo).

% texto(+Ejs, -Txt): Txt es la lista de ejemplos Ejs escrita como términos,
% uno por línea.
texto(Ejs, Txt) :-
    with_output_to(string(Txt),
                   forall(member(E, Ejs), format("~q.~n", [E]))).

% sesion(+Txt, -EV, -Salida): EV y la Salida escrita por el lazo con la
% entrada Txt.
sesion(Txt, EV, Salida) :-
    with_output_to(string(Salida),
                   con_entrada(Txt, aprender_interactivo(EV))).

% El lazo llega a los mismos bordes que eliminar/2, con o sin fin.
test(como_eliminar, [true(EV =@= EV1)]) :-
    secuencia(esfera_roja, Ejs),
    texto(Ejs, Txt),
    sesion(Txt, EV, _),
    eliminar(Ejs, EV1).

test(converge, [true(EV =@= ev([pieza(esfera, rojo, _, _)],
                               [pieza(esfera, rojo, _, _)]))]) :-
    secuencia(esfera_roja, Ejs),
    texto(Ejs, Txt0),
    string_concat(Txt0, "fin.\n", Txt),
    sesion(Txt, EV, Salida),
    sub_string(Salida, _, _, 0, "  converge en pieza(esfera, rojo, _, _)\n").

test(colapso, [true(EV == ev([], []))]) :-
    secuencia(rojo_o_esfera, Ejs),
    texto(Ejs, Txt),
    sesion(Txt, EV, Salida),
    sub_string(Salida, _, _, 0, "  colapso\n").

% Después de cada ejemplo se escriben los dos bordes y el estado.
test(informe, [true(Salida == Esperada)]) :-
    sesion("pos(pieza(esfera, rojo, chico, madera)).", _, Salida),
    atomic_list_concat([ "pos(pieza(esfera, rojo, chico, madera))",
                         "  S:",
                         "    pieza(esfera, rojo, chico, madera)",
                         "  G:",
                         "    pieza(_, _, _, _)",
                         "  abierto",
                         "" ], "\n", A),
    atom_string(A, Esperada).

% Lo que sigue a fin no se lee.
test(fin, [true(EV =@= ev([pieza(esfera, rojo, chico, madera)],
                          [pieza(_, _, _, _)]))]) :-
    sesion("pos(pieza(esfera, rojo, chico, madera)). fin. \c
            neg(pieza(cubo, rojo, chico, madera)).", EV, _).

test(entrada_vacia, [true(EV =@= EV0)]) :-
    sesion("", EV, Salida),
    inicial(EV0),
    Salida == "".

% Cada término mal formado se informa y se ignora; el espacio no cambia.
test(mal_formados, [true(EV-N =@= EV0-6)]) :-
    sesion("pos(pieza(esfera, rojo, grande)). \c
            pos(pieza(esfera, rosa, chico, madera)). \c
            neg(pieza(esfera, _, chico, madera)). \c
            ejemplo(pieza(esfera, rojo, chico, madera)). \c
            X. \c
            pieza(esfera, rojo, chico, madera).", EV, Salida),
    inicial(EV0),
    aggregate_all(count, sub_string(Salida, _, _, _, "mal formado"), N).

% Un error de sintaxis tampoco interrumpe el lazo.
test(sintaxis, [true(EV =@= ev([pieza(esfera, rojo, chico, madera)],
                               [pieza(_, _, _, _)]))]) :-
    sesion("pos(pieza(esfera rojo)). \c
            pos(pieza(esfera, rojo, chico, madera)).", EV, Salida),
    sub_string(Salida, 0, _, _, "error de sintaxis").

% con_entrada/2 restituye la entrada aunque la meta falle.
test(restituye, [true(E1 == E0)]) :-
    current_input(E0),
    \+ con_entrada("a.", fail),
    current_input(E1).

test(ejemplo_valido, [true(Vs == [true, false, false, false])]) :-
    maplist([T, V]>>( ejemplo_valido(T) -> V = true ; V = false ),
            [ neg(pieza(cubo, azul, grande, metal)),
              neg(pieza(cubo, azul, grande, _)),
              _,
              fin ],
            Vs).

:- end_tests(soluciones_interactivo).
