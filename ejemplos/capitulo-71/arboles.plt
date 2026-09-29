:- encoding(utf8).

:- begin_tests(arboles).

arbol(y(a, [meta(b)-1, o(c, meta(d)-3)-2])).

test(costo, [true(C == 6)]) :-
    arbol(A),
    costo(A, C).

test(costo_primitivo, [true(C == 0)]) :-
    costo(meta(a), C).

test(raiz, [true(N == a)]) :-
    arbol(A),
    raiz(A, N).

test(hojas, [true(H == [b, d])]) :-
    arbol(A),
    hojas(A, H).

test(mostrar, [true(S == "a  y\n  +1 b\n  +2 c  o\n    +3 d\n")]) :-
    arbol(A),
    with_output_to(string(S), mostrar(A)).

:- end_tests(arboles).
