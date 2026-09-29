:- encoding(utf8).

% Capítulo 47 - Soluciones de los ejercicios 6 a 10: las matrices.
%
% solo-local: carga inversa.pl y matriz_simbolica.pl, y SWISH no carga
% otros archivos.
%
%?- hilbert(4, racional, H), determinante(H, D).
%?- resolver([[2, 1], [1, 3]], [3, 5], X).
%?- traza([[1, 2], [3, 4]], T).
%?- potencia([[1, 1], [1, 0]], 10, P).
%?- rotacion(z, t, A), rotacion(z, f, B), producto_con_signos(A, B, P).

:- ensure_loaded(inversa).
:- ensure_loaded(matriz_simbolica).

% Ejercicio 6

%!  determinante(+A:list(list), -D:number) is det.
%
%   D es el determinante de la matriz cuadrada A, exacto si sus elementos
%   son enteros o racionales. Produce un error de dominio si A no es
%   cuadrada.
determinante(A, D) :-
    dimensiones(A, N, C),
    (   N =:= C
    ->  true
    ;   domain_error(matriz_cuadrada, A)
    ),
    det(A, D).

%!  det(+A:list(list), -D:number) is det.
%
%   D es el determinante de la matriz cuadrada A. Elige como pivote la
%   primera fila con el primer elemento distinto de 0; sacarla de la
%   posición I y ponerla primera son I intercambios de filas vecinas, y
%   cada uno cambia el signo. Sin pivote, la matriz es singular y D es 0.
det([], 1).
det([F|Fs], D) :-
    (   nth0(I, [F|Fs], P, Resto),
        P = [X|_],
        X =\= 0
    ->  maplist(reducir_fila(P), Resto, Menor),
        det(Menor, D0),
        D is (-1) ^ I * X * D0
    ;   D = 0
    ).

%!  reducir_fila(+Pivote:list, +Fila:list, -Reducida:list) is det.
%
%   Reducida es Fila menos el múltiplo de Pivote que anula su primer
%   elemento, sin ese primer elemento.
reducir_fila([X|Xs], [Y|Ys], Reducida) :-
    dividir_por(X, Y, F),
    maplist(restar_multiplo(F), Xs, Ys, Reducida).

% Ejercicio 7

%!  resolver(+A:list(list), +B:list(number), -X:list(number)) is semidet.
%
%   X es la solución del sistema lineal A * X = B, con A cuadrada. Falla si
%   A es singular.
resolver(A, B, X) :-
    maplist([Fila, Bi, Ampliada]>>append(Fila, [Bi], Ampliada),
            A, B, Filas),
    gauss_jordan(Filas, [], Reducida),
    maplist(last, Reducida, X).

% Ejercicio 8

%!  suma(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es la suma, elemento por elemento, de las matrices A y B, de las
%   mismas dimensiones.
suma(A, B, C) :-
    maplist(maplist([X, Y, Z]>>(Z is X + Y)), A, B, C).

%!  por_escalar(+K:number, +A:list(list), -B:list(list)) is det.
%
%   B es la matriz A con cada elemento multiplicado por K.
por_escalar(K, A, B) :-
    maplist(maplist([X, Y]>>(Y is K * X)), A, B).

%!  traza(+A:list(list), -T:number) is det.
%
%   T es la suma de los elementos de la diagonal de la matriz cuadrada A.
traza(A, T) :-
    findall(X, ( nth1(I, A, Fila), nth1(I, Fila, X) ), Diagonal),
    sum_list(Diagonal, T).

% Ejercicio 9

%!  potencia(+M:list(list), +K:integer, -P:list(list)) is det.
%
%   P es la matriz cuadrada M elevada al natural K, calculada por
%   cuadrados sucesivos.
potencia(M, K, P) :-
    potencia(M, K, P, _).

%!  potencia(+M:list(list), +K:integer, -P:list(list),
%!           -Productos:integer) is det.
%
%   P es M elevada a K, y el cálculo hace Productos productos de matrices.
potencia(M, 0, I, 0) :-
    !,
    length(M, N),
    identidad(N, I).
potencia(M, 1, M, 0) :-
    !.
potencia(M, K, P, Productos) :-
    K2 is K // 2,
    potencia(M, K2, Q, Productos0),
    producto(Q, Q, Q2),
    (   K mod 2 =:= 0
    ->  P = Q2,
        Productos is Productos0 + 1
    ;   producto(M, Q2, P),
        Productos is Productos0 + 2
    ).

%!  fibonacci(+N:integer, -F:integer) is det.
%
%   F es el número de Fibonacci N: el elemento de la primera fila y la
%   segunda columna de [[1, 1], [1, 0]] elevada a N.
fibonacci(N, F) :-
    potencia([[1, 1], [1, 0]], N, [[_, F]|_]).

% Ejercicio 10

%!  simplificar_signos(+E0, -E) is det.
%
%   E es la expresión cerrada E0 sin el menos unario en los productos, ni
%   una suma o una resta de un opuesto. Produce un error de instanciación
%   si E0 tiene variables.
simplificar_signos(E0, E) :-
    must_be(ground, E0),
    signos(E0, E).

%!  signos(+E0, -E) is det.
%
%   E es E0 con las reglas de regla_signo/2 aplicadas de abajo hacia
%   arriba, como simp/2 del capítulo 32.
signos(E0, E) :-
    (   compound(E0)
    ->  mapargs(signos, E0, E1)
    ;   E1 = E0
    ),
    (   regla_signo(E1, E2)
    ->  signos(E2, E)
    ;   E = E1
    ).

%!  regla_signo(+E0, -E) is nondet.
%
%   E es el resultado de reescribir la raíz de E0 con una regla de signos:
%   una respuesta por cada regla que se aplica. signos/2 usa la primera.
regla_signo(-(-A), A).
regla_signo(-A * -B, A * B).
regla_signo(A * -B, -(A * B)).
regla_signo(-A * B, -(A * B)).
regla_signo(A + -B, A - B).
regla_signo(A - -B, A + B).

%!  producto_con_signos(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es el producto simbólico de A y B, simplificado y sin el menos
%   unario en los productos.
producto_con_signos(A, B, C) :-
    producto_simbolico(A, B, C0),
    maplist(maplist(simplificar_signos), C0, C).
