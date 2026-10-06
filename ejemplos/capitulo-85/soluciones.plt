:- encoding(utf8).

:- begin_tests(soluciones).

test(expresion, [true(N == 3)]) :-
    expresion(Cs),
    problemas(Cs, Ps),
    length(Ps, N).

test(expr_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(expr([id, +, id], _), 100000, R).

test(componentes, [true(Ks-Ps == [[d/0, e/0], [c/0], [b/0], [a/0], [f/0]]-[f/0-f/0])]) :-
    Cs = [(a :- \+ b), (b :- c), (c :- \+ d), (d :- e), (e :- d),
          (f :- a, \+ f)],
    componentes(Cs, Ks),
    ciclos_negativos(Cs, Ps).

test(casados, [true(M-C == [married(adam, anne), married(anne, adam)]-costo(2, 2))]) :-
    casados(Cs),
    evaluar(Cs, M, C).

test(casados_magia, [true(Rs == [married(anne, adam)])]) :-
    casados(Cs),
    respuestas_magicas(Cs, married(anne, _), Rs, _).

test(suplementario,
     [true(Cs =@= [ (sup_p_1_1(X, Z) :- a(X, Z)),
                    (sup_p_1_2(X, W) :- sup_p_1_1(X, Z), b(Z, W)),
                    (p(X, Y) :- sup_p_1_2(X, W), c(W, Y)) ])]) :-
    suplementario((p(X, Y) :- a(X, Z), b(Z, W), c(W, Y)), 1, Cs).

test(suplementario_corto, [true(Cs =@= [(p(X) :- q(X))])]) :-
    suplementario((p(X) :- q(X)), 1, Cs).

test(conjuncion, [true(C == (s, l))]) :-
    conjuncion(s, l, C).

test(aparece_en, [fail]) :-
    aparece_en([_], _).

% El mismo modelo con los suplementarios, sin sus átomos.
test(suplementarios, [true(R1 == R2)]) :-
    misma_profundidad(Cs),
    suplementarios(Cs, Ss),
    respuestas(Cs, sd(_, _), R1, _),
    respuestas(Ss, sd(_, _), R2, _).

% Ejercicio 4. Las derivaciones se comparan con su valor exacto; las
% inferencias, a propósito, con una banda del 10 % alrededor de la cifra
% impresa, porque cambian de una versión de SWI-Prolog a otra.
test(suplementarios_sd, [true(D-D1 == 49-159)]) :-
    misma_profundidad(Cs),
    suplementarios(Cs, Ss),
    respuestas(Cs, sd(_, _), _, costo(_, D)),
    respuestas(Ss, sd(_, _), _, costo(_, D1)),
    inferencias(respuestas(Cs, sd(_, _), _, _), N),
    inferencias(respuestas(Ss, sd(_, _), _, _), N1),
    en_banda(N, 13854),
    en_banda(N1, 24935).

test(suplementarios_franjas, [true(D-D1-L == 250000-7000-1000)]) :-
    franjas(Cs),
    suplementarios(Cs, Ss),
    respuestas(Cs, franja_del_anio(_, _), Rs, costo(_, D)),
    respuestas(Ss, franja_del_anio(_, _), Rs, costo(_, D1)),
    length(Rs, L),
    inferencias(respuestas(Cs, franja_del_anio(_, _), _, _), N),
    inferencias(respuestas(Ss, franja_del_anio(_, _), _, _), N1),
    en_banda(N, 2315135),
    en_banda(N1, 1587384).

test(misma_profundidad, [true(Rs-D-D1 == [sd(d, d), sd(d, e), sd(d, f)]-49-23)]) :-
    misma_profundidad(Cs),
    respuestas(Cs, sd(d, _), Rs, costo(_, D)),
    respuestas_magicas(Cs, sd(d, _), Rs, costo(_, D1)).

test(debe_camino, [true(Y == 100)]) :-
    debe_camino(99, Y).

test(evita_camino, [true(T1-R1-T2-R2 == 1-99-1-50)]) :-
    tablas(evita_camino(1, _), T1, R1),
    tablas(evita_camino(50, _), T2, R2).

test(programa_camino, [true(M-A == 1-50)]) :-
    programa_camino(Cs),
    magia(Cs, evita(50, _), M, A).

test(reducciones, [true(Ys == [c, d, e, h, i, k])]) :-
    reducciones(Cs),
    respuestas(Cs, fully_reduce(a, _), Rs, _),
    findall(Y, member(fully_reduce(a, Y), Rs), Ys).

test(quitar_hechos, [true(N-C == 439-costo(21, 400))]) :-
    clausulas(cadena(40), Cs),
    quitar_hechos(Cs, [arco(20, 21)], M, C),
    length(M, N).

test(volver_a_agregar, [true(C == costo(21, 420))]) :-
    clausulas(cadena(40), Cs),
    volver_a_agregar(Cs, [arco(20, 21)], C).

test(hecho_de) :-
    hecho_de([p(a)], (p(a) :- true)).

test(segura_magica, [true(Rs-D == [segura(22)]-87)]) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K),
    segura_magica(K, 2-2, Rs, costo(_, D)).

test(restar_con, [true(Ps == [0, 2, 7, 9, 14, 16])]) :-
    restar_con([1, 3, 4], 20, Js),
    retrogrado(Js, T, _),
    findall(P, member(P-pierde(_), T), Ps).

test(evaluar_ingenuo, [true(C == costo(41, 22960))]) :-
    clausulas(cadena(40), Cs),
    evaluar_ingenuo(Cs, M, C),
    evaluar(Cs, M, _).

test(evaluar_ingenuo_negacion, [true(C == costo(6, 48))]) :-
    clausulas(grafo, Cs),
    evaluar_ingenuo(Cs, M, C),
    evaluar(Cs, M, _).

test(cabeza_en) :-
    cabeza_en([p/1], r(p(a), [])).

:- end_tests(soluciones).
