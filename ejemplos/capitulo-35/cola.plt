:- encoding(utf8).

:- begin_tests(cola).

test(encolar_lista, true(C == [a, b, c])) :-
    encolar_lista(c, [a, b], C).

test(dif, true(X-R == a-[b])) :-
    encolar_dif(a, F-F, C1),
    encolar_dif(b, C1, C2),
    desencolar_dif(X, C2, R-[]).

% desencolar_dif/3 también se cumple con una cola vacía: el elemento
% «quitado» es el que se encola después.
test(dif_vacia, true(X == a)) :-
    desencolar_dif(X, F-F, C1),
    encolar_dif(a, C1, _).

test(orden, true([X, Y] == [a, b])) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    encolar(b, C1, C2),
    desencolar(X, C2, C3),
    desencolar(Y, C3, _).

test(vacia_no_desencola, [fail]) :-
    cola_vacia(C0),
    desencolar(_, C0, _).

test(vaciada_no_desencola, [fail]) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    desencolar(_, C1, C2),
    desencolar(_, C2, _).

test(contador, true(N == 2)) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    encolar(b, C1, cola(N, _, _)).

test(por_niveles, true(L == [1, 2, 3, 4])) :-
    por_niveles(n(n(vacio, 2, vacio), 1, n(vacio, 3, n(vacio, 4, vacio))), L).

test(por_niveles_vacio, true(L == [])) :-
    por_niveles(vacio, L).

test(por_niveles_lista, true(L == [1, 2, 3, 4])) :-
    por_niveles_lista(n(n(vacio, 2, vacio), 1,
                        n(vacio, 3, n(vacio, 4, vacio))), L).

test(completo, true(L == [3, 2, 2, 1, 1, 1, 1])) :-
    completo(3, A),
    por_niveles(A, L).

test(iguales, true(L1 == L2)) :-
    completo(6, A),
    por_niveles(A, L1),
    por_niveles_lista(A, L2).

test(encolar_dif, true(C = [a|G]-G)) :-
    encolar_dif(a, F-F, C).

test(desencolar_contador, true(X-N == a-1)) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    encolar(b, C1, C2),
    desencolar(X, C2, cola(N, _, _)).

test(completo_cero, true(A == vacio)) :-
    completo(0, A).

test(por_niveles_lista_vacio, true(L == [])) :-
    por_niveles_lista(vacio, L).

:- end_tests(cola).
