:- encoding(utf8).

% Capítulo 69 - Soluciones de los ejercicios 13 y 14: la suma de un
% vector con y sin acumulador, y el esquema del acumulador como predicado
% de orden superior.
%
% solo-local: carga vectores.pl, que carga perceptron.pl, y SWISH no
% carga otros archivos.
%
%?- costos_suma(1000, Costos).
%?- con_pila(12000000, suma_rec, 200000, R).
%?- minimo([7, -3, 2, 5], M).

:- ensure_loaded(vectores).

% --- Ejercicio 13 ------------------------------------------------------------

%!  suma_rec(+Xs:list(number), -S:number) is det.
%
%   S es la suma de los elementos de Xs, por recursión simple.
suma_rec([], 0).
suma_rec([X|Xs], S) :-
    suma_rec(Xs, S0),
    S is S0 + X.

%!  suma_acc(+Xs:list(number), -S:number) is det.
%
%   Como suma_rec/2, con un acumulador.
suma_acc(Xs, S) :-
    suma_acc(Xs, 0, S).

%!  suma_acc(+Xs:list(number), +S0:number, -S:number) is det.
%
%   S es S0 más la suma de los elementos de Xs.
suma_acc([], S, S).
suma_acc([X|Xs], S0, S) :-
    S1 is S0 + X,
    suma_acc(Xs, S1, S).

%!  costos_suma(+N:integer, -Costos:list(pair)) is det.
%
%   Costos son las inferencias que usa sumar los números de 1 a N con
%   cada forma: rec-I y acc-I.
costos_suma(N, [rec-I1, acc-I2]) :-
    numlist(1, N, Xs),
    inferencias(suma_rec(Xs, _), I1),
    inferencias(suma_acc(Xs, _), I2).

%!  con_pila(+Limite:integer, +Suma:atom, +N:integer, -Resultado) is det.
%
%   Resultado es suma(S) si el predicado Suma, suma_rec o suma_acc, suma
%   los números de 1 a N con un límite de Limite bytes para las pilas, y
%   sin_pila si las pilas se agotan. El límite anterior se restituye.
con_pila(Limite, Suma, N, Resultado) :-
    numlist(1, N, Xs),
    current_prolog_flag(stack_limit, Anterior),
    setup_call_cleanup(
        set_prolog_flag(stack_limit, Limite),
        catch(( call(Suma, Xs, S),
                Resultado = suma(S) ),
              error(resource_error(_), _),
              Resultado = sin_pila),
        set_prolog_flag(stack_limit, Anterior)).

% --- Ejercicio 14 ------------------------------------------------------------

:- meta_predicate
    esquema_general(1, 2, 2, +, -).

%!  esquema_general(:Parada, :Extraer, :Transformar, +Argumento,
%!                  -Resultado) is det.
%
%   Transforma Argumento con call(Transformar, A0, A) hasta que se cumple
%   call(Parada, A), y da Resultado con call(Extraer, A, Resultado).
esquema_general(Parada, Extraer, Transformar, Arg, Res) :-
    (   call(Parada, Arg)
    ->  call(Extraer, Arg, Res)
    ;   call(Transformar, Arg, Arg1),
        esquema_general(Parada, Extraer, Transformar, Arg1, Res)
    ).

%!  entrenar_general(+Nombre:atom, +Tasa:number, +Pesos0:list,
%!                   -Pesos:list, -Pasos:integer) is det.
%
%   Como entrenar_esquema/5, con esquema_general/5 y las tres partes de
%   vectores.pl.
entrenar_general(Nombre, Tasa, Pesos0, Pesos, Pasos) :-
    datos(Nombre, Ejemplos),
    esquema_general(parada, extraer, transformar,
                    en(Tasa, Ejemplos, Pesos0, 0), sal(Pesos, Pasos)).

%!  minimo(+Xs:list(number), -M:number) is semidet.
%
%   M es el menor elemento de Xs, que no es vacía, con esquema_general/5:
%   el argumento es el par Resto-Menor. Falla si Xs es vacía.
minimo([X|Xs], M) :-
    esquema_general(resto_vacio, menor, avanzar, Xs-X, M).

%!  resto_vacio(+Argumento) is semidet.
%
%   No quedan elementos por examinar.
resto_vacio([]-_).

%!  menor(+Argumento, -M:number) is det.
%
%   M es el menor de Argumento.
menor(_-M, M).

%!  avanzar(+Argumento0, -Argumento) is det.
%
%   Argumento examina el primer elemento restante de Argumento0.
avanzar([X|Xs]-M0, Xs-M) :-
    M is min(M0, X).
