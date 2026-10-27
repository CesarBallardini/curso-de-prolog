:- encoding(utf8).

:- begin_tests(curvas).

%!  cerca(+P:pair, +Q:pair) is semidet.
%
%   Los puntos P y Q difieren en menos de una millonésima.
cerca(X1-Y1, X2-Y2) :-
    abs(X1 - X2) + abs(Y1 - Y2) < 1.0e-6.

test(punto_cicloide_igual_que_la_version_1) :-
    punto(cicloide(5, 8), 1.3, P),
    cicloide:cicloide(5, 8, 1.3, Q),
    cerca(P, Q).

test(punto_circulo, true(cerca(P, 2-13))) :-
    punto(circulo(2, 3, 10), pi/2, P).

test(punto_espiral_inicio, true(P == 1.0-0.0)) :-
    punto(espiral(0.2), 0, P).

test(punto_espiral_una_vuelta, true(cerca(P, E-0))) :-
    punto(espiral(0.2), 2*pi, P),
    E is exp(0.4 * pi).

test(clase_desconocida, [fail]) :-
    punto(parabola(1), 0, _).

test(curva) :-
    curva(cicloide(5, 8)),
    curva(circulo(0, 0, 1)),
    curva(espiral(0.1)).

test(curva_desconocida, [fail]) :-
    curva(parabola(1)).

test(curva_parametro_no_numerico, [fail]) :-
    curva(circulo(0, 0, r)).

test(curva_aridad_equivocada, [fail]) :-
    curva(circulo(0, 1)).

test(muestra, true(L == 9)) :-
    muestra(circulo(0, 0, 1), 0, 2*pi, 8, Ps),
    length(Ps, L).

test(muestra_cierra_el_circulo) :-
    muestra(circulo(0, 0, 1), 0, 2*pi, 8, [P|Ps]),
    last(Ps, U),
    cerca(P, U).

test(epic, true(T == "\\newcommand{\\c}{\\drawline(1.0000,0.0000)(-1.0000,0.0000)(1.0000,0.0000)}")) :-
    muestra(circulo(0, 0, 1), 0, 2*pi, 2, Ps),
    definicion(epic, c, Ps, T).

test(tikz, true(T == "\\newcommand{\\c}{\\draw (1.0000,0.0000) -- (-1.0000,0.0000) -- (1.0000,0.0000);}")) :-
    muestra(circulo(0, 0, 1), 0, 2*pi, 2, Ps),
    definicion(tikz, c, Ps, T).

test(definir, true(T == U)) :-
    definir(epic, e, espiral(0.1), 0, 4*pi, 20, T),
    muestra(espiral(0.1), 0, 4*pi, 20, Ps),
    definicion(epic, e, Ps, U).

test(svg_invierte_y, true(T == "<polyline id=\"c\" points=\"0.0000,-1.0000 2.0000,-3.0000\"/>")) :-
    definicion(svg, c, [0-1, 2-3], T).

test(documento_tikz, true(T == "% dos puntos\n\\newcommand{\\c}{\\draw (0.0000,1.0000) -- (2.0000,3.0000);}\n")) :-
    documento(tikz, [comentario("dos puntos"), curva(c, [0-1, 2-3])], T).

test(documento_svg, true(T == "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"-0.1000 -3.1000 2.2000 2.2000\" fill=\"none\" stroke-width=\"0.0110\" stroke-linejoin=\"round\">\n<!-- dos puntos -->\n<g stroke=\"#1f4e79\"><polyline id=\"c\" points=\"0.0000,-1.0000 2.0000,-3.0000\"/></g>\n</svg>\n")) :-
    documento(svg, [comentario("dos puntos"), curva(c, [0-1, 2-3])], T).

test(documento_svg_colores, true(Colores == ['#1f4e79', '#c0392b', '#1e8449'])) :-
    documento(svg, [curva(a, [0-0]), curva(b, [1-1]), curva(c, [2-2])], T),
    findall(C, ( sub_string(T, Antes, _, _, "stroke=\"#"),
                 Desde is Antes + 8,
                 sub_string(T, Desde, 7, _, S),
                 atom_string(C, S) ),
            Colores).

:- end_tests(curvas).
