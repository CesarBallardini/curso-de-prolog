:- encoding(utf8).

% Capítulo 53 - Versión 2: forma subyacente y reglas ortográficas.
%
% Cada palabra tiene dos niveles. La forma subyacente escribe cada sonido
% con una sola letra y marca con + los límites entre raíz y terminación;
% la forma escrita es la que se lee. Las letras que la ortografía escribe
% de dos maneras son, en el nivel subyacente:
%
%   k   el sonido de «casa» y «queso»: c o qu
%   z   el de «luz» y «luces»: z o c
%   g   el de «gato» y «guerra»: g o gu
%   'J' el de «gente» y «jota»: g o j ante e, i; j ante a, o, u
%
% La forma escrita sale de la subyacente por cuatro pasadas en orden: la e
% del plural después de consonante, las tildes, los límites que se
% borran y la ortografía. lexica/2 arma la forma subyacente de un
% análisis: la raíz del lema, el cambio de vocal cuando recibe el acento
% (cuenta, piensa, pide), las formas listadas del léxico y la terminación.
%
% forma/2 genera bien todas las formas, pero analiza por síntesis: genera
% cada forma del léxico y la compara con la palabra.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- forma(P, verbo("tocar", preterito, 1, singular)).
%?- forma(P, nombre("camión", masculino, plural)).
%?- forma("cuentas", A).
%?- subyacente("proteger", S).

:- module(reglas,
          [ forma/2,
            generar/2,
            analisis/1,
            lexica/2,
            subyacente/2,
            escribir/2,
            superficie/2,
            tilde/2,
            vocal/1,
            consonante/1
          ]).

:- use_module(lexico).
:- use_module(library(apply)).
:- use_module(library(lists)).

% Otros archivos pueden agregar clases de cambio de la raíz.
:- multifile diptongo/3, cerrada/3.

%!  forma(?Palabra:string, ?Analisis) is nondet.
%
%   Palabra es la forma escrita que describe Analisis. Para analizar,
%   recorre todos los análisis del léxico.
forma(Palabra, Analisis) :-
    analisis(Analisis),
    generar(Analisis, Palabra).

%!  generar(+Analisis, -Palabra:string) is semidet.
%
%   Palabra es la forma escrita que describe Analisis.
generar(Analisis, Palabra) :-
    lexica(Analisis, Subyacente),
    superficie(Subyacente, Letras),
    string_chars(Palabra, Letras).

%!  superficie(+Subyacente:list, -Escrita:list) is det.
%
%   Escrita es la forma escrita de Subyacente, por las cuatro pasadas.
superficie(S0, Escrita) :-
    epentesis(S0, S1),
    tildes(S1, S2),
    exclude(==(+), S2, S3),
    escribir(S3, Escrita).

%!  analisis(?Analisis) is nondet.
%
%   Analisis describe una forma de una palabra del léxico.
analisis(nombre(Lema, Genero, Numero)) :-
    nombre(Lema, Genero),
    numero(Numero).
analisis(adjetivo(Lema, Genero, Numero)) :-
    adjetivo(Lema, _),
    genero(Genero),
    numero(Numero).
analisis(verbo(Lema, Tiempo, Persona, Numero)) :-
    verbo(Lema, _),
    terminacion(a, Tiempo, Persona, Numero, _).

% numero(N), genero(G): los valores de cada rasgo.
numero(singular).
numero(plural).
genero(masculino).
genero(femenino).

%!  subyacente(+Palabra:string, -Subyacente:list) is nondet.
%
%   Subyacente es una forma subyacente cuya forma escrita es Palabra, sin
%   límites: escribir/2 en sentido inverso. Para un lema es una sola.
subyacente(Palabra, Subyacente) :-
    string_chars(Palabra, Letras),
    escribir(Subyacente, Letras).

%!  escribir(?Subyacente:list, ?Escrita:list) is nondet.
%
%   Escrita es la ortografía de Subyacente: k, z, g y 'J' se escriben
%   según la vocal que sigue, y j solo aparece ante e, i (tejer). Una de
%   las dos listas debe llegar ligada: cada condición se evalúa después
%   de la llamada recursiva, cuando el resto de la forma subyacente ya
%   está ligado en los dos sentidos.
escribir([], []).
escribir([k|S], [q, u|E]) :-
    escribir(S, E),
    frontal(S).
escribir([k|S], [c|E]) :-
    escribir(S, E),
    \+ frontal(S).
escribir([z|S], [c|E]) :-
    escribir(S, E),
    frontal(S).
escribir([z|S], [z|E]) :-
    escribir(S, E),
    \+ frontal(S).
escribir([g|S], [g, u|E]) :-
    escribir(S, E),
    frontal(S).
escribir([g|S], [g|E]) :-
    escribir(S, E),
    \+ frontal(S),
    \+ ( S = [u|S1], frontal(S1) ).
escribir(['J'|S], [g|E]) :-
    escribir(S, E),
    frontal(S).
escribir(['J'|S], [j|E]) :-
    escribir(S, E),
    \+ frontal(S).
escribir([j|S], [j|E]) :-
    escribir(S, E),
    frontal(S).
escribir([L|S], [L|E]) :-
    escribir(S, E),
    \+ memberchk(L, [k, z, g, 'J', j, c, q]).

%!  frontal(+Letras:list) is semidet.
%
%   Letras empieza con e o con i, con tilde o sin ella.
frontal([V|_]) :-
    sub_atom('eiéí', _, 1, _, V).

%!  epentesis(+S0:list, -S:list) is det.
%
%   El plural agrega es, no s, después de una consonante: luz+s pasa a
%   luz+es.
epentesis(S0, S) :-
    (   append(Raiz, [C, +, s], S0),
        consonante(C)
    ->  append(Raiz, [C, +, e, s], S)
    ;   S = S0
    ).

%!  tildes(+S0:list, -S:list) is det.
%
%   Una vocal con tilde seguida de una consonante, un límite y una vocal
%   la pierde (camión+es, inglés+a); una vocal sin tilde seguida de
%   consonantes, una vocal sin tilde, n y un límite la gana (examen+es).
tildes([], []).
tildes([X|S0], [Y|S]) :-
    (   tilde(Y, X),
        S0 = [C, +, V|_],
        consonante(C),
        vocal(V)
    ->  true
    ;   tilde(X, Y),
        append([C|Cs], [V, n, +|_], S0),
        maplist(consonante, [C|Cs]),
        tilde(V, _)
    ->  true
    ;   Y = X
    ),
    tildes(S0, S).

% tilde(V, T): T es la vocal V con tilde.
tilde(a, 'á').
tilde(e, 'é').
tilde(i, 'í').
tilde(o, 'ó').
tilde(u, 'ú').

%!  vocal(+L) is semidet.
%
%   L es una vocal, con tilde o sin ella.
vocal(L) :-
    (   tilde(L, _)
    ->  true
    ;   tilde(_, L)
    ).

%!  consonante(+L) is semidet.
%
%   L es una letra que no es vocal ni límite.
consonante(L) :-
    L \== +,
    \+ vocal(L).

%!  lexica(+Analisis, -Subyacente:list) is semidet.
%
%   Subyacente es la forma subyacente, con límites, que describe
%   Analisis.
lexica(nombre(Lema, Genero, Numero), S) :-
    nombre(Lema, Genero),
    subyacente(Lema, Raiz),
    numero_final(Numero, Raiz, S).
lexica(adjetivo(Lema, Genero, Numero), S) :-
    adjetivo(Lema, Clase),
    subyacente(Lema, Raiz0),
    raiz_genero(Clase, Genero, Raiz0, Raiz),
    numero_final(Numero, Raiz, S).
lexica(verbo(Lema, Tiempo, Persona, Numero), S) :-
    (   irregular(Lema, Tiempo, Persona, Numero, Forma)
    ->  subyacente(Forma, S)
    ;   Tiempo == preterito,
        preterito_fuerte(Lema, Forma)
    ->  subyacente(Forma, Raiz0),
        append(Raiz, [e], Raiz0),
        terminacion(fuerte, preterito, Persona, Numero, T),
        con_limite(Raiz, T, S)
    ;   verbo(Lema, Clase),
        subyacente(Lema, Infinitivo),
        append(Raiz0, [V, r], Infinitivo),
        terminacion(V, Tiempo, Persona, Numero, T),
        raiz_verbal(Clase, V, Tiempo, Persona, T, Raiz0, Raiz),
        con_limite(Raiz, T, S)
    ).

%!  numero_final(+Numero, +Raiz:list, -S:list) is det.
%
%   S es Raiz en singular, o con el límite y la s del plural.
numero_final(singular, Raiz, Raiz).
numero_final(plural, Raiz, S) :-
    append(Raiz, [+, s], S).

%!  raiz_genero(+Clase, +Genero, +Raiz0:list, -Raiz:list) is det.
%
%   Raiz es la forma de un adjetivo de la Clase en el Genero, antes del
%   número: roj+o, roj+a, inglés, inglés+a, verde.
raiz_genero(invariable, _, Raiz, Raiz).
raiz_genero(o_a, Genero, Raiz0, Raiz) :-
    append(Raiz1, [o], Raiz0),
    (   Genero == masculino
    ->  append(Raiz1, [+, o], Raiz)
    ;   append(Raiz1, [+, a], Raiz)
    ).
raiz_genero(agrega_a, Genero, Raiz0, Raiz) :-
    (   Genero == masculino
    ->  Raiz = Raiz0
    ;   append(Raiz0, [+, a], Raiz)
    ).

%!  con_limite(+Raiz:list, +T:string, -S:list) is det.
%
%   S es Raiz, un límite y la terminación T.
con_limite(Raiz, T, S) :-
    string_chars(T, Letras),
    append(Raiz, [+|Letras], S).

%!  raiz_verbal(+Clase, +Conj, +Tiempo, +Persona, +T, +R0, -R) is det.
%
%   R es la raíz R0 de un verbo de la Clase ante la terminación T. La
%   última vocal cambia cuando la raíz lleva el acento, es decir, cuando
%   T es una sola sílaba sin tilde (cuent+a, pero cont+amos, cont+é); y
%   en la tercera persona del pretérito de los verbos en -ir que cambian
%   (sint+ió, durm+ieron).
raiz_verbal(Clase, _, _, _, T, R0, R) :-
    acento_en_la_raiz(T),
    diptongo(Clase, V, Nueva),
    !,
    cambiar_ultima(V, Nueva, R0, R).
raiz_verbal(Clase, i, preterito, 3, _, R0, R) :-
    cerrada(Clase, V, Nueva),
    !,
    cambiar_ultima(V, Nueva, R0, R).
raiz_verbal(_, _, _, _, _, R, R).

%!  acento_en_la_raiz(+T:string) is semidet.
%
%   La terminación T tiene una sola vocal y no lleva tilde: el acento cae
%   en la raíz.
acento_en_la_raiz(T) :-
    string_chars(T, Letras),
    include(vocal, Letras, [V]),
    tilde(V, _).

% diptongo(Clase, V, Nueva): la vocal V acentuada pasa a Nueva.
diptongo(e_ie, e, [i, e]).
diptongo(o_ue, o, [u, e]).
diptongo(e_i, e, [i]).

% cerrada(Clase, V, Nueva): en el pretérito de -ir, V pasa a Nueva.
cerrada(e_ie, e, [i]).
cerrada(e_i, e, [i]).
cerrada(o_ue, o, [u]).

%!  cambiar_ultima(+V, +Nueva:list, +R0:list, -R:list) is semidet.
%
%   R es R0 con su última vocal, que debe ser V, cambiada por Nueva.
cambiar_ultima(V, Nueva, R0, R) :-
    append(Antes, [V|Despues], R0),
    \+ ( member(X, Despues), vocal(X) ),
    !,
    append(Antes, Nueva, R1),
    append(R1, Despues, R).
