:- encoding(utf8).

% Capítulo 4 - Soluciones de los ejercicios.
%
% Las mismas fichas del capítulo, con los predicados que piden los ejercicios.
%
%?- registro(F), es_gato(F).
%?- misma_especie(F1, F2).

% registro(F): F es la ficha de una mascota.
registro(ficha(mascota(gato, felix), fecha(2021, 5, 3), ana)).
registro(ficha(mascota(perro, rocco), fecha(2019, 11, 20), luis)).
registro(ficha(mascota(gato, gaturro), fecha(2023, 2, 14), eva)).

especie(ficha(mascota(E, _), _, _), E).
nombre_de(ficha(mascota(_, N), _, _), N).

% --- Ejercicio 5 -----------------------------------------------------------

% dia_de(F, D): D es el día en que nació la mascota de la ficha F.
dia_de(ficha(_, fecha(_, _, D), _), D).

% --- Ejercicio 6 -----------------------------------------------------------

% es_gato(F): la ficha F es de un gato. El patrón fija gato como especie.
es_gato(ficha(mascota(gato, _), _, _)).

% --- Ejercicio 8 -----------------------------------------------------------

% producto(T, A, B): A y B son los dos operandos del producto T.
producto(A * B, A, B).

% operacion(T, A, B): T es una suma o un producto de A y B.
operacion(A + B, A, B).
operacion(A * B, A, B).

% --- Ejercicio 9 -----------------------------------------------------------

% misma_especie(F1, F2): dos fichas distintas de la misma especie.
misma_especie(F1, F2) :-
    registro(F1),
    registro(F2),
    especie(F1, E),
    especie(F2, E),
    F1 \== F2.

% --- Ejercicio 13 ----------------------------------------------------------

% propietario_y_especie(F, P, E): P es el propietario de la ficha F y E la
% especie de su mascota. Es la plantilla 7 con dos componentes.
propietario_y_especie(ficha(mascota(E, _), _, P), P, E).

% --- Ejercicio 14 ----------------------------------------------------------

% ficha_de(P, F): F es un registro cuyo propietario es P.
ficha_de(P, F) :-
    registro(F),
    F = ficha(_, _, P).

% --- Ejercicio 17 ----------------------------------------------------------

% mismo_propietario(F1, F2): dos fichas distintas con el mismo propietario.
mismo_propietario(F1, F2) :-
    registro(F1),
    registro(F2),
    F1 = ficha(_, _, P),
    F2 = ficha(_, _, P),
    F1 \== F2.
