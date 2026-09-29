:- encoding(utf8).

% Capítulo 36 - Módulo pantalla: lo mínimo para una interfaz de pantalla
% completa en la terminal.
%
% caja/3 es puro: arma las líneas de un recuadro. dibujar/1 es el único
% predicado que escribe en la pantalla, con secuencias de escape ANSI.
% leer_tecla/2 lee una tecla de una fuente de códigos, que es el teclado en
% el programa y un stream sobre una cadena en las pruebas.
%
% solo-local: SWISH no admite módulos propios ni tiene una terminal.
%
%?- caja("Hola", ["uno", "dos"], Lineas).

:- module(pantalla,
          [ caja/3,
            dibujar/1,
            limpiar/0,
            ir_a/2,
            leer_tecla/2,
            tamanio/2,
            con_pantalla/1
          ]).

:- meta_predicate
    leer_tecla(1, -),
    con_pantalla(0).

%!  caja(+Titulo:string, +Lineas:list(string), -Caja:list(string)) is det.
%
%   Caja son las líneas de un recuadro con Titulo en el borde superior y
%   Lineas adentro, alineadas a la izquierda.
caja(Titulo, Lineas, [Arriba|Medio]) :-
    string_length(Titulo, LargoTitulo),
    maplist(string_length, Lineas, Largos),
    Minimo is LargoTitulo + 1,
    max_list([Minimo|Largos], Ancho),
    borde_superior(Titulo, LargoTitulo, Ancho, Arriba),
    maplist(interior(Ancho), Lineas, Interiores),
    Relleno is Ancho + 2,
    repetir("─", Relleno, Raya),
    string_concat("└", Raya, Abajo0),
    string_concat(Abajo0, "┘", Abajo),
    append(Interiores, [Abajo], Medio).

%!  borde_superior(+Titulo, +LargoTitulo, +Ancho, -Linea:string) is det.
%
%   Linea es el borde superior de una caja de Ancho, con el título.
borde_superior("", _, Ancho, Linea) :-
    !,
    Relleno is Ancho + 2,
    repetir("─", Relleno, Raya),
    atomics_to_string(["┌", Raya, "┐"], Linea).
borde_superior(Titulo, LargoTitulo, Ancho, Linea) :-
    Relleno is Ancho - LargoTitulo - 1,
    repetir("─", Relleno, Raya),
    atomics_to_string(["┌─ ", Titulo, " ", Raya, "┐"], Linea).

%!  interior(+Ancho:integer, +Texto:string, -Linea:string) is det.
%
%   Linea es Texto completado con blancos hasta Ancho, entre bordes.
interior(Ancho, Texto, Linea) :-
    Columna is Ancho + 2,
    format(string(Linea), "│ ~w~t~*| │", [Texto, Columna]).

%!  repetir(+Texto:string, +N:integer, -Repetido:string) is det.
%
%   Repetido es Texto escrito N veces.
repetir(Texto, N, Repetido) :-
    length(Copias, N),
    maplist(=(Texto), Copias),
    atomics_to_string(Copias, Repetido).

%!  limpiar is det.
%
%   Borra la pantalla y lleva el cursor a la esquina superior izquierda.
limpiar :-
    format("\e[2J\e[H").

%!  ir_a(+Fila:integer, +Columna:integer) is det.
%
%   Lleva el cursor a Fila y Columna, contadas desde 1.
ir_a(Fila, Columna) :-
    format("\e[~d;~dH", [Fila, Columna]).

%!  dibujar(+Lineas:list(string)) is det.
%
%   Borra la pantalla y escribe Lineas desde la primera fila, cada una en
%   su fila.
dibujar(Lineas) :-
    limpiar,
    forall(nth1(Fila, Lineas, Linea),
           ( ir_a(Fila, 1),
             write(Linea) )),
    flush_output.

%!  con_pantalla(:Objetivo) is semidet.
%
%   Ejecuta Objetivo con el cursor oculto, y al terminar, de cualquier
%   manera, lo vuelve a mostrar debajo de lo dibujado.
con_pantalla(Objetivo) :-
    setup_call_cleanup(format("\e[?25l"),
                       Objetivo,
                       format("\e[?25h~n")).

%!  leer_tecla(:Siguiente, -Tecla) is det.
%
%   Tecla es la tecla que llega por Siguiente, un predicado que da un
%   código por llamada: arriba, abajo, izquierda, derecha, enter, espacio,
%   letra(L), fin si la entrada se terminó, u otra.
leer_tecla(Siguiente, Tecla) :-
    call(Siguiente, Codigo),
    tecla(Codigo, Siguiente, Tecla).

%!  tecla(+Codigo:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la que empieza con Codigo; una secuencia de escape pide dos
%   códigos más a Siguiente.
tecla(27, Siguiente, Tecla) :-
    !,
    call(Siguiente, C1),
    call(Siguiente, C2),
    (   flecha(C1, C2, Flecha)
    ->  Tecla = Flecha
    ;   Tecla = otra
    ).
tecla(13, _, enter) :-
    !.
tecla(10, _, enter) :-
    !.
tecla(32, _, espacio) :-
    !.
tecla(-1, _, fin) :-
    !.
tecla(Codigo, _, letra(L)) :-
    code_type(Codigo, graph),
    !,
    char_code(L, Codigo).
tecla(_, _, otra).

% flecha(C1, C2, Tecla): la secuencia ESC C1 C2 es la flecha Tecla.
flecha(0'[, 0'A, arriba).
flecha(0'[, 0'B, abajo).
flecha(0'[, 0'C, derecha).
flecha(0'[, 0'D, izquierda).

%!  tamanio(-Filas:integer, -Columnas:integer) is det.
%
%   Filas y Columnas son el tamaño de la terminal, o 24 y 80 si la salida
%   no es una terminal.
tamanio(Filas, Columnas) :-
    catch(tty_size(Filas, Columnas), error(_, _),
          ( Filas = 24, Columnas = 80 )).
