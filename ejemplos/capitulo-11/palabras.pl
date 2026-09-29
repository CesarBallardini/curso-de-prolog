:- encoding(utf8).

% Capítulo 11 - Texto: buscar, dividir, unir y comparar.
%
% sub_atom/5 y atom_concat/3 buscan dentro de un átomo, y sub_string/5 y
% string_concat/3 dentro de una cadena; split_string/4 y atomic_list_concat/3
% dividen y unen; upcase_atom/2 y normalize_space/2 normalizan antes de
% comparar.
%
%?- empieza_con(prolog, pro).
%?- contar_palabras("el  perro   ladra", N).

%!  empieza_con(+Palabra, ?Prefijo) is nondet.
%
%   Prefijo es un comienzo de Palabra. Con Prefijo libre, enumera todos los
%   comienzos, del vacío a la palabra entera.
empieza_con(Palabra, Prefijo) :-
    sub_atom(Palabra, 0, _, _, Prefijo).

%!  termina_con(+Palabra, ?Sufijo) is nondet.
%
%   Sufijo es un final de Palabra.
termina_con(Palabra, Sufijo) :-
    sub_atom(Palabra, _, _, 0, Sufijo).

%!  contar_letra(+Letra, +Palabra, -N) is det.
%
%   N es la cantidad de veces que el carácter Letra aparece en el átomo
%   Palabra.
contar_letra(Letra, Palabra, N) :-
    atom_chars(Palabra, Letras),
    contar(Letra, Letras, N).

%!  contar(+X, +L, -N) is det.
%
%   N es la cantidad de veces que X aparece en la lista L.
contar(_, [], 0).
contar(X, [X|Resto], N) :-
    contar(X, Resto, N0),
    N is N0 + 1.
contar(X, [Y|Resto], N) :-
    X \== Y,
    contar(X, Resto, N).

%!  sin_prefijo(?Prefijo, +Texto, ?Resto) is nondet.
%!  sin_prefijo(+Prefijo, +Texto, -Resto) is semidet.
%
%   Texto es la cadena Prefijo seguida de la cadena Resto.
sin_prefijo(Prefijo, Texto, Resto) :-
    string_concat(Prefijo, Resto, Texto).

%!  aparece_en(+Texto, +Buscado, -Posicion) is nondet.
%
%   Buscado aparece en Texto después de sus primeros Posicion caracteres.
%   Una respuesta por aparición.
aparece_en(Texto, Buscado, Posicion) :-
    sub_string(Texto, Posicion, _, _, Buscado).

%!  contar_palabras(+Texto, -N) is det.
%
%   N es la cantidad de palabras de Texto, separadas por uno o más espacios.
contar_palabras(Texto, N) :-
    split_string(Texto, " ", " ", Partes),
    no_vacias(Partes, N).

%!  no_vacias(+Cadenas, -N) is det.
%
%   N es la cantidad de cadenas de la lista que no son la cadena vacía.
no_vacias([], 0).
no_vacias([""|Resto], N) :-
    no_vacias(Resto, N).
no_vacias([Cadena|Resto], N) :-
    Cadena \== "",
    no_vacias(Resto, N0),
    N is N0 + 1.

%!  nombre_completo(+Nombre, +Apellido, -Completo) is det.
%
%   Completo es el átomo formado por Nombre y Apellido separados por un
%   espacio.
nombre_completo(Nombre, Apellido, Completo) :-
    atomic_list_concat([Nombre, Apellido], ' ', Completo).

%!  mismo_nombre(+A, +B) is semidet.
%
%   A y B son el mismo nombre si se ignoran las mayúsculas y los espacios
%   sobrantes.
mismo_nombre(A, B) :-
    normalizado(A, Normal),
    normalizado(B, Normal).

%!  normalizado(+Texto, -Normal) is det.
%
%   Normal es Texto en minúsculas, con un solo espacio entre palabras y sin
%   espacios al comienzo ni al final.
normalizado(Texto, Normal) :-
    normalize_space(atom(Espaciado), Texto),
    downcase_atom(Espaciado, Normal).
