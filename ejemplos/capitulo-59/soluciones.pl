:- encoding(utf8).

% Capítulo 59 - Soluciones de los ejercicios 2, 3 y 11: más metallamadas,
% los predicados sin llamadas y el orden de un programa por capas.
%
% solo-local: carga problemas.pl.
%
%?- metas(setup_call_cleanup(abrir, usar, cerrar), Ms).
%?- sin_llamadas(notas, Ps).
%?- capas(notas, Capas).

:- ensure_loaded(problemas).

% Ejercicio 2: cuatro metallamadas más para la tabla de la versión 1.

%!  meta_argumento(+Meta, -G, -Extra:integer) is nondet.
%
%   Cláusulas agregadas: with_output_to/2 ejecuta su segundo argumento;
%   setup_call_cleanup/3, los tres; call_cleanup/2, los dos; not/1, el
%   único.
meta_argumento(with_output_to(_, G), G, 0).
meta_argumento(setup_call_cleanup(S, _, _), S, 0).
meta_argumento(setup_call_cleanup(_, G, _), G, 0).
meta_argumento(setup_call_cleanup(_, _, C), C, 0).
meta_argumento(call_cleanup(G, _), G, 0).
meta_argumento(call_cleanup(_, C), C, 0).
meta_argumento(not(G), G, 0).

% Ejercicio 3: los predicados que nadie llama.

%!  sin_llamadas_de(+Clausulas:list, +Raices:list, -Ps:list) is det.
%
%   Ps son los predicados definidos en Clausulas que no están en Raices y
%   que ningún otro predicado llama, ordenados.
sin_llamadas_de(Clausulas, Raices, Ps) :-
    definidos(Clausulas, Ds),
    findall(P, ( member(P, Ds),
                 \+ memberchk(P, Raices),
                 \+ ( llama_de(Clausulas, Q, P),
                      Q \== P ) ),
            Ps).

%!  sin_llamadas_hasta_el_fin_de(+Clausulas, +Raices, -Ps:list) is det.
%
%   Ps son los predicados que se quitan si se borran, una y otra vez, las
%   cláusulas de los que no tienen llamadas, hasta que no queda ninguno.
sin_llamadas_hasta_el_fin_de(Clausulas, Raices, Ps) :-
    sin_llamadas_de(Clausulas, Raices, Ps0),
    (   Ps0 == []
    ->  Ps = []
    ;   exclude(de_alguno(Ps0), Clausulas, Resto),
        sin_llamadas_hasta_el_fin_de(Resto, Raices, Ps1),
        append(Ps0, Ps1, Ps2),
        sort(Ps2, Ps)
    ).

%!  de_alguno(+Ps:list, +Clausula) is semidet.
%
%   Clausula es de uno de los predicados Ps.
de_alguno(Ps, Clausula) :-
    cabeza_cuerpo(Clausula, Cabeza, _),
    indicador(Cabeza, P),
    memberchk(P, Ps).

%!  sin_llamadas(+Programa, -Ps:list) is det.
%
%   sin_llamadas_de/3 sobre las cláusulas y los puntos de entrada del
%   programa llamado Programa.
sin_llamadas(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    raices(Programa, Raices),
    sin_llamadas_de(Clausulas, Raices, Ps).

%!  sin_llamadas_hasta_el_fin(+Programa, -Ps:list) is det.
%
%   sin_llamadas_hasta_el_fin_de/3 sobre las cláusulas y los puntos de
%   entrada del programa llamado Programa.
sin_llamadas_hasta_el_fin(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    raices(Programa, Raices),
    sin_llamadas_hasta_el_fin_de(Clausulas, Raices, Ps).

% Ejercicio 11: el programa por capas.

%!  capas_de(+Clausulas:list, -Capas:list(list)) is det.
%
%   Capas son las componentes fuertemente conexas del grafo, todas, en un
%   orden en que cada una llama solo a las que vienen después: el orden
%   topológico del grafo condensado.
capas_de(Clausulas, Capas) :-
    grafo(Clausulas, Grafo),
    transitive_closure(Grafo, Clausura),
    vertices(Grafo, Vs),
    maplist(componente_de(Clausura), Vs, Cs0),
    sort(Cs0, Componentes),
    edges(Grafo, Arcos),
    findall(CP-CQ, ( member(P-Q, Arcos),
                     componente_de(Clausura, P, CP),
                     componente_de(Clausura, Q, CQ),
                     CP \== CQ ),
            ArcosC),
    vertices_edges_to_ugraph(Componentes, ArcosC, Condensado),
    top_sort(Condensado, Capas).

%!  componente_de(+Clausura, +P, -Componente:list) is det.
%
%   Componente es la lista ordenada de P y los predicados que P alcanza y
%   lo alcanzan, según la clausura transitiva del grafo.
componente_de(Clausura, P, Componente) :-
    neighbours(P, Clausura, SP),
    findall(Q, ( member(Q, SP),
                 neighbours(Q, Clausura, SQ),
                 ord_memberchk(P, SQ) ),
            Qs),
    sort([P|Qs], Componente).

%!  capas(+Programa, -Capas:list(list)) is det.
%
%   capas_de/2 sobre las cláusulas del programa llamado Programa.
capas(Programa, Capas) :-
    clausulas(Programa, Clausulas),
    capas_de(Clausulas, Capas).
