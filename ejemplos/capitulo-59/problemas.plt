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

:- end_tests(problemas).
