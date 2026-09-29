:- encoding(utf8).

% Capítulo 45 - Versión 4: la máquina de pila.
%
% maquina/2 ejecuta el código objeto de generador.pl. El estado de la
% máquina es s(PC, Pila, Memoria): la dirección de la instrucción que
% sigue, la pila de valores, con el tope primero, y la memoria, un árbol
% AVL de library(assoc) que asocia cada celda con su valor; una celda que
% nunca se escribió vale 0. Cada instrucción relaciona un estado con el
% siguiente, y lo que escribe la máquina es, como en el intérprete, la
% lista que describe la gramática. El código se guarda en un término
% codigo(I0, I1, ...) para leer la instrucción de una dirección con arg/3,
% sin recorrer una lista. Las comparaciones y las operaciones son las del
% intérprete: comparar/3 y operar/4.
%
% solo-local: carga generador.pl e interprete.pl con ensure_loaded/1.
%
%?- maquina([apilar(2), apilar(3), sumar, escribir], S).
%?- correr("x := 6; y := x * 7; escribir y", S).
%?- fuente_ejemplo(mcd, T), correr(T, S), ejecutar(T, S).

:- ensure_loaded(generador).
:- ensure_loaded(interprete).
:- use_module(library(assoc)).

%!  correr(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, compilado y
%   ejecutado en la máquina. Falla si Texto no es un programa Mini.
correr(Texto, Salida) :-
    compilar(Texto, Objeto),
    maquina(Objeto, Salida).

%!  maquina(+Objeto:list, -Salida:list(integer)) is det.
%
%   Salida es lo que escribe el código objeto Objeto, ejecutado desde la
%   dirección 0 con la pila vacía y la memoria en 0, hasta que la dirección
%   siguiente queda fuera del código.
maquina(Objeto, Salida) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    empty_assoc(Memoria),
    phrase(ciclo(Codigo, s(0, [], Memoria)), Salida).

%!  ciclo(+Codigo, +Estado)// is det.
%
%   La salida de la máquina desde Estado: si la dirección de Estado tiene
%   una instrucción, la ejecuta y sigue; si no, termina.
ciclo(Codigo, s(PC, Pila, Memoria)) -->
    (   { N is PC + 1,
          arg(N, Codigo, I) }
    ->  paso(I, s(PC, Pila, Memoria), Estado),
        ciclo(Codigo, Estado)
    ;   []
    ).

%!  paso(+I, +Estado0, -Estado)// is det.
%
%   Ejecutar la instrucción I lleva la máquina de Estado0 a Estado; la
%   lista es lo que escribe, vacía salvo para escribir.
paso(apilar(N), s(PC, P, M), s(PC1, [N|P], M)) -->
    { PC1 is PC + 1 }.
paso(cargar(C), s(PC, P, M), s(PC1, [V|P], M)) -->
    { PC1 is PC + 1,
      celda(C, M, V) }.
paso(guardar(C), s(PC, [V|P], M0), s(PC1, P, M)) -->
    { PC1 is PC + 1,
      put_assoc(C, M0, V, M) }.
paso(sumar, S0, S) -->
    { operacion(+, S0, S) }.
paso(restar, S0, S) -->
    { operacion(-, S0, S) }.
paso(multiplicar, S0, S) -->
    { operacion(*, S0, S) }.
paso(dividir, S0, S) -->
    { operacion(/, S0, S) }.
paso(comparar(Op), s(PC, [Y, X|P], M), s(PC1, [V|P], M)) -->
    { PC1 is PC + 1,
      (   comparar(Op, X, Y)
      ->  V = 1
      ;   V = 0
      ) }.
paso(escribir, s(PC, [V|P], M), s(PC1, P, M)) -->
    [V],
    { PC1 is PC + 1 }.
paso(saltar(D), s(_, P, M), s(D, P, M)) -->
    [].
paso(saltar_si_cero(D), s(PC, [V|P], M), s(PC1, P, M)) -->
    {   V =:= 0
    ->  PC1 = D
    ;   PC1 is PC + 1
    }.

%!  operacion(+Op, +Estado0, -Estado) is det.
%
%   Estado es Estado0 con los dos valores del tope de la pila reemplazados
%   por el resultado de la operación Op: el de más abajo es el operando
%   izquierdo.
operacion(Op, s(PC, [Y, X|P], M), s(PC1, [V|P], M)) :-
    operar(Op, X, Y, V),
    PC1 is PC + 1.

%!  celda(+C:integer, +Memoria, -V:integer) is det.
%
%   V es el valor de la celda C en Memoria, o 0 si nunca se escribió.
celda(C, Memoria, V) :-
    (   get_assoc(C, Memoria, V0)
    ->  V = V0
    ;   V = 0
    ).
