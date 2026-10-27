:- encoding(utf8).

:- use_module(krk).

:- begin_tests(consejos).

% posicion(Nombre, P): las posiciones de las pruebas.
posicion(borde, pos(blancas, 1-3, 1-4, 2-1)).
posicion(centro, pos(blancas, 5-5, 1-1, 4-7)).

test(operadores, [true(T == luego(y(=(profundidad, 0), legal),
                                  y(=(profundidad, 2), jaque_con_torre)))]) :-
    T = (profundidad = 0 y legal luego profundidad = 2 y jaque_con_torre).

test(cumple_y) :-
    posicion(borde, P),
    cumple(krk, rey_negro_en_borde y reyes_cerca, P, P).

test(cumple_o) :-
    posicion(borde, P),
    cumple(krk, torre_divide o reyes_cerca, P, P).

test(cumple_no) :-
    posicion(borde, P),
    cumple(krk, no torre_divide, P, P).

test(no_cumple, [fail]) :-
    posicion(borde, P),
    cumple(krk, reyes_cerca y no rey_negro_en_borde, P, P).

% Una meta que la tabla no conoce no se cumple.
test(meta_desconocida, [fail]) :-
    posicion(borde, P),
    cumple(krk, desconocida, P, P).

test(profundidad, [fail]) :-
    posicion(borde, P),
    jugada_con(krk, profundidad = 1 y legal, P, 0, _, _).

% luego da primero las jugadas de la torre y después las del rey.
test(luego, [true(Tipos == [torre, rey])]) :-
    posicion(borde, P),
    findall(F,
            ( jugada_con(krk,
                         torre luego rey_diagonal_primero, P, 0, J, _),
              functor(J, F, _) ),
            Fs),
    list_to_set(Fs, Tipos).

% El único jaque de la torre: b4. a1 también daría jaque, pero el rey blanco
% tapa el camino.
test(jugada_con_y, [true(Js == [torre(1-4, 2-4)])]) :-
    posicion(borde, P),
    findall(J, jugada_con(krk, legal y jaque_con_torre, P, 0, J, _), Js0),
    msort(Js0, Js).

test(mate_en_2, [true(A == juega(torre(1-4, 3-4),
                                 responde([rey(2-1, 1-1)-
                                           juega(torre(3-4, 3-1), hoja)])))]) :-
    posicion(borde, P),
    satisfacible(krk, mate_en_2, P, A).

test(encierro_no_satisfacible, [fail]) :-
    posicion(borde, P),
    satisfacible(krk, encierro, P, _).

test(estrategia_borde, [true(C == mate_en_2)]) :-
    posicion(borde, P),
    estrategia(krk, P, C, _).

test(estrategia_centro, [true(C-J == dividir_en_2-torre(1-1, 3-1))]) :-
    posicion(centro, P),
    estrategia(krk, P, C, juega(J, _)).

% Las hojas del árbol de dividir_en_2 cumplen su meta mejor.
test(hojas_cumplen, [nondet]) :-
    posicion(centro, P),
    estrategia(krk, P, _, juega(J, responde(Ramas))),
    reglas:jugada(P, J, P1),
    forall(member(R-juega(J2, hoja), Ramas),
           ( reglas:jugada(P1, R, P2),
             reglas:jugada(P2, J2, P3),
             cumple(krk, mueven_negras y torre_divide y no torre_expuesta,
                    P3, P) )).

:- end_tests(consejos).
