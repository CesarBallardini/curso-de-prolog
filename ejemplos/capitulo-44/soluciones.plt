:- encoding(utf8).

:- begin_tests(soluciones, [setup(iniciar), cleanup(iniciar)]).

%!  con_entrada(+Texto:string, :Objetivo, -Salida:string) is semidet.
%
%   Ejecuta call(Objetivo, In), con In un stream que lee Texto; Salida es
%   todo lo que Objetivo escribió.
con_entrada(Texto, Objetivo, Salida) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), once(call(Objetivo, In))),
        close(In)).

%!  en_el_sotano is det.
%
%   El jugador en el sótano, con la linterna encendida y el baúl abierto.
en_el_sotano :-
    restablecer([aqui(sotano), esta_en(linterna, jugador),
                 encendido(linterna), esta_en(baul, sotano),
                 esta_en(lente, baul)]).

%!  por_inicial(+Opciones:list, -Valor, +In) is det.
%
%   menu_por_inicial/3 con el stream como último argumento.
por_inicial(Opciones, Valor, In) :-
    menu_por_inicial(In, Opciones, Valor).

% Ejercicio 4

test(sacar_del_baul, true(O == tomar(lente))) :-
    en_el_sotano,
    entender_con_origen("sacar la lente del baúl", O).

test(de_otro_recipiente, true(O == no_entendido)) :-
    en_el_sotano,
    entender_con_origen("sacar la lente del escritorio", O).

test(sin_origen, true(O == tomar(lente))) :-
    en_el_sotano,
    entender_con_origen("tomar la lente", O).

% Ejercicio 5

test(varias, true(S == "Tomas la llave de bronce. Estás en el vestíbulo. \c
                        Un vestíbulo con baldosas gastadas y olor a \c
                        humedad. Ves un perchero. Desde aquí puedes ir a \c
                        la biblioteca y al taller. Abres la puerta del \c
                        taller.")) :-
    iniciar,
    ejecutar("biblioteca", _),
    ejecutar_varias("tomar la llave y vestíbulo y abrir la puerta del \c
                     taller", S).

test(se_detiene_en_la_bloqueada, true(S-A == "La puerta del taller está \c
                                              cerrada.\c
                                              "-vestibulo)) :-
    iniciar,
    ejecutar_varias("taller y biblioteca", S),
    aqui(A).

% Ejercicio 6

test(limite, true(Ultima == "Se terminó el tiempo.")) :-
    iniciar,
    con_entrada("mirar\nmirar\nmirar\nmirar\n",
                [In]>>partida_con_limite(In, 3), Salida),
    split_string(Salida, "\n", "", Lineas),
    once(append(_, [Ultima, ""], Lineas)).

% Ejercicio 7

test(tomar_todo, true(S-Os == "Tomas la lente. Tomas la linterna."-
                              [lente, linterna])) :-
    iniciar,
    restablecer([aqui(sotano), esta_en(linterna, sotano),
                 encendido(linterna), esta_en(baul, sotano),
                 esta_en(lente, baul)]),
    ejecutar_con_todo("agarrar todo", S),
    objetos_en(jugador, Os).

test(nada_para_tomar, true(S == "No hay nada para tomar.")) :-
    iniciar,
    ejecutar_con_todo("tomar todo", S).

% Ejercicio 9

test(con_formato, true(H == H0)) :-
    iniciar,
    ejecutar("biblioteca", _),
    instantanea(H0),
    tmp_file(partida, A),
    guardar_con_formato(A),
    iniciar,
    cargar_con_formato(A),
    delete_file(A),
    instantanea(H).

test(sin_formato, [ error(domain_error(partida_con_formato_1, _)),
                    cleanup(assertion(aqui(vestibulo))) ]) :-
    iniciar,
    tmp_file(partida, A),
    setup_call_cleanup(guardar(A), cargar_con_formato(A), delete_file(A)).

% Ejercicio 11

test(por_inicial, true(V == guardada)) :-
    opciones_de_inicio(Os),
    con_entrada("x\nC\n", por_inicial(Os, V), _).

test(iniciales_repetidas, error(domain_error(iniciales_distintas, _))) :-
    menu_por_inicial(user_input, [opcion("Salir", a), opcion("Seguir", b)],
                     _).

% Ejercicio 12

test(deshacer, true(Lineas == ["> Tomas la llave de bronce.",
                               "> Orden deshecha. Estás en la \c
                                biblioteca. Estantes hasta el techo, casi \c
                                todos vacíos. Ves un escritorio. Desde \c
                                aquí puedes ir a la cúpula y al vestíbulo.",
                               "> No hay nada para deshacer.",
                               "> Fin de la partida.",
                               ""])) :-
    iniciar,
    restablecer([aqui(biblioteca), esta_en(escritorio, biblioteca),
                 esta_en(llave, escritorio)]),
    con_entrada("tomar la llave\ndeshacer\ndeshacer\nsalir\n",
                partida_con_deshacer, Salida),
    split_string(Salida, "\n", "", Lineas).

:- end_tests(soluciones).
