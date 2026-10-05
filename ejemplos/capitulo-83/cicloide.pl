:- encoding(utf8).

% Capítulo 83 - Las curvas, versión 1: la cicloide y el texto de LaTeX.
%
% Un disco de radio R rueda sobre una recta; un punto fijo al disco, a
% distancia A de su centro, describe una cicloide. Con el disco girado un
% ángulo Fi, en radianes, el punto está en
%
%     X = R * Fi - A * sin(Fi),    Y = R - A * cos(Fi).
%
% El programa calcula los puntos de la curva sobre una malla de valores de
% Fi y escribe el comando de LaTeX que los une con segmentos: \drawline,
% del paquete epic, recibe la sucesión de los puntos. Los números se
% escriben con cuatro decimales fijos, porque LaTeX no lee la notación
% exponencial con la que Prolog escribe los números muy chicos.
%
%?- malla(0, 1, 4, Valores).
%?- cicloide(5, 8, 0, P).
%?- definir_cicloide(curva, 5, 5, 1, 4, Texto).

:- module(cicloide,
          [ cicloide/4,
            malla/4,
            puntos_cicloide/5,
            definir_cicloide/6,
            comando/3,
            comando_drawline//2,
            par//1,
            decimal//1,
            atom//1,
            codigos//1
          ]).

%!  cicloide(+R:number, +A:number, +Fi:number, -Punto:pair) is det.
%
%   Punto es X-Y, la posición del punto a distancia A del centro de un
%   disco de radio R que rodó hasta girar Fi radianes.
cicloide(R, A, Fi, X-Y) :-
    X is R * Fi - A * sin(Fi),
    Y is R - A * cos(Fi).

%!  malla(+Desde:number, +Hasta:number, +N:integer, -Valores:list) is det.
%
%   Valores son los N + 1 extremos de los N intervalos iguales en que se
%   divide el intervalo de Desde a Hasta: el primero es Desde, el último
%   es Hasta.
malla(Desde, Hasta, N, Valores) :-
    must_be(positive_integer, N),
    numlist(0, N, Is),
    maplist(valor(Desde, Hasta, N), Is, Valores).

%!  valor(+Desde:number, +Hasta:number, +N:integer, +I:integer,
%!        -V:number) is det.
%
%   V es el extremo I de la malla de N intervalos de Desde a Hasta.
valor(Desde, Hasta, N, I, V) :-
    V is Desde + (Hasta - Desde) * I / N.

%!  puntos_cicloide(+R:number, +A:number, +Vueltas:number, +N:integer,
%!                  -Puntos:list(pair)) is det.
%
%   Puntos son los N + 1 puntos de la cicloide de R y A en la malla de N
%   intervalos de las Vueltas vueltas del disco.
puntos_cicloide(R, A, Vueltas, N, Puntos) :-
    Hasta is 2 * pi * Vueltas,
    malla(0, Hasta, N, Angulos),
    maplist(cicloide(R, A), Angulos, Puntos).

%!  definir_cicloide(+Nombre:atom, +R:number, +A:number, +Vueltas:number,
%!                   +N:integer, -Texto:string) is det.
%
%   Texto es la definición del comando de LaTeX \Nombre, que dibuja la
%   cicloide de R y A en Vueltas vueltas del disco, con N segmentos.
definir_cicloide(Nombre, R, A, Vueltas, N, Texto) :-
    puntos_cicloide(R, A, Vueltas, N, Puntos),
    comando(Nombre, Puntos, Texto).

%!  comando(+Nombre:atom, +Puntos:list(pair), -Texto:string) is det.
%
%   Texto es la definición del comando de LaTeX \Nombre, que une Puntos
%   con \drawline.
comando(Nombre, Puntos, Texto) :-
    phrase(comando_drawline(Nombre, Puntos), Codigos),
    string_codes(Texto, Codigos).

%!  comando_drawline(+Nombre:atom, +Puntos:list(pair))// is det.
%
%   \newcommand{\Nombre}{\drawline(X1,Y1)(X2,Y2)...}.
comando_drawline(Nombre, Puntos) -->
    "\\newcommand{\\", atom(Nombre), "}{\\drawline",
    pares(Puntos),
    "}".

%!  pares(+Puntos:list(pair))// is det.
%
%   Los puntos, cada uno entre paréntesis, sin separador.
pares([]) -->
    [].
pares([P|Ps]) -->
    par(P),
    pares(Ps).

%!  par(+Punto:pair)// is det.
%
%   (X,Y), con cuatro decimales.
par(X-Y) -->
    "(", decimal(X), ",", decimal(Y), ")".

%!  decimal(+X:number)// is det.
%
%   X con cuatro decimales fijos, sin notación exponencial. X se redondea
%   antes de escribirlo, para que un número negativo muy chico se escriba
%   0.0000 y no -0.0000.
decimal(X) -->
    { Redondeado is round(X * 10000) / 10000,
      format(codes(Codigos), "~4f", [Redondeado])
    },
    codigos(Codigos).

%!  atom(+A:atom)// is det.
%
%   Los caracteres de A.
atom(A) -->
    { atom_codes(A, Codigos) },
    codigos(Codigos).

%!  codigos(+Codigos:list(integer))// is det.
%
%   Los códigos de la lista Codigos, en orden.
codigos([]) -->
    [].
codigos([C|Cs]) -->
    [C],
    codigos(Cs).
