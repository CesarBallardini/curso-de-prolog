:- encoding(utf8).

:- begin_tests(lenguaje, [setup(iniciar), cleanup(iniciar)]).

%!  sesion(+Textos:list(string), -Salidas:list(string)) is det.
%
%   Ejecuta las órdenes Textos una tras otra desde una partida nueva.
sesion(Textos, Salidas) :-
    iniciar,
    maplist(ejecutar, Textos, Salidas).

%!  en_un_directorio_temporal(:Objetivo) is semidet.
%
%   Ejecuta Objetivo con un directorio temporal vacío como directorio de
%   trabajo, y lo borra al terminar.
en_un_directorio_temporal(Objetivo) :-
    tmp_file(dir, Dir),
    make_directory(Dir),
    setup_call_cleanup(
        working_directory(Antes, Dir),
        once(Objetivo),
        ( working_directory(_, Antes),
          delete_directory_and_contents(Dir) )).

test(palabras, true(Ps == [ir, a, la, cupula])) :-
    palabras("¡Ir a la CÚPULA!", Ps).

test(palabras_vacio, true(Ps == [])) :-
    palabras("  ¿? ", Ps).

test(orden_con_nombre_completo, all(O == [tomar(llave)])) :-
    phrase(orden(O), [tomar, la, llave, de, bronce]).

test(orden_con_nucleo, all(O == [tomar(llave)])) :-
    phrase(orden(O), [agarrar, llave]).

test(ir_con_contraccion, all(O == [ir(sotano)])) :-
    phrase(orden(O), [bajar, al, sotano]).

test(sala_sola, all(O == [ir(biblioteca)])) :-
    phrase(orden(O), [la, biblioteca]).

test(poner, all(O == [poner(lente, telescopio)])) :-
    phrase(orden(O), [dejar, la, lente, en, el, telescopio]).

test(no_se_va_a_un_objeto, fail) :-
    phrase(orden(_), [ir, a, la, lente]).

test(generar, true(Ps == [tomar, llave, de, bronce])) :-
    once(phrase(orden(tomar(llave)), Ps)).

test(no_entendido, true(O == no_entendido)) :-
    entender("volar hasta la luna", O).

% «abrir la puerta» tiene dos lecturas en el vestíbulo; se elige la que
% ningún impedimento bloquea.
test(elige_por_el_estado, true(O == abrir(puerta_taller))) :-
    sesion(["biblioteca", "tomar la llave", "vestíbulo"], _),
    entender("abrir la puerta", O).

test(sin_lectura_ejecutable, true(O == abrir(puerta_biblioteca))) :-
    iniciar,
    entender("abrir la puerta", O).

test(mirar, true(S == "Estás en el vestíbulo. Un vestíbulo con baldosas \c
                       gastadas y olor a humedad. Ves un perchero. Desde \c
                       aquí puedes ir a la biblioteca y al taller.")) :-
    sesion(["mirar"], [S]).

test(concordancia, true(Ss == ["La linterna ya está encendida.",
                               "La trampilla ya está abierta.",
                               "El baúl ya está abierto."])) :-
    iniciar,
    restablecer([aqui(sotano), esta_en(linterna, jugador),
                 encendido(linterna), esta_en(baul, sotano)]),
    maplist(responder, [encender(linterna), abrir(trampilla), abrir(baul)],
            Ss).

test(motivos, true(Ss == ["No puedes abrir la puerta del taller: está \c
                           cerrada con llave; necesitas la llave de bronce.",
                           "No puedes llevarte el perchero.",
                           "No llevas la lente.",
                           "Ya estás en el vestíbulo."])) :-
    sesion(["abrir la puerta del taller", "tomar el perchero",
            "dejar la lente", "vestíbulo"], Ss).

test(enumeracion,true(S == "Llevas un catálogo de estrellas, una \c
                             linterna y una llave de bronce.")) :-
    iniciar,
    restablecer([aqui(taller), esta_en(catalogo, jugador),
                 esta_en(linterna, jugador), esta_en(llave, jugador)]),
    ejecutar("inventario", S).

test(victoria, true(Ultima == "Pones la lente en el telescopio. Con la \c
                               lente en su lugar, el telescopio muestra el \c
                               cielo nocturno.")) :-
    sesion([ "ir a la biblioteca", "tomar la llave", "vestíbulo",
             "abrir la puerta", "taller", "tomar la linterna",
             "encender la linterna", "abrir la trampilla", "bajar al sótano",
             "abrir el baúl", "tomar la lente", "taller", "vestíbulo",
             "biblioteca", "subir a la cúpula",
             "poner la lente en el telescopio" ], Salidas),
    last(Salidas, Ultima).

test(guardar_y_cargar, true(S2 == "Partida cargada de uno.partida. Estás \c
                                  en la biblioteca. Estantes hasta el \c
                                  techo, casi todos vacíos. Ves un \c
                                  catálogo de estrellas y un escritorio. \c
                                  Desde aquí puedes ir a la cúpula y al \c
                                  vestíbulo.")) :-
    en_un_directorio_temporal(
        ( sesion(["biblioteca", "guardar uno"], [_, S1]),
          assertion(S1 == "Partida guardada en uno.partida."),
          iniciar,
          ejecutar("cargar uno", S2) )).

test(cargar_lo_que_no_existe,
     true(S == "No fue posible cargar la partida de otra.partida.")) :-
    en_un_directorio_temporal(sesion(["cargar otra"], [S])).

test(sin_tilde, true(Cs == [0'u, 0'a])) :-
    lenguaje:sin_tilde(0'ú, U),
    lenguaje:sin_tilde(0'a, A),
    Cs = [U, A].

test(palabra, true(P-Resto == hola-` mundo`)) :-
    phrase(lenguaje:palabra(P), `hola mundo`, Resto).

test(no_es_letra, fail) :-
    phrase(lenguaje:letra(_), `,`, _).

test(destino, all(S == [cupula])) :-
    phrase(lenguaje:destino(S), [a, la, cupula]).

test(destino_contraccion, all(S == [sotano])) :-
    phrase(lenguaje:destino(S), [al, sotano]).

test(sinonimo, all(V == [tomar])) :-
    phrase(lenguaje:verbo(V), [agarrar]).

test(cosa, all(X == [llave])) :-
    phrase(lenguaje:cosa(X), [la, llave, de, bronce]).

test(cosa_sin_articulo, all(X == [lente])) :-
    phrase(lenguaje:cosa(X), [lente]).

test(cosa_no_es_sala, fail) :-
    phrase(lenguaje:cosa(_), [la, biblioteca]).

test(nombrada_por_nucleo, all(X == [llave])) :-
    phrase(lenguaje:nombrada(X), [llave]).

test(responder, true(T == "Estás en el vestíbulo. Un vestíbulo con \c
                          baldosas gastadas y olor a humedad. Ves un \c
                          perchero. Desde aquí puedes ir a la biblioteca \c
                          y al taller.")) :-
    iniciar,
    lenguaje:responder(mirar, T).

test(resultado, true(Rs == [vista(vestibulo, [perchero],
                                  [biblioteca, taller])])) :-
    iniciar,
    lenguaje:resultado(mirar, Rs).

test(del_juego, true(Rs == [fin])) :-
    lenguaje:del_juego(salir, Rs).

test(no_es_del_juego, fail) :-
    lenguaje:del_juego(mirar, _).

test(respuestas, true(S == "Tomas la llave de bronce. Tomas la linterna.")) :-
    phrase(lenguaje:respuestas([tomado(llave), tomado(linterna)]), Cs),
    string_codes(S, Cs).

test(contenido, true(S == "en el escritorio ves una llave de bronce.")) :-
    phrase(lenguaje:contenido([llave], escritorio), Cs),
    string_codes(S, Cs).

test(a_la_vista_nada, true(Cs == [])) :-
    phrase(lenguaje:a_la_vista([]), Cs).

test(enumeracion_uno, true(S == "una llave de bronce")) :-
    phrase(lenguaje:enumeracion(lenguaje:un, [llave]), Cs),
    string_codes(S, Cs).

test(enumeracion_tres,
     true(S == "el perchero, la linterna y la llave de bronce")) :-
    phrase(lenguaje:enumeracion(lenguaje:el, [perchero, linterna, llave]),
           Cs),
    string_codes(S, Cs).

test(articulos, true(Ss == ["un banco de trabajo", "a la cúpula"])) :-
    phrase(lenguaje:un(banco), C1),
    phrase(lenguaje:al(cupula), C2),
    maplist([C, S]>>string_codes(S, C), [C1, C2], Ss).

test(terminacion, true(Ts == ["a", "o"])) :-
    phrase(lenguaje:terminacion(llave), C1),
    phrase(lenguaje:terminacion(baul), C2),
    maplist([C, S]>>string_codes(S, C), [C1, C2], Ts).

:- end_tests(lenguaje).
