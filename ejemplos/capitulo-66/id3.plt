:- encoding(utf8).

:- begin_tests(id3).

atributos([cielo, temperatura, humedad, viento]).

arbol_figura_2(nodo(cielo,
                    [soleado-nodo(humedad, [alta-hoja(n), normal-hoja(p)]),
                     nublado-hoja(p),
                     lluvia-nodo(viento, [si-hoja(n), no-hoja(p)])])).

test(ejemplos, [true(N-E == 14-([cielo=soleado, temperatura=calor,
                                  humedad=alta, viento=no]-n))]) :-
    ejemplos(Es),
    length(Es, N),
    Es = [E|_].

% La ganancia de los cuatro atributos, como en Quinlan, que resta valores
% ya redondeados y da 0,246 y 0,151 para los dos primeros.
test(ganancias, [true(Gs == [0.247, 0.029, 0.152, 0.048])]) :-
    ejemplos(Es),
    atributos(As),
    maplist(ganancia(Es), As, Gs).

test(info, [true(I =:= 0.94)]) :-
    ejemplos(Es),
    info(Es, I0),
    I is round(I0 * 100) / 100.

test(razones, [true(Rs == [0.156, 0.019, 0.152, 0.049])]) :-
    ejemplos(Es),
    atributos(As),
    maplist(razon(Es), As, Rs).

test(valor_intrinseco, [true(IV =:= 1.0)]) :-
    ejemplos(Es),
    valor_intrinseco(Es, humedad, IV).

test(figura_2, [true(A == F)]) :-
    ejemplos(Es),
    atributos(As),
    id3(ganancia, Es, As, A),
    arbol_figura_2(F).

test(razon_misma, [true(A == F)]) :-
    ejemplos(Es),
    atributos(As),
    id3(razon, Es, As, A),
    arbol_figura_2(F).

test(nodos, [true(N == 8)]) :-
    arbol_figura_2(A),
    nodos(A, N).

test(clasificar, [true(C == p)]) :-
    arbol_figura_2(A),
    clasificar(A, [cielo=lluvia, temperatura=fresco, humedad=alta,
                   viento=no], C).

% Un error en la clase del ejemplo 3 duplica el árbol.
test(ruido, [true(N == 16)]) :-
    corrompido(3, Es),
    atributos(As),
    id3(ganancia, Es, As, A),
    nodos(A, N).

test(corrompido, [true(C == n)]) :-
    corrompido(3, Es),
    nth1(3, Es, _-C).

% Con la prueba de chi-cuadrado, catorce ejemplos no alcanzan para
% aceptar ningún atributo al 99 %; al 90 %, solo la humedad.
test(chi, [true(L == [hoja(p),
                      nodo(humedad, [alta-hoja(n), normal-hoja(p)])])]) :-
    corrompido(3, Es),
    atributos(As),
    findall(A, ( member(C, [0.99, 0.90]),
                 id3(ruido(C), Es, As, A) ), L).

test(chi_cuadrado, [true(X-GL == 4.667-1)]) :-
    corrompido(3, Es),
    chi_cuadrado(Es, humedad, X, GL).

test(relevante) :-
    corrompido(3, Es),
    relevante(0.90, Es, humedad),
    \+ relevante(0.90, Es, cielo).

test(ventana, [true(L == [1-3, 4-4, 14-1])]) :-
    ejemplos(Es),
    findall(W-I, ( member(W, [1, 4, 14]),
                   ventana(ganancia, Es, W, _, I) ), L).

test(ventana_arbol, [true(A == F)]) :-
    ejemplos(Es),
    ventana(ganancia, Es, 4, A, _),
    arbol_figura_2(F).

test(iterar, [true(I == 1)]) :-
    ejemplos(Es),
    iterar(ganancia, Es, [], 1, _, I).

test(errores, [true(N == 1)]) :-
    corrompido(3, Es),
    arbol_figura_2(A),
    errores(A, Es, M),
    length(M, N).

test(bien) :-
    arbol_figura_2(A),
    bien(A, [cielo=nublado]-p).

test(valor, [true(V == b)]) :-
    valor([a=1, x=b], x, V).

test(cuentas, [true(C == [n-5, p-9])]) :-
    ejemplos(Es),
    cuentas(Es, C).

test(menos_plogp, [true(S =:= 0.5)]) :-
    menos_plogp(2, p-1, 0.0, S).

test(particion, [true(L == [alta-7, normal-7])]) :-
    ejemplos(Es),
    particion(Es, humedad, G),
    findall(V-N, ( member(V-S, G), length(S, N) ), L).

test(grupo, [true(N == 4)]) :-
    ejemplos(Es),
    grupo(Es, cielo, nublado, nublado-S),
    length(S, N).

test(con_valor) :-
    con_valor(cielo, lluvia, [cielo=lluvia]-p).

test(ganancia_exacta, [true(abs(G - 0.2467) < 0.0001)]) :-
    ejemplos(Es),
    ganancia_exacta(Es, cielo, G).

test(esperada, [true(E =:= 0.5)]) :-
    esperada(4, a-[x-p, y-n], 0.0, E).

test(vacio) :-
    vacio(a-[]),
    \+ vacio(a-[x]).

test(mayoritaria, [true(C == p)]) :-
    ejemplos(Es),
    mayoritaria(Es, C).

test(mayoritaria_empate, [true(C == n)]) :-
    mayoritaria([a-p, b-n], C).

test(elegir, [true(A == humedad)]) :-
    ejemplos(Es),
    elegir(razon, Es, [humedad, viento], A).

test(elegir_ninguno, [fail]) :-
    corrompido(3, Es),
    elegir(ruido(0.99), Es, [cielo, viento], _).

test(candidatos, [true(C == [cielo, humedad])]) :-
    ejemplos(Es),
    atributos(As),
    candidatos(razon, Es, As, C).

test(mejor, [true(A == b)]) :-
    mejor([1-a, 3-b, 3-c, 2-d], A).

test(mayor, [true(M == 1-a)]) :-
    mayor(1-b, 1-a, M).

test(rama_vacia, [true(R == v-hoja(p))]) :-
    rama(ganancia, [], p, v-[], R).

test(rama, [true(R == v-hoja(n))]) :-
    rama(ganancia, [], p, v-[[cielo=lluvia]-n], R).

test(atributos, [true(A == [cielo, temperatura, humedad, viento])]) :-
    atributos(A).

test(datos, [true(N == 14)]) :-
    datos(corrompido(1), Es),
    length(Es, N).

test(aprender, [true(N == 3)]) :-
    aprender(ruido(0.90), corrompido(3), A),
    nodos(A, N).

test(medidas_atributos, [true(F == [cielo-0.247-0.156,
                                    temperatura-0.029-0.019,
                                    humedad-0.152-0.152,
                                    viento-0.048-0.049])]) :-
    medidas_atributos(F).

test(mostrar, [true(S == "humedad = alta: n\nhumedad = normal: p\n")]) :-
    with_output_to(string(S),
                   mostrar(nodo(humedad, [alta-hoja(n), normal-hoja(p)]))).

test(mostrar_hoja, [true(S == "p\n")]) :-
    with_output_to(string(S), mostrar(hoja(p))).

test(mostrar_ramas, [true(S == "|   a = x: p\n")]) :-
    with_output_to(string(S), mostrar_ramas(a, [x-hoja(p)], "|   ")).

test(mostrar_aprendido, [true(L == "nodos: 8")]) :-
    with_output_to(string(S), mostrar_aprendido(ganancia, tabla)),
    split_string(S, "\n", "", Ls),
    nth1(8, Ls, L).

test(ventana_tabla, [true(L == [1-3-8, 4-4-8, 7-3-8, 14-1-8])]) :-
    findall(T-I-N, ( member(T, [1, 4, 7, 14]), ventana_tabla(T, I, N) ), L).

test(medida, [true(A-B == 0.152-0.152)]) :-
    ejemplos(Es),
    medida(razon, Es, humedad, A),
    medida(ganancia, Es, humedad, B0),
    B is round(B0 * 1000) / 1000.0.

:- end_tests(id3).
