:- encoding(utf8).

% Capítulo 57 - Versión 1: evaluar por sustitución.
%
% Las funciones se escriben como términos de Prolog. F@[A1, ..., An] es la
% aplicación de F a los argumentos A1, ..., An; lambda(X, Cuerpo) es una
% función de un argumento, con X una variable de Prolog. Cada hecho
% funcion(Nombre@Parametros, Cuerpo) define una función con nombre. Un
% átomo que no nombra una función es un constructor: par@[1, 2] se evalúa
% a sí mismo, con los argumentos evaluados.
%
% La variable del lenguaje objeto es una variable de Prolog. Aplicar una
% lambda copia el término con copy_term/2 y unifica el parámetro de la
% copia con el argumento: la copia renombra las variables y la
% unificación sustituye el parámetro por el valor en el cuerpo.
%
%?- valor(map@[cuadrado, [1, 2, 3]], V).
%?- valor(suma@[1]@[2], V).
%?- valor(plegar_izq@[producto, 1, [1, 2, 3, 4, 5]], V).

:- op(200, yfx, @).

%!  valor(+Expresion, -Valor) is semidet.
%
%   Valor es el resultado de evaluar Expresion. La evaluación es estricta:
%   los argumentos se evalúan antes de aplicar la función.
valor(E, V) :-
    var(E),
    !,
    V = E.
valor(primitiva@[Op, X, Y], V) :-
    !,
    valor(X, X1),
    valor(Y, Y1),
    calcular(Op, X1, Y1, V).
valor(si@[C, A, B], V) :-
    !,
    valor(C, C1),
    elegir(C1, A, B, E),
    valor(E, V).
valor(F@Args, V) :-
    !,
    valor(F, Fv),
    valor_aplicacion(Fv, F, Args, V).
valor([X|Xs], [V|Vs]) :-
    !,
    valor(X, V),
    valor(Xs, Vs).
valor(F, V) :-
    atom(F),
    funcion(F, Cuerpo),
    !,
    valor(Cuerpo, V).
valor(F, V) :-
    atom(F),
    funcion(F@Parametros, Cuerpo),
    !,
    anidar_lambdas(Parametros, Cuerpo, V).
valor(E, E).

%!  valor_aplicacion(+Fv, +F, +Args:list, -V) is det.
%
%   V es el valor de F@Args, con Fv el valor de F. Si Fv es una lambda, se
%   aplica a los argumentos de a uno; si no, F es un constructor.
valor_aplicacion(lambda(X, Cuerpo), _, Args, V) :-
    !,
    aplicar_lambdas(Args, lambda(X, Cuerpo), V).
valor_aplicacion(_, F, Args, F@Vs) :-
    valor(Args, Vs).

%!  aplicar_lambdas(+Args:list, +Funcion, -V) is det.
%
%   V es el valor de aplicar Funcion al primer argumento, el resultado al
%   segundo, y así hasta agotar Args.
aplicar_lambdas([], V, V).
aplicar_lambdas([A|As], lambda(X, Cuerpo), V) :-
    valor(A, Av),
    copy_term(lambda(X, Cuerpo), lambda(Av, Cuerpo1)),
    valor(Cuerpo1, F),
    aplicar_lambdas(As, F, V).

%!  anidar_lambdas(+Parametros:list, +Cuerpo, -Lambda) is det.
%
%   Lambda anida una lambda por cada parámetro alrededor de Cuerpo.
anidar_lambdas([], Cuerpo, Cuerpo).
anidar_lambdas([X|Xs], Cuerpo, lambda(X, L)) :-
    anidar_lambdas(Xs, Cuerpo, L).

%!  elegir(+Condicion, +Si, +No, -Elegida) is det.
%
%   Elegida es Si cuando Condicion es verdadero y No cuando es falso.
elegir(verdadero, E, _, E).
elegir(falso, _, E, E).

%!  calcular(+Op, +X, +Y, -Z) is det.
%
%   Z es el resultado de la operación primitiva Op sobre X e Y.
calcular(suma, X, Y, Z) :-
    Z is X + Y.
calcular(resta, X, Y, Z) :-
    Z is X - Y.
calcular(producto, X, Y, Z) :-
    Z is X * Y.
calcular(igual, X, Y, B) :-
    (   X == Y
    ->  B = verdadero
    ;   B = falso
    ).
calcular(cons, X, Y, [X|Y]).

% Las funciones predefinidas: cada una llama a su operación primitiva.
funcion(suma@[X, Y], primitiva@[suma, X, Y]).
funcion(resta@[X, Y], primitiva@[resta, X, Y]).
funcion(producto@[X, Y], primitiva@[producto, X, Y]).
funcion(igual@[X, Y], primitiva@[igual, X, Y]).
funcion(cons@[X, Y], primitiva@[cons, X, Y]).
funcion(cabeza@[[X|_]], X).
funcion(cola@[[_|Xs]], Xs).

% Funciones del programa, escritas en el lenguaje objeto.
funcion(cuadrado@[X], producto@[X, X]).
funcion(inc, suma@[1]).
funcion(factorial@[N],
        si@[igual@[N, 0], 1, producto@[N, factorial@[resta@[N, 1]]]]).
funcion(map@[F, L],
        si@[igual@[L, []], [], [F@[cabeza@[L]] | map@[F, cola@[L]]]]).
funcion(plegar_izq@[F, A, L],
        si@[igual@[L, []], A, plegar_izq@[F, F@[A, cabeza@[L]], cola@[L]]]).
funcion(invertir@[L], plegar_izq@[lambda(A, lambda(X, [X|A])), [], L]).
funcion(sumar_a_todos@[N, L], map@[lambda(X, suma@[X, N]), L]).
