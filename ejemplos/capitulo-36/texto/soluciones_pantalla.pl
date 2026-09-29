:- encoding(utf8).

% Capítulo 36 - Soluciones de los ejercicios 2, 3 y 4: caja/3 con líneas de
% color, más teclas en leer_tecla/2, y dos recuadros lado a lado.
%
% El módulo repite de pantalla.pl lo que cambia, para cargarse solo: caja/3,
% que ahora mide el texto visible, y leer_tecla/2, que conoce Inicio, Fin,
% Suprimir y la tecla de borrar (esta última la usa el ejercicio 6).
%
% solo-local: SWISH no admite módulos propios.
%
%?- largo_visible("\e[31m*\e[0m", N).

:- module(soluciones_pantalla,
          [ largo_visible/2,
            caja/3,
            leer_tecla/2,
            lado_a_lado/3
          ]).

:- meta_predicate
    leer_tecla(1, -).

% --- Ejercicio 2 ------------------------------------------------------------

%!  largo_visible(+Texto:string, -N:integer) is det.
%
%   N es la cantidad de caracteres de Texto que se ven: no cuenta las
%   secuencias de escape de atributos, \e[ ... m.
largo_visible(Texto, N) :-
    string_codes(Texto, Codigos),
    phrase(visibles(Visibles), Codigos),
    length(Visibles, N).

%!  visibles(-Codigos:list)// is det.
%
%   Codigos son los códigos de la entrada fuera de las secuencias \e[ ... m.
visibles(Codigos) -->
    [27, 0'[],
    !,
    hasta_la_m,
    visibles(Codigos).
visibles([C|Codigos]) -->
    [C],
    !,
    visibles(Codigos).
visibles([]) -->
    [].

%!  hasta_la_m// is semidet.
%
%   Consume los códigos de una secuencia de atributos hasta la m final.
hasta_la_m -->
    [0'm],
    !.
hasta_la_m -->
    [_],
    hasta_la_m.

%!  caja(+Titulo:string, +Lineas:list(string), -Caja:list(string)) is det.
%
%   Como caja/3 de pantalla.pl, pero el ancho y el relleno de cada línea se
%   calculan con largo_visible/2: una línea con colores queda alineada.
caja(Titulo, Lineas, [Arriba|Medio]) :-
    string_length(Titulo, LargoTitulo),
    maplist(largo_visible, Lineas, Largos),
    Minimo is LargoTitulo + 1,
    max_list([Minimo|Largos], Ancho),
    borde_superior(Titulo, LargoTitulo, Ancho, Arriba),
    maplist(interior(Ancho), Lineas, Interiores),
    Relleno is Ancho + 2,
    repetir("─", Relleno, Raya),
    atomics_to_string(["└", Raya, "┘"], Abajo),
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
%   Linea es Texto entre bordes, con blancos hasta Ancho caracteres
%   visibles.
interior(Ancho, Texto, Linea) :-
    largo_visible(Texto, Largo),
    Faltan is Ancho - Largo,
    repetir(" ", Faltan, Blancos),
    atomics_to_string(["│ ", Texto, Blancos, " │"], Linea).

%!  repetir(+Texto:string, +N:integer, -Repetido:string) is det.
%
%   Repetido es Texto escrito N veces.
repetir(Texto, N, Repetido) :-
    length(Copias, N),
    maplist(=(Texto), Copias),
    atomics_to_string(Copias, Repetido).

% --- Ejercicio 3 ------------------------------------------------------------

%!  leer_tecla(:Siguiente, -Tecla) is det.
%
%   Como leer_tecla/2 de pantalla.pl, con las teclas inicio, final,
%   suprimir y borrar.
leer_tecla(Siguiente, Tecla) :-
    call(Siguiente, Codigo),
    tecla(Codigo, Siguiente, Tecla).

%!  tecla(+Codigo:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la que empieza con Codigo. Una secuencia de escape pide dos
%   códigos más a Siguiente; si el segundo es un dígito, como en \e[3~,
%   pide uno más.
tecla(27, Siguiente, Tecla) :-
    !,
    call(Siguiente, C1),
    call(Siguiente, C2),
    secuencia(C1, C2, Siguiente, Tecla).
tecla(13, _, enter) :-
    !.
tecla(10, _, enter) :-
    !.
tecla(32, _, espacio) :-
    !.
tecla(127, _, borrar) :-
    !.
tecla(8, _, borrar) :-
    !.
tecla(-1, _, fin) :-
    !.
tecla(Codigo, _, letra(L)) :-
    code_type(Codigo, graph),
    !,
    char_code(L, Codigo).
tecla(_, _, otra).

%!  secuencia(+C1:integer, +C2:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la de la secuencia ESC C1 C2, que puede seguir con ~.
secuencia(0'[, C2, Siguiente, Tecla) :-
    code_type(C2, digit),
    !,
    call(Siguiente, C3),
    (   C3 == 0'~,
        con_tilde(C2, T)
    ->  Tecla = T
    ;   Tecla = otra
    ).
secuencia(C1, C2, _, Tecla) :-
    (   escape(C1, C2, T)
    ->  Tecla = T
    ;   Tecla = otra
    ).

% escape(C1, C2, Tecla): la secuencia ESC C1 C2 es Tecla.
escape(0'[, 0'A, arriba).
escape(0'[, 0'B, abajo).
escape(0'[, 0'C, derecha).
escape(0'[, 0'D, izquierda).
escape(0'[, 0'H, inicio).
escape(0'[, 0'F, final).

% con_tilde(C, Tecla): la secuencia ESC [ C ~ es Tecla.
con_tilde(0'3, suprimir).

% --- Ejercicio 4 ------------------------------------------------------------

%!  lado_a_lado(+Caja1:list(string), +Caja2:list(string),
%!              -Lineas:list(string)) is det.
%
%   Lineas pone Caja2 a la derecha de Caja1, separadas por dos espacios. La
%   caja más corta se completa con líneas en blanco de su ancho. Las dos
%   cajas tienen al menos una línea.
lado_a_lado(Caja1, Caja2, Lineas) :-
    length(Caja1, N1),
    length(Caja2, N2),
    N is max(N1, N2),
    completar(Caja1, N, Completa1),
    completar(Caja2, N, Completa2),
    maplist([A, B, L]>>atomics_to_string([A, "  ", B], L),
            Completa1, Completa2, Lineas).

%!  completar(+Caja:list(string), +N:integer, -Completa:list(string)) is det.
%
%   Completa es Caja con líneas en blanco al final hasta tener N líneas.
completar([Primera|Resto], N, Completa) :-
    string_length(Primera, Ancho),
    length([Primera|Resto], M),
    Faltan is N - M,
    repetir(" ", Ancho, Blanco),
    length(Blancos, Faltan),
    maplist(=(Blanco), Blancos),
    append([Primera|Resto], Blancos, Completa).
