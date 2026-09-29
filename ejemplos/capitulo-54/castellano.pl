:- encoding(utf8).

% Capítulo 54 - Versión 2: la gramática del castellano.
%
% oracion_es//1 relaciona una oración castellana, como lista de palabras,
% con su árbol. El árbol conserva el orden del castellano y los rasgos que
% la traducción necesita:
%
%   o(Sujeto, Verbo)             oración con un verbo intransitivo
%   o(Sujeto, Verbo, Objeto)     oración con un verbo transitivo
%   sn(Art, Nombre, Num, Adjs)   artículo, nombre, número y adjetivos
%   pron(Genero, Num)            él, ella, ellos, ellas
%   tacito(Num)                  sujeto omitido: «come manzanas»
%
% Los nombres, los adjetivos y los verbos aparecen por su lema; la forma
% de cada palabra sale de reglas de concordancia de género y número. Cada
% regla consulta el léxico antes de calcular una forma, y así la misma
% gramática sirve para analizar y para generar.
%
%?- phrase(oracion_es(A), ["el", "gato", "negro", "come", "una", "manzana"]).
%?- phrase(oracion_es(o(tacito(pl), dormir)), Ps).

% nombre_es(L, G): L es un nombre de género G.
nombre_es(gato, m).
nombre_es(perro, m).
nombre_es(libro, m).
nombre_es(casa, f).
nombre_es(manzana, f).

% adjetivo_es(L, C): L es un adjetivo; C dice si cambia con el género.
adjetivo_es(negro, variable).
adjetivo_es(blanco, variable).
adjetivo_es(rojo, variable).
adjetivo_es(viejo, variable).
adjetivo_es(grande, invariable).

% verbo_es(L, C, Sg, Pl): L es un verbo transitivo o intransitivo (C), y
% Sg y Pl son sus formas de tercera persona del presente.
verbo_es(comer, transitivo, "come", "comen").
verbo_es(ver, transitivo, "ve", "ven").
verbo_es(leer, transitivo, "lee", "leen").
verbo_es(tener, transitivo, "tiene", "tienen").
verbo_es(dormir, intransitivo, "duerme", "duermen").
verbo_es(correr, intransitivo, "corre", "corren").

% articulo_es(A, G, N, F): F es la forma del artículo A en género G y
% número N.
articulo_es(el, m, sg, "el").
articulo_es(el, f, sg, "la").
articulo_es(el, m, pl, "los").
articulo_es(el, f, pl, "las").
articulo_es(un, m, sg, "un").
articulo_es(un, f, sg, "una").
articulo_es(un, m, pl, "unos").
articulo_es(un, f, pl, "unas").

% pronombre_es(G, N, F): F es el pronombre personal de género G y número N.
pronombre_es(m, sg, "él").
pronombre_es(f, sg, "ella").
pronombre_es(m, pl, "ellos").
pronombre_es(f, pl, "ellas").

%!  oracion_es(?Arbol)// is nondet.
%
%   Una oración castellana con su árbol Arbol. El verbo concuerda en número
%   con el sujeto.
oracion_es(o(S, V)) -->
    sujeto_es(S, N),
    verbo_es(V, intransitivo, N).
oracion_es(o(S, V, O)) -->
    sujeto_es(S, N),
    verbo_es(V, transitivo, N),
    sn_es(O, _).

%!  sujeto_es(?S, ?N)// is nondet.
%
%   El sujeto S, de número N: omitido, un pronombre o un sintagma nominal
%   con artículo; «gatos comen» no es una oración.
sujeto_es(tacito(N), N) -->
    [].
sujeto_es(pron(G, N), N) -->
    [F],
    { pronombre_es(G, N, F) }.
sujeto_es(sn(A, L, N, As), N) -->
    sn_es(sn(A, L, N, As), N),
    { A \== sin }.

%!  sn_es(?SN, ?N)// is nondet.
%
%   Un sintagma nominal de número N: el artículo, el nombre y los
%   adjetivos, que concuerdan en género y número. Sin artículo, solo en
%   plural: «manzanas».
sn_es(sn(A, L, N, As), N) -->
    articulo_es(A, G, N),
    nombre_es(L, G, N),
    adjetivos_es(As, G, N).

%!  articulo_es(?A, ?G, ?N)// is nondet.
%
%   La forma del artículo A en género G y número N; el artículo sin es la
%   ausencia de artículo.
articulo_es(sin, _, pl) -->
    [].
articulo_es(A, G, N) -->
    [F],
    { articulo_es(A, G, N, F) }.

%!  nombre_es(?L, ?G, ?N)// is nondet.
%
%   La forma del nombre L, de género G, en número N.
nombre_es(L, G, N) -->
    [F],
    { nombre_es(L, G),
      atom_string(L, Singular),
      numero_es(N, Singular, F) }.

%!  adjetivos_es(?As:list, ?G, ?N)// is nondet.
%
%   Los adjetivos As, en el orden de la lista, concordados con G y N.
adjetivos_es([], _, _) -->
    [].
adjetivos_es([A|As], G, N) -->
    adjetivo_es(A, G, N),
    adjetivos_es(As, G, N).

%!  adjetivo_es(?L, ?G, ?N)// is nondet.
%
%   La forma del adjetivo L en género G y número N.
adjetivo_es(L, G, N) -->
    [F],
    { adjetivo_es(L, C),
      singular_adjetivo(C, L, G, Singular),
      numero_es(N, Singular, F) }.

%!  singular_adjetivo(+C, +L, ?G, -Singular:string) is det.
%
%   Singular es la forma singular del adjetivo L, de clase C, en género
%   G. Un adjetivo variable cambia la o final del lema por a en femenino.
singular_adjetivo(invariable, L, _, Singular) :-
    atom_string(L, Singular).
singular_adjetivo(variable, L, G, Singular) :-
    sub_atom(L, 0, _, 1, Raiz),
    vocal_de_genero(G, Vocal),
    atomics_to_string([Raiz, Vocal], Singular).

% vocal_de_genero(G, V): V es la vocal final de un adjetivo de género G.
vocal_de_genero(m, o).
vocal_de_genero(f, a).

%!  numero_es(?N, +Singular:string, ?Forma:string) is semidet.
%
%   Forma es Singular en número N. El plural agrega s después de vocal y
%   es después de consonante: «gatos», «mujeres».
numero_es(sg, Singular, Singular).
numero_es(pl, Singular, Plural) :-
    sub_string(Singular, _, 1, 0, Ultima),
    (   sub_string("aeiou", _, 1, _, Ultima)
    ->  string_concat(Singular, "s", Plural)
    ;   string_concat(Singular, "es", Plural)
    ).

%!  verbo_es(?L, ?C, ?N)// is nondet.
%
%   La forma de tercera persona del verbo L, de clase C, en número N.
verbo_es(L, C, N) -->
    [F],
    { verbo_es(L, C, Singular, Plural),
      numero_verbo(N, Singular, Plural, F) }.

% numero_verbo(N, Sg, Pl, F): F es la forma de número N entre Sg y Pl.
numero_verbo(sg, Singular, _, Singular).
numero_verbo(pl, _, Plural, Plural).
