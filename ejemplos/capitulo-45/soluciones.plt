:- encoding(utf8).

:- begin_tests(soluciones).

test(menos_unario, [true(S == [-4])]) :-
    ejecutar("x := -3 * 2; escribir 2 - -x", S).

test(menos_unario_arbol, [true(P == [escribir(bin(-, num(0),
                                                  bin(-, num(0), id(x))))])]) :-
    analizar("escribir - - x", P).

test(repetir_arbol, [true(P == [repetir([escribir(id(i))],
                                        rel(=, id(i), num(1)))])]) :-
    analizar("repetir escribir i hasta i = 1", P).

test(repetir, [true(S == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])]) :-
    fuente_repetir(T),
    ejecutar(T, S).

test(repetir_compilado, [true(S == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])]) :-
    fuente_repetir(T),
    correr(T, S).

test(repetir_una_vez, [true(S == [0])]) :-
    ejecutar("repetir escribir i hasta i = 0", S).

test(fusion, [true(Pasos-N == 69-18)]) :-
    fuente_ejemplo(factorial, T),
    compilar_fusion(T, O),
    memberchk(saltar_si_no(>, 16), O),
    maquina_medida(O, [120], Pasos, _),
    length(O, N).

test(sin_fusion, [true(Pasos-N == 75-19)]) :-
    fuente_ejemplo(factorial, T),
    compilar_optimizado(T, O),
    maquina_medida(O, [120], Pasos, _),
    length(O, N).

test(fusion_como_el_interprete, [forall(fuente_ejemplo(_, T)),
                                 true(S1 == S2)]) :-
    compilar_fusion(T, O),
    maquina(O, S1),
    ejecutar(T, S2).

test(pila_reordenada, [true(H0-H == 4-2)]) :-
    compilar("x := a + (b + (c + d))", O0),
    maquina_medida(O0, _, 8, H0),
    compilar_optimizado("x := a + (b + (c + d))", O),
    maquina_medida(O, _, 8, H).

test(condicion, [true(C == rel(>, bin(+, bin(+, id(b), id(c)), id(a)),
                               num(1)))]) :-
    analizar("si 1 < a + (b + c) entonces escribir 1 fin", P0),
    reordenar_condiciones(P0, [si(C, _, _)]),
    pila_condicion(C, 2).

test(espejo) :-
    forall(espejo(Op, Op1),
           forall(member(X-Y, [1-2, 2-2, 3-2]),
                  (   comparar(Op, X, Y)
                  ->  comparar(Op1, Y, X)
                  ;   \+ comparar(Op1, Y, X)
                  ))).

test(asociar, [true(E == bin(+, id(x), num(5)))]) :-
    plegar_asociando(bin(+, bin(+, id(x), num(2)), num(3)), E).

test(asociar_resta, [true(E == id(x))]) :-
    plegar_asociando(bin(-, bin(+, id(x), num(2)), num(2)), E).

test(marcas, [true(C == [apilar(1), escribir])]) :-
    analizar("si 2 > 1 entonces escribir 1 sino escribir 2 fin", P),
    generar(P, C0),
    mirilla_completa(C0, C).

test(a_texto, [true(T == 'x := (a - (b - c)) * d / 2')]) :-
    analizar("x := (a - (b - c)) * d / 2", P),
    a_texto(P, T).

test(ida_y_vuelta, [forall(programa_ejemplo(_, P)), true(P1 == P)]) :-
    a_texto(P, T),
    analizar(T, P1).

test(compartir, [true(P == [asignar(t_1, bin(+, id(a), id(b))),
                            asignar(x, bin(-, bin(*, id(t_1), id(t_1)),
                                           id(t_1)))])]) :-
    analizar("x := (a + b) * (a + b) - (a + b)", P0),
    compartir(P0, P).

test(compartir_anidadas, [true(P == [asignar(t_1, bin(+, id(a), id(b))),
                                     asignar(t_2, bin(*, id(t_1), id(c))),
                                     asignar(y, bin(+, id(t_2),
                                                    id(t_2)))])]) :-
    analizar("y := (a + b) * c + (a + b) * c", P0),
    compartir(P0, P).

test(compartir_misma_salida, [true(S1 == S2)]) :-
    analizar("a := 3; b := 4; x := (a + b) * (a + b); escribir x - (a + b)",
             P0),
    compartir(P0, P),
    interpretar(P0, S1),
    interpretar(P, S2).

test(medir, [true(R == [18-69-2, 19-75-2])]) :-
    findall(N-P-M, ( member(C, [compilar_fusion, compilar_optimizado]),
                     medir_ejemplo(factorial, C, N, P, M) ), R).

:- end_tests(soluciones).
