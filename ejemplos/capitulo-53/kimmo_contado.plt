:- encoding(utf8).

% Las cifras de kimmo.pl que el Patrón 61 imprime. Las compilaciones no
% dependen de la máquina, y se comparan con su valor exacto. Las
% inferencias cambian de una versión de SWI-Prolog a otra: se comparan,
% a propósito, con una banda del 10 % alrededor de la cifra impresa
% (en_banda/2).

:- begin_tests(kimmo_contado).

% en_banda(Medido, Impreso): Medido difiere de Impreso en menos del 10 %.
en_banda(Medido, Impreso) :-
    abs(Medido - Impreso) =< 0.1 * Impreso.

test(reglas_de, [true(Rs == [limite, k, u, g, z, jota, epentesis,
                             quitar_tilde, poner_tilde, nasal_contada,
                             nasal_n_contada])]) :-
    reglas_de(contando, Rs).

% Contar las compilaciones no cambia la forma generada.
test(misma_forma, [true(Es-Fs == [[i, m, p, o, s, i, b, l, e]]-Es)]) :-
    reglas_de(kimmo, Rs),
    generar_imposible(Rs, Es),
    reglas_de(contando, Ts),
    generar_imposible(Ts, Fs).

% El Patrón 61: kimmo.pl compila 4 263 veces al generar «imposible».
test(compilaciones, [true(N == 4263)]) :-
    compilaciones(N).

% El Patrón 61: 2 535 280 inferencias con kimmo.pl.
test(costo) :-
    costo(N),
    en_banda(N, 2535280).

test(en_banda, [fail]) :-
    en_banda(111, 100).

:- end_tests(kimmo_contado).
