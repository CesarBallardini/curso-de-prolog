:- encoding(utf8).

:- begin_tests(soluciones_propietarios).

test(entender, true(O == compartidos("chris", "david"))) :-
    entender("¿Qué archivos comparte Chris con David?", O).

test(compartidos, true(R == "Chris y David comparten notas.txt.")) :-
    responder_modelo("¿Qué archivos comparte Chris con David?", R).

test(otra_pareja,
     true(R == "Bill y David comparten informes/acta.txt.")) :-
    responder_modelo("¿Qué archivos comparte Bill con David?", R).

test(ninguno, true(R == "Bill y Chris no comparten archivos.")) :-
    responder_modelo("¿Qué archivos comparte Bill con Chris?", R).

test(no_usuario,
     true(R == "Ana no tiene archivos ni permisos en la carpeta.")) :-
    responder_modelo("¿Qué archivos comparte Ana con David?", R).

:- end_tests(soluciones_propietarios).
