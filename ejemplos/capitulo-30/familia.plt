:- encoding(utf8).

:- begin_tests(familia).

test(abuelo, all(N == [luis, eva])) :-
    abuelo(juan, N).

test(edad_de, true(E == 41)) :-
    edad_de(ana, E).

test(edad_desconocida, fail) :-
    edad_de(zoe, _).

test(edad_de_un_numero, error(type_error(atom, 3))) :-
    edad_de(3, _).

% La etiqueta del dict es una variable nueva: se compara con =@=.
test(ficha, true(F =@= _{nombre: ana, edad: 41, hijos: [luis, eva]})) :-
    ficha(ana, F).

:- end_tests(familia).
