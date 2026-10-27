:- encoding(utf8).

:- begin_tests(traductor).

test(al_ingles, all(En == ["The black cat eats an apple."])) :-
    traducir("El gato negro come una manzana.", En).

test(al_castellano, all(Es == ["El perro negro grande ve una casa vieja."])) :-
    traducir(Es, "The big black dog sees an old house.").

test(comprobar, [nondet]) :-
    traducir("Él duerme.", "He sleeps.").

test(tacito, true(Ts == ["He eats apples.", "She eats apples.",
                         "It eats apples."])) :-
    traducciones("Come manzanas.", Ts).

test(generico, true(Ts == ["The black cats eat apples.",
                           "Black cats eat apples."])) :-
    traducciones("Los gatos negros comen manzanas.", Ts).

test(sujeto_generico, true(Ts == ["Los gatos comen manzanas."])) :-
    traducciones("Cats eat apples.", Ts).

test(they, true(Ts == ["Leen libros.", "Ellos leen libros.",
                       "Ellas leen libros."])) :-
    traducciones("They read books.", Ts).

test(he, true(Ts == ["Duerme.", "Él duerme."])) :-
    traducciones("He sleeps.", Ts).

test(sinonimos, true(Ts == ["The big house has a cat.",
                            "The large house has a cat."])) :-
    traducciones("La casa grande tiene un gato.", Ts).

test(ninguna, true(Ts == [])) :-
    traducciones("The cat black eats.", Ts).

test(palabras, true(Ps == ["el", "gato", "duerme"])) :-
    palabras("  El  gato duerme. ", Ps).

test(texto, true(T == "Él come.")) :-
    texto(["él", "come"], T).

test(ingenuo_directo, [nondet, true(En == ["he", "sleeps"])]) :-
    traducir_ingenuo(["él", "duerme"], En).

test(ingenuo_inverso, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(
        findall(Es, traducir_ingenuo(Es, ["the", "cat", "sleeps"]), _),
        100000, R).

test(sin_instanciar, error(instantiation_error)) :-
    traducir(_, _).

test(es_en, all(En == [["the", "cat", "sleeps"]])) :-
    es_en(["el", "gato", "duerme"], En).

test(en_es, all(Es == [["duermen"], ["ellos", "duermen"],
                       ["ellas", "duermen"]])) :-
    en_es(["they", "sleep"], Es).

test(es_en_no_es_oracion, fail) :-
    es_en(["gato", "el", "duerme"], _).

:- end_tests(traductor).
