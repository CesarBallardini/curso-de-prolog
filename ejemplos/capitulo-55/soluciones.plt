:- encoding(utf8).

:- begin_tests(soluciones).

test(ej1_ellas, true(Ts == ["They run."])) :-
    traducciones("Ellas corren.", Ts).

test(ej1_perros, true(Ts == ["Los perros blancos tienen un libro rojo."])) :-
    traducciones("The white dogs have a red book.", Ts).

test(ej2_mujer, true(Ts == ["The old woman reads a blue book."])) :-
    traducciones("La mujer vieja lee un libro azul.", Ts).

test(ej2_plurales, true(Ts == ["Las mujeres miran las casas azules."])) :-
    traducciones("The women watch the blue houses.", Ts).

test(ej3_gata, true(Ts == ["El gato negro duerme.",
                           "La gata negra duerme."])) :-
    traducciones("The black cat sleeps.", Ts).

test(ej4_no, true(Ts == ["The cat does not eat apples."])) :-
    traducciones("El gato no come manzanas.", Ts).

test(ej4_do, true(Ts == ["No duermen.", "Ellos no duermen.",
                         "Ellas no duermen."])) :-
    traducciones("They do not sleep.", Ts).

test(ej4_does, true(Ts == ["No tiene un libro.",
                           "Ella no tiene un libro."])) :-
    traducciones("She does not have a book.", Ts).

test(ej5_insensata, fail) :-
    traducir_sensato("El libro come una manzana.", _).

test(ej5_sensata, all(En == ["The house has a book."])) :-
    traducir_sensato("La casa tiene un libro.", En).

test(ej8_primera, true(Es == ["el", "gato", "duerme"])) :-
    once(al_castellano_por_largo(["the", "cat", "sleeps"], Es)).

test(ej8_no_termina, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(
        findall(Es, al_castellano_por_largo(["the", "cat", "sleeps"], Es), _),
        100000, R).

test(ej9_y, true(Ts == ["The cat and the dog sleep."])) :-
    traducciones("El gato y el perro duermen.", Ts).

test(ej9_and, true(Ts == ["Los gatos y los perros duermen.",
                          "Las gatas y los perros duermen."])) :-
    traducciones("Cats and dogs sleep.", Ts).

test(ej10_inferencias, true((integer(N1), integer(N2)))) :-
    inferencias(es_en(["el", "gato", "duerme"], _), N1),
    inferencias(en_es(["the", "cat", "sleeps"], _), N2).

test(ej11_igual_que_transferencia, true(I == T)) :-
    forall(member(Es, [["los", "gatos", "comen", "manzanas"],
                       ["come", "manzanas"],
                       ["el", "perro", "negro", "grande", "duerme"],
                       ["ellas", "ven", "unas", "casas", "rojas"]]),
           ( findall(En, es_en_interlingua(Es, En), I0),
             findall(En, es_en(Es, En), T0),
             msort(I0, I1), msort(T0, T1),
             I1 == T1 )),
    I = ok, T = ok.

test(ej12_del, true(Ts == ["She reads the cat's book."])) :-
    traducciones("Ella lee el libro del gato.", Ts).

test(ej12_plural, true(Ts == ["He sees the women's books."])) :-
    traducciones("Él ve los libros de las mujeres.", Ts).

test(ej12_apostrofo, true(Ts == ["She has the black dogs' house."])) :-
    traducciones("Ella tiene la casa de los perros negros.", Ts).

test(ej12_al_castellano, true(Ts == ["Ve la casa grande de las mujeres.",
                                     "Él ve la casa grande de las mujeres."
                                    ])) :-
    traducciones("He sees the women's big house.", Ts).

test(auxiliar, all(N == [sg])) :-
    phrase(auxiliar(N), ["does"]).

test(auxiliar_genera, all(Fs == [["do"]])) :-
    phrase(auxiliar(pl), Fs).

test(sensata) :-
    sensata(o(sn(el, gato, sg, []), comer, sn(un, manzana, sg, []))).

test(insensata, fail) :-
    sensata(o(sn(el, libro, sg, []), comer, sn(un, manzana, sg, []))).

test(sensata_negada) :-
    sensata(neg(o(sn(el, casa, sg, []), tener, sn(un, libro, sg, [])))).

test(sujeto_tacito) :-
    sujeto_posible(tacito(sg), comer).

test(sujeto_coordinado) :-
    sujeto_posible(y(sn(el, gato, sg, []), sn(el, perro, sg, [])), dormir).

test(sujeto_coordinado_insensato, fail) :-
    sujeto_posible(y(sn(el, gato, sg, []), sn(el, libro, sg, [])), dormir).

test(interlingua_es, all(I == [evento(dormir, persona(f, sg))])) :-
    interlingua_es(o(pron(f, sg), dormir), I).

% En sentido inverso, el sujeto tácito admite cualquier género.
test(interlingua_es_inversa,
     all(A == [o(tacito(sg), comer, sn(un, manzana, sg, [rojo])),
               o(pron(f, sg), comer, sn(un, manzana, sg, [rojo]))])) :-
    interlingua_es(A, evento(comer, persona(f, sg),
                             ent(indefinido, manzana, sg, [rojo]))).

test(agente_es_generico, all(I == [ent(definido, gato, pl, []),
                                   ent(generico, gato, pl, [])])) :-
    agente_es(sn(el, gato, pl, []), I).

test(entidad_es, all(I == [ent(ninguna, manzana, pl, [])])) :-
    entidad_es(sn(sin, manzana, pl, []), I).

test(interlingua_en, all(I == [evento(dormir, persona(f, sg))])) :-
    interlingua_en(o(pron(she), sleep), I).

test(agente_en_they, [true(I =@= persona(_, pl))]) :-
    agente_en(pron(they), I).

test(agente_en_generico, all(I == [ent(generico, gato, pl, []),
                                   ent(generico, gata, pl, [])])) :-
    agente_en(sn(sin, [], cat, pl), I).

test(entidad_en, all(I == [ent(indefinido, gato, sg, [negro, grande]),
                           ent(indefinido, gata, sg, [negro, grande])])) :-
    entidad_en(sn(a, [big, black], cat, sg), I).

test(posesivo, [true(Ms == ["cat's", "cats'", "women's"])]) :-
    posesivo(sg, "cat", "cats", M1),
    posesivo(pl, "cat", "cats", M2),
    posesivo(pl, "woman", "women", M3),
    Ms = [M1, M2, M3].

test(posesivo_numero, all(N == [pl])) :-
    posesivo(N, "cat", "cats", "cats'").

test(del, all(G-N == [m-sg])) :-
    phrase(de_articulo(G, N), ["del"]).

test(de_las, all(G-N == [f-pl])) :-
    phrase(de_articulo(G, N), ["de", "las"]).

test(de_el_mal, fail) :-
    phrase(de_articulo(_, _), ["de", "el"]).

test(poseedor_es, all(P == [sn(el, gato, sg, [])])) :-
    phrase(poseedor_es(P), ["del", "gato"]).

test(poseedor_en, all(P == [sn(the, [], cat, sg)])) :-
    phrase(poseedor_en(P), ["the", "cat's"]).

test(poseedor_en_plural, all(P == [sn(the, [], dog, pl)])) :-
    phrase(poseedor_en(P), ["the", "dogs'"]).

test(sn_posesion, all(En == [gen(sn(the, [], cat, sg), [], book, sg)])) :-
    sn(de(sn(el, libro, sg, []), sn(el, gato, sg, [])), En).

:- end_tests(soluciones).
