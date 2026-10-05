:- encoding(utf8).

% Capítulo 45 - La reducción de fuerza.
%
% Reducir la fuerza de una operación es reemplazarla por otra más barata
% que da el mismo resultado. reducir_expresion/2 reescribe la sintaxis
% abstracta, de abajo hacia arriba, como el reduce/2 de Clocksin: quita
% las sumas de 0 y los productos por 1, cambia la suma de 1 por un nodo
% incrementar(E) y el producto por una potencia de dos, 2^K, por un nodo
% desplazar(E, K). La máquina recibe dos instrucciones nuevas para esos
% nodos, incrementar y desplazar(K), y una tercera, poner_cero(C), que la
% mirilla usa en lugar de apilar 0 y guardarlo. La división por una potencia
% de dos no se reduce: / trunca hacia cero, y el desplazamiento a la
% derecha redondea hacia abajo.
%
% solo-local: carga optimizador.pl con ensure_loaded/1.
%
%?- reducir_expresion(bin(+, bin(*, id(x), num(8)), num(1)), E).
%?- fuente_ejemplo(factorial, T), correr_reducido(T, S).

:- ensure_loaded(optimizador).

:- multifile
    codigo_expresion//1,
    clase/2,
    paso//3.

%!  compilar_reducido(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa Mini de Texto, optimizado
%   como en compilar_optimizado/2 y con la fuerza reducida. Falla si Texto
%   no es un programa Mini.
compilar_reducido(Texto, Objeto) :-
    analizar(Texto, Programa0),
    optimizar(Programa0, Programa1),
    transformar(reducir_expresion, Programa1, Programa),
    generar(Programa, Simbolico0),
    mirilla(modismo_fuerza, Simbolico0, Simbolico),
    ensamblar(Simbolico, Objeto, _).

%!  correr_reducido(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, compilado con
%   compilar_reducido/2 y ejecutado en la máquina.
correr_reducido(Texto, Salida) :-
    compilar_reducido(Texto, Objeto),
    maquina(Objeto, Salida).

%!  reducir_expresion(+E0, -E) is det.
%
%   E es la expresión E0 con la fuerza reducida: primero los operandos,
%   después la operación misma.
reducir_expresion(bin(Op, A0, B0), E) :-
    !,
    reducir_expresion(A0, A),
    reducir_expresion(B0, B),
    (   reduccion(Op, A, B, E1)
    ->  E = E1
    ;   E = bin(Op, A, B)
    ).
reducir_expresion(E, E).

%!  reduccion(+Op, +A, +B, -E) is semidet.
%
%   La operación Op entre A y B se escribe E, más barata. Falla si no hay
%   una reducción para ella.
reduccion(+, A, num(0), A).
reduccion(+, num(0), B, B).
reduccion(+, A, num(1), incrementar(A)).
reduccion(+, num(1), B, incrementar(B)).
reduccion(-, A, num(0), A).
reduccion(*, A, num(1), A).
reduccion(*, num(1), B, B).
reduccion(*, A, num(C), desplazar(A, K)) :-
    potencia_de_dos(C, K).
reduccion(*, num(C), B, desplazar(B, K)) :-
    potencia_de_dos(C, K).

%!  potencia_de_dos(+C:integer, -K:integer) is semidet.
%
%   C es 2^K, con K mayor que 0.
potencia_de_dos(C, K) :-
    C > 1,
    K is msb(C),
    C =:= 1 << K.

% El código de los dos nodos nuevos: el operando, y la instrucción.
codigo_expresion(incrementar(E)) -->
    codigo_expresion(E),
    [incrementar].
codigo_expresion(desplazar(E, K)) -->
    codigo_expresion(E),
    [desplazar(K)].

% Las instrucciones nuevas: dos fijas y una que nombra una celda.
clase(incrementar, fija).
clase(desplazar(_), fija).
clase(poner_cero(_), memoria).

% Lo que hacen en la máquina.
paso(incrementar, s(PC, [V|P], M), s(PC1, [V1|P], M)) -->
    { PC1 is PC + 1,
      V1 is V + 1 }.
paso(desplazar(K), s(PC, [V|P], M), s(PC1, [V1|P], M)) -->
    { PC1 is PC + 1,
      V1 is V << K }.
paso(poner_cero(C), s(PC, P, M0), s(PC1, P, M)) -->
    { PC1 is PC + 1,
      put_assoc(C, M0, 0, M) }.

%!  modismo_fuerza(+Codigo0:list, -Codigo:list) is semidet.
%
%   Los modismos de modismo/2, y uno más: apilar 0 y guardarlo en una
%   variable es poner la variable en cero.
modismo_fuerza([apilar(0), guardar(X)|R], [poner_cero(X)|R]).
modismo_fuerza(Codigo0, Codigo) :-
    modismo(Codigo0, Codigo).
