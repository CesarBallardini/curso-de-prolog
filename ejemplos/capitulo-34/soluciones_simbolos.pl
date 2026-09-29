:- encoding(utf8).

% Capítulo 34 - Soluciones de los ejercicios 13 y 14.
%
% El ensamblador de simbolos.pl, con dos cambios. Ejercicio 13: una marca
% de etiqueta repetida produce un error de permiso, en lugar de hacer
% fallar el ensamblado. Ejercicio 14: asignar/3 reemplaza el nombre de cada
% variable de cargar/1 y guardar/1 por una dirección de memoria, con otro
% diccionario incompleto.
%
%?- ensamblar([etiqueta(a), sumar, etiqueta(a)], C).
%?- ensamblar([saltar(fin), sumar, etiqueta(fin)], C).
%?- asignar([cargar(x), cargar(y), sumar, guardar(x)], C, N).

% programa(Nombre, Instrucciones): un programa de ejemplo. cuenta escribe
% 3, 2 y 1.
programa(cuenta, [ apilar(3), guardar(n),
                   etiqueta(inicio),
                   cargar(n), saltar_si_cero(fin),
                   cargar(n), escribir,
                   cargar(n), apilar(1), restar, guardar(n),
                   saltar(inicio),
                   etiqueta(fin) ]).

%!  ensamblar(+Programa:list, -Codigo:list) is semidet.
%
%   Codigo es Programa con las marcas de etiqueta quitadas y cada salto
%   dirigido al número de instrucción de su etiqueta, contando desde 0.
%   Produce un error de existencia si un salto usa una etiqueta que no se
%   marca, y un error de permiso si una etiqueta se marca dos veces.
ensamblar(Programa, Codigo) :-
    phrase(codigo(Programa, 0, Tabla), Codigo),
    etiquetas_definidas(Tabla).

%!  codigo(+Programa:list, +Dir:integer, ?Tabla)// is semidet.
%
%   El código de Programa, cuya primera instrucción tiene la dirección Dir;
%   Tabla es el diccionario incompleto de las etiquetas.
codigo([], _, _) -->
    [].
codigo([I|Is], Dir, Tabla) -->
    instruccion(I, Dir, Dir1, Tabla),
    codigo(Is, Dir1, Tabla).

%!  instruccion(+I, +Dir:integer, -Dir1:integer, ?Tabla)// is semidet.
%
%   El código de la instrucción I, en la dirección Dir; Dir1 es la
%   dirección de la siguiente. Una marca no ocupa lugar: registra Dir.
instruccion(I, Dir, Dir1, _) -->
    { simple(I) },
    [I],
    { Dir1 is Dir + 1 }.
instruccion(etiqueta(E), Dir, Dir, Tabla) -->
    { marcar(E, Tabla, Dir) }.
instruccion(saltar(E), Dir, Dir1, Tabla) -->
    [saltar(D)],
    { buscar(E, Tabla, D),
      Dir1 is Dir + 1 }.
instruccion(saltar_si_cero(E), Dir, Dir1, Tabla) -->
    [saltar_si_cero(D)],
    { buscar(E, Tabla, D),
      Dir1 is Dir + 1 }.

% simple(I): I es una instrucción sin etiquetas, que se copia tal cual.
simple(apilar(_)).
simple(cargar(_)).
simple(guardar(_)).
simple(sumar).
simple(restar).
simple(escribir).

%!  listar(+Nombre) is det.
%
%   Escribe el código ensamblado del programa Nombre, una instrucción por
%   línea, con su dirección.
listar(Nombre) :-
    programa(Nombre, Programa),
    ensamblar(Programa, Codigo),
    mostrar(Codigo, 0).

%!  mostrar(+Codigo:list, +Dir:integer) is det.
%
%   Escribe cada instrucción de Codigo con su dirección, desde Dir.
mostrar([], _).
mostrar([I|Is], Dir) :-
    format("~w~t~4|~w~n", [Dir, I]),
    Dir1 is Dir + 1,
    mostrar(Is, Dir1).

%!  etiquetas_definidas(+Tabla) is det.
%
%   Cada etiqueta de Tabla tiene una dirección. Produce un error de
%   existencia con la primera que no la tiene.
etiquetas_definidas(Final) :-
    var(Final),
    !.
etiquetas_definidas([E-Dir|Resto]) :-
    (   var(Dir)
    ->  existence_error(etiqueta, E)
    ;   etiquetas_definidas(Resto)
    ).

%!  buscar(+Clave, ?Dic:list, ?Valor) is semidet.
%
%   Dic es un diccionario incompleto: una lista abierta de pares
%   Clave-Valor, con claves distintas. Si Clave está en Dic, Valor unifica
%   con su valor; si no, el par Clave-Valor se agrega al final. Falla si la
%   clave está con otro valor.
buscar(Clave, [Clave0-Valor0|Resto], Valor) :-
    (   Clave = Clave0
    ->  Valor = Valor0
    ;   buscar(Clave, Resto, Valor)
    ).

% --- Ejercicio 13 ---

%!  marcar(+E, ?Tabla, +Dir:integer) is det.
%
%   Registra en Tabla que la etiqueta E está en la dirección Dir. Produce
%   un error de permiso si E ya estaba marcada.
marcar(E, Tabla, Dir) :-
    buscar(E, Tabla, D),
    (   var(D)
    ->  D = Dir
    ;   permission_error(marcar, etiqueta, E)
    ).

% --- Ejercicio 14 ---

%!  asignar(+Codigo:list, -Codigo1:list, -N:integer) is det.
%
%   Codigo1 es Codigo con el nombre de cada variable de cargar/1 y
%   guardar/1 reemplazado por una dirección de memoria: 0 para la primera
%   variable que aparece, 1 para la segunda, y así. N es la cantidad de
%   variables.
asignar(Codigo, Codigo1, N) :-
    maplist(direccion(Tabla), Codigo, Codigo1),
    numerar(Tabla, 0, N).

%!  direccion(?Tabla, +I, -I1) is det.
%
%   I1 es la instrucción I con la variable, si la tiene, reemplazada por su
%   valor en el diccionario incompleto Tabla. I1 debe llegar libre.
direccion(Tabla, cargar(V), cargar(D)) :-
    !,
    buscar(V, Tabla, D).
direccion(Tabla, guardar(V), guardar(D)) :-
    !,
    buscar(V, Tabla, D).
direccion(_, I, I).

%!  numerar(+Tabla:list, +N0:integer, -N:integer) is det.
%
%   Liga los valores de Tabla a N0, N0+1, …, en orden, hasta el final
%   abierto; N es el siguiente número sin usar.
numerar(Final, N, N) :-
    var(Final),
    !.
numerar([_-N0|Resto], N0, N) :-
    N1 is N0 + 1,
    numerar(Resto, N1, N).
