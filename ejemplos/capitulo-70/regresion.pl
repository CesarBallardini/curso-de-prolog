:- encoding(utf8).

% Capítulo 70 - Lo que vale después de un plan, por regresión.
%
% Un plan es una lista de acciones, y el estado al que lleva no se guarda:
% se calcula hecho por hecho, hacia atrás. Un hecho vale después del plan
% si la última acción lo agrega, o si valía antes de ella y ella no lo
% borra; antes de la primera acción, vale si está dado en el estado
% inicial. Por eso el plan se guarda al revés, con la última acción
% primero: la regresión recorre la lista desde la cabeza. El mundo es un
% módulo, como cubos.pl, y es el primer argumento de cada predicado.
%
% solo-local: carga cubos.pl.
%
%?- vale(cubos, sussman, sobre(c, X), [mover(c, a, mesa)]).
%?- ejecutable(cubos, sussman, [mover(c, a, mesa), mover(b, mesa, c)]).

:- module(regresion,
          [ vale/4,
            preservada/3,
            es_prueba/2,
            ejecutable/3,
            logra/4
          ]).

:- use_module(cubos, []).
:- use_module(library(lists)).

%!  vale(+Mundo, +Inicio, ?Hecho, +Hechas:list) is nondet.
%
%   Hecho vale después de ejecutar, desde el estado inicial Inicio del
%   Mundo, las acciones de Hechas, que está al revés: la última primero.
vale(Mundo, _, Hecho, [Accion|_]) :-
    Mundo:agrega(Hecho, Accion).
vale(Mundo, Inicio, Hecho, [Accion|Antes]) :-
    preservada(Mundo, Hecho, Accion),
    vale(Mundo, Inicio, Hecho, Antes),
    preservada(Mundo, Hecho, Accion).
vale(Mundo, Inicio, Hecho, []) :-
    Mundo:dado(Inicio, Hecho).

%!  preservada(+Mundo, +Hecho, +Accion) is semidet.
%
%   Accion no borra Hecho. Las variables libres de los dos términos se
%   toman como objetos desconocidos, distintos de todo objeto conocido y
%   entre sí: la prueba se hace sobre una copia sin variables, y no liga
%   nada.
preservada(Mundo, Hecho, Accion) :-
    \+ \+ ( numbervars(Hecho-Accion, 0, _),
            \+ Mundo:borra(Hecho, Accion) ).

%!  es_prueba(+Mundo, +Hecho) is semidet.
%
%   Hecho es una prueba del Mundo, que se decide llamándola.
es_prueba(Mundo, Hecho) :-
    \+ \+ Mundo:prueba(Hecho).

%!  ejecutable(+Mundo, +Inicio, +Plan:list) is semidet.
%
%   Las acciones de Plan, en el orden en que se ejecutan, se pueden
%   ejecutar una tras otra desde Inicio: antes de cada una valen sus
%   precondiciones.
ejecutable(Mundo, Inicio, Plan) :-
    ejecutable_(Plan, Mundo, Inicio, []).

%!  ejecutable_(+Plan:list, +Mundo, +Inicio, +Hechas:list) is semidet.
%
%   Las acciones de Plan se pueden ejecutar una tras otra después de
%   Hechas, que está al revés.
ejecutable_([], _, _, _).
ejecutable_([Accion|Resto], Mundo, Inicio, Hechas) :-
    once(( Mundo:puede(Accion, Pre),
           forall(member(H, Pre), cumple(Mundo, Inicio, H, Hechas)) )),
    ejecutable_(Resto, Mundo, Inicio, [Accion|Hechas]).

%!  logra(+Mundo, +Inicio, +Plan:list, +Metas:list) is semidet.
%
%   Plan, en el orden en que se ejecuta, se puede ejecutar desde Inicio y
%   después valen todas las Metas.
logra(Mundo, Inicio, Plan, Metas) :-
    ejecutable(Mundo, Inicio, Plan),
    reverse(Plan, Hechas),
    forall(member(M, Metas), cumple(Mundo, Inicio, M, Hechas)).

%!  cumple(+Mundo, +Inicio, +Hecho, +Hechas:list) is semidet.
%
%   Hecho es una prueba que se cumple, o un hecho que vale después de
%   Hechas.
cumple(Mundo, Inicio, Hecho, Hechas) :-
    (   es_prueba(Mundo, Hecho)
    ->  call(Mundo:Hecho)
    ;   Mundo:siempre(Hecho)
    ->  true
    ;   once(vale(Mundo, Inicio, Hecho, Hechas))
    ).
