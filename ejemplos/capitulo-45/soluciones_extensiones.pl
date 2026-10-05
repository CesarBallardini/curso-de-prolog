:- encoding(utf8).

% Capítulo 45 - Soluciones de los ejercicios 13 y 15: la máquina de
% acumulador sin temporal para un operando izquierdo conmutativo, y la
% profundidad de la pila de marcos. El ejercicio 14 se resuelve con
% registros.pl.
%
% solo-local: carga acumulador.pl, registros.pl, funciones.pl y
% optimizador.pl, de donde toma conmutativa/1, con ensure_loaded/1.
%
%?- analizar("escribir a + b * c", [escribir(E)]), generar_acumulador_conmutativo(E, C).
%?- fuente_funciones(factorial, T), correr_con_profundidad(T, S, Max).

:- ensure_loaded(acumulador).
:- ensure_loaded(registros).
:- ensure_loaded(funciones).
:- ensure_loaded(optimizador).

% Ejercicio 13

%!  generar_acumulador_conmutativo(+E, -Codigo:list) is det.
%
%   Como generar_acumulador/2, pero una operación conmutativa cuyo operando
%   izquierdo es una hoja y el derecho no lo es se calcula sin temporal:
%   primero el derecho, y después la operación con la hoja.
generar_acumulador_conmutativo(E, Codigo) :-
    phrase(codigo_conmutativo(E, 0), Codigo).

%!  codigo_conmutativo(+E, +K:integer)// is det.
%
%   El código de E, que usa las temporales desde t(K).
codigo_conmutativo(E, _) -->
    { hoja(E) },
    !,
    [cargar(E)].
codigo_conmutativo(bin(Op, A, B), K) -->
    (   { hoja(B) }
    ->  codigo_conmutativo(A, K),
        [operar(Op, B)]
    ;   { hoja(A),
          conmutativa(Op) }
    ->  codigo_conmutativo(B, K),
        [operar(Op, A)]
    ;   { K1 is K + 1 },
        codigo_conmutativo(B, K),
        [guardar(t(K))],
        codigo_conmutativo(A, K1),
        [operar(Op, t(K))]
    ).

% Ejercicio 15

%!  correr_con_profundidad(+Texto, -Salida:list(integer), -Max:integer)
%!      is semidet.
%
%   Como correr_funciones/2; Max es la mayor cantidad de marcos que hubo
%   en la pila de marcos durante la ejecución.
correr_con_profundidad(Texto, Salida, Max) :-
    compilar_funciones(Texto, Objeto),
    compound_name_arguments(Codigo, codigo, Objeto),
    empty_assoc(Memoria),
    phrase(ciclo_profundidad(Codigo, f(s(0, [], Memoria), []), 0, Max),
           Salida).

%!  ciclo_profundidad(+Codigo, +Estado, +Max0:integer, -Max:integer)//
%!      is semidet.
%
%   Como ciclo_funciones//2; Max es el mayor entre Max0 y la cantidad de
%   marcos de cada estado que sigue.
ciclo_profundidad(Codigo, f(s(PC, P, M), Marcos), Max0, Max) -->
    (   { N is PC + 1,
          arg(N, Codigo, I) }
    ->  paso_funciones(I, f(s(PC, P, M), Marcos), Estado),
        { Estado = f(_, Marcos1),
          length(Marcos1, D),
          Max1 is max(Max0, D) },
        ciclo_profundidad(Codigo, Estado, Max1, Max)
    ;   { Max = Max0 }
    ).
