:- encoding(utf8).

% Capítulo 45 - Versión 2: el intérprete de Mini.
%
% interpretar/2 ejecuta la sintaxis abstracta de sintaxis.pl. El estado del
% programa es el entorno, una lista de pares Nombre-Valor con cada variable
% del programa, que empieza en 0; cada sentencia relaciona el entorno de
% antes con el de después. Lo que el programa escribe es la lista que
% describe la gramática: escribir agrega un número, y la salida entera es
% la lista de esos números. No hay efectos: interpretar/2 relaciona un
% programa con su salida.
%
% Cada construcción tiene una cláusula por caso, sin si-entonces-sino de
% Prolog: la condición cierta en una cláusula, la falsa en otra. Es la forma
% que el evaluador parcial del capítulo 35 puede desplegar (especializar.pl).
%
% solo-local: carga sintaxis.pl con ensure_loaded/1.
%
%?- ejecutar("x := 6; y := x * 7; escribir y", S).
%?- programa_ejemplo(factorial, P), interpretar(P, S).
%?- programa_ejemplo(mcd, P), variables(P, Vs).

:- ensure_loaded(sintaxis).

%!  ejecutar(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, interpretado. Falla
%   si Texto no es un programa Mini.
ejecutar(Texto, Salida) :-
    analizar(Texto, Programa),
    interpretar(Programa, Salida).

%!  interpretar(+Programa:list, -Salida:list(integer)) is det.
%
%   Salida es la lista de los números que escribe Programa, ejecutado con
%   todas sus variables en 0. No termina si Programa no termina.
interpretar(Programa, Salida) :-
    entorno_inicial(Programa, Entorno),
    once(phrase(ejecutar_bloque(Programa, Entorno, _), Salida)).

%!  entorno_inicial(+Programa:list, -Entorno:list) is det.
%
%   Entorno tiene un par Nombre-0 por cada variable de Programa, en orden
%   alfabético.
entorno_inicial(Programa, Entorno) :-
    variables(Programa, Nombres),
    findall(X-0, member(X, Nombres), Entorno).

%!  variables(+Programa:list, -Nombres:list(atom)) is det.
%
%   Nombres son las variables de Programa, ordenadas y sin repetir: las que
%   se asignan y las que se leen.
variables(Programa, Nombres) :-
    findall(X, ( sub_term(T, Programa), nombre(T, X) ), Xs),
    sort(Xs, Nombres).

% nombre(T, X): el nodo T de la sintaxis abstracta nombra la variable X.
nombre(id(X), X).
nombre(asignar(X, _), X).

%!  ejecutar_bloque(+Ss:list, +E0:list, -E:list)// is nondet.
%
%   Ejecutar las sentencias Ss, en orden, lleva el entorno E0 a E; la lista
%   es lo que escriben.
ejecutar_bloque([], E, E) -->
    [].
ejecutar_bloque([S|Ss], E0, E) -->
    ejecutar_sentencia(S, E0, E1),
    ejecutar_bloque(Ss, E1, E).

%!  ejecutar_sentencia(+S, +E0:list, -E:list)// is nondet.
%
%   Ejecutar la sentencia S lleva el entorno E0 a E. Para si y mientras hay
%   dos cláusulas, con la condición cierta y falsa: solo una se cumple,
%   pero la otra queda como alternativa pendiente.
ejecutar_sentencia(asignar(X, Exp), E0, E) -->
    { evaluar(Exp, E0, V),
      actualizar(X, V, E0, E) }.
ejecutar_sentencia(escribir(Exp), E, E) -->
    { evaluar(Exp, E, V) },
    [V].
ejecutar_sentencia(si(C, Si, _), E0, E) -->
    { cierta(C, E0) },
    ejecutar_bloque(Si, E0, E).
ejecutar_sentencia(si(C, _, No), E0, E) -->
    { falsa(C, E0) },
    ejecutar_bloque(No, E0, E).
ejecutar_sentencia(mientras(C, Cuerpo), E0, E) -->
    { cierta(C, E0) },
    ejecutar_bloque(Cuerpo, E0, E1),
    ejecutar_sentencia(mientras(C, Cuerpo), E1, E).
ejecutar_sentencia(mientras(C, _), E, E) -->
    { falsa(C, E) }.

%!  cierta(+C, +E:list) is semidet.
%
%   La condición C se cumple en el entorno E.
cierta(rel(Op, A, B), E) :-
    evaluar(A, E, X),
    evaluar(B, E, Y),
    comparar(Op, X, Y).

%!  falsa(+C, +E:list) is semidet.
%
%   La condición C no se cumple en el entorno E: se cumple la comparación
%   contraria.
falsa(rel(Op, A, B), E) :-
    contraria(Op, No),
    cierta(rel(No, A, B), E).

% contraria(Op, No): la comparación No se cumple cuando Op no se cumple.
contraria(=, <>).
contraria(<>, =).
contraria(<, >=).
contraria(>=, <).
contraria(>, <=).
contraria(<=, >).

%!  comparar(+Op, +X:integer, +Y:integer) is semidet.
%
%   X e Y cumplen la comparación Op de Mini.
comparar(=, X, Y) :-
    X =:= Y.
comparar(<>, X, Y) :-
    X =\= Y.
comparar(<, X, Y) :-
    X < Y.
comparar(>, X, Y) :-
    X > Y.
comparar(<=, X, Y) :-
    X =< Y.
comparar(>=, X, Y) :-
    X >= Y.

%!  evaluar(+Exp, +E:list, -V:integer) is det.
%
%   V es el valor de la expresión Exp en el entorno E. Produce un error de
%   evaluación si divide por cero.
evaluar(num(N), _, N).
evaluar(id(X), E, V) :-
    valor(X, E, V).
evaluar(bin(Op, A, B), E, V) :-
    evaluar(A, E, X),
    evaluar(B, E, Y),
    operar(Op, X, Y, V).

%!  operar(+Op, +X:integer, +Y:integer, -V:integer) is det.
%
%   V es el resultado de la operación Op de Mini; / es la división entera,
%   que trunca hacia cero.
operar(+, X, Y, V) :-
    V is X + Y.
operar(-, X, Y, V) :-
    V is X - Y.
operar(*, X, Y, V) :-
    V is X * Y.
operar(/, X, Y, V) :-
    V is X // Y.

%!  valor(+X:atom, +E:list, -V) is semidet.
%
%   V es el valor de la variable X en el entorno E.
valor(X, E, V) :-
    memberchk(X-V, E).

%!  actualizar(+X:atom, +V, +E0:list, -E:list) is semidet.
%
%   E es el entorno E0 con el valor de X reemplazado por V.
actualizar(X, V, [Y-W|E0], E) :-
    (   X == Y
    ->  E = [X-V|E0]
    ;   E = [Y-W|E1],
        actualizar(X, V, E0, E1)
    ).
