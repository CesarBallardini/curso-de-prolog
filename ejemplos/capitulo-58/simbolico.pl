:- encoding(utf8).

% Capítulo 58 - Versión 2: el programa sobre valores simbólicos.
%
% Las variables de entrada no tienen un valor: son incógnitas, átomos, y
% las expresiones se evalúan a expresiones de Prolog sobre esas
% incógnitas, simplificadas con el simplificador del capítulo 32. Una
% condición que compara dos números se decide; una que compara
% expresiones con incógnitas no se puede decidir, y el programa sigue las
% dos ramas, cada una con la condición supuesta. Cada respuesta es un
% camino del programa: las condiciones que lo eligen y lo que escribe.
%
% El mientras tiene primero la cláusula que sale del bucle, así las
% respuestas llegan en orden de vueltas: 0, 1, 2... Con una condición sobre
% una incógnita, los caminos son infinitos.
%
% solo-local: carga concreto.pl y simplificar.pl del capítulo 32 con
% ensure_loaded/1.
%
%?- programa_caso(cuadrado, P, _), simbolizar(P, [n], Cs, S).
%?- programa_caso(factorial, P, _), limit(3, simbolizar(P, [n], Cs, S)).

:- ensure_loaded(concreto).
:- ensure_loaded('../capitulo-32/simplificar').

%!  simbolizar(+Programa:list, +Incognitas:list(atom), -Condiciones:list,
%!             -Salida:list) is nondet.
%
%   Salida es lo que escribe Programa por un camino, con las variables de
%   Incognitas como incógnitas y las demás en 0, y Condiciones son las
%   comparaciones que elige ese camino, en orden. Una respuesta por camino;
%   las condiciones no se verifican entre sí, y un camino puede ser
%   imposible.
simbolizar(Programa, Incognitas, Condiciones, Salida) :-
    entorno_inicial(Programa, E0),
    foldl(incognita, Incognitas, E0, E1),
    phrase(sim_bloque(Programa, s(E1, []), s(_, Cs)), Salida),
    reverse(Cs, Condiciones).

%!  simbolizar_caso(+Nombre, -Condiciones:list, -Salida:list) is nondet.
%
%   Como simbolizar/4, sobre el caso Nombre con sus entradas como
%   incógnitas.
simbolizar_caso(Nombre, Condiciones, Salida) :-
    programa_caso(Nombre, Programa, Entradas),
    findall(X, member(X-_, Entradas), Incognitas),
    simbolizar(Programa, Incognitas, Condiciones, Salida).

%!  incognita(+X:atom, +E0:list, -E:list) is det.
%
%   E es el entorno E0 con la variable X ligada a la incógnita X.
incognita(X, E0, E) :-
    fijar(X-X, E0, E).

%!  sim_bloque(+Ss:list, +S0, -S)// is nondet.
%
%   Ejecutar las sentencias Ss sobre valores simbólicos lleva el estado
%   S0 a S; un estado es s(Entorno, Condiciones), con las condiciones del
%   camino de la última a la primera.
sim_bloque([], S, S) -->
    [].
sim_bloque([Sent|Ss], S0, S) -->
    sim_sentencia(Sent, S0, S1),
    sim_bloque(Ss, S1, S).

%!  sim_sentencia(+Sent, +S0, -S)// is nondet.
%
%   Ejecutar la sentencia Sent sobre valores simbólicos lleva el estado S0
%   a S. Un si o un mientras con una condición que no se decide da una
%   respuesta por rama.
sim_sentencia(asignar(X, Exp), s(E0, Cs), s(E, Cs)) -->
    { sim_valor(Exp, E0, V),
      actualizar(X, V, E0, E) }.
sim_sentencia(escribir(Exp), s(E, Cs), s(E, Cs)) -->
    { sim_valor(Exp, E, V) },
    [V].
sim_sentencia(si(C, Si, _), S0, S) -->
    { suponer(C, S0, S1) },
    sim_bloque(Si, S1, S).
sim_sentencia(si(C, _, No), S0, S) -->
    { negar(C, NoC),
      suponer(NoC, S0, S1) },
    sim_bloque(No, S1, S).
sim_sentencia(mientras(C, _), S0, S) -->
    { negar(C, NoC),
      suponer(NoC, S0, S) }.
sim_sentencia(mientras(C, Cuerpo), S0, S) -->
    { suponer(C, S0, S1) },
    sim_bloque(Cuerpo, S1, S2),
    sim_sentencia(mientras(C, Cuerpo), S2, S).

%!  negar(+C, -NoC) is det.
%
%   NoC es la condición contraria de C, con contraria/2 del capítulo 45.
negar(rel(Op, A, B), rel(No, A, B)) :-
    contraria(Op, No).

%!  suponer(+C, +S0, -S) is semidet.
%
%   S es el estado S0 en el que se supone la condición C. Si los dos lados
%   son números, C se decide: S es S0 si se cumple, y falla si no. Si no,
%   S agrega C a las condiciones, como comparación de Prolog.
suponer(rel(Op, A, B), s(E, Cs), s(E, Cs1)) :-
    sim_valor(A, E, VA),
    sim_valor(B, E, VB),
    (   number(VA),
        number(VB)
    ->  comparar(Op, VA, VB),
        Cs1 = Cs
    ;   comparacion_prolog(Op, VA, VB, T),
        Cs1 = [T|Cs]
    ).

% comparacion_prolog(Op, A, B, T): T es la comparación Op de Mini en Prolog.
comparacion_prolog(=, A, B, A =:= B).
comparacion_prolog(<>, A, B, A =\= B).
comparacion_prolog(<, A, B, A < B).
comparacion_prolog(>, A, B, A > B).
comparacion_prolog(<=, A, B, A =< B).
comparacion_prolog(>=, A, B, A >= B).

%!  sim_valor(+Exp, +E:list, -V) is det.
%
%   V es el valor simbólico de la expresión Exp en el entorno E: un número
%   si Exp no depende de incógnitas, o una expresión simplificada de
%   Prolog. Produce un error de evaluación si divide un número por cero.
sim_valor(num(N), _, N).
sim_valor(id(X), E, V) :-
    valor(X, E, V).
sim_valor(bin(Op, A, B), E, V) :-
    sim_valor(A, E, VA),
    sim_valor(B, E, VB),
    combinar(Op, VA, VB, V).

%!  combinar(+Op, +X, +Y, -V) is det.
%
%   V es la operación Op de Mini aplicada a los valores simbólicos X e Y:
%   con operar/4 del capítulo 45 si son números, y si no, la expresión de
%   Prolog simplificada con simplificar/2 del capítulo 32.
combinar(Op, X, Y, V) :-
    (   number(X),
        number(Y)
    ->  operar(Op, X, Y, V)
    ;   operador_simbolico(Op, F),
        T =.. [F, X, Y],
        simplificar(T, V)
    ).

% operador_simbolico(Op, F): F es el functor de Prolog de la operación Op.
operador_simbolico(+, +).
operador_simbolico(-, -).
operador_simbolico(*, *).
operador_simbolico(/, //).
