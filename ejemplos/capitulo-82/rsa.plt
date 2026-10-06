:- encoding(utf8).

% Pruebas de rsa.pl: el ejemplo de Wikipedia (P = 61, Q = 53, E = 17),
% la prueba de primalidad contra la división por tentativa y contra
% números de Carmichael, claves de 512 bits y las dos debilidades.

%!  primo_por_division(+N:integer) is semidet.
%
%   N es primo según la división por tentativa, para comparar.
primo_por_division(N) :-
    N >= 2,
    Max is truncate(sqrt(N)),
    \+ ( between(2, Max, K), N mod K =:= 0 ).

:- begin_tests(rsa).

test(euclides, true(G-X-Y == 2-(-9)-47)) :-
    euclides(240, 46, G, X, Y).

test(euclides_ligado) :-
    euclides(240, 46, 2, -9, 47).

test(inverso, true(D == 2753)) :-
    inverso(17, 3120, D).

test(inverso_imposible, [fail]) :-
    inverso(6, 3120, _).

test(primos_hasta_2000, true(Ps == Qs)) :-
    findall(N, ( between(0, 2000, N), primo(N) ), Ps),
    findall(N, ( between(0, 2000, N), primo_por_division(N) ), Qs).

test(carmichael, [fail]) :-
    member(N, [561, 1105, 1729, 2465, 2821, 6601, 8911, 3215031751]),
    primo(N).

test(mersenne) :-
    N is 2^127 - 1,
    primo(N).

test(mersenne_compuesto, [fail]) :-
    N is 2^67 - 1,
    primo(N).

test(primo_desde, true(P == 1000003)) :-
    primo_desde(1000000, P).

test(primo_aleatorio, true(L == 256)) :-
    primo_aleatorio(256, P),
    primo(P),
    L is msb(P) + 1.

test(claves_wikipedia, true(Pub-Priv == publica(3233, 17)-privada(3233, 2753))) :-
    claves(61, 53, 17, Pub, Priv).

test(cifrar_wikipedia, true(C-M == 2790-65)) :-
    claves(61, 53, 17, Pub, Priv),
    cifrar(65, Pub, C),
    descifrar(C, Priv, M).

test(firmar_wikipedia) :-
    claves(61, 53, 17, Pub, Priv),
    firmar(65, Priv, S),
    verificar(65, S, Pub).

test(verificar_otro, [fail]) :-
    claves(61, 53, 17, Pub, Priv),
    firmar(65, Priv, S),
    verificar(66, S, Pub).

test(ida_y_vuelta_512) :-
    claves_aleatorias(512, Pub, Priv),
    texto_entero("Inscripción aceptada", M),
    cifrar(M, Pub, C),
    descifrar(C, Priv, M1),
    M1 == M.

test(texto_entero, true(N-T == 1215261793-"Hola")) :-
    texto_entero("Hola", N),
    entero_texto(N, T).

test(texto_entero_utf8, true(T == "Inscripción")) :-
    texto_entero("Inscripción", N),
    entero_texto(N, T).

test(clave_de_ejemplo, true(M1 == M)) :-
    clave_de_ejemplo(Pub, Priv),
    texto_entero(abstencion, M),
    cifrar(M, Pub, C),
    descifrar(C, Priv, M1).

test(adivinar, true(V == no)) :-
    claves_aleatorias(512, Pub, _),
    texto_entero(no, M),
    cifrar(M, Pub, C),
    adivinar(C, Pub, [si, no, abstencion], V).

test(falsificar) :-
    claves(61, 53, 17, Pub, Priv),
    firmar(5, Priv, S1),
    firmar(7, Priv, S2),
    falsificar(S1, S2, Pub, S),
    verificar(35, S, Pub).

:- end_tests(rsa).
