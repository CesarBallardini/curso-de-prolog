:- encoding(utf8).

:- begin_tests(red).

% Siete nodos beta para diez condiciones: hermanos, antepasado_1 y
% antepasado_2 empiezan con progenitor(A, B) y comparten el primer nodo.
test(familia, [A, B, C] == [4, 7, 10]) :-
    tamano_red(familia, A, B, C).

test(cajas, [A, B, C] == [4, 14, 20]) :-
    tamano_red(cajas, A, B, C).

test(configurador, [A, B, C] == [19, 54, 58]) :-
    tamano_red(configurador, A, B, C).

% Dos reglas con el mismo prefijo, salvo el nombre de las variables,
% comparten sus nodos; el tercer paso es propio de r2.
test(prefijo_comun, [A, B] == [3, 3]) :-
    compilar_red(pasos, [r1 :: [p(X), q(X)] ---> [],
                         r2 :: [p(Y), q(Y), r(Y)] ---> []], Red),
    medidas_red(Red, A, B, _).

% q(X) y q(Y) son variantes como patrones sueltos, y comparten el nodo
% alfa; los prefijos [p(X), q(X)] y [p(X), q(Y)] no son variantes.
test(prefijo_distinto, [A, B] == [2, 3]) :-
    compilar_red(pasos, [r1 :: [p(X), q(X)] ---> [],
                         r2 :: [p(_), q(_)] ---> []], Red),
    medidas_red(Red, A, B, _).

test(pasos) :-
    pasos([p(X), no(q(X)), {X > 1}], Pasos),
    Pasos == [alfa(p(X), []), no(q(X)), {X > 1}].

% Los sucesores del nodo alfa de sobre/2 quedan del más profundo al menos
% profundo.
test(sucesores, S == [12, 11, 10, 8, 6, 5, 4, 3, 2]) :-
    red_de(cajas, red(_, Alfas, _, _)),
    get_assoc(2, Alfas, a(_, S)).

% bajar y despejada comparten meta(despejar(X)) y no(sobre(_, X)).
test(compartido, Hijos == [10, 11]) :-
    red_de(cajas, red(_, _, Betas, _)),
    get_assoc(9, Betas, beta(_, _, _, Hijos, _)).

test(mostrar) :-
    with_output_to(string(S), mostrar_red(mcd)),
    sub_string(S, 0, _, _, "alfa 1: numero(A) -> [2,1]").

% nodo_beta/6 devuelve el hijo de la raíz cuyo prefijo es una variante, sin
% cambiar la red; con un prefijo nuevo crea el nodo 2.
test(nodo_beta, [N1, N2, A, B] == [1, 2, 2, 2]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], Red0),
    nodo_beta(alfa(p(Y), []), [alfa(p(Y), [])], 0, Red0, Red1, N1),
    Red1 == Red0,
    nodo_beta(alfa(q(Z), []), [alfa(q(Z), [])], 0, Red0, Red2, N2),
    medidas_red(Red2, A, B, _).

% unir/6 recorre los pasos desde la raíz: la segunda vez, con variantes,
% llega a la misma hoja sin crear nodos.
test(unir, [H1, H2, B] == [2, 2, 2]) :-
    compilar_red(pasos, [], Red0),
    unir([alfa(p(X), []), alfa(q(X), [])], [], 0, Red0, Red1, H1),
    unir([alfa(p(Y), []), alfa(q(Y), [])], [], 0, Red1, Red2, H2),
    medidas_red(Red2, _, B, _).

% mostrar/1 escribe una línea por nodo; la regla cuelga del nodo beta 2.
test(mostrar_red_compilada,
     Ls == ["alfa 1: p(A) -> [1]", "alfa 2: q(A) -> [2]",
            "beta 1 (de 0, union(1)): p(A)",
            "beta 2 (de 1, union(2)): q(A) => [r]", ""]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> [agregar(s(X))]], Red),
    with_output_to(string(S), mostrar(Red)),
    split_string(S, "\n", "", Ls).

:- end_tests(red).
