:- encoding(utf8).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module('../../capitulo-31/buscaminas/partida').

:- begin_tests(buscaminas_xpce).

% Las pruebas del núcleo corren en cualquier Prolog. Las de la ventana
% necesitan XPCE: corren en swipl-win y se omiten en la consola swipl.

%!  hay_xpce is semidet.
%
%   XPCE está disponible y puede crear objetos.
hay_xpce :-
    exists_source(library(pce)),
    catch(get(@(pce), version, _), _, fail).

%!  miembro(+Ventana, +Nombre:atom, -Objeto) is semidet.
%
%   Objeto es el elemento Nombre de uno de los dos diálogos de Ventana.
miembro(Ventana, Nombre, Objeto) :-
    member(Dialogo, [controles, tablero]),
    get(Ventana, member, Dialogo, D),
    get(D, member, Nombre, Objeto),
    !.

%!  pulsar_boton(+Ventana, +F:integer, +C:integer) is det.
%
%   Ejecuta el botón de la celda F-C, como un clic.
pulsar_boton(Ventana, F, C) :-
    format(atom(Nombre), "c_~d_~d", [F, C]),
    miembro(Ventana, Nombre, B),
    send(B, execute).

test(niveles, true(N == [principiante-81, intermedio-256, experto-480])) :-
    findall(Nivel-Celdas,
            ( nivel(Nivel, F, C, _), Celdas is F * C ),
            N).

test(vista, true(V == [celda(1, 1, 'M', on), celda(1, 2, '', on),
                       celda(2, 1, '1', off), celda(2, 2, '', on)])) :-
    partida_con_minas(2, 2, [1-2], P0),
    jugar(marcar, 1-1, P0, P1),
    jugar(descubrir, 2-1, P1, P),
    vista(P, V).

test(clic_en_partida_terminada, true(P == P1)) :-
    partida_con_minas(3, 3, [1-1], P0),
    clic(descubrir, 1-1, P0, P1),
    clic(descubrir, 3-3, P1, P).

test(rotulos, true(R == ["Minas sin marcar: 1", "Partida ganada",
                         "Partida perdida"])) :-
    partida_con_minas(3, 3, [1-1], P0),
    clic(descubrir, 3-3, P0, P1),
    clic(descubrir, 1-1, P0, P2),
    maplist(rotulo, [P0, P1, P2], R).

% Un clic en una partida que sigue la cambia como jugar/4.
test(clic_en_juego, true(F == ["M##", "###", "###"])) :-
    partida_con_minas(3, 3, [1-1], P0),
    clic(marcar, 1-1, P0, P),
    filas(P, false, F).

% Con la partida perdida, la vista muestra la mina; las celdas ocultas
% siguen como botones, pero clic/4 ya no cambia la partida.
test(vista_perdida, true(V == [celda(1, 1, '*', off), celda(1, 2, '', on),
                               celda(2, 1, '', on), celda(2, 2, '', on)])) :-
    partida_con_minas(2, 2, [1-1], P0),
    clic(descubrir, 1-1, P0, P),
    vista(P, V).

test(ventana, [ condition(hay_xpce),
                cleanup(send(V, destroy)),
                true(E-R == ''-'Minas sin marcar: 1') ]) :-
    partida_con_minas(3, 3, [1-1], P),
    ventana_con_partida(P, V),
    miembro(V, c_1_1, B),
    get(B, label, E),
    miembro(V, estado, Rotulo),
    get(Rotulo, selection, R).

test(clic_gana, [ condition(hay_xpce),
                  cleanup(send(V, destroy)),
                  true(X == ['*', '1', 'Partida ganada', @(off)]) ]) :-
    partida_con_minas(3, 3, [1-1], P),
    ventana_con_partida(P, V),
    pulsar_boton(V, 3, 3),
    miembro(V, c_1_1, B11),
    miembro(V, c_1_2, B12),
    miembro(V, estado, Rotulo),
    get(B11, label, E11),
    get(B12, label, E12),
    get(Rotulo, selection, R),
    get(B12, active, A12),
    X = [E11, E12, R, A12].

test(clic_marca, [ condition(hay_xpce),
                   cleanup(send(V, destroy)),
                   true(X == ['M', 'Minas sin marcar: 0']) ]) :-
    partida_con_minas(3, 3, [1-1], P),
    ventana_con_partida(P, V),
    miembro(V, accion, Menu),
    send(Menu, selection, marcar),
    pulsar_boton(V, 1, 1),
    miembro(V, c_1_1, B),
    get(B, label, E),
    miembro(V, estado, Rotulo),
    get(Rotulo, selection, R),
    X = [E, R].

% Crear el frame sin abrirlo ubica los botones: la celda 1-2 queda a la
% derecha de la 1-1, y la 2-1 debajo de ella.
test(grilla, [ condition(hay_xpce),
               cleanup(send(V, destroy)),
               true(X == [mismo_y, a_la_derecha, debajo]) ]) :-
    nivel(experto, F, C, N),
    tablero_de_prueba(F, C, N, P),
    ventana_con_partida(P, V),
    send(V, create),
    maplist(posicion(V), [c_1_1, c_1_2, c_2_1], [X11-Y11, X12-Y12, X21-Y21]),
    X = [ Y1, D, A ],
    ( Y11 =:= Y12 -> Y1 = mismo_y ; Y1 = otro_y ),
    ( X12 > X11 -> D = a_la_derecha ; D = otro_lado ),
    ( Y21 > Y11, X21 =:= X11 -> A = debajo ; A = otro_lugar ).

% Después de un clic, los botones conservan el ancho de la grilla, y la
% ventana del nivel experto cabe en una pantalla de 1024 píxeles de ancho.
test(ancho, [ condition(hay_xpce),
              cleanup(send(V, destroy)),
              true(A-Cabe == 30-si) ]) :-
    nivel(experto, F, C, N),
    tablero_de_prueba(F, C, N, P),
    ventana_con_partida(P, V),
    send(V, create),
    pulsar_boton(V, 16, 30),
    miembro(V, c_16_30, B),
    get(B, width, A),
    get(V, area, area(_, _, Ancho, _)),
    (   Ancho =< 1024
    ->  Cabe = si
    ;   Cabe = no
    ).

%!  tablero_de_prueba(+F, +C, +N, -Partida) is det.
%
%   Partida tiene F filas, C columnas y N minas en las primeras celdas.
tablero_de_prueba(F, C, N, Partida) :-
    findall(Fi-Co, ( between(1, F, Fi), between(1, C, Co) ), Celdas),
    length(Minas, N),
    append(Minas, _, Celdas),
    partida_con_minas(F, C, Minas, Partida).

%!  posicion(+Ventana, +Nombre:atom, -Posicion:pair) is det.
%
%   Posicion es X-Y, la esquina del elemento Nombre en su diálogo.
posicion(Ventana, Nombre, X-Y) :-
    miembro(Ventana, Nombre, B),
    get(B, x, X),
    get(B, y, Y).

:- end_tests(buscaminas_xpce).
