# El analizador léxico

Esta página contiene el código de la
[sección 86.3](index.md#863-version-1-el-analizador-lexico) del
[capítulo 86](index.md): `tokens/2` y los no terminales que reconocen
cada clase de token. El código está en `lexico.pl`, en
`ejemplos/capitulo-86/`, con sus pruebas.

## El analizador léxico

`tokens/2` analiza el texto entero con `phrase/3` y deja en el resto lo
que no se pudo reconocer: si el resto no está vacío, su primer carácter
no empieza ningún token, y el error lo nombra. Cada clase de token tiene
su cláusula de `token//1`: una palabra empieza con una letra o un guion
bajo, un número con un dígito, una cadena con una comilla, y lo demás es
un símbolo de uno o dos caracteres.

<!-- ejemplo: capitulo-86/lexico.pl predicado: tokens/2 token//1 cadena//1 simbolo//1 -->
```prolog
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
```
