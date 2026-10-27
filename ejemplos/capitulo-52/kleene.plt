:- encoding(utf8).

:- begin_tests(kleene).

test(termina_ab, [true(T == "(a|b*a)a*b|(a|b*a)a*b((a|bb*a)a*b)*(()|(a|bb*a)a*b)")]) :-
    expresion_de(termina_ab, E),
    texto(E, T).

% La expresión obtenida describe el mismo lenguaje que el autómata.
test(equivalentes, [forall(member(M, [termina_ab, ciclo, er("(ab)*"),
                                     er("a*b*"), er("(a|b)*abb"),
                                     er("a(b|c)*")]))]) :-
    expresion_de(M, E),
    texto(E, T),
    equivalentes(er(T), M).

test(ciclo, [true(T == "b|a*b")]) :-
    expresion_de(ciclo, E),
    texto(E, T).

test(par_ab, [true(T == "()|a(ba)*b")]) :-
    expresion_de(er("(ab)*"), E),
    texto(E, T).

% El lenguaje vacío no tiene texto.
test(vacio, [true(E == nada)]) :-
    expresion_de(interseccion(termina_ab, complemento(termina_ab)), E).

test(texto_nada, [fail]) :-
    texto(nada, _).

test(r_base, [true(E == alt(sim(a), vacia))]) :-
    kleene:r(automata(1, [0], [0-a-0]), 0, 0, 0, E).

test(r_uno, [true(E == estrella(sim(a)))]) :-
    kleene:r(automata(1, [0], [0-a-0]), 0, 0, 1, E).

test(union_final, [true(E == sim(b))]) :-
    kleene:union_final(automata(2, [1], [0-b-1]), 2, 1, nada, E).

test(alt_acumulado, [true(E == alt(sim(a), sim(b)))]) :-
    kleene:alt_acumulado(sim(b), sim(a), E).

test(alt, [true(Es == [sim(a), sim(a), estrella(sim(a)), estrella(sim(a)),
                       alt(sim(a), sim(b))])]) :-
    kleene:alt(nada, sim(a), E1),
    kleene:alt(sim(a), sim(a), E2),
    kleene:alt(vacia, estrella(sim(a)), E3),
    kleene:alt(estrella(sim(a)), alt(sim(a), vacia), E4),
    kleene:alt(sim(a), sim(b), E5),
    Es = [E1, E2, E3, E4, E5].

test(en_estrella, all(X == [vacia, sim(a), alt(sim(a), vacia),
                            alt(vacia, sim(a))])) :-
    member(X, [vacia, sim(a), alt(sim(a), vacia), alt(vacia, sim(a)),
               sim(b)]),
    kleene:en_estrella(X, sim(a)).

test(cat, [true(Es == [nada, sim(a), estrella(sim(a)), estrella(sim(a)),
                       cat(sim(a), sim(b))])]) :-
    kleene:cat(sim(a), nada, E1),
    kleene:cat(vacia, sim(a), E2),
    kleene:cat(alt(vacia, sim(a)), estrella(sim(a)), E3),
    kleene:cat(estrella(sim(a)), estrella(sim(a)), E4),
    kleene:cat(sim(a), sim(b), E5),
    Es = [E1, E2, E3, E4, E5].

test(absorbida, [fail]) :-
    kleene:absorbida(sim(a), sim(a)).

test(estrella, [true(Es == [vacia, vacia, estrella(sim(a)),
                            estrella(sim(a)), estrella(sim(a))])]) :-
    kleene:estrella(nada, E1),
    kleene:estrella(vacia, E2),
    kleene:estrella(estrella(sim(a)), E3),
    kleene:estrella(alt(vacia, sim(a)), E4),
    kleene:estrella(sim(a), E5),
    Es = [E1, E2, E3, E4, E5].

% Los paréntesis van donde la expresión es menos ligada que su contexto.
test(texto_parentesis, [true(T == "(a|b)*c")]) :-
    texto(cat(estrella(alt(sim(a), sim(b))), sim(c)), T).

test(texto_vacia, [true(T == "a|()")]) :-
    texto(alt(sim(a), vacia), T).

test(texto_especial, [true(T == S)]) :-
    atom_codes(S0, [92, 42, 97]),
    atom_string(S0, S),
    texto(cat(sim(*), sim(a)), T).

test(nivel, [true(Ns == [0, 1, 2, 2])]) :-
    maplist(kleene:nivel, [alt(x, y), cat(x, y), estrella(x), sim(x)], Ns).

test(especial, [true]) :-
    kleene:especial('|').

test(no_especial, [fail]) :-
    kleene:especial(a).

test(escribir, [true(Cs == "(a|b)")]) :-
    phrase(kleene:escribir(alt(sim(a), sim(b)), 1), Cs0),
    string_codes(Cs, Cs0).

test(escribir_sin, [true(Cs == "a*")]) :-
    phrase(kleene:escribir_sin(estrella(sim(a))), Cs0),
    string_codes(Cs, Cs0).

test(simbolo, [true(Cs == "a")]) :-
    phrase(kleene:simbolo(a), Cs0),
    string_codes(Cs, Cs0).

test(expresion_texto, [true(T == "()|a(ba)*b")]) :-
    expresion_texto(er("(ab)*"), T).

test(expresion_texto_vacio, [fail]) :-
    expresion_texto(interseccion(termina_ab, complemento(termina_ab)), _).

:- end_tests(kleene).
