:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 2
test(ab, [nondet]) :-
    phrase(ab, [a, a, b, b]).

test(ab_vacia, [fail]) :-
    phrase(ab, []).

test(ab_por_longitud, all(L == [[a, b], [a, a, b, b], [a, a, a, b, b, b]])) :-
    between(1, 6, N),
    length(L, N),
    phrase(ab, L).

% Ejercicio 6: ab//0 genera las listas de menor a mayor; con las reglas
% invertidas, la generación no da ninguna respuesta.
test(ab_genera, true(L == [a, a, b, b])) :-
    once(( phrase(ab, L), L = [a, a|_] )).

test(ab_invertida_analiza, [nondet]) :-
    phrase(ab_invertida, [a, a, b, b]).

% call_with_inference_limit/3, que acota las inferencias,
% se presenta en el capítulo 26.
test(ab_invertida_no_genera, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(phrase(ab_invertida, _), 1000000, R).

% Ejercicio 3: la traducción explícita responde lo mismo que la gramática.
test(traduccion, true(N1-N2 == luis-luis)) :-
    phrase(saludo_a(N1), `hola luis`),
    saludo_a_traducido(N2, `hola luis`, []).

% Ejercicio 4
test(concordancia, [nondet]) :-
    phrase(frase, [los, perros, ladran]).

test(sin_concordancia, [fail]) :-
    phrase(frase, [los, perros, ladra]).

test(todas_las_frases, true(N == 4)) :-
    aggregate_all(count, phrase(frase, _), N).

% Ejercicio 5: solo las oraciones verdaderas.
test(oraciones_verdaderas,
     all(H == [padre(juan, ana), padre(juan, pedro),
               madre(marta, ana), madre(marta, pedro)])) :-
    phrase(oracion_verdadera(H), _).

test(oracion_falsa, [fail]) :-
    phrase(oracion_verdadera(_), [ana, es, la, madre, de, juan]).

% Ejercicio 7
test(recorridos, true(P-S-O == [a, b, c]-[b, a, c]-[b, c, a])) :-
    A = nodo(a, nodo(b, nil, nil), nodo(c, nil, nil)),
    phrase(preorden(A), P),
    phrase(simetrico(A), S),
    phrase(postorden(A), O).

% Ejercicio 8
test(balanceado) :-
    phrase(balanceado, `{[a(b)]c}`).

test(cruzado, [fail]) :-
    phrase(balanceado, `([)]`).

test(sin_cerrar, [fail]) :-
    phrase(balanceado, `((a)`).

% Ejercicio 9
test(expresion, true(V =:= 11)) :-
    phrase(expresion(V), `2+3*4-6/2`).

test(expresion_izquierda, true(V =:= 5)) :-
    phrase(expresion(V), `10-3-2`).

% Ejercicio 10
test(fecha_larga, [nondet, true(F == fecha(2026, 9, 24))]) :-
    phrase(fecha_larga(F), `24 de septiembre de 2026`).

test(fecha_larga_generar, true(A == '1 de enero de 2027')) :-
    phrase(fecha_larga(fecha(2027, 1, 1)), Cs),
    atom_codes(A, Cs).

% Ejercicio 11
test(enumeracion, [nondet, true(L == [ana, luis, eva])]) :-
    phrase(enumeracion(L), `ana, luis y eva`).

test(enumeracion_uno, [nondet, true(L == [ana])]) :-
    phrase(enumeracion(L), `ana`).

% Al generar, csym//1 deja una alternativa que no termina: once/1 la descarta.
test(enumeracion_generar, true(A == 'ana, luis y eva')) :-
    once(phrase(enumeracion([ana, luis, eva]), Cs)),
    atom_codes(A, Cs).

% Ejercicio 12
test(problema, true(V =:= 36)) :-
    phrase(problema(V), `cuanto es 5 mas 13 por 2`).

test(problema_mal_escrito, [fail]) :-
    phrase(problema(_), `cuanto es 5 mas`).

% Ejercicio 13
test(lista_de_enteros, true(L == [1, 2, 3])) :-
    phrase(lista_de_enteros(L), `[1, 2, 3]`).

test(lista_generar, true(A == '[4, 5]')) :-
    phrase(lista_de_enteros([4, 5]), Cs),
    atom_codes(A, Cs).

% Ejercicio 17: la regla no consume el código que examina.
test(empieza_con_mayuscula, true(A == 'Ana')) :-
    phrase(empieza_con_mayuscula, `Ana`, Resto),
    atom_codes(A, Resto).

test(empieza_con_minuscula, [fail]) :-
    phrase(empieza_con_mayuscula, `ana`, _).

test(empieza_vacia, [fail]) :-
    phrase(empieza_con_mayuscula, ``, _).

:- end_tests(soluciones).
