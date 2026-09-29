:- encoding(utf8).

% Capítulo 33 - El programa como datos: clause/2, predicate_property/2 y
% current_predicate/1 sobre un programa pequeño.
%
% clausulas/2 reúne las cláusulas de un predicado como términos
% Cabeza :- Cuerpo; describir/2 dice de qué clase es un predicado.
%
% solo-local: SWISH no permite predicate_property/2 con una cabeza variable.
%
%?- clausulas(antepasado/2, Cs).
%?- describir(antepasado/2, D).
%?- describir(visita/1, D).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

:- dynamic visita/1.

% visita(P): P visitó la casa; el programa agrega y quita estos hechos.
visita(ana).

%!  clausulas(+Indicador, -Clausulas:list) is semidet.
%
%   Clausulas son las cláusulas del predicado Nombre/Aridad, en el orden del
%   programa, como términos Cabeza :- Cuerpo; un hecho tiene el cuerpo true.
%   Falla si el predicado no está definido.
clausulas(Nombre/Aridad, Clausulas) :-
    current_predicate(Nombre/Aridad),
    functor(Cabeza, Nombre, Aridad),
    findall(Cabeza :- Cuerpo, clause(Cabeza, Cuerpo), Clausulas).

%!  describir(+Indicador, -Descripcion) is semidet.
%
%   Descripcion es predefinido para un predicado del sistema, y
%   dinamico(N) o estatico(N) para uno del programa con N cláusulas.
%   Falla si el predicado no está definido.
describir(Nombre/Aridad, Descripcion) :-
    current_predicate(Nombre/Aridad),
    functor(Cabeza, Nombre, Aridad),
    (   predicate_property(Cabeza, built_in)
    ->  Descripcion = predefinido
    ;   predicate_property(Cabeza, number_of_clauses(N)),
        (   predicate_property(Cabeza, dynamic)
        ->  Descripcion = dinamico(N)
        ;   Descripcion = estatico(N)
        )
    ).
