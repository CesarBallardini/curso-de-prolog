:- encoding(utf8).

% Capítulo 59 - Versión 5: un intérprete que cuenta las llamadas.
%
% El análisis de las versiones anteriores lee el programa sin ejecutarlo.
% perfil/3 lo ejecuta con un metaintérprete, como los del capítulo 33, que
% cuenta cada llamada a cada predicado del programa, también las de las
% ramas que después fallan. espiar/1 marca un predicado: el intérprete
% escribe + y la meta cada vez que una llamada a ese predicado tiene
% éxito, y - y la llamada cuando ya no tiene más respuestas.
%
% El intérprete admite la conjunción, la disyunción, el condicional, la
% negación y los predicados predefinidos de sistema/1, que ejecuta con
% ejecutar/1; no admite el corte.
%
%?- perfil(inversa([a, b, c, d], R), Resultado, Cuentas).
%?- perfil(invertir(30), Resultado, Cuentas).
%?- espiar(concatenar/3), perfil(inversa([a, b], [b, a]), R, _).

:- dynamic cuenta/2, espiado/1.

% El programa que se ejecuta: dos maneras de invertir una lista.

%!  concatenar(?Xs:list, ?Ys:list, ?Zs:list) is nondet.
%
%   Zs es la lista de los elementos de Xs seguidos de los de Ys.
concatenar([], L, L).
concatenar([X|Xs], L, [X|Ys]) :-
    concatenar(Xs, L, Ys).

%!  inversa(+Xs:list, ?Ys:list) is semidet.
%
%   Ys es Xs invertida, con una concatenación por cada elemento.
inversa([], []).
inversa([X|Xs], R) :-
    inversa(Xs, R0),
    concatenar(R0, [X], R).

%!  inversa_rapida(+Xs:list, ?Ys:list) is semidet.
%
%   Ys es Xs invertida, con un acumulador.
inversa_rapida(L, R) :-
    inversa_acumulada(L, [], R).

%!  inversa_acumulada(+Xs:list, +A:list, ?Ys:list) is semidet.
%
%   Ys es Xs invertida delante de A.
inversa_acumulada([], R, R).
inversa_acumulada([X|Xs], A, R) :-
    inversa_acumulada(Xs, [X|A], R).

%!  lista(+N:integer, -L:list) is det.
%
%   L es la lista de los enteros de 1 a N.
lista(N, L) :-
    numlist(1, N, L).

%!  invertir(+N:integer) is det.
%
%   Invierte con inversa/2 la lista de los enteros de 1 a N.
invertir(N) :-
    lista(N, L),
    inversa(L, _).

%!  invertir_rapido(+N:integer) is det.
%
%   Invierte con inversa_rapida/2 la lista de los enteros de 1 a N.
invertir_rapido(N) :-
    lista(N, L),
    inversa_rapida(L, _).

% sistema(G): el intérprete ejecuta G con ejecutar/1.
sistema(_ = _).
sistema(_ is _).
sistema(_ < _).
sistema(numlist(_, _, _)).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(numlist(A, B, L)) :-
    numlist(A, B, L).

%!  perfil(+Meta, -Resultado, -Cuentas:list(pair)) is det.
%
%   Ejecuta Meta con el intérprete hasta su primera respuesta. Resultado es
%   exito, con Meta ligada a esa respuesta, o falla. Cuentas son los pares
%   Predicado-N, ordenados, con las llamadas a cada predicado del programa.
perfil(Meta, Resultado, Cuentas) :-
    retractall(cuenta(_, _)),
    (   resolver(Meta)
    ->  Resultado = exito
    ;   Resultado = falla
    ),
    findall(P-N, cuenta(P, N), Cuentas0),
    msort(Cuentas0, Cuentas).

%!  resolver(+Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa, y cada llamada a un
%   predicado del programa se cuenta.
resolver(true).
resolver((A, B)) :-
    resolver(A),
    resolver(B).
resolver((C -> T ; E)) :-
    (   resolver(C)
    ->  resolver(T)
    ;   resolver(E)
    ).
resolver((A ; B)) :-
    A \= (_ -> _),
    (   resolver(A)
    ;   resolver(B)
    ).
resolver(\+ A) :-
    \+ resolver(A).
resolver(G) :-
    sistema(G),
    ejecutar(G).
resolver(G) :-
    del_programa(G),
    functor(G, Nombre, Aridad),
    contar(Nombre/Aridad),
    (   espiado(Nombre/Aridad)
    ->  resolver_espiado(G)
    ;   clause(G, Cuerpo),
        resolver(Cuerpo)
    ).

%!  del_programa(+G) is semidet.
%
%   G no es una construcción de control ni un predicado predefinido.
del_programa(G) :-
    G \= true,
    G \= (_, _),
    G \= (_ ; _),
    G \= (_ -> _),
    G \= (\+ _),
    \+ sistema(G).

%!  resolver_espiado(+G) is nondet.
%
%   Prueba G como resolver/1, y escribe + G por cada respuesta y - con la
%   llamada original cuando no hay más.
resolver_espiado(G) :-
    copy_term(G, Llamada),
    (   clause(G, Cuerpo),
        resolver(Cuerpo),
        escribir('+', G)
    ;   escribir('-', Llamada),
        fail
    ).

%!  contar(+P) is det.
%
%   Suma una llamada a la cuenta del predicado P.
contar(P) :-
    (   retract(cuenta(P, N0))
    ->  N is N0 + 1
    ;   N = 1
    ),
    assertz(cuenta(P, N)).

%!  espiar(+P) is det.
%
%   El intérprete escribe las respuestas y las fallas del predicado P.
espiar(P) :-
    retractall(espiado(P)),
    assertz(espiado(P)).

%!  no_espiar(+P) is det.
%
%   El intérprete deja de escribir las respuestas y las fallas de P.
no_espiar(P) :-
    retractall(espiado(P)).

%!  escribir(+Signo, +G) is det.
%
%   Escribe una línea del rastro: el signo y G, con sus variables nombradas
%   A, B… sin ligarlas.
escribir(Signo, G) :-
    \+ \+ ( numbervars(G, 0, _),
            format("~w ~W~n", [Signo, G, [quoted(true), numbervars(true),
                                          spacing(next_argument)]]) ).
