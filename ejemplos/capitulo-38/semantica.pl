:- encoding(utf8).

% Capítulo 38 - Evaluadores de la semántica de los programas lógicos.
%
% Los programas objeto son cláusulas comunes de este archivo; programa/2
% nombra los predicados de cada uno, y clausulas/2 los lee con clause/2,
% como en el capítulo 33, en una lista de términos Cabeza :- Cuerpo. Un
% programa que se construye como datos, como cadena(N), se nombra con
% generado/2. Cada evaluador tiene dos formas: el que termina en _de
% trabaja sobre la lista de cláusulas, y el otro recibe el nombre del
% programa. Los evaluadores trabajan de abajo hacia arriba: una
% interpretación es un conjunto ordenado de átomos sin variables.
% es_modelo/2 verifica un modelo, consecuencias/3 es el operador T_P, y
% modelo_minimo/2, ingenua/4 y semi_ingenua/4 calculan el modelo mínimo.
% estratos/2 y ciclos_negativos/2 examinan la negación, modelo_estandar/2
% evalúa un programa estratificado y bien_fundado/3 calcula la semántica
% bien fundada de cualquier programa.
%
%?- modelo_minimo(lluvia, M).
%?- es_modelo(lluvia, [calle_mojada, llueve]).
%?- estratos(grafo, E).
%?- bien_fundado(circular, V, I).

% programa(Nombre, Predicados): los predicados que forman el programa Nombre.
programa(lluvia, [llueve/0, riego/0, calle_mojada/0]).
programa(caminos, [arco/2, camino/2]).
programa(grafo, [arco/2, nodo/1, camino/2, inalcanzable/2]).
programa(juego, [mueve/3, gana/2]).
programa(circular, [p/0, q/0, r/0, s/0, t/0]).

% Los predicados sin cláusulas se declaran dinámicos: así existen, y
% clause/2 no encuentra ninguna cláusula de ellos.
:- dynamic riego/0, t/0.

% llueve: llueve.
llueve.

%!  calle_mojada is semidet.
%
%   La calle está mojada si llueve o si se riega.
calle_mojada :-
    llueve.
calle_mojada :-
    riego.

% arco(X, Y): hay un arco de X a Y.
arco(a, b).
arco(b, c).
arco(c, a).
arco(c, d).

% nodo(X): X es un nodo del grafo.
nodo(a).
nodo(b).
nodo(c).
nodo(d).

%!  camino(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Con la recursión a la izquierda y el ciclo de
%   a, b y c, Prolog no termina: el programa se evalúa de abajo hacia
%   arriba.
camino(X, Y) :-
    arco(X, Y).
camino(X, Y) :-
    camino(X, Z),
    arco(Z, Y).

%!  inalcanzable(?X, ?Y) is nondet.
%
%   X e Y son nodos, y no hay un camino de X a Y.
inalcanzable(X, Y) :-
    nodo(X),
    nodo(Y),
    \+ camino(X, Y).

% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y.
mueve(j1, a, b).
mueve(j1, b, a).
mueve(j1, b, c).
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana: puede pasar a una posición desde
%   la que el rival no gana. Con los ciclos de los dos juegos, Prolog no
%   termina.
gana(J, X) :-
    mueve(J, X, Y),
    \+ gana(J, Y).

%!  p is semidet.
%
%   p se cumple si q no se cumple.
p :-
    \+ q.

%!  q is semidet.
%
%   q se cumple si p no se cumple.
q :-
    \+ p.

%!  r is semidet.
%
%   r se cumple si r no se cumple: Prolog no termina.
r :-
    \+ r.

%!  s is semidet.
%
%   s se cumple si t, que no tiene cláusulas, no se cumple.
s :-
    \+ t.

%!  clausulas(+Programa, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas del programa llamado Programa, como
%   términos Cabeza :- Cuerpo; un hecho tiene el cuerpo true. Si Programa
%   está en programa/2, son las de sus predicados, en el orden de
%   programa/2 y, dentro de cada predicado, en el del archivo; si no, las
%   que construye generado/2. Error de existencia si no es ninguno de los
%   dos.
clausulas(Programa, Clausulas) :-
    must_be(callable, Programa),
    (   programa(Programa, Indicadores)
    ->  findall(Cabeza :- Cuerpo,
                ( member(Nombre/Aridad, Indicadores),
                  functor(Cabeza, Nombre, Aridad),
                  clause(Cabeza, Cuerpo) ),
                Clausulas)
    ;   generado(Programa, Generadas)
    ->  Clausulas = Generadas
    ;   existence_error(programa, Programa)
    ).

% Otros archivos agregan programas generados: generado/2 es multifile.
:- multifile generado/2.

%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Clausulas son las del programa Programa, construido como datos: aquí,
%   cadena(N), el de cadena/2. Falla con otro nombre.
generado(cadena(N), Clausulas) :-
    cadena(N, Clausulas).

%!  cumple(+Cuerpo, +I:list, +J:list) is nondet.
%
%   Cuerpo es verdadero con los átomos de la interpretación I; un literal
%   negado \+ A es verdadero si A no está en la interpretación J. Una
%   respuesta por cada forma de hacerlo verdadero, con las variables del
%   cuerpo ligadas. Las comparaciones aritméticas se evalúan con Prolog.
%   Error de instanciación si un literal negado tiene variables.
cumple(true, _, _).
cumple((A, B), I, J) :-
    cumple(A, I, J),
    cumple(B, I, J).
cumple(\+ A, _, J) :-
    must_be(ground, A),
    \+ ord_memberchk(A, J).
cumple(C, _, _) :-
    comparacion(C),
    comparar(C).
cumple(A, I, _) :-
    atomo(A),
    member(A, I).

% comparacion(C): C es una comparación aritmética.
comparacion(_ < _).
comparacion(_ > _).
comparacion(_ =< _).
comparacion(_ >= _).
comparacion(_ =:= _).
comparacion(_ =\= _).

%!  comparar(+C) is semidet.
%
%   La comparación aritmética C se cumple.
comparar(X < Y) :-
    X < Y.
comparar(X > Y) :-
    X > Y.
comparar(X =< Y) :-
    X =< Y.
comparar(X >= Y) :-
    X >= Y.
comparar(X =:= Y) :-
    X =:= Y.
comparar(X =\= Y) :-
    X =\= Y.

%!  atomo(+Literal) is semidet.
%
%   Literal es un átomo del programa: no es true, ni una conjunción, ni una
%   negación, ni una comparación.
atomo(A) :-
    A \= true,
    A \= (_, _),
    A \= (\+ _),
    \+ comparacion(A).

%!  es_modelo_de(+Clausulas:list, +I:list) is semidet.
%
%   I, una lista de átomos sin variables, es un modelo de Clausulas: no hay
%   una cláusula con el cuerpo verdadero en I y la cabeza fuera de I.
es_modelo_de(Clausulas, I0) :-
    sort(I0, I),
    \+ ( member(Cabeza :- Cuerpo, Clausulas),
         cumple(Cuerpo, I, I),
         \+ ord_memberchk(Cabeza, I) ).

%!  es_modelo(+Programa, +I:list) is semidet.
%
%   I es un modelo del programa llamado Programa: es_modelo_de/2 sobre sus
%   cláusulas.
es_modelo(Programa, I) :-
    clausulas(Programa, Clausulas),
    es_modelo_de(Clausulas, I).

%!  derivar(+Clausulas:list, +I:list, +J:list, -Cabezas:list) is det.
%
%   Cabezas son las cabezas de las cláusulas cuyo cuerpo es verdadero con
%   I y J (cumple/3), una por cada forma de hacerlo verdadero, con
%   repeticiones. Error de instanciación si una cabeza queda con variables.
derivar(Clausulas, I, J, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              cumple(Cuerpo, I, J),
              must_be(ground, Cabeza) ),
            Cabezas).

%!  consecuencias_de(+Clausulas:list, +I:list, -T:list) is det.
%
%   T es T_P(I), el conjunto ordenado de las consecuencias inmediatas de I:
%   las cabezas de las cláusulas cuyo cuerpo es verdadero en I.
consecuencias_de(Clausulas, I, T) :-
    derivar(Clausulas, I, I, Cabezas),
    sort(Cabezas, T).

%!  consecuencias(+Programa, +I:list, -T:list) is det.
%
%   T es T_P(I) para el programa llamado Programa.
consecuencias(Programa, I, T) :-
    clausulas(Programa, Clausulas),
    consecuencias_de(Clausulas, I, T).

%!  modelo_minimo_de(+Clausulas:list, -M:list) is det.
%
%   M es el modelo mínimo de Clausulas, un programa definido: el punto
%   fijo de T_P que se alcanza desde la interpretación vacía.
modelo_minimo_de(Clausulas, M) :-
    ingenua_de(Clausulas, [], M, _).

%!  modelo_minimo(+Programa, -M:list) is det.
%
%   M es el modelo mínimo del programa definido llamado Programa.
modelo_minimo(Programa, M) :-
    clausulas(Programa, Clausulas),
    modelo_minimo_de(Clausulas, M).

%!  consecuencia(+Programa, ?Atomo) is nondet.
%
%   Atomo es consecuencia lógica del programa definido llamado Programa:
%   está en su modelo mínimo. Una respuesta por átomo, en orden.
consecuencia(Programa, Atomo) :-
    modelo_minimo(Programa, M),
    member(Atomo, M).

%!  ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación ingenua: M es el primer I que no cambia en la sucesión que
%   empieza en I0 y agrega en cada paso T_P(I). Costo es costo(Pasos,
%   Derivaciones): cuántas veces se aplicó T_P, y cuántas cabezas derivaron
%   todas esas aplicaciones, contando las repetidas.
ingenua_de(Clausulas, I0, M, Costo) :-
    ingenua_de(Clausulas, I0, M, costo(0, 0), Costo).

%!  ingenua_de(+Clausulas:list, +I:list, -M:list, +Costo0, -Costo) is det.
%
%   Continúa la evaluación ingenua desde I. Costo0 es el costo acumulado
%   hasta aquí, y Costo el total al llegar a M.
ingenua_de(Clausulas, I, M, costo(P0, D0), Costo) :-
    derivar(Clausulas, I, I, Cabezas),
    length(Cabezas, D),
    P is P0 + 1,
    D1 is D0 + D,
    sort(Cabezas, T),
    ord_union(I, T, I1),
    (   I1 == I
    ->  M = I,
        Costo = costo(P, D1)
    ;   ingenua_de(Clausulas, I1, M, costo(P, D1), Costo)
    ).

%!  ingenua(+Programa, +I0:list, -M:list, -Costo) is det.
%
%   ingenua_de/4 sobre las cláusulas del programa llamado Programa.
ingenua(Programa, I0, M, Costo) :-
    clausulas(Programa, Clausulas),
    ingenua_de(Clausulas, I0, M, Costo).

%!  semi_ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación semi-ingenua: el mismo M que ingenua_de/4. Después del primer
%   paso, cada cláusula se evalúa solo con al menos un átomo del cuerpo
%   tomado de los nuevos del paso anterior. Costo, como en ingenua_de/4.
semi_ingenua_de(Clausulas, I0, M, Costo) :-
    derivar(Clausulas, I0, I0, Cabezas),
    length(Cabezas, D),
    sort(Cabezas, T),
    ord_subtract(T, I0, Nuevos),
    ord_union(I0, Nuevos, I1),
    semi_ingenua_de(Clausulas, I1, Nuevos, M, costo(1, D), Costo).

%!  semi_ingenua_de(+Clausulas:list, +I:list, +Nuevos:list, -M:list,
%!                  +Costo0, -Costo) is det.
%
%   Continúa la evaluación semi-ingenua desde I; Nuevos son los átomos que
%   agregó el paso anterior. Costo0 es el costo acumulado hasta aquí, y
%   Costo el total al llegar a M.
semi_ingenua_de(Clausulas, I, Nuevos, M, costo(P0, D0), Costo) :-
    (   Nuevos == []
    ->  M = I,
        Costo = costo(P0, D0)
    ;   derivar_con_nuevos(Clausulas, I, Nuevos, Cabezas),
        length(Cabezas, D),
        P is P0 + 1,
        D1 is D0 + D,
        sort(Cabezas, T),
        ord_subtract(T, I, Nuevos1),
        ord_union(I, Nuevos1, I1),
        semi_ingenua_de(Clausulas, I1, Nuevos1, M, costo(P, D1), Costo)
    ).

%!  semi_ingenua(+Programa, +I0:list, -M:list, -Costo) is det.
%
%   semi_ingenua_de/4 sobre las cláusulas del programa llamado Programa.
semi_ingenua(Programa, I0, M, Costo) :-
    clausulas(Programa, Clausulas),
    semi_ingenua_de(Clausulas, I0, M, Costo).

%!  derivar_con_nuevos(+Clausulas:list, +I:list, +Nuevos:list,
%!                     -Cabezas:list) is det.
%
%   Cabezas son las de derivar/4 con I, restringidas a las derivaciones que
%   toman de Nuevos el átomo de alguna posición del cuerpo; los demás
%   literales se evalúan con I. Una derivación que usa dos átomos nuevos
%   aparece dos veces.
derivar_con_nuevos(Clausulas, I, Nuevos, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              conjuncion_lista(Cuerpo, Literales),
              append(Antes, [Literal|Despues], Literales),
              atomo(Literal),
              member(Literal, Nuevos),
              cumple_todos(Antes, I),
              cumple_todos(Despues, I),
              must_be(ground, Cabeza) ),
            Cabezas).

%!  cumple_todos(+Literales:list, +I:list) is nondet.
%
%   Cada uno de Literales es verdadero en I, evaluados de izquierda a
%   derecha con cumple/3.
cumple_todos([], _).
cumple_todos([L|Ls], I) :-
    cumple(L, I, I),
    cumple_todos(Ls, I).

%!  conjuncion_lista(+Cuerpo, -Literales:list) is det.
%
%   Literales son las partes de la conjunción Cuerpo, de izquierda a
%   derecha; el cuerpo true no tiene ninguna.
conjuncion_lista(Cuerpo, Literales) :-
    (   Cuerpo == true
    ->  Literales = []
    ;   Cuerpo = (A, B)
    ->  conjuncion_lista(A, La),
        conjuncion_lista(B, Lb),
        append(La, Lb, Literales)
    ;   Literales = [Cuerpo]
    ).

%!  dependencias_de(+Clausulas:list, -Aristas:list) is det.
%
%   Aristas son los términos P-Q-Signo, ordenados y sin repetir: una
%   cláusula de P tiene en el cuerpo un literal de Q, positivo (Signo es
%   pos) o negado (neg). Las comparaciones no cuentan.
dependencias_de(Clausulas, Aristas) :-
    findall(P-Q-Signo,
            ( member(Cabeza :- Cuerpo, Clausulas),
              indicador(Cabeza, P),
              conjuncion_lista(Cuerpo, Literales),
              member(Literal, Literales),
              dependencia(Literal, Q, Signo) ),
            Todas),
    sort(Todas, Aristas).

%!  dependencias(+Programa, -Aristas:list) is det.
%
%   Aristas es el grafo de dependencias del programa llamado Programa.
dependencias(Programa, Aristas) :-
    clausulas(Programa, Clausulas),
    dependencias_de(Clausulas, Aristas).

%!  dependencia(+Literal, -Q, -Signo) is semidet.
%
%   Literal es un literal de Q, con el Signo pos o neg. Falla con una
%   comparación.
dependencia(\+ A, Q, neg) :-
    indicador(A, Q).
dependencia(A, Q, pos) :-
    atomo(A),
    indicador(A, Q).

%!  indicador(+Atomo, -Indicador) is det.
%
%   Indicador es Nombre/Aridad, el predicado de Atomo.
indicador(Atomo, Nombre/Aridad) :-
    functor(Atomo, Nombre, Aridad).

%!  estratos_de(+Clausulas:list, -Estratos:list) is semidet.
%
%   Estratos son los pares N-Predicados, de N = 0 en adelante: los
%   predicados de Clausulas agrupados por estrato. El estrato de un
%   predicado es el menor número que no es menor que el de ninguno de los
%   que usa en positivo, y es mayor que el de cada uno que usa negado.
%   Falla si el programa no es estratificado.
estratos_de(Clausulas, Estratos) :-
    niveles(Clausulas, Niveles),
    findall(N-P, member(P-N, Niveles), Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Estratos).

%!  estratos(+Programa, -Estratos:list) is semidet.
%
%   Estratos son los del programa llamado Programa. Falla si no es
%   estratificado.
estratos(Programa, Estratos) :-
    clausulas(Programa, Clausulas),
    estratos_de(Clausulas, Estratos).

%!  niveles(+Clausulas:list, -Niveles:list) is semidet.
%
%   Niveles son los pares Predicado-N, con el estrato N de cada predicado.
%   Parte de 0 para todos y sube lo que haga falta, en rondas; si un
%   estrato llega a la cantidad de predicados, hay un ciclo con una
%   negación, y falla.
niveles(Clausulas, Niveles) :-
    dependencias_de(Clausulas, Aristas),
    findall(P, ( member(Cabeza :- _, Clausulas), indicador(Cabeza, P)
               ; member(_-P-_, Aristas) ),
            Ps0),
    sort(Ps0, Ps),
    findall(P-0, member(P, Ps), N0),
    length(Ps, Tope),
    subir(Aristas, Tope, N0, Niveles).

%!  subir(+Aristas:list, +Tope:integer, +N0:list, -N:list) is semidet.
%
%   N son los niveles que resultan de subir los de N0 hasta que ninguna
%   arista los cambie. Falla si alguno llega a Tope.
subir(Aristas, Tope, N0, N) :-
    maplist(elevar(Aristas, N0), N0, N1),
    (   N1 == N0
    ->  N = N0
    ;   member(_-K, N1), K >= Tope
    ->  fail
    ;   subir(Aristas, Tope, N1, N)
    ).

%!  elevar(+Aristas:list, +Niveles:list, +P0, -P) is det.
%
%   P es el par Predicado-K de P0 con el nivel K que exigen sus aristas:
%   al menos el de cada predicado que usa, y uno más si lo usa negado.
elevar(Aristas, Niveles, P-K0, P-K) :-
    findall(K1,
            ( member(P-Q-Signo, Aristas),
              memberchk(Q-KQ, Niveles),
              exigido(Signo, KQ, K1) ),
            Ks),
    max_list([K0|Ks], K).

%!  exigido(+Signo, +KQ:integer, -K:integer) is det.
%
%   K es el nivel mínimo de quien usa, con Signo, un predicado de nivel KQ.
exigido(pos, K, K).
exigido(neg, KQ, K) :-
    K is KQ + 1.

%!  ciclos_negativos_de(+Clausulas:list, -Pares:list) is det.
%
%   Pares son los P-Q, ordenados, tales que P usa negado a Q y Q depende, de
%   forma directa o indirecta, de P: cada par cierra un ciclo que pasa por
%   una negación. Pares es vacía si y solo si el programa es estratificado.
ciclos_negativos_de(Clausulas, Pares) :-
    dependencias_de(Clausulas, Aristas),
    findall(P-Q,
            ( member(P-Q-neg, Aristas),
              alcanza(Aristas, Q, P) ),
            Todos),
    sort(Todos, Pares).

%!  ciclos_negativos(+Programa, -Pares:list) is det.
%
%   Pares cierran los ciclos con una negación del programa llamado
%   Programa.
ciclos_negativos(Programa, Pares) :-
    clausulas(Programa, Clausulas),
    ciclos_negativos_de(Clausulas, Pares).

%!  alcanza(+Aristas:list, +Desde, +Hasta) is semidet.
%
%   Hay una sucesión de aristas, quizás vacía, de Desde a Hasta.
alcanza(Aristas, Desde, Hasta) :-
    alcanza(Aristas, [Desde], [], Hasta).

%!  alcanza(+Aristas:list, +Pendientes:list, +Vistos:list, +Hasta)
%!      is semidet.
%
%   Hasta está en Pendientes o se alcanza desde alguno de ellos, en anchura
%   y sin volver a recorrer los nodos de Vistos.
alcanza(Aristas, [X|Pendientes], Vistos, Hasta) :-
    (   X == Hasta
    ->  true
    ;   memberchk(X, Vistos)
    ->  alcanza(Aristas, Pendientes, Vistos, Hasta)
    ;   findall(Y, member(X-Y-_, Aristas), Ys),
        append(Pendientes, Ys, Pendientes1),
        alcanza(Aristas, Pendientes1, [X|Vistos], Hasta)
    ).

%!  modelo_estandar_de(+Clausulas:list, -M:list) is semidet.
%
%   M es el modelo estándar de Clausulas, un programa estratificado: cada
%   estrato, del 0 en adelante, se evalúa con semi_ingenua_de/4 a partir del
%   modelo de los anteriores. Falla si el programa no es estratificado.
modelo_estandar_de(Clausulas, M) :-
    estratos_de(Clausulas, Estratos),
    foldl(evaluar_estrato(Clausulas), Estratos, [], M).

%!  modelo_estandar(+Programa, -M:list) is semidet.
%
%   M es el modelo estándar del programa llamado Programa. Falla si no es
%   estratificado.
modelo_estandar(Programa, M) :-
    clausulas(Programa, Clausulas),
    modelo_estandar_de(Clausulas, M).

%!  evaluar_estrato(+Clausulas:list, +Estrato, +I0:list, -I:list) is det.
%
%   I agrega a I0 las consecuencias de las cláusulas de los predicados del
%   Estrato, N-Predicados, hasta el punto fijo.
evaluar_estrato(Clausulas, _-Predicados, I0, I) :-
    include(define_alguno(Predicados), Clausulas, DelEstrato),
    semi_ingenua_de(DelEstrato, I0, I, _).

%!  define_alguno(+Predicados:list, +Clausula) is semidet.
%
%   La cabeza de Clausula es de uno de Predicados.
define_alguno(Predicados, Cabeza :- _) :-
    indicador(Cabeza, P),
    memberchk(P, Predicados).

%!  reducido(+Clausulas:list, +J:list, -M:list) is det.
%
%   M es el modelo mínimo de Clausulas con las negaciones fijas: \+ A es
%   verdadero si A no está en J, y no cambia mientras M crece.
reducido(Clausulas, J, M) :-
    reducido(Clausulas, J, [], M).

%!  reducido(+Clausulas:list, +J:list, +I:list, -M:list) is det.
%
%   M es el punto fijo que se alcanza desde I, con las negaciones fijas
%   como en reducido/3.
reducido(Clausulas, J, I, M) :-
    derivar(Clausulas, I, J, Cabezas),
    sort(Cabezas, T),
    ord_union(I, T, I1),
    (   I1 == I
    ->  M = I
    ;   reducido(Clausulas, J, I1, M)
    ).

%!  bien_fundado_de(+Clausulas:list, -Verdaderos:list, -Indefinidos:list)
%!      is det.
%
%   El modelo bien fundado de Clausulas: Verdaderos son los átomos
%   verdaderos, e Indefinidos los que no son verdaderos ni falsos; todos
%   los demás son falsos. Alterna dos cálculos con reducido/3: lo que es
%   posible si es falso todo lo que todavía no es verdadero, y lo que es
%   verdadero si es falso todo lo que no es posible, hasta que no cambian.
bien_fundado_de(Clausulas, Verdaderos, Indefinidos) :-
    alternar(Clausulas, [], Verdaderos, Posibles),
    ord_subtract(Posibles, Verdaderos, Indefinidos).

%!  bien_fundado(+Programa, -Verdaderos:list, -Indefinidos:list) is det.
%
%   El modelo bien fundado del programa llamado Programa.
bien_fundado(Programa, Verdaderos, Indefinidos) :-
    clausulas(Programa, Clausulas),
    bien_fundado_de(Clausulas, Verdaderos, Indefinidos).

%!  alternar(+Clausulas:list, +V0:list, -V:list, -P:list) is det.
%
%   V son los átomos verdaderos y P los posibles, calculados desde los
%   verdaderos V0.
alternar(Clausulas, V0, V, P) :-
    reducido(Clausulas, V0, P0),
    reducido(Clausulas, P0, V1),
    (   V1 == V0
    ->  V = V0,
        P = P0
    ;   alternar(Clausulas, V1, V, P)
    ).

%!  valor_de(+Clausulas:list, +Atomo, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Atomo, sin variables, en
%   el modelo bien fundado de Clausulas.
valor_de(Clausulas, Atomo, Valor) :-
    must_be(ground, Atomo),
    bien_fundado_de(Clausulas, Verdaderos, Indefinidos),
    (   ord_memberchk(Atomo, Verdaderos)
    ->  Valor = verdadero
    ;   ord_memberchk(Atomo, Indefinidos)
    ->  Valor = indefinido
    ;   Valor = falso
    ).

%!  valor(+Programa, +Atomo, -Valor) is det.
%
%   Valor es el de Atomo en el modelo bien fundado del programa llamado
%   Programa.
valor(Programa, Atomo, Valor) :-
    clausulas(Programa, Clausulas),
    valor_de(Clausulas, Atomo, Valor).

%!  cadena(+N:integer, -Clausulas:list) is det.
%
%   Clausulas son las de camino/2 sobre un grafo de N arcos en fila:
%   arco(0, 1), arco(1, 2), ..., hasta el nodo N.
cadena(N, Clausulas) :-
    findall(arco(I, J) :- true,
            ( between(1, N, J),
              I is J - 1 ),
            Arcos),
    findall(camino(X, Y) :- Cuerpo, clause(camino(X, Y), Cuerpo), Reglas),
    append(Arcos, Reglas, Clausulas).
