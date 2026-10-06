:- encoding(utf8).

% Capítulo 86 - Versión 1: el analizador léxico.
%
% Separa el texto de una sentencia en tokens, como el escáner de Toy-Sequel
% de Kluźniak y Szpakowicz: n(Nombre) para una palabra (las palabras clave
% y los nombres de tablas y columnas, en minúsculas, porque SQL no
% distingue mayúsculas en ellos), s(Atomo) para una cadena entre comillas
% simples, i(Entero) para un número, y un átomo para cada símbolo. Los
% blancos y los comentarios de línea («-- …») se descartan.
%
% solo-local: es un módulo que cargan los otros archivos del capítulo.
%
%?- tokens("SELECT nombre FROM alumnos WHERE ingreso >= 2024", Ts).
%?- tokens("WHERE nombre <> 'O''Brien' -- un comentario", Ts).

:- module(lexico,
          [ tokens/2
          ]).

:- use_module(library(dcg/basics)).

%!  tokens(+Texto, -Tokens:list) is det.
%
%   Tokens son los tokens de Texto, una cadena o un átomo. Lanza
%   error(sql(caracter(C)), _) si el texto tiene un carácter C que no
%   empieza ningún token, o una cadena sin cerrar.
tokens(Texto, Tokens) :-
    string_codes(Texto, Codigos),
    phrase(tokens(Tokens), Codigos, Resto),
    (   Resto == []
    ->  true
    ;   Resto = [C|_],
        char_code(Caracter, C),
        throw(error(sql(caracter(Caracter)), _))
    ).

%!  tokens(-Tokens:list)// is det.
%
%   Tokens son los tokens que se reconocen desde el principio del texto,
%   separados por blancos y comentarios. Se detiene en el primer carácter
%   que no empieza un token.
tokens([T|Ts]) -->
    separadores,
    token(T),
    !,
    tokens(Ts).
tokens([]) -->
    separadores.

%!  separadores// is det.
%
%   Blancos y comentarios de línea, en cualquier cantidad.
separadores -->
    blanks,
    (   "--"
    ->  string_without("\n", _),
        separadores
    ;   []
    ).

%!  token(-T)// is semidet.
%
%   T es el token con que empieza el texto. Una palabra empieza con una
%   letra o un guion bajo; un número, con un dígito.
token(n(Nombre)) -->
    csym(Palabra),
    { downcase_atom(Palabra, Nombre) }.
token(i(N)) -->
    digit(D),
    digits(Ds),
    { number_codes(N, [D|Ds]) }.
token(s(Cadena)) -->
    "'",
    cadena(Cs),
    { atom_codes(Cadena, Cs) }.
token(S) -->
    simbolo(S).

%!  cadena(-Codigos:list)// is semidet.
%
%   Codigos son los caracteres de una cadena hasta la comilla que la
%   cierra. Dos comillas seguidas son una comilla dentro de la cadena.
cadena([0''|Cs]) -->
    "''",
    !,
    cadena(Cs).
cadena([]) -->
    "'",
    !.
cadena([C|Cs]) -->
    [C],
    cadena(Cs).

%!  simbolo(-S)// is semidet.
%
%   S es un símbolo de uno o dos caracteres. != es otra forma de <>.
simbolo('<=') --> "<=", !.
simbolo('>=') --> ">=", !.
simbolo('<>') --> "<>", !.
simbolo('<>') --> "!=", !.
simbolo(S) -->
    [C],
    { memberchk(C, `(),.;*+-/=<>`),
      atom_codes(S, [C]) }.
