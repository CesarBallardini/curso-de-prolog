:- encoding(utf8).

:- begin_tests(soluciones_terminal).

% Ejercicio 13.
test(inicio_con_o, [true(P == pos([x, v, v, v, v, v, v, v, v], o))]) :-
    inicio_con_o(3, profundidad(9), e(_, _, P, _, _)).

% La persona marca con o, y la computadora responde con x.
test(persona_con_o, [true(T == [x, x, v, v, o, v, v, v, v])]) :-
    inicio_con_o(3, profundidad(9), E0),
    paso(letra('5'), E0, e(_, _, pos(T, o), _, _)).

test(mensajes, [true(Ms == ["Tu turno: juegas con O.", "Ganaste.",
                            "Gana la computadora."])]) :-
    mensaje_para(o, tateti(3), pos([x, v, v, v, v, v, v, v, v], o), jugar,
                 M1),
    mensaje_para(o, tateti(3), pos([o, o, o, x, x, v, x, v, v], x), jugar,
                 M2),
    mensaje_para(o, tateti(3), pos([x, x, x, o, o, v, v, v, v], o), jugar,
                 M3),
    Ms = [M1, M2, M3].

test(pantalla_para, [true(M == "│ Tu turno: juegas con O. │")]) :-
    inicio_con_o(3, profundidad(9), E),
    pantalla_para(o, E, Lineas),
    nth1(7, Lineas, M).

% Una partida entera con las teclas en una cadena: la persona, con o,
% marca 2 y 3, y x completa la columna 1-4-7. La última pantalla
% anuncia la victoria de la computadora, no la de la persona.
test(partida_con_o, [true(R-Ultima == gana(x)-"│ Gana la computadora. │")]) :-
    inicio_con_o(3, profundidad(9), E0),
    setup_call_cleanup(
        open_string("23", In),
        with_output_to(string(_),
                       bucle_para(o, get_code(In), E0, E)),
        close(In)),
    E = e(J, _, P, _, _),
    fin(J, P, R),
    pantalla_para(o, E, Lineas),
    nth1(7, Lineas, Ultima).

test(resultado_para_empate, [true(M == "Empate.")]) :-
    resultado_para(empate, o, M).

test(mensaje_para_salir, [true(M == "Partida abandonada.")]) :-
    mensaje_para(o, tateti(3), pos([x, v, v, v, v, v, v, v, v], o), salir,
                 M).

% Ejercicio 14.
test(perfecto, [true(Js-R == [1, 5, 2, 3, 7, 4, 6, 8, 9]-empate)]) :-
    autojuego(tateti(3), profundidad(9), profundidad(9), Js, R).

test(contra_profundidad_1, [true(R == empate)]) :-
    autojuego(tateti(3), profundidad(9), profundidad(1), _, R).

test(cuatro, [true(L-R == 16-empate)]) :-
    autojuego(tateti(4), profundidad(4), profundidad(1), Js, R),
    length(Js, L).

:- end_tests(soluciones_terminal).
