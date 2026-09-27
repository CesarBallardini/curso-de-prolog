:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo terminal: el juego en la
% terminal (capítulo 28).
%
% Muestra el tablero, lee una jugada por línea y la aplica con el módulo
% partida, hasta que la partida termina. Las jugadas son d F C (descubrir),
% m F C (marcar) y ? (pedir una celda segura al resolvedor). Lee de un
% stream, y las pruebas juegan partidas enteras con las jugadas en una
% cadena.
%
% solo-local: SWISH no admite módulos propios ni lee del teclado.
%
%?- partida_con_minas(3, 3, [1-1], P), mostrar(P, false).

:- module(terminal,
          [ jugar_en_terminal/3,
            mostrar/2,
            jugada//1
          ]).

:- use_module(library(readutil)).
:- use_module(library(dcg/basics)).
:- use_module(partida).

%!  jugar_en_terminal(+In, +Partida0, -Estado:atom) is det.
%
%   Muestra Partida0, lee jugadas de In y las aplica hasta que la partida
%   termina. Estado es gano o perdio.
%
%   @error existence_error(jugada, fin_de_la_entrada) si In se termina antes.
jugar_en_terminal(In, Partida0, Estado) :-
    estado(Partida0, Estado0),
    (   Estado0 == sigue
    ->  mostrar(Partida0, false),
        leer_jugada(In, Jugada),
        responder(Jugada, Partida0, Partida),
        jugar_en_terminal(In, Partida, Estado)
    ;   mostrar(Partida0, true),
        mensaje_final(Estado0),
        Estado = Estado0
    ).

%!  leer_jugada(+In, -Jugada) is det.
%
%   Jugada es la jugada de la línea siguiente de In, o no_valida.
leer_jugada(In, Jugada) :-
    format("Jugada (d F C, m F C, ?): "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  existence_error(jugada, fin_de_la_entrada)
    ;   string_codes(Linea, Codigos),
        (   phrase(jugada(J), Codigos)
        ->  Jugada = J
        ;   Jugada = no_valida
        )
    ).

%!  jugada(-Jugada)// is semidet.
%
%   Una jugada: d F C, m F C o ?.
jugada(Jugada) -->
    blanks,
    orden(Accion),
    blanks,
    integer(F),
    blanks,
    integer(C),
    blanks,
    { Jugada = jugar(Accion, F-C) }.
jugada(sugerencia) -->
    blanks,
    "?",
    blanks.

%!  orden(-Accion:atom)// is semidet.
%
%   La letra de una acción.
orden(descubrir) --> "d".
orden(marcar) --> "m".

%!  responder(+Jugada, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de Jugada; una jugada imposible se informa
%   y deja la partida como estaba.
responder(no_valida, Partida, Partida) :-
    format("Jugada no válida.~n").
responder(sugerencia, Partida, Partida) :-
    (   sugerencia(Partida, F-C)
    ->  format("Sugerencia: d ~w ~w~n", [F, C])
    ;   format("No hay ninguna celda segura a la vista.~n")
    ).
responder(jugar(Accion, Celda), Partida0, Partida) :-
    catch(jugar(Accion, Celda, Partida0, Partida),
          error(domain_error(celda_del_tablero, _), _),
          ( format("La celda está fuera del tablero.~n"),
            Partida = Partida0 )).

%!  mensaje_final(+Estado:atom) is det.
%
%   Escribe el resultado de la partida.
mensaje_final(gano) :-
    format("Todas las celdas libres están descubiertas: partida ganada.~n").
mensaje_final(perdio) :-
    format("La celda tenía una mina: partida perdida.~n").

%!  mostrar(+Partida, +Minas:boolean) is det.
%
%   Escribe el tablero con los números de fila y de columna, y las minas que
%   quedan por marcar.
mostrar(Partida, Minas) :-
    dimensiones(Partida, _, Columnas),
    numlist(1, Columnas, Numeros),
    fila_de_texto('', Numeros, Encabezado),
    writeln(Encabezado),
    filas(Partida, Minas, Filas),
    forall(nth1(F, Filas, Fila),
           ( string_chars(Fila, Simbolos),
             fila_de_texto(F, Simbolos, Texto),
             writeln(Texto) )),
    minas_restantes(Partida, Restantes),
    format("Minas sin marcar: ~d~n", [Restantes]).

%!  fila_de_texto(+Rotulo, +Simbolos:list, -Fila:atom) is det.
%
%   Fila es Rotulo seguido de Simbolos, cada uno en tres columnas.
fila_de_texto(Rotulo, Simbolos, Fila) :-
    maplist([S, A]>>format(atom(A), "~t~w~3|", [S]), [Rotulo|Simbolos],
            Columnas),
    atomic_list_concat(Columnas, Fila).
