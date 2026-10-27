:- encoding(utf8).

:- begin_tests(informe).

test(cuenta, [true(Lineas == [
    "variable  conjuntos       signos  intervalos      muestra",
    "n         {pos}           pos     i(1,sup)        1..12",
    "x         {cero,neg}      top     i(0,0)          0..0",
    "",
    "conjuntos: puede terminar dividiendo por cero",
    "signos: el divisor de 100/(x+1) puede ser cero (top)",
    "signos: cubre 12 de 12 corridas",
    "intervalos: cubre 12 de 12 corridas",
    ""])]) :-
    with_output_to(string(S), informe(cuenta)),
    split_string(S, "\n", "", Todas),
    once(append(_, ["entradas: [n-entre(1,sup)]", ""|Lineas], Todas)).

test(muerta) :-
    with_output_to(string(S), informe(cuadrado)),
    once(sub_string(S, _, _, _, "conjuntos: nunca se ejecuta escribir 0")).

test(no_es_caso, [fail]) :-
    informe(inexistente).

:- end_tests(informe).
