:- encoding(utf8).

% Capítulo 87 - Las palabras de una pregunta.
%
% palabras/2 separa un texto en palabras: pasa todo a minúsculas, quita
% los signos de interrogación y de exclamación, las comas y el punto, y
% corta en los espacios. Cada palabra es un string, como en los capítulos
% 53 y 54, para conservar las tildes. sin_tildes/2 quita las tildes y la
% diéresis: compara «lógica» con «logica», el nombre que la base guarda.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- palabras("¿Quién cursa Lógica?", Ps).
%?- sin_tildes("análisis", S).

:- module(palabras,
          [ palabras/2,
            sin_tildes/2
          ]).

%!  palabras(+Texto, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Texto, en minúsculas y sin signos de
%   puntuación.
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    split_string(Minusculas, " ", "¿?¡!,.;:", Partes),
    exclude(==(""), Partes, Palabras).

%!  sin_tildes(+Palabra:string, -Simple:string) is det.
%
%   Simple es Palabra sin tildes ni diéresis.
sin_tildes(Palabra, Simple) :-
    string_chars(Palabra, Letras),
    maplist(letra_simple, Letras, Simples),
    string_chars(Simple, Simples).

%!  letra_simple(+Letra, -Simple) is det.
%
%   Simple es Letra sin tilde; las demás letras quedan iguales.
letra_simple(Letra, Simple) :-
    (   con_tilde(Letra, Simple0)
    ->  Simple = Simple0
    ;   Simple = Letra
    ).

% con_tilde(Letra, Simple): Letra lleva tilde o diéresis, y Simple no.
con_tilde('á', a).
con_tilde('é', e).
con_tilde('í', i).
con_tilde('ó', o).
con_tilde('ú', u).
con_tilde('ü', u).
