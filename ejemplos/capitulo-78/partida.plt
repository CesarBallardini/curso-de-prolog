:- encoding(utf8).

:- use_module(nim).

:- begin_tests(partida).

test(primera_contra_suma,
     [true(Js-R == [sacar(1, 1), sacar(3, 1), sacar(2, 1), sacar(3, 1),
                    sacar(2, 1), sacar(3, 1)]-gana(dos))]) :-
    partida(nim([1, 2, 3]), primera, nim:suma, Js, R).

% Con las dos estrategias perfectas, gana el que empieza si y solo si la
% posición inicial no es segura.
test(suma_contra_suma, [true(Rs == [gana(uno), gana(dos)])]) :-
    findall(R, ( member(Ps, [[1, 3, 5], [1, 2, 3]]),
                 partida(nim(Ps), nim:suma, nim:suma, _, R) ),
            Rs).

test(profundidad_contra_suma, [true(R == gana(uno))]) :-
    partida(nim([2, 3, 4]), profundidad(20), nim:suma, _, R).

test(desde_posicion, [true(Js-R == [sacar(2, 1)]-gana(dos))]) :-
    partida(nim([1]), pilas([0, 1], dos), primera, primera, Js, R).

test(tiempo, [true(J == sacar(3, 3))]) :-
    tiempo(1, nim([1, 3, 5]), pilas([1, 3, 5], uno), J).

test(primera, [true(J == sacar(2, 1))]) :-
    primera(nim([0, 4]), pilas([0, 4], uno), J).

test(jugar, [true(S == "Pila 1: 1 |\nPila 2: 2 ||\nTu jugada: 2 5\n\c
Esa jugada no es válida.\nTu jugada: 2 1\nPila 1: 1 |\nPila 2: 1 |\n\c
La computadora juega sacar(1, 1).\nPila 1: 0\nPila 2: 1 |\n\c
Tu jugada: 2 1\nPila 1: 0\nPila 2: 0\nGanaste.\n")]) :-
    open_string("2 5\n2 1\n2 1\n", In),
    with_output_to(string(S), jugar(nim([1, 2]), persona, nim:tabulada, In)).

test(abandono, [true(S == "Pila 1: 3 |||\nTu jugada: \nPartida abandonada.\n")]) :-
    open_string("", In),
    with_output_to(string(S), jugar(nim([3]), persona, primera, In)).

:- end_tests(partida).
