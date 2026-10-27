:- encoding(utf8).

:- begin_tests(acumulador).

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

test(hoja, true(C == [cargar(id(a))])) :-
    generar_acumulador(id(a), C).

test(operando_hoja, true(C == [cargar(id(a)), operar(-, num(1))])) :-
    expresion_ast("a - 1", E),
    generar_acumulador(E, C).

test(temporal, true(C == [cargar(id(b)), operar(*, id(c)),
                          guardar(t(0)), cargar(id(a)), operar(-, t(0))])) :-
    expresion_ast("a - b * c", E),
    generar_acumulador(E, C).

test(acumula_a_la_izquierda, true(N == 0)) :-
    expresion_ast("a + b + c + d", E),
    generar_acumulador(E, C),
    temporales(C, N).

test(reutiliza_temporal, true(N == 1)) :-
    expresion_ast("a + (b + (c + d))", E),
    generar_acumulador(E, C),
    temporales(C, N).

test(dos_temporales, true(N == 2)) :-
    expresion_ast("(a - (b - c)) - (c - d)", E),
    generar_acumulador(E, C),
    temporales(C, N).

test(mismo_valor, true) :-
    entorno(Entorno),
    forall(expresion(T),
           ( expresion_ast(T, E),
             generar_acumulador(E, C),
             ejecutar_acumulador(C, Entorno, V),
             evaluar(E, Entorno, V) )).

test(ejecutar, true(V == -1)) :-
    ejecutar_acumulador([cargar(num(5)), guardar(t(0)), cargar(num(4)),
                         operar(-, t(0))], [], V).

test(paso, true(S == ac(9, T))) :-
    empty_assoc(T),
    paso_acumulador(operar(+, id(x)), [x-4], ac(5, T), S).

test(instruccion, true(S == ac(5, T))) :-
    empty_assoc(T),
    instruccion_acumulador([], cargar(num(5)), ac(0, T), S).

test(valor_temporal, true(V == 8)) :-
    list_to_assoc([0-8], T),
    valor_acumulador(t(0), [], T, V).

test(hojas, all(E == [num(1), id(x)])) :-
    member(E, [num(1), id(x), bin(+, num(1), num(2))]),
    hoja(E).

:- end_tests(acumulador).
