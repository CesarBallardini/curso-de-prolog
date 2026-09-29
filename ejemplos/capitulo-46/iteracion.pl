:- encoding(utf8).

% Capítulo 46 - La base de los métodos numéricos: la ecuación como término
% y el ciclo que repite un paso hasta alcanzar la tolerancia.
%
% Una ecuación es Izq = Der, o una expresión E que se iguala a cero, con
% una incógnita que es un átomo. Su valor en un punto lo calcula evaluar/3
% del capítulo 32. iterar/4 aplica un paso de cualquier método hasta que el
% cambio es menor o igual que la tolerancia, o hasta maximo_de_pasos/1.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- funcion(x * x = 2, F).
%?- valor_en(x ^ 2 - 2, x, 1.5, V).

:- ensure_loaded('../capitulo-32/soluciones').

%!  funcion(+Ecuacion, -F) is det.
%
%   F es la expresión cuyo cero resuelve Ecuacion: Izq - Der si Ecuacion es
%   Izq = Der, y la misma Ecuacion en otro caso.
funcion(Ecuacion, F) :-
    (   Ecuacion = (Izq = Der)
    ->  F = Izq - Der
    ;   F = Ecuacion
    ).

%!  valor_en(+F, +X:atom, +A:number, -V:float) is det.
%
%   V es el valor de la expresión F con la incógnita X reemplazada por A,
%   como número de punto flotante. Otro átomo en F produce un error de
%   existencia.
valor_en(F, X, A, V) :-
    evaluar(F, [X-A], V0),
    V is float(V0).

:- meta_predicate
    iterar(4, +, +, -),
    iterar(4, +, +, +, -).

% maximo_de_pasos(N): ningún método da más de N pasos.
maximo_de_pasos(100).

%!  iterar(:Paso, +Tol:float, +Estado0, -Aproximaciones:list) is semidet.
%
%   Aproximaciones son las que da Paso, un paso tras otro, desde Estado0,
%   hasta el primero cuyo cambio es menor o igual que Tol. call(Paso, E0,
%   E, X, Cambio) da el estado E que sigue a E0, su aproximación X y el
%   Cambio respecto de la anterior. Falla si un paso falla o si la
%   tolerancia no se alcanza en maximo_de_pasos/1 pasos.
iterar(Paso, Tol, Estado0, Aproximaciones) :-
    maximo_de_pasos(Maximo),
    iterar(Paso, Tol, Maximo, Estado0, Aproximaciones).

%!  iterar(:Paso, +Tol:float, +Restantes:integer, +Estado0,
%!         -Aproximaciones:list) is semidet.
%
%   Como iterar/4, con a lo sumo Restantes pasos.
iterar(Paso, Tol, Restantes, Estado0, [X|Xs]) :-
    Restantes > 0,
    call(Paso, Estado0, Estado, X, Cambio),
    (   Cambio =< Tol
    ->  Xs = []
    ;   Restantes1 is Restantes - 1,
        iterar(Paso, Tol, Restantes1, Estado, Xs)
    ).
