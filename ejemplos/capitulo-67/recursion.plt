:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(recursion).

test(antepasado, [true(H =@= [(antepasado(A, B) :- [progenitor(A, B)]),
                              (antepasado(C, D) :- [progenitor(C, E),
                                                    antepasado(E, D)])])]) :-
    aprender_rec(antepasado, H, _).

% El modelo mínimo (capítulo 38) y el intérprete con límite coinciden.
test(antepasado_exacto, [true(R == 14-0-0)]) :-
    aprender_rec(antepasado, H, _),
    evaluar(antepasado, H, A, FP, FN),
    R = A-FP-FN.

test(antepasado_intensional, [true(As == Esperados)]) :-
    aprender_rec(antepasado, H, _),
    extension_intensional(antepasado, H, 5, As),
    ejemplos(antepasado, Esperados, _).

test(abuelo_mejor, [true(H =@= [(abuelo(A, B) :- [padre(A, C),
                                                  progenitor(C, B)])])]) :-
    aprender_rec(abuelo, H, _).

% La cobertura extensional acepta una cláusula circular.
test(hermano_circular, [true(H =@= [(hermano(A, B) :- [hermano(A, C),
                                                       hermano(D, B),
                                                       hermano(D, C)])])]) :-
    aprender_rec(hermano, H, _).

test(hermano_intensional, [true(As == [])]) :-
    aprender_rec(hermano, H, _),
    extension_intensional(hermano, H, 5, As).

% Pocos negativos: la hipótesis generaliza de más.
test(pocos_negativos, [true(R =@= [(abuelo(A, _) :- [varon(A)])]-3-18)]) :-
    ejemplos(abuelo, Pos, Negs),
    length(Ns, 14),
    append(Ns, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, Ns, M, L, 3, H, _),
    evaluar_en(abuelo, H, M, Ac, FP, _),
    R = H-Ac-FP.

test(probar_limite, [fail]) :-
    probar(0, [(p(X) :- [q(X)])], [q(a)], p(a)).

test(probar, [nondet]) :-
    probar(1, [(p(X) :- [q(X)])], [q(a)], p(a)).

test(con_negativos, [true(R == [46, 18, 18, 0, 0])]) :-
    findall(FP, ( member(K, [0, 1, 14, 15, 46]),
                  con_negativos(abuelo, K, _, FP) ),
            R).

% Un solo negativo bien elegido alcanza.
test(un_negativo, [true(FP == 0)]) :-
    ejemplos(abuelo, Pos, _),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, [abuelo(pedro, eva)], M, L, 3, H, _),
    evaluar_en(abuelo, H, M, _, FP, _).

:- end_tests(recursion).
