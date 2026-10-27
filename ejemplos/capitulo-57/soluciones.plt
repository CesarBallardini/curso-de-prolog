:- encoding(utf8).

:- begin_tests(soluciones).

plan_de(Texto, Plan) :-
    entender(Texto, Orden),
    modelo_ejemplo(M),
    planificar(Orden, M, Plan).

muestra(D) :-
    tmp_file(ordenes, D),
    make_directory(D),
    modelo_ejemplo(M),
    crear_muestra(D, M).

test(sinonimos, Os == [ listar("informes", todos),
                        copiar(archivo("notas.txt"), a("respaldo")),
                        mover(archivo("hola.pl"), a("respaldo")) ]) :-
    maplist(entender, [ "Enumera los archivos de informes",
                        "Duplica notas.txt a respaldo",
                        "Traslada hola.pl a respaldo" ], Os).

test(fecha_orden, O == borrar(fechados(".", antes, "2026-09-01"))) :-
    entender("Borra los archivos anteriores al 1/9/2026", O).

test(fecha_plan, P == [borrar("borrador.tmp")]) :-
    plan_de("Borra los archivos anteriores al 1/9/2026", P).

test(fecha_tamano, P == [informar(tamano([ "informes/notas.txt",
                                           "informes/resumen.pdf" ],
                                         2168))]) :-
    plan_de("¿Cuánto ocupan los archivos posteriores al 11/9/2026 de informes?",
            P).

test(fecha_ninguno, T == "En la carpeta informes no hay ningún archivo posterior al 2026-12-01.") :-
    plan_de("Borra los archivos posteriores al 1/12/2026 de informes",
            [rechazo(M)]),
    oracion(rechazo(M), T).

test(fecha_invalida, fail) :-
    entender("Borra los archivos anteriores al 31/2/2026", _).

test(ejemplos, Ts == [ "lista los archivos",
                       "cuantos archivos .txt hay de informes",
                       "copia el archivo notas.txt a respaldo",
                       "mueve los archivos .tmp a viejos",
                       "borra el archivo borrador.tmp",
                       "cuanto ocupan los archivos de informes",
                       "cuando se modifico el archivo notas.txt",
                       "busca los archivos .pl",
                       "ejecuta el archivo hola.pl",
                       "salir" ]) :-
    ejemplos_de_ordenes(Ts).

test(ejemplos_se_entienden) :-
    ejemplos_de_ordenes(Ts),
    forall(member(T, Ts), entender(T, _)).

test(total, P == [informar(total(6))]) :-
    plan_de("¿Cuántos archivos hay en total?", P).

test(total_oracion, T == "Hay 6 archivos en total.") :-
    oracion(total(6), T).

test(mayor, P == [informar(mayor("informes/resumen.pdf", 2048))]) :-
    plan_de("¿Cuál es el archivo más grande de informes?", P).

test(mayor_vacia, P == [rechazo(ninguno("respaldo", todos))]) :-
    plan_de("¿Cuál es el archivo más grande de respaldo?", P).

test(varias, Os == [ copiar(archivo("notas.txt"), a("respaldo")),
                     borrar(archivo("respaldo/notas.txt")) ]) :-
    entender_varias("Copia notas.txt a respaldo y borra respaldo/notas.txt",
                    Os).

test(varias_plan, P == [ copiar("notas.txt", "respaldo/notas.txt"),
                         borrar("respaldo/notas.txt") ]) :-
    entender_varias("Copia notas.txt a respaldo y borra respaldo/notas.txt",
                    Os),
    modelo_ejemplo(M),
    planificar_varias(Os, M, P).

test(varias_rechazo, P == [ mover("notas.txt", "apuntes.txt"),
                            rechazo(no_existe("notas.txt")) ]) :-
    entender_varias("Renombra notas.txt como apuntes.txt y borra notas.txt",
                    Os),
    modelo_ejemplo(M),
    planificar_varias(Os, M, P).

test(aplicar) :-
    modelo_ejemplo(M0),
    aplicar([mover("notas.txt", "apuntes.txt"), borrar("borrador.tmp")],
            M0, M),
    memberchk(archivo("apuntes.txt", 80, "2026-09-20"), M),
    \+ memberchk(archivo("notas.txt", _, _), M),
    \+ memberchk(archivo("borrador.tmp", _, _), M).

test(mayusculas, O == copiar(archivo("Informe.PDF"), a("respaldo"))) :-
    entender_con_mayusculas("Copia Informe.PDF a respaldo.", O).

test(mayusculas_palabras, Ps == ["copia", "Informe.PDF", "a", "respaldo"]) :-
    palabras_con_mayusculas("Copia Informe.PDF a respaldo.", Ps).

test(argumentos, O == ejecutar_con(archivo("eco.pl"), ["uno", "dos"])) :-
    entender("Ejecuta eco.pl con uno dos", O).

test(argumentos_real, [ setup(muestra(D)),
                        cleanup(delete_directory_and_contents(D)) ]) :-
    directory_file_path(D, 'eco.pl', Eco),
    setup_call_cleanup(
        open(Eco, write, S, [newline(posix)]),
        format(S, ":- initialization(main, main).~n~s~n",
               ["main :- current_prolog_flag(argv, A), print(A), nl."]),
        close(S)),
    leer_modelo(D, M),
    entender("Ejecuta eco.pl con uno dos", O),
    planificar(O, M, Plan),
    ejecutar_plan(real, D, Plan, read_line_to_string(user_input),
                  user_output, Rs),
    Rs == [salida("eco.pl", exit(0), ["[uno,dos]"])].

test(argumentos_simulados, T == "Se ejecutaría hola.pl con los argumentos a b.") :-
    oracion(simulada(ejecutar_con("hola.pl", ["a", "b"])), T).

% Ejercicio 7: en qué etapa se detiene cada orden.
test(seguridad, Rs == [ plan([rechazo(ya_existe("notas.txt"))]),
                        plan([rechazo(fuera_de_la_carpeta("informes/../."))]),
                        plan([rechazo(fuera_de_la_carpeta("/etc/passwd"))]),
                        gramatica,
                        gramatica,
                        plan([rechazo(fuera_de_la_carpeta("../notas.txt"))])
                      ]) :-
    maplist(etapa, [ "Copia notas.txt a ..",
                     "Lista los archivos de informes/../..",
                     "Borra /etc/passwd",
                     "Copia notas.txt a c:/x",
                     "Busca ../*.txt",
                     "Copia notas.txt de .. a respaldo" ], Rs).

etapa(Texto, R) :-
    (   entender(Texto, O)
    ->  planificar_ejemplo(O, P),
        R = plan(P)
    ;   R = gramatica
    ).

test(relacion_temporal, all(R == [despues])) :-
    phrase(relacion_temporal(R), ["posteriores", "al"]).

test(comparar_fecha, all(Rel == [antes])) :-
    member(Rel, [antes, despues]),
    comparar_fecha(Rel, "2026-08-30", "2026-09-01").

test(comparar_fecha_igual, fail) :-
    member(Rel, [antes, despues]),
    comparar_fecha(Rel, "2026-09-01", "2026-09-01").

test(varias_una, all(Os == [[borrar(archivo("a.txt"))]])) :-
    phrase(varias(Os), ["borra", "a.txt"]).

test(varias_dos, all(Os == [[borrar(archivo("a.txt")),
                             borrar(archivo("b.txt"))]])) :-
    phrase(varias(Os), ["borra", "a.txt", "y", "borra", "b.txt"]).

test(planificar_varias_ejemplo,
     true(P == [ mover("notas.txt", "apuntes.txt"),
                 copiar("apuntes.txt", "respaldo/apuntes.txt") ])) :-
    planificar_varias_ejemplo([ mover(archivo("notas.txt"), a("apuntes.txt")),
                                copiar(archivo("apuntes.txt"), a("respaldo")) ],
                              P).

test(aplicar_accion_mover,
     true(M == [archivo("b.txt", 1, "f"), carpeta("c")])) :-
    aplicar_accion(mover("a.txt", "b.txt"),
                   [archivo("a.txt", 1, "f"), carpeta("c")], M).

test(aplicar_accion_copiar,
     true(M == [archivo("b.txt", 1, "f"), archivo("a.txt", 1, "f")])) :-
    aplicar_accion(copiar("a.txt", "b.txt"), [archivo("a.txt", 1, "f")], M).

test(aplicar_accion_borrar, true(M == [])) :-
    aplicar_accion(borrar("a.txt"), [archivo("a.txt", 1, "f")], M).

test(aplicar_accion_informar, true(M == [carpeta("c")])) :-
    aplicar_accion(informar(x), [carpeta("c")], M).

test(palabra_conservada, true(Ps == ["Informe.PDF", "copia", "2026"])) :-
    maplist(palabra_conservada, ["Informe.PDF", "Copia", "2026"], Ps).

test(parece_nombre, all(P == ["a.txt", "dir/x", "v2"])) :-
    member(P, ["a.txt", "dir/x", "v2", "Informe"]),
    parece_nombre(P).

:- end_tests(soluciones).
