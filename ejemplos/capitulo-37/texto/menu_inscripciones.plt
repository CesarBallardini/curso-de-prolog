:- encoding(utf8).

:- begin_tests(menu_inscripciones).

%!  con_teclas(+Teclas:string, +Menu0, -Menu, -Salida:string) is det.
%
%   Recorre Menu0 con las teclas escritas en Teclas; Salida es lo que
%   bucle_menu/3 escribió.
con_teclas(Teclas, Menu0, Menu, Salida) :-
    setup_call_cleanup(
        open_string(Teclas, In),
        with_output_to(string(Salida),
                       bucle_menu(get_code(In), Menu0, Menu)),
        close(In)).

test(materias, true(L == ["┌─ Materias ────────────────┐",
                          "│   am1 analisis_1        5 │",
                          "│   alg algebra           4 │",
                          "│ > log logica            4 │",
                          "│   am2 analisis_2        2 │",
                          "│   pp  paradigmas        2 │",
                          "│   ssl sintaxis          0 │",
                          "│   bd  bases_de_datos    0 │",
                          "└───────────────────────────┘",
                          "Flechas: elegir  Enter: inscriptos  q: salir"])) :-
    pantalla_menu(menu(3, materias), L).

test(inscriptos, true(L == ["┌─ Inscriptos en logica ┐",
                            "│ 101 ana       nota 10 │",
                            "│ 102 bruno     nota 6  │",
                            "│ 104 diego     nota 9  │",
                            "│ 106 facundo   nota 3  │",
                            "│                       │",
                            "│ Promedio: 7.00        │",
                            "└───────────────────────┘",
                            "Enter o q: volver"])) :-
    pantalla_menu(menu(3, inscriptos), L).

test(sin_inscriptos, true(L == ["┌─ Inscriptos en bases_de_datos ┐",
                                "│ Sin inscriptos                │",
                                "│                               │",
                                "│ Promedio: sin notas           │",
                                "└───────────────────────────────┘",
                                "Enter o q: volver"])) :-
    pantalla_menu(menu(7, inscriptos), L).

test(bordes, true(M == [menu(1, materias), menu(7, materias)])) :-
    foldl(paso_menu, [arriba, arriba], menu(2, materias), M1),
    length(Abajos, 10),
    maplist(=(abajo), Abajos),
    foldl(paso_menu, Abajos, menu(2, materias), M2),
    M = [M1, M2].

test(ir_y_volver, true(M == [menu(2, inscriptos), menu(2, materias)])) :-
    paso_menu(enter, menu(2, materias), M1),
    paso_menu(letra(q), M1, M2),
    M = [M1, M2].

% Abajo, Enter, q para volver y q para salir: la última pantalla dibujada
% es la lista, con la segunda materia elegida.
test(recorrido, true(M == menu(2, salir))) :-
    con_teclas("\e[B\rqq", menu(1, materias), M, Salida),
    atomic_list_concat(Pantallas, '\e[2J', Salida),
    last(Pantallas, Ultima),
    once(sub_atom(Ultima, _, _, _, '> alg')).

test(fin_de_la_entrada, true(M == menu(1, salir))) :-
    con_teclas("", menu(1, materias), M, _).

% En los inscriptos, Enter también vuelve, y las flechas no cambian nada.
test(inscriptos_teclas,
     true(M == [menu(3, materias), menu(3, inscriptos)])) :-
    paso_menu(enter, menu(3, inscriptos), M1),
    paso_menu(abajo, menu(3, inscriptos), M2),
    M = [M1, M2].

:- end_tests(menu_inscripciones).
