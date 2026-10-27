:- encoding(utf8).

:- begin_tests(soluciones).

test(perezosa_no_evalua, [true(A-B == 3-2)]) :-
    lam("(fun x -> 3) (cabeza [])", A),
    lam("longitud [cabeza [], 2]", B).

test(estricta_evalua, [error(type_error(lista_no_vacia, []))]) :-
    ejecutar("(fun x -> 3) (cabeza [])", _).

test(iterar, [true(V == [1, 2, 4, 8, 16, 32, 64, 128])]) :-
    definiciones(iterar, D),
    lam("tomar 8 (iterar ((*) 2) 1)", D, V).

test(plegados, [true(A-B == [1, 4, 9, 16, 25]-[2, 4, 6, 8, 10])]) :-
    definiciones(plegados, D),
    ejecutar("map2 (fun x -> x * x) (hasta 1 5)", D, A),
    ejecutar("filtrar2 (fun x -> mod x 2 = 0) (hasta 1 10)", D, B).

test(plegar_der_infinita, [true(V == [2, 4, 6])]) :-
    definiciones(plegados, D),
    lam("tomar 3 (filtrar2 (fun x -> mod x 2 = 0) (desde 1))", D, V).

test(sin_lista, [true(A-B-C == 9-[2, 4, 6, 8, 10]-2)]) :-
    definiciones(sin_lista, D),
    lam("maximo [3, 1, 4, 1, 5, 9, 2, 6]", D, A),
    lam("pares (hasta 1 10)", D, B),
    lam("cuantos (fun x -> x > 2) [1, 5, 3, 2]", D, C).

test(cond_perezosa, [true(V == 120)]) :-
    definiciones(cond, D),
    lam("fact 5", D, V).

test(cond_estricta, [true(R == inference_limit_exceeded)]) :-
    definiciones(cond, D),
    call_with_inference_limit(ejecutar("fact 5", D, _), 1 000 000, R).

test(z, [true(V == 3628800)]) :-
    definiciones(z, D),
    ejecutar("z f 10", D, V).

test(suma_cuadrados_pares, [true(S == 171700)]) :-
    suma_cuadrados_pares(100, S).

test(igual_que_lam, [true(S1 == S2)]) :-
    suma_cuadrados_pares(100, S1),
    ejecutar("suma (map (fun x -> x * x) \c
              (filtrar (fun x -> mod x 2 = 0) (hasta 1 100)))", S2).

test(desazucar, [true(D == sea(f, ap(id(z), lam(f, id(f))),
                               ap(id(f), num(1))))]) :-
    desazucar(searec(f, id(f), ap(id(f), num(1))), D).

test(sea_recursivo, [true(V == 120)]) :-
    leer_expresion("fun n -> si n = 0 entonces 1 sino n * f (n - 1)", E1),
    evaluar_con_rec(searec(f, E1, ap(id(f), num(5))), V).

test(evaluaciones, [true(N1-N2 == 2539-179)]) :-
    evaluaciones(contado_nombre, "nesimo 10 fibs", N1),
    evaluaciones(contado_necesidad, "nesimo 10 fibs", N2).

test(lam_con, [true(V == 120)]) :-
    lam_con(cond, "fact 5", V).

test(ejecutar_con, [true(V == 120)]) :-
    ejecutar_con(z, "z f 5", V).

test(suma_cuadrados_pares_vacia, [true(S == 0)]) :-
    suma_cuadrados_pares(1, S).

test(desazucar_sin_searec, [true(D == ap(id(f), num(1)))]) :-
    desazucar(ap(id(f), num(1)), D).

:- end_tests(soluciones).
