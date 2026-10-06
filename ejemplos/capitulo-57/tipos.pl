:- encoding(utf8).

% Capítulo 57 - Tipos simples para Lam.
%
% Un tipo es entero, booleano, lista(T) o fn(A, B), la función de A en B;
% una variable de Prolog es un tipo todavía desconocido. tipo/4 infiere el
% tipo de una expresión de la versión 2 unificando los tipos de sus
% partes: aplicar una función de tipo fn(A, B) a un argumento exige que el
% argumento sea de tipo A. La unificación se hace con
% unify_with_occurs_check/2, para rechazar un tipo infinito como el de
% fun x -> x x.
%
% Las definiciones del programa se tipan en orden. Una definición puede
% llamarse a sí misma con un solo tipo; una vez tipada, cada uso copia su
% tipo con variables nuevas, y así map sirve para listas de números y de
% listas en la misma expresión. Un «sea» no se copia: su nombre tiene un
% solo tipo.
%
% solo-local: carga lector.pl, y plegados.pl para tipar sus definiciones;
% SWISH no carga otros archivos.
%
%?- tipo_de("map", T).
%?- tipo_de("fun f g x -> f (g x)", T).
%?- tipo_de("fun x -> x x", T).
%?- tipo_de("g", "g x = cons x []", T).

:- ensure_loaded(lector).
:- ensure_loaded(plegados).

%!  tipo_de(+Texto:string, -Tipo:string) is semidet.
%
%   Tipo es el tipo de la expresión de Texto, escrito como texto, con las
%   definiciones del preludio. Falla si la expresión no tiene tipo.
tipo_de(Texto, Tipo) :-
    tipo_de(Texto, "", Tipo).

%!  tipo_de(+Texto:string, +Definiciones:string, -Tipo:string) is semidet.
%
%   Como tipo_de/2, con las Definiciones después de las del preludio, que
%   pueden usarlas. Falla si la expresión o una definición no tiene tipo.
tipo_de(Texto, Definiciones, Tipo) :-
    preludio_leido(Preludio),
    leer_programa(Definiciones, Propias),
    append(Preludio, Propias, Prog),
    tipos_del_programa(Prog, Globales),
    leer_expresion(Texto, E),
    tipo(E, [], Globales, T),
    mostrar_tipo(T, Tipo).

%!  tipos_del_programa(+Programa:list, -Globales:list) is semidet.
%
%   Globales liga el nombre de cada definición de Programa a su tipo, en
%   el orden de Programa. Falla si una definición no tiene tipo.
tipos_del_programa(Prog, Globales) :-
    foldl(tipar_definicion, Prog, [], Globales).

%!  tipar_definicion(+Definicion, +G0:list, -G:list) is semidet.
%
%   G es G0 con el tipo de Definicion. Dentro de su cuerpo, el nombre
%   definido tiene un solo tipo, el que se está infiriendo.
tipar_definicion(def(F, E), G0, [F-T|G0]) :-
    tipo(E, [F-T], G0, T).

%!  tipo(+E, +Locales:list, +Globales:list, ?T) is semidet.
%
%   T es el tipo de la expresión E, con los identificadores ligados en
%   Locales, un tipo por nombre, o en Globales, cuyos tipos se copian en
%   cada uso. Falla si E no tiene tipo.
tipo(num(_), _, _, T) :-
    unificar(T, entero).
tipo(id(X), Loc, Glob, T) :-
    tipo_de_nombre(X, Loc, Glob, T0),
    unificar(T, T0).
tipo(lam(X, Cuerpo), Loc, Glob, T) :-
    tipo(Cuerpo, [X-A|Loc], Glob, B),
    unificar(T, fn(A, B)).
tipo(ap(F, A), Loc, Glob, T) :-
    tipo(F, Loc, Glob, TF),
    tipo(A, Loc, Glob, TA),
    unificar(TF, fn(TA, T)).
tipo(si(C, A, B), Loc, Glob, T) :-
    tipo(C, Loc, Glob, booleano),
    tipo(A, Loc, Glob, T),
    tipo(B, Loc, Glob, T).
tipo(sea(X, E1, E2), Loc, Glob, T) :-
    tipo(E1, Loc, Glob, T1),
    tipo(E2, [X-T1|Loc], Glob, T).

%!  tipo_de_nombre(+X:atom, +Locales:list, +Globales:list, -T) is semidet.
%
%   T es el tipo de X: el de Locales tal cual, o una copia del de Globales
%   o del de la primitiva o la constante. Falla si X no tiene tipo.
tipo_de_nombre(X, Loc, Glob, T) :-
    (   memberchk(X-T0, Loc)
    ->  T = T0
    ;   memberchk(X-T0, Glob)
    ->  copy_term(T0, T)
    ;   tipo_predefinido(X, T0)
    ->  copy_term(T0, T)
    ).

%!  unificar(?T1, ?T2) is semidet.
%
%   T1 y T2 son el mismo tipo, sin tipos infinitos.
unificar(T1, T2) :-
    unify_with_occurs_check(T1, T2).

% tipo_predefinido(X, T): el tipo de la primitiva o de la constante X.
tipo_predefinido(+, fn(entero, fn(entero, entero))).
tipo_predefinido(-, fn(entero, fn(entero, entero))).
tipo_predefinido(*, fn(entero, fn(entero, entero))).
tipo_predefinido(div, fn(entero, fn(entero, entero))).
tipo_predefinido(mod, fn(entero, fn(entero, entero))).
tipo_predefinido(<, fn(entero, fn(entero, booleano))).
tipo_predefinido(>, fn(entero, fn(entero, booleano))).
tipo_predefinido(=, fn(A, fn(A, booleano))).
tipo_predefinido(cons, fn(A, fn(lista(A), lista(A)))).
tipo_predefinido(cabeza, fn(lista(A), A)).
tipo_predefinido(cola, fn(lista(A), lista(A))).
tipo_predefinido(vacia, fn(lista(_), booleano)).
tipo_predefinido(nil, lista(_)).
tipo_predefinido(verdadero, booleano).
tipo_predefinido(falso, booleano).

%!  mostrar_tipo(+T, -Texto:string) is det.
%
%   Texto es el tipo T escrito con -> para las funciones, [A] para las
%   listas y a, b, c… para las variables, en el orden en que aparecen.
mostrar_tipo(T0, Texto) :-
    copy_term(T0, T),
    term_variables(T, Vs),
    nombrar(Vs, 0'a),
    phrase(tipo_escrito(T), Cs),
    string_codes(Texto, Cs).

%!  nombrar(+Variables:list, +Letra:integer) is det.
%
%   Liga cada variable a una letra, empezando por Letra.
nombrar([], _).
nombrar([V|Vs], L) :-
    char_code(V, L),
    L1 is L + 1,
    nombrar(Vs, L1).

%!  tipo_escrito(+T)// is det.
%
%   El texto del tipo T. La flecha asocia a la derecha: el argumento de una
%   función que es una función va entre paréntesis.
tipo_escrito(fn(A, B)) -->
    !,
    (   { A = fn(_, _) }
    ->  "(", tipo_escrito(A), ")"
    ;   tipo_escrito(A)
    ),
    " -> ",
    tipo_escrito(B).
tipo_escrito(lista(A)) -->
    !,
    "[", tipo_escrito(A), "]".
tipo_escrito(A) -->
    { atom_codes(A, Cs) },
    Cs.
