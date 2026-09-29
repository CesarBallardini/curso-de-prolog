:- encoding(utf8).

% Capítulo 39 - Solución del ejercicio 15: el árbol de prueba de una
% conclusión, con la tabla de cierto/3 como guía.
%
% cierto/3 dice qué conclusiones son verdaderas, pero no guarda cómo se
% prueban. como_tabulado/4 reconstruye una prueba: en cada condición
% atómica usa solo respuestas sin condiciones de cierto/3, y no vuelve a
% usar una conclusión que ya está en la rama, de modo que el ciclo de r4 y
% r13 no produce un árbol infinito.
%
% solo-local: carga experto.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- como_tabulado(vuela, [tiene_plumas, pone_huevos, peso(2)], vuela, A).

:- ensure_loaded(experto).

%!  como_tabulado(+Version:atom, +Observaciones:list, +Meta, -Arbol)
%!      is semidet.
%
%   Arbol es una prueba de Meta con las reglas de Version y las
%   Observaciones, con las formas observado(M), deducido(M, Regla, Arbol),
%   A y B, X > Y y no M. Falla si Meta no es verdadera.
como_tabulado(Version, Os, Meta, Arbol) :-
    once(arbol(Version, Os, Meta, [], Arbol)).

%!  arbol(+Version:atom, +Os:list, ?Meta, +Rama:list, -Arbol) is nondet.
%
%   Arbol prueba Meta sin usar las conclusiones de Rama, las que están en
%   curso en la rama del árbol.
arbol(_, Os, Meta, _, observado(Meta)) :-
    member(Meta, Os).
arbol(Version, Os, Meta, Rama, deducido(Meta, Regla, Arbol)) :-
    \+ ( member(M, Rama), M == Meta ),
    regla_de(Version, Regla, si Condiciones entonces Meta),
    condiciones(Version, Os, Condiciones, [Meta|Rama], Arbol).

%!  condiciones(+Version:atom, +Os:list, +Condiciones, +Rama:list,
%!              -Arbol) is nondet.
%
%   Arbol prueba las Condiciones de una regla. Una condición atómica se
%   prueba solo si cierto/3 la da como verdadera, sin condiciones.
condiciones(Version, Os, A y B, Rama, ArbolA y ArbolB) :-
    condiciones(Version, Os, A, Rama, ArbolA),
    condiciones(Version, Os, B, Rama, ArbolB).
condiciones(_, _, X > Y, _, X > Y) :-
    X > Y.
condiciones(Version, Os, no A, _, no A) :-
    valor(cierto(Version, Os, A), falso).
condiciones(Version, Os, A, Rama, Arbol) :-
    atomica(A),
    call_delays(cierto(Version, Os, A), true),
    arbol(Version, Os, A, Rama, Arbol).
