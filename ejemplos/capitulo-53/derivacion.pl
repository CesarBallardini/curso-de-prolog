:- encoding(utf8).

% Capítulo 53 - Versión 6: la derivación y los prefijos.
%
% La derivación forma palabras nuevas. Como dice Covington, la mayor
% parte es irregular y se lista en el léxico, y solo conviene escribir
% como reglas los procesos regulares. Este archivo hace las dos cosas:
%
% - lista los verbos con des- y re- y los nombres en -ción, que pasan a
%   ser entradas del léxico: la versión 4 los flexiona sin cambios, y los
%   verbos heredan la clase y las formas irregulares de su base;
% - escribe como reglas el adverbio en -mente, que agrega el sufijo al
%   femenino del adjetivo, el diminutivo en -ito, -cito, -ecito, cuya
%   ortografía resuelven las reglas de dos niveles, y el prefijo in-,
%   cuya N escribe la regla nasal de la versión 5.
%
% solo-local: carga módulos.
%
%?- derivada(P, adverbio("rápido")).
%?- derivada("lucecita", D).
%?- findall(P, forma(P, verbo("deshacer", preterito, 3, singular)), Ps).

:- use_module(lexico).
:- ensure_loaded(kimmo).

% Palabras nuevas del léxico, para los ejemplos.
lexico:nombre("saco", masculino).
lexico:nombre("lago", masculino).
lexico:adjetivo("rápido", o_a).
lexico:adjetivo("fácil", invariable).
lexico:adjetivo("posible", invariable).
lexico:adjetivo("útil", invariable).

% nombre_de_accion(Nombre, Verbo): el nombre en -ción del Verbo, listado.
nombre_de_accion("elección", "elegir").
nombre_de_accion("protección", "proteger").

lexico:nombre(Nombre, femenino) :-
    nombre_de_accion(Nombre, _).

% prefijo_verbal(Prefijo, Base): el verbo Prefijo+Base existe.
prefijo_verbal("des", "hacer").
prefijo_verbal("des", "proteger").
prefijo_verbal("re", "contar").
prefijo_verbal("re", "elegir").

% Un verbo con prefijo hereda la clase, las formas irregulares y el
% pretérito de raíz propia de su base. clause/2 toma solo los hechos del
% léxico, así que un verbo con prefijo no recibe otro prefijo.
lexico:verbo(Verbo, Clase) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:verbo(Base, Clase), true),
    string_concat(Prefijo, Base, Verbo).
lexico:irregular(Verbo, Tiempo, Persona, Numero, Forma) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:irregular(Base, Tiempo, Persona, Numero, Forma0), true),
    string_concat(Prefijo, Base, Verbo),
    string_concat(Prefijo, Forma0, Forma).
lexico:preterito_fuerte(Verbo, Preterito) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:preterito_fuerte(Base, Preterito0), true),
    string_concat(Prefijo, Base, Verbo),
    string_concat(Prefijo, Preterito0, Preterito).

% admite_in(Adjetivo): el Adjetivo forma su contrario con in-. Otros
% archivos pueden agregar adjetivos.
:- multifile admite_in/1.

admite_in("feliz").
admite_in("posible").
admite_in("útil").

lexico:adjetivo(Adjetivo, Clase) :-
    admite_in(Base),
    clause(lexico:adjetivo(Base, Clase), true),
    con_in(Base, Adjetivo).

%!  con_in(+Base:string, -Adjetivo:string) is det.
%
%   Adjetivo es Base con el prefijo in-: la forma subyacente es i, N, un
%   límite y la de la Base, y la regla nasal escribe la N.
con_in(Base, Adjetivo) :-
    once(raiz(Base, S)),
    append([i, 'N', +], S, S1),
    escribir_regla(S1, Adjetivo).

%!  escribir_regla(+Subyacente:list, -Palabra:string) is det.
%
%   Palabra es la forma escrita de Subyacente según todas las reglas.
escribir_regla(Subyacente, Palabra) :-
    reglas(Rs),
    once(transducir(paralelo(Rs), Subyacente, Letras)),
    string_chars(Palabra, Letras).

%!  derivada(?Palabra:string, ?Derivacion) is nondet.
%
%   Palabra deriva de otra según Derivacion: adverbio(Adjetivo),
%   diminutivo(Nombre), accion(Verbo) o prefijo(Prefijo, Base). Con
%   Palabra ligada la analiza; si no, la genera.
derivada(Palabra, adverbio(Adjetivo)) :-
    (   nonvar(Palabra)
    ->  string_concat(Femenino, "mente", Palabra),
        forma(Femenino, adjetivo(Adjetivo, femenino, singular))
    ;   lexico:adjetivo(Adjetivo, _),
        forma(Femenino, adjetivo(Adjetivo, femenino, singular)),
        string_concat(Femenino, "mente", Palabra)
    ).
derivada(Palabra, diminutivo(Nombre)) :-
    lexico:nombre(Nombre, Genero),
    diminutivo(Nombre, Genero, Palabra0),
    Palabra = Palabra0.
derivada(Palabra, accion(Verbo)) :-
    nombre_de_accion(Palabra, Verbo).
derivada(Palabra, prefijo(Prefijo, Base)) :-
    prefijo_verbal(Prefijo, Base),
    string_concat(Prefijo, Base, Palabra).
derivada(Palabra, prefijo("in", Base)) :-
    admite_in(Base),
    con_in(Base, Palabra).

%!  diminutivo(+Nombre:string, +Genero, -Diminutivo:string) is det.
%
%   Diminutivo es el diminutivo del Nombre, de ese Genero. La raíz pierde
%   la tilde, porque el acento pasa al sufijo, y pierde la vocal final sin
%   tilde; el sufijo es -ito después de esa vocal o de una consonante,
%   -cito después de n, r o una vocal con tilde, y -ecito en una palabra
%   de una sílaba terminada en consonante. Las reglas escriben el resto:
%   luz+ecita es lucecita, sak+ito es saquito.
diminutivo(Nombre, Genero, Diminutivo) :-
    once(raiz(Nombre, S0)),
    maplist(sin_tilde, S0, S),
    string_chars(Nombre, Escritas),
    last(Escritas, Ultima),
    vocal_de_genero(Genero, V),
    sufijo(S, Ultima, V, Raiz, Sufijo),
    append(Raiz, Sufijo, Subyacente),
    escribir_regla(Subyacente, Diminutivo).

%!  sufijo(+S:list, +Ultima, +V, -Raiz:list, -Sufijo:list) is det.
%
%   Raiz y Sufijo forman el diminutivo de la forma subyacente S, sin
%   tildes, cuya última letra escrita es Ultima; V es la vocal del género.
sufijo(S, Ultima, V, Raiz, Sufijo) :-
    last(S, L),
    include(reglas:vocal, S, Vocales),
    length(Vocales, Silabas),
    (   reglas:vocal(Ultima),
        \+ reglas:tilde(_, Ultima)
    ->  once(append(Raiz, [L], S)),
        Sufijo = [i, t, V]
    ;   reglas:vocal(Ultima)
    ->  Raiz = S,
        Sufijo = [z, i, t, V]
    ;   Silabas =:= 1
    ->  Raiz = S,
        Sufijo = [e, z, i, t, V]
    ;   memberchk(L, [n, r])
    ->  Raiz = S,
        Sufijo = [z, i, t, V]
    ;   Raiz = S,
        Sufijo = [i, t, V]
    ).

%!  sin_tilde(+L, -M) is det.
%
%   M es la letra L sin tilde.
sin_tilde(L, M) :-
    (   reglas:tilde(M0, L)
    ->  M = M0
    ;   M = L
    ).

% vocal_de_genero(Genero, V): la vocal final del diminutivo.
vocal_de_genero(masculino, o).
vocal_de_genero(femenino, a).
