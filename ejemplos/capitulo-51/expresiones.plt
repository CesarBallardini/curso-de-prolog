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

:- end_tests(expresiones).
