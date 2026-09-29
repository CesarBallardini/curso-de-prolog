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

:- end_tests(soluciones).
