:- encoding(utf8).

:- begin_tests(desconexion).

% Al cargar el configurador, casi todas las activaciones por la derecha
% son nulas, y crecen con el catálogo; las de la izquierda, no.
test(configurador, [true(L == [0-a(189, 187, 2, 0), 50-a(789, 787, 2, 0)])]) :-
    findall(K-A, ( member(K, [0, 50]),
                   activaciones(configurador, pedido(K), A) ),
            L).

% En familia ocurre lo contrario: los tokens llegan a nodos cuya memoria
% alfa todavía está vacía.
test(familia, [true(A == a(7, 0, 4, 4))]) :-
    activaciones(familia, familia, A).

test(nodos_vacios, [true(N == n(35, 24, 12, 5))]) :-
    nodos_vacios(configurador, pedido(0), N).

test(nodos_vacios_familia, [true(N == n(6, 2, 4, 2))]) :-
    nodos_vacios(familia, familia, N).

% Un hecho repetido no entra en la red ni suma activaciones: la cuenta es
% la del primero.
test(repetido, [true(A == a(1, 0, 1, 1))]) :-
    activaciones(familia, lista([padre(juan, ana), padre(juan, ana)]), A).

test(entrar_contando, [true(C == a(1, 0, 1, 1))]) :-
    red_de(familia, Red),
    memoria_vacia(M),
    rete_vacio(Red, R),
    entrar_contando(Red, padre(juan, ana), M-R-a(0, 0, 0, 0), _-_-C).

test(derecha_contando, [true(C == a(1, 1, 0, 0))]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    rete_vacio(Red, R0),
    derecha_contando(1, Red, 2-alfa(q(a), []), R0-a(0, 0, 0, 0), _-C).

test(contar_izquierda, [true(C == a(0, 0, 1, 1))]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    rete_vacio(Red, R0),
    propagar(mas, 1, p(a), Red, R0, R),
    Red = red(_, _, Nodos, _),
    contar_izquierda(Nodos, R0, R, a(0, 0, 0, 0), C).

test(cambios_de, [true(N == 1)]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], Red),
    rete_vacio(Red, R0),
    propagar(mas, 1, p(a), Red, R0, R),
    cambios_de(1, R0, R, N).

test(sumar_hijos, [true(C == 3-3)]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    rete_vacio(Red, rete(Alfas, _, _)),
    Red = red(_, _, Nodos, _),
    sumar_hijos(Nodos, Alfas, 3-[2], 0-0, C).

test(sumar_hijo_prueba, [true(C == 0-0)]) :-
    compilar_red(pasos, [r :: [p(_), {true}] ---> []], Red),
    rete_vacio(Red, rete(Alfas, _, _)),
    Red = red(_, _, Nodos, _),
    sumar_hijo(Nodos, Alfas, 3, 2, 0-0, C).

test(vacio, [true(V-W == si-no)]) :-
    empty_assoc(E),
    vacio(E, V),
    put_assoc(a, E, 1, T),
    vacio(T, W).

test(vacio_padre, [true(V == si)]) :-
    empty_assoc(B),
    vacio_padre(3, B, V).

test(hechos_de, [true(N-L == 7-[a])]) :-
    hechos_de(familia, H),
    length(H, N),
    hechos_de(lista([a]), L).

:- end_tests(desconexion).
