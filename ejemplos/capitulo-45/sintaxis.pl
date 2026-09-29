:- encoding(utf8).

% Capítulo 45 - Versión 1: el análisis léxico y sintáctico de Mini.
%
% Mini es un lenguaje imperativo pequeño: asignaciones, si, mientras y
% escribir, con expresiones enteras. lexico/2 convierte el texto en una
% lista de componentes léxicos con una gramática sobre códigos de
% caracteres; programa//1 convierte esa lista en la sintaxis abstracta,
% con otra gramática sobre los componentes. analizar/2 hace las dos cosas.
%
% La sintaxis abstracta es una representación limpia: cada clase de nodo
% tiene su functor.
%   programa, bloque   lista de sentencias
%   sentencia          asignar(X, E), si(C, Si, No), mientras(C, Cuerpo),
%                      escribir(E); Si, No y Cuerpo son bloques
%   condición          rel(Op, A, B), Op en =, <>, <, >, <=, >=
%   expresión          num(N), id(X), bin(Op, A, B), Op en +, -, *, /
%
%?- lexico("x := x + 1", Ts).
%?- analizar("x := 2 * (y + 1); escribir x", P).
%?- programa_ejemplo(factorial, P).

%!  analizar(+Texto, -Programa:list) is semidet.
%
%   Programa es la sintaxis abstracta del programa Mini escrito en Texto,
%   un átomo, una cadena o una lista de códigos. Falla si el texto no es un
%   programa Mini.
analizar(Texto, Programa) :-
    lexico(Texto, Componentes),
    phrase(programa(Programa), Componentes),
    !.

%!  lexico(+Texto, -Componentes:list) is semidet.
%
%   Componentes es la lista de componentes léxicos de Texto: num(N) para un
%   número, id(X) para un identificador, y el átomo mismo para una palabra
%   reservada o un símbolo. Falla si Texto tiene un carácter que no
%   pertenece a ningún componente.
lexico(Texto, Componentes) :-
    string_codes(Texto, Codigos),
    phrase(componentes(Componentes), Codigos).

%!  componentes(-Componentes:list)// is semidet.
%
%   Los componentes léxicos de la lista de códigos, separados por blancos.
componentes(Cs) -->
    blancos,
    componentes_(Cs).

componentes_([C|Cs]) -->
    componente(C),
    !,
    componentes(Cs).
componentes_([]) -->
    [].

%!  componente(-C)// is semidet.
%
%   Un componente léxico, el más largo que empieza en la posición actual.
componente(num(N)) -->
    digito(D),
    !,
    digitos(Ds),
    { number_codes(N, [D|Ds]) }.
componente(C) -->
    [L],
    { code_type(L, csymf) },
    !,
    alfanumericos(Ls),
    { atom_codes(A, [L|Ls]),
      palabra(A, C) }.
componente(S) -->
    simbolo(S).

%!  palabra(+A:atom, -C) is det.
%
%   C es el componente de la palabra A: A misma si es reservada, id(A) si
%   no lo es.
palabra(A, C) :-
    (   reservada(A)
    ->  C = A
    ;   C = id(A)
    ).

% reservada(P): P es una palabra reservada de Mini.
reservada(si).
reservada(entonces).
reservada(sino).
reservada(fin).
reservada(mientras).
reservada(hacer).
reservada(escribir).

% simbolo(S): los símbolos de Mini; los de dos caracteres, primero.
simbolo(:=) --> ":=".
simbolo(<=) --> "<=".
simbolo(>=) --> ">=".
simbolo(<>) --> "<>".
simbolo(+) --> "+".
simbolo(-) --> "-".
simbolo(*) --> "*".
simbolo(/) --> "/".
simbolo(=) --> "=".
simbolo(<) --> "<".
simbolo(>) --> ">".
simbolo('(') --> "(".
simbolo(')') --> ")".
simbolo(;) --> ";".

%!  blancos// is det.
%
%   Consume los espacios, tabuladores y fines de línea que siguen.
blancos -->
    [C],
    { code_type(C, space) },
    !,
    blancos.
blancos -->
    [].

%!  digito(-D:integer)// is semidet.
%
%   Un código de dígito decimal.
digito(D) -->
    [D],
    { code_type(D, digit) }.

%!  digitos(-Ds:list)// is det.
%
%   Todos los dígitos que siguen.
digitos([D|Ds]) -->
    digito(D),
    !,
    digitos(Ds).
digitos([]) -->
    [].

%!  alfanumericos(-Cs:list)// is det.
%
%   Todas las letras, dígitos y guiones bajos que siguen.
alfanumericos([C|Cs]) -->
    [C],
    { code_type(C, csym) },
    !,
    alfanumericos(Cs).
alfanumericos([]) -->
    [].

%!  programa(?Programa:list)// is nondet.
%
%   Un programa es un bloque: una lista de sentencias separadas por punto y
%   coma, posiblemente vacía.
programa(Ss) -->
    bloque(Ss).

%!  bloque(?Ss:list)// is nondet.
%
%   Una lista de sentencias separadas por punto y coma. Primero se intenta
%   leer una sentencia; el bloque vacío es la última alternativa.
bloque([S|Ss]) -->
    sentencia(S),
    resto_bloque(Ss).
bloque([]) -->
    [].

resto_bloque(Ss) -->
    [;],
    bloque(Ss).
resto_bloque([]) -->
    [].

%!  sentencia(?S)// is nondet.
%
%   Una sentencia: asignación, si con o sin sino, mientras o escribir.
sentencia(asignar(X, E)) -->
    [id(X), :=],
    expresion(E).
sentencia(si(C, Si, No)) -->
    [si],
    condicion(C),
    [entonces],
    bloque(Si),
    rama_sino(No),
    [fin].
sentencia(mientras(C, Cuerpo)) -->
    [mientras],
    condicion(C),
    [hacer],
    bloque(Cuerpo),
    [fin].
sentencia(escribir(E)) -->
    [escribir],
    expresion(E).

rama_sino(No) -->
    [sino],
    bloque(No).
rama_sino([]) -->
    [].

%!  condicion(?C)// is nondet.
%
%   Una comparación entre dos expresiones.
condicion(rel(Op, A, B)) -->
    expresion(A),
    [Op],
    { relacion(Op) },
    expresion(B).

% relacion(Op): Op es un operador de comparación de Mini.
relacion(=).
relacion(<>).
relacion(<).
relacion(>).
relacion(<=).
relacion(>=).

%!  expresion(?E)// is nondet.
%
%   Una suma o resta de términos, agrupada a la izquierda: el primer
%   término es el acumulador, y cada operador lo combina con el siguiente.
expresion(E) -->
    termino(T),
    mas_terminos(T, E).

mas_terminos(Ac, E) -->
    [Op],
    { memberchk(Op, [+, -]) },
    termino(T),
    mas_terminos(bin(Op, Ac, T), E).
mas_terminos(E, E) -->
    [].

%!  termino(?T)// is nondet.
%
%   Un producto o cociente de factores, agrupado a la izquierda.
termino(T) -->
    factor(F),
    mas_factores(F, T).

mas_factores(Ac, T) -->
    [Op],
    { memberchk(Op, [*, /]) },
    factor(F),
    mas_factores(bin(Op, Ac, F), T).
mas_factores(T, T) -->
    [].

%!  factor(?F)// is nondet.
%
%   Un número, un identificador o una expresión entre paréntesis.
factor(num(N)) -->
    [num(N)].
factor(id(X)) -->
    [id(X)].
factor(E) -->
    ['('],
    expresion(E),
    [')'].

%!  programa_ejemplo(?Nombre, -Programa:list) is nondet.
%
%   Programa es la sintaxis abstracta del programa de ejemplo Nombre.
programa_ejemplo(Nombre, Programa) :-
    fuente_ejemplo(Nombre, Texto),
    analizar(Texto, Programa).

%!  fuente_ejemplo(?Nombre, -Texto:atom) is nondet.
%
%   Texto es el programa de ejemplo Nombre, con sus renglones separados
%   por fines de línea.
fuente_ejemplo(Nombre, Texto) :-
    fuente(Nombre, Lineas),
    atomic_list_concat(Lineas, '\n', Texto).

% fuente(Nombre, Lineas): el texto de un programa de ejemplo, por líneas.
fuente(factorial, [ "n := 5;",
                    "f := 1;",
                    "mientras n > 0 hacer",
                    "  f := f * n;",
                    "  n := n - 1",
                    "fin;",
                    "escribir f" ]).
fuente(mcd, [ "a := 84; b := 36;",
              "mientras a <> b hacer",
              "  si a > b entonces a := a - b",
              "  sino b := b - a fin",
              "fin;",
              "escribir a" ]).
fuente(cuenta, [ "n := 3;",
                 "si n > 0 entonces",
                 "  mientras n > 0 hacer",
                 "    escribir n;",
                 "    n := n - 1",
                 "  fin",
                 "fin" ]).
fuente(suma, [ "n := 1000; s := 0;",
               "mientras n > 0 hacer",
               "  s := s + n;",
               "  n := n - 1",
               "fin;",
               "escribir s" ]).
