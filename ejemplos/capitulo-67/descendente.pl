:- encoding(utf8).

% Capítulo 67 - Versión 4: inducción descendente por refinamiento.
%
% La búsqueda parte de la cláusula más general de la relación, una cabeza
% con variables distintas y el cuerpo vacío, y la especializa con dos
% operaciones de la θ-subsunción: unificar dos variables de la cláusula o
% agregar al cuerpo un literal de un predicado del lenguaje de hipótesis.
% Un literal nuevo usa al menos una variable de la cláusula y a lo sumo
% una variable nueva. Como una especialización cubre menos que la cláusula
% de la que sale, la búsqueda descarta toda cláusula que ya no cubre el
% ejemplo positivo que se está explicando. La profundidad crece de a uno
% (profundización iterativa, capítulo 33) hasta encontrar una cláusula que
% cubre ese ejemplo y ningún negativo. Cada búsqueda cuenta las
% cláusulas que genera.
%
% El algoritmo de cobertura es el de la versión 3: busca una cláusula para
% el primer positivo sin cubrir, quita los positivos que cubre y repite.
% extension_en/4 da los átomos de la relación que una hipótesis cubre
% entre todos los pares de personas: una cláusula que no nombra en el
% cuerpo una variable de la cabeza vale para toda persona.
%
% solo-local: carga familia.pl, que carga archivos de otros capítulos.
%
%?- aprender_desc(abuelo, H, N), maplist(mostrar, H).

:- module(descendente,
          [ lenguaje/1,
            refinar/3,
            buscar_clausula/8,
            descendente/7,
            aprender_desc/3,
            extension_en/4,
            evaluar_en/6
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(ascendente).

%!  lenguaje(-L:list) is det.
%
%   L son los predicados del lenguaje de hipótesis: los de fondo.
lenguaje(L) :-
    findall(P, de_fondo(P), L).

%!  refinar(+L:list, +C0, -C) is nondet.
%
%   C es un refinamiento de la cláusula C0 con el lenguaje L: C0 con dos
%   de sus variables unificadas, o con un literal más al final del cuerpo,
%   distinto de los que ya están. C no tiene en el cuerpo un literal igual
%   a la cabeza, porque sería una tautología. C0 no queda ligada.
refinar(L, C0, C) :-
    refinamiento(L, C0, C),
    \+ tautologia(C).

%!  refinamiento(+L:list, +C0, -C) is nondet.
%
%   C es C0 con dos variables unificadas o con un literal más.
refinamiento(_, C0, C) :-
    copy_term(C0, C),
    term_variables(C, Vs),
    append(_, [X|Resto], Vs),
    member(Y, Resto),
    X = Y.
refinamiento(L, C0, (H :- B)) :-
    copy_term(C0, (H :- B0)),
    term_variables(H-B0, Vs),
    member(Nombre/Aridad, L),
    length(Args, Aridad),
    maplist(argumento(Vs, Nueva), Args),
    \+ maplist(==(Nueva), Args),
    Literal =.. [Nombre|Args],
    \+ ( member(Otro, B0),
         Otro == Literal ),
    append(B0, [Literal], B).

%!  tautologia(+C) is semidet.
%
%   El cuerpo de la cláusula C contiene un literal igual a la cabeza.
tautologia((H :- B)) :-
    member(L, B),
    L == H,
    !.

%!  argumento(+Vs:list, ?Nueva, -A) is nondet.
%
%   A es una de las variables Vs de la cláusula, o la variable nueva
%   Nueva.
argumento(Vs, _, A) :-
    member(A, Vs).
argumento(_, Nueva, Nueva).

%!  consistente(+C, +Negs:list, +M:list) is semidet.
%
%   La cláusula C no cubre ningún ejemplo de Negs.
consistente(C, Negs, M) :-
    \+ cubre_alguno(C, Negs, M).

%!  buscar_clausula(+E, +Negs:list, +M:list, +L:list, +Max:integer,
%!                  -R, +N0:integer, -N:integer) is det.
%
%   R es encontrada(C), con C la primera cláusula que cubre el ejemplo E
%   y ningún ejemplo de Negs, buscada con profundidad creciente hasta
%   Max refinamientos; o ninguna, si no la hay. N - N0 es la cantidad de
%   cláusulas generadas.
buscar_clausula(E, Negs, M, L, Max, R, N0, N) :-
    functor(E, Nombre, Aridad),
    functor(H, Nombre, Aridad),
    profundizar(0, Max, (H :- []), E-Negs-M-L, R, N0, N).

%!  profundizar(+D:integer, +Max:integer, +C, +Problema, -R,
%!              +N0:integer, -N:integer) is det.
%
%   Busca desde C con profundidad D, D + 1, ..., Max.
profundizar(D, Max, C, Problema, R, N0, N) :-
    buscar(D, C, Problema, R1, N0, N1),
    (   R1 = encontrada(_)
    ->  R = R1,
        N = N1
    ;   D < Max
    ->  D1 is D + 1,
        profundizar(D1, Max, C, Problema, R, N1, N)
    ;   R = ninguna,
        N = N1
    ).

%!  buscar(+D:integer, +C, +Problema, -R, +N0:integer, -N:integer) is det.
%
%   Búsqueda en profundidad desde C con a lo sumo D refinamientos. Solo
%   se siguen los refinamientos que cubren el ejemplo.
buscar(D, C, E-Negs-M-L, R, N0, N) :-
    (   consistente(C, Negs, M)
    ->  R = encontrada(C),
        N = N0
    ;   D > 0
    ->  findall(S, refinar(L, C, S), Todos),
        length(Todos, K),
        N1 is N0 + K,
        include(cubre_ejemplo(E, M), Todos, Hijos),
        D1 is D - 1,
        buscar_en(Hijos, D1, E-Negs-M-L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).

% cubre_ejemplo(E, M, C): la cláusula C cubre el ejemplo E.
cubre_ejemplo(E, M, C) :-
    cubre(C, E, M).

%!  buscar_en(+Cs:list, +D:integer, +Problema, -R, +N0:integer,
%!            -N:integer) is det.
%
%   Busca desde cada cláusula de Cs, en orden, hasta encontrar una.
buscar_en([], _, _, ninguna, N, N).
buscar_en([C|Cs], D, Problema, R, N0, N) :-
    buscar(D, C, Problema, R1, N0, N1),
    (   R1 = encontrada(_)
    ->  R = R1,
        N = N1
    ;   buscar_en(Cs, D, Problema, R, N1, N)
    ).

%!  descendente(+Pos:list, +Negs:list, +M:list, +L:list, +Max:integer,
%!              -H:list, -N:integer) is det.
%
%   H es la hipótesis que el algoritmo de cobertura construye buscando
%   cada cláusula con a lo sumo Max refinamientos; N es la cantidad de
%   cláusulas generadas. Un positivo sin cláusula queda como hecho.
descendente(Pos, Negs, M, L, Max, H, N) :-
    cubrir_desc(Pos, Negs, M, L, Max, H, 0, N).

%!  cubrir_desc(+Pos:list, +Negs:list, +M:list, +L:list, +Max:integer,
%!              -H:list, +N0:integer, -N:integer) is det.
%
%   H cubre los positivos Pos; N0 y N cuentan las cláusulas generadas.
cubrir_desc([], _, _, _, _, [], N, N).
cubrir_desc([E|Es], Negs, M, L, Max, [C|H], N0, N) :-
    buscar_clausula(E, Negs, M, L, Max, R, N0, N1),
    (   R = encontrada(C)
    ->  exclude(cubierto_por(C, M), Es, Resto)
    ;   C = (E :- []),
        Resto = Es
    ),
    cubrir_desc(Resto, Negs, M, L, Max, H, N1, N).

% cubierto_por(C, M, E): la cláusula C cubre el ejemplo E.
cubierto_por(C, M, E) :-
    cubre(C, E, M).

%!  aprender_desc(+Relacion, -H:list, -N:integer) is det.
%
%   H es la hipótesis que la inducción descendente construye para
%   Relacion con sus ejemplos, el modelo de fondo y a lo sumo tres
%   refinamientos por cláusula; N es la cantidad de cláusulas generadas.
aprender_desc(Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(M),
    lenguaje(L),
    descendente(Pos, Negs, M, L, 3, H, N).

%!  extension_en(+Relacion, +H:list, +M:list, -Atomos:list) is det.
%
%   Atomos son los átomos Relacion(A, B), con A y B personas, que alguna
%   cláusula de H cubre en el modelo M.
extension_en(Relacion, H, M, Atomos) :-
    findall(Atomo,
            ( persona(A),
              persona(B),
              Atomo =.. [Relacion, A, B],
              once(( member(C, H),
                     cubre(C, Atomo, M) )) ),
            Atomos0),
    sort(Atomos0, Atomos).

%!  evaluar_en(+Relacion, +H:list, +M:list, -Aciertos:integer,
%!             -FalsosPositivos:integer, -FalsosNegativos:integer) is det.
%
%   Compara extension_en/4 de H con la definición esperada de Relacion,
%   como evaluar/5 de la versión 3.
evaluar_en(Relacion, H, M, Aciertos, FalsosPositivos, FalsosNegativos) :-
    extension_en(Relacion, H, M, Cubiertos),
    ejemplos(Relacion, Pos, _),
    ord_intersection(Cubiertos, Pos, Comunes),
    ord_subtract(Cubiertos, Pos, Sobran),
    ord_subtract(Pos, Cubiertos, Faltan),
    length(Comunes, Aciertos),
    length(Sobran, FalsosPositivos),
    length(Faltan, FalsosNegativos).
