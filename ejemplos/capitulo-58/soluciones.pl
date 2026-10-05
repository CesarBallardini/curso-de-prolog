:- encoding(utf8).

% Capítulo 58 - Soluciones de los ejercicios.
%
% solo-local: carga informe.pl, simbolico.pl y procedimientos.pl con
% ensure_loaded/1.
%
%?- analizar("x := 2 * n + 1; mientras x <> 0 hacer x := x - 2 fin", P),
%   analisis(paridad, P, [n-entre(inf, sup)], F, Os).
%?- sin_asignar_texto("escribir z; z := z + 1", Xs).
%?- programa_caso(diez, P, _), analisis_umbrales(P, [], F, Os).

:- use_module(library(clpfd)).
:- ensure_loaded(informe).
:- ensure_loaded(simbolico).
:- ensure_loaded(procedimientos).

% Los ejercicios 3, 6 y 11 agregan dominios: cláusulas de las operaciones
% multifile de reticulado.pl, separadas por dominio.
:- discontiguous
    dom_constante/3,
    dom_rango/3,
    dom_operar/5,
    dom_cero/2,
    dom_refinar/5,
    dom_unir/4,
    dom_ensanchar/4,
    dom_contiene/3.

% Ejercicio 3: el dominio de la paridad, con los valores par, impar y top.

dom_constante(paridad, N, V) :-
    paridad_de(N, V).

dom_rango(paridad, entre(Min, Max), V) :-
    (   integer(Min),
        Min == Max
    ->  paridad_de(Min, V)
    ;   V = top
    ).

dom_operar(paridad, Op, A, B, V) :-
    operar_paridad(Op, A, B, V).

dom_cero(paridad, par).
dom_cero(paridad, top).

dom_refinar(paridad, Op, A, B, V) :-
    refinar_paridad(Op, A, B, V).

dom_unir(paridad, A, B, V) :-
    unir_paridad(A, B, V).

dom_ensanchar(paridad, A, B, V) :-
    unir_paridad(A, B, V).

dom_contiene(paridad, top, _).
dom_contiene(paridad, par, N) :-
    N mod 2 =:= 0.
dom_contiene(paridad, impar, N) :-
    N mod 2 =:= 1.

%!  paridad_de(+N:integer, -V) is det.
%
%   V es la paridad del entero N: par o impar.
paridad_de(N, V) :-
    (   N mod 2 =:= 0
    ->  V = par
    ;   V = impar
    ).

%!  operar_paridad(+Op, +A, +B, -V) is det.
%
%   V es la paridad del resultado de la operación Op de Mini entre valores
%   de paridad A y B. El cociente no conserva la paridad: 6 / 2 es impar.
operar_paridad(+, A, B, V) :-
    sumar_paridad(A, B, V).
operar_paridad(-, A, B, V) :-
    sumar_paridad(A, B, V).
operar_paridad(*, A, B, V) :-
    multiplicar_paridad(A, B, V).
operar_paridad(/, _, _, top).

%!  sumar_paridad(+A, +B, -V) is det.
%
%   V es la paridad de una suma o una resta: par si los dos operandos tienen
%   la misma paridad conocida, impar si la tienen distinta, y top si alguno
%   es top.
sumar_paridad(A, B, V) :-
    (   ( A == top ; B == top )
    ->  V = top
    ;   A == B
    ->  V = par
    ;   V = impar
    ).

%!  multiplicar_paridad(+A, +B, -V) is det.
%
%   V es la paridad de un producto: par si algún factor es par, aunque el
%   otro sea top.
multiplicar_paridad(A, B, V) :-
    (   ( A == par ; B == par )
    ->  V = par
    ;   ( A == top ; B == top )
    ->  V = top
    ;   V = impar
    ).

%!  refinar_paridad(+Op, +A, +B, -V) is semidet.
%
%   V es la paridad A restringida por la comparación Op con un valor de
%   paridad B: solo = restringe, a la paridad común. Falla si A y B son
%   paridades distintas y Op es =.
refinar_paridad(Op, A, B, V) :-
    (   Op == (=)
    ->  (   A == top
        ->  V = B
        ;   B == top
        ->  V = A
        ;   A == B,
            V = A
        )
    ;   V = A
    ).

%!  unir_paridad(+A, +B, -V) is det.
%
%   V es la unión de dos paridades: la misma si son iguales, top si no.
unir_paridad(A, B, V) :-
    (   A == B
    ->  V = A
    ;   V = top
    ).

% Ejercicio 4: variables leídas antes de asignarse (Warren).

%!  sin_asignar_texto(+Texto, -Xs:list(atom)) is semidet.
%
%   Xs son las variables que el programa Mini de Texto puede leer antes de
%   asignarlas. Falla si Texto no es un programa Mini.
sin_asignar_texto(Texto, Xs) :-
    analizar(Texto, Programa),
    sin_asignar(Programa, Xs).

%!  sin_asignar(+Programa:list, -Xs:list(atom)) is det.
%
%   Xs es el conjunto ordenado de las variables que alguna ejecución de
%   Programa puede leer antes de asignarlas. Un estado es s(Entorno,
%   Leidas): cada variable asignada o sin_asignar, y las leídas sin
%   asignar hasta allí. Las condiciones no se deciden.
sin_asignar(Programa, Xs) :-
    variables(Programa, Vs),
    findall(V-sin_asignar, member(V, Vs), E0),
    findall(L, def_bloque(Programa, s(E0, []), s(_, L)), Ls),
    append(Ls, L1),
    sort(L1, Xs).

%!  def_bloque(+Ss:list, +S0, -S) is nondet.
%
%   Ejecutar las sentencias Ss puede llevar el estado S0 a S.
def_bloque([], S, S).
def_bloque([Sent|Ss], S0, S) :-
    def(Sent, S0, S1),
    def_bloque(Ss, S1, S).

:- table def/3.

%!  def(+Sent, +S0, -S) is nondet.
%
%   Ejecutar la sentencia Sent puede llevar el estado S0 a S. Una respuesta
%   por estado alcanzable; tabulada, termina con los bucles.
def(asignar(X, Exp), s(E0, L0), s(E, L)) :-
    leer(Exp, E0, L0, L),
    actualizar(X, asignada, E0, E).
def(escribir(Exp), s(E, L0), s(E, L)) :-
    leer(Exp, E, L0, L).
def(si(C, Si, No), s(E, L0), S) :-
    leer(C, E, L0, L),
    (   def_bloque(Si, s(E, L), S)
    ;   def_bloque(No, s(E, L), S)
    ).
def(mientras(C, Cuerpo), s(E, L0), S) :-
    leer(C, E, L0, L),
    (   S = s(E, L)
    ;   def_bloque(Cuerpo, s(E, L), S1),
        def(mientras(C, Cuerpo), S1, S)
    ).

%!  leer(+T, +E:list, +L0:list, -L:list) is det.
%
%   L es el conjunto L0 con las variables que T, una expresión o una
%   condición, lee mientras están sin_asignar en el entorno E.
leer(T, E, L0, L) :-
    findall(X, ( sub_term(id(X), T),
                 valor(X, E, sin_asignar) ),
            Xs),
    append(L0, Xs, L1),
    sort(L1, L).

% Ejercicio 5: una vuelta más sin ensanchar.

%!  estrechar(+Bucle, +E0, -I) is det.
%
%   I es el estado en la condición del mientras Bucle, al que se llega con
%   E0, mejorado con una vuelta sin ensanchar: la unión de E0 con el
%   final del cuerpo desde el invariante de cabeza/3 restringido por la
%   condición. I sigue siendo correcto, y puede ser más preciso.
estrechar(mientras(C, Cuerpo), E0, I) :-
    cabeza(mientras(C, Cuerpo), E0, I0),
    phrase(( partir(C, I0, Dentro, _),
             abs_bloque(Cuerpo, Dentro, E1) ),
           _),
    unir_estados(E0, E1, I).

%!  diez_estrechado(-I, -Fuera) is det.
%
%   I es el estado estrechado en la condición del bucle de diez, y Fuera el
%   estado al salir de él.
diez_estrechado(I, Fuera) :-
    programa_caso(diez, [Asignar, Bucle|_], Es),
    inicial(intervalos, [Asignar, Bucle], Es, Ini),
    phrase(abs_bloque([Asignar], Ini, E0), _),
    estrechar(Bucle, E0, I),
    Bucle = mientras(C, _),
    phrase(partir(C, I, _, Fuera), _).

% Ejercicio 6: signos con noneg y nopos.

dom_constante(signos6, N, S) :-
    signo_de(N, S).

dom_rango(signos6, Rango, V) :-
    findall(S, signo_en(Rango, S), Ss),
    alfa6(Ss, V).

dom_operar(signos6, Op, A, B, V) :-
    findall(S, ( gama6(A, SA),
                 gama6(B, SB),
                 op_signos(Op, SA, SB, S),
                 signo(S) ),
            Ss),
    alfa6(Ss, V).

dom_cero(signos6, V) :-
    once(gama6(V, cero)).

dom_refinar(signos6, Op, A, B, V) :-
    findall(SA, ( gama6(A, SA),
                  gama6(B, SB),
                  posible(Op, SA, SB) ),
            Ss),
    Ss \== [],
    alfa6(Ss, V).

dom_unir(signos6, A, B, V) :-
    findall(S, ( gama6(A, S) ; gama6(B, S) ), Ss),
    alfa6(Ss, V).

dom_ensanchar(signos6, A, B, V) :-
    dom_unir(signos6, A, B, V).

dom_contiene(signos6, V, N) :-
    signo_de(N, S),
    once(gama6(V, S)).

%!  gama6(+V, -S) is nondet.
%
%   S es un signo que representa el valor V del dominio signos6.
gama6(V, S) :-
    representa6(V, Ss),
    member(S, Ss).

% representa6(V, Ss): Ss son los signos que representa V.
representa6(neg, [neg]).
representa6(cero, [cero]).
representa6(pos, [pos]).
representa6(noneg, [cero, pos]).
representa6(nopos, [cero, neg]).
representa6(top, [cero, neg, pos]).

%!  alfa6(+Ss:list, -V) is det.
%
%   V es el menor valor de signos6 que representa los signos de Ss; sin
%   ninguno, top.
alfa6(Ss0, V) :-
    sort(Ss0, Ss),
    (   Ss \== [],
        representa6(V0, Ss)
    ->  V = V0
    ;   V = top
    ).

% Ejercicio 8: caminos posibles de la ejecución simbólica.

%!  camino_posible(+Nombre, -Condiciones:list, -Salida:list) is nondet.
%
%   Como simbolizar_caso/3, pero solo los caminos cuyas condiciones puede
%   cumplir algún entero, según la propagación de library(clpfd). Una
%   propagación que no falla no prueba que haya solución: el filtro puede
%   dejar un camino imposible, nunca descarta uno posible.
camino_posible(Nombre, Condiciones, Salida) :-
    simbolizar_caso(Nombre, Condiciones, Salida),
    \+ \+ posibles(Condiciones).

%!  posibles(+Cs:list) is semidet.
%
%   Las comparaciones de Cs, con cada incógnita como una variable de
%   restricción, no se contradicen según la propagación.
posibles(Cs) :-
    incognitas(Cs, Ps),
    maplist(restriccion(Ps), Cs).

%!  incognitas(+T, -Ps:list) is det.
%
%   Ps tiene un par Atomo-Variable por cada incógnita de T, con una
%   variable nueva.
incognitas(T, Ps) :-
    findall(A, ( sub_term(A, T), atom(A), A \== [] ), As0),
    sort(As0, As),
    findall(A-_, member(A, As), Ps).

%!  restriccion(+Ps:list, +C) is semidet.
%
%   Impone la comparación C de Prolog como restricción de clpfd, con las
%   incógnitas reemplazadas según Ps.
restriccion(Ps, C) :-
    C =.. [Op, A, B],
    restriccion_de(Op, R),
    reemplazar(Ps, A, VA),
    reemplazar(Ps, B, VB),
    Meta =.. [R, VA, VB],
    call(Meta).

% restriccion_de(Op, R): R es la restricción de clpfd de la comparación Op.
restriccion_de(<, #<).
restriccion_de(>, #>).
restriccion_de(=<, #=<).
restriccion_de(>=, #>=).
restriccion_de(=:=, #=).
restriccion_de(=\=, #\=).

%!  reemplazar(+Ps:list, +T, -V) is det.
%
%   V es la expresión T con cada incógnita reemplazada por su variable.
reemplazar(Ps, T, V) :-
    (   atom(T)
    ->  memberchk(T-V, Ps)
    ;   integer(T)
    ->  V = T
    ;   T =.. [F|As],
        maplist(reemplazar(Ps), As, Vs),
        V =.. [F|Vs]
    ).

% Ejercicio 10: sentencias inalcanzables.

%!  inalcanzables(+D, +Programa:list, +Entradas:list, -Ss:list) is det.
%
%   Ss son las sentencias de Programa a las que el análisis en el dominio D
%   llega con nada, según sus observaciones nunca y siempre: la rama de un
%   si cuya condición no se cumple nunca, o siempre; el cuerpo de un
%   mientras que no se ejecuta; lo que sigue a un mientras del que no se
%   sale. Solo las sentencias de más afuera de cada bloque muerto.
inalcanzables(D, Programa, Entradas, Ss) :-
    analisis(D, Programa, Entradas, _, Obs),
    phrase(muertas(Programa, vivo, Obs), Ss).

%!  muertas(+Ss:list, +Estado, +Obs:list)// is det.
%
%   Las sentencias de Ss que no se alcanzan, si el bloque empieza vivo o
%   muerto.
muertas([], _, _) -->
    [].
muertas([S|Ss], Estado, Obs) -->
    muerta_segun(Estado, S, Obs, Sigue),
    muertas(Ss, Sigue, Obs).

%!  muerta_segun(+Estado, +S, +Obs:list, -Sigue)// is det.
%
%   Las sentencias inalcanzables de S, si se llega a S viva o muerta.
muerta_segun(muerto, S, _, muerto) -->
    [S].
muerta_segun(vivo, S, Obs, Sigue) -->
    muerta_en(S, Obs, Sigue).

%!  muerta_en(+S, +Obs:list, -Sigue)// is det.
%
%   Las sentencias inalcanzables dentro de S, alcanzada; Sigue es muerto si
%   después de S no se llega a nada.
muerta_en(asignar(_, _), _, vivo) -->
    [].
muerta_en(escribir(_), _, vivo) -->
    [].
muerta_en(si(C, Si, No), Obs, vivo) -->
    rama(Si, nunca(C), Obs),
    rama(No, siempre(C), Obs).
muerta_en(mientras(C, Cuerpo), Obs, Sigue) -->
    rama(Cuerpo, nunca(C), Obs),
    { (   memberchk(siempre(C), Obs)
      ->  Sigue = muerto
      ;   Sigue = vivo
      ) }.

%!  rama(+Ss:list, +Marca, +Obs:list)// is det.
%
%   Las sentencias inalcanzables de la rama Ss: todas si Obs tiene la Marca,
%   y si no, las de adentro.
rama(Ss, Marca, Obs) -->
    (   { memberchk(Marca, Obs) }
    ->  muertas(Ss, muerto, Obs)
    ;   muertas(Ss, vivo, Obs)
    ).

% Ejercicio 11: ensanchamiento con umbrales del programa.

dom_constante(umbrales(_), N, V) :-
    dom_constante(intervalos, N, V).

dom_rango(umbrales(_), R, V) :-
    dom_rango(intervalos, R, V).

dom_operar(umbrales(_), Op, A, B, V) :-
    dom_operar(intervalos, Op, A, B, V).

dom_cero(umbrales(_), V) :-
    dom_cero(intervalos, V).

dom_refinar(umbrales(_), Op, A, B, V) :-
    dom_refinar(intervalos, Op, A, B, V).

dom_unir(umbrales(_), A, B, V) :-
    dom_unir(intervalos, A, B, V).

dom_ensanchar(umbrales(Ts), Viejo, Nuevo, i(E, F)) :-
    Viejo = i(A, B),
    dom_unir(intervalos, Viejo, Nuevo, i(C, D)),
    (   C == A
    ->  E = A
    ;   umbral_abajo(Ts, C, E)
    ),
    (   D == B
    ->  F = B
    ;   umbral_arriba(Ts, D, F)
    ).

dom_contiene(umbrales(_), V, N) :-
    dom_contiene(intervalos, V, N).

%!  umbral_abajo(+Ts:list, +C, -E) is det.
%
%   E es el mayor umbral de Ts que no supera la cota C, o inf.
umbral_abajo(Ts, C, E) :-
    include([T]>>cota_menor(T, C), Ts, Menores),
    (   Menores == []
    ->  E = inf
    ;   max_list(Menores, E)
    ).

%!  umbral_arriba(+Ts:list, +D, -F) is det.
%
%   F es el menor umbral de Ts que no es menor que la cota D, o sup.
umbral_arriba(Ts, D, F) :-
    include([T]>>cota_menor(D, T), Ts, Mayores),
    (   Mayores == []
    ->  F = sup
    ;   min_list(Mayores, F)
    ).

%!  analisis_umbrales(+Programa:list, +Entradas:list, -F, -Obs:list) is det.
%
%   Como analisis/5 con los intervalos, ensanchando hacia las constantes de
%   Programa y 0.
analisis_umbrales(Programa, Entradas, F, Obs) :-
    findall(N, sub_term(num(N), Programa), Ns),
    sort([0|Ns], Ts),
    analisis(umbrales(Ts), Programa, Entradas, F, Obs).

% Ejercicio 12: los contextos que pueden terminar en error.

%!  contextos_con_error(+Bloque, +Entradas:list, -Contextos:list) is det.
%
%   Contextos son los pares N-Vs, ordenados, de los procedimientos N que el
%   análisis de signos llama con los signos Vs en sus argumentos y cuyo
%   resumen incluye error.
contextos_con_error(Bloque, Entradas, Contextos) :-
    p_resumenes(Bloque, Entradas, Resumenes),
    findall(N-Vs, ( member(resumen(N, Vs, _, Salidas), Resumenes),
                    memberchk(error, Salidas) ),
            Contextos0),
    sort(Contextos0, Contextos).

%!  cociente_directo(-Bloque) is det.
%
%   Bloque es el de cociente con el bloque principal cambiado por una sola
%   llamada a dividir con a, sin la condición.
cociente_directo(bloque(Ds, Ss)) :-
    bloque_caso(cociente, bloque(Ds, _), _),
    traducir_sentencias([llamar(dividir, ["a"])], Ss).

%!  contextos_caso(+Nombre, -Contextos:list) is semidet.
%
%   Como contextos_con_error/3, sobre el caso Nombre con sus entradas.
contextos_caso(Nombre, Contextos) :-
    bloque_caso(Nombre, Bloque, Entradas),
    contextos_con_error(Bloque, Entradas, Contextos).

%!  contextos_directo(-Contextos:list) is det.
%
%   Como contextos_con_error/3, sobre el bloque de cociente_directo/1 con
%   a de cualquier signo.
contextos_directo(Contextos) :-
    cociente_directo(Bloque),
    contextos_con_error(Bloque, [a-entre(inf, sup)], Contextos).
