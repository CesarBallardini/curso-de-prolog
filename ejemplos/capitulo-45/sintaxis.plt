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

:- end_tests(sintaxis).
