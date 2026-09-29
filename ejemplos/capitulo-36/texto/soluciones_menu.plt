:- encoding(utf8).

:- use_module('../../capitulo-31/inscripciones/datos').

:- begin_tests(soluciones_menu).

%!  sin_cambios(:Objetivo) is semidet.
%
%   Ejecuta Objetivo y restaura después los datos de Inscripciones.
sin_cambios(Objetivo) :-
    estado(E),
    setup_call_cleanup(true, Objetivo, restaurar(E)).

test(formulario, true(L == ["┌─ Inscribir en sintaxis ┐",
                            "│ Legajo: 10_            │",
                            "└────────────────────────┘",
                            "Dígitos: legajo  Enter: inscribir  \c
                             q: cancelar"])) :-
    pantalla_formulario(menu(6, formulario("10"), ""), Todas),
    length(L, 4),
    once(append(_, L, Todas)).

test(escribir_y_borrar, true(M == menu(6, formulario("104"), ""))) :-
    foldl(paso_formulario, [letra(i), letra('1'), letra('0'), letra('5'),
                            borrar, letra('4'), letra(x)],
          menu(6, inscriptos, ""), M).

test(inscribir, true(M-Lista == menu(6, inscriptos,
                                     "Inscripción aceptada: 104 en ssl")-
                                "│ 104 diego     cursando  │")) :-
    sin_cambios(( foldl(paso_formulario,
                        [letra(i), letra('1'), letra('0'), letra('4'), enter],
                        menu(6, inscriptos, ""), M),
                  pantalla_formulario(M, [_, Lista|_]) )).

test(rechazo, true(A == "Inscripción rechazada: 103 en ssl, falta(log)")) :-
    sin_cambios(foldl(paso_formulario,
                      [letra(i), letra('1'), letra('0'), letra('3'), enter],
                      menu(6, inscriptos, ""), menu(_, _, A))).

test(cancelar, true(M == menu(6, inscriptos, ""))) :-
    foldl(paso_formulario, [letra(i), letra('7'), letra(q)],
          menu(6, inscriptos, ""), M).

% El bucle con las teclas en una cadena: abajo cinco veces hasta sintaxis,
% Enter, i, 1 0 4, Enter; al final, el fin de la entrada.
test(bucle, true(A == "Inscripción aceptada: 104 en ssl")) :-
    sin_cambios(
        setup_call_cleanup(
            open_string("\e[B\e[B\e[B\e[B\e[B\ri104\r", In),
            with_output_to(string(_),
                           bucle_formulario(get_code(In),
                                            menu(1, materias, ""),
                                            menu(_, salir, A))),
            close(In))).

:- end_tests(soluciones_menu).
