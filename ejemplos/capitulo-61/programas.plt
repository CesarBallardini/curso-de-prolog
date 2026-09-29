:- encoding(utf8).

:- begin_tests(programas).

test(familia, [true(N == 7)]) :-
    programa(familia, Clausulas),
    length(Clausulas, N).

% Un hecho se entrega con el cuerpo true.
test(hecho, [true(C == (padre(juan, ana) :- true))]) :-
    programa(familia, [C|_]).

test(clases, [true(Cs == [ verdad, conjuncion(a, b), corte,
                           predefinida(1 < 2), usuario(p(x))
                         ])]) :-
    maplist(clase, [true, (a, b), !, 1 < 2, p(x)], Cs).

test(variable, [error(instantiation_error)]) :-
    clase(_, _).

test(nativas, [true(Ds == [ antepasado(juan, ana), antepasado(juan, pedro),
                            antepasado(juan, luis), antepasado(juan, eva)
                          ])]) :-
    respuestas_nativas(familia, antepasado(juan, _), Ds).

% Con el corte, Prolog da una sola respuesta.
test(maximo, [true(Ms == [maximo(4, 3, 4)])]) :-
    respuestas_nativas(maximo, maximo(4, 3, _), Ms).

test(suma, [true(Ss == [suma_hasta(100, 5050)])]) :-
    respuestas_nativas(listas, suma_hasta(100, _), Ss).

test(ejecutar, [fail]) :-
    ejecutar(3 < 2).

:- end_tests(programas).
