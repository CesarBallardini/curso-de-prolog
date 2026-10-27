:- encoding(utf8).

:- begin_tests(vista).

test(red_resuelto, [true(Ls == ["       U U U", "       U U U",
                                "       U U U",
                                "L L L  F F F  R R R  B B B",
                                "L L L  F F F  R R R  B B B",
                                "L L L  F F F  R R R  B B B",
                                "       D D D", "       D D D",
                                "       D D D"])]) :-
    resuelto(C),
    red(C, Ls).

test(red_tras_u, [true(L == "F F F  R R R  B B B  L L L")]) :-
    resuelto(C),
    mover(u, C, C1),
    red(C1, Ls),
    nth1(4, Ls, L).

test(mostrar, [true(Salida == Esperada)]) :-
    resuelto(C),
    with_output_to(string(Salida), mostrar(C)),
    red(C, Ls),
    caja("", Ls, Caja),
    atomic_list_concat(Caja, '\n', A),
    atom_concat(A, '\n', A1),
    atom_string(A1, Esperada).

test(leer, [true(Ms == [f, f, -u, r])]) :-
    leer_notacion("F2 U' R", Ms).

test(leer_blancos, [true(Ms == [r, -u])]) :-
    leer_notacion("  R   U'  ", Ms).

test(leer_mal, [fail]) :-
    leer_notacion("R X", _).

test(escribir, [true(T == "R2 U' F")]) :-
    escribir_notacion([r, r, -u, f], T).

test(ida_y_vuelta, [true(T == "R U R' U' F2")]) :-
    leer_notacion("R U R' U' F2", Ms),
    escribir_notacion(Ms, T).

test(mezcla_reproducible, [true(Ms == [f, l, b, f, -u, -d])]) :-
    mezcla(7, 6, Ms).

test(mezcla_sin_caras_repetidas, [nondet]) :-
    mezcla(3, 40, Ms),
    length(Ms, 40),
    forall(nextto(A, B, Ms),
           ( cara_de(A, CA), cara_de(B, CB), CA \== CB )).

test(mostrar_giros, [true(S == E)]) :-
    with_output_to(string(S), mostrar_giros("R")),
    resuelto(C),
    mover(r, C, C1),
    with_output_to(string(E), mostrar(C1)).

:- end_tests(vista).
