:- encoding(utf8).

% Capítulo 48 - Los productos como vectores de signos.
%
% Clocksin (Clause and Effect, 7.5) propone otra representación de los
% productos de una suma de productos cuando las variables son pocas y se
% conocen de antemano: un signo por variable, en un orden fijo, + si la
% variable aparece, - si aparece negada y 0 si no aparece. En esa
% representación un producto no puede ser contradictorio, la absorción se
% decide posición por posición, y dos productos que difieren en el signo
% de una sola variable se combinan en uno: X·Y + X·¬Y = X. Repetir esa
% combinación desde las filas de la tabla de verdad da los implicantes
% primos de una salida.
%
% solo-local: carga los módulos circuitos y formulas, y SWISH no admite
% módulos propios.
%
%?- vector([a, b, ci], [a, ci, ~b], V).
%?- unos(sumador, co, Vs), implicantes_primos(Vs, Ps).

:- module(vectores,
          [ vector/3,
            producto_de_vector/3,
            cubre/2,
            combinar/3,
            unos/3,
            implicantes_primos/2,
            op(300, fy, ~)
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(pairs)).
:- use_module(circuitos).
:- use_module(formulas).

%!  vector(+Nombres:list(atom), +Producto:list, -Signos:list) is det.
%
%   Signos tiene un signo por cada nombre de Nombres: + si el nombre
%   aparece en Producto, - si aparece negado, y 0 si no aparece. Producto
%   no es contradictorio.
vector(Nombres, Producto, Signos) :-
    maplist(signo(Producto), Nombres, Signos).

%!  signo(+Producto:list, +Nombre:atom, -S) is det.
%
%   S es el signo de Nombre en Producto.
signo(Producto, Nombre, S) :-
    (   memberchk(Nombre, Producto)
    ->  S = (+)
    ;   memberchk(~Nombre, Producto)
    ->  S = (-)
    ;   S = 0
    ).

%!  producto_de_vector(+Nombres:list(atom), +Signos:list,
%!                     -Producto:list) is det.
%
%   Producto es la lista de literales del vector Signos, en el orden de
%   Nombres: el nombre si el signo es +, su negación si es -, y nada si
%   es 0.
producto_de_vector([], [], []).
producto_de_vector([N|Ns], [S|Ss], Producto) :-
    literal_de(S, N, Producto, Resto),
    producto_de_vector(Ns, Ss, Resto).

%!  literal_de(+S, +Nombre:atom, -Producto:list, ?Resto:list) is det.
%
%   Producto es Resto precedido por el literal de Nombre con el signo S, o
%   Resto si S es 0.
literal_de(0, _, Resto, Resto).
literal_de(+, N, [N|Resto], Resto).
literal_de(-, N, [~N|Resto], Resto).

%!  cubre(+V:list, +W:list) is semidet.
%
%   Cada literal del producto V está en el producto W: en una suma, V
%   absorbe a W (P + P·Q = P). En cada posición, el signo de V es 0 o el
%   mismo que el de W.
cubre(V, W) :-
    maplist(cubre_signo, V, W).

%!  cubre_signo(+S, +T) is semidet.
%
%   El signo S cubre al signo T: S es 0, o los dos son iguales.
cubre_signo(0, _).
cubre_signo(+, +).
cubre_signo(-, -).

%!  combinar(+V:list, +W:list, -C:list) is semidet.
%
%   V y W difieren solo en una posición, con + en uno y - en el otro, y C
%   es el vector con 0 en esa posición: X·Y + X·¬Y = X.
combinar([S|Vs], [T|Ws], [C|Cs]) :-
    (   S == T
    ->  C = S,
        combinar(Vs, Ws, Cs)
    ;   opuestos(S, T),
        C = 0,
        Vs == Ws,
        Cs = Vs
    ).

%!  opuestos(?S, ?T) is nondet.
%
%   S y T son los signos de una variable y de su negación.
opuestos(+, -).
opuestos(-, +).

%!  unos(+Circuito, +Salida, -Vectores:list(list)) is semidet.
%
%   Vectores tiene un vector por cada fila de la tabla de verdad de
%   Circuito en la que Salida vale 1: + para una entrada en 1 y - para
%   una en 0, en el orden de las entradas. Falla si Salida no es una
%   salida de Circuito.
unos(Circuito, Salida, Vectores) :-
    circuito(Circuito, _, Salidas),
    nth1(I, Salidas, Salida),
    !,
    tabla_de_verdad(Circuito, Filas),
    findall(V,
            ( member(Es-Ss, Filas),
              nth1(I, Ss, 1),
              maplist(signo_de_bit, Es, V) ),
            Vectores).

%!  signo_de_bit(?Bit, ?S) is nondet.
%
%   S es el signo de una entrada con el valor Bit.
signo_de_bit(1, +).
signo_de_bit(0, -).

%!  implicantes_primos(+Vectores:list(list), -Primos:list(list)) is det.
%
%   Primos son los vectores que se obtienen combinando los de Vectores de
%   a dos, mientras se pueda, y que ya no se combinan con ningún otro: los
%   implicantes primos de la suma, en el orden estándar.
implicantes_primos(Vectores0, Primos) :-
    sort(Vectores0, Vectores),
    findall(C-[V, W],
            ( member(V, Vectores),
              member(W, Vectores),
              V @< W,
              combinar(V, W, C) ),
            Pares),
    (   Pares == []
    ->  Primos = Vectores
    ;   pairs_keys_values(Pares, Combinados, Usados0),
        append(Usados0, Usados1),
        sort(Usados1, Usados),
        ord_subtract(Vectores, Usados, Restantes),
        implicantes_primos(Combinados, Primos1),
        ord_union(Restantes, Primos1, Primos)
    ).
