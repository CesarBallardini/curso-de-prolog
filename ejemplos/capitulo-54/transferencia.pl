:- encoding(utf8).

% Capítulo 54 - Versión 3: la transferencia entre los árboles.
%
% transferir/2 relaciona el árbol de una oración castellana (castellano.pl)
% con el de una oración inglesa (ingles.pl). Es una relación entre dos
% términos, sin palabras: cambia los lemas por sus equivalentes, invierte
% el orden de los adjetivos, da un pronombre al sujeto tácito y relaciona
% el plural genérico con el artículo del castellano. Se usa en los dos
% sentidos: con el árbol castellano o con el inglés instanciado.
%
%?- transferir(o(sn(el, gato, sg, [negro, grande]), dormir), En).
%?- transferir(Es, o(pron(she), eat, sn(sin, [red], apple, pl))).

% nombre(Es, En): el nombre castellano Es se traduce por el inglés En.
nombre(gato, cat).
nombre(perro, dog).
nombre(libro, book).
nombre(casa, house).
nombre(manzana, apple).

% adjetivo(Es, En): el adjetivo castellano Es se traduce por el inglés En.
adjetivo(negro, black).
adjetivo(blanco, white).
adjetivo(rojo, red).
adjetivo(viejo, old).
adjetivo(grande, big).
adjetivo(grande, large).

% verbo(Es, En): el verbo castellano Es se traduce por el inglés En.
verbo(comer, eat).
verbo(ver, see).
verbo(leer, read).
verbo(tener, have).
verbo(dormir, sleep).
verbo(correr, run).

% articulo(Es, En): el artículo castellano Es se traduce por el inglés En.
articulo(el, the).
articulo(un, a).
articulo(sin, sin).

%!  transferir(?Es, ?En) is nondet.
%
%   En es un árbol de oración inglesa que traduce el árbol castellano Es.
%   Uno de los dos debe llegar instanciado.
transferir(o(S1, V1), o(S2, V2)) :-
    sujeto(S1, S2),
    verbo(V1, V2).
transferir(o(S1, V1, O1), o(S2, V2, O2)) :-
    sujeto(S1, S2),
    verbo(V1, V2),
    sn(O1, O2).

%!  sujeto(?Es, ?En) is nondet.
%
%   El sujeto inglés En traduce el sujeto castellano Es. El sujeto tácito
%   pasa a un pronombre: en singular, he, she o it. El plural con artículo
%   definido tiene además la lectura genérica, sin artículo en inglés:
%   «los gatos comen» es «the cats eat» o «cats eat».
sujeto(tacito(sg), pron(he)).
sujeto(tacito(sg), pron(she)).
sujeto(tacito(sg), pron(it)).
sujeto(tacito(pl), pron(they)).
sujeto(pron(m, sg), pron(he)).
sujeto(pron(f, sg), pron(she)).
sujeto(pron(m, pl), pron(they)).
sujeto(pron(f, pl), pron(they)).
sujeto(sn(A1, L1, N, As1), sn(A2, As2, L2, N)) :-
    sn(sn(A1, L1, N, As1), sn(A2, As2, L2, N)).
sujeto(sn(el, L1, pl, As1), sn(sin, As2, L2, pl)) :-
    nombre(L1, L2),
    adjetivos(As1, As2).

%!  sn(?Es, ?En) is nondet.
%
%   El sintagma nominal inglés En traduce el castellano Es: mismo número,
%   artículo, nombre y adjetivos equivalentes, los adjetivos en orden
%   inverso.
sn(sn(A1, L1, N, As1), sn(A2, As2, L2, N)) :-
    articulo(A1, A2),
    nombre(L1, L2),
    adjetivos(As1, As2).

%!  adjetivos(?Es:list, ?En:list) is nondet.
%
%   En son los equivalentes de los adjetivos Es, en orden inverso: «un
%   gato negro grande» es «a big black cat». Una de las dos listas debe
%   tener largo conocido; same_length/2 fija el de la otra antes de
%   invertir.
adjetivos(As1, As2) :-
    same_length(As1, As2),
    reverse(As1, Invertidos),
    maplist(adjetivo, Invertidos, As2).

%!  adjetivos_ingenuo(+Es:list, ?En:list) is nondet.
%
%   Como adjetivos/2, sin same_length/2. Con Es libre, reverse/2 da la
%   primera respuesta y, pedida otra, no termina.
adjetivos_ingenuo(As1, As2) :-
    reverse(As1, Invertidos),
    maplist(adjetivo, Invertidos, As2).
