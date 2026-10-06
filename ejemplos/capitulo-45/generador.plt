:- encoding(utf8).

:- begin_tests(generador).

test(expresion, [true(C == [apilar(2), cargar(x), multiplicar, apilar(1),
                            sumar, guardar(x)])]) :-
    analizar("x := 2 * x + 1", P),
    generar(P, C).

test(etiquetas_nuevas) :-
    programa_ejemplo(factorial, P),
    generar(P, C),
    C = [_, _, _, _, etiqueta(Inicio)|_],
    last(C, escribir),
    memberchk(saltar(Inicio), C),
    memberchk(saltar_si_cero(Fin), C),
    var(Inicio),
    var(Fin),
    Inicio \== Fin.

test(si, [true(C =@= [cargar(x), apilar(0), comparar(>), saltar_si_cero(S),
                     apilar(1), escribir, saltar(F), etiqueta(S),
                     apilar(2), escribir, etiqueta(F)])]) :-
    analizar("si x > 0 entonces escribir 1 sino escribir 2 fin", P),
    generar(P, C).

test(ensamblar, [true(O == [cargar(0), apilar(3), comparar(<),
                            saltar_si_cero(9), cargar(0), apilar(1),
                            sumar, guardar(0), saltar(0)])]) :-
    compilar("mientras x < 3 hacer x := x + 1 fin", O).

test(liga_simbolico, [true(Dirs == [4, 17])]) :-
    programa_ejemplo(factorial, P),
    generar(P, S),
    ensamblar(S, _, _),
    findall(D, member(etiqueta(D), S), Dirs).

test(tabla, [true(Tabla == [n-0, f-1|Resto])]) :-
    programa_ejemplo(factorial, P),
    generar(P, S),
    ensamblar(S, _, Tabla),
    Tabla = [_, _|Resto],
    var(Resto).

test(etiqueta_doble, [fail]) :-
    ensamblar([etiqueta(L), apilar(1), etiqueta(L)], _, _).

test(listar, [true(Lineas == ["0   apilar(1)", "1   guardar(0)",
                              "2   cargar(0)", "3   escribir", ""])]) :-
    with_output_to(string(S), listar_objeto("x := 1; escribir x")),
    split_string(S, "\n", "", Lineas).

test(no_es_mini, [fail]) :-
    compilar("x := ", _).

test(codigo_expresion, true(C == [cargar(a), apilar(1), restar])) :-
    phrase(codigo_expresion(bin(-, id(a), num(1))), C).

test(codigo_condicion, true(C == [cargar(a), apilar(1), comparar(<)])) :-
    phrase(codigo_condicion(rel(<, id(a), num(1))), C).

test(codigo_sentencia, true(C == [apilar(1), guardar(x)])) :-
    phrase(codigo_sentencia(asignar(x, num(1))), C).

test(codigo_bloque, true(C == [apilar(1), escribir])) :-
    phrase(codigo_bloque([escribir(num(1))]), C).

test(codigo_mientras, true(C = [etiqueta(I), cargar(n), apilar(0),
                                comparar(>), saltar_si_cero(F), cargar(n),
                                escribir, saltar(I), etiqueta(F)])) :-
    phrase(codigo_sentencia(mientras(rel(>, id(n), num(0)),
                                     [escribir(id(n))])), C).

test(tablas, true(I-C1-C2 == multiplicar-fija-memoria)) :-
    aritmetica(*, I),
    clase(saltar(_), C1),
    clase(cargar(_), C2).

test(objeto, true(O-L == [apilar(1), saltar(0)]-0)) :-
    phrase(objeto([etiqueta(L), apilar(1), saltar(L)], 0, _), O).

test(ensamblar_instruccion, true(D-O == 4-[apilar(1)])) :-
    phrase(ensamblar_instruccion(fija, apilar(1), 3, D, _), O).

test(codigo_ejemplo, true(N == 22)) :-
    codigo_ejemplo(cuenta, C),
    length(C, N).

test(listar_codigo, true(S == "0   apilar(1)\n1   escribir\n")) :-
    with_output_to(string(S), listar_codigo([apilar(1), escribir], 0)).

:- end_tests(generador).
