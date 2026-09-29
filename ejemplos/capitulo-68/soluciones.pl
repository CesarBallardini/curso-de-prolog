:- encoding(utf8).

% Capítulo 68 - Soluciones de los ejercicios 2 a 8, 10 y 11.
%
% Carga las versiones 4 y 6 del capítulo, como proyecto.pl, y la versión
% 3 del capítulo 67 para comparar con la inducción. El ejercicio 9 está en
% soluciones_ebg.pl.
%
% solo-local: carga archivos de otros capítulos.
%
%?- todos_convergen.
%?- eliminar_con_descarte_de(3, EV, D).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(aggregate)).
:- use_module(preguntas).
:- use_module(ebg, except([inferencias/2])).
:- use_module('../capitulo-67/generalizar', [lgg_ingenua/3]).
:- use_module('../capitulo-67/subsuncion', [subsume/2]).
:- use_module('../capitulo-67/ascendente', [aprender_asc/3, evaluar/5]).
:- use_module('../capitulo-67/familia', [ejemplos/3]).

% Ejercicio 2

%!  ejemplos_de(+C, -Ejs:list) is det.
%
%   Ejs son las 36 instancias, en el orden de instancia/1, con la clase
%   que les da el concepto C.
ejemplos_de(C, Ejs) :-
    findall(Ej, ( instancia(I),
                  objetivo(C, I, Ej) ), Ejs).

%!  eliminar_todos(+C, -EV) is det.
%
%   EV es el espacio de versiones de las 36 instancias clasificadas por C.
eliminar_todos(C, EV) :-
    ejemplos_de(C, Ejs),
    eliminar(Ejs, EV).

%!  todos_convergen is semidet.
%
%   Para cada concepto C distinto de vacio, eliminar/2 converge a C con
%   los ejemplos de ejemplos_de/2.
todos_convergen :-
    forall(( concepto(C),
             C \== vacio ),
           ( eliminar_todos(C, EV),
             estado(EV, convergio(D)),
             D =@= C )).

% Ejercicio 3

%!  con_interior(:Meta) is semidet.
%
%   Prueba Meta con un quinto atributo, interior, cuyos valores rojo y
%   verde repiten valores de color.
con_interior(Meta) :-
    setup_call_cleanup(assertz(espacio:atributo(interior, [rojo, verde])),
                       once(Meta),
                       retract(espacio:atributo(interior, [rojo, verde]))).

%!  generalizacion_ingenua(+S, +I, -S1) is det.
%
%   Como generalizacion/3, con lgg_ingenua/3: cada diferencia recibe su
%   propia variable, y el resultado nunca exige que dos atributos
%   coincidan.
generalizacion_ingenua(S, I, S1) :-
    (   S == vacio
    ->  S1 = I
    ;   lgg_ingenua(S, I, S1)
    ).

% Ejercicio 4

%!  cuenta_clases(-Pos:integer, -Neg:integer, -Desc:integer) is det.
%
%   Cantidad de instancias positivas, negativas y desconocidas según el
%   espacio de los tres primeros ejemplos de esfera_roja.
cuenta_clases(Pos, Neg, Desc) :-
    eliminar_de(esfera_roja, 3, EV),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, positivo) ),
                  Pos),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, negativo) ),
                  Neg),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, desconocido) ),
                  Desc).

%!  desconocidas_esperadas is semidet.
%
%   Las instancias desconocidas son las que cubre pieza(esfera, _, _, _)
%   o pieza(_, rojo, _, _) y no pieza(esfera, rojo, _, _).
desconocidas_esperadas :-
    eliminar_de(esfera_roja, 3, EV),
    forall(instancia(I),
           (   clasificar(EV, I, desconocido)
           ->  ( cubre(pieza(esfera, _, _, _), I)
               ; cubre(pieza(_, rojo, _, _), I) ),
               \+ cubre(pieza(esfera, rojo, _, _), I)
           ;   true
           )).

% Ejercicio 5

%!  pasivo_inverso(+C, -N:integer, -E) is det.
%
%   Como pasivo/3, con las instancias en el orden inverso al de
%   instancia/1 después del primer positivo.
pasivo_inverso(C, N, E) :-
    primer_positivo(C, I),
    findall(Ej, ( instancia(J),
                  J \== I,
                  objetivo(C, J, Ej) ), Ejs0),
    reverse(Ejs0, Ejs),
    inicial(EV0),
    actualizar(pos(I), EV0, EV),
    recibir(Ejs, EV, 1, N, E).

%!  recibir(+Ejs:list, +EV, +N0:integer, -N:integer, -E) is det.
%
%   Actualiza EV con los ejemplos de Ejs hasta que converge o colapsa. N0
%   es la cantidad de ejemplos ya recibidos y N la final.
recibir(Ejs, EV, N0, N, E) :-
    estado(EV, E0),
    (   E0 == abierto,
        Ejs = [Ej|Resto]
    ->  actualizar(Ej, EV, EV1),
        N1 is N0 + 1,
        recibir(Resto, EV1, N1, N, E)
    ;   N = N0,
        E = E0
    ).

%!  promedio_inverso(-P:float) is det.
%
%   P es el promedio de ejemplos de pasivo_inverso/3 sobre los conceptos
%   distintos de vacio, redondeado a dos decimales.
promedio_inverso(P) :-
    aggregate_all(bag(N), ( concepto(C),
                            C \== vacio,
                            pasivo_inverso(C, N, _) ), Ns),
    sum_list(Ns, Suma),
    length(Ns, K),
    P is round(Suma / K * 100) / 100.0.

% Ejercicio 6

%!  eliminar_con_descarte(+Ejs:list, -EV, -Descartados:list) is det.
%
%   EV es el espacio de versiones de los ejemplos de Ejs, salvo los que lo
%   harían colapsar, que se ignoran y quedan en Descartados, en el orden
%   en que llegaron.
eliminar_con_descarte(Ejs, EV, Descartados) :-
    inicial(EV0),
    foldl(con_descarte, Ejs, EV0-[], EV-Inv),
    reverse(Inv, Descartados).

%!  con_descarte(+Ej, +Estado0, -Estado) is det.
%
%   Estado es EV-Ds después de Ej: si actualizar EV0 con Ej lo hace
%   colapsar, EV es EV0 y Ej se agrega a Ds.
con_descarte(Ej, EV0-Ds0, EV-Ds) :-
    actualizar(Ej, EV0, EV1),
    (   estado(EV1, colapso)
    ->  EV = EV0,
        Ds = [Ej|Ds0]
    ;   EV = EV1,
        Ds = Ds0
    ).

%!  eliminar_con_descarte_de(+K:integer, -EV, -Descartados:list) is det.
%
%   eliminar_con_descarte/3 sobre la secuencia esfera_roja con el negativo
%   mal clasificado insertado después de los K primeros ejemplos.
eliminar_con_descarte_de(K, EV, Descartados) :-
    secuencia(esfera_roja, Ejs0),
    length(Antes, K),
    append(Antes, Despues, Ejs0),
    append(Antes, [neg(pieza(esfera, rojo, grande, madera))|Despues], Ejs),
    eliminar_con_descarte(Ejs, EV, Descartados).

% Ejercicio 8

%!  reglas_abuelo(-Rs:list) is det.
%
%   Rs son las reglas de abuelo/2 aprendidas de cada positivo de
%   ejemplos/3, sin las que otra regla de la lista subsume.
reglas_abuelo(Rs) :-
    ejemplos(abuelo, Pos, _),
    findall(R, ( member(E, Pos),
                 aprender(familia, familia, E, R) ), Rs0),
    sin_subsumidas(Rs0, Rs).

%!  sin_subsumidas(+Rs0:list, -Rs:list) is det.
%
%   Rs son las reglas de Rs0, en su orden, salvo las que una regla
%   anterior de Rs subsume.
sin_subsumidas(Rs0, Rs) :-
    foldl(agregar_si_nueva, Rs0, [], Inv),
    reverse(Inv, Rs).

%!  agregar_si_nueva(+R, +Rs0:list, -Rs:list) is det.
%
%   Rs es Rs0 con R al frente, salvo que una regla de Rs0 subsuma a R.
agregar_si_nueva(R, Rs0, Rs) :-
    (   member(Q, Rs0),
        subsume(Q, R)
    ->  Rs = Rs0
    ;   Rs = [R|Rs0]
    ).

%!  cobertura_abuelo(-P:integer, -N:integer) is det.
%
%   P es la cantidad de positivos y N la de negativos de abuelo/2 que
%   cubre alguna regla de reglas_abuelo/1.
cobertura_abuelo(P, N) :-
    reglas_abuelo(Rs),
    ejemplos(abuelo, Pos, Negs),
    hechos(familia, Hs),
    aggregate_all(count, ( member(E, Pos), cubierto(Rs, Hs, E) ), P),
    aggregate_all(count, ( member(E, Negs), cubierto(Rs, Hs, E) ), N).

%!  cubierto(+Rs:list, +Hs:list, +E) is semidet.
%
%   Alguna regla de Rs prueba E con los hechos Hs.
cubierto(Rs, Hs, E) :-
    member(R, Rs),
    aplicar(familia, R, Hs, E),
    !.

% Ejercicio 10

%!  reglas_de_tazas(-Rs:list) is det.
%
%   Rs son las reglas aprendidas de cada taza de la población, sin las
%   que una regla anterior subsume.
reglas_de_tazas(Rs) :-
    poblacion(Os),
    clasificar_con_teoria(taza, Tazas),
    findall(R, ( member(O, Tazas),
                 memberchk(O-Hs, Os),
                 operacionales(taza, Ops),
                 once(ebg(taza, Ops, Hs, taza(O), R)) ), Rs0),
    sin_subsumidas(Rs0, Rs).

%!  costo_con(+K:integer, -N:integer) is det.
%
%   N son las inferencias de reconocidas/3 con K reglas: las de
%   reglas_de_tazas/1 repetidas en ciclo hasta completar K.
costo_con(K, N) :-
    reglas_de_tazas(Rs),
    length(Rs, L),
    findall(R, ( between(1, K, J),
                 I is (J - 1) mod L,
                 nth0(I, Rs, R) ), Reglas),
    ebg:inferencias(reconocidas(taza, Reglas, _), N).

% Ejercicio 11

%!  relevantes(+T, +E, +Meta, -Usados:list) is semidet.
%
%   Usados son los hechos de la descripción del ejemplo E que son hojas
%   de la primera explicación de Meta con la teoría T, en el orden de la
%   descripción. Falla si Meta no tiene explicación.
relevantes(T, E, Meta, Usados) :-
    hechos(E, Hs),
    once(explicar(T, Hs, Meta, Arbol)),
    findall(H, hoja(Arbol, H), Hojas),
    include(usado(Hojas), Hs, Usados).

%!  irrelevantes(+T, +E, +Meta, -Otros:list) is semidet.
%
%   Otros son los hechos de la descripción de E que la primera
%   explicación de Meta con la teoría T no usa.
irrelevantes(T, E, Meta, Otros) :-
    hechos(E, Hs),
    relevantes(T, E, Meta, Usados),
    exclude(usado(Usados), Hs, Otros).

%!  hoja(+Arbol, -H) is nondet.
%
%   H es un hecho que aparece como hoja prueba(H, []) del árbol Arbol.
hoja(prueba(H, []), H).
hoja(prueba(_, [A|As]), H) :-
    member(B, [A|As]),
    hoja(B, H).

%!  usado(+Hs:list, @H) is semidet.
%
%   H es uno de los términos de Hs.
usado(Hs, H) :-
    memberchk(H, Hs).
