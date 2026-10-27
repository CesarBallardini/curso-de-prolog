:- encoding(utf8).

% La cifra de las reglas compiladas al cargar que el Patrón 61 imprime.
% Las inferencias cambian de una versión de SWI-Prolog a otra: se
% comparan, a propósito, con una banda del 10 % alrededor de la cifra
% impresa (en_banda/2).

:- begin_tests(kimmo_al_cargar).

% en_banda(Medido, Impreso): Medido difiere de Impreso en menos del 10 %.
en_banda(Medido, Impreso) :-
    abs(Medido - Impreso) =< 0.1 * Impreso.

% Cada regla aparece una sola vez: la cláusula de kimmo.pl que compila en
% cada llamada no se cargó.
test(reglas, [true(Rs == [limite, k, u, g, z, jota, epentesis,
                          quitar_tilde, poner_tilde, nasal, nasal_n])]) :-
    reglas(Rs).

% Las reglas compiladas al cargar dan los patrones que da compilar/5.
test(mismos_patrones, [true(Ps == Qs)]) :-
    findall(R-P, ( member(R, [nasal, nasal_n]),
                   dos_niveles:regla(R, P) ), Ps),
    findall(R-P, ( member(R, [nasal, nasal_n]),
                   regla_dos_niveles(R, Par, Op, Izquierda, Derechas),
                   compilar(Par, Op, Izquierda, Derechas, P) ), Qs).

test(imposible, [true(Es == [[i, m, p, o, s, i, b, l, e]])]) :-
    generar_imposible(Es).

% El Patrón 61: 1 006 077 inferencias con las reglas compiladas al
% cargar.
test(costo) :-
    costo(N),
    en_banda(N, 1006077).

test(en_banda, [fail]) :-
    en_banda(111, 100).

:- end_tests(kimmo_al_cargar).
