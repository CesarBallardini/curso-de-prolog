:- encoding(utf8).

:- begin_tests(tratamiento).

test(tu_al_ingles, [true(Ts == ["You eat an apple."])]) :-
    traducciones("Tú comes una manzana.", Ts).

test(usted_al_ingles, [true(Ts == ["You read a book."])]) :-
    traducciones("Usted lee un libro.", Ts).

test(tu_omitido, [true(Ts == ["You sleep."])]) :-
    traducciones("Duermes.", Ts).

test(you_al_castellano, [true(Ts == ["Lees un libro.", "Tú lees un libro.",
                                     "Usted lee un libro."])]) :-
    traducciones("You read a book.", Ts).

test(con_tu, all(Es == ["Lees un libro.", "Tú lees un libro."])) :-
    traducir_con_trato(tu, Es, "You read a book.").

test(con_usted, all(Es == ["Usted lee un libro."])) :-
    traducir_con_trato(usted, Es, "You read a book.").

% Una oración que no se dirige a nadie se traduce igual con cualquier
% trato.
test(sin_trato, all(Es == ["El gato duerme."])) :-
    traducir_con_trato(usted, Es, "The cat sleeps.").

% La tercera persona no cambia.
test(tercera_persona, [true(Ts == ["He eats apples.", "She eats apples.",
                                   "It eats apples."])]) :-
    traducciones("Come manzanas.", Ts).

test(tu_con_tercera_persona, [fail]) :-
    phrase(oracion_es(_), ["tú", "come", "una", "manzana"]).

test(numero_verbo, [true(F == "comes")]) :-
    numero_verbo(tu, "come", "comen", F).

test(trato_fijo, all(T == [usted])) :-
    trato(pron(usted), T).

test(trato_libre, [true(var(T))]) :-
    trato(pron(m, sg), T).

test(trato_distinto, [fail]) :-
    trato(tacito(tu), usted).

:- end_tests(tratamiento).
