:- encoding(utf8).

:- begin_tests(propietarios).

plan_con_usuarios(Orden, Plan) :-
    modelo_con_usuarios(M),
    planificar(Orden, M, Plan).

test(entender_cuantos, true(O == contar_de("david"))) :-
    entender("¿Cuántos archivos tiene David?", O).

test(entender_cuales, true(O == listar_de("david"))) :-
    entender("¿Qué archivos tiene David?", O).

test(entender_de_quien, true(O == propietario(archivo("notas.txt")))) :-
    entender("¿De quién es notas.txt?", O).

test(entender_comparte,
     true(O == comparten(archivo("notas.txt"), "chris", "david"))) :-
    entender("¿Comparte Chris notas.txt con David?", O).

% Las preguntas de antes se siguen entendiendo como antes.
test(sigue_listar, true(O == listar(".", todos))) :-
    entender("¿Qué archivos hay?", O).

test(modelo_con_usuarios, true(N-P-C == 16-6-2)) :-
    modelo_con_usuarios(M),
    length(M, N),
    aggregate_all(count, member(propietario(_, _), M), P),
    aggregate_all(count, member(compartido(_, _), M), C).

test(plan_contar_de, true(P == [informar(cantidad_de("david", 3))])) :-
    plan_con_usuarios(contar_de("david"), P).

test(plan_listar_de,
     true(P == [informar(archivos_de("chris", ["hola.pl", "notas.txt"]))])) :-
    plan_con_usuarios(listar_de("chris"), P).

test(plan_propietario, true(P == [informar(duenio("notas.txt", "chris"))])) :-
    plan_con_usuarios(propietario(archivo("notas.txt")), P).

test(plan_sin_duenio, true(P == [informar(duenio("x.txt", nadie))])) :-
    planificar(propietario(archivo("x.txt")), [archivo("x.txt", 1, "f")],
               P).

test(plan_no_existe, true(P == [rechazo(no_existe("otro.txt"))])) :-
    plan_con_usuarios(propietario(archivo("otro.txt")), P).

test(plan_comparten_si,
     true(P == [informar(comparten("notas.txt", "chris", "david", si))])) :-
    plan_con_usuarios(comparten(archivo("notas.txt"), "chris", "david"), P).

test(plan_comparten_no,
     true(P == [informar(comparten("notas.txt", "bill", "david", no))])) :-
    plan_con_usuarios(comparten(archivo("notas.txt"), "bill", "david"), P).

% Nadie comparte un archivo consigo mismo.
test(plan_comparten_mismo,
     true(P == [informar(comparten("notas.txt", "chris", "chris", no))])) :-
    plan_con_usuarios(comparten(archivo("notas.txt"), "chris", "chris"), P).

test(plan_no_usuario, true(P == [rechazo(no_es_usuario("ana"))])) :-
    plan_con_usuarios(contar_de("ana"), P).

test(usuario_compartido) :-
    modelo_con_usuarios(M),
    usuario("david", M).

test(usuario_desconocido, throws(rechazo(no_es_usuario("ana")))) :-
    modelo_con_usuarios(M),
    usuario("ana", M).

test(acceso, all(U == ["chris", "david"])) :-
    modelo_con_usuarios(M),
    member(U, ["bill", "chris", "david"]),
    acceso("notas.txt", U, M).

test(oracion_cantidad, true(T == "Bill tiene 1 archivo.")) :-
    oracion(cantidad_de("bill", 1), T).

test(oracion_sin_archivos, true(T == "Ana no tiene archivos.")) :-
    oracion(archivos_de("ana", []), T).

test(oracion_sin_duenio, true(T == "x.txt no tiene dueño registrado.")) :-
    oracion(duenio("x.txt", nadie), T).

test(persona, true(P == "David")) :-
    persona("david", P).

test(responder_modelo, true(Rs == [ "David tiene 3 archivos.",
                                    "notas.txt es de Chris.",
                                    "Sí: Chris y David pueden usar \c
                                     notas.txt.",
                                    "No: Bill y David no comparten \c
                                     notas.txt.",
                                    "Ana no tiene archivos ni permisos en \c
                                     la carpeta." ])) :-
    maplist(responder_modelo,
            [ "¿Cuántos archivos tiene David?",
              "¿De quién es notas.txt?",
              "¿Comparte Chris notas.txt con David?",
              "¿Comparte Bill notas.txt con David?",
              "¿Cuántos archivos tiene Ana?" ],
            Rs).

test(no_entiende, fail) :-
    responder_modelo("¿Quién es David?", _).

:- end_tests(propietarios).
