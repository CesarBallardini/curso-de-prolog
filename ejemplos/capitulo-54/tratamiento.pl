:- encoding(utf8).

% Capítulo 54 - Versión 7: tú y usted.
%
% El castellano distingue el trato de confianza, tú, del de respeto,
% usted, y el inglés tiene una sola forma, you; Covington cita esta
% diferencia entre las dificultades de la traducción (§8.2.5). Del
% castellano al inglés las dos formas dan you; del inglés al castellano
% hay que elegir, y la elección no está en la oración: es un dato del
% contexto, el Trato, que traducir_con_trato/3 recibe como parámetro.
%
% tú lleva el verbo en segunda persona, que en el vocabulario del capítulo
% es la tercera más una s: come, comes; usted lleva el verbo en tercera
% persona. El número tu marca la segunda persona del singular. you lleva
% el verbo inglés en plural: you eat.
%
% solo-local: carga traductor.pl con ensure_loaded/1.
%
%?- traducir("Tú comes una manzana.", En).
%?- traducir_con_trato(usted, Es, "You read a book.").

:- multifile
    sujeto_es//2,
    numero_verbo/4,
    pronombre_en/3,
    sujeto/2.

:- ensure_loaded(traductor).

% tú y usted como sujetos castellanos; tú también puede omitirse, con la
% cláusula de tacito/1 de castellano.pl y el número tu.
sujeto_es(pron(tu), tu) -->
    ["tú"].
sujeto_es(pron(usted), sg) -->
    ["usted"].

% La segunda persona del singular: la tercera más una s.
numero_verbo(tu, Singular, _, Forma) :-
    string_concat(Singular, "s", Forma).

% you, con el verbo en plural.
pronombre_en(you, pl, "you").

% Los dos tratos, y el sujeto omitido de la segunda persona, son you.
sujeto(tacito(tu), pron(you)).
sujeto(pron(tu), pron(you)).
sujeto(pron(usted), pron(you)).

%!  traducir_con_trato(+Trato, -Es:string, +En:string) is nondet.
%
%   Es traduce al castellano el texto inglés En con el Trato, tu o usted,
%   cuando la oración se dirige a alguien; las demás oraciones se
%   traducen como con traducir/2.
traducir_con_trato(Trato, Es, En) :-
    palabras(En, PalabrasEn),
    phrase(oracion_en(ArbolEn), PalabrasEn),
    transferir(ArbolEs, ArbolEn),
    arg(1, ArbolEs, Sujeto),
    trato(Sujeto, Trato),
    phrase(oracion_es(ArbolEs), PalabrasEs),
    texto(PalabrasEs, Es).

%!  trato(+Sujeto, ?Trato) is semidet.
%
%   El Sujeto castellano corresponde al Trato: tú, omitido o no, al de
%   confianza, usted al de respeto. Cualquier otro sujeto admite los dos.
trato(Sujeto, Trato) :-
    (   trato_de(Sujeto, T)
    ->  Trato = T
    ;   true
    ).

% trato_de(Sujeto, Trato): los sujetos que fijan el trato.
trato_de(tacito(tu), tu).
trato_de(pron(tu), tu).
trato_de(pron(usted), usted).
