:- encoding(utf8).

:- begin_tests(leer).

test(lexico, true(Ts == [leer, id(x)])) :-
    lexico("leer x", Ts).

test(analizar, true(P == [leer(x), escribir(bin(*, id(x), id(x)))])) :-
    analizar("leer x; escribir x * x", P).

test(leer_sin_variable, fail) :-
    analizar("leer 3", _).

test(variables, true(Vs == [n, s, x])) :-
    suma_leida(T),
    analizar(T, P),
    variables(P, Vs).

test(interpretar, true(S == [49])) :-
    ejecutar_con_entrada("leer x; escribir x * x", [7], S).

test(sentencia, true(E == ['<entrada>'-[2], x-5])) :-
    phrase(ejecutar_sentencia(leer(x), ['<entrada>'-[5, 2], x-0], E), []).

test(entrada_agotada, fail) :-
    ejecutar_con_entrada("leer x; leer y", [1], _).

test(sobra_entrada, true(S == [1])) :-
    ejecutar_con_entrada("leer x; escribir x", [1, 2, 3], S).

test(sin_entrada, fail) :-
    analizar("leer x", P),
    interpretar(P, _).

test(codigo, true(C == [leer, guardar(0), cargar(0), cargar(0),
                        multiplicar, escribir])) :-
    compilar("leer x; escribir x * x", C).

test(maquina, true(S == [7, 3])) :-
    maquina_con_entrada([leer, leer, escribir, escribir], [3, 7], S).

test(maquina_agotada, fail) :-
    maquina_con_entrada([leer, leer], [3], _).

test(correr, true(S == [49])) :-
    correr_con_entrada("leer x; escribir x * x", [7], S).

test(suma, true(S1-S2 == [60]-[60])) :-
    suma_leida(T),
    ejecutar_con_entrada(T, [3, 10, 20, 30], S1),
    correr_con_entrada(T, [3, 10, 20, 30], S2).

test(suma_vacia, true(S == [0])) :-
    suma_leida(T),
    correr_con_entrada(T, [0], S).

test(ejemplos_sin_leer, true) :-
    forall(fuente_ejemplo(_, T),
           ( ejecutar(T, S),
             correr_con_entrada(T, [], S) )).

:- end_tests(leer).
