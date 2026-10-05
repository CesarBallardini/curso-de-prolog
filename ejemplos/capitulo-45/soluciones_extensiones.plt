:- encoding(utf8).

:- begin_tests(soluciones_extensiones).

%!  expresion_ast(+Texto:string, -E) is det.
%
%   E es la sintaxis abstracta de la expresión Texto.
expresion_ast(Texto, E) :-
    string_concat("escribir ", Texto, Programa),
    analizar(Programa, [escribir(E)]).

test(sin_temporal, true(C == [cargar(id(b)), operar(*, id(c)),
                              operar(+, id(a))])) :-
    expresion_ast("a + b * c", E),
    generar_acumulador_conmutativo(E, C).

test(resta_con_temporal, true(N == 1)) :-
    expresion_ast("a - b * c", E),
    generar_acumulador_conmutativo(E, C),
    temporales(C, N).

test(cadena_a_la_derecha, true(N == 0)) :-
    expresion_ast("a + (b + (c + d))", E),
    generar_acumulador_conmutativo(E, C),
    temporales(C, N).

test(mismo_valor, true) :-
    Entorno = [a-20, b-7, c-3, d-1],
    forall(member(T, ["a + b * c", "a - b * c", "a * (b - (c - d))",
                      "(a - (b - c)) - (c - d)", "a + (b + (c + d))"]),
           ( expresion_ast(T, E),
             generar_acumulador_conmutativo(E, C),
             ejecutar_acumulador(C, Entorno, V),
             evaluar(E, Entorno, V) )).

test(ejercicio_14, true(Ns-Is == [2, 3, 2, 4]-[2, 3, 4, 4])) :-
    Ts = ["a + b", "(a + b) * (c + d)", "a - (b - (c - d))",
          "((a + b) + (c + d)) * ((a - b) - (c - d))"],
    findall(N-I, ( member(T, Ts),
                   expresion_ast(T, E),
                   registros_necesarios(E, N),
                   generar_ingenuo(E, C),
                   registros_usados(C, I) ), Ps),
    pairs_keys_values(Ps, Ns, Is).

test(profundidad_factorial, true(S-M == [120]-5)) :-
    fuente_funciones(factorial, T),
    correr_con_profundidad(T, S, M).

test(profundidad_iterativo, true(M == 1)) :-
    fuente_funciones(iterativo, T),
    correr_con_profundidad(T, _, M).

test(profundidad_fibonacci, true(M == 7)) :-
    fuente_funciones(fibonacci, T),
    correr_con_profundidad(T, _, M).

test(profundidad_sin_funciones, true(M == 0)) :-
    correr_con_profundidad("escribir 1", _, M).

:- end_tests(soluciones_extensiones).
