:- encoding(utf8).

% Capítulo 59 - Solución del ejercicio 9: el grafo de llamadas que recorre
% una ejecución, comparado con el que se lee del programa.
%
% arcos_usados/2 ejecuta una meta con una variante del intérprete de
% perfil.pl que anota cada arco Llamador-Llamado que recorre. sin_recorrer/3
% da los arcos del grafo estático, calculado con llamadas.pl sobre las
% cláusulas que clause/2 devuelve, que la ejecución no recorrió: lo que las
% pruebas de esa meta no cubren.
%
% solo-local: carga perfil.pl y llamadas.pl.
%
%?- arcos_usados(inversa([a], R), Arcos).
%?- sin_recorrer(inversa([a], _), [inversa/2, concatenar/3], Arcos).

:- ensure_loaded(perfil).
:- ensure_loaded(llamadas).

:- dynamic arco_usado/2.

%!  arcos_usados(+Meta, -Arcos:list(pair)) is det.
%
%   Arcos son los arcos Llamador-Llamado entre predicados del programa que
%   recorre la ejecución de Meta hasta su primera respuesta, o hasta que
%   falla; el llamador de Meta es '<consulta>'.
arcos_usados(Meta, Arcos) :-
    retractall(arco_usado(_, _)),
    (   resolver_desde(Meta, '<consulta>')
    ->  true
    ;   true
    ),
    findall(A-B, arco_usado(A, B), Arcos0),
    sort(Arcos0, Arcos).

%!  resolver_desde(+Meta, +Desde) is nondet.
%
%   Meta se prueba como con resolver/1 de perfil.pl, dentro de una cláusula
%   del predicado Desde, y se anota cada arco que se recorre.
resolver_desde(true, _).
resolver_desde((A, B), Desde) :-
    resolver_desde(A, Desde),
    resolver_desde(B, Desde).
resolver_desde((C -> T ; E), Desde) :-
    (   resolver_desde(C, Desde)
    ->  resolver_desde(T, Desde)
    ;   resolver_desde(E, Desde)
    ).
resolver_desde((A ; B), Desde) :-
    A \= (_ -> _),
    (   resolver_desde(A, Desde)
    ;   resolver_desde(B, Desde)
    ).
resolver_desde(\+ A, Desde) :-
    \+ resolver_desde(A, Desde).
resolver_desde(G, _) :-
    sistema(G),
    ejecutar(G).
resolver_desde(G, Desde) :-
    del_programa(G),
    indicador(G, P),
    anotar(Desde, P),
    clause(G, Cuerpo),
    resolver_desde(Cuerpo, P).

%!  anotar(+Desde, +P) is det.
%
%   Registra el arco Desde-P, una sola vez.
anotar(Desde, P) :-
    (   arco_usado(Desde, P)
    ->  true
    ;   assertz(arco_usado(Desde, P))
    ).

%!  clausulas_del_programa(+PIs:list, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas de los predicados PIs, obtenidas con
%   clause/2, en la representación de llamadas.pl.
clausulas_del_programa(PIs, Clausulas) :-
    findall(C, ( member(Nombre/Aridad, PIs),
                 functor(Cabeza, Nombre, Aridad),
                 clause(Cabeza, Cuerpo),
                 (   Cuerpo == true
                 ->  C = Cabeza
                 ;   C = (Cabeza :- Cuerpo)
                 ) ),
            Clausulas).

%!  sin_recorrer(+Meta, +PIs:list, -Arcos:list(pair)) is det.
%
%   Arcos son los arcos entre los predicados PIs que el programa tiene y la
%   ejecución de Meta no recorre.
sin_recorrer(Meta, PIs, Arcos) :-
    clausulas_del_programa(PIs, Clausulas),
    findall(P-Q, ( llama_de(Clausulas, P, Q),
                   memberchk(Q, PIs) ),
            Estaticos0),
    sort(Estaticos0, Estaticos),
    arcos_usados(Meta, Usados),
    ord_subtract(Estaticos, Usados, Arcos).
