:- encoding(utf8).

:- use_module(tablero).

:- begin_tests(descubrir).

% Un 3 x 3 con una mina en una esquina: la esquina opuesta descubre las ocho
% celdas libres.
test(region, true(N == 8)) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 3-3, [], D),
    length(D, N).

test(numero, true(D == [1-2])) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 1-2, [], D).

test(ya_descubierta, true(D == [1-2])) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 1-2, [1-2], D).

:- end_tests(descubrir).
