:- encoding(utf8).

% Capítulo 39 - Soluciones de los ejercicios 2, 4, 5, 6, 7, 8, 9 y 10.
%
% Cada ejercicio repite los datos que usa, para que el archivo se cargue
% solo: el grafo de camino.pl, el de distancias.pl y el juego de juego.pl.
%
%?- findall(Y, camino_der(a, Y), Ys), tablas(T).
%?- formas(100, [1, 5, 10, 25, 50], N).
%?- saltos(a, b, N).
%?- valor(gana(j3, a), V).

% arco(X, Y): hay un arco de X a Y.
arco(a, b).
arco(b, c).
arco(c, a).
arco(c, d).

% Ejercicio 2

:- table camino_der/2.

%!  camino_der(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y, con la recursión a la derecha y tabulado.
camino_der(X, Y) :-
    arco(X, Y).
camino_der(X, Y) :-
    arco(X, Z),
    camino_der(Z, Y).

%!  tablas(-N:integer) is det.
%
%   N es la cantidad de tablas que existen en este momento.
tablas(N) :-
    aggregate_all(count, current_table(_, _), N).

% Ejercicio 4

:- table suma_hasta/2.

%!  suma_hasta(+N:integer, -S:integer) is semidet.
%
%   S es la suma de 1 a N. Falla si N no es positivo.
suma_hasta(1, 1).
suma_hasta(N, S) :-
    N > 1,
    N1 is N - 1,
    suma_hasta(N1, S1),
    S is S1 + N.

% Ejercicio 5

:- table formas/3.

%!  formas(+Monto:integer, +Monedas:list(integer), -N:integer) is det.
%
%   N es la cantidad de formas de pagar Monto con monedas de los valores de
%   Monedas, positivos y sin repetir, sin importar el orden.
formas(Monto, Monedas, N) :-
    (   Monto =:= 0
    ->  N = 1
    ;   Monedas == []
    ->  N = 0
    ;   Monedas = [Moneda|Resto],
        (   Moneda > Monto
        ->  formas(Monto, Resto, N)
        ;   Menos is Monto - Moneda,
            formas(Menos, Monedas, N1),
            formas(Monto, Resto, N2),
            N is N1 + N2
        )
    ).

%!  formas_sin_tabla(+Monto:integer, +Monedas:list(integer), -N:integer)
%!      is det.
%
%   La misma relación que formas/3, sin tabla.
formas_sin_tabla(Monto, Monedas, N) :-
    (   Monto =:= 0
    ->  N = 1
    ;   Monedas == []
    ->  N = 0
    ;   Monedas = [Moneda|Resto],
        (   Moneda > Monto
        ->  formas_sin_tabla(Monto, Resto, N)
        ;   Menos is Monto - Moneda,
            formas_sin_tabla(Menos, Monedas, N1),
            formas_sin_tabla(Monto, Resto, N2),
            N is N1 + N2
        )
    ).

% Ejercicios 6 y 7

% tramo(X, Y, D): hay un tramo de X a Y de longitud D.
tramo(a, b, 4).
tramo(a, c, 1).
tramo(c, b, 2).
tramo(b, d, 5).
tramo(d, a, 3).

:- table distancia(_, _, min).

%!  distancia(?X, ?Y, -D:integer) is nondet.
%
%   D es la longitud del recorrido más corto de X a Y. D debe llegar libre.
distancia(X, Y, D) :-
    tramo(X, Y, D).
distancia(X, Y, D) :-
    distancia(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.

:- table distancia_max(_, _, max).

%!  distancia_max(?X, ?Y, -D:integer) is nondet.
%
%   Pretende dar la longitud del recorrido más largo de X a Y. Con un
%   ciclo de longitud positiva no termina: cada vuelta mejora el máximo.
distancia_max(X, Y, D) :-
    tramo(X, Y, D).
distancia_max(X, Y, D) :-
    distancia_max(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.

:- table saltos(_, _, min).

%!  saltos(?X, ?Y, -N:integer) is nondet.
%
%   N es la menor cantidad de tramos de un recorrido de X a Y. N debe
%   llegar libre.
saltos(X, Y, 1) :-
    tramo(X, Y, _).
saltos(X, Y, N) :-
    saltos(X, Z, N0),
    tramo(Z, Y, _),
    N is N0 + 1.

% Ejercicio 8

% dag(X, Y, D): hay un tramo de X a Y de longitud D, en un grafo sin
% ciclos.
dag(s, a, 2).
dag(s, b, 1).
dag(b, a, 5).
dag(a, t, 3).
dag(b, t, 1).

:- table ruta_mas_larga(_, _, lattice(mas_larga/3)).

%!  ruta_mas_larga(?X, ?Y, -R) is nondet.
%
%   R es D-Nodos: el recorrido más largo de X a Y en dag/3, con su
%   longitud D y sus nodos. R debe llegar libre.
ruta_mas_larga(X, Y, D-[X, Y]) :-
    dag(X, Y, D).
ruta_mas_larga(X, Y, D-Nodos) :-
    ruta_mas_larga(X, Z, R0),
    R0 = D0-Nodos0,
    dag(Z, Y, D1),
    D is D0 + D1,
    append(Nodos0, [Y], Nodos).

%!  mas_larga(+R1, +R2, -R) is det.
%
%   R es la más larga de las rutas R1 y R2, de la forma D-Nodos; con
%   longitudes iguales, R1.
mas_larga(D1-N1, D2-N2, R) :-
    (   D1 >= D2
    ->  R = D1-N1
    ;   R = D2-N2
    ).

% Ejercicio 9

% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y. j3 es j2 con un movimiento más, de a a e.
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).
mueve(j3, a, b).
mueve(j3, b, a).
mueve(j3, b, c).
mueve(j3, c, d).
mueve(j3, a, e).

:- table gana/2.

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana. Las posiciones de empate son
%   respuestas indefinidas.
gana(J, X) :-
    mueve(J, X, Y),
    tnot(gana(J, Y)).

%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, en la semántica bien fundada.
valor(Meta, Valor) :-
    must_be(ground, Meta),
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).

% Ejercicio 10

:- table p/0, q/0, r/0.

%!  p is semidet.
%
%   p es verdadero si q no lo es.
p :-
    tnot(q).

%!  q is semidet.
%
%   q es verdadero si p no lo es.
q :-
    tnot(p).

%!  r is semidet.
%
%   r es verdadero si r no lo es.
r :-
    tnot(r).

%!  r_prolog is semidet.
%
%   r con la negación de Prolog y sin tabla: no termina.
r_prolog :-
    \+ r_prolog.
