:- encoding(utf8).

% Capítulo 53 - Versión 4: las reglas en paralelo, sin construir el
% producto.
%
% paralelo(Rs) es el transductor de las reglas de Rs aplicadas a la vez.
% Su estado es la lista de los estados de cada regla, y cada estado de una
% regla es el conjunto de estados de su autómata contiene(R) en el que
% está la lectura: un par avanza todas las reglas, y la sucesión se
% rechaza en cuanto alguna encuentra un patrón prohibido. No hace falta
% conocer de antemano todos los estados: se visitan solo los que las
% palabras consultadas alcanzan, y el paso de cada regla se tabula.
%
% forma/2 analiza con el inverso del léxico compuesto con las reglas, y
% genera con las reglas solas. raiz/2 obtiene la forma subyacente de una
% palabra sin límites, como el lema, con las reglas y no con escribir/2.
%
% solo-local: carga módulos.
%
%?- forma("camiones", A).
%?- forma(P, verbo("elegir", presente, 1, singular)).
%?- forma("fue", A).
%?- reglas(Rs), transducir(paralelo(Rs), S, [l, u, c, e, s]).
%?- raiz("proteger", S).

:- use_module(dos_niveles).
:- use_module(library(apply)).
:- use_module(library(lists)).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

%!  forma(?Palabra:string, ?Analisis) is nondet.
%
%   Palabra es la forma escrita que describe Analisis. Con Palabra ligada
%   la analiza con el inverso del léxico compuesto con las reglas; si no,
%   Analisis debe llegar ligado y la genera con las reglas.
forma(Palabra, Analisis) :-
    reglas(Rs),
    (   nonvar(Palabra)
    ->  string_chars(Palabra, Letras),
        transducir(inversa(compuesta(lexico, paralelo(Rs))), Letras,
                   Subyacente),
        forma_lexica(Subyacente, Analisis)
    ;   forma_lexica(Subyacente, Analisis),
        transducir(paralelo(Rs), Subyacente, Letras),
        string_chars(Palabra, Letras)
    ).

automatas:alfabeto(paralelo(_), Pares) :-
    findall(P, par(P), Pares0),
    sort(Pares0, Pares).
automatas:inicial(paralelo(Rs), Ds) :-
    maplist(inicial_regla, Rs, Ds).
automatas:final(paralelo(Rs), Ds) :-
    maplist(acepta_regla, Rs, Ds).
automatas:delta(paralelo(Rs), Ds, P, Ds1) :-
    par(P),
    maplist(paso(P), Rs, Ds, Ds1).

%!  inicial_regla(+R, -D:list) is det.
%
%   D es el conjunto de estados de contiene(R) antes de leer un par.
inicial_regla(R, D) :-
    inicial(contiene(R), Q0),
    clausura_conjunto(contiene(R), [Q0], D).

%!  acepta_regla(+R, +D:list) is semidet.
%
%   Ningún estado de D es final en contiene(R): la sucesión leída no
%   tiene un patrón prohibido por R.
acepta_regla(R, D) :-
    \+ ( member(Q, D), final(contiene(R), Q) ).

:- table paso/4.

%!  paso(+P, +R, +D:list, -D1:list) is semidet.
%
%   Leyendo el par P, la regla R pasa del conjunto D al D1, y no encuentra
%   un patrón prohibido en el medio de la palabra. Tabulada: cada paso se
%   calcula una vez.
paso(P, R, D, D1) :-
    mover(contiene(R), P, D, D1),
    \+ memberchk(hallado, D1).

%!  raiz(+Palabra:string, -Subyacente:list) is nondet.
%
%   Subyacente es una forma subyacente sin límites cuya forma escrita es
%   Palabra: la de un lema, como subyacente/2 de la versión 2. La
%   identidad sobre las letras sin el límite + restringe el nivel
%   subyacente antes de las reglas.
raiz(Palabra, Subyacente) :-
    reglas(Rs),
    findall(L, ( par([L]:_), L \== + ), Ls0),
    sort(Ls0, Ls),
    string_chars(Palabra, Letras),
    transducir(inversa(compuesta(identidad(Ls), paralelo(Rs))), Letras,
               Subyacente).
