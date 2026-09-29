:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 2
test(reglas_antepasado, true(N == 2)) :-
    reglas(antepasado/2, N).

test(reglas_hechos, true(N == 0)) :-
    reglas(padre/2, N).

test(reglas_mixto, true(N == 1)) :-
    reglas(maximo/3, N).

test(reglas_no_definido, [fail]) :-
    reglas(no_definido/2, _).

% Ejercicio 4
test(signo, all(S == [negativo])) :-
    resolver(signo(-3, S)).

test(signo_cero, all(S == [cero])) :-
    resolver(signo(0, S)).

test(signo_como_prolog, true(Rs == Ps)) :-
    findall(X-S, ( member(X, [-2, 0, 5]), resolver(signo(X, S)) ), Rs),
    findall(X-S, ( member(X, [-2, 0, 5]), signo(X, S) ), Ps).

test(disyuncion, all(X == [luis, juan])) :-
    resolver(pariente_directo(ana, X)).

test(disyuncion_como_prolog, true(Rs == Ps)) :-
    findall(A-B, resolver(pariente_directo(A, B)), Rs),
    findall(A-B, pariente_directo(A, B), Ps).

test(limpiar_condicional,
     true(C == si(sis(x > 0), sis(s = p), si(sis(x < 0), sis(s = n),
                                             sis(s = c))))) :-
    limpiar((x > 0 -> s = p ; x < 0 -> s = n ; s = c), C).

% Ejercicio 5
test(maximo_prolog, all(M == [5])) :-
    maximo(5, 3, M).

test(maximo_interpretado, all(M == [5, 3])) :-
    resolver(maximo(5, 3, M)).

test(maximo_interpretado_bien, all(M == [5])) :-
    resolver(maximo(3, 5, M)).

% Ejercicio 6
test(anchura_camino,
     true(Cs == [[a-b, b-c], [a-b, b-a, a-b, b-c], [a-b, b-c, c-b, b-c]])) :-
    findall(C, limit(3, resolver_anchura(camino(a, c, C))), Cs).

% La recursión a la izquierda da sus tres respuestas en anchura.
test(anchura_izquierda, true(As == [luis, ana, juan])) :-
    findall(A, limit(3, resolver_anchura(antepasado_izq(A, eva))), As).

test(anchura_como_prolog, true(Rs == Ps)) :-
    findall(D, resolver_anchura(antepasado(juan, D)), Rs0),
    msort(Rs0, Rs),
    findall(D, antepasado(juan, D), Ps0),
    msort(Ps0, Ps).

test(anchura_sin_prueba, [fail]) :-
    resolver_anchura(padre(eva, _)).

% Ejercicio 7
test(hechos_usados, true(H == [padre(juan, ana), padre(ana, luis)])) :-
    once(resolver_arbol(abuelo(juan, _), A)),
    hechos_usados(A, H).

test(hechos_usados_con_predefinido,
     true(H == [edad(juan, 68), edad(ana, 41)])) :-
    hechos_usados(prueba(mayor(juan, ana),
                         [ prueba(edad(juan, 68), []),
                           prueba(edad(ana, 41), []),
                           sis(68 > 41) ]),
                  H).

% Ejercicio 8
test(acotado_corto, all(R == [agotado])) :-
    resolver_acotado(camino(a, d, _), 3, R).

test(acotado_largo, all(R == [si, agotado])) :-
    resolver_acotado(camino(a, d, _), 4, R).

test(acotado_largo_camino, all(C == [[a-b, b-c, c-d]])) :-
    resolver_acotado(camino(a, d, C), 4, si).

% La respuesta agotado no liga las variables de Meta.
test(acotado_sin_ligaduras, true(V == libre)) :-
    resolver_acotado(camino(a, d, C), 3, agotado),
    (   var(C)
    ->  V = libre
    ;   V = ligada
    ).

% Sin prueba y sin llegar al límite: la respuesta es no.
test(acotado_sin_prueba, [fail]) :-
    resolver_acotado(padre(eva, _), 3, _).

test(acotado_completo, all(R == [si])) :-
    resolver_acotado(abuelo(juan, luis), 5, R).

% Ejercicio 9
test(sin_ciclos, all(A == [luis, ana])) :-
    resolver_sin_ciclos(antepasado_izq(A, eva)).

test(sin_ciclos_derecha, all(D == [ana, pedro, luis, eva])) :-
    resolver_sin_ciclos(antepasado(juan, D)).

% Ejercicio 10
test(rastrear_entradas,
     true(S == "llama abuelo(juan, A)\n  llama padre(juan, A)\n  \c
                sale padre(juan, ana)\n  llama padre(ana, A)\n  \c
                sale padre(ana, luis)\nsale abuelo(juan, luis)\n")) :-
    with_output_to(string(S), once(rastrear_entradas(abuelo(juan, _)))).

:- end_tests(soluciones).
