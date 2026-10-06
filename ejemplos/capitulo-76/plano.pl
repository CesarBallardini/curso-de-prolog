:- encoding(utf8).

% Capítulo 76 - Versión 1: el plano del robot.
%
% Un plano es un dibujo: una lista de filas, cada una un átomo con un
% carácter por celda, '.' para una celda libre y '#' para una ocupada. La
% celda X-Y está en la columna X y en la fila Y, contadas desde 1 a partir
% de la esquina de arriba a la izquierda. El robot va de una celda libre a
% una vecina libre en una de las cuatro direcciones, nunca en diagonal.
%
% Las búsquedas preguntan miles de veces si una celda está libre. Para no
% recorrer el dibujo en cada pregunta, term_expansion/2 (capítulo 35)
% convierte al cargar el archivo cada hecho plano/2 en hechos libre/3, uno
% por celda libre, y un hecho medidas/3; la búsqueda consulta esos hechos,
% que SWI-Prolog indexa.
%
% solo-local: usa term_expansion/2, que SWISH no permite.
%
%?- medidas(taller, Ancho, Alto).
%?- vecina(taller, 1-1, Direccion, Celda).
%?- mostrar(taller, [2-4, 3-4, 4-4]).

:- module(plano,
          [ plano/2,
            medidas/3,
            libre/3,
            vecina/4,
            lineas/3,
            mostrar/2
          ]).

% Cada plano agrega cláusulas a los tres predicados, intercaladas.
:- discontiguous plano/2, medidas/3, libre/3.

%!  term_expansion(+Hecho, -Clausulas:list) is semidet.
%
%   Clausulas son el hecho plano(Nombre, Filas), un hecho
%   medidas(Nombre, Ancho, Alto) y un hecho libre(Nombre, X, Y) por cada
%   celda libre del dibujo. Falla con cualquier otro término, que se carga
%   sin cambios.
term_expansion(plano(Nombre, Filas), [plano(Nombre, Filas),
                                      medidas(Nombre, Ancho, Alto)
                                     | Libres]) :-
    length(Filas, Alto),
    Filas = [Primera|_],
    atom_length(Primera, Ancho),
    findall(libre(Nombre, X, Y),
            ( nth1(Y, Filas, Fila),
              sub_atom(Fila, Antes, 1, _, '.'),
              X is Antes + 1 ),
            Libres).
term_expansion(plano(Nombre, Ancho, Alto, Bloques), Clausulas) :-
    dibujo(Ancho, Alto, Bloques, Filas),
    term_expansion(plano(Nombre, Filas), Clausulas).

%!  dibujo(+Ancho:integer, +Alto:integer, +Bloques:list, -Filas:list)
%!      is det.
%
%   Filas es el dibujo de un plano de Ancho x Alto celdas en el que están
%   ocupadas las celdas de los rectángulos de Bloques, cada uno
%   b(X1, Y1, X2, Y2) con sus esquinas opuestas.
dibujo(Ancho, Alto, Bloques, Filas) :-
    findall(Fila,
            ( between(1, Alto, Y),
              findall(C,
                      ( between(1, Ancho, X),
                        (   ocupada(Bloques, X, Y)
                        ->  C = '#'
                        ;   C = '.'
                        ) ),
                      Cs),
              atom_chars(Fila, Cs) ),
            Filas).

%!  ocupada(+Bloques:list, +X:integer, +Y:integer) is semidet.
%
%   La celda X-Y está dentro de uno de los rectángulos de Bloques.
ocupada(Bloques, X, Y) :-
    member(b(X1, Y1, X2, Y2), Bloques),
    between(X1, X2, X),
    between(Y1, Y2, Y),
    !.

% plano(Nombre, Filas): el dibujo del plano Nombre, fila por fila.
plano(taller,
      [ '....................',
        '..####......####....',
        '..####......####....',
        '..........#.........',
        '######....#....#####',
        '..........#.........',
        '...####...#..####...',
        '...####......####...',
        '....................',
        '....................'
      ]).
plano(galpon,
      [ '..............................',
        '.#####.#####.#####.#####.####.',
        '.#.........#.....#.....#....#.',
        '.#.#######.#.###.#.###.#.##.#.',
        '.#.#.....#.#.#...#...#.#..#.#.',
        '.#.#.###.#.#.#.#####.#.##.#.#.',
        '.#.#.#.#.#...#.....#.#....#.#.',
        '.#.#.#.#.#####.###.#.######.#.',
        '.#...#.......#...#.#........#.',
        '.#####.#####.###.#.##########.',
        '.......#...#.....#............',
        '########.#.#######.##########.',
        '.........#.........#..........',
        '.#######.#########.#.########.',
        '.#.....#.........#.#.#......#.',
        '.#.###.#########.#.#.#.####.#.',
        '.#...#...........#...#....#.#.',
        '.###.###############.####.#.#.',
        '.....................#......#.',
        '##############################'
      ]).

% plano(Nombre, Ancho, Alto, Bloques): un plano dado por sus medidas y sus
% rectángulos ocupados; term_expansion/2 lo convierte en un dibujo.
plano(patio, 60, 40, [b(30, 5, 31, 40)]).
plano(bolsa, 60, 40, [b(20, 10, 40, 11), b(39, 10, 40, 30), b(20, 29, 40, 30)]).

%!  vecina(+Plano, +Celda, ?Direccion, -Vecina) is nondet.
%
%   Vecina es la celda libre de Plano que está junto a Celda en Direccion:
%   norte, sur, este u oeste.
vecina(Plano, X-Y, Direccion, X1-Y1) :-
    paso(Direccion, DX, DY),
    X1 is X + DX,
    Y1 is Y + DY,
    libre(Plano, X1, Y1).

% paso(Direccion, DX, DY): moverse en Direccion suma DX a la columna y DY
% a la fila; la fila 1 es la de arriba.
paso(norte, 0, -1).
paso(sur, 0, 1).
paso(este, 1, 0).
paso(oeste, -1, 0).

%!  lineas(+Plano, +Camino:list, -Lineas:list) is det.
%
%   Lineas son las filas del dibujo de Plano, como átomos, con un '*' en
%   cada celda de Camino.
lineas(Plano, Camino, Lineas) :-
    plano(Plano, Filas),
    findall(Linea,
            ( nth1(Y, Filas, Fila),
              linea(Fila, Y, Camino, Linea) ),
            Lineas).

%!  linea(+Fila, +Y:integer, +Camino:list, -Linea) is det.
%
%   Linea es Fila, la fila Y del dibujo, con un '*' en cada celda de Camino
%   que está en esa fila.
linea(Fila, Y, Camino, Linea) :-
    atom_chars(Fila, Cs0),
    findall(C,
            ( nth1(X, Cs0, C0),
              (   memberchk(X-Y, Camino)
              ->  C = '*'
              ;   C = C0
              ) ),
            Cs),
    atom_chars(Linea, Cs).

%!  mostrar(+Plano, +Camino:list) is det.
%
%   Escribe el dibujo de Plano con el Camino marcado, una fila por línea.
mostrar(Plano, Camino) :-
    lineas(Plano, Camino, Lineas),
    forall(member(L, Lineas), writeln(L)).
