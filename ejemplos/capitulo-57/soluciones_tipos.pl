:- encoding(utf8).

% Capítulo 57 - Soluciones de los ejercicios 13 y 14: los tipos de los
% plegados y un «sea» polimórfico.
%
% tipo_con_plegados/2 tipa una expresión con las definiciones de
% plegados.pl después de las del preludio.
%
% tipo_ml/4 es tipo/4 de tipos.pl con una sola diferencia: el nombre de un
% «sea» se guarda en los locales como esquema(T), y cada uso copia T salvo
% las variables que aparecen en los tipos de los demás locales, que siguen
% compartidas. Es la generalización del sistema de tipos de ML.
%
% solo-local: carga tipos.pl, y SWISH no carga otros archivos.
%
%?- tipo_con_plegados("plegar1_der", T).
%?- tipo_ml_de("sea id = fun x -> x en si id verdadero entonces id 1 sino 2", T).

:- ensure_loaded(tipos).

%!  tipo_con_plegados(+Texto:string, -Tipo:string) is semidet.
%
%   Tipo es el tipo de la expresión de Texto, con las definiciones del
%   preludio y las de plegados/1. Falla si la expresión no tiene tipo.
tipo_con_plegados(Texto, Tipo) :-
    plegados(Definiciones),
    tipo_de(Texto, Definiciones, Tipo).

%!  tipo_ml_de(+Texto:string, -Tipo:string) is semidet.
%
%   Tipo es el tipo de la expresión de Texto, con «sea» polimórfico y las
%   definiciones del preludio. Falla si la expresión no tiene tipo.
tipo_ml_de(Texto, Tipo) :-
    preludio_leido(Prog),
    tipos_del_programa(Prog, Globales),
    leer_expresion(Texto, E),
    tipo_ml(E, [], Globales, T),
    mostrar_tipo(T, Tipo).

%!  tipo_ml(+E, +Locales:list, +Globales:list, ?T) is semidet.
%
%   Como tipo/4, con los nombres de «sea» generalizados.
tipo_ml(num(_), _, _, T) :-
    unificar(T, entero).
tipo_ml(id(X), Loc, Glob, T) :-
    (   memberchk(X-T0, Loc),
        es_esquema(X-T0)
    ->  T0 = esquema(T00),
        instanciar(T00, Loc, T1)
    ;   tipo_de_nombre(X, Loc, Glob, T1)
    ),
    unificar(T, T1).
tipo_ml(lam(X, Cuerpo), Loc, Glob, T) :-
    tipo_ml(Cuerpo, [X-A|Loc], Glob, B),
    unificar(T, fn(A, B)).
tipo_ml(ap(F, A), Loc, Glob, T) :-
    tipo_ml(F, Loc, Glob, TF),
    tipo_ml(A, Loc, Glob, TA),
    unificar(TF, fn(TA, T)).
tipo_ml(si(C, A, B), Loc, Glob, T) :-
    tipo_ml(C, Loc, Glob, booleano),
    tipo_ml(A, Loc, Glob, T),
    tipo_ml(B, Loc, Glob, T).
tipo_ml(sea(X, E1, E2), Loc, Glob, T) :-
    tipo_ml(E1, Loc, Glob, T1),
    tipo_ml(E2, [X-esquema(T1)|Loc], Glob, T).

%!  instanciar(+T0, +Locales:list, -T) is det.
%
%   T es una copia de T0 con variables nuevas, salvo las que aparecen en
%   los tipos de los parámetros de Locales, que T comparte con T0. Los
%   esquemas no cuentan: sus variables propias son las que se generalizan.
instanciar(T0, Loc, T) :-
    exclude(es_esquema, Loc, Parametros),
    term_variables(Parametros, Fijas),
    copy_term(Fijas-T0, Copias-T),
    Copias = Fijas.

%!  es_esquema(+Par) is semidet.
%
%   Par liga un nombre de «sea» a su esquema. Un tipo que es una variable
%   no es un esquema, y no se liga.
es_esquema(_-Tipo) :-
    nonvar(Tipo),
    Tipo = esquema(_).
