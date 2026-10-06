:- encoding(utf8).

% Capítulo 86 - Versión 4: el compilador de Toy-Sequel.
%
% Traduce un SELECT sin agregados ni subconsultas a una meta de Prolog,
% como el compilador de comandos de Kluźniak y Szpakowicz: los generadores
% de las tablas del FROM, uno por tabla, y después el filtro de WHERE. Cada
% igualdad entre columnas o con una constante se resuelve al compilar,
% unificando sus variables, y desaparece de la meta; si la unificación no
% es posible, la igualdad se compila como fail. Es la optimización más
% rentable del compilador, pero se aplica en cualquier lugar de la
% condición, y bajo OR o NOT cambia el resultado. Tampoco hay NULL: las
% comparaciones son las de Prolog. consultas.pl corrige las dos cosas.
%
% solo-local: carga los módulos del capítulo.
%
%?- traducir_ingenuo("SELECT nombre FROM alumnos WHERE carrera = 'civil'", F, M).
%?- consulta_ingenua("SELECT nombre FROM alumnos WHERE carrera = 'civil' OR carrera = 'industrial'", Fs).

:- module(ingenuo,
          [ traducir_ingenuo/3,
            consulta_ingenua/2
          ]).

:- use_module(sintaxis).
:- use_module(catalogo).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  consulta_ingenua(+Texto, -Filas:list) is det.
%
%   Filas son las filas que da la meta traducida de Texto, una por cada
%   demostración, en orden.
consulta_ingenua(Texto, Filas) :-
    traducir_ingenuo(Texto, Fila, Meta),
    findall(Fila, Meta, Filas).

%!  traducir_ingenuo(+Texto, -Fila:list, -Meta) is det.
%
%   Meta es la traducción del SELECT Texto: cada solución de Meta liga
%   Fila, la lista de los valores de una fila del resultado.
traducir_ingenuo(Texto, Fila, Meta) :-
    analizar(Texto, consulta(Seleccion, [], sin_limite)),
    Seleccion = seleccion(no, Items, Desde, Donde, [], cierto),
    marcos(Desde, Generadores, Marcos),
    filtro(Donde, [Marcos], Filtro),
    proyeccion(Items, Marcos, Fila),
    append(Generadores, [Filtro], Metas),
    conjuncion(Metas, Meta).

%!  filtro(+Condicion, +Pila:list, -Meta) is det.
%
%   Meta es la condición de WHERE con las metas de Prolog: la conjunción,
%   la disyunción y \+. Una igualdad se resuelve al compilar.
filtro(cierto, _, true).
filtro(y(A, B), Pila, Meta) :-
    filtro(A, Pila, MA),
    filtro(B, Pila, MB),
    conjuncion([MA, MB], Meta).
filtro(o(A, B), Pila, (MA ; MB)) :-
    filtro(A, Pila, MA),
    filtro(B, Pila, MB).
filtro(no(A), Pila, \+ MA) :-
    filtro(A, Pila, MA).
filtro(comparar(Op, E1, E2), Pila, Meta) :-
    valor(E1, Pila, V1, Tipo),
    valor(E2, Pila, V2, _),
    (   Op == (=)
    ->  (   V1 = V2
        ->  Meta = true
        ;   Meta = fail
        )
    ;   once(comparacion(Tipo, Op, Predicado)),
        Meta =.. [Predicado, V1, V2]
    ).

%!  valor(+Expresion, +Pila:list, -V, -Tipo) is det.
%
%   El valor y el tipo de una columna o de una constante.
valor(ent(N), _, N, entero).
valor(cad(A), _, A, texto).
valor(columna(C), Pila, V, Tipo) :-
    buscar_columna(columna(C), Pila, col(_, Tipo, _, V), _).
valor(columna(A, C), Pila, V, Tipo) :-
    buscar_columna(columna(A, C), Pila, col(_, Tipo, _, V), _).

%!  comparacion(+Tipo, +Op, -Predicado) is det.
%
%   El predicado de Prolog que compara dos valores de Tipo con Op.
comparacion(entero, <>, =\=).
comparacion(entero, <, <).
comparacion(entero, >, >).
comparacion(entero, <=, =<).
comparacion(entero, >=, >=).
comparacion(texto, <>, \==).
comparacion(texto, <, @<).
comparacion(texto, >, @>).
comparacion(texto, <=, @=<).
comparacion(texto, >=, @>=).

%!  proyeccion(+Items, +Marcos:list, -Fila:list) is det.
%
%   Fila son las variables de las columnas de Items: todas las de los
%   marcos para *, o las nombradas.
proyeccion(todo, Marcos, Fila) :-
    columnas_de(Marcos, Fila).
proyeccion([I|Is], Marcos, Fila) :-
    Items = [I|Is],
    valores_items(Items, Marcos, Fila).

%!  columnas_de(+Marcos:list, -Vs:list) is det.
%
%   Vs son las variables de todas las columnas de Marcos, en orden.
columnas_de([], []).
columnas_de([marco(_, Cs)|Ms], Vs) :-
    variables(Cs, Vs, Resto),
    columnas_de(Ms, Resto).

%!  variables(+Cols:list, -Vs:list, ?Resto:list) is det.
%
%   Vs-Resto son las variables de Cols, como lista diferencia.
variables([], Vs, Vs).
variables([col(_, _, _, V)|Cs], [V|Vs], Resto) :-
    variables(Cs, Vs, Resto).

%!  valores_items(+Items:list, +Marcos:list, -Fila:list) is det.
%
%   Fila son los valores de los ítems item(E, _) de la selección.
valores_items([], _, []).
valores_items([item(E, _)|Is], Marcos, [V|Vs]) :-
    valor(E, [Marcos], V, _),
    valores_items(Is, Marcos, Vs).

%!  conjuncion(+Metas:list, -Meta) is det.
%
%   Meta es la conjunción de Metas, sin los true.
conjuncion(Metas, Meta) :-
    exclude(==(true), Metas, Ms),
    (   Ms = []
    ->  Meta = true
    ;   encadenar(Ms, Meta)
    ).

%!  encadenar(+Metas:list, -Meta) is det.
%
%   Meta es (M1, (M2, …)) para Metas no vacía.
encadenar([M], M) :-
    !.
encadenar([M|Ms], (M, Resto)) :-
    encadenar(Ms, Resto).
