:- encoding(utf8).

:- begin_tests(aventura, [setup(iniciar), cleanup(iniciar)]).

%!  con_entrada(+Texto:string, :Objetivo, -Salida:string) is semidet.
%
%   Ejecuta call(Objetivo, In), con In un stream que lee Texto; Salida es
%   todo lo que Objetivo escribió.
con_entrada(Texto, Objetivo, Salida) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), once(call(Objetivo, In))),
        close(In)).

%!  ultima_pantalla(+Salida:string, -Pantalla:string) is det.
%
%   Pantalla es lo que se escribió después del último borrado.
ultima_pantalla(Salida, Pantalla) :-
    atomic_list_concat(Partes, '\e[2J', Salida),
    last(Partes, Ultima),
    atom_string(Ultima, Pantalla).

%!  lineas(+Pantalla:string, -Lineas:list(string)) is det.
%
%   Lineas son las filas que Pantalla escribe, cada una después de la
%   secuencia que lleva el cursor a su fila.
lineas(Pantalla, Lineas) :-
    split_string(Pantalla, "\e", "", [_|Partes]),
    maplist(sin_posicion, Partes, Lineas).

%!  sin_posicion(+Parte:string, -Linea:string) is det.
%
%   Linea es Parte sin la secuencia de posición, que termina en H.
sin_posicion(Parte, Linea) :-
    once(sub_string(Parte, _, 1, Despues, "H")),
    sub_string(Parte, _, Despues, 0, Linea).

%!  contiene(+Texto:string, +Parte:string) is semidet.
%
%   Parte aparece en Texto.
contiene(Texto, Parte) :-
    once(sub_string(Texto, _, _, _, Parte)).

%!  bucle_desde(+Mensajes:list(string), +In) is det.
%
%   bucle/2 con el stream como último argumento, para con_entrada/3.
bucle_desde(Mensajes, In) :-
    bucle(In, Mensajes).

test(partir, true(Ls == ["uno dos", "tres", "cuatro"])) :-
    partir("uno  dos tres cuatro", 8, Ls).

test(partir_palabra_larga, true(Ls == ["a", "larguisima", "b"])) :-
    partir("a larguisima b", 4, Ls).

test(partir_vacio, true(Ls == [])) :-
    partir("   ", 10, Ls).

test(pantalla_inicial, true(L == [
    "┌─ Lugar ──────────────────────────────────────────────────────┐",
    "│ Estás en el vestíbulo. Un vestíbulo con baldosas gastadas y  │",
    "│ olor a humedad. Ves un perchero. Desde aquí puedes ir a la   │",
    "│ biblioteca y al taller.                                      │",
    "└──────────────────────────────────────────────────────────────┘",
    "┌─ Inventario ─────────────────────────────────────────────────┐",
    "│ No llevas nada.                                              │",
    "└──────────────────────────────────────────────────────────────┘",
    "┌─ Mensajes ───────────────────────────────────────────────────┐",
    "│                                                              │",
    "└──────────────────────────────────────────────────────────────┘"
    ])) :-
    iniciar,
    pantalla([], L).

test(hasta_ganar, true) :-
    iniciar,
    con_entrada("biblioteca\ntomar la llave\nvestíbulo\nabrir la puerta\n\c
                 taller\ntomar la linterna\nencender la linterna\n\c
                 abrir la trampilla\nsótano\nabrir el baúl\n\c
                 tomar la lente\ntaller\nvestíbulo\nbiblioteca\ncúpula\n\c
                 poner la lente en el telescopio\nmirar\n",
                bucle_desde([]), Salida),
    ultima_pantalla(Salida, Pantalla),
    contiene(Pantalla, "> poner la lente en el telescopio"),
    contiene(Pantalla, "Pones la lente en el telescopio."),
    \+ contiene(Pantalla, "> mirar"),
    ganado.

% Cuatro órdenes dan más de ocho líneas de mensajes; se ven las ocho
% últimas, y la primera que queda es la respuesta del segundo mirar.
test(solo_los_ultimos_mensajes, true(N == 8)) :-
    iniciar,
    con_entrada("mirar
mirar
mirar
salir
", bucle_desde([]), Salida),
    ultima_pantalla(Salida, Pantalla),
    lineas(Pantalla, Lineas),
    once(( append(_, [Titulo|Resto], Lineas),
           contiene(Titulo, "Mensajes") )),
    once(( append(Interiores, [Pie|_], Resto),
           contiene(Pie, "└") )),
    length(Interiores, N).

test(fin_de_la_entrada, true) :-
    iniciar,
    con_entrada("", bucle_desde([]), Salida),
    ultima_pantalla(Salida, Pantalla),
    contiene(Pantalla, "Fin de la partida.").

test(menu_y_salir, true) :-
    con_entrada("1\nsalir\n", aventura, Salida),
    string_concat("1. Partida nueva", _, Salida),
    ultima_pantalla(Salida, Pantalla),
    contiene(Pantalla, "Fin de la partida.").

:- end_tests(aventura).
