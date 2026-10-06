:- encoding(utf8).

:- begin_tests(soluciones).

test(tres, [true(Fs == [0, 0, 1, 0, 0, 1, 0, 0, 1])]) :-
    figuras(tres, b, 9, Fs).

test(ceros_unos, [true(Fs == [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1])]) :-
    figuras(ceros_unos, inicio, 12, Fs).

test(ceros_unos_infinita, [true(R = incompleta(_))]) :-
    completa(ceros_unos, inicio, [0, 1, schwa], 500, R).

test(cr, [true(Ss == [schwa, schwa, 1, x, 0, x, 1, blanco, 0])]) :-
    cinta_de([schwa, schwa, 1, x, 0, x], 0, C0),
    ejecutar(biblioteca, cr(fin, x), C0, 10000, detenida(fin, C)),
    contenido(C, Ss).

test(ciclo, [throws(error(ciclo_de_alias(uno), _))]) :-
    resolver_seguro(circular, uno, _, _).

test(sin_ciclo, [true(Q-N == emite(b, 0)-1)]) :-
    resolver_seguro(alterna, a, Q, N).

test(alcanzable, [true(Xs == Ys)]) :-
    findall(X, alcanzable(ii, b, [0, 1, schwa, x], X), Xs0),
    sort(Xs0, Xs),
    completa(ii, b, [0, 1, schwa, x], 100, tabla(Ys0, _)),
    sort(Ys0, Ys).

test(sd_numero, [true(SD == "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;")]) :-
    sd_numero(SD, 31332531173113353111731113322531111731111335317).

test(ida_y_vuelta, [true(N == N0)]) :-
    numero(ii, b, [0, 1, schwa, x], N0),
    sd_numero(SD, N0),
    sd_numero(SD, N).

test(instrucciones_de, [true(Is == [i(1, 0, 1, r, 2), i(2, 0, 0, r, 3),
                                    i(3, 0, 2, r, 4), i(4, 0, 0, r, 1)])]) :-
    instrucciones_de("DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;", Is).

test(figuras_dn_i, [true(Fs == [0, 1, 0, 1, 0, 1])]) :-
    figuras_dn(31332531173113353111731113322531111731111335317, 6, Fs).

test(figuras_dn_ii, [true(Fs == Gs)]) :-
    numero(ii, b, [0, 1, schwa, x], N),
    figuras_dn(N, 20, Fs),
    figuras(ii, b, 20, Gs).

test(e_desde_el_final, [true(Ss == [schwa, schwa, 1, blanco, 0, blanco, 1])]) :-
    cinta_de([schwa, schwa, 1, a, 0, a, 1], 0, C0),
    ejecutar(biblioteca, q(e(fin)), C0, 1000, detenida(fin, C)),
    contenido(C, Ss).

test(e_desde_el_comienzo, [true(Ss == [schwa, schwa, blanco, a, blanco, a])]) :-
    cinta_de([schwa, schwa, 1, a, 0, a, 1], 0, C0),
    ejecutar(biblioteca, e(fin), C0, 1000, detenida(fin, C)),
    contenido(C, Ss).

test(re_todas, [true(Ss == [schwa, schwa, 1, blanco, 1, blanco, 1])]) :-
    cinta_de([schwa, schwa, 1, blanco, 0, blanco, 0], 0, C0),
    ejecutar(biblioteca, re(fin, 0, 1), C0, 1000, detenida(fin, C)),
    contenido(C, Ss).

test(rapido, [true(M == medida(121, 14, 33))]) :-
    medir(rapido, inicio, 120, M).

test(rapido_figuras, [true(Fs == Gs)]) :-
    figuras(rapido, inicio, 30, Fs),
    figuras(ii, b, 30, Gs).

test(cuenta_mas_larga_primero, [all(N-R == [2-"D", 1-"AD", 0-"AAD"])]) :-
    string_codes("AAD", Cs),
    phrase(cuenta(0'A, N), Cs, Resto),
    string_codes(R, Resto).

test(cuenta_ninguna, [true(N == 0)]) :-
    phrase(cuenta(0'A, N), `D`, `D`).

test(instruccion_sd, [all(I == [i(1, 0, 1, r, 2)])]) :-
    phrase(instruccion_sd(I), `DADDCRDAA;`).

test(instruccion_sd_mal_formada, [fail]) :-
    phrase(instruccion_sd(_), `DADDCXDAA;`).

test(instrucciones_sd, [all(Is == [[i(1, 0, 1, r, 2), i(2, 0, 0, l, 1)]])]) :-
    phrase(instrucciones_sd(Is), `DADDCRDAA;DAADDLDA;`).

test(instrucciones_sd_vacia, [all(Is == [[]])]) :-
    phrase(instrucciones_sd(Is), []).

test(sd_numero_inverso, [true(N == 3137)]) :-
    sd_numero("DAD;", N).

test(instruccion_estandar, [true(I == i(1, blanco, e(1, n), s(3)))]) :-
    instruccion_estandar(i(1, 0, 2, n, s(3)), I).

test(simbolos, [true(Ss == [blanco, 0, 1, s(3), s(7)])]) :-
    maplist(simbolo_numero, Ss, [0, 1, 2, 3, 7]).

% figuras/4 cuenta cada figura impresa; U, solo las impresas en un blanco.
test(reimprime, [true(Fs-Us == [0, 1, 0, 1]-[0, 0, 0, 0])]) :-
    figuras(reimprime, b, 4, Fs),
    universal(reimprime, b, [0, 1], 4, Us).

test(reimprime_descripcion,
     [true(SD == "DADDCNDAA;DAADCDCCRDAAA;DAAADDRDA;DAAADCDCRDA;DAAADCCDCCRDA;")]) :-
    descripcion(reimprime, b, [0, 1], SD).

% U no detecta que la máquina se detuvo: kom sigue buscando hacia la
% izquierda una instrucción.
test(corta, [true(Q-T == kom-":DAD:0:DCDAAD")]) :-
    descripcion(corta, b, [0, 1], SD),
    cinta_universal(SD, C0),
    ejecutar(universal, b, C0, 200000, limite(Q, C)),
    escrito(C, T).

:- end_tests(soluciones).
