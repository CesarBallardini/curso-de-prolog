:- encoding(utf8).

:- begin_tests(proyecto).

test(espacio, [true(C =@= pieza(esfera, rojo, _, _))]) :-
    secuencia(esfera_roja, Ejs),
    eliminar(Ejs, EV),
    estado(EV, convergio(C)).

test(ebg, [true(C == material(A, carton))]) :-
    aprender(taza, taza2, taza(taza2), (taza(A) :- [C|_])).

:- end_tests(proyecto).
