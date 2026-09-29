:- encoding(utf8).

:- begin_tests(capitulo40).

test(anchura, [true(P-K == [-u, -r]-25)]) :-
    resuelto(C),
    aplicar([r, u], C, C1),
    en_anchura(C1, P, K).

test(profundizando, [true(P == [-u, -r])]) :-
    resuelto(C),
    aplicar([r, u], C, C1),
    profundizando(C1, P).

test(ya_resuelto, [true(P == [])]) :-
    resuelto(C),
    profundizando(C, P).

test(colocar_pieza, [true(P == [[-u]])]) :-
    resuelto(C),
    mover(u, C, C1),
    functor(Criterio, c, 54),
    arg(20, Criterio, f),
    colocar_pieza(prueba, C1, [Criterio], P).

user:candidato(prueba, [M], C0, C) :-
    member(M, [u, -u]),
    mover(M, C0, C).

:- end_tests(capitulo40).
