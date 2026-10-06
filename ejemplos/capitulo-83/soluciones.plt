:- encoding(utf8).

:- begin_tests(soluciones).

% --- Ejercicio 1 ------------------------------------------------------------

test(v1_fin_primero, true(Q == ["FIN", "a"])) :-
    cribar(["FIN", "a"], "INICIO", "FIN", Q).

test(v2_fin_primero, error(marcas(fin_sin_inicio(1)))) :-
    cribar_seguro:cribar(["FIN", "a"], "INICIO", "FIN", _).

test(v1_inicio_al_final, true(Q == ["a"])) :-
    cribar(["a", "INICIO"], "INICIO", "FIN", Q).

test(v2_inicio_al_final, error(marcas(inicio_sin_fin(2)))) :-
    cribar_seguro:cribar(["a", "INICIO"], "INICIO", "FIN", _).

test(v1_secciones_vacias, true(Q == [])) :-
    cribar(["INICIO", "FIN", "INICIO", "FIN"], "INICIO", "FIN", Q).

test(v2_secciones_vacias, true(Q == [])) :-
    cribar_seguro:cribar(["INICIO", "FIN", "INICIO", "FIN"], "INICIO", "FIN",
                         Q).

test(v1_sangria, true(Q == [" INICIO", "a", "FIN"])) :-
    cribar([" INICIO", "a", "FIN"], "INICIO", "FIN", Q).

test(v2_sangria, error(marcas(fin_sin_inicio(3)))) :-
    cribar_seguro:cribar([" INICIO", "a", "FIN"], "INICIO", "FIN", _).

% --- Ejercicio 2 ------------------------------------------------------------

test(conservar, true(Q == ["b", "d", "e"])) :-
    conservar(["a", "INICIO", "b", "FIN", "c", "INICIO", "d", "e", "FIN"],
              "INICIO", "FIN", Q).

test(conservar_sin_secciones, true(Q == [])) :-
    conservar(["a", "b"], "INICIO", "FIN", Q).

test(conservar_sin_fin, error(marcas(inicio_sin_fin(2)))) :-
    conservar(["a", "INICIO", "b"], "INICIO", "FIN", _).

test(conservar_y_cribar_reparten, true(L1 + L2 + 4 =:= L)) :-
    Lineas = ["a", "INICIO", "b", "FIN", "c", "INICIO", "d", "e", "FIN"],
    length(Lineas, L),
    conservar(Lineas, "INICIO", "FIN", Q1),
    cribar_seguro:cribar(Lineas, "INICIO", "FIN", Q2),
    length(Q1, L1),
    length(Q2, L2).

% --- Ejercicio 3 ------------------------------------------------------------

test(sangria, true(Q == ["a", "  c"])) :-
    cribar_sangria(["a", "  INICIO", "b", "\tFIN", "  c"], "INICIO", "FIN",
                   Q).

test(sangria_sin_fin, error(marcas(inicio_sin_fin(2)))) :-
    cribar_sangria(["a", " INICIO", "b"], "INICIO", "FIN", _).

test(sin_sangria, true(R == "x  y")) :-
    sin_sangria(" \t x  y", R).

% --- Ejercicio 4 ------------------------------------------------------------

test(secciones, true(R == [2-4, 6-9])) :-
    secciones(["a", "INICIO", "b", "FIN", "c", "INICIO", "d", "e", "FIN"],
              "INICIO", "FIN", R).

test(secciones_examen, true(R == [9-13, 15-17])) :-
    secciones_archivo('archivos/examen_soluciones.tex', "\\solstart",
                      "\\solend", R).

% --- Ejercicio 5 ------------------------------------------------------------

test(pares, true(Q == ["a", "c", "e"])) :-
    cribar_pares(["a", "SOL", "b", "/SOL", "c", "NOTA", "d", "/NOTA", "e"],
                 ["SOL"-"/SOL", "NOTA"-"/NOTA"], Q).

test(pares_anidado, error(marcas(inicio_anidado(3, 2)))) :-
    cribar_pares(["a", "SOL", "NOTA", "/NOTA", "/SOL"],
                 ["SOL"-"/SOL", "NOTA"-"/NOTA"], _).

test(pares_fin_cruzado, error(marcas(fin_sin_inicio(3)))) :-
    cribar_pares(["a", "SOL", "/NOTA", "/SOL"],
                 ["SOL"-"/SOL", "NOTA"-"/NOTA"], _).

test(pares_fin_sin_inicio, error(marcas(fin_sin_inicio(2)))) :-
    cribar_pares(["a", "/NOTA"], ["SOL"-"/SOL", "NOTA"-"/NOTA"], _).

test(pares_sin_fin, error(marcas(inicio_sin_fin(2)))) :-
    cribar_pares(["a", "NOTA", "b"], ["SOL"-"/SOL", "NOTA"-"/NOTA"], _).

test(pares_un_par_igual_que_v2, true(Q1 == Q2)) :-
    Lineas = ["a", "INICIO", "b", "FIN", "c"],
    cribar_pares(Lineas, ["INICIO"-"FIN"], Q1),
    cribar_seguro:cribar(Lineas, "INICIO", "FIN", Q2).

% --- Ejercicio 6 ------------------------------------------------------------

test(decimales, true(As == ['2.0001', '0.0000', '10000000000.0000',
                            '12.0000'])) :-
    findall(A, ( member(X, [2.00005, -0.00004, 1.0e10, 12]),
                 phrase(decimal(X), C),
                 atom_codes(A, C) ),
            As).

% --- Ejercicios 7 y 8 -------------------------------------------------------

test(lissajous) :-
    curva(lissajous(3, 2, 0.5)),
    definir(tikz, lissajous, lissajous(3, 2, 0.5), 0, 2*pi, 100, T),
    sub_string(T, 0, _, _, "\\newcommand{\\lissajous}{\\draw (0.4794,0.0000)").

test(hipocicloide_cierra) :-
    muestra(hipocicloide(5, 3, 1), 0, 6*pi, 180, [X0-Y0|Ps]),
    last(Ps, X1-Y1),
    abs(X0 - X1) + abs(Y0 - Y1) < 1.0e-9.

test(hipocicloide_inicio, true(P == 3-0)) :-
    punto(hipocicloide(5, 3, 1), 0, X-Y),
    P = X0-Y0,
    X0 is round(X),
    Y0 is round(Y).

% La figura de las hipocicloides de la página de soluciones es la salida de
% dibujar/2.
test(figura_hipocicloides, true(Texto == Figura)) :-
    source_file(user:dibujar(_, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, 'archivos/hipocicloides.curvas', Ruta),
    curvas(Ruta, svg, Texto),
    directory_file_path(Directorio,
        '../../docs/capitulo-83-proyecto-procesamiento-textos/hipocicloides.svg',
        Svg),
    read_file_to_string(Svg, Figura, [encoding(utf8)]).

% --- Ejercicio 9 ------------------------------------------------------------

test(mensajes, true(Problemas == [nombre(c1), curva, intervalos(8.0),
                                  curva])) :-
    findall(P, ( member(T, [ curva(c1, circulo(0, 0, 1), 0, 1, 8),
                             curva(c, circulo(0, 0, _), 0, 1, 8),
                             curva(c, circulo(0, 0, 1), 0, 1, 8.0),
                             curva(c, recta, 0, 1, 8) ]),
                 catch(especificacion(T, 1, _),
                       error(especificacion(1, P0), _),
                       true),
                 resumir(P0, P) ),
            Problemas).

%!  resumir(+Problema, -Resumen) is det.
%
%   Resumen es Problema, salvo curva(_), que se resume como curva.
resumir(curva(_), curva) :-
    !.
resumir(P, P).

% --- Ejercicio 10 -----------------------------------------------------------

test(datos, true(T == "# dos curvas\n0.0000 1.0000\n2.0000 3.0000\n\n1.5000 -1.0000\n")) :-
    datos([comentario("dos curvas"), curva(a, [0-1, 2-3]),
           curva(b, [1.5-(-1)])], T).

test(datos_sin_curvas, true(T == "# nada\n")) :-
    datos([comentario("nada")], T).

:- end_tests(soluciones).
