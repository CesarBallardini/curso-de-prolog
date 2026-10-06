:- encoding(utf8).

:- begin_tests(lexico).

test(mini, [true(Cs == [mientras, id(x), <=, num(10), hacer, id(x), :=,
                        id(x), +, num(1), fin])]) :-
    componentes("mientras x <= 10 hacer x := x + 1 fin", Cs).

% La coincidencia más larga: sino es una palabra reservada, y siguiente
% un identificador que empieza como si.
test(mas_larga, [true(Cs == [sino, id(siguiente)])]) :-
    componentes("sino siguiente", Cs).

test(simbolos, [true(Cs == [id(a), <>, id(b), ;, '(', num(2), ')'])]) :-
    componentes("a<>b;(2)", Cs).

test(prefijo, [true(N == 2)]) :-
    string_chars("12a", W),
    prefijo_mas_largo(er("[0-9]+"), W, N).

test(prefijo_vacio, [true(N == 0)]) :-
    string_chars("a", W),
    prefijo_mas_largo(er("[0-9]+"), W, N).

test(error, [throws(error(syntax_error(componente_desconocido('# y')),
                          _))]) :-
    componentes("x # y", _).

% Los mismos componentes que el analizador léxico del capítulo 45.
test(capitulo45, [forall(texto_mini(T)), true(Cs == Ms)]) :-
    componentes(T, Cs),
    mini:lexico(T, Ms).

texto_mini("x := 2 * (y + 1); escribir x").
texto_mini("si x >= 10 entonces escribir x sino x := x - 1 fin").
texto_mini("mientras n <> 0 hacer f := f * n; n := n - 1 fin").

:- load_files(mini:'../capitulo-45/sintaxis', []).

test(vacio, [true(Cs == [])]) :-
    componentes("", Cs).

test(leer, [true(Cs == [id(x), :=, num(42)])]) :-
    lexico:leer([x, ' ', :, =, ' ', '4', '2'], Cs).

% Ante un empate gana el primero: la regla escrita antes.
test(mejor, [true(M == 5-b)]) :-
    lexico:mejor([3-a, 5-b, 5-c, 2-d], 0-ninguna, M).

test(mejor_vacio, [true(M == 0-ninguna)]) :-
    lexico:mejor([], 0-ninguna, M).

test(componente_numero, [true(Cs == [num(42), fin])]) :-
    lexico:componente(numero, ['4', '2'], Cs, [fin]).

test(componente_blanco, [true(Cs == [fin])]) :-
    lexico:componente(blanco, [' '], Cs, [fin]).

test(componente_identificador, [true(Cs == [id(x1)])]) :-
    lexico:componente(identificador, [x, '1'], Cs, []).

test(avanzar, [true(N == 1)]) :-
    lexico:avanzar(er("ab*"), [b, c], [], 1, 1, N).

:- end_tests(lexico).
