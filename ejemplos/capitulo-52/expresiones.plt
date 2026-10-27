:- encoding(utf8).

:- begin_tests(expresiones).

test(arbol, [true(E == cat(cat(cat(estrella(alt(sim(a), sim(b))), sim(a)),
                              sim(b)), sim(b)))]) :-
    expresion("(a|b)*abb", E).

test(sufijos, [true(E == cat(alt(sim(a), vacia), cat(sim(b),
                                                   estrella(sim(b)))))]) :-
    expresion("a?b+", E).

test(clase, [true(E == clase(['-', '0', '1', '2', a, b]))]) :-
    expresion("[a-b0-2-]", E).

test(escape, [true(E == cat(sim(*), sim(a)))]) :-
    expresion("\\*a", E).

test(vacia, [true(E == alt(sim(a), vacia))]) :-
    expresion("a|", E).

test(error, [throws(error(syntax_error(expresion_regular("(a")), _))]) :-
    expresion("(a", _).

test(acepta) :-
    acepta(er("(a|b)*abb"), [b, a, b, b]).

test(rechaza, [fail]) :-
    acepta(er("(a|b)*abb"), [a, b, b, a]).

test(palabras, [true(Ws == [[a, b, b], [b, b, b]])]) :-
    palabras(er("a?b+"), 3, Ws).

% Nombrar los estados por la subexpresión confunde las dos a de aa.
test(ingenua, [true(Ws == [[a, a, a]])]) :-
    acepta(ingenua("aa"), [a]),
    palabras(ingenua("aa"), 3, Ws).

test(thompson_aa, [fail]) :-
    acepta(er("aa"), [a]).

test(tamanos, [true(Ns == [20, 5, 4])]) :-
    E = er("(a|b)*abb"),
    numero_estados(E, N1),
    numero_estados(det(E), N2),
    numero_estados(min(E), N3),
    Ns = [N1, N2, N3].

test(min, [true(T == automata(4, [3], [0-a-1, 0-b-0, 1-a-1, 1-b-2, 2-a-1,
                                       2-b-3, 3-a-1, 3-b-0]))]) :-
    tabla(min(er("(a|b)*abb")), T).

test(equivalentes) :-
    equivalentes(er("(a*b*)*"), er("(a|b)*")).

test(contraejemplo, [true(W == [a])]) :-
    contraejemplo(er("(ab)*"), er("a*b*"), W).

% El autómata de la expresión y el que describe el mismo lenguaje con
% hechos son equivalentes.
test(termina_ab) :-
    equivalentes(er("(a|b)*ab"), termina_ab).

test(subexpresion, [true(Ps == [[], [1], [1, 1], [2], [2, 1]])]) :-
    expresion("ab|c", E),
    findall(P, subexpresion(E, P, _), Ps0),
    msort(Ps0, Ps).

test(alternativa, [nondet, true(E == alt(cat(sim(a), sim(b)), sim(c)))]) :-
    string_chars("ab|c", Cs),
    phrase(expresiones:alternativa(E), Cs).

test(alternativa_vacia, all(E == [vacia])) :-
    phrase(expresiones:alternativa(E), []).

test(mas_alternativas, [nondet, true(E == alt(sim(a), sim(b)))]) :-
    string_chars("|b", Cs),
    phrase(expresiones:mas_alternativas(sim(a), E), Cs).

test(concatenacion, [nondet, true(E == cat(sim(a), sim(b)))]) :-
    string_chars("ab", Cs),
    phrase(expresiones:concatenacion(E), Cs).

test(mas_factores, [nondet, true(E == cat(cat(sim(a), sim(b)), sim(c)))]) :-
    string_chars("bc", Cs),
    phrase(expresiones:mas_factores(sim(a), E), Cs).

test(factor, [nondet, true(E == alt(estrella(sim(a)), vacia))]) :-
    string_chars("a*?", Cs),
    phrase(expresiones:factor(E), Cs).

test(sufijo_mas, [nondet, true(E == cat(sim(a), estrella(sim(a))))]) :-
    phrase(expresiones:sufijos(sim(a), E), [+]).

test(atomo_escape, all(E == [sim(*)])) :-
    atom_codes(T, [92, 42]),
    atom_chars(T, Cs),
    phrase(expresiones:atomo(E), Cs).

test(atomo_especial, [fail]) :-
    phrase(expresiones:atomo(_), [*]).

% La primera lectura de una clase toma a-c como rango.
test(caracteres, [true(Cs == [a, b, c, x])]) :-
    string_chars("a-cx", Cs0),
    once(phrase(expresiones:caracteres(Cs), Cs0)).

test(caracteres_al_reves, all(Cs == [[z, -, a]])) :-
    phrase(expresiones:caracteres(Cs), [z, -, a]).

test(rango, [true(Cs == [a, b, c, d, e])]) :-
    expresiones:rango(a, e, Cs).

test(rango_vacio, [fail]) :-
    expresiones:rango(e, a, _).

test(arco_alt, all(A == [e(i, i1), e(i, i2), e(f1, f), e(f2, f)])) :-
    expresiones:arco(alt(x, y), i, f, i1, f1, i2, f2, A).

test(arco_clase, all(A == [t(i, a, f), t(i, b, f)])) :-
    expresiones:arco(clase([a, b]), i, f, _, _, _, _, A).

test(arco_er, all(A == [e(i([]), i([1])), e(i([]), f([])),
                        e(f([1]), i([1])), e(f([1]), f([])),
                        t(i([1]), a, f([1]))])) :-
    expresiones:arco_er("a*", A).

test(arco_ingenuo, all(A == [e(i(cat(sim(a), sim(b))), i(sim(a))),
                             e(f(sim(a)), i(sim(b))),
                             e(f(sim(b)), f(cat(sim(a), sim(b)))),
                             t(i(sim(a)), a, f(sim(a))),
                             t(i(sim(b)), b, f(sim(b)))])) :-
    expresiones:arco_ingenuo("ab", A).

test(hijos_estrella, [true(A-V == x-true)]) :-
    expresiones:hijos(estrella(x), A, B),
    (   var(B)
    ->  V = true
    ;   V = false
    ).

test(hijos_hoja, [true(V == true)]) :-
    expresiones:hijos(sim(x), A, B),
    (   var(A), var(B)
    ->  V = true
    ;   V = false
    ).

test(alfabeto_er, [true(S == [a, b, c, x])]) :-
    expresiones:alfabeto_er("[a-c]x|a", S).

test(alfabeto_vacio, [true(S == [])]) :-
    expresiones:alfabeto_er("", S).

:- end_tests(expresiones).
