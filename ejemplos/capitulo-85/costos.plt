:- encoding(utf8).

% Las cifras medidas que el capítulo imprime. Los pasos, las derivaciones,
% las tablas, los hechos mágicos y los arcos no dependen de la máquina, y
% se comparan con su valor exacto. Las inferencias cambian de una versión
% de SWI-Prolog a otra: se comparan, a propósito, con una banda del 10 %
% alrededor de la cifra impresa (en_banda/2).

:- begin_tests(costos).

% Sección 85.2: el programa de Nilsson y Małuszyński.
test(nilsson, [true(C == costo(3, 6))]) :-
    modelo(nilsson, _, C).

% Sección 85.4: la fila de 40 arcos, con el motor y con el capítulo 38.
test(cadena_40, [true(C-C38 == costo(41, 820)-costo(42, 860))]) :-
    clausulas(cadena(40), Cs),
    semi_ingenua(Cs, M, C),
    semi_ingenua_de(Cs, [], M, C38).

test(cadena_40_inferencias) :-
    clausulas(cadena(40), Cs),
    inferencias(semi_ingenua(Cs, _, _), N),
    inferencias(semi_ingenua_de(Cs, [], _, _), N38),
    en_banda(N, 154818),
    en_banda(N38, 483968).

% Sección 85.5: las componentes y los estratos del sistema experto.
test(experto, [true(N-N0 == 10-21)]) :-
    clausulas(base(original), Cs),
    componentes(Cs, Ks),
    length(Ks, N),
    estratos_de(Cs, [_-E0|_]),
    length(E0, N0).

% Sección 85.6 y la tabla de la página de la transformación mágica.
test(tabla_magia, [true(Ds == [820-41, 820-862, 820-860, 820-158])]) :-
    findall(D-D1,
            ( member(P-Meta, [ cadena(40)-camino(0, _),
                               cadena(40)-camino(_, 40),
                               fila(40)-camino(0, _),
                               fila(40)-camino(_, 40) ]),
              consulta(P, Meta, Rs, costo(_, D)),
              consulta_magica(P, Meta, Rs, costo(_, D1)) ),
            Ds).

test(tablas_y_magia, [true(L == [izq-1-100-1-100, der-100-10000-100-10000])]) :-
    findall(R-T-A-M-B,
            ( member(R-Meta, [ izq-(tablas:evita_izq(1, _)),
                              der-(tablas:evita_der(1, _)) ]),
              tablas(Meta, T, A),
              programa(R, 100, Cs),
              magia(Cs, evita(1, _), M, B) ),
            L).

% Sección 85.7: agregar un arco cuesta 41 derivaciones; recalcular, 861.
test(agregar, [true(C-N-D == costo(2, 41)-902-861)]) :-
    agregar_a(cadena(40), [arco(40, 41)], C, M),
    length(M, N),
    modelo(cadena(41), _, costo(_, D)).

% Página de aplicaciones: el Wumpus.
test(wumpus, [true(S-Dif == 188-0)]) :-
    numlist(1, 20, Ss),
    comparar(Ss, r(S, Dif, I38, IMotor)),
    en_banda(I38, 3070780),
    en_banda(IMotor, 1977966).

test(wumpus_instantanea, [true(C-N == costo(6, 104)-137)]) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K),
    programa_wumpus(K, Cs),
    evaluar(Cs, M, C),
    length(M, N).

% Página de aplicaciones: los marcos y los registros.
test(marcos, [true(C == costo(11, 147))]) :-
    consulta_marcos(tiene_parte(auto, _), _, C).

test(registros, [true(C == costo(6, 25))]) :-
    consulta_metricas(registros('2026-10-01.log'), racha(_, _), _, C).

% Página de la tabla de un juego.
test(juegos, [true(L == [4-3, 2])]) :-
    rondas([a-b, b-a, b-c], _, N1),
    retrogrado([a-b, b-a, b-c], _, N2),
    retrogrado([a-b, b-a, b-c, c-d], _, N3),
    L = [N1-N2, N3].

test(restar_12, [true(N == 33)]) :-
    restar(12, Js),
    retrogrado(Js, _, N).

test(restar_1000, [true(N1-N2-J == 750747-2997-2997)]) :-
    restar(1000, Js),
    length(Js, J),
    rondas(Js, T, N1),
    retrogrado(Js, T, N2).

test(en_banda, [fail]) :-
    en_banda(111, 100).

:- end_tests(costos).
