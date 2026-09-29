:- encoding(utf8).

% Capítulo 32 - Qué clase de término es: las pruebas de tipo, por qué no son
% relaciones, must_be/2 e is_of_type/2.
%
% clase/2 clasifica un término cualquiera. Las cuatro versiones de
% mayor_de_edad muestran qué hace cada forma de verificar un tipo antes de
% comparar: la comparación sola produce un error de tipo con un átomo; la
% prueba de tipo falla también con una variable libre; must_be/2 distingue
% las dos situaciones con dos errores distintos; la restricción de clpfd
% responde también con la variable libre.
%
%?- clase(f(a, B), Clase).
%?- edad(P, E), mayor_de_edad(E).

:- use_module(library(error)).
:- use_module(library(clpfd)).

%!  clase(@Termino, -Clase) is det.
%
%   Clase es la clase de Termino en su estado actual: variable, entero,
%   flotante, atomo, cadena, lista_vacia o compuesto(Nombre/Aridad).
%   Termino no se modifica.
clase(T, Clase) :-
    (   var(T)
    ->  Clase = variable
    ;   integer(T)
    ->  Clase = entero
    ;   float(T)
    ->  Clase = flotante
    ;   atom(T)
    ->  Clase = atomo
    ;   string(T)
    ->  Clase = cadena
    ;   T == []
    ->  Clase = lista_vacia
    ;   compound_name_arity(T, Nombre, Aridad),
        Clase = compuesto(Nombre/Aridad)
    ).

% edad(P, E): la edad registrada de P; desconocida si no se sabe.
edad(ana, 41).
edad(luis, 12).
edad(eva, desconocida).
edad(juan, 68).

%!  mayor_de_edad_ingenuo(+E:integer) is semidet.
%
%   E es una edad de 18 o más. Produce un error de tipo si E no es un
%   número.
mayor_de_edad_ingenuo(E) :-
    E >= 18.

%!  mayor_de_edad(@E) is semidet.
%
%   E es un entero de 18 o más. Falla con cualquier otro término, incluida
%   una variable libre.
mayor_de_edad(E) :-
    integer(E),
    E >= 18.

%!  mayor_de_edad_verificado(+E:integer) is semidet.
%
%   E es una edad de 18 o más. Produce un error de instanciación si E está
%   libre, y un error de tipo si no es un entero.
mayor_de_edad_verificado(E) :-
    must_be(integer, E),
    E >= 18.

%!  mayor_de_edad_restringido(?E:integer) is semidet.
%
%   E es un entero de 18 o más. Con E libre, la respuesta es la restricción
%   E #>= 18, sin elegir un valor. Produce un error de dominio si E no es
%   un entero ni una expresión de clpfd.
mayor_de_edad_restringido(E) :-
    E #>= 18.
