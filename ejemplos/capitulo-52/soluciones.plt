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

test(contiene_final, [true]) :-
    contiene_final(termina_ab, [q0, q2]).

test(contiene_final_no, [fail]) :-
    contiene_final(termina_ab, [q0]).

test(contiene_final_vacio, [fail]) :-
    contiene_final(termina_ab, []).

test(repetir_cero, [true(R == vacia)]) :-
    repetir(0, sim(a), R).

test(repetir_uno, [true(R == sim(a))]) :-
    repetir(1, sim(a), R).

test(repetir_tres, [true(R == cat(sim(a), cat(sim(a), sim(a))))]) :-
    repetir(3, sim(a), R).

% Ejercicio 12: las dos expresiones describen el lenguaje de multiplo3.
test(ej12_kleene) :-
    expresion_texto(multiplo3, T),
    equivalentes(er(T), multiplo3).

test(ej12_corta) :-
    expresion_corta(T),
    equivalentes(er(T), multiplo3).

test(ej12_mas_corta, [true(L1 < L2)]) :-
    expresion_corta(T1),
    string_length(T1, L1),
    expresion_texto(multiplo3, T2),
    string_length(T2, L2).

% Ejercicio 13: la máquina de Moore escribe S0 y después lo mismo que la
% de Mealy, para todas las entradas de hasta 5 bits.
test(ej13_gray, [forall(( between(0, 5, L), length(E, L),
                          maplist([B]>>member(B, [0, 1]), E) )),
                 nondet, true(S == [0|G])]) :-
    transducir(gray, E, G),
    moore(moore_de(gray, 0), E, S).

test(ej13_complemento2, [forall(( between(0, 4, L), length(E, L),
                                  maplist([B]>>member(B, [0, 1]), E) )),
                         nondet, true(S == [x|G])]) :-
    transducir(complemento2, E, G),
    moore(moore_de(complemento2, x), E, S).

% Los estados de gray se desdoblan: b0 y b1 se alcanzan escribiendo 0 y 1.
test(ej13_estados, [true(Qs == [b0-0, b0-1, b1-0, b1-1])]) :-
    findall(Q, alcanzable(moore_de(gray, 0), Q), Qs0),
    sort(Qs0, Qs).

test(ej13_salida, [true(S == 1)]) :-
    moore:salida_estado(moore_de(gray, 0), b0-1, S).

test(ej13_inverso, [nondet, true(E == [1, 0, 1, 1])]) :-
    moore(moore_de(gray, 0), E, [0, 1, 1, 1, 0]).

:- end_tests(soluciones).
