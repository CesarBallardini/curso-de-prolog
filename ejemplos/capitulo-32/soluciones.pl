:- encoding(utf8).

% Capítulo 32 - Soluciones de los ejercicios 3 a 9 y 12.
%
% Predicados sobre términos de forma desconocida: aridades, posiciones,
% profundidad, apariciones, variantes, una representación limpia de las
% expresiones aritméticas y la evaluación de una expresión con incógnitas.
%
%?- aridad_maxima(f(a, g(b, c, d), [x]), N).
%?- apariciones(f(a, g(a, b), a), a, N).
%?- evaluar(x * x + y, [x-3, y-1], V).

:- use_module(library(error)).
:- use_module(library(terms)).

%!  aridad_maxima(+Termino, -N:integer) is det.
%
%   N es la mayor aridad de los subtérminos compuestos de Termino, o 0 si no
%   tiene ninguno.
aridad_maxima(T, N) :-
    findall(A,
            ( sub_term(S, T),
              compound(S),
              compound_name_arity(S, _, A) ),
            Aridades),
    max_list([0|Aridades], N).

%!  posiciones_iguales(+T1, +T2, -Posiciones:list(integer)) is semidet.
%
%   T1 y T2 tienen el mismo nombre y la misma aridad, y Posiciones son las
%   posiciones, en orden, de los argumentos idénticos (==) en los dos. Falla
%   si el nombre o la aridad difieren.
posiciones_iguales(T1, T2, Posiciones) :-
    functor(T1, Nombre, Aridad),
    functor(T2, Nombre, Aridad),
    findall(I,
            ( between(1, Aridad, I),
              arg(I, T1, X),
              arg(I, T2, Y),
              X == Y ),
            Posiciones).

%!  sustituir_ingenuo(?Viejo, ?Nuevo, +Termino0, -Termino) is det.
%
%   Como sustituir/4, pero compara con =: reemplaza también los subtérminos
%   que unifican con Viejo, y liga sus variables.
sustituir_ingenuo(Viejo, Nuevo, T0, T) :-
    (   T0 = Viejo
    ->  T = Nuevo
    ;   compound(T0)
    ->  mapargs(sustituir_ingenuo(Viejo, Nuevo), T0, T)
    ;   T = T0
    ).

%!  profundidad(@Termino, -P:integer) is det.
%
%   P es la profundidad de Termino: 0 si es atómico o una variable, y uno
%   más que la del argumento más profundo si es compuesto.
profundidad(T, P) :-
    (   compound(T)
    ->  compound_name_arguments(T, _, Args),
        maplist(profundidad, Args, Ps),
        max_list([0|Ps], Max),
        P is Max + 1
    ;   P = 0
    ).

%!  apariciones(+Termino, @S, -N:integer) is det.
%
%   N es la cantidad de subtérminos de Termino idénticos (==) a S.
apariciones(T, S, N) :-
    aggregate_all(count, ( sub_term(X, T), X == S ), N).

%!  variantes(@A, @B) is semidet.
%
%   A y B son iguales salvo el nombre de sus variables. No liga nada.
variantes(A, B) :-
    \+ \+ ( copy_term(A-B, CA-CB),
            numbervars(CA, 0, _),
            numbervars(CB, 0, _),
            CA == CB ).

%!  a_limpia(+Expresion, -Limpia) is det.
%
%   Limpia es la Expresion cerrada escrita con los functores num/1, inc/1,
%   suma/2, resta/2 y producto/2. Produce un error de instanciación si
%   Expresion tiene variables, y un error de dominio si contiene otra
%   operación.
a_limpia(E, L) :-
    must_be(ground, E),
    limpia(E, L).

%!  limpia(+Expresion, -Limpia) is det.
%
%   Como a_limpia/2, sin verificar que Expresion es cerrada.
limpia(E, L) :-
    (   number(E)
    ->  L = num(E)
    ;   atom(E)
    ->  L = inc(E)
    ;   E = A + B
    ->  L = suma(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   E = A - B
    ->  L = resta(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   E = A * B
    ->  L = producto(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   domain_error(expresion, E)
    ).

%!  valor(+Limpia, +Valores:list(pair), ?V) is semidet.
%
%   V es el valor de la expresión Limpia con las incógnitas de Valores,
%   pares Incognita-Valor. Falla si una incógnita no tiene valor.
valor(num(N), _, N).
valor(inc(X), Valores, V) :-
    memberchk(X-V, Valores).
valor(suma(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA + VB.
valor(resta(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA - VB.
valor(producto(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA * VB.

%!  evaluar(+Expresion, +Valores:list(pair), -V:number) is det.
%
%   V es el valor de la Expresion cerrada con cada incógnita reemplazada por
%   su valor en Valores, pares Incognita-Valor. Una incógnita sin valor
%   produce existence_error(incognita, X).
evaluar(E, Valores, V) :-
    must_be(ground, E),
    mapsubterms(valor_de(Valores), E, E1),
    V is E1.

%!  valor_de(+Valores:list(pair), +X, -V) is semidet.
%
%   V es el valor de la incógnita X en Valores. Falla si X no es un átomo, y
%   entonces mapsubterms/3 sigue por sus argumentos.
valor_de(Valores, X, V) :-
    atom(X),
    (   memberchk(X-V0, Valores)
    ->  V = V0
    ;   existence_error(incognita, X)
    ).
