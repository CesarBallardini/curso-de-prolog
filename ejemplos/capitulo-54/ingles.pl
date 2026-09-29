:- encoding(utf8).

% Capítulo 54 - Versión 2: la gramática del inglés.
%
% oracion_en//1 relaciona una oración inglesa con su árbol, que conserva el
% orden del inglés: los adjetivos van antes del nombre.
%
%   o(Sujeto, Verbo)             oración con un verbo intransitivo
%   o(Sujeto, Verbo, Objeto)     oración con un verbo transitivo
%   sn(Art, Adjs, Nombre, Num)   artículo, adjetivos, nombre y número
%   pron(P)                      he, she, it, they
%
% El artículo indefinido es «a» o «an» según la palabra que lo sigue. La
% condición se comprueba al final del sintagma, cuando esa palabra ya se
% conoce en los dos sentidos (sección 53.5).
%
%?- phrase(oracion_en(A), ["the", "black", "cat", "eats", "an", "apple"]).
%?- phrase(oracion_en(o(pron(she), read, sn(a, [old], book, sg))), Ps).

% nombre_en(L, Sg, Pl): el nombre de lema L tiene las formas Sg y Pl.
nombre_en(cat, "cat", "cats").
nombre_en(dog, "dog", "dogs").
nombre_en(book, "book", "books").
nombre_en(house, "house", "houses").
nombre_en(apple, "apple", "apples").

% adjetivo_en(L, F): el adjetivo de lema L se escribe F.
adjetivo_en(black, "black").
adjetivo_en(white, "white").
adjetivo_en(red, "red").
adjetivo_en(old, "old").
adjetivo_en(big, "big").
adjetivo_en(large, "large").

% verbo_en(L, C, Sg, Pl): L es un verbo transitivo o intransitivo (C), y
% Sg y Pl son sus formas del presente con un sujeto de tercera persona.
verbo_en(eat, transitivo, "eats", "eat").
verbo_en(see, transitivo, "sees", "see").
verbo_en(read, transitivo, "reads", "read").
verbo_en(have, transitivo, "has", "have").
verbo_en(sleep, intransitivo, "sleeps", "sleep").
verbo_en(run, intransitivo, "runs", "run").

% articulo_en(A, N, F): F es una forma del artículo A en número N.
articulo_en(the, _, "the").
articulo_en(a, sg, "a").
articulo_en(a, sg, "an").
articulo_en(a, pl, "some").

% pronombre_en(P, N, F): F es el pronombre P, de número N.
pronombre_en(he, sg, "he").
pronombre_en(she, sg, "she").
pronombre_en(it, sg, "it").
pronombre_en(they, pl, "they").

%!  oracion_en(?Arbol)// is nondet.
%
%   Una oración inglesa con su árbol Arbol. El verbo concuerda en número
%   con el sujeto.
oracion_en(o(S, V)) -->
    sujeto_en(S, N),
    verbo_en(V, intransitivo, N).
oracion_en(o(S, V, O)) -->
    sujeto_en(S, N),
    verbo_en(V, transitivo, N),
    sn_en(O, _).

%!  sujeto_en(?S, ?N)// is nondet.
%
%   El sujeto S, de número N: un pronombre o un sintagma nominal.
sujeto_en(pron(P), N) -->
    [F],
    { pronombre_en(P, N, F) }.
sujeto_en(S, N) -->
    sn_en(S, N).

%!  sn_en(?SN, ?N)// is nondet.
%
%   Un sintagma nominal de número N: el artículo, los adjetivos y el
%   nombre. Sin artículo, solo en plural: «apples». Siguiente es la
%   primera palabra después del artículo, y la forma del artículo se
%   comprueba contra ella al final.
sn_en(sn(A, As, L, N), N) -->
    articulo_en(A, N, F),
    adjetivos_en(As, Siguiente, Nombre),
    nombre_en(L, N, Nombre),
    { antes_de(F, Siguiente) }.

%!  articulo_en(?A, ?N, ?F)// is nondet.
%
%   La forma F del artículo A en número N; el artículo sin es la ausencia
%   de artículo, y su forma es la lista vacía.
articulo_en(sin, pl, []) -->
    [].
articulo_en(A, N, F) -->
    [F],
    { articulo_en(A, N, F) }.

%!  antes_de(+Articulo, +Palabra:string) is semidet.
%
%   La forma Articulo puede ir antes de Palabra: «an» antes de una vocal,
%   «a» antes de una consonante, las demás antes de cualquier palabra.
antes_de("an", P) :-
    !,
    empieza_con_vocal(P).
antes_de("a", P) :-
    !,
    \+ empieza_con_vocal(P).
antes_de(_, _).

%!  empieza_con_vocal(+Palabra:string) is semidet.
%
%   Palabra empieza con una vocal.
empieza_con_vocal(P) :-
    sub_string(P, 0, 1, _, Letra),
    sub_string("aeiou", _, 1, _, Letra),
    !.

%!  adjetivos_en(?As:list, ?Primera:string, ?Nombre:string)// is nondet.
%
%   Los adjetivos As. Primera es la primera palabra que escriben, o
%   Nombre, la forma del nombre que los sigue, si As es vacía.
adjetivos_en([], Nombre, Nombre) -->
    [].
adjetivos_en([A|As], F, Nombre) -->
    [F],
    { adjetivo_en(A, F) },
    adjetivos_en(As, _, Nombre).

%!  nombre_en(?L, ?N, ?F)// is nondet.
%
%   La forma F del nombre L en número N.
nombre_en(L, N, F) -->
    [F],
    { nombre_en(L, Singular, Plural),
      numero_en(N, Singular, Plural, F) }.

%!  verbo_en(?L, ?C, ?N)// is nondet.
%
%   La forma del verbo L, de clase C, con un sujeto de número N.
verbo_en(L, C, N) -->
    [F],
    { verbo_en(L, C, Singular, Plural),
      numero_en(N, Singular, Plural, F) }.

% numero_en(N, Sg, Pl, F): F es la forma de número N entre Sg y Pl.
numero_en(sg, Singular, _, Singular).
numero_en(pl, _, Plural, Plural).
