:- encoding(utf8).

% Capítulo 67 - Versión 5: la mejor cláusula y las definiciones
% recursivas.
%
% La búsqueda de la versión 4 se queda con la primera cláusula
% consistente que encuentra. mejor_clausula/9 recorre los refinamientos
% por niveles: el nivel D son las cláusulas a D refinamientos de la más
% general que todavía cubren el ejemplo. En el primer nivel que tiene
% cláusulas consistentes elige la que cubre más positivos, y ante un
% empate la primera generada.
%
% Para aprender una relación recursiva, la relación entra en el lenguaje
% de hipótesis y los ejemplos positivos entran en el modelo: la cobertura
% extensional de una cláusula recursiva consulta los positivos, como si
% la definición ya estuviera aprendida. La hipótesis terminada se prueba
% en forma intensional, sin los positivos: probar/4 es el intérprete
% vainilla del capítulo 33 con un límite de profundidad, sobre las
% cláusulas de la hipótesis y el modelo de fondo.
%
% solo-local: carga familia.pl, que carga archivos de otros capítulos.
%
%?- aprender_rec(antepasado, H, N), maplist(mostrar, H).
%?- aprender_rec(abuelo, H, N), maplist(mostrar, H).

:- module(recursion,
          [ mejor_clausula/9,
            inductivo/7,
            aprender_rec/3,
            con_negativos/4,
            probar/4,
            extension_intensional/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(descendente).

%!  mejor_clausula(+E, +Pos:list, +Negs:list, +M:list, +L:list,
%!                 +Max:integer, -R, +N0:integer, -N:integer) is det.
%
%   R es encontrada(C), con C la cláusula consistente del primer nivel que
%   tiene alguna, que cubre más ejemplos de Pos; o ninguna, si no hay una
%   hasta el nivel Max. Todas cubren E. N - N0 es la cantidad de
%   cláusulas generadas.
mejor_clausula(E, Pos, Negs, M, L, Max, R, N0, N) :-
    functor(E, Nombre, Aridad),
    functor(H, Nombre, Aridad),
    nivel(0, Max, [(H :- [])], E-Pos-Negs-M-L, R, N0, N).

%!  nivel(+D:integer, +Max:integer, +Frontera:list, +Problema, -R,
%!        +N0:integer, -N:integer) is det.
%
%   Frontera son las cláusulas del nivel D. Si alguna es consistente, R
%   es la mejor; si no, se pasa al nivel siguiente, hasta Max.
nivel(D, Max, Frontera, E-Pos-Negs-M-L, R, N0, N) :-
    include(consistente_con(Negs, M), Frontera, Consistentes),
    (   Consistentes = [_|_]
    ->  maplist(puntuar(Pos, M), Consistentes, Puntuadas),
        sort(1, @>=, Puntuadas, [_-C|_]),
        R = encontrada(C),
        N = N0
    ;   D < Max
    ->  findall(S, ( member(C0, Frontera),
                     refinar(L, C0, S) ),
                Todos),
        length(Todos, K),
        N1 is N0 + K,
        include(cubre_ejemplo(E, M), Todos, Siguiente),
        D1 is D + 1,
        nivel(D1, Max, Siguiente, E-Pos-Negs-M-L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).

%!  consistente_con(+Negs:list, +M:list, +C) is semidet.
%
%   La cláusula C no cubre ningún ejemplo de Negs.
consistente_con(Negs, M, C) :-
    \+ cubre_alguno(C, Negs, M).

%!  cubre_ejemplo(+E, +M:list, +C) is semidet.
%
%   La cláusula C cubre el ejemplo E en el modelo M.
cubre_ejemplo(E, M, C) :-
    cubre(C, E, M).

%!  puntuar(+Pos:list, +M:list, +C, -Par:pair) is det.
%
%   Par es K-C, con K la cantidad de ejemplos de Pos que C cubre.
puntuar(Pos, M, C, K-C) :-
    include(cubierto(C, M), Pos, Cubiertos),
    length(Cubiertos, K).

%!  cubierto(+C, +M:list, +E) is semidet.
%
%   La cláusula C cubre el ejemplo E en el modelo M.
cubierto(C, M, E) :-
    cubre(C, E, M).

%!  inductivo(+Pos:list, +Negs:list, +M:list, +L:list, +Max:integer,
%!            -H:list, -N:integer) is det.
%
%   H es la hipótesis que el algoritmo de cobertura construye con
%   mejor_clausula/9; N es la cantidad de cláusulas generadas. La
%   puntuación cuenta los positivos que todavía no están cubiertos, y la
%   cobertura consulta el modelo M.
inductivo(Pos, Negs, M, L, Max, H, N) :-
    cubrir_mejor(Pos, Negs, M, L, Max, H, 0, N).

%!  cubrir_mejor(+Pos:list, +Negs:list, +M:list, +L:list, +Max:integer,
%!               -H:list, +N0:integer, -N:integer) is det.
%
%   H cubre los positivos Pos; N0 y N cuentan las cláusulas generadas.
cubrir_mejor([], _, _, _, _, [], N, N).
cubrir_mejor([E|Es], Negs, M, L, Max, [C|H], N0, N) :-
    mejor_clausula(E, Es, Negs, M, L, Max, R, N0, N1),
    (   R = encontrada(C)
    ->  exclude(cubierto(C, M), Es, Resto)
    ;   C = (E :- []),
        Resto = Es
    ),
    cubrir_mejor(Resto, Negs, M, L, Max, H, N1, N).

%!  aprender_rec(+Relacion, -H:list, -N:integer) is det.
%
%   H es la hipótesis para Relacion con la relación misma en el lenguaje,
%   los positivos agregados al modelo de fondo y a lo sumo tres
%   refinamientos por cláusula; N es la cantidad de cláusulas generadas.
aprender_rec(Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(Fondo),
    ord_union(Fondo, Pos, M),
    lenguaje(L0),
    append(L0, [Relacion/2], L),
    inductivo(Pos, Negs, M, L, 3, H, N).

%!  con_negativos(+Relacion, +K:integer, -H:list, -FP:integer) is det.
%
%   H es la hipótesis que inductivo/7 aprende para Relacion con todos los
%   positivos y solo los primeros K negativos, en su orden, sin la
%   relación en el lenguaje; FP es la cantidad de falsos positivos de su
%   extensión entre los pares de personas.
con_negativos(Relacion, K, H, FP) :-
    ejemplos(Relacion, Pos, Negs),
    length(Primeros, K),
    append(Primeros, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, Primeros, M, L, 3, H, _),
    evaluar_en(Relacion, H, M, _, FP, _).

%!  probar(+D:integer, +H:list, +Fondo:list, ?Meta) is nondet.
%
%   Meta se deduce de las cláusulas de H y de los átomos de Fondo con a
%   lo sumo D pasos de resolución con cláusulas de H.
probar(_, _, Fondo, Meta) :-
    member(Meta, Fondo).
probar(D, H, Fondo, Meta) :-
    D > 0,
    D1 is D - 1,
    member(C, H),
    copy_term(C, (Meta :- Cuerpo)),
    maplist(probar(D1, H, Fondo), Cuerpo).

%!  extension_intensional(+Relacion, +H:list, +D:integer, -Atomos:list)
%!      is det.
%
%   Atomos son los átomos Relacion(A, B), con A y B personas, que probar/4
%   deduce de H y del modelo de fondo con profundidad D.
extension_intensional(Relacion, H, D, Atomos) :-
    modelo_fondo(Fondo),
    findall(Atomo,
            ( persona(A),
              persona(B),
              Atomo =.. [Relacion, A, B],
              once(probar(D, H, Fondo, Atomo)) ),
            Atomos0),
    sort(Atomos0, Atomos).
