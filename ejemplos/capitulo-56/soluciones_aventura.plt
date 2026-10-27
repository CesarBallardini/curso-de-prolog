:- encoding(utf8).

:- begin_tests(soluciones_aventura).

test(conversacion, true(Lineas ==
                        [ "> No puedes llevarte el perchero.",
                          "> ¿Por qué estás aburrido?",
                          "> Tomas la llave de bronce.",
                          "> Adiós. Gracias por conversar.",
                          ""
                        ])) :-
    setup_call_cleanup(
        open_string("tomar el perchero\nestoy aburrido\nbiblioteca\n\c
                     tomar la llave\nadiós\n", In),
        with_output_to(string(Salida), aventura_con_eliza(In)),
        close(In)),
    split_string(Salida, "\n", "", Lineas0),
    exclude([L]>>sub_string(L, _, _, _, "Estás en"), Lineas0, Lineas).

:- end_tests(soluciones_aventura).
