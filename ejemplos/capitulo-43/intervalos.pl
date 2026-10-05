:- encoding(utf8).

% Capítulo 43 - Aritmética de intervalos.
%
% Si la incógnita está en un intervalo, cada expresión que la contiene
% está en un intervalo que se calcula con las operaciones de sus
% extremos: es el paquete con que PRESS comprueba las condiciones de sus
% reglas, como que un divisor no se anule. El mismo cálculo prueba que
% una ecuación no tiene raíces en un intervalo y, partiendo el intervalo
% en mitades, encierra las raíces que tiene. Los extremos se calculan con
% números de punto flotante sin redondear hacia afuera.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- intervalo(x - cos(x), [x-i(pi / 3, pi / 2)], I).
%?- distinto_de_cero(x - cos(x), [x-i(pi / 3, pi / 2)]).
%?- encerrar(cos(x) = x, x, i(-10, 10), 0.001, Is).

:- module(intervalos,
          [ intervalo/3,
            distinto_de_cero/2,
            sin_raices/3,
            encerrar/5
          ]).

:- use_module(library(error)).
:- use_module(library(apply)).
:- use_module(library(lists)).

%!  intervalo(+E, +Asignacion:list(pair), -I) is semidet.
%
%   I = i(Min, Max) contiene todos los valores de la expresión cerrada E
%   cuando cada variable X de la Asignacion, una lista de pares
%   X-i(Lo, Hi), toma un valor entre Lo y Hi. Falla si E tiene una
%   operación sin regla, o una que puede no estar definida en ese
%   intervalo: un divisor que contiene 0, una raíz o un logaritmo de un
%   intervalo con valores negativos.
intervalo(E, _, i(E, E)) :-
    number(E),
    !.
intervalo(pi, _, i(V, V)) :-
    !,
    V is pi.
intervalo(X, Asignacion, i(Lo, Hi)) :-
    atom(X),
    !,
    memberchk(X-i(Lo0, Hi0), Asignacion),
    Lo is Lo0,
    Hi is Hi0.
intervalo(E, Asignacion, I) :-
    compound_name_arguments(E, Op0, Args),
    (   Op0 == (-),
        Args = [_]
    ->  Op = opuesto
    ;   Op = Op0
    ),
    maplist(intervalo_de(Asignacion), Args, Is),
    operar_intervalo(Op, Is, I).

%!  intervalo_de(+Asignacion:list(pair), +E, -I) is semidet.
%
%   Como intervalo/3, con los argumentos en el orden de maplist/3.
intervalo_de(Asignacion, E, I) :-
    intervalo(E, Asignacion, I).

%!  operar_intervalo(+Op, +Is:list, -I) is semidet.
%
%   I es el intervalo de la operación Op aplicada a valores de los
%   intervalos Is. El signo menos de un solo argumento se llama opuesto,
%   para que la primera cláusula se elija por el nombre de la operación.
operar_intervalo(+, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    C1 is A1 + B1,
    C2 is A2 + B2.
operar_intervalo(-, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    C1 is A1 - B2,
    C2 is A2 - B1.
operar_intervalo(opuesto, [i(A1, A2)], i(C1, C2)) :-
    C1 is -A2,
    C2 is -A1.
operar_intervalo(*, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    P1 is A1 * B1,
    P2 is A1 * B2,
    P3 is A2 * B1,
    P4 is A2 * B2,
    min_list([P1, P2, P3, P4], C1),
    max_list([P1, P2, P3, P4], C2).
operar_intervalo(/, [IA, i(B1, B2)], I) :-
    ( B1 > 0 ; B2 < 0 ),
    !,
    R1 is 1 / B2,
    R2 is 1 / B1,
    operar_intervalo(*, [IA, i(R1, R2)], I).
operar_intervalo(^, [i(A1, A2), i(N, N)], i(C1, C2)) :-
    integer(N),
    N >= 0,
    (   N mod 2 =:= 0,
        A1 < 0,
        A2 > 0
    ->  C1 = 0,
        C2 is max(A1 ^ N, A2 ^ N)
    ;   N mod 2 =:= 0,
        A2 =< 0
    ->  C1 is A2 ^ N,
        C2 is A1 ^ N
    ;   C1 is A1 ^ N,
        C2 is A2 ^ N
    ).
operar_intervalo(sqrt, [i(A1, A2)], i(C1, C2)) :-
    A1 >= 0,
    C1 is sqrt(A1),
    C2 is sqrt(A2).
operar_intervalo(exp, [i(A1, A2)], i(C1, C2)) :-
    C1 is exp(A1),
    C2 is exp(A2).
operar_intervalo(log, [i(A1, A2)], i(C1, C2)) :-
    A1 > 0,
    C1 is log(A1),
    C2 is log(A2).
operar_intervalo(sin, [i(A1, A2)], I) :-
    periodica(sin, A1, A2, pi / 2, -pi / 2, I).
operar_intervalo(cos, [i(A1, A2)], I) :-
    periodica(cos, A1, A2, 0, pi, I).

%!  periodica(+F, +A1:number, +A2:number, +Max, +Min, -I) is det.
%
%   I es el intervalo de F, sin o cos, entre A1 y A2. Max y Min son los
%   puntos donde F vale 1 y -1, que se repiten cada 2 * pi: si el
%   intervalo contiene uno, el extremo correspondiente es 1 o -1.
periodica(F, A1, A2, Max, Min, i(C1, C2)) :-
    G1 =.. [F, A1],
    G2 =.. [F, A2],
    V1 is G1,
    V2 is G2,
    (   contiene_punto(A1, A2, Min)
    ->  C1 = -1
    ;   C1 is min(V1, V2)
    ),
    (   contiene_punto(A1, A2, Max)
    ->  C2 = 1
    ;   C2 is max(V1, V2)
    ).

%!  contiene_punto(+A1:number, +A2:number, +P) is semidet.
%
%   Algún punto P + 2 * K * pi, con K entero, está entre A1 y A2.
contiene_punto(A1, A2, P) :-
    K is ceiling((A1 - P) / (2 * pi)),
    P + 2 * K * pi =< A2.

%!  distinto_de_cero(+E, +Asignacion:list(pair)) is semidet.
%
%   El intervalo de E con la Asignacion no contiene 0: E no se anula para
%   ningún valor de las variables en sus intervalos.
distinto_de_cero(E, Asignacion) :-
    intervalo(E, Asignacion, i(Lo, Hi)),
    ( Lo > 0 ; Hi < 0 ),
    !.

%!  sin_raices(+Ecuacion, +X:atom, +I) is semidet.
%
%   La Ecuacion Izq = Der no tiene soluciones con X en el intervalo I.
sin_raices(Izq = Der, X, I) :-
    distinto_de_cero(Izq - Der, [X-I]).

%!  encerrar(+Ecuacion, +X:atom, +I, +Ancho:number, -Is:list) is det.
%
%   Is son intervalos de ancho Ancho o menor, de menor a mayor, cuya unión
%   contiene todas las soluciones de la Ecuacion con X en I. Un intervalo
%   donde no se puede descartar una raíz se parte en dos mitades; los
%   contiguos que quedan se unen.
encerrar(Ecuacion, X, i(Lo0, Hi0), Ancho, Is) :-
    must_be(ground, Ecuacion),
    Lo is Lo0,
    Hi is Hi0,
    partir(Ecuacion, X, Ancho, Lo, Hi, Is0, []),
    unir(Is0, Is).

%!  partir(+Ecuacion, +X:atom, +Ancho, +Lo, +Hi, -Is, ?Is0) is det.
%
%   Is, con Is0 como resto, son los intervalos de ancho Ancho o menor
%   entre Lo y Hi donde la Ecuacion puede tener soluciones.
partir(Ecuacion, X, Ancho, Lo, Hi, Is, Is0) :-
    (   sin_raices(Ecuacion, X, i(Lo, Hi))
    ->  Is = Is0
    ;   Hi - Lo =< Ancho
    ->  Is = [i(Lo, Hi)|Is0]
    ;   M is (Lo + Hi) / 2,
        partir(Ecuacion, X, Ancho, Lo, M, Is, Is1),
        partir(Ecuacion, X, Ancho, M, Hi, Is1, Is0)
    ).

%!  unir(+Is0:list, -Is:list) is det.
%
%   Is es Is0 con cada par de intervalos contiguos unido en uno.
unir([i(A, B), i(B, C)|Is0], Is) :-
    !,
    unir([i(A, C)|Is0], Is).
unir([I|Is0], [I|Is]) :-
    !,
    unir(Is0, Is).
unir([], []).
