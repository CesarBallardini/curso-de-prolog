:- encoding(utf8).

% Capítulo 54 - Soluciones de los ejercicios.
%
% Carga el traductor completo. Los ejercicios 2, 3, 4, 9 y 12 agregan
% cláusulas a predicados de castellano.pl, ingles.pl y transferencia.pl:
% por eso esos predicados se declaran multifile antes de cargarlos.
%
% solo-local: carga traductor.pl con ensure_loaded/1.
%
%?- traducciones("La mujer vieja lee un libro azul.", Ts).
%?- traducciones("El gato no come manzanas.", Ts).

:- multifile
    nombre_es/2,
    adjetivo_es/2,
    verbo_es/4,
    nombre_en/3,
    adjetivo_en/2,
    verbo_en/4,
    nombre/2,
    adjetivo/2,
    verbo/2,
    oracion_es//1,
    oracion_en//1,
    sujeto_es//2,
    sujeto_en//2,
    sn_es//2,
    sn_en//2,
    transferir/2,
    sujeto/2,
    sn/2.

:- ensure_loaded(traductor).

% Ejercicio 2: palabras nuevas; ninguna regla cambia.
nombre_es(mujer, f).
nombre_en(woman, "woman", "women").
nombre(mujer, woman).
adjetivo_es(azul, invariable).
adjetivo_en(blue, "blue").
adjetivo(azul, blue).
verbo_es(mirar, transitivo, "mira", "miran").
verbo_en(watch, transitivo, "watches", "watch").
verbo(mirar, watch).

% Ejercicio 3: «cat» traduce también un nombre femenino.
nombre_es(gata, f).
nombre(gata, cat).

% Ejercicio 4: la negación.

%!  oracion_es(?Arbol)// is nondet.
%
%   La oración negada: «no» antes del verbo.
oracion_es(neg(o(S, V))) -->
    sujeto_es(S, N),
    ["no"],
    verbo_es(V, intransitivo, N).
oracion_es(neg(o(S, V, O))) -->
    sujeto_es(S, N),
    ["no"],
    verbo_es(V, transitivo, N),
    sn_es(O, _).

%!  oracion_en(?Arbol)// is nondet.
%
%   La oración negada: el auxiliar do concuerda con el sujeto, y el verbo
%   va en su forma base, que es la del plural.
oracion_en(neg(o(S, V))) -->
    sujeto_en(S, N),
    auxiliar(N),
    ["not"],
    verbo_en(V, intransitivo, pl).
oracion_en(neg(o(S, V, O))) -->
    sujeto_en(S, N),
    auxiliar(N),
    ["not"],
    verbo_en(V, transitivo, pl),
    sn_en(O, _).

%!  auxiliar(?N)// is det.
%
%   La forma del auxiliar do con un sujeto de número N.
auxiliar(sg) -->
    ["does"].
auxiliar(pl) -->
    ["do"].

%!  transferir(?Es, ?En) is nondet.
%
%   Una oración negada se traduce por la negación de su traducción.
transferir(neg(A), neg(B)) :-
    transferir(A, B).

% Ejercicio 5: restricciones de selección.

% animado(L): el nombre castellano L designa un ser animado.
animado(gato).
animado(gata).
animado(perro).
animado(mujer).

% pide_animado(V): el sujeto del verbo V tiene que ser animado.
pide_animado(comer).
pide_animado(ver).
pide_animado(leer).
pide_animado(mirar).
pide_animado(dormir).
pide_animado(correr).

%!  sensata(+Arbol) is semidet.
%
%   El árbol castellano Arbol respeta las restricciones de selección: si
%   el verbo pide un sujeto animado, un sujeto nominal lo es.
sensata(neg(A)) :-
    sensata(A).
sensata(o(S, V)) :-
    sujeto_posible(S, V).
sensata(o(S, V, _)) :-
    sujeto_posible(S, V).

%!  sujeto_posible(+S, +V) is semidet.
%
%   El sujeto S puede acompañar al verbo V. Un pronombre o un sujeto
%   tácito siempre puede.
sujeto_posible(sn(_, L, _, _), V) :-
    (   pide_animado(V)
    ->  animado(L)
    ;   true
    ).
sujeto_posible(y(A, B), V) :-
    sujeto_posible(A, V),
    sujeto_posible(B, V).
sujeto_posible(pron(_, _), _).
sujeto_posible(tacito(_), _).

%!  traducir_sensato(+Es:string, -En:string) is nondet.
%
%   Como traducir/2 al inglés, solo para las oraciones sensatas.
traducir_sensato(Es, En) :-
    palabras(Es, PalabrasEs),
    phrase(oracion_es(A), PalabrasEs),
    sensata(A),
    transferir(A, B),
    phrase(oracion_en(B), PalabrasEn),
    texto(PalabrasEn, En).

% Ejercicio 8: generar por largo creciente.

%!  al_castellano_por_largo(+En:list(string), -Es:list(string)) is nondet.
%
%   Es es una traducción de En, buscada entre las oraciones castellanas
%   de largo 0, 1, 2… Encuentra todas las traducciones, pero no termina
%   después de la última.
al_castellano_por_largo(En, Es) :-
    length(Es, _),
    traducir_ingenuo(Es, En).

% Ejercicio 9: sujetos coordinados.

%!  sujeto_es(?S, ?N)// is nondet.
%
%   Dos sintagmas con artículo unidos por «y»: el sujeto es plural.
sujeto_es(y(A, B), pl) -->
    sn_es(A, _),
    ["y"],
    sn_es(B, _),
    { A = sn(Art1, _, _, _),
      B = sn(Art2, _, _, _),
      Art1 \== sin,
      Art2 \== sin }.

%!  sujeto_en(?S, ?N)// is nondet.
%
%   Dos sintagmas unidos por «and»: el sujeto es plural.
sujeto_en(y(A, B), pl) -->
    sn_en(A, _),
    ["and"],
    sn_en(B, _).

%!  sujeto(?Es, ?En) is nondet.
%
%   Un sujeto coordinado se traduce miembro a miembro.
sujeto(y(A1, B1), y(A2, B2)) :-
    sujeto(A1, A2),
    sujeto(B1, B2).

% Ejercicio 10: inferencias de cada sentido.

%!  inferencias(:Meta, -N:integer) is semidet.
%
%   N es la cantidad de inferencias que usa la primera solución de Meta.
%   Meta se ejecuta dos veces y se mide la segunda: la primera carga las
%   bibliotecas que usa por primera vez, y esa carga también se contaría.
%   La doble negación deshace las ligaduras de la primera ejecución.
inferencias(Meta, N) :-
    \+ \+ once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I),
    N is I - I0.

% Ejercicio 11: una interlingua.

%!  interlingua_es(?Arbol, ?I) is nondet.
%
%   I es la representación común del árbol castellano Arbol: un evento
%   con la acción, el agente y el paciente. Los conceptos se nombran con
%   los lemas castellanos; los adjetivos, en el orden del castellano.
interlingua_es(o(S, V), evento(V, I)) :-
    agente_es(S, I).
interlingua_es(o(S, V, O), evento(V, I, J)) :-
    agente_es(S, I),
    entidad_es(O, J).

%!  agente_es(?S, ?I) is nondet.
%
%   I representa al sujeto castellano S. El sujeto tácito deja el género
%   sin determinar; el plural con artículo definido puede ser genérico.
agente_es(tacito(N), persona(_, N)).
agente_es(pron(G, N), persona(G, N)).
agente_es(S, I) :-
    entidad_es(S, I).
agente_es(sn(el, L, pl, As), ent(generico, L, pl, As)).

%!  entidad_es(?SN, ?I) is nondet.
%
%   I representa al sintagma nominal castellano SN.
entidad_es(sn(A, L, N, As), ent(D, L, N, As)) :-
    determinacion(A, D).

% determinacion(A, D): el artículo castellano A expresa la determinación D.
determinacion(el, definido).
determinacion(un, indefinido).
determinacion(sin, ninguna).

%!  interlingua_en(?Arbol, ?I) is nondet.
%
%   I es la representación común del árbol inglés Arbol.
interlingua_en(o(S, V), evento(C, I)) :-
    verbo(C, V),
    agente_en(S, I).
interlingua_en(o(S, V, O), evento(C, I, J)) :-
    verbo(C, V),
    agente_en(S, I),
    entidad_en(O, J).

%!  agente_en(?S, ?I) is nondet.
%
%   I representa al sujeto inglés S; it es la persona de género neutro.
agente_en(pron(he), persona(m, sg)).
agente_en(pron(she), persona(f, sg)).
agente_en(pron(it), persona(n, sg)).
agente_en(pron(they), persona(_, pl)).
agente_en(sn(sin, As, L, pl), ent(generico, C, pl, Ps)) :-
    nombre(C, L),
    adjetivos(Ps, As).
agente_en(sn(A, As, L, N), I) :-
    A \== sin,
    entidad_en(sn(A, As, L, N), I).

%!  entidad_en(?SN, ?I) is nondet.
%
%   I representa al sintagma nominal inglés SN; los adjetivos se invierten
%   con adjetivos/2 de transferencia.pl.
entidad_en(sn(A, As, L, N), ent(D, C, N, Ps)) :-
    determinacion_en(A, D),
    nombre(C, L),
    adjetivos(Ps, As).

% determinacion_en(A, D): el artículo inglés A expresa la determinación D.
determinacion_en(the, definido).
determinacion_en(a, indefinido).
determinacion_en(sin, ninguna).

%!  es_en_interlingua(+Es:list(string), ?En:list(string)) is nondet.
%
%   Como es_en/2, con la interlingua en lugar de la transferencia.
es_en_interlingua(Es, En) :-
    phrase(oracion_es(A), Es),
    interlingua_es(A, I),
    interlingua_en(B, I),
    phrase(oracion_en(B), En).

% Ejercicio 12: el complemento de posesión.

%!  sn_es(?SN, ?N)// is nondet.
%
%   Un sintagma con artículo definido y un complemento con de: «el libro
%   del gato». El poseedor lleva artículo definido.
sn_es(de(sn(el, L, N, As), P), N) -->
    sn_es(sn(el, L, N, As), N),
    poseedor_es(P).

%!  poseedor_es(?P)// is nondet.
%
%   El complemento «de» con un sintagma definido; de el se contrae en del.
poseedor_es(sn(el, L, N, As)) -->
    de_articulo(G, N),
    nombre_es(L, G, N),
    adjetivos_es(As, G, N).

%!  de_articulo(?G, ?N)// is nondet.
%
%   La preposición de con el artículo definido de género G y número N.
de_articulo(m, sg) -->
    ["del"].
de_articulo(G, N) -->
    ["de"],
    [F],
    { articulo_es(el, G, N, F),
      F \== "el" }.

%!  sn_en(?SN, ?N)// is nondet.
%
%   Un sintagma cuyo determinante es un poseedor: «the cat's black book».
sn_en(gen(P, As, L, N), N) -->
    poseedor_en(P),
    adjetivos_en(As, _, Nombre),
    nombre_en(L, N, Nombre).

%!  poseedor_en(?P)// is nondet.
%
%   Un sintagma definido con la marca de posesión en el nombre.
poseedor_en(sn(the, As, L, N)) -->
    ["the"],
    adjetivos_en(As, _, Marcado),
    [Marcado],
    { nombre_en(L, Singular, Plural),
      posesivo(N, Singular, Plural, Marcado) }.

%!  posesivo(?N, +Sg:string, +Pl:string, ?Marcado:string) is semidet.
%
%   Marcado es la forma posesiva, en número N, del nombre de formas Sg y
%   Pl: 's, o solo el apóstrofo después de la s de un plural regular.
posesivo(sg, Singular, _, Marcado) :-
    string_concat(Singular, "'s", Marcado).
posesivo(pl, _, Plural, Marcado) :-
    (   string_concat(_, "s", Plural)
    ->  string_concat(Plural, "'", Marcado)
    ;   string_concat(Plural, "'s", Marcado)
    ).

%!  sn(?Es, ?En) is nondet.
%
%   «el libro del gato» es «the cat's book»: el poseedor ocupa el lugar
%   del artículo.
sn(de(sn(el, L1, N, As1), P1), gen(P2, As2, L2, N)) :-
    nombre(L1, L2),
    adjetivos(As1, As2),
    sn(P1, P2).
