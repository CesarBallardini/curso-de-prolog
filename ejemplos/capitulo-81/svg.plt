:- encoding(utf8).

:- begin_tests(svg).

%!  cuenta(+Texto:string, +Sub:string, -N:integer) is det.
%
%   N es la cantidad de apariciones de Sub en Texto.
cuenta(Texto, Sub, N) :-
    aggregate_all(count, sub_string(Texto, _, _, _, Sub), N).

test(cubo_sin_etiquetas, [true(Ns == [9, 0, 0, 7])]) :-
    svg(cubo, [], "Cubo", T),
    cuenta(T, "<line", L),
    cuenta(T, "<polygon", P),
    cuenta(T, ">+<", S),
    cuenta(T, "font-size=\"13\"", Nombres),
    Ns = [L, P, S, Nombres].

test(cubo_etiquetado, [true(Ns == [6, 3])]) :-
    Ls = [(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
          (c-e)-izq, (c-f)-der, (d-f)-izq, (d-g)-der],
    svg(cubo, Ls, "Cubo", T),
    cuenta(T, "<polygon", P),
    cuenta(T, ">+<", S),
    Ns = [P, S].

test(titulo) :-
    svg(cubo, [], "Un cubo", T),
    sub_string(T, _, _, _, "<title id=\"t\">Un cubo</title>"),
    !.

test(catalogo, [true(Ns == [48, 22, 26])]) :-
    catalogo_svg(T),
    cuenta(T, "<line", L),
    cuenta(T, ">+<", Mas),
    cuenta(T, ">−<", Menos),
    cuenta(T, "<polygon", P),
    Signos is Mas + Menos,
    Ns = [L, Signos, P].

test(caja, [true(C == caja(0, 10, 36, 440, 440))]) :-
    caja([a-(0/0), b-(10/10)], C).

test(pantalla, [true(XY == 40/40)]) :-
    pantalla([a-(0/10)], caja(0, 10, 36, 440, 440), a, X, Y),
    XY = X/Y.

test(marca_de_mas) :-
    with_output_to(string(T), marca_de(mas, 0, 0, 1, 0)),
    sub_string(T, _, _, _, ">+<"),
    !.

test(punta_hacia_la_derecha) :-
    with_output_to(string(T), marca(der, 0, 0, 10, 0)),
    sub_string(T, _, _, _, "<polygon points=\"12.0,0.0"),
    !.

test(punta_invertida) :-
    with_output_to(string(T), marca(izq, 0, 0, 10, 0)),
    sub_string(T, _, _, _, "<polygon points=\"-2.0,0.0"),
    !.

test(signo) :-
    with_output_to(string(T), signo("−", 0, 0, 1, 0)),
    sub_string(T, _, _, _, ">−<"),
    !.

test(guardar, [cleanup(delete_file(Archivo))]) :-
    tmp_file(svg, Archivo),
    guardar_svg("<svg/>", Archivo),
    read_file_to_string(Archivo, T, [encoding(utf8)]),
    T == "<svg/>".

test(numerar, [true(Ns == [(1/0)-(ele-a), (2/0)-(ele-b),
                           (1/2)-(flecha-c)])]) :-
    numerar([ele-a, ele-b, flecha-c], 1, ninguno, Ns).

test(muestra, [true(N-M == 3-2)]) :-
    muestra(1/0, ele, [der, izq], Ps, Ss, _),
    length(Ps, N),
    length(Ss, M).

test(extremo, [true(P == u(0, 1, 2)-(12/0))]) :-
    extremo(0, 1, 0, 0, 2, 12/0, P).

test(linea_de_muestra, [true(L == u(0, 1, 0)-u(0, 1, 2))]) :-
    linea_de_muestra(0, 1, 2, L).

test(etiqueta_de_muestra, [true(E == (u(0, 1, 0)-u(0, 1, 2))-mas)]) :-
    etiqueta_de_muestra(0, 1, 2, mas, E).

test(pares, [true(R == [[p], [l], [e]])]) :-
    pares([[p]-[l]-[e]], Ps, Ls, Es),
    R = [Ps, Ls, Es].

test(escribir_nombre) :-
    with_output_to(string(T),
                   escribir_nombre([a-(0/0)], caja(0, 0, 4, 48, 48), a)),
    sub_string(T, _, _, _, ">a<"),
    !.

test(escribir_linea) :-
    with_output_to(string(T),
                   escribir_linea([a-(0/0), b-(1/0)],
                                  caja(0, 0, 4, 52, 48), [], a-b)),
    sub_string(T, _, _, _, "<line"),
    !.

test(generar_figuras, [true(N == 7)]) :-
    tmp_file(figuras, Dir),
    make_directory(Dir),
    generar_figuras(Dir),
    directory_files(Dir, Archivos),
    include([A]>>file_name_extension(_, svg, A), Archivos, Svgs),
    length(Svgs, N),
    delete_directory_and_contents(Dir).

test(figura_etiquetada, [true(N == 4)]) :-
    aggregate_all(count, figura_etiquetada(_, _, _), N).

:- end_tests(svg).
