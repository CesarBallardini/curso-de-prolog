:- encoding(utf8).

:- begin_tests(guiones).

test(restaurante, true(G-E ==
        restaurante-[ ir(juan, casa, leones),
                      sentarse(juan, mesa),
                      pedir(juan, hamburguesa, mozo),
                      traer(mozo, hamburguesa, juan),
                      comer(juan, hamburguesa),
                      pagar(juan, cuenta, mozo),
                      ir(juan, leones, otro_lugar) ])) :-
    historia(leones, H),
    once(entender(H, G, E)).

test(contar, true(T == "Juan fue de su casa a Leones. Juan se sentó a una \c
                        mesa. Juan le pidió una hamburguesa al mozo. El \c
                        mozo le trajo una hamburguesa a Juan. Juan comió \c
                        una hamburguesa. Juan le pagó la cuenta al mozo. \c
                        Juan fue de Leones a otro lugar.")) :-
    historia(leones, H),
    once(entender(H, _, E)),
    contar(E, T).

test(colectivo, true(T == "Ana fue de su casa a la parada. Ana subió al \c
                          colectivo en la parada. Ana le pagó el boleto al \c
                          chofer. Ana viajó en el colectivo hasta Plaza. \c
                          Ana bajó del colectivo en Plaza.")) :-
    historia(colectivo, H),
    once(entender(H, colectivo, E)),
    contar(E, T).

test(plural, true(T == "Luis le pidió empanadas al mozo.")) :-
    phrase(oracion(pedir(luis, empanadas, mozo)), Cs),
    string_codes(T, Cs).

test(sin_guion, fail) :-
    historia(sin_guion, H),
    entender(H, _, _).

test(subsucesion_en_orden, fail) :-
    subsucesion([b, a], [a, b, c]).

test(subsucesion, all(G == [[a, x, c], [x, a, c]])) :-
    member(G, [[a, x, c], [x, a, c], [a, c, x]]),
    once(subsucesion([a, c], G)),
    once(subsucesion([x], G)),
    \+ G = [_, _, x].

:- end_tests(guiones).
