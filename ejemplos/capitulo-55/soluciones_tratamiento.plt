:- encoding(utf8).

:- begin_tests(soluciones_tratamiento).

test(cuatro_traducciones, [true(Ts == ["He eats apples.", "She eats apples.",
                                       "It eats apples.",
                                       "You eat apples."])]) :-
    traducciones("Come manzanas.", Ts).

% traducir_con_trato/3 acepta el sujeto omitido en tercera persona para
% tú, porque solo examina el árbol castellano.
test(trato_solo_castellano, all(Es == ["Comes manzanas.",
                                       "Tú comes manzanas.",
                                       "Come manzanas."])) :-
    traducir_con_trato(tu, Es, "You eat apples.").

test(trato_ingles_tu, all(Es == ["Comes manzanas.",
                                 "Tú comes manzanas."])) :-
    traducir_con_trato_ingles(tu, Es, "You eat apples.").

test(trato_ingles_usted, all(Es == ["Usted come manzanas.",
                                    "Come manzanas."])) :-
    traducir_con_trato_ingles(usted, Es, "You eat apples.").

test(trato_ingles_he, all(Es == ["Come manzanas.", "Él come manzanas."])) :-
    traducir_con_trato_ingles(tu, Es, "He eats apples.").

test(trato_ingles_omitido, all(T == [usted])) :-
    trato_ingles(tacito(sg), pron(you), T).

test(trato_ingles_otro, [true(var(T))]) :-
    trato_ingles(tacito(sg), pron(he), T).

:- end_tests(soluciones_tratamiento).
