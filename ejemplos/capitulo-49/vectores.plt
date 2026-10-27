:- encoding(utf8).

:- begin_tests(vectores).

test(vector, [true(V == [+, -, +])]) :-
    vector([a, b, ci], [a, ci, ~b], V).

test(vector_vacio, [true(V == [0, 0])]) :-
    vector([a, b], [], V).

test(producto_de_vector, [true(P == [~a, ci])]) :-
    producto_de_vector([a, b, ci], [-, 0, +], P).

test(ida_y_vuelta, [true(P == [a, ~b, ci])]) :-
    vector([a, b, ci], [ci, a, ~b], V),
    producto_de_vector([a, b, ci], V, P).

test(signo, [true(Ss == [+, -, 0])]) :-
    maplist(vectores:signo([a, ~b]), [a, b, c], Ss).

test(literal_de, [true(P == [~a|R])]) :-
    vectores:literal_de(-, a, P, R).

% [a] absorbe a [a, ~b, ci], y [a, ~b] no absorbe a [a, ci].
test(cubre) :-
    cubre([+, 0, 0], [+, -, +]).

test(no_cubre, [fail]) :-
    cubre([+, -, 0], [+, 0, +]).

test(cubre_signo, all(T == [+])) :-
    vectores:cubre_signo(+, T).

% a·b·¬c + a·¬b·¬c = a·¬c.
test(combinar, [true(C == [+, 0, -])]) :-
    combinar([+, +, -], [+, -, -], C).

test(combinar_dos_diferencias, [fail]) :-
    combinar([+, +, -], [-, -, -], _).

test(combinar_iguales, [fail]) :-
    combinar([+, 0], [+, 0], _).

test(combinar_con_cero, [fail]) :-
    combinar([+, 0], [+, -], _).

test(opuestos, all(S-T == [(+)-(-), (-)-(+)])) :-
    vectores:opuestos(S, T).

test(signo_de_bit, all(B-S == [1-(+), 0-(-)])) :-
    vectores:signo_de_bit(B, S).

test(unos, [true(Vs == [[-, +, +], [+, -, +], [+, +, -], [+, +, +]])]) :-
    unos(sumador, co, Vs).

test(unos_otra_salida, [fail]) :-
    unos(sumador, z, _).

% El acarreo del sumador es la mayoría de sus tres entradas.
test(acarreo, [true(Ps == [[b, ci], [a, ci], [a, b]])]) :-
    unos(sumador, co, Vs),
    implicantes_primos(Vs, Vs1),
    maplist(producto_de_vector([a, b, ci]), Vs1, Ps).

% La suma no se simplifica: ningún par de filas en 1 es adyacente.
test(suma, [true(Ps == Vs1)]) :-
    unos(sumador, s, Vs),
    msort(Vs, Vs1),
    implicantes_primos(Vs, Ps).

% Una función siempre verdadera se reduce al vector sin literales.
test(siempre, [true(Ps == [[0, 0]])]) :-
    implicantes_primos([[+, +], [+, -], [-, +], [-, -]], Ps).

test(primos_vacio, [true(Ps == [])]) :-
    implicantes_primos([], Ps).

% a·¬b·¬c, a·¬b·c, a·b·c y ¬a·b·c: los implicantes primos son b·c, a·c
% y a·¬b; a·¬b·c se combina con dos vectores y no queda.
test(primos_mezcla, [true(Ps == [[0, +, +], [+, 0, +], [+, -, 0]])]) :-
    implicantes_primos([[+, -, -], [+, -, +], [+, +, +], [-, +, +]], Ps).

:- end_tests(vectores).
