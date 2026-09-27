:- encoding(utf8).

% Pruebas de la solución del ejercicio 14: el núcleo con un tablero fijo, la
% partida con las jugadas en una cadena, y el programa en otro proceso, con
% una semilla fija.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(soluciones_buscaminas).

%!  partida_con(+Tablero, +Jugadas:string, -Resultado, -Salida:string)
%!      is det.
%
%   Juega con Tablero, leyendo Jugadas; Salida es lo que escribió.
partida_con(Tablero, Jugadas, Resultado, Salida) :-
    setup_call_cleanup(
        open_string(Jugadas, In),
        with_output_to(string(Salida),
                       jugar(In, juego(Tablero, [], []), Resultado)),
        close(In)).

%!  correr(+Argumentos:list, +Entrada:string, -Estado) is det.
%
%   Ejecuta el programa con Argumentos y Entrada como teclado; Estado es
%   exit(Codigo).
correr(Argumentos, Entrada, Estado) :-
    source_file(user:jugar(_, _, _), Programa),
    process_create(path(swipl), [Programa|Argumentos],
                   [ stdin(pipe(In)), stdout(null), stderr(null),
                     process(Pid) ]),
    format(In, "~s", [Entrada]),
    close(In),
    process_wait(Pid, Estado).

% --- El núcleo -------------------------------------------------------------

% Un 3 × 3 con una mina en una esquina: descubrir la esquina opuesta
% descubre las ocho celdas libres.
test(descubrir_region, true(N == 8)) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 3-3, [], D),
    length(D, N).

test(descubrir_numero, true(D == [1-2])) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 1-2, [], D).

test(ganar, true(E == gano)) :-
    tablero(3, 3, [1-1], T),
    aplicar(descubrir(3-3), juego(T, [], []), _, E).

test(perder, true(E == perdio)) :-
    tablero(3, 3, [1-1], T),
    aplicar(descubrir(1-1), juego(T, [], []), _, E).

test(marcar_y_desmarcar, true(M1-M2 == [2-2]-[])) :-
    tablero(3, 3, [1-1], T),
    aplicar(marcar(2-2), juego(T, [], []), juego(_, _, M1), sigue),
    aplicar(marcar(2-2), juego(T, [], M1), juego(_, _, M2), sigue).

test(fuera_del_tablero, fail) :-
    tablero(3, 3, [1-1], T),
    aplicar(descubrir(4-1), juego(T, [], []), _, _).

test(jugadas, true(J == [descubrir(3-4), marcar(10-2)])) :-
    maplist([Texto, Jugada]>>( string_codes(Texto, Codigos),
                              phrase(jugada(Jugada), Codigos) ),
            ["d 3 4", "  m 10  2 "], J).

test(jugada_no_valida, fail) :-
    string_codes("x 1 1", Codigos),
    phrase(jugada(_), Codigos).

% --- La partida ------------------------------------------------------------

test(partida_ganada, true(R == gano)) :-
    tablero(3, 3, [1-1], T),
    partida_con(T, "d 3 3\n", R, _).

% Una jugada que no se entiende y una fuera del tablero no terminan la
% partida.
test(partida_perdida, true(R == perdio)) :-
    tablero(3, 3, [1-1], T),
    partida_con(T, "hola\nd 5 5\nd 1 1\n", R, S),
    once(sub_string(S, _, _, _, "Jugada no válida")),
    once(sub_string(S, _, _, _, "fuera del tablero")).

% Al terminar, el tablero completo, con la mina. El encabezado de columnas
% queda en la línea de la pregunta, porque la respuesta no se escribe.
test(tablero_al_final, true(Filas == [ "  1  *  1  .",
                                       "  2  1  1  .",
                                       "  3  .  .  ." ])) :-
    tablero(3, 3, [1-1], T),
    partida_con(T, "d 3 3\n", _, S),
    split_string(S, "\n", "", Lineas),
    once(append(_, [A, B, C, _Mensaje, ""], Lineas)),
    Filas = [A, B, C].

% --- El programa -----------------------------------------------------------

% Con la semilla 42, las minas de un 5 × 5 con 4 son 2-3, 3-2, 3-4 y 5-1.
test(programa_pierde, true(E == exit(1))) :-
    correr(['--semilla=42', '5', '5', '4'], "d 2 3\n", E).

% Con la semilla 42, la mina de un 2 × 2 con 1 está en 1-1.
test(programa_gana, true(E == exit(0))) :-
    correr(['--semilla=42', '2', '2', '1'], "d 1 2\nd 2 1\nd 2 2\n", E).

test(argumentos_de_mas_o_de_menos, true(E == exit(2))) :-
    correr(['5', '5'], "", E).

test(demasiadas_minas, true(E == exit(2))) :-
    correr(['2', '2', '4'], "", E).

:- end_tests(soluciones_buscaminas).
