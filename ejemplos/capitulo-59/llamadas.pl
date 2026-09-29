:- encoding(utf8).

% Capítulo 59 - Versión 1: el grafo de llamadas de un programa escrito como
% una lista de cláusulas.
%
% Un programa es una lista de términos Cabeza :- Cuerpo, o Cabeza para un
% hecho, y clausulas/2 la da por el nombre del programa. metas/2 recorre un
% cuerpo y devuelve las metas que llama, en orden: atraviesa las
% construcciones de control (la conjunción, la disyunción, el condicional y
% la negación) y entra en los argumentos que las metallamadas, como
% findall/3, forall/2 o maplist/N, ejecutan como metas. llama/3 es el arco
% del grafo: el predicado P tiene una cláusula que llama a Q. Cada análisis
% tiene dos formas: el que termina en _de trabaja sobre la lista de
% cláusulas, y el otro recibe el nombre del programa.
%
% clausulas/2, meta_argumento/3 y predefinido/1 son multifile, para que otro
% archivo les agregue cláusulas: otros programas, y más conocimiento sobre
% el sistema.
%
%?- llamadas(notas, mostrar/1, Qs).
%?- llama(notas, P, promedio/2).
%?- metas((a, (b -> c ; \+ d), findall(X, e(X), _)), Ms).

:- multifile clausulas/2, meta_argumento/3, predefinido/1.

%!  clausulas(+Programa, -Clausulas:list) is semidet.
%
%   Clausulas son las cláusulas del programa que se llama Programa. Falla si
%   no hay un programa con ese nombre. El de notas calcula los promedios y
%   las medianas de las notas de unos alumnos, y tiene defectos a propósito:
%   promedo/2 no existe, y nada llama a varianza/2.
clausulas(notas, [
    ( informe :-
        alumnos(As),
        maplist(mostrar, As),
        forall(mejor(A), format("Mejor promedio: ~w~n", [A])) ),
    ( alumnos(As) :-
        findall(A, notas(A, _), As) ),
    notas(ana, [8, 9, 10]),
    notas(bruno, [4, 6, 5, 7]),
    notas(carla, []),
    ( mostrar(A) :-
        notas(A, Ns),
        (   promedio(Ns, P)
        ->  mediana(Ns, M),
            format("~w: promedio ~w, mediana ~w~n", [A, P, M])
        ;   format("~w: sin notas~n", [A])
        ) ),
    ( promedio(Ns, P) :-
        Ns \== [],
        suma(Ns, S),
        length(Ns, L),
        P is S / L ),
    suma([], 0),
    ( suma([N|Ns], S) :-
        suma(Ns, S0),
        S is S0 + N ),
    ( mediana(Ns, M) :-
        msort(Ns, Os),
        length(Os, L),
        I is L // 2,
        (   longitud_par(Os)
        ->  nth0(I, Os, B),
            nth1(I, Os, A),
            M is (A + B) / 2
        ;   nth0(I, Os, M)
        ) ),
    longitud_par([]),
    ( longitud_par([_|Xs]) :-
        longitud_impar(Xs) ),
    ( longitud_impar([_|Xs]) :-
        longitud_par(Xs) ),
    ( mejor(A) :-
        notas(A, Ns),
        promedio(Ns, P),
        \+ ( notas(B, Ms),
             B \== A,
             promedo(Ms, Q),
             Q > P ) ),
    ( varianza(Ns, V) :-
        promedio(Ns, P),
        maplist(desvio2(P), Ns, Ds),
        suma(Ds, S),
        length(Ns, L),
        V is S / L ),
    ( desvio2(P, N, D) :-
        D is (N - P) ** 2 )
]).

% predefinido(P): P es un predicado del sistema, que el programa no define.
predefinido(true/0).
predefinido(fail/0).
predefinido(!/0).
predefinido((=)/2).
predefinido((\==)/2).
predefinido((is)/2).
predefinido((<)/2).
predefinido((>)/2).
predefinido((>=)/2).
predefinido(length/2).
predefinido(msort/2).
predefinido(nth0/3).
predefinido(nth1/3).
predefinido(format/2).
predefinido(findall/3).
predefinido(forall/2).
predefinido(maplist/2).
predefinido(maplist/3).
predefinido(maplist/4).

%!  meta_argumento(+Meta, -G, -Extra:integer) is nondet.
%
%   La metallamada Meta ejecuta G como una meta con Extra argumentos más.
%   G queda libre cuando el programa lo calcula durante la ejecución.
meta_argumento(once(G), G, 0).
meta_argumento(ignore(G), G, 0).
meta_argumento(findall(_, G, _), G, 0).
meta_argumento(findall(_, G, _, _), G, 0).
meta_argumento(aggregate_all(_, G, _), G, 0).
meta_argumento(forall(C, _), C, 0).
meta_argumento(forall(_, A), A, 0).
meta_argumento(catch(G, _, _), G, 0).
meta_argumento(catch(_, _, R), R, 0).
meta_argumento(bagof(_, G0, _), G, 0) :-
    sin_cuantificar(G0, G).
meta_argumento(setof(_, G0, _), G, 0) :-
    sin_cuantificar(G0, G).
meta_argumento(Meta, G, Extra) :-
    compound(Meta),
    compound_name_arguments(Meta, Nombre, [G|Resto]),
    length(Resto, N),
    extra(Nombre, N, Extra).

%!  extra(?Nombre, ?N:integer, ?Extra:integer) is nondet.
%
%   Una metallamada Nombre con N argumentos después del primero llama a su
%   primer argumento con Extra argumentos más.
extra(call, N, N).
extra(maplist, N, N) :-
    N >= 1.
extra(foldl, N, N) :-
    N >= 3.
extra(include, 2, 1).
extra(exclude, 2, 1).
extra(partition, 3, 1).

%!  sin_cuantificar(+G0, -G) is det.
%
%   G es la meta G0 sin las variables cuantificadas con ^ de bagof/3 y
%   setof/3.
sin_cuantificar(G0, G) :-
    (   nonvar(G0),
        G0 = _^G1
    ->  sin_cuantificar(G1, G)
    ;   G = G0
    ).

%!  metas(+Cuerpo, -Metas:list) is det.
%
%   Metas son las metas que Cuerpo llama, en el orden en que aparecen,
%   incluidas las que ejecutan sus metallamadas. Las construcciones de
%   control no son metas: se atraviesan; true tampoco.
metas(Cuerpo, Metas) :-
    phrase(metas_de(Cuerpo), Metas).

%!  metas_de(+Cuerpo)// is det.
%
%   Describe la lista de las metas que llama Cuerpo.
metas_de(G) -->
    { var(G) },
    !.
metas_de(true) -->
    !.
metas_de((A, B)) -->
    !,
    metas_de(A),
    metas_de(B).
metas_de((A ; B)) -->
    !,
    metas_de(A),
    metas_de(B).
metas_de((A -> B)) -->
    !,
    metas_de(A),
    metas_de(B).
metas_de((A *-> B)) -->
    !,
    metas_de(A),
    metas_de(B).
metas_de(\+ A) -->
    !,
    metas_de(A).
metas_de(_:G) -->
    !,
    metas_de(G).
metas_de(G) -->
    [G],
    { findall(A, llamado_por_meta(G, A), As) },
    metas_de_lista(As).

%!  metas_de_lista(+Cuerpos:list)// is det.
%
%   Describe las metas de cada cuerpo de la lista, en orden.
metas_de_lista([]) -->
    [].
metas_de_lista([C|Cs]) -->
    metas_de(C),
    metas_de_lista(Cs).

%!  llamado_por_meta(+Meta, -G) is nondet.
%
%   Meta es una metallamada que ejecuta la meta G, ya con los argumentos
%   que Meta le agrega. No hay respuesta para un argumento libre.
llamado_por_meta(Meta, G) :-
    meta_argumento(Meta, G0, Extra),
    callable(G0),
    length(Agregados, Extra),
    G0 =.. Partes0,
    append(Partes0, Agregados, Partes),
    G =.. Partes.

%!  cabeza_cuerpo(+Clausula, -Cabeza, -Cuerpo) is det.
%
%   Clausula es Cabeza :- Cuerpo; un hecho tiene el cuerpo true.
cabeza_cuerpo(Clausula, Cabeza, Cuerpo) :-
    (   Clausula = (Cabeza :- Cuerpo)
    ->  true
    ;   Cabeza = Clausula,
        Cuerpo = true
    ).

%!  indicador(+Meta, -Indicador) is det.
%
%   Indicador es Nombre/Aridad del predicado de Meta.
indicador(Meta, Nombre/Aridad) :-
    functor(Meta, Nombre, Aridad).

%!  definidos(+Clausulas:list, -Ps:list) is det.
%
%   Ps son los indicadores de los predicados que Clausulas define, ordenados
%   y sin repetidos.
definidos(Clausulas, Ps) :-
    findall(P, ( member(C, Clausulas),
                 cabeza_cuerpo(C, H, _),
                 indicador(H, P) ),
            Ps0),
    sort(Ps0, Ps).

%!  llamadas_de(+Clausulas:list, ?P, -Qs:list) is nondet.
%
%   P es un predicado definido en Clausulas y Qs son los predicados que sus
%   cláusulas llaman, en el orden en que aparecen y sin repetidos. Con P
%   ligado hay una respuesta o ninguna.
llamadas_de(Clausulas, P, Qs) :-
    definidos(Clausulas, Ps),
    (   ground(P)
    ->  memberchk(P, Ps)
    ;   member(P, Ps)
    ),
    findall(Q, ( member(C, Clausulas),
                 cabeza_cuerpo(C, H, B),
                 indicador(H, P),
                 metas(B, Ms),
                 member(M, Ms),
                 indicador(M, Q) ),
            Qs0),
    list_to_set(Qs0, Qs).

%!  llama_de(+Clausulas:list, ?P, ?Q) is nondet.
%
%   El predicado P, definido en Clausulas, llama a Q: el arco P-Q del grafo
%   de llamadas.
llama_de(Clausulas, P, Q) :-
    llamadas_de(Clausulas, P, Qs),
    member(Q, Qs).

%!  llamadas(+Programa, ?P, -Qs:list) is nondet.
%
%   llamadas_de/3 sobre las cláusulas del programa llamado Programa.
llamadas(Programa, P, Qs) :-
    clausulas(Programa, Clausulas),
    llamadas_de(Clausulas, P, Qs).

%!  llama(+Programa, ?P, ?Q) is nondet.
%
%   llama_de/3 sobre las cláusulas del programa llamado Programa.
llama(Programa, P, Q) :-
    clausulas(Programa, Clausulas),
    llama_de(Clausulas, P, Q).

%!  arcos(+Clausulas:list, -Arcos:list) is det.
%
%   Arcos son los arcos P-Q del grafo de llamadas de Clausulas, ordenados.
arcos(Clausulas, Arcos) :-
    findall(P-Q, llama_de(Clausulas, P, Q), Arcos0),
    sort(Arcos0, Arcos).
