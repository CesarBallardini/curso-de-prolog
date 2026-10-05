# El mejor horario

Esta página es la versión 5 del
[capítulo 73](index.md#737-version-5-el-mejor-horario): el costo de un
horario para los alumnos, el horario de costo mínimo, la garantía cuando la
búsqueda se corta y la carrera de estrategias de etiquetado. Todo está en
`optimo.pl`, que reexporta el modelo de restricciones de la versión 4.

## El costo

Para un alumno que sigue el plan, un horario es mejor si
tiene clase en pocos días y sin **huecos**, franjas libres entre dos
clases del mismo día. El costo suma, para cada año, los días con clase y
los huecos, y se expresa como una variable de clpfd sobre el modelo: una
variable 0/1 por año, día y franja dice si hay clase, y un hueco es una
franja sin clase con alguna clase antes y alguna después, una conjunción
reificada:

<!-- ejemplo: capitulo-73/optimo.pl predicado: costo/3 costo_del_dia/5 hueco/3 alguna/2 -->
```prolog
%!  costo(+Oferta, +Horario:list, -Costo) is det.
%
%   Costo es una variable de clpfd igual a la cantidad de días con clase
%   más la cantidad de huecos, sumadas sobre todos los años, de Horario,
%   cuyos momentos pueden estar todavía libres.
costo(Oferta, Horario, Costo) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    findall(A, grupo(Oferta, anio(A)), Anios),
    numlist(1, Dias, Ds),
    findall(Anio-Dia, ( member(Anio, Anios), member(Dia, Ds) ), Claves),
    maplist(costo_del_dia(Oferta, Horario, Franjas), Claves, Costos),
    sum(Costos, #=, Costo).

%!  costo_del_dia(+Oferta, +Horario:list, +Franjas:integer, +Clave,
%!                -C) is det.
%
%   C es la variable del costo del año y el día de Clave, un par
%   Anio-Dia: 1 si el año tiene alguna clase ese día, más la cantidad de
%   huecos de ese día.
costo_del_dia(Oferta, Horario, Franjas, Anio-Dia, C) :-
    include(en_grupo(Oferta, anio(Anio)), Horario, DelAnio),
    maplist(momento_de, DelAnio, Ss),
    numlist(1, Franjas, Fs),
    maplist(ocupada(Oferta, Ss, Dia), Fs, Ocupadas),
    alguna(Ocupadas, Viene),
    huecos_de(Ocupadas, H),
    C #= Viene + H.

%!  hueco(+Ocupadas:list, +I:integer, -B) is det.
%
%   B es 1 si la franja I de Ocupadas está libre y hay clase antes y
%   después de ella, y 0 si no.
hueco(Ocupadas, I, B) :-
    I0 is I - 1,
    length(Previas, I0),
    append(Previas, [Esta|Despues], Ocupadas),
    alguna(Previas, HayAntes),
    alguna(Despues, HayDespues),
    B #<==> (Esta #= 0 #/\ HayAntes #/\ HayDespues).

%!  alguna(+Bs:list, -B) is det.
%
%   B es 1 si alguna de las variables 0/1 de Bs vale 1, y 0 si no; con la
%   lista vacía, 0.
alguna([], 0).
alguna([X|Xs], B) :-
    sum([X|Xs], #=, Suma),
    B #<==> (Suma #>= 1).
```

## La cota inferior

La opción `min(Costo)` de `labeling/2` busca el
horario de menor costo, pero para devolverlo tiene que probar que ninguno
cuesta menos, y en la oferta `cuatrimestre` no termina en dos minutos.
Una cota inferior barata acorta esa prueba: cada año tiene clase al menos
tantos días como clases tiene su materia de más clases, porque van en
días distintos, y al menos como sus clases divididas por las franjas de
un día. `optimo/4` acota el costo primero por esa cota, y después por
cada número siguiente; el primer horario que aparece es óptimo, porque
cada cota anterior falló:

<!-- ejemplo: capitulo-73/optimo.pl predicado: cota_inferior/2 dias_minimos/4 optimo/4 -->
```prolog
%!  cota_inferior(+Oferta, -Cota:integer) is det.
%
%   Ningún horario de Oferta cuesta menos que Cota: cada año viene al
%   menos tantos días como clases tiene su materia de más clases, porque
%   van en días distintos, y como sus clases divididas por las franjas
%   de un día, redondeado hacia arriba.
cota_inferior(Oferta, Cota) :-
    Oferta = oferta(semana(_, Franjas), _, _, _),
    findall(A, grupo(Oferta, anio(A)), Anios),
    maplist(dias_minimos(Oferta, Franjas), Anios, Minimos),
    sum_list(Minimos, Cota).

%!  dias_minimos(+Oferta, +Franjas:integer, +Anio, -Dias:integer) is det.
%
%   El año Anio de Oferta tiene clase al menos Dias días.
dias_minimos(Oferta, Franjas, Anio, Dias) :-
    aggregate_all(count, clase(Oferta, _, _, Anio, _, _), N),
    aggregate_all(max(K),
                  ( clase(Oferta, M-K, M, Anio, _, _) ),
                  Mayor),
    Dias is max(Mayor, (N + Franjas - 1) // Franjas).

%!  optimo(+Oferta, +Metodo, -Horario:list, -Costo:integer) is semidet.
%
%   Horario es un horario válido de Oferta de costo mínimo, Costo. Metodo
%   es min, que usa la opción min(Costo) de labeling/2, o cotas, que
%   prueba con el costo acotado por la cota de cota_inferior/2 y después
%   por cada número siguiente. Falla si Oferta no tiene ningún horario.
optimo(Oferta, Metodo, Horario, Costo) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Pares)),
    costo(Oferta, Horario, Costo),
    (   Metodo == min
    ->  once(labeling([ff, min(Costo)], Pares))
    ;   must_be(oneof([cotas]), Metodo),
        cota_inferior(Oferta, Minimo),
        fd_sup(Costo, Maximo),
        between(Minimo, Maximo, Cota),
        Costo #=< Cota,
        once(labeling([ff], Pares))
    ->  true
    ).
```

En la oferta `cuatrimestre` la cota es 3 + 3 + 2 = 8, y un horario de
costo 8 aparece con 2,9 millones de inferencias: es la grilla del
comienzo del [capítulo 73](index.md), y la del segundo año tiene la misma forma:

```prolog
?- ver_optimo(cuatrimestre, 2).
   lun       mar       mie       jue       vie
F1 ssl/a2    pp/a2     ssl/a2    -         -
F2 am2/a1    am2/a1    am2/a1    -         -
F3 -         -         pp/a2     -         -
F4 -         -         -         -         -
costo: 8
true.
```

## Con un límite, una garantía

En las ofertas `facultad(N)` la cota no
se alcanza, y probar que cada costo menor es imposible cuesta tanto como
en la versión 4 probar que no hay horario. `mejor_con_limite/4` aplica el
[Patrón 71](../patrones.md#71-resultado-con-garantia) del
[capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md#727-version-5-el-planificador):
empieza por un horario cualquiera y pide cada vez uno de costo menor, con
un límite de inferencias por búsqueda; si la cota se alcanza o una
búsqueda falla, el horario es óptimo, y si una búsqueda pasa del límite,
la respuesta dice entre qué valores está el óptimo:

<!-- ejemplo: capitulo-73/optimo.pl predicado: mejor_con_limite/4 mejorar/7 menor/3 -->
```prolog
%!  mejor_con_limite(+Oferta, +Limite:integer, -Horario:list, -Garantia)
%!      is semidet.
%
%   Horario es el mejor horario de Oferta que se encuentra mejorando de a
%   uno: el primero, y después cada vez uno de costo menor que el
%   anterior, cada búsqueda con a lo sumo Limite inferencias. Garantia es
%   optimo(C) si Horario cuesta C y está probado que no hay uno mejor
%   (porque C es la cota inferior o porque la búsqueda de uno mejor falló),
%   o entre(Cota, C) si una búsqueda pasó del límite: el óptimo está entre
%   la cota inferior y C. Falla si Oferta no tiene ningún horario.
mejor_con_limite(Oferta, Limite, Horario, Garantia) :-
    cota_inferior(Oferta, Cota),
    once(horario_clpfd(Oferta, [], Primero)),
    evaluar(Oferta, Primero, C0),
    mejorar(Oferta, Limite, Cota, Primero, C0, Horario, Garantia).

%!  mejorar(+Oferta, +Limite:integer, +Cota:integer, +Horario0:list,
%!          +C0:integer, -Horario:list, -Garantia) is det.
%
%   Horario es Horario0, de costo C0, o uno mejor que se encuentra
%   pidiendo cada vez un costo menor, con Garantia como en
%   mejor_con_limite/4.
mejorar(Oferta, Limite, Cota, Horario0, C0, Horario, Garantia) :-
    (   C0 =< Cota
    ->  Horario = Horario0,
        Garantia = optimo(C0)
    ;   call_with_inference_limit(menor(Oferta, C0, Horario1),
                                  Limite, Resultado)
    ->  (   Resultado == inference_limit_exceeded
        ->  Horario = Horario0,
            Garantia = entre(Cota, C0)
        ;   evaluar(Oferta, Horario1, C1),
            mejorar(Oferta, Limite, Cota, Horario1, C1, Horario, Garantia)
        )
    ;   Horario = Horario0,
        Garantia = optimo(C0)
    ).

%!  menor(+Oferta, +C0:integer, -Horario:list) is semidet.
%
%   Horario es un horario de Oferta que cuesta menos que C0.
menor(Oferta, C0, Horario) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Pares)),
    costo(Oferta, Horario, Costo),
    Costo #< C0,
    once(labeling([ff], Pares)).
```

```prolog
?- garantia(cuatrimestre, 5000000, G).
G = optimo(8).

?- garantia(facultad(6), 1000000, G).
G = entre(9, 11).

?- garantia(facultad(12), 5000000, G).
G = entre(12, 19).
```

En `facultad(6)`, con cincuenta millones de inferencias por búsqueda, la
garantía mejora a `entre(9, 10)` en diez segundos. El [ejercicio 8](index.md#ejercicios)
prueba si empezar por un primer horario más barato acerca la mejora al
óptimo.

## La carrera de estrategias

La [tabla de la versión 4](index.md#736-version-4-el-modelo-de-restricciones) muestra que una
estrategia de etiquetado puede no terminar en una oferta en la que otra
termina enseguida, y que no hay una que gane siempre. `carrera/3` corre
tres a la vez en hilos con `first_solution/3`
([capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md#374-paralelismo-de-datos))
y se queda con la primera que termina; las demás se cancelan. Cada hilo
arma su propio modelo, porque las restricciones son atributos de
variables que no se comparten entre hilos:

<!-- ejemplo: capitulo-73/optimo.pl predicado: carrera/3 una_estrategia/4 -->
```prolog
%!  carrera(+Oferta, -Estrategia, -Horario:list) is semidet.
%
%   Horario es el primer horario de Oferta que encuentra alguna de tres
%   estrategias corridas en hilos a la vez, y Estrategia es la que lo
%   encontró: momentos (los momentos y después las aulas), pares (el par
%   momento-aula) o simple (el par, sin las restricciones de conteo). Los
%   hilos que no terminaron se cancelan.
carrera(Oferta, Estrategia, Horario) :-
    first_solution(Estrategia-Horario,
                   [ una_estrategia(Oferta, momentos, Horario, Estrategia),
                     una_estrategia(Oferta, pares, Horario, Estrategia),
                     una_estrategia(Oferta, simple, Horario, Estrategia) ],
                   []).

%!  una_estrategia(+Oferta, +Nombre, -Horario:list, -Nombre) is semidet.
%
%   Horario es el primer horario de Oferta con la estrategia Nombre, que
%   se devuelve en el último argumento para saber cuál ganó.
una_estrategia(Oferta, momentos, Horario, momentos) :-
    once(horario_clpfd(Oferta, [etiquetar(momentos)], Horario)).
una_estrategia(Oferta, pares, Horario, pares) :-
    once(horario_clpfd(Oferta, [], Horario)).
una_estrategia(Oferta, simple, Horario, simple) :-
    once(horario_clpfd(Oferta, [modelo(simple)], Horario)).
```

```prolog
?- ganadora(facultad(14), E).
E = simple.
```

En `facultad(14)`, donde el etiquetado de los momentos no termina, la
carrera responde en medio segundo; en esta máquina ganó el modelo simple
con el etiquetado de pares, el que menos propaga. Cuál gana depende de la
máquina y de la carga, pero la respuesta llega tan pronto como termina la
mejor de las tres.
