:- encoding(utf8).

:- begin_tests(complecion).

test(gusta, [true(Fs =@= [sii(gusta(A, B), (A = pedro, alumno_de(B, pedro))),
                          sii(alumno_de(C, D), (C = pablo, D = pedro))])]) :-
    completar(gusta, Fs).

% Un predicado usado y no definido queda equivalente a falso.
test(tweety, [true(F =@= sii(anormal(_), falso))]) :-
    completar(tweety, Fs),
    last(Fs, F).

test(modelos, [true(L == [gusta-[[alumno_de(pablo, pedro),
                                  gusta(pedro, pablo)]],
                          tweety-[[ave(tweety), vuela(tweety)]],
                          sabio-[]])]) :-
    findall(N-M, ( member(N, [gusta, tweety, sabio]), modelos(N, M) ), L).

% El supuesto de mundo cerrado: agregar una cláusula achica lo negado.
test(cwa, [true(N1-N2 == 6-4)]) :-
    cwa(gusta, C1),
    cwa(gusta_mas, C2),
    length(C1, N1),
    length(C2, N2).

% Para un programa sin negaciones, la compleción y el supuesto de mundo
% cerrado tienen el mismo único modelo.
test(cwa_igual_comp, [true(M == [Min])]) :-
    modelos(gusta, M),
    modelo_minimo(gusta, Min).

test(escribir,
     [true(Ls == ["sii(ave(A),A=tweety)",
                  "sii(vuela(A),(ave(A),\\+anormal(A)))",
                  "sii(anormal(A),falso)", ""])]) :-
    with_output_to(string(S), escribir_complecion(tweety)),
    split_string(S, "\n", "", Ls).

test(predicados, [true(P == [ave/1, vuela/1, anormal/1])]) :-
    clausulas(tweety, Cs),
    predicados(Cs, P).

test(atomo, [true(A-B == b-a)]) :-
    atomo(\+ b, A),
    atomo(a, B).

test(universo, [true(U == [pablo, pedro])]) :-
    universo(gusta, U).

test(base, [true(N == 8)]) :-
    base(gusta, B),
    length(B, N).

test(elegir, [true(L == [a, b])]) :-
    findall(X, elegir([a, b], X), L).

test(subconjunto, [true(L == [[a, b], [a], [b], []])]) :-
    findall(S, subconjunto([a, b], S), L).

test(definicion_vale) :-
    definicion_vale(sii(p(X), X = a), [p(a)], [a, b]).

test(definicion_no_vale, [fail]) :-
    definicion_vale(sii(p(X), X = a), [p(a), p(b)], [a, b]).

test(verdad) :-
    verdad((p(a) ; p(b)), [p(b)], [a, b]),
    \+ verdad(existe([Y], (p(Y), \+ p(Y))), [p(a)], [a]),
    verdad(sii(p(a), true), [p(a)], [a]),
    \+ verdad(falso, [], []),
    verdad(a = a, [], []).

test(deducir, [true(M == [p(a), q(a)])]) :-
    deducir([(p(a) :- true), (q(X) :- p(X))], [a], [], M).

test(en_modelo, [true(X == a)]) :-
    en_modelo([p(a)], p(X)).

:- end_tests(complecion).
