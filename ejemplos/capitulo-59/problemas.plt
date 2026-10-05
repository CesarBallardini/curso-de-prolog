:- encoding(utf8).

:- begin_tests(problemas).

test(indefinidos, [true(Ps == [promedo/2])]) :-
    indefinidos(notas, Ps).

% desvio2/3 tiene quien lo llame, varianza/2, pero ninguno de los dos se
% alcanza desde informe/0.
test(no_usados, [true(Ps == [desvio2/3, varianza/2])]) :-
    no_usados(notas, Ps).

test(no_usados_dos_raices, [true(Ps == [])]) :-
    clausulas(notas, Cs),
    no_usados_de(Cs, [informe/0, varianza/2], Ps).

test(recursivos, [true(Ps == [longitud_impar/1, longitud_par/1, suma/2])]) :-
    recursivos(notas, Ps).

test(componentes,
     [true(Gs == [[longitud_impar/1, longitud_par/1], [suma/2]])]) :-
    componentes(notas, Gs).

% Un ciclo de tres predicados forma una sola componente.
test(ciclo_de_tres, [true(Gs == [[a/0, b/0, c/0]])]) :-
    componentes_de([(a :- b), (b :- c), (c :- a, d), d], Gs).

test(arbol, [true(Ls == [ linea(1, 0, informe/0, ninguna),
                          linea(2, 1, alumnos/1, ninguna),
                          linea(3, 2, notas/2, ninguna) ])]) :-
    clausulas(notas, Cs),
    arbol(Cs, informe/0, Todas),
    length(Ls, 3),
    append(Ls, _, Todas).

% Once predicados en el árbol, numerados una vez cada uno.
test(arbol_numeros, [true(Ns == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])]) :-
    clausulas(notas, Cs),
    arbol(Cs, informe/0, Ls),
    findall(N, ( member(linea(N, _, _, _), Ls), N \== (-) ), Ns).

test(arbol_indefinido, [nondet]) :-
    clausulas(notas, Cs),
    arbol(Cs, informe/0, Ls),
    member(linea(11, 2, promedo/2, indefinido), Ls).

% Un predicado que el programa define es suyo aunque exista uno predefinido
% con el mismo nombre: el arco a length/2 queda en el grafo.
test(definido_gana, [true(G == [length/2-[length/2], p/0-[length/2]])]) :-
    grafo([(p :- length(_, _)),
           length([], 0),
           (length([_|Xs], N) :- length(Xs, N0), N is N0 + 1)], G).

test(propio) :-
    propio([length/2], length/2),
    propio([], promedo/2),
    \+ propio([], length/2).

test(indefinidos_de, [true(Ps == [b/0, d/1])]) :-
    indefinidos_de([(a :- b, d(_), length(_, _)), c], Ps).

test(indefinidos_de_ninguno, [true(Ps == [])]) :-
    indefinidos_de([(a :- b), b], Ps).

test(recursivos_de, [true(Ps == [a/0, b/0, d/0])]) :-
    recursivos_de([(a :- b), (b :- a, c), c, (d :- d)], Ps).

% Desde un estado con a/0 ya numerado, una aparición remite a su número.
test(nodo_visto, [true(Ls-N == [linea(-, 2, a/0, ver(1))]-2)]) :-
    list_to_assoc([a/0-1], Vistos),
    phrase(nodo([a], [a/0], 2, a/0, Vistos-2, _-N), Ls).

test(nodo_ciclo, [true(Ls == [linea(1, 0, a/0, ninguna),
                              linea(2, 1, b/0, ninguna),
                              linea(-, 2, a/0, ver(1))])]) :-
    empty_assoc(V),
    phrase(nodo([(a :- b), (b :- a)], [a/0, b/0], 0, a/0, V-1, _), Ls).

test(escribir_arbol_de,
     [true(S == "   1 a/0\n   2    b/0\n   3       c/0\n           a/0 (ver 1)\n        c/0 (ver 3)\n")]) :-
    with_output_to(string(S),
                   escribir_arbol_de([(a :- b, c), (b :- c, a), c], a/0)).

:- end_tests(problemas).
