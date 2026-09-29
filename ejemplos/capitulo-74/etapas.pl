:- encoding(utf8).

% Capítulo 74 - Versión 6: la solución por etapas.
%
% El cubo se arma por capas, de abajo hacia arriba, en cinco etapas de
% cuatro piezas cada una: la cruz de abajo, las esquinas de abajo, las
% aristas del medio, las aristas de arriba y las esquinas de arriba. Las
% piezas se colocan de a una. Para cada pieza se arma un criterio: un
% término c/54 con las casillas de las piezas ya colocadas y de la pieza
% nueva ligadas a su color, y las demás libres. Un cubo cumple el criterio
% si unifica con él. La búsqueda prueba secuencias de candidatos de la
% etapa, de menor a mayor longitud (la profundización iterativa del
% capítulo 40): cada candidato es un giro o una macro compilada, y
% aplicarlo es una unificación. Los candidatos de una misma familia se
% escriben una vez, para la pieza de adelante a la derecha, y se generan
% para las otras tres posiciones cambiando las letras de las caras: es
% girar el cubo entero sobre el eje vertical.
%
% solo-local: carga macros.pl.
%
%?- resolver_mezcla(7, 20, PorEtapa, Total).

:- ensure_loaded(macros).
:- use_module(capitulo40).

% --- Los candidatos de cada etapa -------------------------------------------

% familia(Etapa, Texto): la secuencia Texto es candidata en la etapa, en
% sus cuatro orientaciones.
familia(1, "U").
familia(1, "U'").
familia(1, "U2").
familia(1, "F").
familia(1, "F'").
familia(1, "F2").
familia(1, "D").
familia(1, "D'").
familia(1, "D2").
familia(2, "U").
familia(2, "U'").
familia(2, "U2").
familia(2, "R U R'").
familia(2, "F' U' F").
familia(2, "R U2 R' U' R U R'").
familia(3, "U").
familia(3, "U'").
familia(3, "U2").
familia(3, "U R U' R' U' F' U F").
familia(3, "U' F' U F U R U' R'").
familia(4, "U").
familia(4, "U'").
familia(4, "U2").
familia(4, "F R U R' U' F'").
familia(4, "R U R' U R U2 R'").
familia(5, "R U' L' U R' U' L U").
familia(5, "U' L' U R U' L U R'").
familia(5, "R' D' R D R' D' R D U D' R' D R D' R' D R U'").
familia(5, "U D' R' D R D' R' D R U' R' D' R D R' D' R D").
familia(5, "R' D' R D R' D' R D U2 D' R' D R D' R' D R U2").

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término generar_candidatos se reemplaza, al cargar, por un hecho
%   candidato(Etapa, Movimientos, Antes, Despues) por cada secuencia
%   distinta que dan las familias en las cuatro orientaciones, con la
%   secuencia ya compilada.
term_expansion(generar_candidatos, Hechos) :-
    findall(Etapa-Movimientos,
            ( familia(Etapa, Texto),
              leer_notacion(Texto, Movimientos0),
              between(0, 3, K),
              orientar(K, Movimientos0, Movimientos) ),
            Pares0),
    sort(Pares0, Pares),
    findall(candidato(Etapa, Movimientos, Antes, Despues),
            ( member(Etapa-Movimientos, Pares),
              compilar(Movimientos, Antes-Despues) ),
            Hechos).

%!  orientar(+K:integer, +Movimientos0:list, -Movimientos:list) is det.
%
%   Movimientos es Movimientos0 hecho con el cubo girado K cuartos de
%   vuelta sobre el eje vertical: cada cara lateral pasa a la de su
%   izquierda.
orientar(0, Movimientos, Movimientos) :-
    !.
orientar(K, Movimientos0, Movimientos) :-
    maplist(a_la_izquierda, Movimientos0, Movimientos1),
    K1 is K - 1,
    orientar(K1, Movimientos1, Movimientos).

%!  a_la_izquierda(+Movimiento, -Movimiento1) is det.
%
%   Movimiento1 gira la cara que queda a la izquierda de la que gira
%   Movimiento, visto desde arriba.
a_la_izquierda(-Cara, -Cara1) :-
    !,
    a_la_izquierda(Cara, Cara1).
a_la_izquierda(Cara, Cara1) :-
    izquierda(Cara, Cara1).

% izquierda(Cara, Cara1): visto desde arriba, Cara1 sigue a Cara al girar
% el cubo entero un cuarto de vuelta.
izquierda(f, l).
izquierda(l, b).
izquierda(b, r).
izquierda(r, f).
izquierda(u, u).
izquierda(d, d).

generar_candidatos.

% --- Las etapas y el criterio -----------------------------------------------

% etapa(Etapa, Piezas): las piezas que coloca la etapa, en orden.
etapa(1, ['DF', 'DR', 'DB', 'DL']).
etapa(2, ['DFR', 'DBR', 'DBL', 'DFL']).
etapa(3, ['FR', 'BR', 'BL', 'FL']).
etapa(4, ['UF', 'UR', 'UB', 'UL']).
etapa(5, ['UFR', 'UBR', 'UBL', 'UFL']).

% nombre_etapa(Etapa, Nombre): lo que arma la etapa.
nombre_etapa(1, "la cruz de abajo").
nombre_etapa(2, "las esquinas de abajo").
nombre_etapa(3, "las aristas del medio").
nombre_etapa(4, "las aristas de arriba").
nombre_etapa(5, "las esquinas de arriba").

%!  criterio(+Piezas:list(atom), -Criterio) is det.
%
%   Criterio es un término c/54 con las casillas de Piezas ligadas al
%   color del cubo resuelto y las demás libres.
criterio(Piezas, Criterio) :-
    functor(Criterio, c, 54),
    resuelto(Resuelto),
    maplist(casillas_de, Piezas, Listas),
    append(Listas, Casillas),
    maplist(copiar_casilla(Resuelto, Criterio), Casillas).

%!  casillas_de(+Nombre, -Casillas:list(integer)) is det.
%
%   Casillas son los números de las casillas de la pieza Nombre.
casillas_de(Nombre, Casillas) :-
    pieza(_, Nombre, Casillas).

%!  copiar_casilla(+Resuelto, +Criterio, +I:integer) is det.
%
%   La casilla I de Criterio queda ligada al color que tiene en Resuelto.
copiar_casilla(Resuelto, Criterio, I) :-
    arg(I, Resuelto, Color),
    arg(I, Criterio, Color).

% --- La búsqueda ---------------------------------------------------------

%!  resolver(+Cubo, -Pasos:list) is det.
%
%   Pasos es la lista de pasos(Etapa, Pieza, Movimientos) que arma Cubo,
%   pieza por pieza.
resolver(Cubo, Pasos) :-
    findall(E-P, ( etapa(E, Ps), member(P, Ps) ), Plan),
    colocar_todas(Plan, [], Cubo, Pasos).

%!  colocar_todas(+Plan:list, +Colocadas:list, +Cubo, -Pasos:list) is det.
%
%   Pasos coloca las piezas de Plan en Cubo, que ya tiene Colocadas.
colocar_todas([], _, _, []).
colocar_todas([Etapa-Pieza|Plan], Colocadas, Cubo,
              [paso(Etapa, Pieza, Movimientos)|Pasos]) :-
    Colocadas1 = [Pieza|Colocadas],
    criterio(Colocadas1, Criterio),
    colocar(Etapa, Cubo, Criterio, Movimientos, Cubo1),
    colocar_todas(Plan, Colocadas1, Cubo1, Pasos).

%!  colocar(+Etapa, +Cubo, +Criterio, -Movimientos:list, -Cubo1) is det.
%
%   Movimientos es una de las secuencias más cortas de candidatos de
%   Etapa que llevan Cubo a Cubo1, que cumple Criterio. La búsqueda es la
%   profundización iterativa del capítulo 40.
colocar(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    colocar_pieza(Etapa, Cubo, [Criterio], Plan),
    append(Plan, Movimientos),
    aplicar(Movimientos, Cubo, Cubo1).

%!  resolver_mezcla(+Semilla:integer, +Largo:integer, -PorEtapa:list,
%!                  -Total:integer) is det.
%
%   Resuelve la mezcla de Largo giros de Semilla. PorEtapa da, para cada
%   etapa E, un par E-N con los N cuartos de vuelta que usó; Total es la
%   suma. Si la solución no deja el cubo resuelto, lanza un error.
resolver_mezcla(Semilla, Largo, PorEtapa, Total) :-
    mezcla(Semilla, Largo, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    resolver(C1, Pasos),
    findall(E-N,
            ( etapa(E, _),
              aggregate_all(sum(L), ( member(paso(E, _, G), Pasos),
                                      length(G, L) ), N) ),
            PorEtapa),
    pairs_values(PorEtapa, Ns),
    sum_list(Ns, Total),
    findall(G, member(paso(_, _, G), Pasos), Gs),
    append(Gs, Todos),
    aplicar(Todos, C1, C2),
    (   C2 == C
    ->  true
    ;   domain_error(cubo_resuelto, C2)
    ).
