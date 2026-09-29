:- encoding(utf8).

% Capítulo 62 - Versión 5: la forma clausal de la lógica de predicados.
%
% Completa la forma clausal de la versión 2 con los pasos que los
% cuantificadores exigen: después de la forma normal negada, cada
% cuantificador recibe una variable propia (↔ duplica subfórmulas, y con
% ellas sus variables ligadas); la forma prenexa lleva los cuantificadores
% al frente; la skolemización reemplaza cada variable existencial por un
% término nuevo, una constante o una función de las variables universales
% que la preceden; y la matriz que queda, sin cuantificadores, pasa a
% cláusulas con fnc/2. Las variables universales quedan como variables de
% Prolog de las cláusulas.
%
% solo-local: carga los módulos lector y clausal, y SWISH no admite
% módulos propios.
%
%?- clausulas_fo_texto("¬∃x (bebe(x) → ∀y bebe(y))", Cs).
%?- leer_formula("∀x ∃y ama(x, y)", F), prenexa(F, P, M), skolemizar(P, 1, _).

:- module(primer_orden,
          [ clausulas_fo/2,
            clausulas_fo_texto/2,
            renombrar/2,
            prenexa/3,
            skolemizar/3
          ]).

:- use_module(library(lists)).
:- reexport(clausal).

%!  clausulas_fo_texto(+Texto, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de la fórmula que Texto escribe.
clausulas_fo_texto(Texto, Clausulas) :-
    leer_formula(Texto, F),
    clausulas_fo(F, Clausulas).

%!  clausulas_fo(+F, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de F, una fórmula cerrada de la lógica
%   de predicados: una lista de cláusulas, ninguna tautológica, con las
%   variables universales como variables de Prolog y las existenciales
%   reemplazadas por términos de Skolem sk1, sk2…
clausulas_fo(F, Clausulas) :-
    fnn(F, G0),
    renombrar(G0, G),
    prenexa(G, Prefijo, Matriz),
    skolemizar(Prefijo, 1, _),
    fnc(Matriz, Cs),
    sin_variantes(Cs, Clausulas).

%!  renombrar(+F, -G) is det.
%
%   G es F con una variable nueva para cada cuantificador: dos
%   cuantificadores de G nunca ligan la misma variable.
renombrar(at(A), at(A)).
renombrar(no(F), no(G)) :-
    renombrar(F, G).
renombrar(y(A, B), y(RA, RB)) :-
    renombrar(A, RA),
    renombrar(B, RB).
renombrar(o(A, B), o(RA, RB)) :-
    renombrar(A, RA),
    renombrar(B, RB).
renombrar(todo(X, F), todo(Y, G)) :-
    reemplazar(X, Y, F, F1),
    renombrar(F1, G).
renombrar(existe(X, F), existe(Y, G)) :-
    reemplazar(X, Y, F, F1),
    renombrar(F1, G).

%!  reemplazar(@X, +Y, +T0, -T) is det.
%
%   T es T0 con cada aparición de la variable X reemplazada por Y.
reemplazar(X, Y, T0, T) :-
    (   T0 == X
    ->  T = Y
    ;   var(T0)
    ->  T = T0
    ;   compound(T0)
    ->  compound_name_arguments(T0, N, As0),
        maplist(reemplazar(X, Y), As0, As),
        compound_name_arguments(T, N, As)
    ;   T = T0
    ).

%!  prenexa(+G, -Prefijo:list, -Matriz) is det.
%
%   Prefijo y Matriz forman la forma prenexa de G, una fórmula en forma
%   normal negada con una variable distinta por cuantificador: Prefijo es
%   la lista de los cuantificadores, todo(X) o existe(X), en el orden en
%   que aparecen de izquierda a derecha, y Matriz es G sin ellos.
prenexa(at(A), [], at(A)).
prenexa(no(A), [], no(A)).
prenexa(y(A, B), P, y(MA, MB)) :-
    prenexa(A, PA, MA),
    prenexa(B, PB, MB),
    append(PA, PB, P).
prenexa(o(A, B), P, o(MA, MB)) :-
    prenexa(A, PA, MA),
    prenexa(B, PB, MB),
    append(PA, PB, P).
prenexa(todo(X, F), [todo(X)|P], M) :-
    prenexa(F, P, M).
prenexa(existe(X, F), [existe(X)|P], M) :-
    prenexa(F, P, M).

%!  skolemizar(+Prefijo:list, +N0:integer, -N:integer) is det.
%
%   Liga cada variable existencial del Prefijo a un término de Skolem:
%   skN(U1, …, Uk), donde U1, …, Uk son las variables universales que la
%   preceden, o la constante skN si no hay ninguna. N0 es el número del
%   primer término, y N el siguiente al último.
skolemizar(Prefijo, N0, N) :-
    skolemizar(Prefijo, [], N0, N).

%!  skolemizar(+Prefijo:list, +Universales:list, +N0:integer,
%!             -N:integer) is det.
%
%   Como skolemizar/3; Universales son las variables universales ya
%   recorridas, en orden.
skolemizar([], _, N, N).
skolemizar([todo(X)|P], Us, N0, N) :-
    append(Us, [X], Us1),
    skolemizar(P, Us1, N0, N).
skolemizar([existe(X)|P], Us, N0, N) :-
    atom_concat(sk, N0, Nombre),
    (   Us == []
    ->  X = Nombre
    ;   compound_name_arguments(X, Nombre, Us)
    ),
    N1 is N0 + 1,
    skolemizar(P, Us, N1, N).

%!  sin_variantes(+Cs:list, -Rs:list) is det.
%
%   Rs es Cs sin las cláusulas que son variantes de una anterior.
sin_variantes([], []).
sin_variantes([C|Cs], [C|Rs]) :-
    exclude(=@=(C), Cs, Cs1),
    sin_variantes(Cs1, Rs).
