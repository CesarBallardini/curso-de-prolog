:- encoding(utf8).

% Capítulo 85 - Versión 1: los programas que el motor acepta.
%
% Un programa es una lista de cláusulas Cabeza :- Cuerpo, como en el
% capítulo 38; un hecho tiene el cuerpo true. El motor evalúa programas
% Datalog seguros: ningún argumento de un átomo es un término compuesto,
% cada variable de la cabeza aparece en un literal positivo del cuerpo, y
% cada variable de un literal negado, de una comparación o de la expresión
% de is/2 está ligada por un literal anterior. problemas/2 da lo que impide
% evaluar un programa, y seguro/1 dice si no hay nada.
%
% solo-local: es un módulo que cargan los otros archivos del capítulo.
%
%?- problemas([(p(X) :- q(X)), (r(Y) :- \+ q(Y))], Ps).
%?- seguro([(camino(X, Y) :- arco(X, Z), camino(Z, Y))]).

:- module(seguro,
          [ literales/2,
            problemas/2,
            seguro/1,
            comparacion/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).

%!  literales(+Cuerpo, -Literales:list) is det.
%
%   Literales son las partes de la conjunción Cuerpo, de izquierda a
%   derecha; el cuerpo true no tiene ninguna.
literales(Cuerpo, Literales) :-
    (   Cuerpo == true
    ->  Literales = []
    ;   Cuerpo = (A, B)
    ->  literales(A, La),
        literales(B, Lb),
        append(La, Lb, Literales)
    ;   Literales = [Cuerpo]
    ).

% comparacion(C): C es una comparación aritmética.
comparacion(_ < _).
comparacion(_ > _).
comparacion(_ =< _).
comparacion(_ >= _).
comparacion(_ =:= _).
comparacion(_ =\= _).

%!  problemas(+Clausulas:list, -Problemas:list) is det.
%
%   Problemas son, en el orden de las cláusulas, los motivos por los que
%   Clausulas no es un programa Datalog seguro: funcion(T), un argumento
%   compuesto; cabeza_libre(C), una cabeza con una variable que ningún
%   literal positivo liga; y negacion_libre(L), comparacion_libre(L) o
%   aritmetica_libre(L), un literal que se evalúa con variables libres.
problemas(Clausulas, Problemas) :-
    maplist(problemas_clausula, Clausulas, PorClausula),
    append(PorClausula, Problemas).

%!  seguro(+Clausulas:list) is semidet.
%
%   Clausulas es un programa Datalog seguro: no tiene problemas.
seguro(Clausulas) :-
    problemas(Clausulas, []).

%!  problemas_clausula(+Clausula, -Problemas:list) is det.
%
%   Problemas son los de una sola cláusula Cabeza :- Cuerpo: primero los
%   argumentos compuestos, después los literales del cuerpo que se
%   evaluarían con variables libres, y al final la cabeza.
problemas_clausula(Cabeza :- Cuerpo, Problemas) :-
    literales(Cuerpo, Ls),
    findall(funcion(T),
            ( member(L, [Cabeza|Ls]),
              argumento_compuesto(L, T) ),
            Fs),
    recorrer(Ls, [], Ligadas, Ns),
    term_variables(Cabeza, Vs0),
    sort(Vs0, Vs),
    (   ord_subset(Vs, Ligadas)
    ->  Cs = []
    ;   Cs = [cabeza_libre(Cabeza)]
    ),
    append([Fs, Ns, Cs], Problemas).

%!  argumento_compuesto(+Literal, -T) is nondet.
%
%   T es un argumento compuesto de un átomo de Literal, negado o no. Las
%   comparaciones y is/2 no cuentan: sus expresiones son compuestas.
argumento_compuesto(L, T) :-
    (   L = (\+ A)
    ->  argumento_compuesto(A, T)
    ;   ( L = (_ is _) ; comparacion(L) )
    ->  fail
    ;   compound(L),
        arg(_, L, T),
        compound(T)
    ).

%!  recorrer(+Literales:list, +Ligadas0:list, -Ligadas:list,
%!           -Problemas:list) is det.
%
%   Recorre los literales de izquierda a derecha. Ligadas son las variables
%   ligadas al final, como conjunto ordenado, empezando por Ligadas0; un
%   literal positivo liga las suyas, e is/2 su lado izquierdo. Problemas
%   son los literales que se evaluarían con una variable libre.
recorrer([], Ligadas, Ligadas, []).
recorrer([L|Ls], Ligadas0, Ligadas, Problemas) :-
    literal(L, Ligadas0, Ligadas1, Problemas, Resto),
    recorrer(Ls, Ligadas1, Ligadas, Resto).

%!  literal(+L, +Ligadas0:list, -Ligadas:list, -Problemas:list, ?Resto)
%!      is det.
%
%   Problemas es la lista diferencia Problemas-Resto con el problema de L,
%   si lo tiene, con las variables Ligadas0; Ligadas agrega las que L liga.
literal(L, Ligadas0, Ligadas, Problemas, Resto) :-
    (   L = (\+ A)
    ->  Ligadas = Ligadas0,
        exigir(A, Ligadas0, negacion_libre(L), Problemas, Resto)
    ;   L = (X is E)
    ->  exigir(E, Ligadas0, aritmetica_libre(L), Problemas, Resto),
        ligar(X, Ligadas0, Ligadas)
    ;   comparacion(L)
    ->  Ligadas = Ligadas0,
        exigir(L, Ligadas0, comparacion_libre(L), Problemas, Resto)
    ;   Problemas = Resto,
        ligar(L, Ligadas0, Ligadas)
    ).

%!  exigir(+T, +Ligadas:list, +Problema, -Problemas:list, ?Resto) is det.
%
%   Problemas es [Problema|Resto] si T tiene una variable que no está en
%   Ligadas, y Resto si no.
exigir(T, Ligadas, Problema, Problemas, Resto) :-
    term_variables(T, Vs0),
    sort(Vs0, Vs),
    (   ord_subset(Vs, Ligadas)
    ->  Problemas = Resto
    ;   Problemas = [Problema|Resto]
    ).

%!  ligar(+T, +Ligadas0:list, -Ligadas:list) is det.
%
%   Ligadas agrega a Ligadas0 las variables de T.
ligar(T, Ligadas0, Ligadas) :-
    term_variables(T, Vs0),
    sort(Vs0, Vs),
    ord_union(Ligadas0, Vs, Ligadas).
