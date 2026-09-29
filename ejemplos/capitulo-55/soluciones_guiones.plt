:- encoding(utf8).

:- begin_tests(soluciones_guiones).

test(consulta, true(T == "Luis fue de su casa a la clínica. Luis esperó \c
                         en la sala de espera. La médica atendió a Luis. \c
                         La médica le recetó un jarabe a Luis. Luis fue \c
                         de la clínica a otro lugar.")) :-
    historia(clinica, H),
    once(entender(H, consulta, E)),
    contar(E, T).

test(relato) :-
    palabras("Juan fue a Leones, comió una hamburguesa y se fue.", Ps),
    once(phrase(relato(H), Ps)),
    assertion(H =@= [ir(juan, _, leones), comer(juan, hamburguesa),
                     ir(juan, _, _)]).

test(comprender, true(R == "Juan fue de su casa a Leones. Juan se sentó a \c
                           una mesa. Juan le pidió una hamburguesa al \c
                           mozo. El mozo le trajo una hamburguesa a Juan. \c
                           Juan comió una hamburguesa. Juan le pagó la \c
                           cuenta al mozo. Juan fue de Leones a otro \c
                           lugar.")) :-
    comprender("Juan fue a Leones, comió una hamburguesa y se fue.", R).

test(dos_sujetos, true(R == "Ana fue de su casa a la parada. Ana subió al \c
                            colectivo en la parada. Ana le pagó el boleto \c
                            al chofer. Ana viajó en el colectivo hasta \c
                            Plaza. Ana bajó del colectivo en Plaza.")) :-
    comprender("Ana subió al colectivo y bajó en Plaza.", R).

test(sin_guion, fail) :-
    comprender("Juan comió una hamburguesa.", _).

:- end_tests(soluciones_guiones).
