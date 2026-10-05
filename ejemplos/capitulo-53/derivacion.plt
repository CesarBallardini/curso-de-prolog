:- encoding(utf8).

:- begin_tests(derivacion).

test(adverbio_genera, all(P == ["rápidamente"])) :-
    derivada(P, adverbio("rápido")).

% El adjetivo conserva su tilde y su z: -mente no es un sufijo como los
% otros.
test(adverbio_tilde, all(D == [adverbio("fácil")])) :-
    derivada("fácilmente", D).

test(adverbio_z, all(D == [adverbio("feliz")])) :-
    derivada("felizmente", D).

% La regla sobregenera: el léxico no sabe qué adverbios se usan.
test(adverbio_sobregenera, all(D == [adverbio("joven")])) :-
    derivada("jovenmente", D).

test(adverbio_de_un_prefijado, all(D == [adverbio("inútil")])) :-
    derivada("inútilmente", D).

test(diminutivos, [true(Ps == ["casita", "librito", "sofacito",
                               "mesecito", "arbolito", "lucecita",
                               "lapicito", "pececito", "camioncito",
                               "cancioncita", "examencito", "imagencita",
                               "saquito", "laguito", "eleccioncita",
                               "proteccioncita"])]) :-
    findall(P, derivada(P, diminutivo(_)), Ps).

test(diminutivo_analiza, all(D == [diminutivo("luz")])) :-
    derivada("lucecita", D).

test(diminutivo_inexistente, [fail]) :-
    derivada("lucita", diminutivo(_)).

test(diminutivo_3, [true(D == "saquito")]) :-
    diminutivo("saco", masculino, D).

test(sufijo_vocal, [true(R-S == [l, i, b, r]-[i, t, o])]) :-
    sufijo([l, i, b, r, o], o, o, R, S).

test(sufijo_vocal_con_tilde, [true(R-S == [s, o, f, a]-[z, i, t, o])]) :-
    sufijo([s, o, f, a], 'á', o, R, S).

test(sufijo_una_silaba, [true(R-S == [l, u, z]-[e, z, i, t, a])]) :-
    sufijo([l, u, z], z, a, R, S).

test(sufijo_n, [true(R-S == [k, a, m, i, o, n]-[z, i, t, o])]) :-
    sufijo([k, a, m, i, o, n], n, o, R, S).

test(sufijo_consonante, [true(R-S == [a, r, b, o, l]-[i, t, o])]) :-
    sufijo([a, r, b, o, l], l, o, R, S).

test(sin_tilde, [true(Ls == [a, o, n])]) :-
    maplist(sin_tilde, ['á', o, n], Ls).

test(accion, all(D == [accion("elegir")])) :-
    derivada("elección", D).

test(accion_plural, all(A == [nombre("elección", femenino, plural)])) :-
    forma("elecciones", A).

test(prefijos, [true(Ps == ["deshacer", "desproteger", "recontar",
                            "reelegir", "infeliz", "imposible",
                            "inútil"])]) :-
    findall(P, derivada(P, prefijo(_, _)), Ps).

test(con_in, [true(Ps == ["infeliz", "imposible", "inútil"])]) :-
    maplist(con_in, ["feliz", "posible", "útil"], Ps).

test(escribir_regla, [true(P == "lucecita")]) :-
    escribir_regla([l, u, z, e, z, i, t, a], P).

% Un verbo con prefijo hereda la clase y las formas irregulares.
test(deshacer, [true(Ps == ["deshago", "deshizo"])]) :-
    findall(P, forma(P, verbo("deshacer", presente, 1, singular)), P1),
    findall(P, forma(P, verbo("deshacer", preterito, 3, singular)), P2),
    append(P1, P2, Ps).

test(recontar, all(A == [verbo("recontar", presente, 1, singular)])) :-
    forma("recuento", A).

test(reelegir, [true(Ps == ["reeligió"])]) :-
    findall(P, forma(P, verbo("reelegir", preterito, 3, singular)), Ps).

test(sin_doble_prefijo, [fail]) :-
    lexico:verbo("desdeshacer", _).

test(adjetivo_con_in, [true(As == [adjetivo("infeliz", masculino, plural),
                                   adjetivo("infeliz", femenino, plural)])]) :-
    findall(A, forma("infelices", A), As).

:- end_tests(derivacion).
