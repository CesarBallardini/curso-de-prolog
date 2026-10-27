:- encoding(utf8).

:- begin_tests(numeros).

test(descripcion_i, [true(SD == "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;")]) :-
    descripcion(i, b, [0, 1], SD).

test(numero_i, [true(N == 31332531173113353111731113322531111731111335317)]) :-
    numero(i, b, [0, 1], N).

test(estandar_ii, [true(NE-NI == 15-70)]) :-
    tabla_estandar(ii, b, [0, 1, schwa, x], tabla(Es, Is)),
    length(Es, NE),
    length(Is, NI).

test(misma_sucesion, [true(Fs == Gs)]) :-
    tabla_estandar(ii, b, [0, 1, schwa, x], T),
    figuras_estandar(T, 30, Fs),
    figuras(ii, b, 30, Gs).

test(resto, [true(A-Q1 == e(schwa, r)-resto([p(schwa), r, p(0), r, r,
                                               p(0), l, l], o))]) :-
    estandar(ii, b, blanco, A, Q1).

test(sin_operaciones, [true(A-Q1 == e(0, n)-q)]) :-
    estandar(ii, o, 0, A, Q1).

test(borrar, [true(A-Q1 == e(blanco, n)-resto([p(y)], fin))]) :-
    estandar(biblioteca, re1(fin, falta, x, y), x, A, Q1).

test(contador, [fail]) :-
    numero(contador, inicio, [0, 1, schwa], _).

test(dos_maquinas, [true(N1 \== N2)]) :-
    numero(i, b, [0, 1], N1),
    numero(i_bis, b, [0, 1], N2).

test(grupo_imprimir_mover, [true(W-Mov-Ops == 0-r-[p(1)])]) :-
    numeros:grupo([p(0), r, p(1)], blanco, W, Mov, Ops).

test(grupo_borrar, [true(W-Mov-Ops == blanco-l-[])]) :-
    numeros:grupo([e, l], x, W, Mov, Ops).

test(grupo_solo_mover, [true(W-Mov-Ops == x-r-[r])]) :-
    numeros:grupo([r, r], x, W, Mov, Ops).

test(grupo_vacio, [true(W-Mov-Ops == 1-n-[])]) :-
    numeros:grupo([], 1, W, Mov, Ops).

test(grupo_dos_impresiones, [true(W-Mov-Ops == 0-n-[p(1)])]) :-
    numeros:grupo([p(0), p(1)], blanco, W, Mov, Ops).

test(letras, [true(Cs == "AAA")]) :-
    phrase(numeros:letras(0'A, 3), Codigos),
    string_codes(Cs, Codigos).

test(letras_cero, [true(Codigos == [])]) :-
    phrase(numeros:letras(0'C, 0), Codigos).

test(instrucciones_dcg, [true(SD == "DADCDCCRDAA;DAADDNDA;")]) :-
    phrase(numeros:instrucciones([i(b, 0, e(1, r), c),
                                  i(c, blanco, e(blanco, n), b)],
                                 [b, c], [blanco, 0, 1]),
           Codigos),
    string_codes(SD, Codigos).

test(instrucciones_vacia, [true(Codigos == [])]) :-
    phrase(numeros:instrucciones([], [b], [blanco]), Codigos).

:- end_tests(numeros).
