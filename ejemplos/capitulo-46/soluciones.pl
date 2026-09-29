:- encoding(utf8).

% Capítulo 46 - Soluciones de los ejercicios 3 a 12.
%
% Extensiones del programa de métodos numéricos: el ciclo sin límite y con
% tolerancia relativa, la falsa posición, la derivada de sin, cos, exp y
% log, Newton para raíces múltiples y para sistemas de dos ecuaciones,
% Jacobi, la diagonal dominante, el residuo y la búsqueda de varias raíces.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- biseccion_relativa(x ^ 2 = 2.0e12, x, 0-2.0e6, 1.0e-12, Xs).
%?- newton_ampliado(x = cos(x), x, 1, 1.0e-12, Xs).

:- ensure_loaded(metodos).

:- meta_predicate
    iterar_sin_limite(4, +, +, -),
    iterar_relativa(4, +, +, -),
    iterar_relativa(4, +, +, +, -).

%!  iterar_sin_limite(:Paso, +Tol:float, +Estado0,
%!                    -Aproximaciones:list) is semidet.
%
%   Como iterar/4, sin maximo_de_pasos/1: si la tolerancia no se alcanza,
%   no termina.
iterar_sin_limite(Paso, Tol, Estado0, [X|Xs]) :-
    call(Paso, Estado0, Estado, X, Cambio),
    (   Cambio =< Tol
    ->  Xs = []
    ;   iterar_sin_limite(Paso, Tol, Estado, Xs)
    ).

%!  iterar_relativa(:Paso, +Tol:float, +Estado0,
%!                  -Aproximaciones:list) is semidet.
%
%   Como iterar/4, con la tolerancia relativa: se detiene cuando el cambio
%   es menor o igual que Tol por el mayor entre 1 y el valor absoluto de la
%   aproximación.
iterar_relativa(Paso, Tol, Estado0, Aproximaciones) :-
    maximo_de_pasos(Maximo),
    iterar_relativa(Paso, Tol, Maximo, Estado0, Aproximaciones).

%!  iterar_relativa(:Paso, +Tol:float, +Restantes:integer, +Estado0,
%!                  -Aproximaciones:list) is semidet.
%
%   Como iterar_relativa/4, con a lo sumo Restantes pasos.
iterar_relativa(Paso, Tol, Restantes, Estado0, [X|Xs]) :-
    Restantes > 0,
    call(Paso, Estado0, Estado, X, Cambio),
    (   Cambio =< Tol * max(1, abs(X))
    ->  Xs = []
    ;   Restantes1 is Restantes - 1,
        iterar_relativa(Paso, Tol, Restantes1, Estado, Xs)
    ).

%!  biseccion_relativa(+Ecuacion, +X:atom, +Intervalo, +Tol:float,
%!                     -Aproximaciones:list(float)) is semidet.
%
%   Como biseccion/5, con la tolerancia relativa de iterar_relativa/4.
biseccion_relativa(Ecuacion, X, A0-B0, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(A0),
    B is float(B0),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    (   A < B,
        FA * FB =< 0
    ->  iterar_relativa(paso_biseccion(F, X), Tol, intervalo(A, FA, B), Xs)
    ;   domain_error(intervalo_con_cambio_de_signo, A0-B0)
    ).

%!  falsa_posicion(+Ecuacion, +X:atom, +Intervalo, +Tol:float,
%!                 -Aproximaciones:list(float)) is semidet.
%
%   Aproximaciones son los puntos donde la secante por los extremos del
%   intervalo corta el eje, hasta que dos seguidos difieren en Tol o menos.
%   Intervalo es A-B con A < B y un cambio de signo, o se produce un error
%   de dominio.
falsa_posicion(Ecuacion, X, A0-B0, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(A0),
    B is float(B0),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    (   A < B,
        FA * FB =< 0
    ->  iterar(paso_falsa_posicion(F, X), Tol, falsa(A, FA, B, FB, A), Xs)
    ;   domain_error(intervalo_con_cambio_de_signo, A0-B0)
    ).

%!  paso_falsa_posicion(+F, +X:atom, +Estado0, -Estado, -C:float,
%!                      -Cambio:float) is semidet.
%
%   C es el punto donde la secante por los extremos de Estado0,
%   falsa(A, FA, B, FB, Anterior), corta el eje; Estado es la parte del
%   intervalo con cambio de signo, y Cambio la distancia de C a la
%   aproximación Anterior. Falla si FA y FB son iguales.
paso_falsa_posicion(F, X, falsa(A, FA, B, FB, Anterior), Estado, C,
                    Cambio) :-
    FA =\= FB,
    C is B - FB * (B - A) / (FB - FA),
    valor_en(F, X, C, FC),
    Cambio is abs(C - Anterior),
    (   FA * FC =< 0
    ->  Estado = falsa(A, FA, C, FC, C)
    ;   Estado = falsa(C, FC, B, FB, C)
    ).

%!  derivar_ampliado(+E, +X:atom, -D) is det.
%
%   D es la derivada de la expresión cerrada E respecto de X, simplificada.
%   E usa +, -, *, ^ con exponente numérico, sin, cos, exp y log.
derivar_ampliado(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada_ampliada(E, X, D0),
    simplificar(D0, D).

%!  derivada_ampliada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar, con la regla de la
%   cadena para las cuatro funciones. Produce un error de dominio con otra
%   operación.
derivada_ampliada(E, X, D) :-
    (   E == X
    ->  D = 1
    ;   atomic(E)
    ->  D = 0
    ;   E = U + V
    ->  D = DU + DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U - V
    ->  D = DU - DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada_ampliada(U, X, DU)
    ;   E = sin(U)
    ->  D = cos(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = cos(U)
    ->  D = -1 * sin(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = exp(U)
    ->  D = exp(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = log(U)
    ->  D = DU / U,
        derivada_ampliada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).

%!  newton_ampliado(+Ecuacion, +X:atom, +X0:number, +Tol:float,
%!                  -Aproximaciones:list(float)) is semidet.
%
%   Como newton/5, con la derivada de derivar_ampliado/3.
newton_ampliado(Ecuacion, X, X0, Tol, Xs) :-
    funcion(Ecuacion, F),
    derivar_ampliado(F, X, DF),
    A is float(X0),
    iterar(paso_newton(F, DF, X), Tol, A, Xs).

%!  newton_multiple(+Ecuacion, +X:atom, +M:integer, +X0:number,
%!                  +Tol:float, -Aproximaciones:list(float)) is semidet.
%
%   Como newton/5, con el paso multiplicado por M, la multiplicidad de la
%   raíz buscada.
newton_multiple(Ecuacion, X, M, X0, Tol, Xs) :-
    funcion(Ecuacion, F),
    derivar(F, X, DF),
    A is float(X0),
    iterar(paso_newton_multiple(F, DF, X, M), Tol, A, Xs).

%!  paso_newton_multiple(+F, +DF, +X:atom, +M:integer, +X0:float,
%!                       -X1:float, -X1:float, -Cambio:float) is semidet.
%
%   X1 es X0 menos M veces el cociente entre F y su derivada DF en X0.
%   Falla si la derivada vale 0 en X0.
paso_newton_multiple(F, DF, X, M, X0, X1, X1, Cambio) :-
    valor_en(F, X, X0, F0),
    valor_en(DF, X, X0, D0),
    D0 =\= 0,
    X1 is X0 - M * F0 / D0,
    Cambio is abs(X1 - X0).

%!  jacobi(+Filas:list(list(number)), +Bs:list(number),
%!         +X0s:list(number), +Tol:float,
%!         -Aproximaciones:list(list(float))) is semidet.
%
%   Como gauss_seidel/5, pero cada barrido usa solo los valores del
%   barrido anterior.
jacobi(Filas, Bs, X0s, Tol, Aproximaciones) :-
    iterar(paso_jacobi(Filas, Bs), Tol, X0s, Aproximaciones).

%!  paso_jacobi(+Filas, +Bs, +X0s, -Xs, -Xs, -Cambio:float) is semidet.
%
%   Xs es el resultado de un barrido de Jacobi desde X0s; Cambio es el
%   mayor cambio de una componente.
paso_jacobi(Filas, Bs, X0s, Xs, Xs, Cambio) :-
    barrido_jacobi(Filas, Bs, [], X0s, Xs),
    foldl(mayor_diferencia, X0s, Xs, 0.0, Cambio).

%!  barrido_jacobi(+Filas, +Bs, +Anteriores:list(number),
%!                 +Viejos:list(number), -Xs:list(float)) is semidet.
%
%   Xs son los valores nuevos de las incógnitas de Filas. Anteriores y
%   Viejos son los valores del barrido anterior de las incógnitas que
%   preceden a la fila actual y de las que siguen, ella incluida. Falla si
%   un coeficiente de la diagonal es 0.
barrido_jacobi([], [], _, [], []).
barrido_jacobi([Fila|Filas], [B|Bs], Anteriores, [V|Viejos], [X|Xs]) :-
    length(Anteriores, K),
    length(Izquierda, K),
    append(Izquierda, [Diagonal|Derecha], Fila),
    Diagonal =\= 0,
    producto_escalar(Izquierda, Anteriores, P1),
    producto_escalar(Derecha, Viejos, P2),
    X is (B - P1 - P2) / Diagonal,
    append(Anteriores, [V], Anteriores1),
    barrido_jacobi(Filas, Bs, Anteriores1, Viejos, Xs).

%!  diagonal_dominante(+Filas:list(list(number))) is semidet.
%
%   En cada fila de Filas, el valor absoluto del coeficiente de la diagonal
%   supera la suma de los valores absolutos de los demás.
diagonal_dominante(Filas) :-
    diagonal_dominante(Filas, 0).

%!  diagonal_dominante(+Filas:list(list(number)), +K:integer) is semidet.
%
%   Como diagonal_dominante/1, con la diagonal de la primera fila de Filas
%   en la posición K, contada desde 0.
diagonal_dominante([], _).
diagonal_dominante([Fila|Filas], K) :-
    length(Izquierda, K),
    append(Izquierda, [Diagonal|Derecha], Fila),
    foldl(sumar_absoluto, Izquierda, 0, S1),
    foldl(sumar_absoluto, Derecha, S1, S),
    abs(Diagonal) > S,
    K1 is K + 1,
    diagonal_dominante(Filas, K1).

%!  sumar_absoluto(+A:number, +S0:number, -S:number) is det.
%
%   S es S0 más el valor absoluto de A.
sumar_absoluto(A, S0, S) :-
    S is S0 + abs(A).

%!  ordenar_filas(+Filas:list(list(number)), +Bs:list(number),
%!                -Filas1:list(list(number)), -Bs1:list(number))
%!      is semidet.
%
%   Filas1 y Bs1 son las mismas ecuaciones en el primer orden, entre las
%   permutaciones, que tiene la diagonal estrictamente dominante. Falla si
%   ningún orden la tiene.
ordenar_filas(Filas, Bs, Filas1, Bs1) :-
    pairs_keys_values(Pares, Filas, Bs),
    once(( permutation(Pares, Pares1),
           pairs_keys_values(Pares1, Filas2, _),
           diagonal_dominante(Filas2) )),
    pairs_keys_values(Pares1, Filas1, Bs1).

%!  residuo(+Filas:list(list(number)), +Bs:list(number),
%!          +Xs:list(number), -R:float) is det.
%
%   R es el mayor valor absoluto de las componentes de A·x - b.
residuo(Filas, Bs, Xs, R) :-
    foldl(residuo_fila(Xs), Filas, Bs, 0.0, R).

%!  residuo_fila(+Xs:list(number), +Fila:list(number), +B:number,
%!               +R0:float, -R:float) is det.
%
%   R es el mayor entre R0 y el valor absoluto de Fila·Xs - B.
residuo_fila(Xs, Fila, B, R0, R) :-
    producto_escalar(Fila, Xs, P),
    R is max(R0, abs(P - B)).

%!  newton_sistema(+Ecuaciones:list, +Incognitas, +Inicio, -Raiz)
%!      is semidet.
%
%   Raiz, un par X-Y, es una solución de las dos Ecuaciones en las
%   Incognitas, un par de átomos, buscada desde Inicio, otro par, con una
%   tolerancia de 1.0e-12. Falla si el jacobiano se anula o si el método no
%   converge.
newton_sistema([E1, E2], X-Y, X0-Y0, Raiz) :-
    funcion(E1, F1),
    funcion(E2, F2),
    derivar(F1, X, A),
    derivar(F1, Y, B),
    derivar(F2, X, C),
    derivar(F2, Y, D),
    Punto is float(X0),
    Punto2 is float(Y0),
    iterar(paso_newton_sistema(X-Y, F1-F2, A-B, C-D), 1.0e-12,
           Punto-Punto2, Aproximaciones),
    last(Aproximaciones, Raiz).

%!  paso_newton_sistema(+Incognitas, +Fs, +Fila1, +Fila2, +P0, -P, -P,
%!                      -Cambio:float) is semidet.
%
%   P es el punto que sigue a P0 en el método de Newton para las dos
%   funciones Fs, F1-F2, cuyas derivadas parciales forman las filas del
%   jacobiano Fila1 y Fila2. El sistema lineal se resuelve por la regla de
%   Cramer. Falla si el determinante es 0.
paso_newton_sistema(X-Y, F1-F2, A-B, C-D, X0-Y0, X1-Y1, X1-Y1, Cambio) :-
    Valores = [X-X0, Y-Y0],
    maplist(valor_en_punto(Valores), [F1, F2, A, B, C, D],
            [V1, V2, VA, VB, VC, VD]),
    Det is VA * VD - VB * VC,
    Det =\= 0,
    DX is (VB * V2 - VD * V1) / Det,
    DY is (VC * V1 - VA * V2) / Det,
    X1 is X0 + DX,
    Y1 is Y0 + DY,
    Cambio is max(abs(DX), abs(DY)).

%!  valor_en_punto(+Valores:list(pair), +E, -V:float) is det.
%
%   V es el valor de E con las incógnitas de Valores.
valor_en_punto(Valores, E, V) :-
    evaluar(E, Valores, V0),
    V is float(V0).

%!  raices(+Ecuacion, +X:atom, +Intervalo, +N:integer,
%!         -Raices:list(float)) is det.
%
%   Raices son las que da la bisección en cada uno de los N intervalos
%   iguales en que se parte Intervalo, A-B, que tiene cambio de signo.
raices(Ecuacion, X, A-B, N, Raices) :-
    must_be(positive_integer, N),
    Ancho is (B - A) / N,
    N1 is N - 1,
    numlist(0, N1, Is),
    convlist(raiz_en_tramo(Ecuacion, X, A, Ancho), Is, Raices).

%!  raiz_en_tramo(+Ecuacion, +X:atom, +A:number, +Ancho:number,
%!                +I:integer, -R:float) is semidet.
%
%   R es la raíz que da la bisección en el tramo I, de A + I·Ancho a
%   A + (I + 1)·Ancho. Falla si el tramo no tiene cambio de signo.
raiz_en_tramo(Ecuacion, X, A, Ancho, I, R) :-
    Desde is A + I * Ancho,
    Hasta is Desde + Ancho,
    funcion(Ecuacion, F),
    valor_en(F, X, Desde, FD),
    valor_en(F, X, Hasta, FH),
    FD * FH =< 0,
    biseccion(Ecuacion, X, Desde-Hasta, R).
