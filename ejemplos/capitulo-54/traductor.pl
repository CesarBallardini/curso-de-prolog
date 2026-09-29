:- encoding(utf8).

% Capítulo 54 - Versión 5: el traductor en los dos sentidos.
%
% Traducir es analizar la oración con la gramática de su lengua, transferir
% el árbol y generar la oración con la gramática de la otra lengua. es_en/2
% y en_es/2 trabajan sobre listas de palabras y analizan siempre primero;
% traducir/2 trabaja sobre textos y elige el sentido según cuál de los dos
% llega instanciado. traducciones/2 reúne las traducciones de un texto
% escrito en cualquiera de las dos lenguas.
%
% solo-local: carga las gramáticas y la transferencia con ensure_loaded/1.
%
%?- traducir("El gato negro come una manzana.", En).
%?- traducir(Es, "The big black dog sees an old house.").
%?- traducciones("Come manzanas.", Ts).

:- ensure_loaded(castellano).
:- ensure_loaded(ingles).
:- ensure_loaded(transferencia).

%!  traducir(+Es:string, ?En:string) is nondet.
%!  traducir(-Es:string, +En:string) is nondet.
%
%   En es una traducción al inglés del texto castellano Es. Cada texto es
%   una oración, con o sin mayúscula inicial y punto final; la traducción
%   lleva los dos.
traducir(Es, En) :-
    (   nonvar(Es)
    ->  palabras(Es, PalabrasEs),
        es_en(PalabrasEs, PalabrasEn),
        texto(PalabrasEn, En)
    ;   palabras(En, PalabrasEn),
        en_es(PalabrasEn, PalabrasEs),
        texto(PalabrasEs, Es)
    ).

%!  traducciones(+Texto:string, -Ts:list(string)) is det.
%
%   Ts son las traducciones distintas de Texto, en el orden en que salen:
%   al inglés si Texto es una oración castellana, al castellano si es una
%   oración inglesa, ninguna si no es ni una ni otra.
traducciones(Texto, Ts) :-
    findall(T, ( traducir(Texto, T) ; traducir(T, Texto) ), Ts0),
    list_to_set(Ts0, Ts).

%!  es_en(+Es:list(string), ?En:list(string)) is nondet.
%
%   En es una traducción al inglés de la oración castellana Es.
es_en(Es, En) :-
    phrase(oracion_es(ArbolEs), Es),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_en(ArbolEn), En).

%!  en_es(+En:list(string), ?Es:list(string)) is nondet.
%
%   Es es una traducción al castellano de la oración inglesa En.
en_es(En, Es) :-
    phrase(oracion_en(ArbolEn), En),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_es(ArbolEs), Es).

%!  traducir_ingenuo(+Es:list(string), ?En:list(string)) is nondet.
%
%   Como es_en/2, y pensado para los dos sentidos. Con Es libre, genera
%   oraciones castellanas una tras otra y no termina cuando la traducción
%   tiene un sujeto con artículo.
traducir_ingenuo(Es, En) :-
    phrase(oracion_es(ArbolEs), Es),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_en(ArbolEn), En).

%!  palabras(+Texto:string, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Texto en minúsculas, sin los blancos ni
%   el punto final.
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    split_string(Minusculas, " ", " .", Partes),
    exclude(==(""), Partes, Palabras).

%!  texto(+Palabras:list(string), -Texto:string) is det.
%
%   Texto es la oración de Palabras separadas por un blanco, con la
%   primera letra en mayúscula y un punto al final.
texto(Palabras, Texto) :-
    atomic_list_concat(Palabras, ' ', Frase),
    sub_atom(Frase, 0, 1, _, Inicial),
    sub_atom(Frase, 1, _, 0, Resto),
    upcase_atom(Inicial, Mayuscula),
    atomic_list_concat([Mayuscula, Resto, '.'], Oracion),
    atom_string(Oracion, Texto).
