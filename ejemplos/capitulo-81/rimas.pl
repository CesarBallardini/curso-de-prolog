:- encoding(utf8).

% Capítulo 81 - Dos canciones con estructura: una acumulativa y una que
% cuenta.
%
% «La casa que construyó Juan» es una rima acumulativa: cada estrofa
% agrega un personaje al principio y repite todo lo anterior, así que la
% última estrofa contiene todas las demás. Un eslabón es
% e(Articulo, Nombre, Enlace): el personaje y la manera de nombrar al
% siguiente, que es v(Verbo, Preposicion) o fin. Las estrofas son los
% sufijos de la cadena completa, del más corto al más largo.
%
% «Un elefante se balanceaba» cuenta sin fin: la estrofa N nombra N
% elefantes, con el número en letras y los verbos en singular o en plural.
% cancion/1 da las estrofas una por una, sin límite.
%
%?- sufijos([f, e, d, c, b, a], Ss).
%?- estrofa_n(3, Ls).
%?- en_letras(21, P).
%?- estrofa_elefantes(2, Ls).

:- use_module(library(apply)).
:- use_module(library(lists)).

% --- La casa que construyó Juan -----------------------------------------

% cadena(Eslabones): los personajes de la última estrofa, del primero al
% último.
cadena([ e(el, "granjero que siembra su trigo", v("que tenía", a)),
         e(el, "gallo que cantaba a la mañana", v("que despertó", a)),
         e(el, "cura de cabeza rapada", v("que casó", a)),
         e(el, "hombre de ropa rasgada", v("que besó", a)),
         e(la, "doncella desamparada", v("que ordeñó", a)),
         e(la, "vaca de cuerno torcido", v("que corneó", a)),
         e(el, "perro", v("que asustó", a)),
         e(el, "gato", v("que mató", a)),
         e(la, "rata", v("que se comió", ninguna)),
         e(la, "malta", v("que estaba en", ninguna)),
         e(la, "casa que construyó Juan", fin)
       ]).

%!  sufijos(+Lista:list, -Sufijos:list) is det.
%
%   Sufijos son los sufijos no vacíos de Lista, del más corto al más
%   largo.
sufijos(Lista, Sufijos) :-
    findall(S, ( append(_, S, Lista), S \== [] ), Sufijos0),
    reverse(Sufijos0, Sufijos).

%!  estrofa(+Eslabones:list, -Lineas:list) is det.
%
%   Lineas son los versos de la estrofa que presenta al primero de
%   Eslabones y recorre los demás.
estrofa([e(Articulo, Nombre, Enlace)|Es], Lineas) :-
    presentacion(Articulo, Presenta),
    format(string(Primera), "~w ~w ~w", [Presenta, Articulo, Nombre]),
    versos(Enlace, Es, Resto),
    con_punto([Primera|Resto], Lineas).

%!  versos(+Enlace, +Eslabones:list, -Lineas:list) is det.
%
%   Lineas son los versos que nombran a cada eslabón de Eslabones con el
%   enlace del anterior; Enlace es el del eslabón que los precede.
versos(_, [], []).
versos(v(Verbo, Prep), [e(Articulo, Nombre, Enlace)|Es], [Linea|Lineas]) :-
    contraccion(Prep, Articulo, Union),
    format(string(Linea), "~w ~w ~w", [Verbo, Union, Nombre]),
    versos(Enlace, Es, Lineas).

% presentacion(Articulo, Palabras): cómo empieza la estrofa según el
% género del primer personaje.
presentacion(el, "Este es").
presentacion(la, "Esta es").

%!  contraccion(+Preposicion, +Articulo, -Union:atom) is det.
%
%   Union es la preposición seguida del artículo: a y el se contraen en
%   al; sin preposición (ninguna), Union es el artículo.
contraccion(Prep, Articulo, Union) :-
    (   Prep == ninguna
    ->  Union = Articulo
    ;   Prep == a,
        Articulo == el
    ->  Union = al
    ;   atomic_list_concat([Prep, Articulo], ' ', Union)
    ).

%!  con_punto(+Lineas0:list, -Lineas:list) is det.
%
%   Lineas es Lineas0 con un punto al final del último verso.
con_punto([L0|Ls0], Lineas) :-
    con_punto(Ls0, L0, Lineas).

%!  con_punto(+Siguientes:list, +L0:string, -Lineas:list) is det.
%
%   Lineas es [L0|Siguientes] con un punto al final del último verso. El
%   verso actual va aparte, para que la indexación por el primer
%   argumento distinga si es el último.
con_punto([], L0, [L]) :-
    string_concat(L0, ".", L).
con_punto([L1|Ls0], L0, [L0|Ls]) :-
    con_punto(Ls0, L1, Ls).

%!  rima(-Estrofas:list) is det.
%
%   Estrofas son las estrofas de la rima, cada una una lista de versos,
%   de la más corta a la más larga.
rima(Estrofas) :-
    cadena(Cadena),
    sufijos(Cadena, Sufijos),
    maplist(estrofa, Sufijos, Estrofas).

%!  estrofa_n(+N:integer, -Lineas:list) is semidet.
%
%   Lineas son los versos de la estrofa N de la rima, de 1 a 11.
estrofa_n(N, Lineas) :-
    rima(Estrofas),
    nth1(N, Estrofas, Lineas).

% --- Un elefante se balanceaba ------------------------------------------

% unidad(N, Palabra): los números del 1 al 29 que tienen nombre propio.
unidad(1, "uno").
unidad(2, "dos").
unidad(3, "tres").
unidad(4, "cuatro").
unidad(5, "cinco").
unidad(6, "seis").
unidad(7, "siete").
unidad(8, "ocho").
unidad(9, "nueve").
unidad(10, "diez").
unidad(11, "once").
unidad(12, "doce").
unidad(13, "trece").
unidad(14, "catorce").
unidad(15, "quince").
unidad(16, "dieciséis").
unidad(17, "diecisiete").
unidad(18, "dieciocho").
unidad(19, "diecinueve").
unidad(20, "veinte").
unidad(21, "veintiuno").
unidad(22, "veintidós").
unidad(23, "veintitrés").
unidad(24, "veinticuatro").
unidad(25, "veinticinco").
unidad(26, "veintiséis").
unidad(27, "veintisiete").
unidad(28, "veintiocho").
unidad(29, "veintinueve").

% decena(D, Palabra): el nombre de las decenas desde el 30.
decena(3, "treinta").
decena(4, "cuarenta").
decena(5, "cincuenta").
decena(6, "sesenta").
decena(7, "setenta").
decena(8, "ochenta").
decena(9, "noventa").

%!  en_letras(+N:integer, -Palabras:string) is semidet.
%
%   Palabras es el número N, de 1 a 99, escrito en letras. Falla fuera de
%   ese intervalo.
en_letras(N, Palabras) :-
    (   unidad(N, P)
    ->  Palabras = P
    ;   N >= 30,
        N =< 99,
        D is N // 10,
        U is N mod 10,
        decena(D, PD),
        (   U =:= 0
        ->  Palabras = PD
        ;   unidad(U, PU),
            format(string(Palabras), "~w y ~w", [PD, PU])
        )
    ).

%!  ante_sustantivo(+N:integer, -Palabras:string) is semidet.
%
%   Palabras es N en letras como se dice delante de un sustantivo
%   masculino: uno pierde la última vocal (un, veintiún, treinta y un).
ante_sustantivo(N, Palabras) :-
    en_letras(N, P),
    (   string_concat(Raiz, "uno", P)
    ->  (   Raiz == "veinti"
        ->  Palabras = "veintiún"
        ;   string_concat(Raiz, "un", Palabras)
        )
    ;   Palabras = P
    ).

%!  estrofa_elefantes(+N:integer, -Lineas:list) is semidet.
%
%   Lineas son los cuatro versos de la estrofa N, con N de 1 a 99.
estrofa_elefantes(N, [L1, L2, L3, L4]) :-
    ante_sustantivo(N, Numero0),
    mayuscula_inicial(Numero0, Numero),
    numero_gramatical(N, Num),
    formas(Num, Elefantes, Balanceaba, Veia, Fue),
    format(string(L1), "~w ~w se ~w", [Numero, Elefantes, Balanceaba]),
    L2 = "sobre la tela de una araña;",
    format(string(L3), "como ~w que resistía", [Veia]),
    format(string(L4), "~w a llamar a otro elefante.", [Fue]).

%!  numero_gramatical(+N:integer, -Num) is det.
%
%   Num es singular si N es 1 y plural si no.
numero_gramatical(N, Num) :-
    (   N =:= 1
    ->  Num = singular
    ;   Num = plural
    ).

% formas(Num, Elefantes, Balanceaba, Veia, Fue): las palabras de la
% estrofa que concuerdan con la cantidad de elefantes.
formas(singular, "elefante", "balanceaba", "veía", "fue").
formas(plural, "elefantes", "balanceaban", "veían", "fueron").

%!  mayuscula_inicial(+Texto:string, -Texto1:string) is det.
%
%   Texto1 es Texto con la primera letra en mayúscula.
mayuscula_inicial(Texto, Texto1) :-
    sub_string(Texto, 0, 1, _, Primera),
    sub_string(Texto, 1, _, 0, Resto),
    string_upper(Primera, Mayuscula),
    string_concat(Mayuscula, Resto, Texto1).

%!  cancion(-Estrofa:list) is nondet.
%
%   Estrofa es una estrofa de la canción: la primera, la segunda y así,
%   al pedir otra respuesta, hasta la 99.
cancion(Estrofa) :-
    between(1, 99, N),
    estrofa_elefantes(N, Estrofa).
