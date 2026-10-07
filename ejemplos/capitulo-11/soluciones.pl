:- encoding(utf8).

% Capítulo 11 - Soluciones de los ejercicios.
%
%?- ultima_letra(prolog, L).
%?- iniciales_de('juan carlos perez', I).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% --- Ejercicio 3 -----------------------------------------------------------

%!  ultima_letra(+Palabra, ?L) is semidet.
%
%   L es el último carácter del átomo Palabra. sub_atom/5 con Despues = 0 y
%   Largo = 1 toma el fragmento de un carácter que termina al final.
ultima_letra(Palabra, L) :-
    sub_atom(Palabra, _, 1, 0, L).

% --- Ejercicio 4 -----------------------------------------------------------

%!  mas_largo(+A, +B, -M) is det.
%
%   M es el más largo de los átomos A y B; con el mismo largo, M es A. Las
%   condiciones de las dos cláusulas son complementarias.
mas_largo(A, B, A) :-
    atom_length(A, LA),
    atom_length(B, LB),
    LA >= LB.
mas_largo(A, B, B) :-
    atom_length(A, LA),
    atom_length(B, LB),
    LA < LB.

% --- Ejercicio 6 -----------------------------------------------------------

%!  tabla_con_titulos(+Personas) is semidet.
%
%   Escribe los títulos, una línea de guiones de 14 caracteres y las filas
%   de tabla/1.
tabla_con_titulos(Personas) :-
    format("~w~t~10|~t~w~4+~n", ['Nombre', 'Edad']),
    format("~`-t~14|~n"),
    tabla(Personas).

%!  tabla(+Personas) is semidet.
%
%   Una fila por persona: el nombre en diez posiciones y la edad alineada a
%   la derecha en las cuatro siguientes.
tabla([]).
tabla([P|Resto]) :-
    edad(P, E),
    format("~w~t~10|~t~d~4+~n", [P, E]),
    tabla(Resto).

% --- Ejercicio 7 -----------------------------------------------------------

%!  palindromo(+Palabra) is semidet.
%
%   Palabra se lee igual en los dos sentidos: su lista de caracteres es igual
%   a la lista invertida.
palindromo(Palabra) :-
    atom_chars(Palabra, Letras),
    reverse(Letras, Letras).

% --- Ejercicio 8 -----------------------------------------------------------

%!  quitar_prefijo(+Palabra, ?Prefijo, ?Resto) is nondet.
%
%   El átomo Palabra empieza con Prefijo, y Resto es lo que sigue.
quitar_prefijo(Palabra, Prefijo, Resto) :-
    atom_concat(Prefijo, Resto, Palabra).

% --- Ejercicio 9 -----------------------------------------------------------

%!  contar_vocales(+Palabra, -N) is det.
%
%   N es la cantidad de vocales de Palabra, sin distinguir mayúsculas.
contar_vocales(Palabra, N) :-
    downcase_atom(Palabra, Minusculas),
    atom_chars(Minusculas, Letras),
    vocales(Letras, N).

%!  vocales(+Letras, -N) is det.
%
%   N es la cantidad de vocales de la lista de caracteres Letras. Las
%   condiciones de la segunda y la tercera cláusula son complementarias.
vocales([], 0).
vocales([C|Resto], N) :-
    vocal(C),
    vocales(Resto, N0),
    N is N0 + 1.
vocales([C|Resto], N) :-
    \+ vocal(C),
    vocales(Resto, N).

% vocal(C): C es una vocal minúscula.
vocal(a).
vocal(e).
vocal(i).
vocal(o).
vocal(u).

% --- Ejercicio 11 ----------------------------------------------------------

%!  campos(+Linea, -Campos) is det.
%
%   Campos es la lista de los campos de Linea, separados por comas y con los
%   espacios de los bordes quitados, como átomos.
campos(Linea, Campos) :-
    split_string(Linea, ",", " ", Partes),
    a_atomos(Partes, Campos).

%!  a_atomos(+Cadenas, -Atomos) is det.
%
%   Atomos es la lista de las cadenas convertidas en átomos.
a_atomos([], []).
a_atomos([Cadena|Resto], [Atomo|Atomos]) :-
    atom_string(Atomo, Cadena),
    a_atomos(Resto, Atomos).

% --- Ejercicio 12 ----------------------------------------------------------

%!  campos_con_numeros(+Linea, -Campos) is det.
%
%   Como campos/2, pero los campos que representan números quedan como
%   números.
campos_con_numeros(Linea, Campos) :-
    split_string(Linea, ",", " ", Partes),
    a_valores(Partes, Campos).

%!  a_valores(+Cadenas, -Valores) is det.
%
%   Valores es la lista de los valores de las cadenas.
a_valores([], []).
a_valores([Cadena|Resto], [Valor|Valores]) :-
    valor(Cadena, Valor),
    a_valores(Resto, Valores).

%!  valor(+Cadena, -Valor) is det.
%
%   Valor es el número que representa Cadena, o el átomo con su texto si no
%   representa un número. El corte es rojo: la segunda cláusula acepta
%   cualquier cadena.
valor(Cadena, Numero) :-
    atom_string(Atomo, Cadena),
    atom_number(Atomo, Numero),
    !.
valor(Cadena, Atomo) :-
    atom_string(Atomo, Cadena).

% --- Ejercicio 13 ----------------------------------------------------------

%!  mismo_texto(+A, +B) is semidet.
%
%   A y B, átomos o cadenas, son el mismo texto si se ignoran las mayúsculas,
%   los espacios sobrantes y los signos de puntuación.
mismo_texto(A, B) :-
    en_forma_normal(A, Normal),
    en_forma_normal(B, Normal).

%!  en_forma_normal(+Texto, -Normal) is det.
%
%   Normal es el átomo de Texto sin signos de puntuación, en minúsculas y con
%   los espacios normalizados. atom_chars/2 acepta un átomo o una cadena.
en_forma_normal(Texto, Normal) :-
    atom_chars(Texto, Caracteres),
    sin_puntuacion(Caracteres, Letras),
    atom_chars(SinPuntuacion, Letras),
    normalize_space(atom(Espaciado), SinPuntuacion),
    downcase_atom(Espaciado, Normal).

%!  sin_puntuacion(+Caracteres, -Letras) is det.
%
%   Letras es la lista Caracteres sin los signos de puntuación.
sin_puntuacion([], []).
sin_puntuacion([C|Resto], Letras) :-
    puntuacion(C),
    sin_puntuacion(Resto, Letras).
sin_puntuacion([C|Resto], [C|Letras]) :-
    \+ puntuacion(C),
    sin_puntuacion(Resto, Letras).

% puntuacion(C): C es un signo de puntuación.
puntuacion(',').
puntuacion('.').
puntuacion(';').
puntuacion(':').

% --- Ejercicio 15 ----------------------------------------------------------

%!  iniciales_de(+NombreCompleto, -Iniciales) is det.
%
%   Iniciales es el átomo formado por las iniciales de las palabras de
%   NombreCompleto, en mayúscula.
iniciales_de(NombreCompleto, Iniciales) :-
    split_string(NombreCompleto, " ", " ", Palabras),
    primeras_letras(Palabras, Letras),
    atomic_list_concat(Letras, Minusculas),
    upcase_atom(Minusculas, Iniciales).

%!  primeras_letras(+Palabras, -Letras) is det.
%
%   Letras es la lista de los primeros caracteres de las cadenas no vacías
%   de Palabras.
primeras_letras([], []).
primeras_letras([""|Resto], Letras) :-
    primeras_letras(Resto, Letras).
primeras_letras([Palabra|Resto], [Letra|Letras]) :-
    Palabra \== "",
    string_chars(Palabra, [Letra|_]),
    primeras_letras(Resto, Letras).

% --- Ejercicio 16 ----------------------------------------------------------

%!  alrededor(+Palabra, ?Fragmento, ?Antes, ?Despues) is nondet.
%
%   El átomo Palabra es la concatenación de Antes, Fragmento y Despues. Una
%   respuesta por cada aparición de Fragmento en Palabra.
alrededor(Palabra, Fragmento, Antes, Despues) :-
    sub_atom(Palabra, LargoAntes, _, LargoDespues, Fragmento),
    sub_atom(Palabra, 0, LargoAntes, _, Antes),
    sub_atom(Palabra, _, LargoDespues, 0, Despues).

% --- Ejercicio 17 ----------------------------------------------------------

%!  en_orden(+Palabras) is semidet.
%
%   La lista de átomos Palabras está en el orden estándar: cada átomo es
%   menor o igual que el siguiente.
en_orden([]).
en_orden([_]).
en_orden([A, B|Resto]) :-
    A @=< B,
    en_orden([B|Resto]).
