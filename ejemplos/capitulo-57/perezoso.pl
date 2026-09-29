:- encoding(utf8).

% Capítulo 57 - Versión 4: evaluación perezosa por nombre.
%
% El argumento de una aplicación no se evalúa antes de la llamada: se
% guarda como una promesa, la expresión junto con su entorno, y se evalúa
% recién cuando alguien necesita su valor. cons no evalúa ninguno de sus
% dos argumentos, así que una lista puede ser infinita: se calculan solo
% los elementos que se usan. Las primitivas aritméticas, cabeza, cola,
% vacia y la condición de si fuerzan las promesas que reciben.
%
% El entorno liga cada nombre a una promesa. Una lista es [] o [P|Q], con
% P y Q promesas. prometer/4 y forzar/3 son multifile: aquí se define la
% promesa por nombre, que se evalúa cada vez que se fuerza; necesidad.pl
% agrega otra clase de promesa.
%
% solo-local: carga lector.pl, y SWISH no carga otros archivos.
%
%?- ejecutar_perezoso(nombre, "tomar 5 (desde 1)", "", V).
%?- ejecutar_perezoso(nombre, "tomar 8 fibs", "", V).
%?- ejecutar_perezoso(nombre, "cabeza [1, cabeza []]", "", V).

:- ensure_loaded(lector).

:- multifile prometer/4, forzar/3.

%!  ejecutar_perezoso(+Modo, +Texto, +Definiciones, -Valor) is det.
%
%   Valor es el resultado de evaluar la expresión de Texto con las
%   Definiciones y el preludio, con promesas de la clase Modo. Si el
%   resultado es una lista, se fuerzan todos sus elementos: la consulta no
%   termina si la lista es infinita.
ejecutar_perezoso(Modo, Texto, Definiciones, V) :-
    leer_programa(Definiciones, Propias),
    preludio_leido(Preludio),
    append(Propias, Preludio, Prog),
    contexto(Modo, Prog, Ctx),
    leer_expresion(Texto, E),
    valor_perezoso(E, [], Ctx, V0),
    forzar_todo(V0, Ctx, V).

%!  contexto(+Modo, +Programa:list, -Ctx) is det.
%
%   Ctx es contexto(Modo, Globales): Globales liga el nombre de cada
%   definición de Programa a una promesa de su expresión, con el entorno
%   vacío. Cada nombre tiene una sola promesa, compartida por todos los
%   usos.
contexto(Modo, Prog, contexto(Modo, Globales)) :-
    maplist(global(Modo), Prog, Globales).

%!  global(+Modo, +Definicion, -Par) is det.
%
%   Par liga el nombre de Definicion a la promesa de su expresión.
global(Modo, def(X, E), X-P) :-
    prometer(Modo, E, [], P).

%!  valor_perezoso(+E, +Entorno:list, +Ctx, -V) is det.
%
%   V es el valor de la expresión E, con los identificadores ligados a
%   promesas en Entorno o en las globales de Ctx. El argumento de una
%   aplicación y el valor de un «sea» quedan como promesas.
valor_perezoso(num(N), _, _, N).
valor_perezoso(id(X), Ent, Ctx, V) :-
    buscar_perezoso(X, Ent, Ctx, V).
valor_perezoso(lam(X, Cuerpo), Ent, _, clausura(X, Cuerpo, Ent)).
valor_perezoso(ap(F, A), Ent, Ctx, V) :-
    valor_perezoso(F, Ent, Ctx, Fv),
    Ctx = contexto(Modo, _),
    prometer(Modo, A, Ent, P),
    aplicar_perezoso(Fv, P, Ctx, V).
valor_perezoso(si(C, A, B), Ent, Ctx, V) :-
    valor_perezoso(C, Ent, Ctx, Cv),
    rama(Cv, A, B, E),
    valor_perezoso(E, Ent, Ctx, V).
valor_perezoso(sea(X, E1, E2), Ent, Ctx, V) :-
    Ctx = contexto(Modo, _),
    prometer(Modo, E1, Ent, P),
    valor_perezoso(E2, [X-P|Ent], Ctx, V).

%!  buscar_perezoso(+X:atom, +Entorno:list, +Ctx, -V) is det.
%
%   V es el valor del identificador X: se fuerza su promesa del entorno o
%   de las globales; si no tiene, es una primitiva o una constante. Error
%   de existencia si X no es ninguna de esas cosas.
buscar_perezoso(X, Ent, Ctx, V) :-
    Ctx = contexto(_, Globales),
    (   memberchk(X-P, Ent)
    ->  forzar(P, Ctx, V)
    ;   memberchk(X-P, Globales)
    ->  forzar(P, Ctx, V)
    ;   primitiva(X, N)
    ->  V = prim(X, N, [])
    ;   constante(X, V0)
    ->  V = V0
    ;   existence_error(identificador, X)
    ).

%!  aplicar_perezoso(+Funcion, +Promesa, +Ctx, -V) is det.
%
%   V es el resultado de aplicar el valor Funcion al argumento Promesa, sin
%   forzarlo.
aplicar_perezoso(clausura(X, Cuerpo, Ent), P, Ctx, V) :-
    !,
    valor_perezoso(Cuerpo, [X-P|Ent], Ctx, V).
aplicar_perezoso(prim(Op, N, Recibidas), P, Ctx, V) :-
    !,
    (   N =:= 1
    ->  reverse([P|Recibidas], Ps),
        calcular_perezoso(Op, Ps, Ctx, V)
    ;   N1 is N - 1,
        V = prim(Op, N1, [P|Recibidas])
    ).
aplicar_perezoso(F, _, _, _) :-
    type_error(funcion, F).

%!  calcular_perezoso(+Op, +Promesas:list, +Ctx, -V) is det.
%
%   V es el resultado de la primitiva Op sobre los argumentos Promesas.
%   cons no fuerza nada; cabeza, cola y vacia fuerzan solo lo que usan; las
%   demás fuerzan todos sus argumentos y calculan como en entornos.pl.
calcular_perezoso(cons, [P, Q], _, V) :-
    !,
    V = [P|Q].
calcular_perezoso(cabeza, [P], Ctx, V) :-
    !,
    forzar(P, Ctx, L),
    no_vacia(L, Q, _),
    forzar(Q, Ctx, V).
calcular_perezoso(cola, [P], Ctx, V) :-
    !,
    forzar(P, Ctx, L),
    no_vacia(L, _, Q),
    forzar(Q, Ctx, V).
calcular_perezoso(vacia, [P], Ctx, V) :-
    !,
    forzar(P, Ctx, L),
    booleano(L == [], V).
calcular_perezoso(Op, Ps, Ctx, V) :-
    maplist(forzado(Ctx), Ps, Xs),
    calcular(Op, Xs, V).

%!  forzado(+Ctx, +Promesa, -V) is det.
%
%   V es el valor de Promesa; forzar/3 con los argumentos en el orden que
%   necesita maplist/3.
forzado(Ctx, P, V) :-
    forzar(P, Ctx, V).

%!  forzar_todo(+V0, +Ctx, -V) is det.
%
%   V es V0 con todas las promesas de sus listas forzadas, a cualquier
%   profundidad. No termina si V0 es una lista infinita.
forzar_todo(V0, Ctx, V) :-
    (   V0 = [P|Q]
    ->  forzar(P, Ctx, X0),
        forzar_todo(X0, Ctx, X),
        forzar(Q, Ctx, Xs0),
        forzar_todo(Xs0, Ctx, Xs),
        V = [X|Xs]
    ;   V = V0
    ).

%!  prometer(+Modo, +E, +Entorno:list, -Promesa) is det.
%
%   Promesa guarda la expresión E con su Entorno, sin evaluarla.
prometer(nombre, E, Ent, promesa(E, Ent)).

%!  forzar(+Promesa, +Ctx, -V) is det.
%
%   V es el valor de Promesa. Una promesa por nombre se evalúa cada vez que
%   se fuerza.
forzar(promesa(E, Ent), Ctx, V) :-
    valor_perezoso(E, Ent, Ctx, V).
