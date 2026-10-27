:- encoding(utf8).

:- begin_tests(soluciones_v7).

test(disyunciones, [true(Ds =@= [[pieza(esfera, _, _, _),
                                   pieza(cubo, verde, grande, metal)],
                                  [pieza(_, _, grande, metal),
                                   pieza(esfera, rojo, chico, madera)]])]) :-
    disyunciones(esferas_y_cubos_verdes, Ds).

% Con dos positivos que no se pueden generalizar juntos, el orden solo
% cambia el orden de los disyuntos.
test(disyunciones_dos, [true(N == 2)]) :-
    disyunciones(rojo_o_esfera, Ds),
    length(Ds, N).

test(sin_variantes, [true(Us =@= [f(_), g(a)])]) :-
    sin_variantes([f(_), g(a), f(_), g(a)], Us).

test(costos_incorporar, [true]) :-
    costos_incorporar(Recorrer, Teoria, Segunda),
    Teoria < Segunda,
    Segunda < Recorrer.

:- end_tests(soluciones_v7).
