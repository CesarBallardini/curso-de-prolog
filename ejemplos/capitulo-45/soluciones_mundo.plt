:- encoding(utf8).

:- begin_tests(soluciones_mundo, [setup(iniciar), cleanup(iniciar)]).

test(salidas_del_vestibulo, true(S == "Estás en el vestíbulo. Un \c
                                       vestíbulo con baldosas gastadas y \c
                                       olor a humedad. Ves un perchero. \c
                                       Desde aquí puedes ir a la \c
                                       biblioteca, al taller y al \c
                                       jardín.")) :-
    iniciar,
    ejecutar("mirar", S).

% Con el jardín, «abrir la puerta» tiene tres lecturas en el vestíbulo; la
% única que ningún impedimento bloquea es la puerta de vidrio.
test(abrir_la_puerta, true(O == abrir(puerta_vidrio))) :-
    iniciar,
    entender("abrir la puerta", O).

test(recorrer_el_jardin, true(Ss == ["Abres la puerta de vidrio.",
                                     "Estás en el jardín. Un jardín \c
                                      descuidado, con canteros secos. Ves \c
                                      una regadera. Desde aquí puedes ir \c
                                      al vestíbulo.",
                                     "Tomas la regadera."])) :-
    iniciar,
    maplist(ejecutar, ["abrir la puerta de vidrio", "ir al jardín",
                       "recoger la regadera"], Ss).

test(sinonimos, true(Os == [tomar(lente), tomar(lente), salir])) :-
    maplist([Ps, O]>>once(phrase(orden(O), Ps)),
            [[recoger, la, lente], [levantar, lente], [terminar]], Os).

test(datos_coherentes, true) :-
    forall(puerta(_, S1, S2), ( sala(S1, _), sala(S2, _) )),
    forall(inicio(esta_en(X, L)),
           ( nombre(X, _, _), ( sala(L, _) ; recipiente(L) ) )).

:- end_tests(soluciones_mundo).
