:- encoding(utf8).

:- begin_tests(nim).

test(sacar, [true(Js == [sacar(1, 1)-[0, 2], sacar(2, 1)-[1, 1],
                         sacar(2, 2)-[1, 0]])]) :-
    findall(J-P, sacar([1, 2], J, P), Js).

test(sacar_demasiadas, [fail]) :-
    sacar([1, 2], sacar(1, 2), _).

test(sacar_de_vacia, [fail]) :-
    sacar([0, 2], sacar(1, _), _).

test(vacias) :-
    vacias([0, 0, 0]).

test(no_vacias, [fail]) :-
    vacias([0, 1]).

test(ganadora) :-
    ganadora([1, 3, 5]).

test(perdedora, [fail]) :-
    ganadora([1, 2, 3]).

test(sin_fichas, [fail]) :-
    ganadora([0, 0]).

%!  posicion(+Pilas:integer, +Maximo:integer, -Posicion:list) is nondet.
%
%   Posicion es una lista de Pilas pilas de 0 a Maximo fichas.
posicion(Pilas, Maximo, Posicion) :-
    length(Posicion, Pilas),
    maplist(hasta(Maximo), Posicion).

%!  hasta(+Maximo:integer, -P:integer) is nondet.
%
%   P es un entero de 0 a Maximo.
hasta(Maximo, P) :-
    between(0, Maximo, P).

% La búsqueda y la suma de Nim coinciden en todas las posiciones de tres
% pilas de hasta 4 fichas.
test(busqueda_igual_suma, [true(Distintas == [])]) :-
    findall(P, ( posicion(3, 4, P),
                 \+ ( ganadora(P) -> \+ segura(P) ; segura(P) ) ),
            Distintas).

test(tabulada_igual_suma, [true(Distintas == [])]) :-
    findall(P, ( ( posicion(3, 7, P) ; posicion(4, 5, P) ),
                 \+ ( ganadora_tabulada(P) -> \+ segura(P) ; segura(P) ) ),
            Distintas).

test(forma, [true(F == [1, 3, 3])]) :-
    forma([3, 0, 1, 3], F).

test(posiciones, [true(N == 137)]) :-
    abolish_all_tables,
    \+ ganadora_tabulada([1, 3, 5, 7]),
    posiciones(N).

test(jugada_ganadora, [true(J == sacar(3, 3))]) :-
    jugada_ganadora([1, 3, 5], J).

test(sin_jugada_ganadora, [fail]) :-
    jugada_ganadora([1, 2, 3], _).

test(una_ficha, [true(J == sacar(2, 1))]) :-
    una_ficha([0, 4, 2], J).

test(una_ficha_sin_fichas, [fail]) :-
    una_ficha([0, 0], _).

test(tabulada, [true(Js == [sacar(3, 3), sacar(1, 1)])]) :-
    maplist([P, J]>>tabulada(nim(P), pilas(P, uno), J),
            [[1, 3, 5], [1, 2, 3]], Js).

% La estrategia tabulada y la suma de Nim eligen jugadas ganadoras en las
% mismas posiciones, aunque no siempre la misma jugada.
test(tabulada_y_suma, [true(Distintas == [])]) :-
    findall(P, ( posicion(3, 6, P),
                 \+ ( jugada_ganadora(P, _) -> jugada_segura(P, _)
                     ; \+ jugada_segura(P, _) ) ),
            Distintas).

test(suma, [true(Ss == [0, 4, 0])]) :-
    maplist(suma_nim, [[1, 3, 5, 7], [2, 6], [9, 5, 12]], Ss).

test(segura) :-
    segura([1, 3, 5, 7]).

% Las 35 combinaciones seguras de tres pilas distintas, no vacías y
% menores que 16, que Bouton lista en la sección 4 de su artículo.
test(bouton, [true(N == 35)]) :-
    aggregate_all(count,
                  ( between(1, 15, A), between(A, 15, B), A < B,
                    between(B, 15, C), B < C,
                    segura([A, B, C]) ),
                  N).

test(jugada_segura, [all(J == [sacar(2, 4)])]) :-
    jugada_segura([2, 6], J).

% El ejemplo de Bouton: de 7, 5 y 12 se sacan 10 de la tercera pila.
test(jugada_bouton, [all(J == [sacar(3, 10)])]) :-
    jugada_segura([7, 5, 12], J).

test(desde_segura, [fail]) :-
    jugada_segura([1, 3, 5, 7], _).

% Los dos teoremas de Bouton: desde una posición segura, toda jugada deja
% una insegura; desde una insegura, hay una jugada que deja una segura.
test(teoremas, [true(Contraejemplos == [])]) :-
    findall(P, ( posicion(3, 7, P),
                 (   segura(P)
                 ->  sacar(P, _, P1), segura(P1)
                 ;   \+ ( jugada_segura(P, J), sacar(P, J, P1),
                          segura(P1) )
                 ) ),
            Contraejemplos).

test(elegir, [true(Js == [sacar(1, 1), sacar(3, 4), sacar(2, 1)])]) :-
    maplist(elegir, [[1, 3, 5, 7], [0, 0, 4], [0, 2, 2]], Js).

test(elegir_sin_fichas, [fail]) :-
    elegir([0, 0], _).

test(estrategia, [true(J == sacar(3, 3))]) :-
    nim:suma(nim([1, 3, 5]), pilas([1, 3, 5], uno), J).

test(alfabeta_gana, [true(J-V-N == sacar(3, 3)-100-6077)]) :-
    alfabeta(nim([1, 3, 5]), pilas([1, 3, 5], uno), 20, J, V, N).

test(alfabeta_pierde, [true(V == -100)]) :-
    alfabeta(nim([1, 2, 3]), pilas([1, 2, 3], uno), 20, _, V, _).

test(fin, [true(R == gana(uno))]) :-
    capitulo41:fin(nim(_), pilas([0, 0], dos), R).

test(pantalla, [true(Ls == ["Pila 1: 2 ||", "Pila 2: 0"])]) :-
    partida:pantalla(nim(_), pilas([2, 0], uno), Ls).

test(leer_jugada, [true(J == sacar(2, 3))]) :-
    partida:leer_jugada(nim(_), _, "2 3", J).

test(leer_mal, [fail]) :-
    partida:leer_jugada(nim(_), _, "dos", _).

:- end_tests(nim).
