:- encoding(utf8).

:- begin_tests(teclas).

%!  con_entrada(+Texto:string, :Objetivo, -Salida:string) is semidet.
%
%   Ejecuta call(Objetivo, In), con In un stream que lee Texto; Salida es
%   todo lo que Objetivo escribió.
con_entrada(Texto, Objetivo, Salida) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), once(call(Objetivo, In))),
        close(In)).

%!  elegir(+Opciones:list, -Valor, +In) is det.
%
%   menu_tecla/3 con el stream como último argumento.
elegir(Opciones, Valor, In) :-
    menu_tecla(In, Opciones, Valor).

%!  responder(+Pregunta:string, -R, +In) is det.
%
%   si_o_no/3 con el stream como último argumento.
responder(Pregunta, R, In) :-
    si_o_no(In, Pregunta, R).

%!  opciones(-Opciones:list) is det.
%
%   Tres opciones para probar el menú.
opciones([opcion("Uno", a), opcion("Dos", b), opcion("Tres", c)]).

test(leer_tecla, true(Cs == [a, b, end_of_file])) :-
    open_string(" a\n\tb  ", In),
    findall(C, ( between(1, 3, _), leer_tecla(In, C) ), Cs),
    close(In).

test(menu, true(V == b)) :-
    opciones(Os),
    con_entrada("2", elegir(Os, V), _).

test(menu_sin_intro, true(V == a)) :-
    opciones(Os),
    con_entrada("13", elegir(Os, V), _).

test(menu_repite, true(V-N == c-2)) :-
    opciones(Os),
    con_entrada("x7\n3", elegir(Os, V), Salida),
    aggregate_all(count,
                  sub_string(Salida, _, _, _, "no es una de las opciones"),
                  N).

test(menu_cero, true(V == a)) :-
    opciones(Os),
    con_entrada("01", elegir(Os, V), _).

test(menu_sin_entrada, true(V == c)) :-
    opciones(Os),
    con_entrada("", elegir(Os, V), _).

test(menu_muestra, true(Ls == ["1. Uno", "2. Dos", "3. Tres",
                               "Pulsa una tecla, de 1 a 3: "])) :-
    opciones(Os),
    con_entrada("1", elegir(Os, _), Salida),
    split_string(Salida, "\n", "", Ls).

test(si, true(R == si)) :-
    con_entrada("s", responder("¿Seguir?", R), _).

test(no_mayuscula, true(R == no)) :-
    con_entrada("N", responder("¿Seguir?", R), _).

test(si_o_no_repite, true(R-S == si-"¿Seguir? (s/n): Pulsa s o n.\n\c
                                    ¿Seguir? (s/n): ")) :-
    con_entrada("x S", responder("¿Seguir?", R), S).

test(si_o_no_sin_entrada, true(R == no)) :-
    con_entrada("", responder("¿Seguir?", R), _).

test(respuesta, all(T-R == [s-si, n-no])) :-
    teclas:respuesta(T, R).

:- end_tests(teclas).
