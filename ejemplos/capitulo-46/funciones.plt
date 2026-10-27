:- encoding(utf8).

:- begin_tests(funciones).

test(lexico_coma, true(Ts == [id(f), '(', id(a), ',', num(1), ')'])) :-
    lexico("f(a, 1)", Ts).

test(analizar, true(P == programa([funcion(doble, [x],
                                           [devolver(bin(*, num(2),
                                                         id(x)))])],
                                  [escribir(llamada(doble, [num(4)]))]))) :-
    analizar_funciones("funcion doble(x) devolver 2 * x fin; \c
                        escribir doble(4)", P).

test(sin_funciones, true(P == programa([], [escribir(num(1))]))) :-
    analizar_funciones("escribir 1", P).

test(sin_parametros, true(Fs == [funcion(siete, [], [devolver(num(7))])])) :-
    analizar_funciones("funcion siete() devolver 7 fin; escribir siete()",
                       programa(Fs, _)).

test(dos_parametros, true(Ps == [a, b])) :-
    fuente_funciones(mcd, T),
    analizar_funciones(T, programa([funcion(mcd, Ps, _)], _)).

test(definicion_sin_fin, fail) :-
    analizar_funciones("funcion f(x) devolver x; escribir f(1)", _).

test(codigo, true(O == [apilar(4), llamar(4, 1), escribir, saltar(10),
                        apilar(2), cargar_local(0), multiplicar, volver,
                        apilar(0), volver])) :-
    compilar_funciones("funcion doble(x) devolver 2 * x fin; \c
                        escribir doble(4)", O).

test(no_definida, fail) :-
    compilar_funciones("escribir f(1)", _).

test(otra_aridad, fail) :-
    compilar_funciones("funcion f(x) devolver x fin; escribir f(1, 2)", _).

test(factorial, true(S == [120])) :-
    fuente_funciones(factorial, T),
    correr_funciones(T, S).

test(locales, true(S == [24, 4])) :-
    fuente_funciones(iterativo, T),
    correr_funciones(T, S).

test(fibonacci, true(S == [0, 1, 1, 2, 3, 5, 8, 13])) :-
    fuente_funciones(fibonacci, T),
    correr_funciones(T, S).

test(recursion_mutua, true(S == [1, 1, 0])) :-
    fuente_funciones(paridad, T),
    correr_funciones(T, S).

test(mcd, true(S == [12])) :-
    fuente_funciones(mcd, T),
    correr_funciones(T, S).

test(devuelve_cero, true(S == [0])) :-
    correr_funciones("funcion f(x) y := x fin; escribir f(5)", S).

test(local_sin_asignar, true(S == [0])) :-
    correr_funciones("funcion f() devolver z fin; z := 9; escribir f()", S).

test(sin_funciones_igual, true) :-
    forall(fuente_ejemplo(_, T),
           ( ejecutar(T, S),
             correr_funciones(T, S) )).

test(volver_sin_marco, fail) :-
    correr_funciones("devolver 1", _).

test(locales_orden, true(Ls == [b, a, c])) :-
    locales([b, a], [asignar(c, bin(+, id(a), id(b)))], Ls).

test(localizar, true(Is == [cargar_local(1), guardar_local(0), sumar])) :-
    maplist(localizar([x, y]), [cargar(y), guardar(x), sumar], Is).

test(resolver, true(Is == [llamar(L, 2), escribir])) :-
    resolver_llamadas([f-L-2], [llamar(f, 2), escribir], Is).

test(entrada, true(E = f-_-2)) :-
    entrada_funcion(funcion(f, [a, b], []), E).

test(marco, true(P-Ls-R == [9]-[0-4, 1-5]-3)) :-
    empty_assoc(M),
    phrase(paso_funciones(llamar(10, 2), f(s(2, [5, 4, 9], M), []),
                          f(s(10, P, M), [marco(L, R)])), []),
    assoc_to_list(L, Ls).

test(volver, true(E == f(s(3, [7, 9], M), []))) :-
    empty_assoc(M),
    phrase(paso_funciones(volver, f(s(12, [7, 9], M), [marco(M, 3)]), E),
           []).

:- end_tests(funciones).
