:- encoding(utf8).

% Capítulo 81 - Moléculas: buscar estructuras en un grafo con rótulos.
%
% Una molécula es un grafo: los nodos son átomos, rotulados con su
% elemento, y las aristas son los enlaces. molecula(Nombre, Atomos,
% Enlaces) da los átomos agrupados por elemento y cada enlace una sola
% vez, como A-B; enlazados/3 lo recorre en los dos sentidos.
%
% Versión 1: las consultas de Covington, escritas como generar y probar
% sobre el grafo. Cada estructura aparece tantas veces como maneras hay
% de nombrar sus átomos: un metilo seis veces, un anillo de seis doce.
% Versión 2: una respuesta por estructura, pidiendo que los átomos
% intercambiables aparezcan en orden; la fórmula molecular.
% Versión 3: el orden de cada enlace (simple, doble o triple), deducido
% de la valencia de cada elemento con las restricciones del capítulo 23.
%
%?- metilo_v1(clorotolueno, C).
%?- metilo(clorotolueno, C).
%?- anillo(clorotolueno, 6, Anillo).
%?- formula(tnt, F).
%?- ordenes(fenol, Ordenes).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(clpfd)).

% --- Las moléculas --------------------------------------------------------

% molecula(Nombre, Atomos, Enlaces): Atomos es una lista Elemento-Nombres;
% Enlaces, una lista de pares A-B de átomos enlazados.
% Es multifile para que otros archivos agreguen moléculas.
:- multifile molecula/3.

molecula(clorotolueno,
         [ carbono-[c1, c2, c3, c4, c5, c6, c7],
           hidrogeno-[h1, h2, h3, h4, h5, h6, h7],
           cloro-[cl1]
         ],
         [ c1-c2, c2-c5, c5-c7, c7-c6, c6-c4, c4-c1,
           c4-c3, c3-h2, c3-h3, c3-h5,
           c1-h1, c5-h4, c6-h6, c7-h7, c2-cl1 ]).
molecula(fenol,
         [ carbono-[c1, c2, c3, c4, c5, c6],
           hidrogeno-[h1, h2, h3, h4, h5, h6],
           oxigeno-[o1]
         ],
         [ c1-c2, c2-c3, c3-c4, c4-c5, c5-c6, c6-c1,
           c2-h1, c3-h2, c4-h3, c5-h4, c6-h5,
           c1-o1, o1-h6
         ]).
molecula(metanol,
         [ carbono-[c1],
           hidrogeno-[h1, h2, h3, h4],
           oxigeno-[o1]
         ],
         [ c1-h1, c1-h2, c1-h3, c1-o1, o1-h4 ]).
molecula(difenilo,
         [ carbono-[a1, a2, a3, a4, a5, a6, b1, b2, b3, b4, b5, b6],
           hidrogeno-[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10]
         ],
         [ a1-a2, a2-a3, a3-a4, a4-a5, a5-a6, a6-a1,
           b1-b2, b2-b3, b3-b4, b4-b5, b5-b6, b6-b1,
           a1-b1,
           a2-h1, a3-h2, a4-h3, a5-h4, a6-h5,
           b2-h6, b3-h7, b4-h8, b5-h9, b6-h10
         ]).
molecula(tnt,
         [ carbono-[c1, c2, c3, c4, c5, c6, c7],
           hidrogeno-[h1, h2, h3, h4, h5],
           nitrogeno-[n1, n2, n3],
           oxigeno-[o1, o2, o3, o4, o5, o6]
         ],
         [ c1-c2, c2-c3, c3-c4, c4-c5, c5-c6, c6-c1,
           c1-c7, c7-h1, c7-h2, c7-h3,
           c3-h4, c5-h5,
           c2-n1, n1-o1, n1-o2,
           c4-n2, n2-o3, n2-o4,
           c6-n3, n3-o5, n3-o6
         ]).
molecula(hidroxilamina,
         [ hidrogeno-[h1, h2, h3],
           nitrogeno-[n1],
           oxigeno-[o1]
         ],
         [ n1-h1, n1-h2, n1-o1, o1-h3 ]).

% --- Versión 1: las consultas sobre el grafo -----------------------------

%!  elemento(?M, ?A, ?E) is nondet.
%
%   El átomo A de la molécula M es del elemento E.
elemento(M, A, E) :-
    molecula(M, Atomos, _),
    member(E-As, Atomos),
    member(A, As).

%!  enlazados(?M, ?A, ?B) is nondet.
%
%   Los átomos A y B de la molécula M están enlazados.
enlazados(M, A, B) :-
    molecula(M, _, Enlaces),
    (   member(A-B, Enlaces)
    ;   member(B-A, Enlaces)
    ).

%!  metilo_v1(?M, ?C) is nondet.
%
%   El carbono C de la molécula M tiene tres hidrógenos: es el centro de un
%   grupo metilo. Da una respuesta por cada orden de los tres hidrógenos.
metilo_v1(M, C) :-
    elemento(M, C, carbono),
    enlazados(M, C, H1),
    elemento(M, H1, hidrogeno),
    enlazados(M, C, H2),
    elemento(M, H2, hidrogeno),
    H1 \== H2,
    enlazados(M, C, H3),
    elemento(M, H3, hidrogeno),
    H3 \== H1,
    H3 \== H2.

%!  anillo_v1(?M, ?Anillo:list) is nondet.
%
%   Anillo son seis carbonos de M, distintos, cada uno enlazado con el
%   siguiente y el último con el primero. Da una respuesta por cada
%   carbono de partida y cada sentido de recorrido.
anillo_v1(M, [A1, A2, A3, A4, A5, A6]) :-
    elemento(M, A1, carbono),
    enlazados(M, A1, A2),
    elemento(M, A2, carbono),
    enlazados(M, A2, A3),
    A3 \== A1,
    elemento(M, A3, carbono),
    enlazados(M, A3, A4),
    \+ memberchk(A4, [A1, A2, A3]),
    elemento(M, A4, carbono),
    enlazados(M, A4, A5),
    \+ memberchk(A5, [A1, A2, A3, A4]),
    elemento(M, A5, carbono),
    enlazados(M, A5, A6),
    \+ memberchk(A6, [A1, A2, A3, A4, A5]),
    elemento(M, A6, carbono),
    enlazados(M, A6, A1).

%!  hidroxilo(?M, ?O) is nondet.
%
%   El oxígeno O de la molécula M está enlazado con un hidrógeno: es el
%   centro de un grupo hidroxilo.
hidroxilo(M, O) :-
    elemento(M, O, oxigeno),
    enlazados(M, O, H),
    elemento(M, H, hidrogeno).

% --- Versión 2: una respuesta por estructura ------------------------------

%!  metilo(?M, ?C) is nondet.
%
%   Como metilo_v1/2, con los tres hidrógenos en orden: una respuesta
%   por grupo.
metilo(M, C) :-
    elemento(M, C, carbono),
    enlazados(M, C, H1),
    elemento(M, H1, hidrogeno),
    enlazados(M, C, H2),
    elemento(M, H2, hidrogeno),
    H1 @< H2,
    enlazados(M, C, H3),
    elemento(M, H3, hidrogeno),
    H2 @< H3.

%!  anillo(?M, +N:integer, -Anillo:list) is nondet.
%
%   Anillo es un ciclo de N carbonos de M, con N de 3 en adelante, escrito
%   de una sola manera: empieza por el menor átomo, y el segundo es menor
%   que el último.
anillo(M, N, [A|As]) :-
    elemento(M, A, carbono),
    N1 is N - 1,
    cadena(M, N1, A, [A], As),
    last(As, Z),
    enlazados(M, Z, A),
    As = [B|_],
    B @< Z,
    forall(member(X, As), A @< X).

%!  cadena(+M, +K:integer, +A, +Vistos:list, -Cadena:list) is nondet.
%
%   Cadena son K carbonos de M, fuera de Vistos y distintos entre sí, el
%   primero enlazado con A y cada uno con el siguiente.
cadena(_, 0, _, _, []).
cadena(M, K, A, Vistos, [B|Bs]) :-
    K > 0,
    enlazados(M, A, B),
    elemento(M, B, carbono),
    \+ memberchk(B, Vistos),
    K1 is K - 1,
    cadena(M, K1, B, [B|Vistos], Bs).

%!  anillo_metilado(?M, -Estructura:list) is nondet.
%
%   Estructura es [C|Anillo]: C es un metilo enlazado con un carbono del
%   anillo de seis Anillo.
anillo_metilado(M, [C|Anillo]) :-
    anillo(M, 6, Anillo),
    member(A, Anillo),
    enlazados(M, A, C),
    metilo(M, C).

%!  nitro(?M, ?N) is nondet.
%
%   El nitrógeno N de la molécula M tiene dos oxígenos que no están
%   enlazados con ningún otro átomo: es el centro de un grupo nitro.
nitro(M, N) :-
    elemento(M, N, nitrogeno),
    enlazados(M, N, O1),
    elemento(M, O1, oxigeno),
    enlazados(M, N, O2),
    elemento(M, O2, oxigeno),
    O1 @< O2,
    \+ ( enlazados(M, O1, X), X \== N ),
    \+ ( enlazados(M, O2, X), X \== N ).

% simbolo(Elemento, Simbolo): el símbolo químico del elemento.
simbolo(carbono, 'C').
simbolo(hidrogeno, 'H').
simbolo(nitrogeno, 'N').
simbolo(oxigeno, 'O').
simbolo(cloro, 'Cl').

%!  formula(+M, -Formula:atom) is det.
%
%   Formula es la fórmula molecular de M en el orden de Hill: primero el
%   carbono y el hidrógeno, después los demás símbolos en orden
%   alfabético; sin carbono, todos en orden alfabético. Un elemento con un
%   solo átomo no lleva número.
formula(M, Formula) :-
    molecula(M, Atomos, _),
    findall(S-K,
            ( member(E-As, Atomos),
              simbolo(E, S),
              length(As, K) ),
            Cuentas0),
    keysort(Cuentas0, Cuentas1),
    (   selectchk('C'-C, Cuentas1, Cuentas2)
    ->  (   selectchk('H'-H, Cuentas2, Cuentas3)
        ->  Cuentas = ['C'-C, 'H'-H|Cuentas3]
        ;   Cuentas = ['C'-C|Cuentas2]
        )
    ;   Cuentas = Cuentas1
    ),
    maplist(termino, Cuentas, Terminos),
    atomic_list_concat(Terminos, Formula).

%!  termino(+Cuenta, -Termino:atom) is det.
%
%   Termino es el símbolo de Cuenta, S-K, seguido de K si K no es 1.
termino(S-K, T) :-
    (   K =:= 1
    ->  T = S
    ;   atom_concat(S, K, T)
    ).

% --- Versión 3: el orden de los enlaces -----------------------------------

% valencia(Elemento, V): cada átomo del elemento forma V enlaces, contando
% dos por un enlace doble y tres por uno triple.
valencia(carbono, 4).
valencia(hidrogeno, 1).
valencia(nitrogeno, 3).
valencia(oxigeno, 2).
valencia(cloro, 1).

%!  ordenes(+M, -Ordenes:list) is nondet.
%
%   Ordenes da a cada enlace A-B de M su orden: una lista de A-B-O, con O
%   1, 2 o 3, en la que los órdenes de los enlaces de cada átomo suman su
%   valencia. Una respuesta por cada asignación posible.
ordenes(M, Ordenes) :-
    molecula(M, _, Enlaces),
    length(Enlaces, N),
    length(Os, N),
    Os ins 1..3,
    maplist(orden, Enlaces, Os, Ordenes),
    findall(A-E, elemento(M, A, E), Atomos),
    maplist(valencia_cumplida(Ordenes), Atomos),
    label(Os).

%!  orden(+Enlace, +O, -EnlaceConOrden) is det.
%
%   EnlaceConOrden es el enlace A-B con su orden O: A-B-O.
orden(A-B, O, A-B-O).

%!  valencia_cumplida(+Ordenes:list, +Atomo) is semidet.
%
%   Para Atomo, A-E, los órdenes de los enlaces de A en Ordenes suman la
%   valencia de E: impone esa restricción.
valencia_cumplida(Ordenes, A-E) :-
    valencia(E, V),
    del_atomo(Ordenes, A, Os),
    sum(Os, #=, V).

%!  del_atomo(+Ordenes:list, +A, -Os:list) is det.
%
%   Os son los órdenes, todavía variables, de los enlaces de A en Ordenes.
%   No se usa findall/3, que copiaría las variables y las separaría de
%   sus restricciones.
del_atomo([], _, []).
del_atomo([X-Y-O|Ordenes], A, Os) :-
    (   ( X == A ; Y == A )
    ->  Os = [O|Os1]
    ;   Os = Os1
    ),
    del_atomo(Ordenes, A, Os1).

%!  dobles(+M, -Dobles:list) is nondet.
%
%   Dobles son los enlaces dobles de una asignación de órdenes de M.
dobles(M, Dobles) :-
    ordenes(M, Ordenes),
    findall(A-B, member(A-B-2, Ordenes), Dobles).
