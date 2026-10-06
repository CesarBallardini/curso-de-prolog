:- encoding(utf8).

% Capítulo 69 - Versión 5: vectores y el esquema del acumulador.
%
% La regla del perceptrón multiplica un vector por un número y suma dos
% vectores. Este archivo escribe las dos operaciones de dos maneras, por
% recursión simple y con un acumulador, y compara su costo. Después
% escribe el entrenamiento de a un ejemplo con el esquema general de un
% predicado con acumulador: un argumento que se transforma hasta que se
% cumple una condición de parada, y del que se extrae el resultado.
%
% solo-local: carga perceptron.pl, y SWISH no carga otros archivos.
%
%?- escalar_rec([1, 2, 3], 2, Ys).
%?- costos_vectores(1000, Costos).
%?- entrenar_esquema(puntos, 0.25, [0.13, -0.51, -0.35], Pesos, Pasos).

:- ensure_loaded(perceptron).

% --- Recursión simple --------------------------------------------------------

%!  escalar_rec(+Xs:list(number), +K:number, -Ys:list(number)) is det.
%
%   Ys es el vector Xs multiplicado por el número K, por recursión simple.
escalar_rec([], _, []).
escalar_rec([X|Xs], K, [Y|Ys]) :-
    Y is K * X,
    escalar_rec(Xs, K, Ys).

%!  escalar_k(+K:number, +Xs:list(number), -Ys:list(number)) is det.
%
%   Como escalar_rec/3, con el número primero, en el orden de los
%   argumentos de Csenki. La indexación por el primer argumento no
%   distingue sus dos cláusulas, y la última respuesta deja una
%   alternativa pendiente.
escalar_k(_, [], []).
escalar_k(K, [X|Xs], [Y|Ys]) :-
    Y is K * X,
    escalar_k(K, Xs, Ys).

%!  sumar_rec(+Xs:list(number), +Ys:list(number), -Zs:list(number)) is det.
%
%   Zs es la suma de los vectores Xs e Ys, de igual longitud, por
%   recursión simple.
sumar_rec([], [], []).
sumar_rec([X|Xs], [Y|Ys], [Z|Zs]) :-
    Z is X + Y,
    sumar_rec(Xs, Ys, Zs).

% --- Con acumulador ----------------------------------------------------------

%!  escalar_acc(+Xs:list(number), +K:number, -Ys:list(number)) is det.
%
%   Como escalar_rec/3, con un acumulador que guarda los productos ya
%   calculados en orden inverso.
escalar_acc(Xs, K, Ys) :-
    escalar_acc(Xs, K, [], Ys).

%!  escalar_acc(+Xs:list, +K:number, +Inv:list, -Ys:list) is det.
%
%   Ys son los productos de Inv, invertidos, seguidos de los de Xs.
escalar_acc([], _, Inv, Ys) :-
    reverse(Inv, Ys).
escalar_acc([X|Xs], K, Inv, Ys) :-
    Y is K * X,
    escalar_acc(Xs, K, [Y|Inv], Ys).

%!  sumar_acc(+Xs:list(number), +Ys:list(number), -Zs:list(number)) is det.
%
%   Como sumar_rec/3, con un acumulador en orden inverso.
sumar_acc(Xs, Ys, Zs) :-
    sumar_acc(Xs, Ys, [], Zs).

%!  sumar_acc(+Xs:list, +Ys:list, +Inv:list, -Zs:list) is det.
%
%   Zs son las sumas de Inv, invertidas, seguidas de las de Xs e Ys.
sumar_acc([], [], Inv, Zs) :-
    reverse(Inv, Zs).
sumar_acc([X|Xs], [Y|Ys], Inv, Zs) :-
    Z is X + Y,
    sumar_acc(Xs, Ys, [Z|Inv], Zs).

% --- La regla del perceptrón con vectores ------------------------------------

%!  corregir_vectores(+Tasa:number, +Ejemplo, +Pesos0:list, -Pesos:list)
%!      is det.
%
%   Como corregir/4, escrito como Pesos = Pesos0 + K·[1|Xs], con
%   K = Tasa·(D - Y). Si el ejemplo está bien clasificado, K es cero y
%   los pesos no cambian de valor.
corregir_vectores(Tasa, ej(Xs, D), Pesos0, Pesos) :-
    salida(Pesos0, Xs, Y),
    K is Tasa * (D - Y),
    escalar_rec([1|Xs], K, Deltas),
    sumar_rec(Pesos0, Deltas, Pesos).

% --- El costo de cada forma --------------------------------------------------

%!  costos_vectores(+N:integer, -Costos:list(pair)) is det.
%
%   Costos son las inferencias que usa escalar un vector de N elementos y
%   sumarlo consigo mismo, por recursión simple, con acumulador y con
%   maplist/3 y maplist/4: pares rec-I, acc-I y maplist-I.
costos_vectores(N, [rec-I1, acc-I2, maplist-I3]) :-
    numlist(1, N, Xs),
    inferencias(( escalar_rec(Xs, 2, Ys1),
                  sumar_rec(Xs, Ys1, _) ), I1),
    inferencias(( escalar_acc(Xs, 2, Ys2),
                  sumar_acc(Xs, Ys2, _) ), I2),
    inferencias(( maplist(por(2), Xs, Ys3),
                  maplist(mas, Xs, Ys3, _) ), I3).

%!  por(+K:number, +X:number, -Y:number) is det.
%
%   Y es K·X.
por(K, X, Y) :-
    Y is K * X.

%!  mas(+X:number, +Y:number, -Z:number) is det.
%
%   Z es X + Y.
mas(X, Y, Z) :-
    Z is X + Y.

% --- El esquema general del acumulador ---------------------------------------

%!  esquema(+Argumento, -Resultado) is det.
%
%   Transforma Argumento hasta que cumple la condición de parada, y
%   extrae de él el Resultado. Argumento es en(Tasa, Ejemplos, Pesos,
%   Pasos) y Resultado es sal(Pesos, Pasos). No termina si los ejemplos
%   no son linealmente separables.
esquema(Arg, Res) :-
    (   parada(Arg)
    ->  extraer(Arg, Res)
    ;   transformar(Arg, Arg1),
        esquema(Arg1, Res)
    ).

%!  parada(+Argumento) is semidet.
%
%   Los pesos de Argumento clasifican bien todos sus ejemplos.
parada(en(_, Ejemplos, Pesos, _)) :-
    maplist(bien_clasificado(Pesos), Ejemplos).

%!  extraer(+Argumento, -Resultado) is det.
%
%   Resultado son los pesos y los pasos de Argumento.
extraer(en(_, _, Pesos, Pasos), sal(Pesos, Pasos)).

%!  transformar(+Argumento0, -Argumento) is det.
%
%   Argumento sigue a Argumento0: los pesos corregidos con el primer
%   ejemplo, ese ejemplo al final de la lista y un paso más.
transformar(en(Tasa, [E|Es], Pesos0, Pasos0), en(Tasa, Es1, Pesos, Pasos)) :-
    corregir_vectores(Tasa, E, Pesos0, Pesos),
    append(Es, [E], Es1),
    Pasos is Pasos0 + 1.

%!  entrenar_esquema(+Nombre:atom, +Tasa:number, +Pesos0:list,
%!                   -Pesos:list, -Pasos:integer) is det.
%
%   Como pasos/5, con esquema/2: el argumento empieza con los ejemplos del
%   conjunto Nombre, los Pesos0 y cero pasos.
entrenar_esquema(Nombre, Tasa, Pesos0, Pesos, Pasos) :-
    datos(Nombre, Ejemplos),
    esquema(en(Tasa, Ejemplos, Pesos0, 0), sal(Pesos, Pasos)).
