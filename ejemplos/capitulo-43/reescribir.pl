:- encoding(utf8).

% Capítulo 43 - Reglas de reescritura escritas como datos y convertidas
% en cláusulas al cargarlas.
%
% Una regla se escribe Izq ~> Der si Condicion, o Izq ~> Der si no tiene
% condición. En la Condicion, con(T) exige que T contenga la incógnita y
% libre(T), que no la contenga; cualquier otro objetivo queda igual.
% expandir_regla/2 convierte la regla en una cláusula de regla/3, que
% recibe la incógnita como primer argumento: un módulo que define
% term_expansion/2 con expandir_regla/2 carga sus reglas como cláusulas.
% reescribir/4 aplica una regla a un subtérmino cualquiera.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- expandir_regla((W * W ~> W ^ 2 si con(W)), C), portray_clause(C).
%?- con(x, 2 * sin(x)).

:- module(reescribir,
          [ op(1100, xfx, ~>),
            op(1150, xfx, si),
            expandir_regla/2,
            reescribir/4,
            con/2,
            libre/2
          ]).

:- meta_predicate
    reescribir(3, +, +, -).

%!  expandir_regla(+Regla, -Clausula) is semidet.
%
%   Clausula es la cláusula de regla/3 que corresponde a la Regla, escrita
%   Izq ~> Der si Condicion o Izq ~> Der. Falla con cualquier otro término.
expandir_regla((Izq ~> Der si Condicion), (regla(X, Izq, Der) :- Cuerpo)) :-
    condicion(Condicion, X, Cuerpo).
expandir_regla((Izq ~> Der), regla(_, Izq, Der)).

%!  condicion(+Condicion, ?X, -Cuerpo) is det.
%
%   Cuerpo es la Condicion con la incógnita X agregada a con/1 y libre/1.
condicion((A, B), X, (CA, CB)) :-
    !,
    condicion(A, X, CA),
    condicion(B, X, CB).
condicion(con(T), X, con(X, T)) :-
    !.
condicion(libre(T), X, libre(X, T)) :-
    !.
condicion(Objetivo, _, Objetivo).

%!  reescribir(:Regla, +X:atom, +E0, -E) is nondet.
%
%   E es E0 con un subtérmino reescrito por call(Regla, X, S0, S): primero
%   la raíz, después cada argumento de izquierda a derecha. Hay una
%   respuesta por cada subtérmino y cada regla que se aplica.
reescribir(Regla, X, E0, E) :-
    call(Regla, X, E0, E).
reescribir(Regla, X, E0, E) :-
    compound(E0),
    compound_name_arguments(E0, Nombre, Args0),
    append(Antes, [A0|Despues], Args0),
    reescribir(Regla, X, A0, A),
    append(Antes, [A|Despues], Args),
    compound_name_arguments(E, Nombre, Args).

%!  con(+X:atom, +T) is semidet.
%
%   El término cerrado T contiene la incógnita X.
con(X, T) :-
    once(sub_term(X, T)).

%!  libre(+X:atom, +T) is semidet.
%
%   El término cerrado T no contiene la incógnita X.
libre(X, T) :-
    \+ sub_term(X, T).
