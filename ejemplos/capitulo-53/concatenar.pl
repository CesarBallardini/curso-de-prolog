:- encoding(utf8).

% Capítulo 53 - Versión 1: raíz más terminación.
%
% Una forma es la concatenación de una raíz y una terminación. partes/3
% relaciona el análisis de una palabra con esas dos partes, y forma/2 las
% une para generar o las separa para analizar: string_concat/3 con la
% palabra ligada da cada manera de cortarla, y la raíz se busca en el
% léxico. Los análisis son términos:
%
%   nombre(Lema, Genero, Numero)
%   adjetivo(Lema, Genero, Numero)
%   verbo(Lema, Tiempo, Persona, Numero)
%
% Ninguna letra cambia al unir las partes: es lo que falla en «tocé»,
% «lápizes», «camiónes» y «conto».
%
% solo-local: carga el módulo lexico.
%
%?- forma(P, verbo("hablar", preterito, 3, singular)).
%?- forma("comemos", A).
%?- forma(P, verbo("tocar", preterito, 1, singular)).

:- use_module(lexico).

%!  forma(?Palabra:string, ?Analisis) is nondet.
%
%   Palabra es la forma que describe Analisis. Con Palabra ligada la
%   analiza; si no, Analisis debe llegar ligado y la genera.
forma(Palabra, Analisis) :-
    (   nonvar(Palabra)
    ->  string_concat(Raiz, Terminacion, Palabra),
        partes(Analisis, Raiz, Terminacion)
    ;   partes(Analisis, Raiz, Terminacion),
        string_concat(Raiz, Terminacion, Palabra)
    ).

%!  partes(?Analisis, ?Raiz:string, ?Terminacion:string) is nondet.
%
%   La palabra que describe Analisis es Raiz seguida de Terminacion. Debe
%   llegar ligado Analisis, o Raiz y Terminacion.
partes(nombre(Lema, Genero, singular), Lema, "") :-
    nombre(Lema, Genero).
partes(nombre(Lema, Genero, plural), Lema, T) :-
    nombre(Lema, Genero),
    plural(Lema, T).
partes(adjetivo(Lema, Genero, singular), Lema, "") :-
    adjetivo(Lema, invariable),
    genero(Genero).
partes(adjetivo(Lema, Genero, plural), Lema, T) :-
    adjetivo(Lema, invariable),
    genero(Genero),
    plural(Lema, T).
partes(adjetivo(Lema, Genero, Numero), Raiz, T) :-
    terminacion_genero(Clase, Genero, Numero, T),
    raiz_adjetivo(Clase, Lema, Raiz),
    adjetivo(Lema, Clase).
partes(verbo(Lema, Tiempo, Persona, Numero), Raiz, T) :-
    terminacion(Conj, Tiempo, Persona, Numero, T),
    infinitivo(Conj, Inf),
    string_concat(Raiz, Inf, Lema),
    verbo(Lema, _).

%!  plural(+Palabra:string, -T:string) is det.
%
%   T es la terminación del plural de Palabra: s después de una vocal, es
%   después de una consonante.
plural(Palabra, T) :-
    (   sub_string(Palabra, _, 1, 0, Ultima),
        sub_string("aeiouáéíóú", _, 1, _, Ultima)
    ->  T = "s"
    ;   T = "es"
    ).

%!  raiz_adjetivo(+Clase, ?Lema:string, ?Raiz:string) is semidet.
%
%   Raiz es la raíz a la que un adjetivo de la Clase agrega las
%   terminaciones de género: sin la o final, o el lema entero.
raiz_adjetivo(o_a, Lema, Raiz) :-
    string_concat(Raiz, "o", Lema).
raiz_adjetivo(agrega_a, Lema, Lema).

% genero(G): G es un género.
genero(masculino).
genero(femenino).

% terminacion_genero(Clase, Genero, Numero, T): la terminación de un
% adjetivo que distingue el género.
terminacion_genero(o_a, masculino, singular, "o").
terminacion_genero(o_a, femenino, singular, "a").
terminacion_genero(o_a, masculino, plural, "os").
terminacion_genero(o_a, femenino, plural, "as").
terminacion_genero(agrega_a, masculino, singular, "").
terminacion_genero(agrega_a, femenino, singular, "a").
terminacion_genero(agrega_a, masculino, plural, "es").
terminacion_genero(agrega_a, femenino, plural, "as").
