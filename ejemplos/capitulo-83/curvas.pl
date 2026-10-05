:- encoding(utf8).

% Capítulo 83 - Las curvas, versión 2: cualquier curva, varios formatos.
%
% Una curva paramétrica es un término que dice su clase y sus parámetros:
% cicloide(R, A), circulo(Cx, Cy, R), espiral(K). punto/3 da el punto de
% la curva para un valor T del parámetro, con una cláusula por clase; una
% clase nueva es una cláusula más. muestra/5 calcula los puntos sobre una
% malla, y las gramáticas del final escriben los puntos en uno de tres
% formatos: epic (\drawline, de LaTeX), tikz (\draw, de LaTeX) y svg (un
% dibujo para la web). Los puntos no saben nada del formato, y el formato
% no sabe nada de la curva.
%
% solo-local: es un módulo que carga otro.
%
%?- punto(circulo(0, 0, 10), pi/2, P).
%?- punto(cicloide(5, 8), pi, P).
%?- definir(tikz, c, circulo(0, 0, 1), 0, 2*pi, 4, T).

:- module(curvas,
          [ punto/3,
            curva/1,
            muestra/5,
            definicion/4,
            definir/7,
            documento/3
          ]).

:- use_module(cicloide, [malla/4, decimal//1, atom//1, codigos//1,
                         comando_drawline//2]).

% punto/3 es multifile: otro archivo agrega una clase de curva con una
% cláusula curvas:punto(Clase, T, X-Y), sin modificar este.
:- multifile punto/3.

%!  punto(+Curva, +T:number, -Punto:pair) is det.
%
%   Punto es X-Y, el punto de Curva para el valor T de su parámetro. T
%   puede ser una expresión aritmética, como pi/2.
punto(cicloide(R, A), T, X-Y) :-
    X is R * T - A * sin(T),
    Y is R - A * cos(T).
punto(circulo(Cx, Cy, R), T, X-Y) :-
    X is Cx + R * cos(T),
    Y is Cy + R * sin(T).
punto(espiral(K), T, X-Y) :-
    X is exp(K * T) * cos(T),
    Y is exp(K * T) * sin(T).

%!  curva(+Curva) is semidet.
%
%   Curva es una curva que punto/3 conoce, con parámetros numéricos.
curva(Curva) :-
    compound(Curva),
    Curva =.. [_|Parametros],
    maplist(number, Parametros),
    clause(punto(Curva, _, _), _),
    !.

%!  muestra(+Curva, +Desde, +Hasta, +N:integer, -Puntos:list(pair)) is det.
%
%   Puntos son los N + 1 puntos de Curva en la malla de N intervalos de
%   Desde a Hasta, que pueden ser expresiones aritméticas.
muestra(Curva, Desde, Hasta, N, Puntos) :-
    malla(Desde, Hasta, N, Valores),
    maplist(punto(Curva), Valores, Puntos).

%!  definir(+Formato, +Nombre:atom, +Curva, +Desde, +Hasta, +N:integer,
%!          -Texto:string) is det.
%
%   Texto es la definición, en Formato, de la curva Nombre: Curva con el
%   parámetro de Desde a Hasta, en N segmentos.
definir(Formato, Nombre, Curva, Desde, Hasta, N, Texto) :-
    muestra(Curva, Desde, Hasta, N, Puntos),
    definicion(Formato, Nombre, Puntos, Texto).

%!  definicion(+Formato, +Nombre:atom, +Puntos:list(pair),
%!             -Texto:string) is det.
%
%   Texto es la definición de la curva Nombre, de Puntos, en Formato: epic,
%   tikz o svg.
definicion(Formato, Nombre, Puntos, Texto) :-
    phrase(definicion(Formato, Nombre, Puntos), Codigos),
    string_codes(Texto, Codigos).

%!  definicion(+Formato, +Nombre:atom, +Puntos:list(pair))// is det.
%
%   La definición de una curva. En epic y en tikz, un comando de LaTeX
%   \Nombre; en svg, una polilínea con el identificador Nombre, con Y hacia
%   arriba, como en las otras dos.
definicion(epic, Nombre, Puntos) -->
    comando_drawline(Nombre, Puntos).
definicion(tikz, Nombre, [P|Ps]) -->
    "\\newcommand{\\", atom(Nombre), "}{\\draw ",
    tikz_par(P),
    tikz_resto(Ps),
    ";}".
definicion(svg, Nombre, Puntos) -->
    "<polyline id=\"", atom(Nombre), "\" points=\"",
    svg_pares(Puntos),
    "\"/>".

%!  tikz_par(+Punto:pair)// is det.
%
%   (X,Y), con cuatro decimales.
tikz_par(X-Y) -->
    "(", decimal(X), ",", decimal(Y), ")".

%!  tikz_resto(+Puntos:list(pair))// is det.
%
%   Cada punto precedido por --, el segmento desde el anterior.
tikz_resto([]) -->
    [].
tikz_resto([P|Ps]) -->
    " -- ",
    tikz_par(P),
    tikz_resto(Ps).

%!  svg_pares(+Puntos:list(pair))// is det.
%
%   X,-Y para cada punto, separados por un espacio: en SVG el eje Y
%   apunta hacia abajo.
svg_pares([]) -->
    [].
svg_pares([X-Y|Ps]) -->
    { Abajo is -Y },
    decimal(X), ",", decimal(Abajo),
    (   { Ps == [] }
    ->  []
    ;   " ",
        svg_pares(Ps)
    ).

%!  documento(+Formato, +Partes:list, -Texto:string) is det.
%
%   Texto es un archivo completo en Formato con Partes, en orden: cada
%   parte es comentario(Cadena) o curva(Nombre, Puntos). En epic y tikz,
%   un comentario es una línea que empieza con %, y una curva, la línea de
%   su definición; en svg, un dibujo con las curvas y los comentarios
%   como comentarios de XML, del tamaño de lo que contienen.
documento(Formato, Partes, Texto) :-
    phrase(documento(Formato, Partes), Codigos),
    string_codes(Texto, Codigos).

%!  documento(+Formato, +Partes:list)// is det.
%
%   El archivo de documento/3. En svg, el grosor de las líneas es el
%   0,5 % del lado mayor del dibujo, que está en las unidades de las
%   curvas.
documento(svg, Partes) -->
    { include(es_curva, Partes, Curvas),
      caja(Curvas, Caja),
      Caja = caja(_, _, Ancho, Alto),
      Grosor is 0.005 * max(Ancho, Alto)
    },
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"", caja(Caja),
    "\" fill=\"none\" stroke-width=\"", decimal(Grosor),
    "\" stroke-linejoin=\"round\">\n",
    partes_svg(Partes, 0),
    "</svg>\n".
documento(epic, Partes) -->
    partes_latex(Partes, epic).
documento(tikz, Partes) -->
    partes_latex(Partes, tikz).

%!  partes_latex(+Partes:list, +Formato)// is det.
%
%   Una línea por parte, en epic o en tikz.
partes_latex([], _) -->
    [].
partes_latex([Parte|Partes], Formato) -->
    parte_latex(Parte, Formato),
    "\n",
    partes_latex(Partes, Formato).

%!  parte_latex(+Parte, +Formato)// is det.
%
%   Un comentario o la definición de una curva, en epic o en tikz.
parte_latex(comentario(Texto), _) -->
    "% ", texto(Texto).
parte_latex(curva(Nombre, Puntos), Formato) -->
    definicion(Formato, Nombre, Puntos).

%!  partes_svg(+Partes:list, +I:integer)// is det.
%
%   Una línea por parte, en svg; I es la cantidad de curvas anteriores,
%   que elige el color de la próxima.
partes_svg([], _) -->
    [].
partes_svg([Parte|Partes], I) -->
    parte_svg(Parte, I, I1),
    partes_svg(Partes, I1).

%!  parte_svg(+Parte, +I:integer, -I1:integer)// is det.
%
%   Un comentario o una curva, en svg; I1 es I más las curvas de Parte.
parte_svg(comentario(Texto), I, I) -->
    "<!-- ", texto(Texto), " -->\n".
parte_svg(curva(Nombre, Puntos), I, I1) -->
    { color(I, Color),
      I1 is I + 1
    },
    "<g stroke=\"", atom(Color), "\">",
    definicion(svg, Nombre, Puntos),
    "</g>\n".

% color(I, Color): el color de la curva I, en un ciclo de cuatro.
color(I, Color) :-
    Colores = ['#1f4e79', '#c0392b', '#1e8449', '#7d3c98'],
    J is I mod 4,
    nth0(J, Colores, Color).

%!  es_curva(+Parte) is semidet.
%
%   Parte es curva(Nombre, Puntos).
es_curva(curva(_, _)).

%!  caja(+Curvas:list, -Caja) is det.
%
%   Caja es caja(X0, Y0, Ancho, Alto), el rectángulo de SVG que contiene
%   los puntos de Curvas con un margen del 5 % del lado mayor; Y0 es el
%   borde de arriba, con el eje Y hacia abajo.
caja(Curvas, caja(X0, Y0, Ancho, Alto)) :-
    findall(X-Y, ( member(curva(_, Ps), Curvas), member(X-Y, Ps) ), Todos),
    pairs_keys_values(Todos, Xs, Ys),
    min_list(Xs, Xmin), max_list(Xs, Xmax),
    min_list(Ys, Ymin), max_list(Ys, Ymax),
    Margen is 0.05 * max(Xmax - Xmin, Ymax - Ymin),
    X0 is Xmin - Margen,
    Y0 is -Ymax - Margen,
    Ancho is Xmax - Xmin + 2 * Margen,
    Alto is Ymax - Ymin + 2 * Margen.

%!  caja(+Caja)// is det.
%
%   Los cuatro números del atributo viewBox.
caja(caja(X0, Y0, Ancho, Alto)) -->
    decimal(X0), " ", decimal(Y0), " ", decimal(Ancho), " ", decimal(Alto).

%!  texto(+Texto:string)// is det.
%
%   Los caracteres de Texto.
texto(Texto) -->
    { string_codes(Texto, Codigos) },
    codigos(Codigos).
