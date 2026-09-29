:- encoding(utf8).

% Capítulo 45 - Versión 5: el compilador optimizador.
%
% Tres mejoras, dos sobre la sintaxis abstracta y una sobre el código:
%   - plegar_expresion/2 calcula las operaciones entre constantes con el
%     simplificador del capítulo 32 (simplificar.pl), que trabaja sobre
%     expresiones aritméticas de Prolog: a_termino/2 y de_termino/2 pasan de
%     una representación a la otra;
%   - reordenar_expresion/2 pone primero, en + y *, el operando que más pila
%     necesita, para que la máquina use menos pila;
%   - mirilla/2 recorre el código simbólico y reemplaza secuencias cortas de
%     instrucciones por otras equivalentes, hasta que ninguna se aplica.
% Las etiquetas del código simbólico son variables: una regla de la mirilla
% que las unifica en la cabeza une dos etiquetas distintas. mirilla_ingenua/2
% tiene esa regla, para mostrar lo que produce.
%
% solo-local: carga maquina.pl y simplificar.pl del capítulo 32 con
% ensure_loaded/1.
%
%?- plegar_expresion(bin(*, id(d), bin(*, num(24), num(60))), E).
%?- reordenar_expresion(bin(+, id(a), bin(+, id(b), id(c))), E).
%?- mirilla([apilar(2), apilar(1), comparar(>), saltar_si_cero(L)], C).
%?- fuente_ejemplo(cuenta, T), correr_optimizado(T, S).

:- ensure_loaded(maquina).
:- ensure_loaded('../capitulo-32/simplificar').

%!  compilar_optimizado(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa Mini de Texto, con las
%   expresiones plegadas y reordenadas y el código pasado por la mirilla.
%   Falla si Texto no es un programa Mini.
compilar_optimizado(Texto, Objeto) :-
    analizar(Texto, Programa0),
    optimizar(Programa0, Programa),
    generar(Programa, Simbolico0),
    mirilla(Simbolico0, Simbolico),
    ensamblar(Simbolico, Objeto, _).

%!  correr_optimizado(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, compilado con
%   compilar_optimizado/2 y ejecutado en la máquina.
correr_optimizado(Texto, Salida) :-
    compilar_optimizado(Texto, Objeto),
    maquina(Objeto, Salida).

%!  optimizar(+Programa0:list, -Programa:list) is det.
%
%   Programa es Programa0 con cada expresión plegada y después reordenada.
optimizar(Programa0, Programa) :-
    transformar(plegar_expresion, Programa0, Programa1),
    transformar(reordenar_expresion, Programa1, Programa).

%!  transformar(:T, +Programa0:list, -Programa:list) is det.
%
%   Programa es Programa0 con cada expresión E0 reemplazada por E, donde
%   call(T, E0, E); también las de las condiciones.
transformar(T, Ss0, Ss) :-
    maplist(transformar_sentencia(T), Ss0, Ss).

%!  transformar_sentencia(:T, +S0, -S) is det.
%
%   S es la sentencia S0 con sus expresiones transformadas por T.
transformar_sentencia(T, S0, S) :-
    sentencia_transformada(S0, T, S).

% La sentencia va primero, para que la cláusula se elija por su functor.
sentencia_transformada(asignar(X, E0), T, asignar(X, E)) :-
    call(T, E0, E).
sentencia_transformada(escribir(E0), T, escribir(E)) :-
    call(T, E0, E).
sentencia_transformada(si(C0, Si0, No0), T, si(C, Si, No)) :-
    condicion_transformada(C0, T, C),
    transformar(T, Si0, Si),
    transformar(T, No0, No).
sentencia_transformada(mientras(C0, Cuerpo0), T, mientras(C, Cuerpo)) :-
    condicion_transformada(C0, T, C),
    transformar(T, Cuerpo0, Cuerpo).

condicion_transformada(rel(Op, A0, B0), T, rel(Op, A, B)) :-
    call(T, A0, A),
    call(T, B0, B).

%!  plegar_expresion(+E0, -E) is det.
%
%   E es la expresión E0 simplificada por simplificar/2 del capítulo 32.
plegar_expresion(E0, E) :-
    a_termino(E0, T0),
    simplificar(T0, T),
    de_termino(T, E).

%!  a_termino(+E, -T) is det.
%
%   T es la expresión de Mini E escrita como expresión aritmética de
%   Prolog: los números como números y las variables como átomos.
a_termino(num(N), N).
a_termino(id(X), X).
a_termino(bin(Op, A, B), T) :-
    a_termino(A, TA),
    a_termino(B, TB),
    operador_prolog(Op, F),
    compound_name_arguments(T, F, [TA, TB]).

%!  de_termino(+T, -E) is det.
%
%   E es la expresión de Mini que corresponde a la expresión aritmética T
%   de Prolog. Sin un functor que lo diga, la clase de una hoja se averigua
%   con integer/1 y atom/1.
de_termino(T, E) :-
    (   integer(T)
    ->  E = num(T)
    ;   atom(T)
    ->  E = id(T)
    ;   compound_name_arguments(T, F, [TA, TB]),
        operador_prolog(Op, F),
        de_termino(TA, A),
        de_termino(TB, B),
        E = bin(Op, A, B)
    ).

% operador_prolog(Op, F): la operación Op de Mini se escribe en Prolog con
% el functor F.
operador_prolog(+, +).
operador_prolog(-, -).
operador_prolog(*, *).
operador_prolog(/, //).

%!  reordenar_expresion(+E0, -E) is det.
%
%   E es E0 con los operandos de cada + y * en el orden que menos pila
%   necesita: el que más necesita, primero.
reordenar_expresion(E0, E) :-
    reordenar(E0, E, _).

%!  reordenar(+E0, -E, -N:integer) is det.
%
%   E es E0 reordenada, y N es la pila que necesita la máquina para
%   evaluarla.
reordenar(num(N), num(N), 1).
reordenar(id(X), id(X), 1).
reordenar(bin(Op, A0, B0), E, N) :-
    reordenar(A0, A, NA),
    reordenar(B0, B, NB),
    (   conmutativa(Op),
        NB > NA
    ->  E = bin(Op, B, A),
        N is max(NB, NA + 1)
    ;   E = bin(Op, A, B),
        N is max(NA, NB + 1)
    ).

% conmutativa(Op): el orden de los operandos de Op no cambia el resultado.
conmutativa(+).
conmutativa(*).

%!  pila(+E, -N:integer) is det.
%
%   N es la cantidad de lugares de pila que usa la máquina para evaluar E
%   con el código de generar/2: el operando izquierdo queda en la pila
%   mientras se evalúa el derecho.
pila(num(_), 1).
pila(id(_), 1).
pila(bin(_, A, B), N) :-
    pila(A, NA),
    pila(B, NB),
    N is max(NA, NB + 1).

%!  mirilla(+Codigo0:list, -Codigo:list) is det.
%
%   Codigo es el código simbólico Codigo0 con los modismos de modismo/2
%   reemplazados mientras alguno se aplique.
mirilla(Codigo0, Codigo) :-
    mirilla(modismo, Codigo0, Codigo).

%!  mirilla_ingenua(+Codigo0:list, -Codigo:list) is det.
%
%   Como mirilla/2, con una regla más, que compara etiquetas por
%   unificación: puede unir dos etiquetas distintas.
mirilla_ingenua(Codigo0, Codigo) :-
    mirilla(modismo_ingenuo, Codigo0, Codigo).

%!  mirilla(:M, +Codigo0:list, -Codigo:list) is det.
%
%   Aplica la primera reescritura de call(M, _, _) que encuentra, contando
%   desde el principio del código, y vuelve a empezar, hasta que no queda
%   ninguna. Cada reescritura acorta el código, así que termina.
mirilla(M, Codigo0, Codigo) :-
    (   reescribir(M, Codigo0, Codigo1)
    ->  mirilla(M, Codigo1, Codigo)
    ;   Codigo = Codigo0
    ).

%!  reescribir(:M, +Codigo0:list, -Codigo:list) is nondet.
%
%   Codigo es Codigo0 con un modismo reemplazado, en cualquier posición.
reescribir(M, Codigo0, Codigo) :-
    call(M, Codigo0, Codigo).
reescribir(M, [I|Codigo0], [I|Codigo]) :-
    reescribir(M, Codigo0, Codigo).

%!  modismo(+Codigo0:list, -Codigo:list) is semidet.
%
%   Codigo0 empieza con una secuencia que se reemplaza, y Codigo es el
%   resultado. Las etiquetas se comparan con ==, salvo dos marcas seguidas,
%   que están en la misma dirección y se unifican.
modismo([apilar(X), apilar(Y), I|R], [apilar(V)|R]) :-
    constante(I, X, Y, V).
modismo([apilar(N), saltar_si_cero(L)|R], Codigo) :-
    (   N =:= 0
    ->  Codigo = [saltar(L)|R]
    ;   Codigo = R
    ).
modismo([saltar(L), I|R], [saltar(L)|R]) :-
    I \= etiqueta(_).
modismo([etiqueta(L), etiqueta(L)|R], [etiqueta(L)|R]).
modismo([saltar(L1), etiqueta(L2)|R], [etiqueta(L2)|R]) :-
    L1 == L2.

%!  modismo_ingenuo(+Codigo0:list, -Codigo:list) is semidet.
%
%   Los modismos de modismo/2 y uno más, erróneo: el salto a la instrucción
%   siguiente escrito con la misma variable en la cabeza.
modismo_ingenuo([saltar(L), etiqueta(L)|R], [etiqueta(L)|R]).
modismo_ingenuo(Codigo0, Codigo) :-
    modismo(Codigo0, Codigo).

%!  constante(+I, +X:integer, +Y:integer, -V:integer) is semidet.
%
%   V es lo que deja en la pila la instrucción I con los operandos X e Y.
%   Falla si I no opera sobre dos valores, o si divide por cero, que queda
%   para el momento de la ejecución.
constante(sumar, X, Y, V) :-
    operar(+, X, Y, V).
constante(restar, X, Y, V) :-
    operar(-, X, Y, V).
constante(multiplicar, X, Y, V) :-
    operar(*, X, Y, V).
constante(dividir, X, Y, V) :-
    Y =\= 0,
    operar(/, X, Y, V).
constante(comparar(Op), X, Y, V) :-
    (   comparar(Op, X, Y)
    ->  V = 1
    ;   V = 0
    ).
