:- encoding(utf8).

:- begin_tests(proyecto).

test(acepta) :-
    acepta(er("(a|b)*abb"), [a, b, a, b, b]).

test(min, [true(N == 4)]) :-
    tabla(min(er("(a|b)*abb")), automata(N, _, _)).

test(contraejemplo, [true(W == [a])]) :-
    contraejemplo(er("(ab)*"), er("a*b*"), W).

test(componentes, [true(Cs == [mientras, id(x), <=, num(10), hacer, id(x),
                               :=, id(x), +, num(1), fin])]) :-
    componentes("mientras x <= 10 hacer x := x + 1 fin", Cs).

test(plural, [true(Ws == [[l, u, c], [l, u, c, e], [l, u, z]])]) :-
    findall(W, transducir(plural, W, [l, u, c, e, s]), Ws0),
    sort(Ws0, Ws).

test(circuito, [true(N == 8)]) :-
    numero_estados(circuito(contador_gray, [0, 0, 0]), N).

:- end_tests(proyecto).
