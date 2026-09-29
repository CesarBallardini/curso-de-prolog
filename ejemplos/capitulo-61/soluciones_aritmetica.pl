:- encoding(utf8).

% Capítulo 61 - Solución del ejercicio 10: la aritmética compilada.
%
% El módulo aritmetica es una versión de la máquina para ejecutar/5 de
% almacen.pl. Compila el programa con compilar/2 de compilado.pl y
% reemplaza en los cuerpos cada '$predefinida'(X is E) por '$is'(X, Codigo),
% donde Codigo es E traducida a una lista de instrucciones de una máquina
% de pila, como la del capítulo 45: numero(N) apila un número, celda(C)
% apila el valor de una celda, y op(F) desapila dos valores y apila el
% resultado de la operación F, una de + - * // y mod; otra expresión
% produce un error de tipo al compilar. Al ejecutarla no hace falta reconstruir la
% expresión como un término de Prolog. Lo demás es la versión 6.
%
% solo-local: carga los módulos almacen y compilado.
%
%?- codigo(X + 2 * Y, C).
%?- comparar(listas, suma_hasta(200, _), Compilado, Aritmetica).

:- module(aritmetica, [codigo/2, comparar/4]).

:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(programas).
:- use_module(almacen,
              [ resolver_con/3,
                desreferenciar/3,
                unificar/5,
                marca/2
              ]).
:- use_module(compilado, []).

%!  compilar(+Clausulas:list, -Tabla) is det.
%
%   Como compilar/2 de compilado.pl, con las expresiones aritméticas de
%   los cuerpos compiladas.
compilar(Clausulas, Tabla) :-
    compilado:compilar(Clausulas, Tabla0),
    map_assoc(compilar_procedimiento, Tabla0, Tabla).

%!  compilar_procedimiento(+Pares0:list, -Pares:list) is det.
%
%   Pares son las cláusulas compiladas de Pares0 con la aritmética
%   compilada.
compilar_procedimiento(Pares0, Pares) :-
    maplist(compilar_par, Pares0, Pares).

%!  compilar_par(+Par0, -Par) is det.
%
%   Par es la cláusula compilada Par0 con sus llamadas a is/2 compiladas.
compilar_par(Clave-cc(K, Instrucciones, Llamadas0),
             Clave-cc(K, Instrucciones, Llamadas)) :-
    maplist(compilar_llamada, Llamadas0, Llamadas).

%!  compilar_llamada(+Llamada0, -Llamada) is det.
%
%   Llamada es '$is'(X, Codigo) si Llamada0 es '$predefinida'(X is E), y
%   Llamada0 si no.
compilar_llamada(Llamada0, Llamada) :-
    (   Llamada0 = '$predefinida'(X is E)
    ->  codigo(E, Codigo),
        Llamada = '$is'(X, Codigo)
    ;   Llamada = Llamada0
    ).

%!  codigo(+Expresion, -Codigo:list) is det.
%
%   Codigo es la Expresion, un término sin variables de Prolog con celdas,
%   números y operaciones binarias, en el orden de una máquina de pila.
codigo(Expresion, Codigo) :-
    phrase(codigo(Expresion), Codigo).

%!  codigo(+Expresion)// is det.
%
%   Las instrucciones de la Expresion, con los operandos antes de la
%   operación.
codigo(Expresion) -->
    (   { Expresion = '$v'(_) }
    ->  [celda(Expresion)]
    ;   { number(Expresion) }
    ->  [numero(Expresion)]
    ;   { compound_name_arguments(Expresion, F, [A, B]),
          memberchk(F, [+, -, *, //, mod])
        }
    ->  codigo(A),
        codigo(B),
        [op(F)]
    ;   { type_error(evaluable, Expresion) }
    ).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Ejecuta '$is'(X, Codigo); las demás metas, con el paso de
%   compilado.pl.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = '$is'(X, Codigo)
    ->  Estado0 = m(_, Pila, A0, R0, L, M),
        foldl(evaluar(A0), Codigo, [], [Valor]),
        marca(Pila, Marca),
        (   unificar(X, Valor, Marca, A0-R0, A-R)
        ->  Resultado = sigue(m(Metas, Pila, A, R, L, M))
        ;   Resultado = falla(Estado0)
        )
    ;   compilado:paso(Meta, Metas, Tabla, Estado0, Resultado)
    ).

%!  evaluar(+Almacen, +Instruccion, +Pila0:list, -Pila:list) is det.
%
%   Ejecuta una Instruccion de la máquina de pila. Una celda libre produce
%   un error de instanciación, como en Prolog.
evaluar(_, numero(N), Pila, [N|Pila]).
evaluar(Almacen, celda(C), Pila, [V|Pila]) :-
    desreferenciar(C, Almacen, V),
    (   number(V)
    ->  true
    ;   instantiation_error(V)
    ).
evaluar(_, op(F), [B, A|Pila], [V|Pila]) :-
    operar(F, A, B, V).

%!  operar(+F:atom, +A:number, +B:number, -V:number) is det.
%
%   V es el resultado de la operación F con A y B.
operar(+, A, B, V) :-
    V is A + B.
operar(-, A, B, V) :-
    V is A - B.
operar(*, A, B, V) :-
    V is A * B.
operar(//, A, B, V) :-
    V is A // B.
operar(mod, A, B, V) :-
    V is A mod B.

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   La vuelta atrás de compilado.pl.
volver(Tabla, Estado0, Resultado) :-
    compilado:volver(Tabla, Estado0, Resultado).

%!  comparar(+Nombre:atom, +Meta, -Compilado:integer,
%!           -Aritmetica:integer) is det.
%
%   Compilado y Aritmetica son las inferencias de Prolog que cuesta la
%   búsqueda completa de Meta con el programa objeto Nombre en las
%   versiones compilado y aritmetica, medidas en una segunda ejecución.
comparar(Nombre, Meta, Compilado, Aritmetica) :-
    inferencias(compilado, Nombre, Meta, Compilado),
    inferencias(aritmetica, Nombre, Meta, Aritmetica).

%!  inferencias(+Version:atom, +Nombre:atom, +Meta, -N:integer) is det.
%
%   N son las inferencias de la búsqueda completa de Meta en la Version.
inferencias(Version, Nombre, Meta, N) :-
    findall(x, resolver_con(Version, Nombre, Meta), _),
    statistics(inferences, I0),
    findall(x, resolver_con(Version, Nombre, Meta), _),
    statistics(inferences, I1),
    N is I1 - I0.
