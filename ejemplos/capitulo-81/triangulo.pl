:- encoding(utf8).

% Capítulo 81 - El triángulo de clavijas: el tablero, los saltos, la
% búsqueda y las simetrías.
%
% El tablero tiene quince agujeros en cinco filas, numerados por filas de
% 1 (el vértice de arriba) a 15 (el vértice de abajo a la derecha). Una
% posición es un término t/15 con un argumento por agujero: 1 si tiene
% clavija, 0 si está vacío. Un salto lleva una clavija por encima de una
% vecina a un agujero vacío en línea recta, y quita la clavija saltada; se
% escribe s(De, Sobre, Hasta). Se empieza con un solo agujero vacío y se
% gana cuando queda una sola clavija.
%
% Versión 1: cada salto es un hecho salto(S, Antes, Despues) cuyos dos
% términos t/15 comparten las doce variables de los agujeros que el salto
% no toca, como propuso Richard O'Keefe: saltar es una unificación. Los 36
% hechos no se escriben a mano: term_expansion/2 los calcula al cargar el
% archivo, con la geometría del triángulo. resolver/2 es la búsqueda en
% profundidad del propio Prolog, sin registro de posiciones.
%
% Versión 2: el triángulo como problema para las búsquedas del capítulo
% 40, a través del puente del capítulo 76: el problema triangulo:todas(V)
% recorre las posiciones; buscar/5 recuerda las vistas.
%
% Versión 3: las seis simetrías del triángulo, también generadas al
% cargar como pares de términos t/15. La forma de una posición es la menor
% de sus seis imágenes; el problema triangulo:formas(V) recorre formas,
% así que el registro de visitados guarda una sola posición por clase.
%
% solo-local: carga el puente del capítulo 76, y SWISH no permite cargar
% otro archivo.
%
%?- inicio(1, T), dibujar(T).
%?- inicio(1, T), resolver(T, Saltos).
%?- imagen(giro, 1, N).
%?- inicio(4, T), forma(T, F), dibujar(F).
%?- jugar_formas(profundidad, 1, Saltos, K).

:- module(triangulo,
          [ casilla/3,
            linea/3,
            imagen/3,
            salto/3,
            simetria/3,
            inicio/2,
            clavijas/2,
            resolver/2,
            jugar/3,
            filas/2,
            dibujar/1,
            forma/2,
            jugar_todas/4,
            jugar_formas/4,
            en_el_tablero/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- reexport('../capitulo-76/capitulo40').

% --- La geometría -------------------------------------------------------------

%!  casilla(?N:integer, ?F:integer, ?C:integer) is nondet.
%
%   El agujero N, de 1 a 15, es el C-ésimo de la fila F, de 1 a 5,
%   contando desde la izquierda.
casilla(N, F, C) :-
    between(1, 5, F),
    between(1, F, C),
    N is F * (F - 1) // 2 + C.

% direccion(DF, DC): un paso en línea recta suma DF a la fila y DC a la
% posición en la fila: a lo largo de la fila, o hacia abajo por uno de
% los dos lados.
direccion(0, 1).
direccion(1, 0).
direccion(1, 1).

%!  linea(?A:integer, ?B:integer, ?C:integer) is nondet.
%
%   A, B y C son tres agujeros seguidos en línea recta, en ese orden, de
%   arriba hacia abajo o de izquierda a derecha.
linea(A, B, C) :-
    casilla(A, F, K),
    direccion(DF, DK),
    F1 is F + DF,
    K1 is K + DK,
    F2 is F1 + DF,
    K2 is K1 + DK,
    casilla(B, F1, K1),
    casilla(C, F2, K2).

%!  coordenadas(?N:integer, ?Coordenadas:list) is nondet.
%
%   Coordenadas es [X, Y, Z]: la distancia del agujero N al lado
%   izquierdo, al lado derecho y a la base, en pasos. Las tres suman 4.
coordenadas(N, [X, Y, Z]) :-
    casilla(N, F, C),
    X is C - 1,
    Y is F - C,
    Z is 5 - F.

% permutacion(S, Antes, Despues): la simetría S del triángulo permuta las
% tres coordenadas de cada agujero así. giro es un tercio de vuelta en el
% sentido de las agujas del reloj; espejo1, espejo11 y espejo15 reflejan
% el triángulo sobre la altura que pasa por ese vértice.
permutacion(identidad, [X, Y, Z], [X, Y, Z]).
permutacion(giro, [X, Y, Z], [Z, X, Y]).
permutacion(giro2, [X, Y, Z], [Y, Z, X]).
permutacion(espejo1, [X, Y, Z], [Y, X, Z]).
permutacion(espejo11, [X, Y, Z], [Z, Y, X]).
permutacion(espejo15, [X, Y, Z], [X, Z, Y]).

%!  imagen(?S, ?N:integer, ?N1:integer) is nondet.
%
%   La simetría S lleva el agujero N al agujero N1.
imagen(S, N, N1) :-
    permutacion(S, P, P1),
    coordenadas(N, P),
    coordenadas(N1, P1).

% --- Los hechos generados al cargar -----------------------------------------

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término generar_triangulo se reemplaza, al cargar el archivo, por
%   un hecho salto/3 por cada salto y un hecho simetria/3 por cada
%   simetría. Falla con cualquier otro término.
term_expansion(generar_triangulo, Hechos) :-
    findall(salto(s(De, Sobre, Hasta), Antes, Despues),
            ( ( linea(De, Sobre, Hasta)
              ; linea(Hasta, Sobre, De)
              ),
              salto_calculado(De, Sobre, Hasta, Antes, Despues) ),
            Saltos),
    findall(simetria(S, Antes, Despues),
            ( permutacion(S, _, _),
              simetria_calculada(S, Antes, Despues) ),
            Simetrias),
    append(Saltos, Simetrias, Hechos).

%!  salto_calculado(+De:integer, +Sobre:integer, +Hasta:integer, -Antes,
%!                  -Despues) is det.
%
%   Antes y Despues son dos términos t/15 que comparten las variables de
%   los agujeros que no son De, Sobre ni Hasta: Antes tiene clavijas en De
%   y en Sobre y Hasta vacío; Despues, al revés.
salto_calculado(De, Sobre, Hasta, Antes, Despues) :-
    numlist(1, 15, Ns),
    maplist(agujero(De, Sobre, Hasta), Ns, As, Ds),
    Antes =.. [t|As],
    Despues =.. [t|Ds].

%!  agujero(+De:integer, +Sobre:integer, +Hasta:integer, +N:integer, -A,
%!          -D) is det.
%
%   A y D son el contenido del agujero N antes y después del salto: fijos
%   en los tres agujeros del salto, la misma variable en los demás.
agujero(De, Sobre, Hasta, N, A, D) :-
    (   ( N =:= De ; N =:= Sobre )
    ->  A = 1,
        D = 0
    ;   N =:= Hasta
    ->  A = 0,
        D = 1
    ;   A = D
    ).

%!  simetria_calculada(+S, -Antes, -Despues) is det.
%
%   Antes y Despues son dos términos t/15 con las mismas variables: lo que
%   Antes tiene en el agujero N, Despues lo tiene en la imagen de N por S.
simetria_calculada(S, Antes, Despues) :-
    findall(N1, ( between(1, 15, N), imagen(S, N, N1) ), Destinos),
    length(Vs, 15),
    Antes =.. [t|Vs],
    pairs_keys_values(Pares, Destinos, Vs),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Ws),
    Despues =.. [t|Ws].

generar_triangulo.

% --- Versión 1: las posiciones y la búsqueda de Prolog ---------------------

%!  inicio(+Vacio:integer, -T) is det.
%
%   T es la posición de partida con el agujero Vacio sin clavija.
inicio(Vacio, T) :-
    numlist(1, 15, Ns),
    maplist(lleno_salvo(Vacio), Ns, As),
    T =.. [t|As].

%!  lleno_salvo(+Vacio:integer, +N:integer, -A:integer) is det.
%
%   A es 0 si N es el agujero Vacio, y 1 si no.
lleno_salvo(Vacio, N, A) :-
    (   N =:= Vacio
    ->  A = 0
    ;   A = 1
    ).

%!  clavijas(+T, -K:integer) is det.
%
%   K es la cantidad de clavijas de la posición T.
clavijas(T, K) :-
    T =.. [t|As],
    sum_list(As, K).

%!  resolver(+T, -Saltos:list) is nondet.
%
%   Saltos lleva de la posición T a una posición con una sola clavija.
resolver(T, []) :-
    clavijas(T, 1).
resolver(T0, [S|Ss]) :-
    salto(S, T0, T),
    resolver(T, Ss).

%!  jugar(+Saltos:list, +T0, -Ts:list) is semidet.
%
%   Ts son las posiciones por las que pasa la partida que empieza en T0 y
%   hace Saltos, empezando por T0. La lista va primero para que la
%   indexación distinga las dos cláusulas. Falla si algún salto no es legal.
%   Desde una posición, cada salto lleva a una sola posición: once/1 no
%   pierde respuestas.
jugar([], T, [T]).
jugar([S|Ss], T0, [T0|Ts]) :-
    once(salto(S, T0, T)),
    jugar(Ss, T, Ts).

%!  filas(+T, -Filas:list) is det.
%
%   Filas son las cinco líneas de texto que dibujan la posición T: o es
%   una clavija y · un agujero vacío.
filas(T, Filas) :-
    findall(Fila, fila(T, Fila), Filas).

%!  fila(+T, -Fila:string) is nondet.
%
%   Fila es el dibujo de una de las filas de T, de arriba hacia abajo.
fila(T, Fila) :-
    between(1, 5, F),
    findall(Simbolo,
            ( casilla(N, F, _),
              arg(N, T, A),
              simbolo(A, Simbolo) ),
            Simbolos),
    atomic_list_concat(Simbolos, ' ', Agujeros),
    Margen is 5 - F,
    format(string(Fila), "~*c~w", [Margen, 0'\s, Agujeros]).

% simbolo(A, S): el agujero con contenido A se dibuja con S.
simbolo(0, '·').
simbolo(1, o).

%!  dibujar(+T) is det.
%
%   Escribe el dibujo de la posición T.
dibujar(T) :-
    filas(T, Filas),
    forall(member(Fila, Filas), format("~w~n", [Fila])).

% --- Versión 2: el triángulo para las búsquedas del capítulo 40 ------------

%!  inicial(+Problema, -T) is det.
%
%   T es la posición de partida de Problema: todas(Vacio) recorre las
%   posiciones, formas(Vacio) sus formas.
inicial(todas(Vacio), T) :-
    inicio(Vacio, T).
inicial(formas(Vacio), F) :-
    inicio(Vacio, T),
    forma(T, F).

%!  meta(+Problema, +T) is semidet.
%
%   T tiene una sola clavija.
meta(_, T) :-
    clavijas(T, 1).

%!  sucesor(+Problema, +T0, -Accion, -T, -Costo:integer) is nondet.
%
%   Con todas(_), Accion es un salto que lleva de T0 a T. Con formas(_),
%   T es la forma de la posición que deja un salto desde la forma T0, y
%   Accion es T: la acción nombra la clase de la posición siguiente.
sucesor(todas(_), T0, S, T, 1) :-
    salto(S, T0, T).
sucesor(formas(_), F0, F, F, 1) :-
    salto(_, F0, T),
    forma(T, F).

%!  jugar_todas(+Estrategia, +Vacio:integer, -Saltos:list,
%!              -Expandidos:integer) is semidet.
%
%   Saltos resuelve el triángulo que empieza con el agujero Vacio, buscado
%   con buscar/5 y Estrategia sobre las posiciones; Expandidos es la
%   cantidad de posiciones que la búsqueda expandió.
jugar_todas(Estrategia, Vacio, Saltos, Expandidos) :-
    buscar(Estrategia, triangulo:todas(Vacio), Saltos, _, Expandidos).

% --- Versión 3: las simetrías en el registro de visitados -----------------

%!  forma(+T, -F) is det.
%
%   F es la forma de la posición T: la menor, en el orden estándar, de sus
%   seis imágenes por las simetrías del triángulo.
forma(T, F) :-
    findall(I, simetria(_, T, I), Imagenes),
    min_member(F, Imagenes).

%!  jugar_formas(+Estrategia, +Vacio:integer, -Saltos:list,
%!               -Expandidos:integer) is semidet.
%
%   Como jugar_todas/4, pero la búsqueda recorre formas: Expandidos cuenta
%   clases de posiciones. Saltos son los saltos en el tablero real.
jugar_formas(Estrategia, Vacio, Saltos, Expandidos) :-
    buscar(Estrategia, triangulo:formas(Vacio), Formas, _, Expandidos),
    inicio(Vacio, T),
    en_el_tablero(Formas, T, Saltos).

%!  en_el_tablero(+Formas:list, +T0, -Saltos:list) is semidet.
%
%   Saltos lleva de T0 por posiciones cuyas formas son, en orden, las de
%   Formas: en cada paso, el primer salto que deja una posición de la
%   forma pedida.
en_el_tablero([], _, []).
en_el_tablero([F|Fs], T0, [S|Ss]) :-
    once(( salto(S, T0, T),
           forma(T, F) )),
    en_el_tablero(Fs, T, Ss).
