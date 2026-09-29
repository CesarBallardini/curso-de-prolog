:- encoding(utf8).

% Capítulo 60 - Programas dirigidos por patrones.
%
% Un programa es una lista de módulos Nombre :: Condiciones ---> Acciones.
% Las condiciones se comparan con la memoria de trabajo, una colección de
% hechos sin variables: un patrón pide un hecho que unifique con él, no(F)
% pide que ninguno unifique con F, y {Meta} es una prueba que se ejecuta
% con Prolog. Las acciones cambian la memoria: agregar(F), quitar(F),
% reemplazar(F, G); {Meta} hace un cálculo, y parar(R) termina el ciclo con
% el resultado R. Los programas son datos: este archivo no ejecuta nada.
%
%?- programa(mcd, Modulos), maplist(bien_formado, Modulos).
%?- posiciones([c, a, b], Hechos).

:- op(850, xfx, ::).
:- op(800, xfx, --->).

% Otros archivos agregan programas.
:- multifile programa/2.

%!  programa(?Nombre, ?Modulos:list) is nondet.
%
%   Modulos es la lista de módulos del programa Nombre, en el orden en que
%   se escribieron.
programa(mcd,
    [ resta :: [numero(X), numero(Y), {X > Y}]
           ---> [{Z is X - Y}, reemplazar(numero(X), numero(Z))],
      resultado :: [numero(X)]
           ---> [parar(X)]
    ]).
programa(mcd_invertido,
    [ resultado :: [numero(X)]
           ---> [parar(X)],
      resta :: [numero(X), numero(Y), {X > Y}]
           ---> [{Z is X - Y}, reemplazar(numero(X), numero(Z))]
    ]).
programa(mcd_mal,
    [ resta :: [numero(X), numero(Y), {X >= Y}]
           ---> [{Z is X - Y}, reemplazar(numero(X), numero(Z))],
      resultado :: [numero(X)]
           ---> [parar(X)]
    ]).
programa(ordenar,
    [ intercambio :: [pos(I, X), pos(J, Y), {I < J, X > Y}]
           ---> [reemplazar(pos(I, X), pos(I, Y)),
                 reemplazar(pos(J, Y), pos(J, X))]
    ]).
programa(luz,
    [ apagar :: [luz(encendida)]
           ---> [reemplazar(luz(encendida), luz(apagada))],
      encender :: [luz(apagada)]
           ---> [reemplazar(luz(apagada), luz(encendida))]
    ]).
programa(contador,
    [ sumar :: [contador(N)]
           ---> [{M is N + 1}, reemplazar(contador(N), contador(M))]
    ]).

%!  bien_formado(+Modulo) is semidet.
%
%   Modulo tiene la forma Nombre :: Condiciones ---> Acciones, con un átomo
%   por nombre y listas de condiciones y de acciones reconocidas.
bien_formado(Nombre :: Condiciones ---> Acciones) :-
    atom(Nombre),
    is_list(Condiciones),
    maplist(condicion_valida, Condiciones),
    is_list(Acciones),
    maplist(accion_valida, Acciones).

%!  condicion_valida(+Condicion) is semidet.
%
%   Condicion es una prueba {Meta}, una negación no(F) o un patrón de hecho.
condicion_valida({Meta}) :-
    callable(Meta).
condicion_valida(no(F)) :-
    patron(F).
condicion_valida(F) :-
    patron(F).

%!  accion_valida(+Accion) is semidet.
%
%   Accion es una de las cinco acciones del lenguaje.
accion_valida({Meta}) :-
    callable(Meta).
accion_valida(agregar(F)) :-
    patron(F).
accion_valida(quitar(F)) :-
    patron(F).
accion_valida(reemplazar(F, G)) :-
    patron(F),
    patron(G).
accion_valida(parar(_)).

%!  patron(+F) is semidet.
%
%   F puede ser un hecho de la memoria: un término que no es una variable,
%   ni una prueba {Meta}, ni una negación no(G).
patron(F) :-
    nonvar(F),
    F \= {_},
    F \= no(_).

%!  posiciones(+Lista:list, -Hechos:list) is det.
%
%   Hechos son los hechos pos(I, X), uno por elemento X de Lista, con su
%   posición I contada desde 1.
posiciones(Lista, Hechos) :-
    foldl(posicion, Lista, Hechos, 1, _).

%!  posicion(+X, -Hecho, +I0, -I) is det.
%
%   Hecho es pos(I0, X), e I la posición siguiente.
posicion(X, pos(I0, X), I0, I) :-
    I is I0 + 1.

%!  valores(+Hechos:list, -Lista:list) is det.
%
%   Lista son los elementos de los hechos pos(I, X) de Hechos, ordenados por
%   su posición I.
valores(Hechos, Lista) :-
    findall(I-X, member(pos(I, X), Hechos), Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Lista).
