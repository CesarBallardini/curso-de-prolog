:- encoding(utf8).

% Capítulo 74 - Versión 2: el cubo a la vista.
%
% red/2 arma, sin escribir nada, las líneas del cubo desplegado en forma
% de cruz: la cara u arriba, las caras l, f, r y b en una fila y la cara
% d abajo, cada casilla con la letra de su cara en mayúscula. caja/3, del
% módulo pantalla del capítulo 36, la encierra en un recuadro, y
% mostrar/1 es el único predicado que escribe. Las secuencias se leen y
% se escriben en la notación de Singmaster: una letra por cara, un
% apóstrofo para el giro inverso y un 2 para la media vuelta. mezcla/3
% genera una mezcla reproducible a partir de una semilla.
%
% solo-local: carga cubo.pl y el módulo pantalla del capítulo 36.
%
%?- mostrar_giros("R U R' U'").
%?- leer_notacion("F2 U' R", Ms).
%?- mezcla(7, 6, Ms), escribir_notacion(Ms, T).

:- ensure_loaded(cubo).
:- use_module('../capitulo-36/texto/pantalla', [caja/3]).

% --- El cubo desplegado ----------------------------------------------------

%!  red(+Cubo, -Lineas:list(string)) is det.
%
%   Lineas es el cubo desplegado en cruz, una fila de casillas por línea.
red(Cubo, Lineas) :-
    findall(L, ( between(0, 2, F), fila_sola(Cubo, u, F, L) ), Arriba),
    findall(L, ( between(0, 2, F), fila_media(Cubo, F, L) ), Medio),
    findall(L, ( between(0, 2, F), fila_sola(Cubo, d, F, L) ), Abajo),
    append([Arriba, Medio, Abajo], Lineas).

%!  fila_sola(+Cubo, +Cara, +F:integer, -Linea:string) is det.
%
%   Linea es la fila F de Cara, corrida a la altura de la cara f.
fila_sola(Cubo, Cara, F, Linea) :-
    fila(Cubo, Cara, F, Fila),
    string_concat("       ", Fila, Linea).

%!  fila_media(+Cubo, +F:integer, -Linea:string) is det.
%
%   Linea es la fila F de las caras l, f, r y b, una al lado de la otra.
fila_media(Cubo, F, Linea) :-
    maplist(fila(Cubo), [l, f, r, b], [F, F, F, F], Filas),
    atomic_list_concat(Filas, '  ', Atomo),
    atom_string(Atomo, Linea).

%!  fila(+Cubo, +Cara, +F:integer, -Fila:string) is det.
%
%   Fila son las tres casillas de la fila F de Cara, en mayúsculas.
fila(Cubo, Cara, F, Fila) :-
    cara(Cara, K, _),
    findall(Letra,
            ( between(0, 2, C),
              I is 9 * K + 3 * F + C + 1,
              arg(I, Cubo, Color),
              upcase_atom(Color, Letra) ),
            Letras),
    atomic_list_concat(Letras, ' ', Atomo),
    atom_string(Atomo, Fila).

%!  mostrar(+Cubo) is det.
%
%   Escribe Cubo desplegado, dentro de un recuadro.
mostrar(Cubo) :-
    red(Cubo, Lineas),
    caja("", Lineas, Caja),
    forall(member(Linea, Caja), writeln(Linea)).

% --- La notación de Singmaster ---------------------------------------------

%!  leer_notacion(+Texto, -Movimientos:list) is semidet.
%
%   Movimientos son los giros escritos en Texto, separados por blancos:
%   "R" es r, "R'" es -r y "R2" es r, r. Falla si Texto no está en la
%   notación.
leer_notacion(Texto, Movimientos) :-
    string_codes(Texto, Codigos),
    phrase(escritos(Grupos), Codigos),
    append(Grupos, Movimientos).

%!  escritos(-Gs:list)// is det.
%
%   Gs son los grupos de movimientos de los giros escritos, separados por
%   blancos.
escritos([G|Gs]) --> blancos, escrito(G), !, escritos(Gs).
escritos([]) --> blancos.

%!  escrito(-Ms:list)// is semidet.
%
%   Ms son los movimientos de un giro: la letra de una cara y su sufijo.
escrito(Ms) --> [C], { letra_cara(C, Cara) }, sufijo(Cara, Ms).

%!  sufijo(+Cara, -Ms:list)// is det.
%
%   Ms son los movimientos de Cara según el sufijo: apóstrofo, el giro
%   inverso; 2, dos giros; sin sufijo, uno.
sufijo(Cara, [-Cara]) --> "'", !.
sufijo(Cara, [Cara, Cara]) --> "2", !.
sufijo(Cara, [Cara]) --> [].

%!  blancos// is det.
%
%   Consume los blancos que siguen.
blancos --> " ", !, blancos.
blancos --> [].

%!  letra_cara(?Codigo, ?Cara) is nondet.
%
%   Codigo es la letra mayúscula de Cara en la notación.
letra_cara(Codigo, Cara) :-
    cara(Cara, _, _),
    upcase_atom(Cara, Letra),
    char_code(Letra, Codigo).

%!  escribir_notacion(+Movimientos:list, -Texto:string) is det.
%
%   Texto es Movimientos en la notación; dos cuartos de vuelta seguidos
%   de la misma cara se escriben como una media vuelta.
escribir_notacion(Movimientos, Texto) :-
    agrupar(Movimientos, Palabras),
    atomic_list_concat(Palabras, ' ', Atomo),
    atom_string(Atomo, Texto).

%!  agrupar(+Movimientos:list, -Palabras:list(atom)) is det.
%
%   Palabras es Movimientos en la notación, un giro por palabra.
agrupar([], []).
agrupar([M, M|Ms], [P|Ps]) :-
    !,
    cara_de(M, Cara),
    upcase_atom(Cara, Letra),
    atom_concat(Letra, '2', P),
    agrupar(Ms, Ps).
agrupar([-Cara|Ms], [P|Ps]) :-
    !,
    upcase_atom(Cara, Letra),
    atom_concat(Letra, '''', P),
    agrupar(Ms, Ps).
agrupar([Cara|Ms], [Letra|Ps]) :-
    upcase_atom(Cara, Letra),
    agrupar(Ms, Ps).

%!  cara_de(+Movimiento, -Cara) is det.
%
%   Cara es la cara que gira Movimiento.
cara_de(-Cara, Cara) :-
    !.
cara_de(Cara, Cara).

% --- Mezclas reproducibles --------------------------------------------------

%!  mezcla(+Semilla:integer, +N:integer, -Movimientos:list) is det.
%
%   Movimientos son N giros elegidos al azar a partir de Semilla, sin dos
%   giros seguidos de la misma cara.
mezcla(Semilla, N, Movimientos) :-
    mezcla(N, ninguna, Semilla, Movimientos).

%!  mezcla(+N:integer, +Anterior, +S:integer, -Movimientos:list) is det.
%
%   Movimientos son N giros al azar desde el estado S del generador; el
%   primero no gira la cara Anterior.
mezcla(0, _, _, []) :-
    !.
mezcla(N, Anterior, S0, [M|Ms]) :-
    findall(G, ( cara(Cara, _, _), Cara \== Anterior,
                 member(G, [Cara, -Cara]) ), Giros),
    length(Giros, L),
    azar(L, K, S0, S),
    nth0(K, Giros, M),
    cara_de(M, Cara),
    N1 is N - 1,
    mezcla(N1, Cara, S, Ms).

%!  azar(+N:integer, -K:integer, +S0:integer, -S:integer) is det.
%
%   K es un entero entre 0 y N - 1 obtenido del estado S0 de un generador
%   congruencial lineal; S es el estado siguiente.
azar(N, K, S0, S) :-
    S is (1103515245 * S0 + 12345) mod 2147483648,
    K is (S >> 16) mod N.

%!  mostrar_giros(+Texto) is semidet.
%
%   Escribe el cubo resuelto con los giros de Texto aplicados. Falla si
%   Texto no está en la notación.
mostrar_giros(Texto) :-
    leer_notacion(Texto, Movimientos),
    resuelto(C),
    aplicar(Movimientos, C, C1),
    mostrar(C1).
