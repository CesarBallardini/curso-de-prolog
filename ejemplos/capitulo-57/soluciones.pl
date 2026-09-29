:- encoding(utf8).

% Capítulo 57 - Soluciones de los ejercicios.
%
% Carga el intérprete terminado, funcional.pl, y con él las cinco
% versiones. Las soluciones escritas en el lenguaje objeto son textos:
% definiciones(Ejercicio, Texto) guarda las definiciones de cada
% ejercicio, que se pasan a lam/3 o a ejecutar/3.
%
% solo-local: carga funcional.pl, y SWISH no carga otros archivos.
%
%?- definiciones(iterar, D), lam("tomar 8 (iterar ((*) 2) 1)", D, V).
%?- suma_cuadrados_pares(100, S).
%?- evaluaciones(contado_nombre, "nesimo 10 fibs", N).

:- ensure_loaded(funcional).

% definiciones(Ejercicio, Texto): las definiciones en el lenguaje objeto
% que resuelven el Ejercicio.
definiciones(iterar, "iterar f x = cons x (iterar f (f x))").
definiciones(plegados,
             "map2 f = plegar_der (fun x a -> cons (f x) a) []; \c
              filtrar2 p = plegar_der \c
                (fun x a -> si p x entonces cons x a sino a) []").
definiciones(sin_lista,
             "plegar1 f l = plegar_izq f (cabeza l) (cola l); \c
              maximo = plegar1 (fun a b -> si a > b entonces a sino b); \c
              pares = filtrar (fun x -> mod x 2 = 0); \c
              cuantos p = componer longitud (filtrar p)").
definiciones(cond,
             "cond c a b = si c entonces a sino b; \c
              fact n = cond (n = 0) 1 (n * fact (n - 1))").
definiciones(z,
             "z g = (fun x -> g (fun v -> x x v)) \c
                    (fun x -> g (fun v -> x x v)); \c
              f fact n = si n = 0 entonces 1 sino n * fact (n - 1)").

%!  suma_cuadrados_pares(+N:integer, -S:integer) is det.
%
%   S es la suma de los cuadrados de los números pares de 1 a N, con los
%   predicados de orden superior del capítulo 18.
suma_cuadrados_pares(N, S) :-
    numlist(1, N, L),
    include([X]>>(X mod 2 =:= 0), L, Pares),
    maplist([X, Y]>>(Y is X * X), Pares, Cuadrados),
    foldl([X, A0, A]>>(A is A0 + X), Cuadrados, 0, S).

%!  desazucar(+E, -D) is det.
%
%   D es la expresión E con cada searec(F, E1, E2), un «sea» recursivo,
%   reemplazado por sea(F, ap(id(z), lam(F, E1)), E2): F se liga al punto
%   fijo de la función que recibe F y devuelve E1.
desazucar(searec(F, E1, E2), sea(F, ap(id(z), lam(F, D1)), D2)) :-
    !,
    desazucar(E1, D1),
    desazucar(E2, D2).
desazucar(E, D) :-
    compound(E),
    !,
    compound_name_arguments(E, Nombre, Args),
    maplist(desazucar, Args, Ds),
    compound_name_arguments(D, Nombre, Ds).
desazucar(E, E).

%!  evaluar_con_rec(+E, -V) is det.
%
%   V es el valor estricto de la expresión E, que puede tener searec/3,
%   con el preludio y la definición de z del ejercicio 7.
evaluar_con_rec(E, V) :-
    definiciones(z, Texto),
    leer_programa(Texto, Z),
    preludio_leido(Preludio),
    append(Z, Preludio, Prog),
    desazucar(E, D),
    evaluar(D, [], Prog, V).

% prometer/4, declarada en perezoso.pl: dos modos que cuentan cuántas
% veces se evalúa una promesa.
prometer(contado_nombre, E, Ent, contada(E, Ent)).
prometer(contado_necesidad, E, Ent, contada(E, Ent, _)).

% forzar/3, declarada en perezoso.pl: cada evaluación de una promesa
% contada suma uno al contador evaluaciones.
forzar(contada(E, Ent), Ctx, V) :-
    flag(evaluaciones, N, N + 1),
    valor_perezoso(E, Ent, Ctx, V).
forzar(contada(E, Ent, Valor), Ctx, V) :-
    (   nonvar(Valor)
    ->  V = Valor
    ;   flag(evaluaciones, N, N + 1),
        valor_perezoso(E, Ent, Ctx, V),
        Valor = V
    ).

%!  evaluaciones(+Modo, +Texto, -N:integer) is det.
%
%   N es la cantidad de promesas que se evalúan al calcular la expresión
%   de Texto en el Modo contado_nombre o contado_necesidad.
evaluaciones(Modo, Texto, N) :-
    flag(evaluaciones, _, 0),
    ejecutar_perezoso(Modo, Texto, "", _),
    flag(evaluaciones, N, N).

%!  lam_con(+Ejercicio, +Texto, -V) is det.
%
%   V es el valor por necesidad de la expresión de Texto, con las
%   definiciones del Ejercicio.
lam_con(Ejercicio, Texto, V) :-
    definiciones(Ejercicio, D),
    lam(Texto, D, V).

%!  ejecutar_con(+Ejercicio, +Texto, -V) is det.
%
%   V es el valor estricto de la expresión de Texto, con las definiciones
%   del Ejercicio.
ejecutar_con(Ejercicio, Texto, V) :-
    definiciones(Ejercicio, D),
    ejecutar(Texto, D, V).
