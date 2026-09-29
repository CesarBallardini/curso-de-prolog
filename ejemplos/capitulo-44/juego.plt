:- encoding(utf8).

:- begin_tests(juego, [setup(iniciar), cleanup(iniciar)]).

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
%   menu/3 con el stream como último argumento, para con_entrada/3.
elegir(Opciones, Valor, In) :-
    menu(In, Opciones, Valor).

%!  opciones(-Opciones:list) is det.
%
%   Tres opciones para probar el menú.
opciones([opcion("Uno", a), opcion("Dos", b), opcion("Tres", c)]).

test(menu, true(V == b)) :-
    opciones(Os),
    con_entrada("2\n", elegir(Os, V), _).

test(menu_repite, true(V-N == c-2)) :-
    opciones(Os),
    con_entrada("7\nuno\n 3 \n", elegir(Os, V), Salida),
    aggregate_all(count,
                  sub_string(Salida, _, _, _, "no es una de las opciones"),
                  N).

test(menu_sin_entrada, true(V == c)) :-
    opciones(Os),
    con_entrada("", elegir(Os, V), _).

test(menu_muestra, true(Primeras == ["1. Uno", "2. Dos", "3. Tres"])) :-
    opciones(Os),
    con_entrada("1\n", elegir(Os, _), Salida),
    split_string(Salida, "\n", "", [L1, L2, L3|_]),
    Primeras = [L1, L2, L3].

test(partida_hasta_ganar, true(Ultima == "> Pones la lente en el \c
                                           telescopio. Con la lente en su \c
                                           lugar, el telescopio muestra el \c
                                           cielo nocturno.")) :-
    iniciar,
    con_entrada("biblioteca\ntomar la llave\nvestíbulo\nabrir la puerta\n\c
                 taller\ntomar la linterna\nencender la linterna\n\c
                 abrir la trampilla\nsótano\nabrir el baúl\n\c
                 tomar la lente\ntaller\nvestíbulo\nbiblioteca\ncúpula\n\c
                 poner la lente en el telescopio\nmirar\n",
                partida, Salida),
    split_string(Salida, "\n", "", Lineas),
    once(append(_, [Ultima, ""], Lineas)),
    ganado.

test(partida_sin_entrada, true(Salida == "> Fin de la partida.\n")) :-
    iniciar,
    con_entrada("", partida, Salida).

test(salir, true(Salida == "> La llave de bronce no está al alcance.\n\c
                            > Fin de la partida.\n")) :-
    iniciar,
    con_entrada("tomar la llave\nsalir\ntaller\n", partida, Salida).

test(jugar_partida_nueva, true(Lineas == ["1. Partida nueva",
                                          "2. Continuar la partida guardada",
                                          "3. Salir",
                                          "Elige una opción, de 1 a 3: \c
                                           Estás en el vestíbulo. Un \c
                                           vestíbulo con baldosas gastadas \c
                                           y olor a humedad. Ves un \c
                                           perchero. Desde aquí puedes ir a \c
                                           la biblioteca y al taller.",
                                          "> Fin de la partida.",
                                          ""])) :-
    con_entrada("1\nsalir\n", jugar, Salida),
    split_string(Salida, "\n", "", Lineas).

test(jugar_salir, true(Ultima == "Elige una opción, de 1 a 3: ")) :-
    con_entrada("3\n", jugar, Salida),
    split_string(Salida, "\n", "", Lineas),
    last(Lineas, Ultima).

:- end_tests(juego).
