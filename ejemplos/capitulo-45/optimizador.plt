:- encoding(utf8).

:- begin_tests(optimizador).

test(a_termino, [true(T == 2 * x + y // 3)]) :-
    a_termino(bin(+, bin(*, num(2), id(x)), bin(/, id(y), num(3))), T).

test(de_termino, [true(E == bin(+, bin(*, num(2), id(x)),
                                bin(/, id(y), num(-3))))]) :-
    de_termino(2 * x + y // -3, E).

test(plegar, [true(E == bin(*, num(1440), id(d)))]) :-
    plegar_expresion(bin(*, id(d), bin(*, num(24), num(60))), E).

test(plegar_suma_no, [true(E == bin(+, bin(+, id(x), num(2)), num(3)))]) :-
    plegar_expresion(bin(+, bin(+, id(x), num(2)), num(3)), E).

test(plegar_resta, [true(E == num(0))]) :-
    plegar_expresion(bin(-, id(x), id(x)), E).

test(reordenar, [true(N0-N == 4-2)]) :-
    E0 = bin(+, id(a), bin(+, id(b), bin(+, id(c), id(d)))),
    reordenar_expresion(E0, E),
    pila(E0, N0),
    pila(E, N).

test(resta_no_se_reordena, [true(E == E0)]) :-
    E0 = bin(-, id(a), bin(-, id(b), id(c))),
    reordenar_expresion(E0, E).

test(optimizar, [true(P == [asignar(s, bin(*, num(1440), id(d)))])]) :-
    analizar("s := d * (24 * 60)", P0),
    optimizar(P0, P).

test(constante, [true(C == [])]) :-
    mirilla([apilar(2), apilar(1), comparar(>), saltar_si_cero(_)], C).

% apilar(0) y saltar_si_cero pasan a saltar; lo que sigue al salto no se
% ejecuta; y el salto a la instrucción siguiente sobra.
test(salto_incondicional, [true(C =@= [etiqueta(_)])]) :-
    mirilla([apilar(0), saltar_si_cero(L), apilar(7), escribir,
             etiqueta(L)], C).

test(codigo_muerto, [true(C =@= [saltar(L), etiqueta(M)])]) :-
    mirilla([saltar(L), apilar(7), escribir, etiqueta(M)], C).

test(marcas_seguidas, [true(A == B)]) :-
    mirilla([etiqueta(A), etiqueta(B)], [etiqueta(_)]).

test(bucle_vacio, [true(C =@= [etiqueta(A), cargar(n),
                               saltar_si_cero(B), saltar(A),
                               etiqueta(B)])]) :-
    C0 = [etiqueta(A), cargar(n), saltar_si_cero(B), saltar(A), etiqueta(B)],
    mirilla(C0, C).

test(bucle_vacio_ingenuo, [true(A == B)]) :-
    C0 = [etiqueta(A), cargar(n), saltar_si_cero(B), saltar(A), etiqueta(B)],
    mirilla_ingenua(C0, C),
    C == [etiqueta(A), cargar(n), saltar_si_cero(A), etiqueta(A)].

test(ingenuo_no_ensambla, [fail]) :-
    fuente_ejemplo(cuenta, T),
    analizar(T, P),
    generar(P, C0),
    mirilla_ingenua(C0, C),
    ensamblar(C, _, _).

test(mas_corto, [true(N0-N == 22-19)]) :-
    fuente_ejemplo(cuenta, T),
    analizar(T, P),
    generar(P, C0),
    mirilla(C0, C),
    length(C0, N0),
    length(C, N).

% El código optimizado escribe lo mismo que el intérprete.
test(como_el_interprete, [forall(fuente_ejemplo(_, T)),
                          true(Optimizado == Interprete)]) :-
    correr_optimizado(T, Optimizado),
    ejecutar(T, Interprete).

test(division_por_cero, [error(evaluation_error(zero_divisor))]) :-
    correr_optimizado("escribir 1 / 0", _).

:- end_tests(optimizador).
