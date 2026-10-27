:- encoding(utf8).

:- begin_tests(sintaxis).

test(componentes, [true(Ts == [id(x), :=, id(x), +, num(1)])]) :-
    lexico("x := x + 1", Ts).

test(reservadas, [true(Ts == [mientras, id(sin), <>, num(0), hacer, fin])]) :-
    lexico("mientras sin<>0 hacer fin", Ts).

test(simbolos_dobles, [true(Ts == [<=, >=, <>, :=, <, >, =])]) :-
    lexico("<= >= <> := < > =", Ts).

test(caracter_invalido, [fail]) :-
    lexico("x := 3 # 4", _).

test(precedencia, [true(P == [asignar(x, bin(+, num(1),
                                             bin(*, num(2), num(3))))])]) :-
    analizar("x := 1 + 2 * 3", P).

test(izquierda, [true(E == bin(-, bin(-, num(10), num(3)), num(2)))]) :-
    analizar("x := 10 - 3 - 2", [asignar(x, E)]).

test(parentesis, [true(E == bin(*, num(2), bin(+, id(y), num(1))))]) :-
    analizar("x := 2 * (y + 1)", [asignar(x, E)]).

test(si_sin_sino, [true(P == [si(rel(<, id(a), num(0)),
                                 [asignar(a, num(0))], [])])]) :-
    analizar("si a < 0 entonces a := 0 fin", P).

test(bloque_vacio, [true(P == [mientras(rel(=, id(x), num(1)), [])])]) :-
    analizar("mientras x = 1 hacer fin", P).

test(programa_vacio, [true(P == [])]) :-
    analizar("", P).

test(punto_y_coma_final, [true(P == [escribir(num(1))])]) :-
    analizar("escribir 1;", P).

test(incompleto, [fail]) :-
    analizar("x := ", _).

test(sin_fin, [fail]) :-
    analizar("si x > 0 entonces x := 1", _).

test(ejemplos, [true(Ns == [cuenta, factorial, mcd, suma])]) :-
    findall(N, programa_ejemplo(N, _), Ns0),
    msort(Ns0, Ns).

test(factorial) :-
    programa_ejemplo(factorial, P),
    P = [asignar(n, num(5)), asignar(f, num(1)),
         mientras(rel(>, id(n), num(0)), [_, _]), escribir(id(f))].

test(componentes_dcg, true(Cs == [id(x), :=, num(10), ;])) :-
    phrase(componentes(Cs), `x := 10;`).

test(componente_reservada, true(C == mientras)) :-
    phrase(componente(C), `mientras`).

test(palabra, true(Ps == [si, id(x)])) :-
    palabra(si, P1),
    palabra(x, P2),
    Ps = [P1, P2].

test(digito, true(D-R == 0'7-`x`)) :-
    phrase(digito(D), `7x`, R).

test(no_es_digito, fail) :-
    phrase(digito(_), `x`, _).

test(digitos, true(Ds-R == `42`-`a`)) :-
    phrase(digitos(Ds), `42a`, R).

test(alfanumericos, true(Cs-R == `ab1`-` c`)) :-
    phrase(alfanumericos(Cs), `ab1 c`, R).

test(blancos, true(R == `x`)) :-
    phrase(blancos, `  x`, R).

test(precedencia, all(E == [bin(+, id(x), bin(*, num(2), num(3)))])) :-
    phrase(expresion(E), [id(x), +, num(2), *, num(3)]).

test(termino_a_izquierda,
     all(T == [bin(/, bin(*, num(2), id(x)), num(3))])) :-
    phrase(termino(T), [num(2), *, id(x), /, num(3)]).

test(factor_parentesis, all(F == [num(1)])) :-
    phrase(factor(F), ['(', num(1), ')']).

test(condicion, all(C == [rel(<, id(x), num(3))])) :-
    phrase(condicion(C), [id(x), <, num(3)]).

test(sentencia, all(S == [escribir(id(x))])) :-
    phrase(sentencia(S), [escribir, id(x)]).

test(bloque, all(Ss == [[escribir(num(1)), escribir(num(2))]])) :-
    phrase(bloque(Ss), [escribir, num(1), ;, escribir, num(2)]).

test(programa, all(P == [[escribir(num(1))]])) :-
    phrase(programa(P), [escribir, num(1)]).

test(tablas) :-
    reservada(fin),
    relacion(<=),
    phrase(simbolo(:=), `:=`).

test(fuente, true(L == 7)) :-
    fuente(cuenta, Lineas),
    length(Lineas, L).

:- end_tests(sintaxis).
