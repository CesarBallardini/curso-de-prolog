:- encoding(utf8).

% Capítulo 58 - Versión 3: signos, con un intérprete abstracto tabulado.
%
% Cada variable guarda su signo, neg, cero o pos, en lugar de su valor. Las
% operaciones de Mini pasan a ser relaciones entre signos: la suma de un
% positivo y un negativo puede tener cualquier signo, y da una respuesta
% por cada uno. Una condición entre signos puede cumplirse y no cumplirse,
% y el intérprete sigue las dos ramas. El resultado de dividir por cero es
% el átomo error, que no es un signo: la evaluación se detiene.
%
% El intérprete tiene la forma del intérprete del capítulo 45: una cláusula
% por caso, con la condición cierta en una y la falsa en otra. Como los
% estados abstractos son finitos, :- table efecto/3 hace terminar los
% bucles: la tabla guarda los estados alcanzables, el menor punto fijo, y
% una vuelta que llega a un estado ya visto no produce nada nuevo.
%
% solo-local: carga concreto.pl con ensure_loaded/1.
%
%?- op_signos(+, pos, neg, S).
%?- programa_caso(cuadrado, P, Es), finales_signos(P, Es, Fs).
%?- programa_caso(promedio, P, _), finales_signos(P, [n-entre(0, sup)], Fs).

:- ensure_loaded(concreto).

% signo(S): S es un signo, el de los negativos, el cero o los positivos.
signo(neg).
signo(cero).
signo(pos).

%!  signo_de(+N:integer, -S) is det.
%
%   S es el signo del entero N.
signo_de(N, S) :-
    (   N < 0
    ->  S = neg
    ;   N =:= 0
    ->  S = cero
    ;   S = pos
    ).

%!  signo_en(+Rango, -S) is nondet.
%
%   S es el signo de algún entero del Rango entre(Min, Max), con Min un
%   entero o inf y Max un entero o sup.
signo_en(entre(Min, _), neg) :-
    cota_menor(Min, -1).
signo_en(entre(Min, Max), cero) :-
    cota_menor(Min, 0),
    cota_menor(0, Max).
signo_en(entre(_, Max), pos) :-
    cota_menor(1, Max).

%!  cota_menor(+A, +B) is semidet.
%
%   La cota A es menor o igual que la cota B: inf es menor que todas y sup
%   mayor que todas.
cota_menor(A, B) :-
    (   A == inf
    ->  true
    ;   B == sup
    ->  true
    ;   integer(A),
        integer(B),
        A =< B
    ).

% opuesto(S, T): T es el signo de -X si S es el signo de X.
opuesto(neg, pos).
opuesto(cero, cero).
opuesto(pos, neg).

% no_nulo(S): S es el signo de un entero distinto de cero.
no_nulo(neg).
no_nulo(pos).

%!  mas(?A, ?B, ?S) is nondet.
%
%   Hay un X de signo A y un Y de signo B tales que X + Y tiene signo S.
mas(cero, S, S) :-
    signo(S).
mas(neg, cero, neg).
mas(pos, cero, pos).
mas(neg, neg, neg).
mas(pos, pos, pos).
mas(neg, pos, S) :-
    signo(S).
mas(pos, neg, S) :-
    signo(S).

%!  menos(?A, ?B, ?S) is nondet.
%
%   Hay un X de signo A y un Y de signo B tales que X - Y tiene signo S:
%   la suma de X y el opuesto de Y.
menos(A, B, S) :-
    opuesto(B, C),
    mas(A, C, S).

%!  por(?A, ?B, ?S) is nondet.
%
%   El producto de un entero de signo A y uno de signo B tiene signo S.
por(cero, B, cero) :-
    signo(B).
por(A, cero, cero) :-
    no_nulo(A).
por(neg, neg, pos).
por(pos, pos, pos).
por(neg, pos, neg).
por(pos, neg, neg).

%!  cociente(?A, ?B, ?S) is nondet.
%
%   Hay un X de signo A y un Y de signo B, distinto de cero, tales que la
%   división entera X / Y, que trunca hacia cero, tiene signo S: 1 / 2 es
%   0.
cociente(cero, B, cero) :-
    no_nulo(B).
cociente(A, B, cero) :-
    no_nulo(A),
    no_nulo(B).
cociente(A, B, S) :-
    no_nulo(A),
    no_nulo(B),
    por(A, B, S).

%!  op_signos(+Op, +A, +B, -R) is nondet.
%
%   R es un resultado posible de la operación Op de Mini entre valores de
%   signos A y B: un signo, o error si Op divide por cero. Un error en un
%   operando da error.
op_signos(_, error, _, error).
op_signos(_, A, error, error) :-
    signo(A).
op_signos(+, A, B, S) :-
    mas(A, B, S).
op_signos(-, A, B, S) :-
    menos(A, B, S).
op_signos(*, A, B, S) :-
    por(A, B, S).
op_signos(/, A, B, S) :-
    cociente(A, B, S).
op_signos(/, A, cero, error) :-
    signo(A).

%!  posible(+Op, +A, +B) is semidet.
%
%   Hay un X de signo A y un Y de signo B que cumplen la comparación Op:
%   X - Y tiene un signo D tal que un entero de signo D cumple Op con 0. La
%   comparación es comparar/3 del capítulo 45.
posible(Op, A, B) :-
    once(( menos(A, B, D),
           representante(D, N),
           comparar(Op, N, 0) )).

% representante(S, N): N es un entero de signo S.
representante(neg, -1).
representante(cero, 0).
representante(pos, 1).

%!  signo_exp(+Exp, +E:list, -R) is nondet.
%
%   R es un resultado posible de la expresión Exp en el entorno de signos
%   E: un signo o error.
signo_exp(num(N), _, S) :-
    signo_de(N, S).
signo_exp(id(X), E, S) :-
    valor(X, E, S).
signo_exp(bin(Op, A, B), E, R) :-
    signo_exp(A, E, RA),
    signo_exp(B, E, RB),
    op_signos(Op, RA, RB, R).

%!  veredicto_condicion(+C, +E:list, -V) is nondet.
%
%   V es un veredicto posible de la condición C en el entorno de signos E:
%   cierta, falsa o error.
veredicto_condicion(rel(Op, A, B), E, V) :-
    signo_exp(A, E, RA),
    signo_exp(B, E, RB),
    veredicto(Op, RA, RB, V).

%!  veredicto(+Op, +RA, +RB, -V) is nondet.
%
%   V es un veredicto posible de la comparación Op entre los resultados RA
%   y RB.
veredicto(_, error, _, error).
veredicto(_, RA, error, error) :-
    signo(RA).
veredicto(Op, A, B, cierta) :-
    signo(A),
    signo(B),
    posible(Op, A, B).
veredicto(Op, A, B, falsa) :-
    signo(A),
    signo(B),
    contraria(Op, No),
    posible(No, A, B).

%!  seguir(+R, +Estado, -Final) is det.
%
%   Final es Estado si el resultado R es un signo, y error si es error.
seguir(error, _, error).
seguir(S, Estado, Estado) :-
    signo(S).

%!  efecto_bloque(+Ss:list, +R0, -R) is nondet.
%
%   Ejecutar las sentencias Ss sobre signos puede llevar el estado R0 a R.
%   Un estado es estado(Entorno) o error.
efecto_bloque([], R, R).
efecto_bloque([S|Ss], R0, R) :-
    efecto(S, R0, R1),
    efecto_bloque(Ss, R1, R).

:- table efecto/3.

%!  efecto(+S, +R0, -R) is nondet.
%
%   Ejecutar la sentencia S sobre signos puede llevar el estado R0 a R. Una
%   respuesta por estado alcanzable; tabulada, termina aunque S sea un
%   mientras que vuelve a un estado ya visto.
efecto(_, error, error).
efecto(asignar(X, Exp), estado(E0), R) :-
    signo_exp(Exp, E0, V),
    asignar_signo(V, X, E0, R).
efecto(escribir(Exp), estado(E), R) :-
    signo_exp(Exp, E, V),
    seguir(V, estado(E), R).
efecto(si(C, Si, _), estado(E0), R) :-
    veredicto_condicion(C, E0, cierta),
    efecto_bloque(Si, estado(E0), R).
efecto(si(C, _, No), estado(E0), R) :-
    veredicto_condicion(C, E0, falsa),
    efecto_bloque(No, estado(E0), R).
efecto(mientras(C, Cuerpo), estado(E0), R) :-
    veredicto_condicion(C, E0, cierta),
    efecto_bloque(Cuerpo, estado(E0), R1),
    efecto(mientras(C, Cuerpo), R1, R).
efecto(mientras(C, _), estado(E), estado(E)) :-
    veredicto_condicion(C, E, falsa).
efecto(S, estado(E), error) :-
    condicion_de(S, C),
    veredicto_condicion(C, E, error).

% condicion_de(S, C): C es la condición de la sentencia S.
condicion_de(si(C, _, _), C).
condicion_de(mientras(C, _), C).

%!  asignar_signo(+V, +X:atom, +E0:list, -R) is det.
%
%   R es el estado después de asignar a X el resultado V en el entorno E0:
%   error si V es error.
asignar_signo(error, _, _, error).
asignar_signo(S, X, E0, estado(E)) :-
    signo(S),
    actualizar(X, S, E0, E).

%!  inicial_signos(+Programa:list, +Entradas:list, -R) is nondet.
%
%   R es un estado inicial de Programa: las variables de Entradas con un
%   signo de su rango, una respuesta por combinación, y las demás en cero.
inicial_signos(Programa, Entradas, estado(E)) :-
    entorno_inicial(Programa, Ceros),
    maplist(par_cero, Ceros, E0),
    foldl(entrada_signo, Entradas, E0, E).

% par_cero(X-0, X-cero): la variable X empieza en cero.
par_cero(X-0, X-cero).

%!  entrada_signo(+Entrada, +E0:list, -E:list) is nondet.
%
%   E es E0 con la variable de la Entrada X-Rango en un signo de Rango.
entrada_signo(X-Rango, E0, E) :-
    signo_en(Rango, S),
    fijar(X-S, E0, E).

%!  finales_signos(+Programa:list, +Entradas:list, -Finales:list) is det.
%
%   Finales es el conjunto ordenado de los estados en que puede terminar
%   Programa, desde cada estado inicial, según el análisis de signos.
finales_signos(Programa, Entradas, Finales) :-
    findall(R, ( inicial_signos(Programa, Entradas, R0),
                 efecto_bloque(Programa, R0, R) ),
            Rs),
    sort(Rs, Finales).

%!  finales_caso(+Nombre, +Entradas:list, -Finales:list) is semidet.
%
%   Como finales_signos/3, sobre el caso Nombre con las Entradas dadas.
%   Falla si Nombre no es un caso.
finales_caso(Nombre, Entradas, Finales) :-
    programa_caso(Nombre, Programa, _),
    finales_signos(Programa, Entradas, Finales).

%!  alcanzadas_signos(+Programa:list, +Entradas:list, -Ss:list) is det.
%
%   Ss es el conjunto ordenado de las sentencias de Programa que el
%   análisis de signos alcanza en algún estado. Las lee de la tabla de
%   efecto/3, que guarda cada llamada: cada sentencia con cada estado en que
%   se ejecutó. En SWI-Prolog 9.2.9, current_table/2 enumera las tablas
%   solo con el módulo y los argumentos libres. Borra antes todas las
%   tablas.
alcanzadas_signos(Programa, Entradas, Ss) :-
    abolish_all_tables,
    finales_signos(Programa, Entradas, _),
    findall(S, ( current_table(_:efecto(S, R, _), _),
                 R = estado(_) ),
            Ss0),
    sort(Ss0, Ss).

%!  muertas_signos(+Programa:list, +Entradas:list, -Muertas:list) is det.
%
%   Muertas es el conjunto ordenado de las sentencias de Programa que el
%   análisis de signos no alcanza en ningún estado: código muerto.
muertas_signos(Programa, Entradas, Muertas) :-
    alcanzadas_signos(Programa, Entradas, Ss),
    findall(S, ( sub_term(S, Programa),
                 es_sentencia(S),
                 \+ memberchk(S, Ss) ),
            Muertas0),
    sort(Muertas0, Muertas).

%!  muertas_caso(+Nombre, -Muertas:list) is semidet.
%
%   Como muertas_signos/3, sobre el caso Nombre con sus entradas.
muertas_caso(Nombre, Muertas) :-
    programa_caso(Nombre, Programa, Entradas),
    muertas_signos(Programa, Entradas, Muertas).

% es_sentencia(S): S es una sentencia de Mini.
es_sentencia(asignar(_, _)).
es_sentencia(escribir(_)).
es_sentencia(si(_, _, _)).
es_sentencia(mientras(_, _)).
