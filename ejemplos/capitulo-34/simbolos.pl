:- encoding(utf8).

% Capítulo 34 - La tabla de símbolos de un ensamblador.
%
% Un programa para una máquina de pila usa etiquetas: etiqueta(E) marca una
% posición, y saltar(E) y saltar_si_cero(E) saltan a ella. ensamblar/2
% reemplaza cada etiqueta por su dirección, el número de la instrucción que
% sigue a la marca, en una sola pasada. La tabla de símbolos es un
% diccionario incompleto (buscar/3, repetido de diccionario.pl): un salto
% hacia adelante agrega la etiqueta con la dirección libre, y la marca, al
% aparecer más abajo, la liga. El código se construye con una gramática, es
% decir, como lista diferencia.
%
%?- listar(cuenta).
%?- ensamblar([saltar(fin), sumar, etiqueta(fin)], C).
%?- ensamblar([saltar(fin), sumar], C).

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
%   marca; falla si una etiqueta se marca dos veces en direcciones
%   distintas.
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
    { buscar(E, Tabla, Dir) }.
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
