:- encoding(utf8).

% Capítulo 47 - Versión 5: la inversa de una matriz, exacta.
%
% inversa/2 aplica la eliminación de Gauss-Jordan a la matriz ampliada
% [A | I]: para cada columna elige como pivote una fila pendiente con un
% elemento distinto de 0 en esa columna, la divide por ese elemento y resta
% un múltiplo de ella a todas las demás filas, para que la columna quede
% con un 1 en la fila del pivote y 0 en las otras. Al terminar, la mitad
% izquierda es la identidad y la derecha es la inversa. Las operaciones
% son las de is/2: con enteros y racionales el resultado es exacto; con
% números de punto flotante, cada paso redondea. hilbert/3 construye la
% matriz de Hilbert, el ejemplo clásico de una matriz mal condicionada.
%
% solo-local: carga matriz.pl, y SWISH no carga otros archivos.
%
%?- inversa([[2, 1], [1, 1]], I).
%?- inversa([[1, 2], [2, 4]], I).
%?- hilbert(3, racional, H), inversa(H, I).
%?- hilbert(3, flotante, H), inversa(H, I), producto(H, I, P).
%?- desvio_hilbert(8, flotante, E).

:- ensure_loaded(matriz).

%!  inversa(+A:list(list), -Inversa:list(list)) is semidet.
%
%   Inversa es la inversa de la matriz cuadrada A. Falla si A es singular.
%   Produce un error de dominio si A no es cuadrada.
inversa(A, Inversa) :-
    dimensiones(A, N, C),
    (   N =:= C
    ->  true
    ;   domain_error(matriz_cuadrada, A)
    ),
    identidad(N, I),
    maplist(append, A, I, Ampliada),
    gauss_jordan(Ampliada, [], Reducida),
    maplist(mitad_derecha(N), Reducida, Inversa).

%!  gauss_jordan(+Pendientes:list(list), +Hechas:list(list),
%!               -Reducida:list(list)) is semidet.
%
%   Reducida son las filas Hechas y Pendientes con cada columna de pivote
%   reducida: la columna K tiene un 1 en la fila K y 0 en las demás. Hechas
%   son las filas que ya tienen su pivote, en orden, y la columna siguiente
%   es la número length(Hechas). Falla si una columna no tiene pivote.
gauss_jordan([], Hechas, Hechas).
gauss_jordan([P|Ps], Hechas0, Reducida) :-
    length(Hechas0, K),
    elegir_pivote(K, [P|Ps], Pivote0, Resto0),
    nth0(K, Pivote0, X),
    maplist(dividir_por(X), Pivote0, Pivote),
    maplist(eliminar(K, Pivote), Hechas0, Hechas1),
    maplist(eliminar(K, Pivote), Resto0, Resto),
    append(Hechas1, [Pivote], Hechas),
    gauss_jordan(Resto, Hechas, Reducida).

%!  elegir_pivote(+K:integer, +Filas:list(list), -Pivote:list,
%!                -Resto:list(list)) is semidet.
%
%   Pivote es la primera de Filas cuyo elemento K (desde 0) no es 0, y
%   Resto son las demás filas, en orden. Falla si no hay ninguna.
elegir_pivote(K, Filas, Pivote, Resto) :-
    select(Pivote, Filas, Resto),
    nth0(K, Pivote, X),
    X =\= 0,
    !.

%!  dividir_por(+X:number, +Y:number, -Z:number) is det.
%
%   Z es Y / X, exacto si X e Y son enteros o racionales.
dividir_por(X, Y, Z) :-
    (   rational(X),
        rational(Y)
    ->  Z is Y rdiv X
    ;   Z is Y / X
    ).

%!  eliminar(+K:integer, +Pivote:list, +Fila:list, -Nueva:list) is det.
%
%   Nueva es Fila menos Pivote multiplicado por el elemento K de Fila: el
%   elemento K de Nueva es 0, porque el de Pivote es 1.
eliminar(K, Pivote, Fila, Nueva) :-
    nth0(K, Fila, F),
    maplist(restar_multiplo(F), Pivote, Fila, Nueva).

%!  restar_multiplo(+F:number, +P:number, +X:number, -Y:number) is det.
%
%   Y es X - F * P.
restar_multiplo(F, P, X, Y) :-
    Y is X - F * P.

%!  mitad_derecha(+N:integer, +Fila:list, -Derecha:list) is det.
%
%   Derecha es Fila sin sus primeros N elementos.
mitad_derecha(N, Fila, Derecha) :-
    length(Izquierda, N),
    append(Izquierda, Derecha, Fila).

%!  hilbert(+N:integer, +Tipo:atom, -H:list(list)) is det.
%
%   H es la matriz de Hilbert de orden N, cuyo elemento en la fila I y la
%   columna J es 1 / (I + J - 1), con elementos racionales si Tipo es
%   racional y de punto flotante si Tipo es flotante.
hilbert(N, Tipo, H) :-
    must_be(oneof([racional, flotante]), Tipo),
    findall(K, between(1, N, K), Is),
    maplist(fila_hilbert(Tipo, Is), Is, H).

%!  fila_hilbert(+Tipo:atom, +Js:list(integer), +I:integer, -Fila:list) is det.
%
%   Fila es la fila I de la matriz de Hilbert, para las columnas Js.
fila_hilbert(Tipo, Js, I, Fila) :-
    maplist(elemento_hilbert(Tipo, I), Js, Fila).

%!  elemento_hilbert(+Tipo:atom, +I:integer, +J:integer, -X:number) is det.
%
%   X es 1 / (I + J - 1), racional o de punto flotante según Tipo.
elemento_hilbert(racional, I, J, X) :-
    X is 1 rdiv (I + J - 1).
elemento_hilbert(flotante, I, J, X) :-
    X is 1.0 / (I + J - 1).

%!  desvio(+A:list(list), +Inversa:list(list), -E:number) is det.
%
%   E es la mayor diferencia, en valor absoluto, entre un elemento de
%   A * Inversa y el de la identidad en la misma posición: 0 si Inversa
%   es exactamente la inversa de A.
desvio(A, Inversa, E) :-
    producto(A, Inversa, P),
    length(P, N),
    identidad(N, I),
    append(P, Ps),
    append(I, Is),
    foldl(mayor_diferencia, Ps, Is, 0, E).

%!  mayor_diferencia(+X:number, +Y:number, +E0:number, -E:number) is det.
%
%   E es el mayor entre E0 y el valor absoluto de X - Y.
mayor_diferencia(X, Y, E0, E) :-
    E is max(E0, abs(X - Y)).

%!  desvio_hilbert(+N:integer, +Tipo:atom, -E:number) is det.
%
%   E es el desvío de la inversa de la matriz de Hilbert de orden N con
%   elementos del Tipo racional o flotante.
desvio_hilbert(N, Tipo, E) :-
    hilbert(N, Tipo, H),
    inversa(H, I),
    desvio(H, I, E).
