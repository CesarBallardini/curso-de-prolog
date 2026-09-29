:- encoding(utf8).

% Capítulo 50 - Soluciones de los ejercicios.
%
% solo-local: carga fft.pl, y SWISH no carga otros archivos.
%
%?- alternar_mal([0, 1, 2, 3], P, I).
%?- fft_grafo(8, Ns, _), productos_por(Ns, 2, C).
%?- fft_grafo(4, Ns, Ss), maplist(profundidad(Ns), Ss, Ps).
%?- fft_numerica([1, 2, 3, 4], Xs), fft_inversa(Xs, As).
%?- producto_polinomios([1, 2, 3], [4, 5], R).

:- ensure_loaded(fft).

% Ejercicio 2

%!  alternar_mal(?Lista:list, ?Pares:list, ?Impares:list) is semidet.
%
%   La versión con error del ejercicio 2: pretende ser alternar/3, pero la
%   llamada recursiva intercambia las dos listas.
alternar_mal([], [], []).
alternar_mal([X, Y|T], [X|Xs], [Y|Ys]) :-
    alternar_mal(T, Ys, Xs).

% Ejercicio 4

%!  productos_por(+Nodos:list, +K:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de productos del grafo Nodos en los que uno de
%   los operandos es la hoja w(K).
productos_por(Nodos, K, Cantidad) :-
    memberchk(nodo(Raiz, w(K)), Nodos),
    !,
    aggregate_all(count,
                  ( member(nodo(_, op(*, I, J)), Nodos),
                    ( I == Raiz -> true ; J == Raiz )
                  ),
                  Cantidad).
productos_por(_, _, 0).

%!  productos_no_triviales(+N:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de productos de la mariposa de orden N que no
%   son por w(N/4), es decir, por la unidad imaginaria. N es una potencia
%   de 2.
productos_no_triviales(N, Cantidad) :-
    fft_grafo(N, Nodos, _),
    contar_nodos(Nodos, _, _, P),
    K is N // 4,
    productos_por(Nodos, K, Pi),
    Cantidad is P - Pi.

% Ejercicio 5

%!  profundidad(+Nodos:list, +Id:integer, -P:integer) is semidet.
%
%   P es la cantidad de operaciones del camino más largo desde una hoja
%   del grafo Nodos hasta el nodo Id; 0 si Id es una hoja. Falla si Id no
%   es un nodo del grafo.
profundidad(Nodos, Id, P) :-
    memberchk(nodo(Id, T), Nodos),
    (   T = op(_, I, J)
    ->  profundidad(Nodos, I, PI),
        profundidad(Nodos, J, PJ),
        P is max(PI, PJ) + 1
    ;   P = 0
    ).

%!  profundidad_maxima(+Nodos:list, +Salidas:list, -P:integer) is det.
%
%   P es la mayor profundidad de los nodos Salidas del grafo Nodos.
profundidad_maxima(Nodos, Salidas, P) :-
    maplist(profundidad(Nodos), Salidas, Ps),
    max_list(Ps, P).

% Ejercicio 8

%!  presente(+E, ?Dic, -Id) is semidet.
%
%   La clave cerrada E está en el diccionario incompleto Dic con el valor
%   Id. A diferencia de buscar/3, no agrega nada: falla al llegar al final
%   abierto.
presente(E, Dic, Id) :-
    nonvar(Dic),
    Dic = [E0-V|Resto],
    (   E0 == E
    ->  Id = V
    ;   presente(E, Resto, Id)
    ).

%!  grafo_rapido(+Es:list, -Nodos:list, -Salidas:list(integer)) is det.
%
%   La misma relación que grafo/3, sin volver a recorrer una subexpresión
%   que ya está en el diccionario.
grafo_rapido(Es, Nodos, Salidas) :-
    must_be(ground, Es),
    maplist(agregar_rapido(Dic), Es, Salidas),
    numerar(Dic, 1),
    nodos(Dic, Dic, Nodos).

%!  agregar_rapido(?Dic, +E, -Id) is det.
%
%   Como agregar/3, pero si E ya está en Dic no examina sus hijos, que
%   también están.
agregar_rapido(Dic, E, Id) :-
    (   presente(E, Dic, Id0)
    ->  Id = Id0
    ;   (   operacion(E, _, A, B)
        ->  agregar_rapido(Dic, A, _),
            agregar_rapido(Dic, B, _)
        ;   true
        ),
        buscar(E, Dic, Id)
    ).

% Ejercicio 9

%!  valor_exacto(+N:integer, +Coefs:list, +E, -V) is det.
%
%   Como valor/4, con N igual a 1, 2 o 4 y las raíces exactas: V es un
%   complejo de componentes enteras si los coeficientes son enteros.
valor_exacto(_, _, X, c(X, 0)) :-
    number(X),
    !.
valor_exacto(_, Coefs, a(J), V) :-
    !,
    nth0(J, Coefs, C),
    complejo(C, V).
valor_exacto(N, _, w(K), V) :-
    !,
    raiz_exacta(N, K, V).
valor_exacto(N, Coefs, E, V) :-
    E =.. [Op, A, B],
    valor_exacto(N, Coefs, A, VA),
    valor_exacto(N, Coefs, B, VB),
    operar(Op, VA, VB, V).

%!  raiz_exacta(+N:integer, +K:integer, -V) is det.
%
%   V es la potencia K de la raíz N-ésima de la unidad, exacta, con N igual
%   a 1, 2 o 4. Produce un error de dominio para otro N.
raiz_exacta(N, K, V) :-
    (   memberchk(N, [1, 2, 4])
    ->  true
    ;   domain_error(orden_exacto, N)
    ),
    Q is (K * (4 // N)) mod 4,
    nth0(Q, [c(1, 0), c(0, 1), c(-1, 0), c(0, -1)], V).

%!  valor_grafo_exacto(+N:integer, +Coefs:list, +Nodos:list,
%!                     +Salidas:list, -Vs:list) is det.
%
%   Como valor_grafo/5, con las hojas evaluadas por valor_exacto/4.
valor_grafo_exacto(N, Coefs, Nodos, Salidas, Vs) :-
    empty_assoc(T0),
    foldl(valor_nodo_exacto(N, Coefs), Nodos, T0, T),
    maplist([Id, V]>>get_assoc(Id, T, V), Salidas, Vs).

%!  valor_nodo_exacto(+N, +Coefs, +Nodo, +T0, -T) is det.
%
%   Como valor_nodo/5, con las hojas evaluadas por valor_exacto/4.
valor_nodo_exacto(N, Coefs, nodo(Id, T), T0, T1) :-
    (   T = op(Op, I, J)
    ->  get_assoc(I, T0, VI),
        get_assoc(J, T0, VJ),
        operar(Op, VI, VJ, V)
    ;   valor_exacto(N, Coefs, T, V)
    ),
    put_assoc(Id, T0, V, T1).

% Ejercicio 10

%!  fft_inversa_grafo(+N:integer, -Nodos:list, -Salidas:list) is det.
%
%   Nodos es el grafo de la transformada inversa de orden N sin la
%   división por N: la salida J es el polinomio de las entradas evaluado
%   en w(-J), es decir, en w((N - J) mod N). N es una potencia de 2.
fft_inversa_grafo(N, Nodos, Salidas) :-
    potencia_de_dos(N),
    N1 is N - 1,
    numlist(0, N1, Is),
    maplist(salida_inversa(Is, N), Is, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, Salidas).

%!  salida_inversa(+Is:list(integer), +N:integer, +J:integer, -E) is det.
%
%   E es la expresión de la salida J de la transformada inversa de orden N.
salida_inversa(Is, N, J, E) :-
    K is (N - J) mod N,
    evaluar(Is, K, N, E).

%!  fft_inversa(+Xs:list, -As:list) is det.
%
%   As es la transformada inversa de Xs, una lista de números o complejos
%   c(Re, Im) de longitud potencia de 2: el grafo de fft_inversa_grafo/3
%   evaluado con Xs, y cada valor dividido por la longitud.
fft_inversa(Xs, As) :-
    length(Xs, N),
    fft_inversa_grafo(N, Nodos, Salidas),
    valor_grafo(N, Xs, Nodos, Salidas, Vs),
    maplist(dividir(N), Vs, As).

%!  dividir(+N:number, +V, -W) is det.
%
%   W es el complejo V dividido por N.
dividir(N, c(R0, I0), c(R, I)) :-
    R is R0 / N,
    I is I0 / N.

% Ejercicio 11

%!  producto_polinomios(+P:list(integer), +Q:list(integer),
%!                      -R:list(integer)) is det.
%
%   R es la lista de coeficientes del producto de los polinomios de
%   coeficientes P y Q, calculado con la transformada rápida: las dos
%   transformadas, su producto salida por salida y la inversa, con la
%   parte real redondeada. P y Q no son vacías.
producto_polinomios(P, Q, R) :-
    length(P, LP),
    length(Q, LQ),
    L is LP + LQ - 1,
    potencia_mayor(L, 1, N),
    completar(P, N, P1),
    completar(Q, N, Q1),
    fft_numerica(P1, VP),
    fft_numerica(Q1, VQ),
    maplist(operar(*), VP, VQ, VR),
    fft_inversa(VR, As),
    length(R0, L),
    append(R0, _, As),
    maplist([c(Re, _), X]>>(X is round(Re)), R0, R).

%!  potencia_mayor(+L:integer, +N0:integer, -N:integer) is det.
%
%   N es la menor potencia de 2 que es al menos L y al menos N0, con N0 una
%   potencia de 2.
potencia_mayor(L, N0, N) :-
    (   N0 >= L
    ->  N = N0
    ;   N1 is 2 * N0,
        potencia_mayor(L, N1, N)
    ).

%!  completar(+P:list, +N:integer, -P1:list) is det.
%
%   P1 es P seguida de ceros hasta tener N elementos; P no tiene más de N.
completar(P, N, P1) :-
    length(P, LP),
    K is N - LP,
    length(Ceros, K),
    maplist(=(0), Ceros),
    append(P, Ceros, P1).

% Ejercicio 3

% costo/4, declarada en tdf.pl: el grafo de las expresiones de la matriz,
% simplificadas, sin la recursión sobre las mitades.
costo(matriz_grafo, N, S, P) :-
    tdf_ingenua(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, _),
    contar_nodos(Nodos, _, S, P).

% Ejercicio 5

%!  profundidad_version(+Version, +N:integer, -P:integer) is det.
%
%   P es la mayor profundidad de las salidas del grafo de orden N de la
%   Version: mariposa, o matriz_grafo, el del ejercicio 3.
profundidad_version(mariposa, N, P) :-
    fft_grafo(N, Nodos, Salidas),
    profundidad_maxima(Nodos, Salidas, P).
profundidad_version(matriz_grafo, N, P) :-
    tdf_ingenua(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, Salidas),
    profundidad_maxima(Nodos, Salidas, P).

% Ejercicio 6

%!  rotaciones(-Es:list) is det.
%
%   Es son los 16 elementos, fila por fila, del producto simplificado de
%   las rotaciones alrededor del eje z en los ángulos a y b.
rotaciones(Es) :-
    rotacion(z, a, A),
    rotacion(z, b, B),
    producto_simbolico(A, B, P),
    append(P, Es).

%!  costo_rotaciones(-S0, -P0, -S, -P) is det.
%
%   Los elementos de rotaciones/1 tienen, por separado, S0 sumas o restas
%   y P0 productos, y su grafo tiene S sumas o restas y P productos.
costo_rotaciones(S0, P0, S, P) :-
    rotaciones(Es),
    operaciones(Es, S0, P0),
    grafo(Es, Nodos, _),
    contar_nodos(Nodos, _, S, P).

% Ejercicio 9

%!  fft_exacta(+Coefs:list(integer), -Vs:list) is det.
%
%   Vs es la transformada exacta de Coefs, de longitud 1, 2 o 4, con el
%   grafo de la mariposa.
fft_exacta(Coefs, Vs) :-
    length(Coefs, N),
    fft_grafo(N, Nodos, Salidas),
    valor_grafo_exacto(N, Coefs, Nodos, Salidas, Vs).
