:- encoding(utf8).

:- begin_tests(soluciones).

test(ej2_equivalentes) :-
    equivalentes(par_par, interseccion(a_par, b_par)).

test(ej2_palabras, [true(N == 8)]) :-
    palabras(par_par, 4, Ws),
    length(Ws, N).

test(ej3_sin_epsilon, [fail]) :-
    epsilon(sin_epsilon(ciclo), _, _).

test(ej3_ciclo) :-
    equivalentes(ciclo, sin_epsilon(ciclo)).

test(ej3_er) :-
    equivalentes(er("(a|b)*abb"), sin_epsilon(er("(a|b)*abb"))).

test(ej3_contra, [true(Ws == [[b]])]) :-
    equivalentes(contra, sin_epsilon(contra)),
    palabras(sin_epsilon(contra), 1, Ws).

test(ej4_diferencia, [true(Ws == [[a, a, a], [a, a, b], [a, b, b],
                                  [b, b, b]])]) :-
    palabras(diferencia(er("a*b*"), er("(ab)*")), 3, Ws).

test(ej4_vacia, [forall(member(M, [termina_ab, multiplo3, er("a?b+")]))]) :-
    vacio(diferencia(M, M)).

test(ej5_explosion, [true(Fs == [1-2-2, 2-4-4, 3-8-8, 4-16-16])]) :-
    explosion(4, Fs).

test(ej6_repeticion) :-
    equivalentes(er("a{3}"), er("aaa")).

test(ej6_grupo) :-
    acepta(er("(ab){2}c"), [a, b, a, b, c]).

test(ej6_cero, [true(E == cat(vacia, sim(y)))]) :-
    expresion("x{0}y", E).

test(ej7_lexico, [true(Cs == [id(x), :=, num(1), id(y), :=,
                              cadena(hola)])]) :-
    componentes("x := 1 # uno\ny := \"hola\"", Cs).

% El complemento a dos de N es 16 - N módulo 16, en los dos sentidos.
test(ej8_complemento2) :-
    forall(between(0, 15, N),
           ( bits(N, B),
             C is (16 - N) mod 16,
             bits(C, S),
             transducir(complemento2, B, S),
             transducir(complemento2, S, B) )).

test(ej9_estados, [true(N-M == 4-3)]) :-
    numero_estados(circuito(par2, [0, 0]), N),
    numero_estados(min(circuito(par2, [0, 0])), M).

% bits(N, Bs): los cuatro bits de N, el menos significativo primero.
bits(N, Bs) :-
    findall(B, ( between(0, 3, I), B is (N >> I) /\ 1 ), Bs).

:- end_tests(soluciones).
