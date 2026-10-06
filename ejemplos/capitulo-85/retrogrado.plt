:- encoding(utf8).

:- begin_tests(retrogrado).

test(restar, [true(Js == [1-0, 2-1, 2-0, 3-2, 3-1, 3-0])]) :-
    restar(3, Js).

test(posiciones, [true(Ps == [a, b, c])]) :-
    posiciones([a-b, b-c, b-a], Ps).

test(vecinos, [true(L == [a-[b], b-[c, a], c-[]])]) :-
    vecinos([a-b, b-a, b-c], [a, b, c], V),
    assoc_to_list(V, L).

test(valor_en_gana, [true(V == gana(3))]) :-
    list_to_assoc([b-pierde(0)], Vs),
    valor_en(3, [a, b], Vs, V).

test(valor_en_pierde, [true(V == pierde(3))]) :-
    list_to_assoc([a-gana(1), b-gana(2)], Vs),
    valor_en(3, [a, b], Vs, V).

test(valor_en_nada, [fail]) :-
    list_to_assoc([a-gana(1)], Vs),
    valor_en(3, [a, b], Vs, _).

% El juego j1 del capítulo 38: a pierde, b gana, c no tiene jugadas.
test(j1, [true(T == [a-pierde(2), b-gana(1), c-pierde(0)])]) :-
    rondas([a-b, b-a, b-c], T, _),
    retrogrado([a-b, b-a, b-c], T, _).

% El juego j2: a y b son tablas, las indefinidas del modelo bien fundado.
test(j2, [true(T == [c-gana(1), d-pierde(0)])]) :-
    rondas([a-b, b-a, b-c, c-d], T, _),
    retrogrado([a-b, b-a, b-c, c-d], T, _).

% En el juego de restar, el que mueve pierde en los múltiplos de 4.
test(restar_multiplos, [true(Ps == [0, 4, 8, 12])]) :-
    restar(12, Js),
    retrogrado(Js, T, _),
    findall(P, member(P-pierde(_), T), Ps).

test(iguales, [true(N2 < N1)]) :-
    restar(100, Js),
    rondas(Js, T, N1),
    retrogrado(Js, T, N2).

test(arcos, [true(N == 297)]) :-
    restar(100, Js),
    retrogrado(Js, _, N).

test(sumar_sucesoras, [true(N == 7)]) :-
    list_to_assoc([a-[b, c]], S),
    sumar_sucesoras(S, a, 5, N).

test(poner_valor, [true(V == gana(1))]) :-
    empty_assoc(E),
    poner_valor(a-gana(1)-0, E, Vs),
    get_assoc(a, Vs, V).

test(predecesora_cuenta, [true(G-N == []-1)]) :-
    list_to_assoc([q-2], C0),
    empty_assoc(Vs),
    predecesora(1, gana(0), Vs, q, C0-[], C-G),
    get_assoc(q, C, N).

test(predecesora_pierde, [true(G == [q-pierde(4)-0])]) :-
    list_to_assoc([q-1], C0),
    empty_assoc(Vs),
    predecesora(4, gana(3), Vs, q, C0-[], _-G).

test(propagar, [true(G-A == [a-gana(1)-0]-1)]) :-
    list_to_assoc([b-[a]], Pred),
    list_to_assoc([b-pierde(0)], Vs),
    list_to_assoc([a-1], C0),
    propagar(1, Pred, Vs, b, C0-[]-0, _-G-A).

:- end_tests(retrogrado).
