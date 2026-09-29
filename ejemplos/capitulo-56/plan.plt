:- encoding(utf8).

:- begin_tests(plan).

plan_de(Orden, Plan) :-
    modelo_ejemplo(M),
    planificar(Orden, M, Plan).

test(copiar_conjunto, P == [ copiar("informes/acta.txt", "respaldo/acta.txt"),
                             copiar("informes/notas.txt",
                                    "respaldo/notas.txt") ]) :-
    plan_de(copiar(archivos("informes", patron("*.txt")), a("respaldo")), P).

test(renombrar, P == [mover("notas.txt", "apuntes.txt")]) :-
    plan_de(mover(archivo("notas.txt"), a("apuntes.txt")), P).

test(no_sobrescribe, P == [rechazo(ya_existe("informes/notas.txt"))]) :-
    plan_de(copiar(archivo("notas.txt"), a("informes")), P).

test(varios_a_un_nombre, P == [rechazo(no_es_carpeta("nuevo"))]) :-
    plan_de(copiar(archivos("informes", todos), a("nuevo")), P).

test(nombre_en_carpeta_inexistente, P == [rechazo(no_existe("otra"))]) :-
    plan_de(copiar(archivo("notas.txt"), a("otra/notas.txt")), P).

test(borrar_patron, P == [borrar("borrador.tmp")]) :-
    plan_de(borrar(archivos(".", patron("*.tmp"))), P).

test(borrar_ninguno, P == [rechazo(ninguno("informes", patron("*.doc")))]) :-
    plan_de(borrar(archivos("informes", patron("*.doc"))), P).

test(no_existe, P == [rechazo(no_existe("otro.txt"))]) :-
    plan_de(borrar(archivo("otro.txt")), P).

test(listar, P == [informar(lista(".", [ "borrador.tmp", "hola.pl",
                                         "informes/", "notas.txt",
                                         "respaldo/" ]))]) :-
    plan_de(listar(".", todos), P).

test(listar_patron,
     P == [informar(lista("informes", ["acta.txt", "notas.txt"]))]) :-
    plan_de(listar("informes", patron("*.txt")), P).

test(contar, P == [informar(cantidad("informes", todos, 3))]) :-
    plan_de(contar("informes", todos), P).

test(carpeta_inexistente, P == [rechazo(no_existe("nada"))]) :-
    plan_de(listar("nada", todos), P).

test(tamano, P == [informar(tamano([ "informes/acta.txt",
                                     "informes/notas.txt",
                                     "informes/resumen.pdf" ], 2468))]) :-
    plan_de(tamano(archivos("informes", todos)), P).

test(fecha, P == [informar(fecha("hola.pl", "2026-09-01"))]) :-
    plan_de(fecha(archivo("hola.pl")), P).

test(buscar, P == [informar(encontrados("notas.txt",
                                        [ "informes/notas.txt",
                                          "notas.txt" ]))]) :-
    plan_de(buscar(patron("notas.txt")), P).

test(buscar_nada, P == [informar(encontrados("*.doc", []))]) :-
    plan_de(buscar(patron("*.doc")), P).

test(ejecutar, P == [ejecutar("hola.pl")]) :-
    plan_de(ejecutar(archivo("hola.pl")), P).

test(no_ejecutable, P == [rechazo(no_ejecutable("notas.txt"))]) :-
    plan_de(ejecutar(archivo("notas.txt")), P).

test(salir, P == [salir]) :-
    plan_de(salir, P).

test(fuera_arriba, P == [rechazo(fuera_de_la_carpeta("../secreto.txt"))]) :-
    plan_de(borrar(archivo("../secreto.txt")), P).

test(fuera_absoluta, P == [rechazo(fuera_de_la_carpeta("/etc/passwd"))]) :-
    plan_de(copiar(archivo("/etc/passwd"), a("respaldo")), P).

test(fuera_unidad, P == [rechazo(fuera_de_la_carpeta("c:/x"))]) :-
    plan_de(copiar(archivo("notas.txt"), a("c:/x")), P).

test(fuera_en_medio,
     P == [rechazo(fuera_de_la_carpeta("informes/../../x"))]) :-
    plan_de(listar("informes/../../x", todos), P).

test(comodin, all(N == ["acta.txt", "nota.txt"])) :-
    member(N, ["acta.txt", "nota.txt", "notas.pdf", "txt"]),
    pasa(patron("*t*.txt"), N).

:- end_tests(plan).
