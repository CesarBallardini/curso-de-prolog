:- encoding(utf8).

% Capítulo 51 - Versión 6: un analizador léxico hecho con expresiones
% regulares.
%
% Cada clase de componente léxico se define con una expresión regular, en
% una tabla ordenada. El analizador lee el texto de izquierda a derecha y,
% en cada posición, aplica la regla de la coincidencia más larga: toma el
% prefijo más largo que alguna expresión acepta, y si dos expresiones
% aceptan el mismo prefijo, la que figura primero en la tabla. El
% prefijo más largo se busca recorriendo el determinista de la expresión
% hasta que queda en el conjunto vacío, y recordando el último punto en
% el que pasó por un estado final.
%
% La tabla describe los componentes de Mini, el lenguaje del capítulo 45,
% y produce la misma lista de componentes que lexico/2 de ese capítulo.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- componentes("mientras x <= 10 hacer x := x + 1 fin", Cs).
%?- componentes("sino siguiente", Cs).
%?- string_chars("12a", W), prefijo_mas_largo(er("[0-9]+"), W, N).

:- module(lexico,
          [ regla/2,
            componentes/2,
            prefijo_mas_largo/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(expresiones).

:- multifile regla/2, componente/4.

% regla(Clase, Expresion): los componentes de la Clase son las palabras
% de la expresión regular. El orden decide entre dos reglas que aceptan
% el mismo prefijo. Otros archivos pueden agregar clases con cláusulas
% lexico:regla/2 y lexico:componente/4, que quedan al final de la tabla.
regla(blanco, "[ \t\n]+").
regla(reservada, "si|entonces|sino|fin|mientras|hacer|escribir").
regla(numero, "[0-9]+").
regla(identificador, "[a-zA-Z_][a-zA-Z0-9_]*").
regla(simbolo, ":=|<=|>=|<>|[-+*/=<>();]").

%!  componentes(+Texto, -Cs:list) is det.
%
%   Cs es la lista de componentes léxicos de Texto, un string o un átomo,
%   sin los blancos: num(N) para un número, id(X) para un identificador,
%   y el átomo mismo para una palabra reservada o un símbolo. Produce un
%   error de sintaxis en el primer carácter con el que no empieza ningún
%   componente.
componentes(Texto, Cs) :-
    atom_chars(Texto, Caracteres),
    leer(Caracteres, Cs).

%!  leer(+Caracteres:list, -Cs:list) is det.
%
%   Cs son los componentes de la lista de Caracteres.
leer([], []).
leer([C|Resto0], Cs) :-
    findall(N-Clase,
            ( regla(Clase, Expresion),
              prefijo_mas_largo(er(Expresion), [C|Resto0], N) ),
            Candidatos),
    mejor(Candidatos, 0-ninguna, N-Clase),
    (   N =:= 0
    ->  atom_chars(Resto, [C|Resto0]),
        syntax_error(componente_desconocido(Resto))
    ;   length(Lexema, N),
        append(Lexema, Resto, [C|Resto0]),
        componente(Clase, Lexema, Cs, Cs1),
        leer(Resto, Cs1)
    ).

%!  mejor(+Candidatos:list(pair), +Mejor0:pair, -Mejor:pair) is det.
%
%   Mejor es el primer par N-Clase de Candidatos con el mayor N, o
%   Mejor0 si ninguno lo supera.
mejor([], Mejor, Mejor).
mejor([N-Clase|Candidatos], N0-Clase0, Mejor) :-
    (   N > N0
    ->  mejor(Candidatos, N-Clase, Mejor)
    ;   mejor(Candidatos, N0-Clase0, Mejor)
    ).

%!  componente(+Clase, +Lexema:list, -Cs:list, ?Cs1:list) is det.
%
%   Cs es Cs1 con el componente de Clase cuyo texto es Lexema delante; un
%   blanco no agrega nada.
componente(blanco, _, Cs, Cs).
componente(reservada, Lexema, [A|Cs], Cs) :-
    atom_chars(A, Lexema).
componente(numero, Lexema, [num(N)|Cs], Cs) :-
    number_chars(N, Lexema).
componente(identificador, Lexema, [id(A)|Cs], Cs) :-
    atom_chars(A, Lexema).
componente(simbolo, Lexema, [A|Cs], Cs) :-
    atom_chars(A, Lexema).

%!  prefijo_mas_largo(+M, +W:list, -N:integer) is det.
%
%   N es la longitud del prefijo más largo de W que acepta el autómata M,
%   o 0 si no acepta ninguno, ni la palabra vacía. Avanza por W con los
%   conjuntos de estados de M hasta llegar al conjunto vacío.
prefijo_mas_largo(M, W, N) :-
    inicial(M, Q0),
    clausura_conjunto(M, [Q0], D0),
    avanzar(M, W, D0, 0, 0, N).

%!  avanzar(+M, +W:list, +D:list, +I:integer, +N0:integer, -N:integer)
%!      is det.
%
%   Con el conjunto de estados D después de leer I símbolos, N es la
%   longitud del prefijo más largo aceptado: I si D tiene un estado final,
%   o el último encontrado, N0.
avanzar(M, W, D, I, N0, N) :-
    (   member(Q, D),
        final(M, Q)
    ->  N1 = I
    ;   N1 = N0
    ),
    (   D \== [],
        W = [S|W1]
    ->  mover(M, S, D, D1),
        I1 is I + 1,
        avanzar(M, W1, D1, I1, N1, N)
    ;   N = N1
    ).
