:- encoding(utf8).

:- begin_tests(maquinas).

test(parentesis, [nondet]) :-
    acepta_pila(parentesis, ['(', '(', ')', ')', '(', ')']).

test(parentesis_mal, [fail]) :-
    acepta_pila(parentesis, ['(', ')', ')']).

test(parentesis_4, [true(Ws == [['(', '(', ')', ')'], ['(', ')', '(', ')']])]) :-
    findall(W, ( length(W, 4), acepta_pila(parentesis, W) ), Ws).

test(palindromo, [nondet]) :-
    acepta_pila(palindromo, [a, b, b, a]).

test(no_palindromo, [fail]) :-
    acepta_pila(palindromo, [a, b, a, b]).

test(palindromos_4, [true(Ws == [[a, a, a, a], [a, b, b, a], [b, a, a, b],
                                 [b, b, b, b]])]) :-
    findall(W, ( length(W, 4), acepta_pila(palindromo, W) ), Ws).

test(abc, [true(R == acepta([x, x, y, y, z, z]))]) :-
    turing(abc, [a, a, b, b, c, c], 1000, R).

test(abc_rechaza, [true(R == rechaza([x, x, y, z, c]))]) :-
    turing(abc, [a, a, b, c, c], 1000, R).

test(abc_vacia, [true(R == acepta([]))]) :-
    turing(abc, [], 10, R).

test(limite, [true(R = limite(_, _))]) :-
    turing(abc, [a, a, a, b, b, b, c, c, c], 5, R).

% Acepta exactamente las palabras a^n b^n c^n de longitud hasta 6.
test(abc_todas) :-
    forall(( between(0, 6, L),
             length(W, L),
             maplist([S]>>member(S, [a, b, c]), W) ),
           (   turing(abc, W, 1000, acepta(_))
           ->  abc(W)
           ;   \+ abc(W)
           )).

% abc(W): W es a^n b^n c^n.
abc(W) :-
    length(W, L),
    N is L // 3,
    L =:= 3 * N,
    length(As, N), maplist(=(a), As),
    length(Bs, N), maplist(=(b), Bs),
    length(Cs, N), maplist(=(c), Cs),
    append([As, Bs, Cs], W).

test(configuracion, [nondet]) :-
    configuracion(parentesis, p, ['(', ')'], [z]).

test(configuracion_mal, [fail]) :-
    configuracion(parentesis, p, [')'], [z]).

test(configuracion_palindromo, all(W == [[a, a], [b, b]])) :-
    length(W, 2),
    configuracion(palindromo, q0, W, [z]).

test(turing_vacia, [true(R == acepta([]))]) :-
    turing(abc, [], 100, R).

test(turing_rechaza, [true(R == rechaza([x, y]))]) :-
    turing(abc, [a, b], 100, R).

test(turing_limite, [true(R == limite(q3, [x, y, z]))]) :-
    turing(abc, [a, b, c], 3, R).

test(ejecutar_final, [true(R == acepta([]))]) :-
    ejecutar(abc, acepta, c([], blanco, []), 5, R).

test(ejecutar_sin_pasos, [true(R == limite(q0, [a, b, c]))]) :-
    ejecutar(abc, q0, c([], a, [b, c]), 0, R).

test(mover_izq_borde, [true(C == c([], blanco, [x, b]))]) :-
    mover_cabezal(izq, x, c([], a, [b]), C).

test(mover_der_borde, [true(C == c([x], blanco, []))]) :-
    mover_cabezal(der, x, c([], a, []), C).

test(mover_der, [true(C == c([x, y], b, []))]) :-
    mover_cabezal(der, x, c([y], a, [b]), C).

test(izquierda, [true(C == c([z], y, [b]))]) :-
    izquierda([y, z], [b], C).

test(derecha, [true(C == c([y], b, [c]))]) :-
    derecha([b, c], [y], C).

% Los blancos interiores quedan; los de los extremos, no.
test(contenido, [true(Ss == [a, blanco, blanco, b])]) :-
    contenido(c([blanco, a], blanco, [b, blanco]), Ss).

test(contenido_vacio, [true(Ss == [])]) :-
    contenido(c([], blanco, []), Ss).

test(sin_blancos, [true(R == [a, blanco])]) :-
    sin_blancos([blanco, blanco, a, blanco], R).

:- end_tests(maquinas).
