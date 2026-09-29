:- encoding(utf8).

% Capítulo 22 - Soluciones de los ejercicios 1 a 9 y 16. Las de los ejercicios
% 10 y 11 están en soluciones_bloques.pl, las de 12 y 13 en
% soluciones_buscaminas.pl, y las de 14 y 15 en soluciones_proyecto.pl.
%
%?- por_longitud([[a, b, c], [d], [e, f]], L).
%?- anagramas(roma, [amor, mora, ramo, rama], L).
%?- formatear_nombre(ana, [mayusculas(true), prefijo('Sra. ')], T).

% --- Ejercicio 3 ----------------------------------------------------------

%!  por_longitud(+Listas:list(list), -Ordenadas:list(list)) is det.
%
%   Ordenadas son las Listas de la más corta a la más larga; con la misma
%   longitud, en el orden original.
por_longitud(Listas, Ordenadas) :-
    map_list_to_pairs(length, Listas, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Ordenadas).

% --- Ejercicio 4 ----------------------------------------------------------

%!  anagramas(+Palabra:atom, +Candidatas:list, -Anagramas:list) is det.
%
%   Anagramas son las Candidatas que tienen las mismas letras que Palabra,
%   en otro orden. Palabra misma no es su propio anagrama.
anagramas(Palabra, Candidatas, Anagramas) :-
    letras(Palabra, Letras),
    include([C]>>( C \== Palabra, letras(C, Letras) ), Candidatas,
            Anagramas).

%!  letras(+Palabra:atom, -Letras:list) is det.
%
%   Letras son los caracteres de Palabra ordenados, con los repetidos.
letras(Palabra, Letras) :-
    atom_chars(Palabra, Caracteres),
    msort(Caracteres, Letras).

% --- Ejercicio 5 ----------------------------------------------------------

%!  agregar_alumno(+Grado:integer, +Nombre:atom, +Escuela0, -Escuela) is det.
%
%   Escuela es Escuela0, un assoc de cada grado a un conjunto ordenado de
%   nombres, con Nombre agregado al Grado.
agregar_alumno(Grado, Nombre, Escuela0, Escuela) :-
    (   get_assoc(Grado, Escuela0, Nombres0)
    ->  true
    ;   Nombres0 = []
    ),
    ord_add_element(Nombres0, Nombre, Nombres),
    put_assoc(Grado, Escuela0, Nombres, Escuela).

%!  alumnos_de(+Escuela, +Grado:integer, -Nombres:list(atom)) is det.
%
%   Nombres son los alumnos del Grado, en orden alfabético; la lista vacía si
%   no tiene ninguno.
alumnos_de(Escuela, Grado, Nombres) :-
    (   get_assoc(Grado, Escuela, Encontrados)
    ->  Nombres = Encontrados
    ;   Nombres = []
    ).

%!  escuela(+Altas:list(pair), -Escuela) is det.
%
%   Escuela es la escuela que resulta de agregar cada alta Grado-Nombre, en
%   orden, a una escuela vacía.
escuela(Altas, Escuela) :-
    empty_assoc(Vacia),
    foldl([G-N, E0, E]>>agregar_alumno(G, N, E0, E), Altas, Vacia, Escuela).

% --- Ejercicio 6 ----------------------------------------------------------

%!  por_valor(+Pares:list(pair), -Ordenados:list(pair)) is det.
%
%   Ordenados son los Pares de menor a mayor valor, con los repetidos:
%   comparar_valor/3 nunca responde =.
por_valor(Pares, Ordenados) :-
    predsort(comparar_valor, Pares, Ordenados).

%!  comparar_valor(-Orden, +A:pair, +B:pair) is det.
%
%   Orden es < si el valor de A es menor o igual que el de B, y > si no.
comparar_valor(Orden, _-VA, _-VB) :-
    (   VA =< VB
    ->  Orden = (<)
    ;   Orden = (>)
    ).

% --- Ejercicio 7 ----------------------------------------------------------

%!  la_mayor(+Personas:list(dict), -Mayor:dict) is semidet.
%
%   Mayor es el dict de mayor edad de Personas; con empate, el primero. Falla
%   con la lista vacía.
la_mayor([Primera|Resto], Mayor) :-
    foldl(la_mayor_de_dos, Resto, Primera, Mayor).

%!  la_mayor_de_dos(+P:dict, +Hasta:dict, -Mayor:dict) is det.
%
%   Mayor es P si es mayor que Hasta, o Hasta si no. La notación funcional
%   se expande en la cláusula que la contiene: dentro de una lambda, se
%   evaluaría antes de que la lambda reciba P.
la_mayor_de_dos(P, Hasta, Mayor) :-
    (   P.edad > Hasta.edad
    ->  Mayor = P
    ;   Mayor = Hasta
    ).

% --- Ejercicio 8 ----------------------------------------------------------

%!  formatear_nombre(+Nombre:atom, +Opciones:list, -Texto:atom) is det.
%
%   Texto es Nombre con las Opciones: mayusculas(B), si se escribe en
%   mayúsculas, false si falta; prefijo(P), el texto que va antes, '' si
%   falta.
formatear_nombre(Nombre, Opciones, Texto) :-
    option(mayusculas(Mayusculas), Opciones, false),
    option(prefijo(Prefijo), Opciones, ''),
    (   Mayusculas == true
    ->  upcase_atom(Nombre, Base)
    ;   Base = Nombre
    ),
    atom_concat(Prefijo, Base, Texto).

% --- Ejercicio 9 ----------------------------------------------------------

%!  sorteo(+Cantidad:integer, +Hasta:integer, -Numeros:list(integer)) is det.
%
%   Numeros son Cantidad números distintos entre 1 y Hasta, elegidos al azar,
%   en el orden en que salieron.
sorteo(Cantidad, Hasta, Numeros) :-
    randseq(Cantidad, Hasta, Numeros).

% --- Ejercicio 16 ---------------------------------------------------------

%!  insertar_mal(+Clave, +Arbol0, -Arbol) is det.
%
%   Arbol es Arbol0 con Clave agregada. Versión incorrecta, la del
%   enunciado: las cláusulas recursivas devuelven el árbol del subárbol, sin
%   el nodo que lo contiene, y la última no liga Arbol.
insertar_mal(Clave, vacio, n(vacio, Clave, vacio)).
insertar_mal(Clave, n(Izq, Clave0, _), Arbol) :-
    Clave @< Clave0,
    insertar_mal(Clave, Izq, Arbol).
insertar_mal(Clave, n(_, Clave0, Der), Arbol) :-
    Clave @> Clave0,
    insertar_mal(Clave, Der, Arbol).
insertar_mal(Clave, n(_, Clave, _), _).

%!  insertar(+Clave, +Arbol0, -Arbol) is det.
%
%   Arbol es el árbol de búsqueda Arbol0 con Clave agregada; si Clave ya
%   está, Arbol es igual a Arbol0. El árbol es vacio o n(Izq, Clave, Der).
insertar(Clave, Arbol0, Arbol) :-
    insertar_en(Arbol0, Clave, Arbol).

%!  insertar_en(+Arbol0, +Clave, -Arbol) is det.
%
%   El recorrido de insertar/3, con el árbol como primer argumento para que
%   la indexación distinga vacio de n/3.
insertar_en(vacio, Clave, n(vacio, Clave, vacio)).
insertar_en(n(Izq, Clave0, Der), Clave, Arbol) :-
    compare(Orden, Clave, Clave0),
    insertar_segun(Orden, Clave, n(Izq, Clave0, Der), Arbol).

%!  insertar_segun(+Orden, +Clave, +Nodo, -Arbol) is det.
%
%   Arbol es Nodo con Clave agregada, según el Orden de Clave respecto de la
%   clave de Nodo: un nodo nuevo con el subárbol que cambió, o el mismo Nodo
%   si la clave ya está.
insertar_segun(<, Clave, n(Izq, Clave0, Der), n(Izq1, Clave0, Der)) :-
    insertar_en(Izq, Clave, Izq1).
insertar_segun(=, _, Nodo, Nodo).
insertar_segun(>, Clave, n(Izq, Clave0, Der), n(Izq, Clave0, Der1)) :-
    insertar_en(Der, Clave, Der1).
