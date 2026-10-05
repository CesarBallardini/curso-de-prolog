:- encoding(utf8).

% Capítulo 64 - Extensión: la negación de una conjunción.
%
% La condición no_todos([F1, ..., Fn]) se cumple cuando no hay ninguna
% combinación de hechos que cumpla a la vez los patrones F1, ..., Fn con
% las variables ya ligadas por las condiciones anteriores. Un nodo
% negacion_conj(As) lee los nodos alfa As de los patrones y guarda cada
% token de su padre con una cuenta: cuántas combinaciones lo bloquean.
% Un hecho que entra o sale de cualquiera de esas memorias alfa hace
% recontar los tokens guardados; el que pasa de cero a más sale de la
% salida, y el que vuelve a cero entra. La comparación de referencia es un
% conjunto de conflicto reunido desde cero, como el del capítulo 63, con
% una cláusula más para no_todos/1.
%
% solo-local: carga rete.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- conjunto_conj(bloques, [bloque(a), bloque(b), sobre(c, a), color(c, rojo)], Is).
%?- cambios_conj(bloques, [bloque(a), sobre(c, a), color(c, rojo)], [menos(color(c, rojo))], Is).

:- ensure_loaded(rete).

:- table red_conj/2.

% Un bloque está libre de rojo si no tiene encima un bloque rojo: la
% negación es de la conjunción sobre(Y, X), color(Y, rojo).
programa(bloques,
    [ libre :: [bloque(X), no_todos([sobre(Y, X), color(Y, rojo)])]
               ---> [agregar(libre_de_rojo(X))]
    ]).

%!  red_conj(+Programa, -Red) is det.
%
%   Red es la red del Programa con los pasos de pasos_conj/2.
red_conj(Programa, Red) :-
    programa(Programa, Reglas),
    compilar_red(pasos_conj, Reglas, Red).

%!  pasos_conj(+Condiciones:list, -Pasos:list) is det.
%
%   Como pasos/2, con no_todos(Fs) como un paso propio.
pasos_conj(Condiciones, Pasos) :-
    maplist(paso_conj, Condiciones, Pasos).

%!  paso_conj(+Condicion, -Paso) is det.
%
%   Paso es no_todos(Fs) para esa condición, o el de paso/2.
paso_conj(Condicion, Paso) :-
    (   Condicion = no_todos(_)
    ->  Paso = Condicion
    ;   paso(Condicion, Paso)
    ).

%   El nodo de no_todos(Fs) lee un nodo alfa por patrón.
tipo_de(no_todos(Fs), negacion_conj(As), Red0, Red) :-
    foldl(alfa_de_patron, Fs, As, Red0, Red).

%   El nodo es sucesor de cada uno de sus nodos alfa.
agregar_sucesor(negacion_conj(As), Nodo, Alfas0, Alfas) :-
    foldl(sucesor_de(Nodo), As, Alfas0, Alfas).

%!  alfa_de_patron(+F, -A:integer, +Red0, -Red) is det.
%
%   A es el nodo alfa del patrón F, que se crea si hace falta.
alfa_de_patron(F, A, Red0, Red) :-
    nodo_alfa(alfa(F, []), Red0, Red, A).

%!  sucesor_de(+Nodo:integer, +A:integer, +Alfas0, -Alfas) is det.
%
%   Nodo pasa a ser sucesor del nodo alfa A.
sucesor_de(Nodo, A, Alfas0, Alfas) :-
    agregar_sucesor(union(A), Nodo, Alfas0, Alfas).

%   Un hecho que entra o sale de una de las memorias alfa hace recontar
%   todos los tokens del nodo.
derecha(negacion_conj(As), _, _, _-Nodo, Prefijo, Red, Rete0, Rete) :-
    Rete0 = rete(Alfas, Betas0, Conjunto),
    tokens(cuentas(Nodo), Rete0, Cuentas0),
    foldl(recontar_conj(As, Alfas, Prefijo), Cuentas0, Cuentas, [],
          Cambios0),
    reverse(Cambios0, Cambios),
    empty_assoc(Vacia),
    foldl(guardar_cuenta, Cuentas, Vacia, Memoria),
    put_assoc(cuentas(Nodo), Betas0, Memoria, Betas),
    foldl(salida_negacion(Nodo, Prefijo, Red), Cambios,
          rete(Alfas, Betas, Conjunto), Rete).

%   Un token que llega del padre se guarda con su cuenta; uno que se va,
%   como en la negación de un solo patrón.
izquierda(negacion_conj(As), Signo, Token, Nodo, Prefijo, Red, Rete0,
          Rete) :-
    (   Signo == mas
    ->  llega_conj(As, Token, Nodo, Prefijo, Red, Rete0, Rete)
    ;   llega_a_negacion(menos, _, Token, Nodo, Prefijo, Red, Rete0, Rete)
    ).

%!  llega_conj(+As:list, +Token, +Nodo:integer, +Prefijo:list, +Red,
%!             +Rete0, -Rete) is det.
%
%   El Token entra en las cuentas del Nodo con las combinaciones que lo
%   bloquean, y pasa a la salida si no lo bloquea ninguna.
llega_conj(As, Sellos-Instancia, Nodo, Prefijo, Red, Rete0, Rete) :-
    Rete0 = rete(Alfas, Betas0, Conjunto),
    bloqueos(As, Alfas, Prefijo, Instancia, N),
    cambiar_memoria(mas, cuentas(Nodo), Sellos-(Instancia-N), Betas0, Betas),
    Rete1 = rete(Alfas, Betas, Conjunto),
    (   N =:= 0
    ->  salida_negacion(Nodo, Prefijo, Red, mas-(Sellos-Instancia), Rete1,
                        Rete)
    ;   Rete = Rete1
    ).

%!  bloqueos(+As:list, +Alfas, +Prefijo:list, +Instancia:list,
%!           -N:integer) is det.
%
%   N es la cantidad de combinaciones de hechos de las memorias alfa As
%   que cumplen los patrones del último paso no_todos(Fs) del Prefijo con
%   las variables de la Instancia.
bloqueos(As, Alfas, Prefijo, Instancia, N) :-
    aggregate_all(count,
                  ( copy_term(Prefijo, P),
                    append(Instancia, [no_todos(Fs)], P),
                    combinacion(Fs, As, Alfas) ),
                  N).

%!  combinacion(+Fs:list, +As:list, +Alfas) is nondet.
%
%   Cada patrón de Fs unifica con un hecho de la memoria alfa que le
%   corresponde en As. Una solución por combinación.
combinacion([], [], _).
combinacion([F|Fs], [A|As], Alfas) :-
    get_assoc(A, Alfas, Memoria),
    elementos_alfa(Memoria, F, Elementos),
    member(_-alfa(F, _), Elementos),
    combinacion(Fs, As, Alfas).

%!  recontar_conj(+As:list, +Alfas, +Prefijo:list, +Cuenta0, -Cuenta,
%!                +Cambios0, -Cambios) is det.
%
%   Cuenta tiene la cantidad de bloqueos actual del token de Cuenta0.
%   Cambios registra menos-Token si el token dejó de pasar y mas-Token si
%   volvió a pasar.
recontar_conj(As, Alfas, Prefijo, Sellos-(Instancia-N0),
              Sellos-(Instancia-N), Cambios0, Cambios) :-
    bloqueos(As, Alfas, Prefijo, Instancia, N),
    (   N0 =:= 0, N > 0
    ->  Cambios = [menos-(Sellos-Instancia)|Cambios0]
    ;   N0 > 0, N =:= 0
    ->  Cambios = [mas-(Sellos-Instancia)|Cambios0]
    ;   Cambios = Cambios0
    ).

%!  conjunto_conj(+Programa, +Hechos:list, -Instanciaciones:list) is det.
%
%   Instanciaciones es el conjunto de conflicto que la red de red_conj/2
%   mantiene después de cargar los Hechos.
conjunto_conj(Programa, Hechos, Instanciaciones) :-
    cambios_conj(Programa, Hechos, [], Instanciaciones).

%!  cambios_conj(+Programa, +Hechos:list, +Cambios:list,
%!               -Instanciaciones:list) is semidet.
%
%   Como cambios_rete/4, con la red de red_conj/2.
cambios_conj(Programa, Hechos, Cambios, Instanciaciones) :-
    red_conj(Programa, Red),
    cargar(Red, Hechos, Memoria0, Rete0),
    foldl(cambio(Red), Cambios, Memoria0-Rete0, _-Rete),
    conjunto_rete(Rete, Instanciaciones).

%!  desde_cero(+Programa, +Memoria, -Instanciaciones:list) is det.
%
%   Instanciaciones es el conjunto de conflicto del Programa en la
%   Memoria, reunido desde cero, en el orden de conjunto_conflicto/3.
desde_cero(Programa, Memoria, Instanciaciones) :-
    programa(Programa, Reglas),
    findall(instanciacion(Nombre, Sellos, N, Acciones),
            ( member(Nombre :: Condiciones ---> Acciones, Reglas),
              length(Condiciones, N),
              cumple_conj(Condiciones, Memoria, Sellos) ),
            Instanciaciones).

%!  cumple_conj(+Condiciones:list, +Memoria, -Sellos:list) is nondet.
%
%   Como cumple/3 del capítulo 63, con no_todos(Fs): no hay hechos que
%   cumplan todos los patrones de Fs a la vez.
cumple_conj([], _, []).
cumple_conj([C|Cs], Memoria, Sellos) :-
    (   C = no_todos(Fs)
    ->  \+ todos(Fs, Memoria),
        cumple_conj(Cs, Memoria, Sellos)
    ;   cumple_condicion(C, Memoria, Sellos, Resto),
        cumple_conj(Cs, Memoria, Resto)
    ).

%!  todos(+Fs:list, +Memoria) is semidet.
%
%   Hay hechos en Memoria que cumplen todos los patrones de Fs.
todos([], _).
todos([F|Fs], Memoria) :-
    elemento(_, F, Memoria),
    todos(Fs, Memoria).

%!  mismo_conjunto_conj(+Programa, +Hechos:list, +Cambios:list)
%!      is semidet.
%
%   Después de los Cambios, el conjunto de la red es una variante del que
%   desde_cero/3 reúne en la misma memoria.
mismo_conjunto_conj(Programa, Hechos, Cambios) :-
    red_conj(Programa, Red),
    cargar(Red, Hechos, Memoria0, Rete0),
    foldl(cambio(Red), Cambios, Memoria0-Rete0, Memoria-Rete),
    conjunto_rete(Rete, Is),
    desde_cero(Programa, Memoria, Is0),
    Is =@= Is0.
