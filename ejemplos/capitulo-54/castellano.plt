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

:- end_tests(castellano).
