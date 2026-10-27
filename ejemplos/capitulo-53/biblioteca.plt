:- encoding(utf8).

:- begin_tests(biblioteca).

%!  ejecuta(+Q0, +Simbolos:list, +Posicion, -Q, -Contenido:list) is semidet.
%
%   La biblioteca, desde Q0 con la cinta Simbolos y el cabezal en
%   Posicion, se detiene en Q con el Contenido en la cinta.
ejecuta(Q0, Simbolos, Posicion, Q, Contenido) :-
    cinta_de(Simbolos, Posicion, C0),
    ejecutar(biblioteca, Q0, C0, 10000, detenida(Q, C)),
    contenido(C, Contenido).

test(contador, [true(Fs == [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])]) :-
    figuras(contador, inicio, 15, Fs).

test(f_encuentra, [true(S == x)]) :-
    cinta_de([schwa, a, x, b], 3, C0),
    ejecutar(biblioteca, f(fin, falta, x), C0, 100, detenida(fin, C)),
    leer(C, S).

test(f_falta, [true(Q == fin)]) :-
    ejecuta(f(encontrada, fin, x), [schwa, a, b], 2, Q, _).

test(e_primera, [true(Ss == [schwa, schwa, 1, blanco, 0, x])]) :-
    ejecuta(e(fin, falta, x), [schwa, schwa, 1, x, 0, x], 5, fin, Ss).

test(e_todas, [true(Ss == [schwa, schwa, 1, blanco, 0])]) :-
    ejecuta(e(fin, x), [schwa, schwa, 1, x, 0, x], 5, fin, Ss).

test(pe, [true(Ss == [schwa, schwa, 1, blanco, 0])]) :-
    ejecuta(pe(fin, 0), [schwa, schwa, 1], 0, fin, Ss).

test(pe2, [true(Ss == [schwa, schwa, 0, blanco, 1])]) :-
    ejecuta(pe2(fin, 0, 1), [schwa, schwa], 0, fin, Ss).

test(c, [true(Ss == [schwa, schwa, 1, blanco, 0, x, 0])]) :-
    ejecuta(c(fin, falta, x), [schwa, schwa, 1, blanco, 0, x], 0, fin, Ss).

test(ce, [true(Ss == [schwa, schwa, 1, blanco, 0, blanco, 1, blanco, 0])]) :-
    ejecuta(ce(fin, a), [schwa, schwa, 1, a, 0, a], 0, fin, Ss).

test(ce2, [true(Ss == [schwa, schwa, 1, blanco, 0, blanco, 1, blanco, 0])]) :-
    ejecuta(ce2(fin, a, b), [schwa, schwa, 1, a, 0, b], 0, fin, Ss).

test(re, [true(Ss == [schwa, schwa, 1, b, 0, b])]) :-
    ejecuta(re(fin, a, b), [schwa, schwa, 1, a, 0, a], 0, fin, Ss).

test(cp, [true(Qs == [igual, distinto, ninguna])]) :-
    ejecuta(cp(igual, distinto, ninguna, a, b), [schwa, schwa, 1, a, 1, b],
            0, Q1, _),
    ejecuta(cp(igual, distinto, ninguna, a, b), [schwa, schwa, 1, a, 0, b],
            0, Q2, _),
    ejecuta(cp(igual, distinto, ninguna, a, b), [schwa, schwa, 1, blanco, 0],
            0, Q3, _),
    Qs = [Q1, Q2, Q3].

test(cpe_iguales, [true(Q-Ss == iguales-[schwa, schwa, 1, blanco, 0, blanco,
                                         1, blanco, 0])]) :-
    ejecuta(cpe(distintas, iguales, a, b),
            [schwa, schwa, 1, a, 0, a, 1, b, 0, b], 0, Q, Ss).

test(cpe_distintas, [true(Q == distintas)]) :-
    ejecuta(cpe(distintas, iguales, a, b),
            [schwa, schwa, 1, a, 0, a, 1, b, 1, b], 0, Q, _).

test(q, [true(S-N == a-5)]) :-
    cinta_de([schwa, schwa, 1, a, 0, a, 1], 0, C0),
    ejecutar(biblioteca, q(fin, a), C0, 1000, detenida(fin, C)),
    C = c(I, S, _),
    length(I, N).

test(e_marcas, [true(Ss == [schwa, schwa, 1, blanco, 0, blanco, 1])]) :-
    ejecuta(e(fin), [schwa, schwa, 1, a, 0, a, 1], 6, fin, Ss).

test(sin_regla, [true(R = detenida(nada(x), _))]) :-
    cinta_de([schwa], 0, C0),
    ejecutar(biblioteca, nada(x), C0, 10, R).

:- end_tests(biblioteca).
