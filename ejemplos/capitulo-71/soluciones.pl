:- encoding(utf8).

% Capítulo 71 - Soluciones de los ejercicios.
%
% El archivo carga juego.pl, que carga las búsquedas de las versiones 2, 4
% y 5 y los problemas del mapa, las torres de Hanoi y el ta-te-ti, sin
% modificarlos. Los problemas nuevos agregan cláusulas a primitivo/2,
% expansion/4 y estimacion/3, que son multifile.
%
% solo-local: carga otros archivos.
%
%?- profundizando(rio(cero), ruta(alamos, islas), A, L), costo(A, C).
%?- contar_arboles(rio(cero), ruta(alamos, paso), N).

:- ensure_loaded(juego).

:- multifile primitivo/2, expansion/4, estimacion/3.

% --- Ejercicio 3: límite de profundidad y profundización progresiva -------

%!  resolver_limitado(+Problema, +Nodo, +Limite:integer, -Arbol) is nondet.
%
%   Arbol es un árbol solución de Nodo en el que ningún camino de la raíz a
%   una hoja pasa por más de Limite nodos expandidos. No lleva ancestros:
%   el límite basta para que la búsqueda termine.
resolver_limitado(Problema, Nodo, _, meta(Nodo)) :-
    primitivo(Problema, Nodo).
resolver_limitado(Problema, Nodo, Limite, Arbol) :-
    Limite > 0,
    expansion(Problema, Nodo, Tipo, Hijos),
    L1 is Limite - 1,
    limitado(Tipo, Problema, Nodo, Hijos, L1, Arbol).

%!  limitado(+Tipo, +Problema, +Nodo, +Hijos:list, +Limite:integer,
%!           -Arbol) is nondet.
%
%   Arbol es un árbol solución de Nodo, de Tipo o o y, con los hijos
%   resueltos dentro de Limite.
limitado(o, Problema, Nodo, Hijos, L, o(Nodo, A-C)) :-
    member(Hijo-C, Hijos),
    resolver_limitado(Problema, Hijo, L, A).
limitado(y, Problema, Nodo, Hijos, L, y(Nodo, Arcos)) :-
    maplist(arco_limitado(Problema, L), Hijos, Arcos).

%!  arco_limitado(+Problema, +Limite:integer, +Hijo, -Arco) is nondet.
%
%   Arco es A-C con un árbol A del hijo Hijo-C dentro de Limite.
arco_limitado(Problema, L, Hijo-C, A-C) :-
    resolver_limitado(Problema, Hijo, L, A).

%!  profundizando(+Problema, +Nodo, -Arbol, -Limite:integer) is semidet.
%
%   Arbol es el primer árbol solución de Nodo con el menor Limite posible,
%   hasta 20. Falla si no hay ninguno con ese límite.
profundizando(Problema, Nodo, Arbol, Limite) :-
    between(1, 20, Limite),
    resolver_limitado(Problema, Nodo, Limite, Arbol),
    !.

% --- Ejercicio 4: cuántos árboles solución hay -----------------------------

%!  contar_arboles(+Problema, +Nodo, -N:integer) is det.
%
%   N es la cantidad de árboles solución de Nodo que no repiten un nodo en
%   un mismo camino desde la raíz.
contar_arboles(Problema, Nodo, N) :-
    contar(Problema, Nodo, [], N).

%!  contar(+Problema, +Nodo, +Ancestros:list, -N:integer) is det.
%
%   N es la cantidad de árboles solución de Nodo que no pasan por ninguno
%   de Ancestros: la suma de los de sus hijos en un nodo O, y el producto
%   en un nodo Y.
contar(Problema, Nodo, Ancestros, N) :-
    (   memberchk(Nodo, Ancestros)
    ->  N = 0
    ;   primitivo(Problema, Nodo)
    ->  N = 1
    ;   expansion(Problema, Nodo, Tipo, Hijos)
    ->  maplist(contar_hijo(Problema, [Nodo|Ancestros]), Hijos, Ns),
        (   Tipo == o
        ->  sum_list(Ns, N)
        ;   foldl(multiplicar, Ns, 1, N)
        )
    ;   N = 0
    ).

%!  contar_hijo(+Problema, +Ancestros:list, +Hijo, -N:integer) is det.
%
%   N es la cantidad de árboles del hijo Hijo-C.
contar_hijo(Problema, Ancestros, Hijo-_, N) :-
    contar(Problema, Hijo, Ancestros, N).

%!  multiplicar(+X:integer, +P0:integer, -P:integer) is det.
%
%   P es P0 por X.
multiplicar(X, P0, P) :-
    P is P0 * X.

% --- Ejercicio 5: un peaje en la barca --------------------------------------

%!  primitivo(+Problema, +Nodo) is semidet.
%
%   peaje(E, Peaje) tiene los nodos primitivos del mapa.
primitivo(peaje(_, _), Nodo) :-
    primitivo(rio(cero), Nodo).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   Las expansiones del mapa, con Peaje sumado a los arcos de la barca.
expansion(peaje(E, Peaje), Nodo, Tipo, Hijos) :-
    expansion(rio(E), Nodo, Tipo, Hijos0),
    maplist(cobrar(Peaje), Hijos0, Hijos).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   La estimación E del mapa, que el peaje no hace exagerar.
estimacion(peaje(E, _), Nodo, H) :-
    estimacion(rio(E), Nodo, H).

%!  cobrar(+Peaje:number, +Hijo0, -Hijo) is det.
%
%   Hijo es Hijo0 con Peaje sumado al costo del arco si cruza en barca.
cobrar(Peaje, Hijo-C0, Hijo-C) :-
    (   Hijo = cruce(_, barca, _)
    ->  C is C0 + Peaje
    ;   C = C0
    ).

% --- Ejercicio 6: una estimación que exagera --------------------------------

%!  primitivo(+Problema, +Nodo) is semidet.
%
%   doble tiene los nodos primitivos del mapa.
primitivo(doble, Nodo) :-
    primitivo(rio(cero), Nodo).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   doble tiene las expansiones del mapa.
expansion(doble, Nodo, Tipo, Hijos) :-
    expansion(rio(cero), Nodo, Tipo, Hijos).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   H es el doble de la distancia en línea recta: puede exagerar.
estimacion(doble, Nodo, H) :-
    estimacion(rio(distancia), Nodo, H0),
    H is 2 * H0.

%!  comparar_doble(-Distintos:integer, -Exceso:integer, -K1:integer,
%!                 -K2:integer) is det.
%
%   Sobre los 169 pares de pueblos, Distintos es la cantidad en que la
%   estimación doble no da el costo mínimo, Exceso la suma de lo que se
%   pasa, y K1 y K2 las expansiones totales con la distancia y con el
%   doble.
comparar_doble(Distintos, Exceso, K1, K2) :-
    findall(C1-C2-E1-E2,
            ( pueblo(X, _, _, _),
              pueblo(Y, _, _, _),
              mejor(rio(distancia), ruta(X, Y), _, C1, E1),
              mejor(doble, ruta(X, Y), _, C2, E2) ),
            Rs),
    aggregate_all(count, ( member(C1-C2-_-_, Rs), C1 =\= C2 ), Distintos),
    aggregate_all(sum(C2 - C1), member(C1-C2-_-_, Rs), Exceso),
    aggregate_all(sum(E1), member(_-_-E1-_, Rs), K1),
    aggregate_all(sum(E2), member(_-_-_-E2, Rs), K2).

% --- Ejercicio 7: el costo de un árbol compartido --------------------------

%!  costo_compartido(+Arbol, -Costo:number) is det.
%
%   Costo es el costo de Arbol, calculado una sola vez por nodo: sirve para
%   los árboles de compartido/4, en los que un mismo nodo tiene siempre el
%   mismo subárbol.
costo_compartido(Arbol, Costo) :-
    empty_assoc(M0),
    costo_m(Arbol, Costo, M0, _).

%!  costo_m(+Arbol, -Costo:number, +M0, -M) is det.
%
%   Costo es el costo de Arbol; M0 y M asocian cada nodo ya calculado con
%   su costo.
costo_m(Arbol, Costo, M0, M) :-
    raiz(Arbol, Nodo),
    (   get_assoc(Nodo, M0, Costo)
    ->  M = M0
    ;   costo_nodo(Arbol, Costo, M0, M1),
        put_assoc(Nodo, M1, Costo, M)
    ).

%!  costo_nodo(+Arbol, -Costo:number, +M0, -M) is det.
%
%   Costo es el costo de Arbol, con sus hijos calculados por costo_m/4.
costo_nodo(meta(_), 0, M, M).
costo_nodo(o(_, A-C), Costo, M0, M) :-
    costo_m(A, CA, M0, M),
    Costo is C + CA.
costo_nodo(y(_, Arcos), Costo, M0, M) :-
    foldl(costo_arco, Arcos, 0-M0, Costo-M).

%!  costo_arco(+Arco, +S0, -S) is det.
%
%   S0 y S son Suma-Memoria; S suma el costo del arco A-C y el de A.
costo_arco(A-C, S0-M0, S-M) :-
    costo_m(A, CA, M0, M),
    S is S0 + C + CA.

%!  comparar_costos(+N:integer, -I1:integer, -I2:integer) is det.
%
%   I1 e I2 son las inferencias de costo/2 y de costo_compartido/2 sobre el
%   árbol compartido de la torre de N discos.
comparar_costos(N, I1, I2) :-
    compartido(hanoi, torre(N, a, c), Arbol, _),
    call_time(costo(Arbol, C), T1),
    call_time(costo_compartido(Arbol, C), T2),
    get_dict(inferences, T1, I1),
    get_dict(inferences, T2, I2).

% --- Ejercicio 8: la estrategia como árbol ---------------------------------

%!  mostrar_estrategia(+Busqueda, +Tablero:list) is semidet.
%
%   Escribe con mostrar/1 el árbol de la estrategia ganadora de x que halla
%   Busqueda en la posición de Tablero. Falla si no hay estrategia.
mostrar_estrategia(Busqueda, Tablero) :-
    buscar_estrategia(Busqueda, gana(tateti(3), x), mueve(pos(Tablero, x)),
                      si(Arbol), _),
    mostrar(Arbol).

% --- Ejercicio 9: las respuestas a la esquina -------------------------------

%!  respuestas_a_la_esquina(-Rs:list) is det.
%
%   Rs tiene un R-Resultado por cada respuesta R de o a x en la casilla 1:
%   Resultado es el tamaño de la menor estrategia ganadora de x, o
%   ninguna.
respuestas_a_la_esquina(Rs) :-
    findall(R-Resultado,
            ( between(2, 9, R),
              posicion_esquina(R, P),
              (   mejor(gana(tateti(3), x), mueve(P), _, C, _)
              ->  Resultado = C
              ;   Resultado = ninguna
              ) ),
            Rs).

%!  posicion_esquina(+R:integer, -P) is det.
%
%   P es la posición con x en 1 y o en R, en la que mueve x.
posicion_esquina(R, pos(T, x)) :-
    length(T, 9),
    foldl(casilla_esquina(R), T, 1, _).

%!  casilla_esquina(+R:integer, -M, +I0:integer, -I:integer) is det.
%
%   M es la marca de la casilla I0: x en 1, o en R y v en las demás.
casilla_esquina(R, M, I0, I) :-
    (   I0 =:= 1
    ->  M = x
    ;   I0 =:= R
    ->  M = o
    ;   M = v
    ),
    I is I0 + 1.

% --- Ejercicio 11: tres búsquedas en las mismas posiciones -----------------

%!  medir_esquina(-Rs:list) is det.
%
%   Rs tiene un R-[K1, K2, K3] por cada respuesta R de o a x en la casilla
%   1: los nodos que expanden la búsqueda en profundidad, la de
%   subproblemas compartidos y la de mejor primero.
medir_esquina(Rs) :-
    findall(R-Ks,
            ( between(2, 9, R),
              posicion_esquina(R, pos(T, x)),
              findall(K,
                      ( member(B, [profundidad, compartido, mejor]),
                        estrategia(B, T, _, K) ),
                      Ks) ),
            Rs).

% --- Ejercicio 12: integración simbólica ------------------------------------

% Los nodos son int(E), «hallar una primitiva de E», y las transformaciones
% que se le aplican; cada transformación cuesta 1.

%!  primitivo(+Problema, +Nodo) is semidet.
%
%   int(E) es primitivo si E tiene una primitiva inmediata.
primitivo(integral, int(E)) :-
    inmediata(E, _).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   int(E) es un nodo O con una transformación por hijo; cada
%   transformación es un nodo Y con las integrales que deja.
expansion(integral, int(E), o, Hijos) :-
    \+ inmediata(E, _),
    findall(T-1, transformacion(E, T), Hijos).
expansion(integral, suma(A, B), y, [int(A)-0, int(B)-0]).
expansion(integral, factor(_, F), y, [int(F)-0]).
expansion(integral, distribuir(E), y, [int(E)-0]).

% estimacion(P, N, H): sin información, la estimación es cero.
estimacion(integral, _, 0).

%!  inmediata(+E, -F) is semidet.
%
%   F es una primitiva de E que se escribe sin transformar E.
inmediata(K, K*x) :-
    number(K).
inmediata(x, x^2/2).
inmediata(x^N, x^N1/N1) :-
    number(N),
    N =\= -1,
    N1 is N + 1.
inmediata(sin(x), -cos(x)).
inmediata(cos(x), sin(x)).
inmediata(exp(x), exp(x)).

%!  transformacion(+E, -T) is nondet.
%
%   T es una transformación aplicable a E: separar una suma, sacar un
%   factor constante o distribuir un producto sobre una suma.
transformacion(A+B, suma(A, B)).
transformacion(K*F, factor(K, F)) :-
    number(K).
transformacion(A*(B+C), distribuir(A*B+A*C)).
transformacion((A+B)*C, distribuir(A*C+B*C)).

%!  primitiva(+Arbol, -F) is det.
%
%   F es la primitiva que describe Arbol, un árbol solución de int(E).
primitiva(meta(int(E)), F) :-
    inmediata(E, F).
primitiva(o(int(_), A-_), F) :-
    primitiva(A, F).
primitiva(y(suma(_, _), [A-_, B-_]), FA + FB) :-
    primitiva(A, FA),
    primitiva(B, FB).
primitiva(y(factor(K, _), [A-_]), K * F) :-
    primitiva(A, F).
primitiva(y(distribuir(_), [A-_]), F) :-
    primitiva(A, F).

%!  integrar(+E, -F, -Costo:integer) is semidet.
%
%   F es una primitiva de E, hallada con la búsqueda mejor primero con
%   Costo transformaciones. Falla si las reglas no alcanzan.
integrar(E, F, Costo) :-
    mejor(integral, int(E), Arbol, Costo, _),
    primitiva(Arbol, F).
