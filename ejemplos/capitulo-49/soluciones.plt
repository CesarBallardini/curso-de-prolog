:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(soluciones).

test(ejercicio_2, [true(F-D == [[[g1]], [[g2]], [[g4]]]-[[[g1]], [[g2]], [[g4]]])]) :-
    sospechosas(fuerte, xor_nand, [[1, 0]-[0]], 2, F),
    sospechosas(debil, xor_nand, [[1, 0]-[0]], 2, D).

test(ejercicio_2_dos, [true(Ds == [[[g1]-invertida], [[g1]-pegada(0)],
                                   [[g2]-pegada(1)], [[g4]-pegada(0)]])]) :-
    mas_simples(fuerte, xor_nand, [[1, 0]-[0], [0, 0]-[0]], Ds).

test(ejercicio_3, [nondet, true(D == [[m2, x1]-pegada(0), [o1]-pegada(0),
                                      [o1]-pegada(1)])]) :-
    diagnostico_mal(sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], D),
    repetida(D).

test(ejercicio_4, [true(N-M == 8-4)]) :-
    aggregate_all(count, diagnostico(flach, sumador, [[0, 0, 1]-[0, 1]], _),
                  N),
    por_filtro(flach, sumador, [[0, 0, 1]-[0, 1]], Ds),
    length(Ds, M).

test(ejercicio_4_dos, [fail]) :-
    mas_simples(flach, sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], _).

test(ejercicio_6, [true(D == [A])]) :-
    A = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)],
    predecir(sumador_sondas, [0, 0, 1], A, Ss),
    localizar(sumador_sondas, A, [[0, 0, 1]-Ss], _, D).

test(ejercicio_7, [nondet, true(R == [[m1, x1], [m1, y1], [m2, x1], [m2, y1],
                                      [o1]])]) :-
    explicar(fuerte, sumador, [[1, 0, 1]-[0, 1]], S),
    sanas(S, R).

test(ejercicio_8, [true(Ss == [[arranque-malo, bateria-bien],
                                [combustible-vacio, bateria-bien]])]) :-
    findall(S, ( abducir((motor(no_arranca), luces(encendidas)), S),
                 cerrar(S) ),
            Ss).

test(ejercicio_9, [true(D == [[s2, m2, y1]-pegada(0)])]) :-
    mas_probables(sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 2,
                  [_-D|_]).

test(ejercicio_10, [true(C == [[m1, x1], [m2, x1]])]) :-
    cono(sumador, s, C).

test(ejercicio_10_conos, [true]) :-
    O = [1, 1, 0, 1, 0, 1]-[1, 0, 0, 0],
    minimos(fuerte, sumador3, [O], 2, Ds),
    forall(member(D, Ds), toca_los_conos(sumador3, O, D)).

test(ejercicio_11, [true(P-U == [[0, 0, 0], [0, 1, 1], [1, 1, 1]]-[])]) :-
    conjunto_de_pruebas(sumador, P, U).

% Con un solo supuesto por componente, la copia coincide con abducir/2.
test(abducir_mal_una, all(S == [[[g]-pegada(0)], [[g]-invertida]])) :-
    abducir_mal(salida(fuerte, [g], and, [1, 1], 0), S),
    cerrar(S).

test(abductiva_mal, all(S-Sp == [1-[[g]-ok], 0-[[g]-pegada(0)],
                                 1-[[g]-pegada(1)], 0-[[g]-invertida]])) :-
    abductiva_mal(Sp, [g], and, [1, 1], S),
    cerrar(Sp).

test(observar_mal, all(S == [[[x1]-ok, [y1]-ok], [[x1]-ok, [y1]-pegada(1)],
                             [[x1]-pegada(0), [y1]-ok],
                             [[x1]-pegada(0), [y1]-pegada(1)]])) :-
    observar_mal(semisumador, S, [1, 1]-[0, 1]),
    cerrar(S).

test(repetida_no, [fail]) :-
    repetida([[a]-x, [b]-y]).

test(repetida_si, [true]) :-
    repetida([[b]-y, [a]-x, [a]-y]).

test(sanas_vacio, [true(R == [])]) :-
    sanas([], R).

test(sanas, [true(R == [[a], [c]])]) :-
    sanas([[a]-ok, [b]-pegada(1), [c]-ok], R).

test(multiplicar, [true(P =:= 0.0005)]) :-
    multiplicar([g]-invertida, 0.5, P).

test(con_probabilidad_sano, [true(abs(P - 0.979 ** 5) < 1.0e-12)]) :-
    con_probabilidad(5, [], P-[]).

test(con_probabilidad, [true(abs(P - 0.01 * 0.979 ** 4) < 1.0e-12)]) :-
    con_probabilidad(5, [[g]-pegada(1)], P-_).

% pegada(1) es diez veces más probable que invertida.
test(mas_probables, [true(Ds == [[[m1, x1]-pegada(1)],
                                 [[m1, x1]-invertida]])]) :-
    mas_probables(sumador, [[0, 0, 1]-[0, 1]], 1, Pares),
    pairs_values(Pares, Ds).

test(cono_acarreo, [true(C == [[m1, x1], [m1, y1], [m2, y1], [o1]])]) :-
    cono(sumador, co, C).

test(depende_entrada, [true(R-E == []-[a])]) :-
    depende(sumador, [], a, R, E).

test(depende_cable, [true(R-E == [[m1, x1]]-[a, b])]) :-
    depende(sumador, [], t, R, E).

test(unir, [true(U == [[m1, x1]]-[a, a, b])]) :-
    unir(sumador, [], t, []-[a], U).

test(toca_los_conos_no, [fail]) :-
    toca_los_conos(sumador, [0, 0, 1]-[0, 1], [[o1]-pegada(1)]).

test(toca_los_conos_si, [true]) :-
    toca_los_conos(sumador, [0, 0, 1]-[0, 1], [[m1, x1]-pegada(1)]).

test(detecta_si, [true]) :-
    detecta(sumador, [0, 0, 1], [o1]-pegada(1)).

test(detecta_no, [fail]) :-
    detecta(sumador, [0, 0, 1], [o1]-pegada(0)).

test(fallas_simples, [true(N == 15)]) :-
    fallas_simples(sumador, Fs),
    length(Fs, N).

test(conjunto_semisumador, [true(P-U == [[0, 0], [0, 1], [1, 1]]-[])]) :-
    conjunto_de_pruebas(semisumador, P, U).

% Una falla que ninguna entrada detecta queda sin detectar.
test(elegir_sin_deteccion, [true(P-U == []-[[o1]-pegada(0)])]) :-
    elegir(sumador, [[0, 0, 0]], [[o1]-pegada(0)], P, U).

% Ejercicio 13: en el modelo fuerte, agregar una compuerta puede romper
% un diagnóstico.
test(ejercicio_13, [true]) :-
    conjunto_fuerte(sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]], [[m1, x1]]).

test(ejercicio_13_mas, [fail]) :-
    conjunto_fuerte(sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]],
                    [[m1, x1], [o1]]).

:- end_tests(soluciones).
