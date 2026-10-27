:- encoding(utf8).

:- begin_tests(cribar_seguro).

test(una_seccion, true(Q == ["a", "c"])) :-
    cribar(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Q).

test(dos_secciones, true(Q == ["a", "c", "e"])) :-
    cribar(["a", "INICIO", "b", "FIN", "c", "INICIO x", "d", "FIN y", "e"],
           "INICIO", "FIN", Q).

test(vacio, true(Q == [])) :-
    cribar([], "INICIO", "FIN", Q).

test(inicio_sin_fin, error(marcas(inicio_sin_fin(2)))) :-
    cribar(["a", "INICIO", "b", "c"], "INICIO", "FIN", _).

test(fin_sin_inicio, error(marcas(fin_sin_inicio(2)))) :-
    cribar(["a", "FIN", "b"], "INICIO", "FIN", _).

test(inicio_anidado, error(marcas(inicio_anidado(3, 2)))) :-
    cribar(["a", "INICIO", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", _).

test(marcas_iguales, true(Q == ["a", "c"])) :-
    cribar(["a", "%%", "b", "%%", "c"], "%%", "%%", Q).

test(paso_inicio, true(E-S == salteando(4)-[])) :-
    paso(copiando, 4, "INICIO", "INICIO", "FIN", E, S).

test(paso_fin, true(E-S == copiando-[])) :-
    paso(salteando(4), 6, "FIN", "INICIO", "FIN", E, S).

test(final_copiando) :-
    final(copiando).

test(final_salteando, error(marcas(inicio_sin_fin(4)))) :-
    final(salteando(4)).

test(mensaje, true(Texto == "línea 3: marca de inicio dentro de la sección abierta en la línea 2")) :-
    texto_del_mensaje(error(marcas(inicio_anidado(3, 2)), _), Texto).

%!  texto_del_mensaje(+Mensaje, -Texto:string) is det.
%
%   Texto es el texto de Mensaje, como lo escribe print_message/2, sin el
%   salto de línea final.
texto_del_mensaje(Mensaje, Texto) :-
    once(phrase(prolog:message(Mensaje), Lineas)),
    with_output_to(string(Con),
                   print_message_lines(current_output, '', Lineas)),
    split_string(Con, "", "\n", [Texto]).

:- end_tests(cribar_seguro).
