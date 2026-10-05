:- encoding(utf8).

% Capítulo 80 - Versión 6: dibujar las interpretaciones.
%
% Una interpretación se entiende mejor dibujada. svg/4 escribe el dibujo
% como un documento SVG: cada línea con su etiqueta, un + o un - junto a la
% línea, o una punta de flecha en su centro que deja el cuerpo a la
% derecha. Las coordenadas del dibujo tienen el eje y hacia arriba y las
% del SVG hacia abajo, así que la y se invierte. catalogo_svg/1 dibuja las
% 18 uniones del catálogo con la misma función. Las figuras del capítulo se
% generaron con generar_figuras/1.
%
% solo-local: carga waltz.pl y escribe archivos.
%
%?- etiquetar_waltz(cubo, borde, Ls), svg(cubo, Ls, "Cubo", Texto).

:- ensure_loaded(waltz).

%!  svg(+F, +Etiquetas:list, +Titulo:string, -Texto:string) is det.
%
%   Texto es el SVG del dibujo F con las Etiquetas, pares Linea-Etiqueta
%   (una lista vacía dibuja las líneas sin etiquetas), los nombres de los
%   puntos y el Titulo como descripción accesible.
svg(F, Etiquetas, Titulo, Texto) :-
    findall(P-(X/Y), punto(F, P, X, Y), Puntos),
    lineas(F, Lineas),
    with_output_to(string(Texto),
                   escribir_svg(Puntos, Lineas, Etiquetas, si, Titulo)).

%!  escribir_svg(+Puntos, +Lineas, +Etiquetas, +Nombres, +Titulo) is det.
%
%   Escribe el documento SVG: Puntos son pares P-(X/Y), Lineas pares A-B y
%   Etiquetas pares Linea-Etiqueta. Nombres es si o no.
escribir_svg(Puntos, Lineas, Etiquetas, Nombres, Titulo) :-
    caja(Puntos, Caja),
    Caja = caja(_, _, _, Ancho, Alto),
    format('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ~w ~w" \c
            width="~w" height="~w" role="img" aria-labelledby="t">~n',
           [Ancho, Alto, Ancho, Alto]),
    format('  <title id="t">~w</title>~n', [Titulo]),
    format('  <rect width="~w" height="~w" fill="#ffffff"/>~n',
           [Ancho, Alto]),
    forall(member(L, Lineas),
           escribir_linea(Puntos, Caja, Etiquetas, L)),
    (   Nombres == si
    ->  forall(member(P-_, Puntos), escribir_nombre(Puntos, Caja, P))
    ;   true
    ),
    format('</svg>~n').

% margen(M): el margen alrededor del dibujo, en unidades del SVG.
margen(40).

%!  caja(+Puntos:list, -Caja) is det.
%
%   Caja es caja(XMin, YMax, S, Ancho, Alto): la esquina de arriba a la
%   izquierda del dibujo, la escala S, que lleva el lado mayor del dibujo a
%   unas 360 unidades (al menos 4 por unidad del dibujo), y el tamaño del
%   SVG que lo contiene con margen.
caja(Puntos, caja(XMin, YMax, S, Ancho, Alto)) :-
    findall(X, member(_-(X/_), Puntos), Xs),
    findall(Y, member(_-(_/Y), Puntos), Ys),
    min_list(Xs, XMin),
    max_list(Xs, XMax),
    min_list(Ys, YMin),
    max_list(Ys, YMax),
    S is max(4, 360 // max(XMax - XMin, YMax - YMin)),
    margen(M),
    Ancho is (XMax - XMin) * S + 2 * M,
    Alto is (YMax - YMin) * S + 2 * M.

%!  pantalla(+Puntos:list, +Caja, +P, -XS:number, -YS:number) is det.
%
%   (XS, YS) es la posición del punto P en el SVG.
pantalla(Puntos, caja(XMin, YMax, S, _, _), P, XS, YS) :-
    memberchk(P-(X/Y), Puntos),
    margen(M),
    XS is (X - XMin) * S + M,
    YS is (YMax - Y) * S + M.

%!  escribir_linea(+Puntos, +Caja, +Etiquetas:list, +L) is det.
%
%   Escribe la línea L = A-B y, si tiene una etiqueta, su marca.
escribir_linea(Puntos, Caja, Etiquetas, A-B) :-
    pantalla(Puntos, Caja, A, X1, Y1),
    pantalla(Puntos, Caja, B, X2, Y2),
    format('  <line x1="~1f" y1="~1f" x2="~1f" y2="~1f" stroke="#222222" \c
            stroke-width="2" stroke-linecap="round"/>~n',
           [X1, Y1, X2, Y2]),
    (   memberchk((A-B)-E, Etiquetas)
    ->  marca(E, X1, Y1, X2, Y2)
    ;   true
    ).

%!  marca(+E, +X1, +Y1, +X2, +Y2) is det.
%
%   Escribe la marca de la etiqueta E de la línea de (X1, Y1) a (X2, Y2):
%   el signo al costado del centro, o la punta de flecha en el centro, con
%   el cuerpo a la derecha en el sentido de la flecha.
marca(E, X1, Y1, X2, Y2) :-
    XM is (X1 + X2) / 2,
    YM is (Y1 + Y2) / 2,
    Largo is sqrt((X2 - X1)**2 + (Y2 - Y1)**2),
    DX is (X2 - X1) / Largo,
    DY is (Y2 - Y1) / Largo,
    marca_de(E, XM, YM, DX, DY).

%!  marca_de(+E, +XM, +YM, +DX, +DY) is det.
%
%   Escribe la marca de E en el centro (XM, YM) de una línea de dirección
%   unitaria (DX, DY), que va de la primera punta a la segunda.
marca_de(mas, XM, YM, DX, DY) :-
    signo("+", XM, YM, DX, DY).
marca_de(menos, XM, YM, DX, DY) :-
    signo("−", XM, YM, DX, DY).
marca_de(der, XM, YM, DX, DY) :-
    punta(XM, YM, DX, DY).
marca_de(izq, XM, YM, DX, DY) :-
    MX is -DX,
    MY is -DY,
    punta(XM, YM, MX, MY).

%!  signo(+Signo:string, +XM, +YM, +DX, +DY) is det.
%
%   Escribe Signo a 11 unidades del centro de la línea, hacia un costado.
signo(Signo, XM, YM, DX, DY) :-
    X is XM - DY * 11,
    Y is YM + DX * 11 + 5,
    format('  <text x="~1f" y="~1f" font-family="sans-serif" \c
            font-size="16" font-weight="bold" fill="#b03020" \c
            text-anchor="middle">~w</text>~n',
           [X, Y, Signo]).

%!  punta(+XM, +YM, +DX, +DY) is det.
%
%   Escribe una punta de flecha centrada en (XM, YM) que apunta en la
%   dirección (DX, DY).
punta(XM, YM, DX, DY) :-
    XA is XM + DX * 7,
    YA is YM + DY * 7,
    XB is XM - DX * 5 - DY * 5,
    YB is YM - DY * 5 + DX * 5,
    XC is XM - DX * 5 + DY * 5,
    YC is YM - DY * 5 - DX * 5,
    format('  <polygon points="~1f,~1f ~1f,~1f ~1f,~1f" fill="#1f5fa8"/>~n',
           [XA, YA, XB, YB, XC, YC]).

%!  escribir_nombre(+Puntos, +Caja, +P) is det.
%
%   Escribe el nombre del punto P junto a él.
escribir_nombre(Puntos, Caja, P) :-
    pantalla(Puntos, Caja, P, X0, Y0),
    X is X0 + 6,
    Y is Y0 - 6,
    format('  <text x="~1f" y="~1f" font-family="sans-serif" \c
            font-size="13" fill="#555555">~w</text>~n',
           [X, Y, P]).

%!  guardar_svg(+Texto:string, +Archivo) is det.
%
%   Escribe el Texto en el Archivo, en UTF-8.
guardar_svg(Texto, Archivo) :-
    setup_call_cleanup(open(Archivo, write, S, [encoding(utf8)]),
                       write(S, Texto),
                       close(S)).

%!  catalogo_svg(-Texto:string) is det.
%
%   Texto es el SVG de las 18 uniones del catálogo, una fila por tipo,
%   cada una con sus líneas en el orden del catálogo y sus etiquetas vistas
%   desde la unión.
catalogo_svg(Texto) :-
    findall(Tipo-Ls, union_posible(Tipo, Ls), Uniones),
    numerar(Uniones, 1, ninguno, Numeradas),
    findall(Ps-Ss-Es, ( member(N-(Tipo-Ls), Numeradas),
                        muestra(N, Tipo, Ls, Ps, Ss, Es) ), Muestras),
    pares(Muestras, Puntos, Lineas, Etiquetas),
    with_output_to(string(Texto),
                   escribir_svg(Puntos, Lineas, Etiquetas, no,
                                "Las 18 uniones del catálogo")).

%!  numerar(+Uniones:list, +I:integer, ?Anterior, -Numeradas:list) is det.
%
%   Numeradas son pares Columna/Fila-Union: la fila cambia con el tipo de
%   la unión, y la columna cuenta las uniones de la fila.
numerar([], _, _, []).
numerar([Tipo-Ls|Us], I, Anterior, [(C/F)-(Tipo-Ls)|Ns]) :-
    fila(Tipo, F),
    (   Tipo == Anterior
    ->  C = I
    ;   C = 1
    ),
    C1 is C + 1,
    numerar(Us, C1, Tipo, Ns).

% fila(Tipo, F): las uniones de Tipo van en la fila F del catálogo.
fila(ele, 0).
fila(horquilla, 1).
fila(flecha, 2).
fila(te, 3).

% brazos(Tipo, Extremos): los extremos de las líneas de una unión de Tipo,
% relativos a su centro, en el orden del catálogo.
brazos(ele, [0/12, 12/0]).
brazos(horquilla, [0/12, 10/ -6, -10/ -6]).
brazos(flecha, [-10/6, 0/12, 10/6]).
brazos(te, [-12/0, 12/0, 0/ -12]).

%!  muestra(+Pos, +Tipo, +Ls:list, -Ps:list, -Ss:list, -Es:list) is det.
%
%   Ps, Ss y Es son los puntos, las líneas y las etiquetas de la unión de
%   Tipo con etiquetas Ls, dibujada en la posición Pos = C/F.
muestra(C/F, Tipo, Ls, [u(F, C, 0)-(X0/Y0)|Ps], Ss, Es) :-
    X0 is C * 36,
    Y0 is -F * 36,
    brazos(Tipo, Bs),
    numlist(1, 3, Ks0),
    length(Bs, NB),
    length(Ks, NB),
    append(Ks, _, Ks0),
    maplist(extremo(F, C, X0, Y0), Ks, Bs, Ps),
    maplist(linea_de_muestra(F, C), Ks, Ss),
    maplist(etiqueta_de_muestra(F, C), Ks, Ls, Es).

%!  extremo(+F, +C, +X0, +Y0, +K, +Brazo, -Punto) is det.
%
%   Punto es el extremo K de la muestra de la fila F y la columna C.
extremo(F, C, X0, Y0, K, DX/DY, u(F, C, K)-(X/Y)) :-
    X is X0 + DX,
    Y is Y0 + DY.

%!  linea_de_muestra(+F, +C, +K, -L) is det.
%
%   L es la línea del centro de la muestra a su extremo K.
linea_de_muestra(F, C, K, u(F, C, 0)-u(F, C, K)).

%!  etiqueta_de_muestra(+F, +C, +K, +E, -Par) is det.
%
%   Par da a la línea K de la muestra la etiqueta E, vista desde el
%   centro, que es su primera punta.
etiqueta_de_muestra(F, C, K, E, (u(F, C, 0)-u(F, C, K))-E).

%!  pares(+Muestras:list, -Puntos:list, -Lineas:list, -Etiquetas:list)
%!      is det.
%
%   Junta los puntos, las líneas y las etiquetas de todas las Muestras.
pares(Muestras, Puntos, Lineas, Etiquetas) :-
    findall(P, ( member(Ps-_-_, Muestras), member(P, Ps) ), Puntos),
    findall(L, ( member(_-Ss-_, Muestras), member(L, Ss) ), Lineas),
    findall(E, ( member(_-_-Es, Muestras), member(E, Es) ), Etiquetas).

%!  generar_figuras(+Dir) is det.
%
%   Escribe en el directorio Dir las figuras del capítulo: el catálogo, el
%   cubo sin etiquetas, y el cubo, los bloques, el escalón y la escalera de
%   tres escalones con su interpretación con borde, y el poiuyt sin
%   etiquetas.
generar_figuras(Dir) :-
    catalogo_svg(Catalogo),
    directory_file_path(Dir, 'catalogo.svg', A1),
    guardar_svg(Catalogo, A1),
    svg(cubo, [], "Dibujo de un cubo, con los nombres de sus puntos", Cubo),
    directory_file_path(Dir, 'cubo.svg', A2),
    guardar_svg(Cubo, A2),
    forall(figura_etiquetada(F, Archivo, Titulo),
           ( once(etiquetar_waltz(F, borde, Ls)),
             svg(F, Ls, Titulo, Texto),
             directory_file_path(Dir, Archivo, Ruta),
             guardar_svg(Texto, Ruta) )),
    svg(poiuyt, [], "Un dibujo con las uniones del poiuyt", Poiuyt),
    directory_file_path(Dir, 'poiuyt-uniones.svg', A3),
    guardar_svg(Poiuyt, A3).

% figura_etiquetada(F, Archivo, Titulo): el dibujo F se guarda etiquetado
% en Archivo, con ese Titulo.
figura_etiquetada(cubo, 'cubo-etiquetado.svg',
                  "El cubo con su interpretación").
figura_etiquetada(bloques, 'bloques-etiquetado.svg',
                  "Dos cubos, uno delante del otro, con su interpretación").
figura_etiquetada(escalon, 'escalon-etiquetado.svg',
                  "Un bloque en forma de ele con su interpretación").
figura_etiquetada(escalera(3), 'escalera-etiquetada.svg',
                  "La escalera de tres escalones con su interpretación").
