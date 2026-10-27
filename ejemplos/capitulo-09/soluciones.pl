:- encoding(utf8).

% Capítulo 9 - Soluciones de los ejercicios.
%
%?- categoria_sin_ningun_corte(sofia, C).
%?- sin_repetidos([a, b, a, c, b], R).

edad(juan, 68).
edad(ana, 41).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

% --- Ejercicio 3 -----------------------------------------------------------

%!  categoria_sin_ningun_corte(?P, ?C) is nondet.
%!  categoria_sin_ningun_corte(+P, -C) is semidet.
%
%   C es la categoría de P, con las condiciones completas, sin corte.
categoria_sin_ningun_corte(P, bebe) :-
    edad(P, A),
    A < 4.
categoria_sin_ningun_corte(P, chico) :-
    edad(P, A),
    A >= 4,
    A < 13.
categoria_sin_ningun_corte(P, adulto) :-
    edad(P, A),
    A >= 13.

% --- Ejercicio 5 -----------------------------------------------------------

%!  primer_par(+L, -X) is semidet.
%
%   X es el primer número par de L.
primer_par([X|_], X) :-
    0 =:= X mod 2,
    !.
primer_par([X|Resto], P) :-
    0 =\= X mod 2,
    primer_par(Resto, P).

% --- Ejercicio 6 -----------------------------------------------------------

%!  hay_algun_menor(+L) is nondet.
%
%   Algún número de L es menor que 18. No requiere corte: es suficiente que
%   exista uno, y la consulta se cumple al encontrarlo.
hay_algun_menor(L) :-
    member(X, L),
    X < 18.

% --- Ejercicio 8 -----------------------------------------------------------

%!  primer_cuadrado_mayor(+N, -C) is semidet.
%
%   C es el primer número cuyo cuadrado supera a N; falla si ninguno hasta
%   10 000 lo supera. C debe llegar libre: el corte es rojo.
primer_cuadrado_mayor(N, C) :-
    between(1, 10000, C),
    C * C > N,
    !.

% --- Ejercicio 9 -----------------------------------------------------------

%!  descuento(+Edad, -D) is det.
%
%   D es el descuento que corresponde a Edad: el corte rojo corregido, con las
%   condiciones completas.
descuento(Edad, 50) :-
    Edad < 12.
descuento(Edad, 30) :-
    Edad >= 65.
descuento(Edad, 0) :-
    Edad >= 12,
    Edad < 65.

% --- Ejercicio 10 ----------------------------------------------------------

%!  sin_repetidos(+L, -R) is det.
%
%   R es L sin repetidos; conserva la primera aparición de cada elemento.
%   El acumulador lleva los elementos ya incluidos.
sin_repetidos(L, R) :-
    sin_los_vistos(L, [], R).

%!  sin_los_vistos(+L, +Vistos, -R) is det.
%
%   R es L sin los elementos de Vistos y sin repetidos; Vistos acumula los
%   elementos ya incluidos en R. El corte descarta las demás soluciones de
%   member/2: es suficiente que X aparezca una vez en Vistos.
sin_los_vistos([], _, []).
sin_los_vistos([X|Resto], Vistos, [X|RestoR]) :-
    \+ member(X, Vistos),
    sin_los_vistos(Resto, [X|Vistos], RestoR).
sin_los_vistos([X|Resto], Vistos, R) :-
    member(X, Vistos),
    !,
    sin_los_vistos(Resto, Vistos, R).

% --- Ejercicio 14 ----------------------------------------------------------

%!  clasificar(+N, -C) is det.
%
%   C es negativo, cero o positivo, según N. Plantilla 14. Correcto con C
%   libre; con C instanciado, el corte puede no ejecutarse.
clasificar(N, negativo) :-
    N < 0,
    !.
clasificar(0, cero) :-
    !.
clasificar(_, positivo).

% --- Ejercicio 16 ----------------------------------------------------------

% talle(T): T es un talle del catálogo.
talle(chico).
talle(grande).

% color(C): C es un color del catálogo.
color(rojo).
color(azul).

% tela(M): M es una tela del catálogo.
tela(algodon).
tela(lana).

%!  prenda(?T, ?C, ?M) is nondet.
%
%   Hay una prenda de talle T, color C y tela M.
prenda(unico, blanco, lino).
prenda(T, C, M) :-
    talle(T),
    color(C),
    tela(M).
prenda(unico, negro, cuero).

%!  prenda_corte_talle(-T, -C, -M) is multi.
%
%   prenda/3 con un corte después de talle/1. T, C y M deben llegar libres.
prenda_corte_talle(unico, blanco, lino).
prenda_corte_talle(T, C, M) :-
    talle(T),
    !,
    color(C),
    tela(M).
prenda_corte_talle(unico, negro, cuero).

%!  prenda_corte_color(-T, -C, -M) is multi.
%
%   prenda/3 con un corte después de color/1. T, C y M deben llegar libres.
prenda_corte_color(unico, blanco, lino).
prenda_corte_color(T, C, M) :-
    talle(T),
    color(C),
    !,
    tela(M).
prenda_corte_color(unico, negro, cuero).

%!  prenda_corte_final(-T, -C, -M) is multi.
%
%   prenda/3 con un corte al final del cuerpo. T, C y M deben llegar libres.
prenda_corte_final(unico, blanco, lino).
prenda_corte_final(T, C, M) :-
    talle(T),
    color(C),
    tela(M),
    !.
prenda_corte_final(unico, negro, cuero).

% --- Ejercicio 17 ----------------------------------------------------------

%!  identifica(+Datos, -Secuencia) is det.
%
%   Secuencia es la forma de la lista de números Datos: maximo, minimo,
%   meseta o sinorden. Plantilla 14. Secuencia debe llegar libre: con
%   sinorden ya ligado, la última cláusula lo acepta sin verificar nada.
identifica(Datos, maximo) :-
    append(Sube, [Cima|Baja], Datos),
    Sube = [_|_],
    Baja = [_|_],
    append(Sube, [Cima], Subida),
    creciente(Subida),
    decreciente([Cima|Baja]),
    !.
identifica(Datos, minimo) :-
    append(Baja, [Fondo|Sube], Datos),
    Baja = [_|_],
    Sube = [_|_],
    append(Baja, [Fondo], Bajada),
    decreciente(Bajada),
    creciente([Fondo|Sube]),
    !.
identifica(Datos, meseta) :-
    append(Sube, Resto, Datos),
    Sube = [_|_],
    append(Meseta, Baja, Resto),
    Meseta = [Primero, _|_],
    Baja = [_|_],
    append(Sube, [Primero], Subida),
    creciente(Subida),
    constante(Meseta),
    last(Meseta, Ultimo),
    decreciente([Ultimo|Baja]),
    !.
identifica(_, sinorden).

%!  creciente(+L) is semidet.
%
%   Los números de L están en orden estrictamente creciente.
creciente([]).
creciente([_]).
creciente([X, Y|Resto]) :-
    X < Y,
    creciente([Y|Resto]).

%!  decreciente(+L) is semidet.
%
%   Los números de L están en orden estrictamente decreciente.
decreciente([]).
decreciente([_]).
decreciente([X, Y|Resto]) :-
    X > Y,
    decreciente([Y|Resto]).

%!  constante(+L) is semidet.
%
%   Todos los números de L son iguales.
constante([]).
constante([_]).
constante([X, Y|Resto]) :-
    X =:= Y,
    constante([Y|Resto]).

% --- Ejercicio 18 ----------------------------------------------------------

%!  sust(+L1, +P1, +P2, -L2) is det.
%
%   L2 es L1 con cada aparición de la lista P1 reemplazada por la lista P2,
%   de izquierda a derecha y sin superposiciones. P1 no puede ser vacía.
sust([], _, _, []).
sust(L1, P1, P2, L2) :-
    append(P1, Resto, L1),
    !,
    sust(Resto, P1, P2, R),
    append(P2, R, L2).
sust([X|Xs], P1, P2, [X|L2]) :-
    sust(Xs, P1, P2, L2).

% --- Ejercicio 19 ----------------------------------------------------------

%!  atomiza(+Xs, -Ys) is det.
%
%   Ys tiene los elementos de Xs que no son listas, de todos los niveles de
%   anidamiento, en orden. Los cortes distinguen una lista de un elemento.
atomiza([], Ys) :-
    !,
    Ys = [].
atomiza([X|Xs], Ys) :-
    !,
    atomiza(X, Ys1),
    atomiza(Xs, Ys2),
    append(Ys1, Ys2, Ys).
atomiza(X, [X]).
