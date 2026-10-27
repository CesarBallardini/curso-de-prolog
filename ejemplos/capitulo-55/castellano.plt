:- encoding(utf8).

:- begin_tests(castellano).

test(transitiva, all(A == [o(sn(el, gato, sg, [negro]), comer,
                             sn(un, manzana, sg, []))])) :-
    phrase(oracion_es(A),
           ["el", "gato", "negro", "come", "una", "manzana"]).

test(concordancia, all(A == [o(sn(el, casa, pl, [blanco, grande]),
                               dormir)])) :-
    phrase(oracion_es(A), ["las", "casas", "blancas", "grandes", "duermen"]).

test(genero_mal, fail) :-
    phrase(oracion_es(_), ["la", "gato", "duerme"]).

test(adjetivo_mal, fail) :-
    phrase(oracion_es(_), ["el", "gato", "negra", "duerme"]).

test(numero_mal, fail) :-
    phrase(oracion_es(_), ["los", "gatos", "duerme"]).

test(tacito, all(A == [o(tacito(sg), comer, sn(sin, manzana, pl, []))])) :-
    phrase(oracion_es(A), ["come", "manzanas"]).

test(pronombre, all(A == [o(pron(f, sg), ver, sn(el, perro, sg, []))])) :-
    phrase(oracion_es(A), ["ella", "ve", "el", "perro"]).

test(el_no_es_pronombre, fail) :-
    phrase(oracion_es(_), ["el", "duerme"]).

test(sujeto_sin_articulo, fail) :-
    phrase(oracion_es(_), ["gatos", "comen", "manzanas"]).

test(singular_sin_articulo, fail) :-
    phrase(oracion_es(_), ["come", "manzana"]).

test(intransitivo_con_objeto, fail) :-
    phrase(oracion_es(_), ["el", "gato", "duerme", "un", "libro"]).

test(generar, all(Ps == [["unas", "casas", "viejas", "grandes", "tienen",
                           "libros", "rojos"]])) :-
    phrase(oracion_es(o(sn(un, casa, pl, [viejo, grande]), tener,
                        sn(sin, libro, pl, [rojo]))),
           Ps).

test(generar_tacito, all(Ps == [["duermen"]])) :-
    phrase(oracion_es(o(tacito(pl), dormir)), Ps).

test(generar_pronombre, all(Ps == [["él", "corre"]])) :-
    phrase(oracion_es(o(pron(m, sg), correr)), Ps).

test(sujeto_sn, all(S-N == [sn(el, gato, sg, [])-sg])) :-
    phrase(sujeto_es(S, N), ["el", "gato"]).

% El sujeto tácito comparte el número con el verbo, todavía libre.
test(sujeto_tacito, [nondet, true(S-N =@= tacito(M)-M)]) :-
    phrase(sujeto_es(S, N), []).

test(sujeto_sin_articulo_mal, fail) :-
    phrase(sujeto_es(_, _), ["gatos"]).

% Como objeto, un plural sin artículo es un sintagma nominal.
test(sn_sin_articulo, all(SN == [sn(sin, gato, pl, [negro])])) :-
    phrase(sn_es(SN, pl), ["gatos", "negros"]).

test(sn_genera, all(Fs == [["una", "casa", "grande", "blanca"]])) :-
    phrase(sn_es(sn(un, casa, sg, [grande, blanco]), sg), Fs).

test(articulo, all(A-G-N == [el-f-pl])) :-
    phrase(articulo_es(A, G, N), ["las"]).

test(nombre, all(L-G-N == [casa-f-pl])) :-
    phrase(nombre_es(L, G, N), ["casas"]).

test(adjetivo, all(L-G-N == [blanco-f-pl])) :-
    phrase(adjetivo_es(L, G, N), ["blancas"]).

test(adjetivos, all(As == [[blanco, grande]])) :-
    phrase(adjetivos_es(As, f, pl), ["blancas", "grandes"]).

test(adjetivos_vacia, all(As == [[]])) :-
    phrase(adjetivos_es(As, m, sg), []).

test(numero_vocal, all(N == [pl])) :-
    numero_es(N, "gato", "gatos").

test(numero_consonante, true(F == "mujeres")) :-
    numero_es(pl, "mujer", F).

test(singular_variable, true(S == "negra")) :-
    singular_adjetivo(variable, negro, f, S).

test(singular_invariable, true(S == "grande")) :-
    singular_adjetivo(invariable, grande, f, S).

test(verbo_analiza, all(L-C-N == [dormir-intransitivo-pl])) :-
    phrase(verbo_es(L, C, N), ["duermen"]).

test(verbo_genera, all(Fs == [["come"]])) :-
    phrase(verbo_es(comer, transitivo, sg), Fs).

:- end_tests(castellano).
