:- encoding(utf8).

:- begin_tests(registros).

%!  expresion(-Texto:string) is multi.
%
%   Expresiones de prueba, con las variables a, b, c y d.
expresion("a").
expresion("7").
expresion("a - b * c").
expresion("(a - b) * c").
expresion("a + (b + (c + d))").
expresion("a + b + c + d").
expresion("(a - b) / (c - d)").
expresion("a * (b - (c - (d - 1)))").
expresion("(a - (b - c)) - (c - d)").

%!  entorno(-E:list) is det.
%
%   Valores para las variables de las expresiones de prueba.
entorno([a-20, b-7, c-3, d-1]).

%!  expresion_ast(+Texto:string, -E) is det.
%
%   E es la sintaxis abstracta de la expresión Texto.
expresion_ast(Texto, E) :-
    string_concat("escribir ", Texto, Programa),
    analizar(Programa, [escribir(E)]).

test(ingenuo, true(C == [cargar(0, id(a)), cargar(1, id(b)),
                         cargar(2, id(c)), operar(*, 1, 2),
                         operar(-, 0, 1)])) :-
    expresion_ast("a - b * c", E),
    generar_ingenuo(E, C).

test(sethi_ullman, true(C == [cargar(1, id(b)), cargar(0, id(c)),
                              operar(*, 1, 0), cargar(0, id(a)),
                              operar(-, 0, 1)])) :-
    expresion_ast("a - b * c", E),
    generar_registros(E, C).

test(necesarios, true(Ns == [1, 1, 2, 2, 2, 2, 3, 2, 3])) :-
    findall(N, ( expresion(T),
                 expresion_ast(T, E),
                 registros_necesarios(E, N) ), Ns).

test(usa_los_necesarios, true) :-
    forall(expresion(T),
           ( expresion_ast(T, E),
             generar_registros(E, C),
             registros_usados(C, N),
             registros_necesarios(E, N) )).

test(nunca_mas_que_el_ingenuo, true) :-
    forall(expresion(T),
           ( expresion_ast(T, E),
             generar_registros(E, C1),
             generar_ingenuo(E, C2),
             registros_usados(C1, N1),
             registros_usados(C2, N2),
             N1 =< N2 )).

test(ingenuo_a_la_derecha, true(N == 4)) :-
    expresion_ast("a + (b + (c + d))", E),
    generar_ingenuo(E, C),
    registros_usados(C, N).

test(mismo_valor, true) :-
    entorno(Entorno),
    forall(expresion(T),
           ( expresion_ast(T, E),
             generar_registros(E, C1),
             generar_ingenuo(E, C2),
             evaluar(E, Entorno, V),
             ejecutar_registros(C1, Entorno, V),
             ejecutar_registros(C2, Entorno, V) )).

test(libres_insuficientes, fail) :-
    phrase(codigo_registros(bin(+, id(a), id(b)), [0]), _).

test(registro, all(R == [0, 1])) :-
    registro(operar(+, 0, 1), R).

test(paso, true(V == 6)) :-
    list_to_assoc([0-2, 1-3], Rs0),
    paso_registros(operar(*, 0, 1), [], Rs0, Rs),
    get_assoc(0, Rs, V).

test(instruccion, true(V == 4)) :-
    empty_assoc(Rs0),
    instruccion_registros([x-4], cargar(0, id(x)), Rs0, Rs),
    get_assoc(0, Rs, V).

:- end_tests(registros).
