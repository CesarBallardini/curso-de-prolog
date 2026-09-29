:- encoding(utf8).

% Capítulo 68 - Versión 2: búsqueda en una sola dirección.
%
% La búsqueda de lo específico a lo general guarda el conjunto S de los
% conceptos más específicos consistentes con los ejemplos. Parte de vacio
% y, con cada positivo que S no cubre, lo reemplaza por su generalización
% mínima que lo cubre: la lgg del capítulo 67. Los negativos solo sirven
% para descartar: se guardan, y un concepto de S que cubre alguno se
% elimina.
%
% La búsqueda de lo general a lo específico guarda el conjunto G de los
% conceptos más generales consistentes. Parte del concepto que cubre todo
% y, con cada negativo que un concepto de G cubre, lo reemplaza por sus
% especializaciones mínimas que no lo cubren: fijar un atributo libre en
% un valor distinto del que tiene el negativo. Para eso necesita conocer
% los valores de cada atributo. Los positivos solo sirven para descartar.
%
% solo-local: carga espacio.pl, que carga un archivo de otro capítulo.
%
%?- una_direccion(esfera_roja, 3, S, G).

:- module(unidireccional,
          [ mas_general_de_todos/1,
            generalizacion/3,
            especializacion/3,
            generalizacion_con/3,
            cubre_instancia/2,
            especifico/2,
            general/2,
            una_direccion/4,
            mostrar_conceptos/1
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(espacio).

%!  mas_general_de_todos(-T) is det.
%
%   T es el concepto que cubre todas las instancias: una pieza con una
%   variable en cada atributo.
mas_general_de_todos(T) :-
    aggregate_all(count, atributo(_, _), N),
    functor(T, pieza, N).

%!  generalizacion(+S, +I, -S1) is det.
%
%   S1 es la generalización mínima del concepto S que cubre la instancia
%   I: I misma si S es vacio, la lgg de S e I en otro caso.
generalizacion(S, I, S1) :-
    (   S == vacio
    ->  S1 = I
    ;   lgg(S, I, S1)
    ).

%!  especializacion(+G, +I, -H) is nondet.
%
%   H es una especialización mínima del concepto G que no cubre la
%   instancia I: G con uno de sus atributos libres fijado en un valor
%   distinto del que tiene I. Una respuesta por cada atributo libre y
%   cada valor. H es una copia: no comparte variables con G.
especializacion(G, I, H) :-
    findall(Vs, atributo(_, Vs), Vss),
    nth1(K, Vss, Vs),
    arg(K, G, A),
    var(A),
    arg(K, I, V0),
    member(V, Vs),
    V \== V0,
    copy_term(G, H),
    arg(K, H, V).

%!  especifico(+Ejs:list, -S:list) is det.
%
%   S es el conjunto de los conceptos más específicos consistentes con
%   Ejs, calculado de lo específico a lo general. Es vacío si ningún
%   concepto es consistente.
especifico(Ejs, S) :-
    foldl(paso_especifico, Ejs, s([vacio], []), s(S, _)).

%!  paso_especifico(+Ej, +Estado0, -Estado) is det.
%
%   Estado es s(S, Negs) después de ver el ejemplo Ej: S, los conceptos
%   más específicos, y Negs, los negativos vistos.
paso_especifico(pos(I), s(S0, Negs), s(S, Negs)) :-
    maplist(generalizacion_con(I), S0, S1),
    exclude(cubre_alguno(Negs), S1, S).
paso_especifico(neg(I), s(S0, Negs), s(S, [I|Negs])) :-
    exclude(cubre_instancia(I), S0, S).

%!  general(+Ejs:list, -G:list) is det.
%
%   G es el conjunto de los conceptos más generales consistentes con Ejs,
%   calculado de lo general a lo específico. Es vacío si ningún concepto
%   es consistente.
general(Ejs, G) :-
    mas_general_de_todos(T),
    foldl(paso_general, Ejs, g([T], []), g(G, _)).

%!  una_direccion(+Nombre, +K:integer, -S:list, -G:list) is det.
%
%   S y G son los conjuntos que calculan especifico/2 y general/2 con los
%   primeros K ejemplos de la secuencia Nombre.
una_direccion(Nombre, K, S, G) :-
    prefijo(Nombre, K, Ejs),
    especifico(Ejs, S),
    general(Ejs, G).

%!  paso_general(+Ej, +Estado0, -Estado) is det.
%
%   Estado es g(G, Pos) después de ver el ejemplo Ej: G, los conceptos más
%   generales, y Pos, los positivos vistos.
paso_general(pos(I), g(G0, Pos), g(G, [I|Pos])) :-
    include(cubre_instancia(I), G0, G).
paso_general(neg(I), g(G0, Pos), g(G, Pos)) :-
    foldl(especializar_si_cubre(I, Pos), G0, [], G1),
    maximos(G1, G2),
    conjunto(G2, G).

%!  especializar_si_cubre(+I, +Pos:list, +C, +Gs0:list, -Gs:list) is det.
%
%   Gs es Gs0 con C agregado si C no cubre el negativo I, o con las
%   especializaciones mínimas de C que no lo cubren y cubren todos los
%   positivos de Pos.
especializar_si_cubre(I, Pos, C, Gs0, Gs) :-
    (   cubre(C, I)
    ->  findall(H, ( especializacion(C, I, H),
                     forall(member(P, Pos), cubre(H, P)) ), Hs),
        append(Gs0, Hs, Gs)
    ;   append(Gs0, [C], Gs)
    ).

%!  generalizacion_con(+I, +S, -S1) is det.
%
%   generalizacion/3 con la instancia como primer argumento, para
%   maplist/3.
generalizacion_con(I, S, S1) :-
    generalizacion(S, I, S1).

%!  cubre_instancia(+I, @C) is semidet.
%
%   El concepto C cubre la instancia I.
cubre_instancia(I, C) :-
    cubre(C, I).

%!  cubre_alguno(+Is:list, @C) is semidet.
%
%   El concepto C cubre alguna de las instancias de Is.
cubre_alguno(Is, C) :-
    member(I, Is),
    cubre(C, I),
    !.

%!  mostrar_conceptos(+Cs:list) is det.
%
%   Escribe los conceptos de Cs, uno por línea, con un _ en cada atributo
%   libre.
mostrar_conceptos(Cs) :-
    forall(member(C, Cs),
           \+ \+ ( term_variables(C, Vs),
                   maplist(=('$VAR'('_')), Vs),
                   format("~W~n", [C, [numbervars(true),
                                       spacing(next_argument)]]) )).
