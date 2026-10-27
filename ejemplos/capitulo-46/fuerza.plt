:- encoding(utf8).

:- begin_tests(fuerza).

test(suma_de_uno, true(E == incrementar(id(x)))) :-
    reducir_expresion(bin(+, id(x), num(1)), E).

test(uno_mas, true(E == incrementar(id(x)))) :-
    reducir_expresion(bin(+, num(1), id(x)), E).

test(suma_de_cero, true(E == id(x))) :-
    reducir_expresion(bin(+, num(0), id(x)), E).

test(resta_de_cero, true(E == id(x))) :-
    reducir_expresion(bin(-, id(x), num(0)), E).

test(cero_menos, true(E == bin(-, num(0), id(x)))) :-
    reducir_expresion(bin(-, num(0), id(x)), E).

test(producto_por_uno, true(E == id(x))) :-
    reducir_expresion(bin(*, num(1), id(x)), E).

test(potencia_de_dos, true(E == desplazar(id(x), 3))) :-
    reducir_expresion(bin(*, id(x), num(8)), E).

test(potencia_a_la_izquierda, true(E == desplazar(id(x), 10))) :-
    reducir_expresion(bin(*, num(1024), id(x)), E).

test(no_potencia, true(E == bin(*, id(x), num(6)))) :-
    reducir_expresion(bin(*, id(x), num(6)), E).

test(division_no_se_reduce, true(E == bin(/, id(x), num(2)))) :-
    reducir_expresion(bin(/, id(x), num(2)), E).

test(division_y_desplazamiento, true(D-S == (-3)-(-4))) :-
    operar(/, -7, 2, D),
    S is -7 >> 1.

test(de_abajo_hacia_arriba, true(E == incrementar(desplazar(id(x), 3)))) :-
    reducir_expresion(bin(+, bin(*, id(x), num(8)), num(1)), E).

test(se_encadena, true(E == incrementar(id(x)))) :-
    reducir_expresion(bin(+, bin(*, id(x), num(1)), num(1)), E).

test(potencias, all(C-K == [2-1, 4-2, 1024-10])) :-
    member(C, [0, 1, 2, 3, 4, 6, 1024, 1025]),
    potencia_de_dos(C, K).

test(potencia_negativa, fail) :-
    potencia_de_dos(-4, _).

test(poner_cero, true(C == [poner_cero(x), escribir])) :-
    mirilla(modismo_fuerza, [apilar(0), guardar(x), escribir], C).

test(codigo, true(O == [poner_cero(0), cargar(0), desplazar(2), incrementar,
                        guardar(1), cargar(1), escribir])) :-
    compilar_reducido("x := 0; y := x * 4 + 1; escribir y", O).

test(maquina, true(S == [41])) :-
    maquina([apilar(5), desplazar(3), incrementar, escribir], S).

test(maquina_poner_cero, true(S == [0])) :-
    maquina([apilar(7), guardar(0), poner_cero(0), cargar(0), escribir], S).

test(ejemplos_iguales, true) :-
    forall(fuente_ejemplo(_, T),
           ( correr_reducido(T, S),
             ejecutar(T, S) )).

test(negativos, true(S == [-27, -27])) :-
    correr_reducido("x := 0 - 7; escribir x * 4 + 1; escribir 1 + 2 * (x * 2)",
                    S).

:- end_tests(fuerza).
