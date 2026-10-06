:- encoding(utf8).

% Capítulo 73 - Versión 5: el mejor horario y la carrera de estrategias.
%
% Entre los horarios válidos, unos son mejores que otros para los alumnos:
% conviene que cada año tenga clase en pocos días y sin huecos. Un hueco
% es una franja libre de un año entre dos clases del mismo año en el mismo
% día: el alumno que sigue el plan espera sin clase. El costo de un
% horario suma, para cada año, los días con clase y los huecos, y se
% expresa como una variable de clpfd sobre el modelo de la versión 4: una
% variable 0/1 por año, día y franja dice si hay clase, y un hueco es una
% franja sin clase con alguna clase antes y alguna después.
%
% optimo/4 busca el horario de menor costo de dos maneras: con la opción
% min(Costo) de labeling/2, o acotando el costo por una cota inferior y
% después por cada número siguiente hasta que aparece un horario; como
% cada cota anterior falló, el primero que aparece es óptimo.
% mejor_con_limite/4 mejora de a uno con un límite de inferencias y
% responde con una garantía (Patrón 71).
%
% carrera/3 corre varias estrategias de etiquetado en hilos, con
% first_solution/3 del capítulo 37, y se queda con la primera que
% termina: una estrategia mala para una oferta no demora la respuesta si
% otra es buena.
%
% solo-local: carga otros archivos y usa hilos.
%
%?- oferta(cuatrimestre, O), optimo(O, cotas, H, C), mostrar_anio(O, H, 2).
%?- oferta(facultad(14), O), carrera(O, E, H).

:- module(optimo,
          [ optimo/4,
            costo/3,
            evaluar/3,
            cota_inferior/2,
            mejor_con_limite/4,
            mejorar/7,
            carrera/3,
            ver_optimo/2,
            garantia/3,
            ganadora/2
          ]).

:- use_module(library(clpfd)).
:- use_module(library(thread)).
:- reexport(restricciones).

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

%!  ocupada(+Oferta, +Ss:list, +Dia:integer, +Franja:integer, -B) is det.
%
%   B es 1 si alguno de los momentos Ss es la franja Franja del día Dia,
%   y 0 si no. Como los momentos de un año son distintos, la suma de las
%   comparaciones reificadas es 0 o 1.
ocupada(Oferta, Ss, Dia, Franja, B) :-
    momento(Oferta, S, Dia, Franja),
    maplist(es_momento(S), Ss, Bs),
    sum(Bs, #=, B).

%!  es_momento(+S:integer, +X, -B) is det.
%
%   B es 1 si la variable X toma el valor S, y 0 si no.
es_momento(S, X, B) :-
    B #<==> (X #= S).

%!  huecos_de(+Ocupadas:list, -H) is det.
%
%   H es la cantidad de franjas sin clase de Ocupadas, una lista de
%   variables 0/1 en el orden del día, que tienen alguna franja con clase
%   antes y alguna después.
huecos_de(Ocupadas, H) :-
    length(Ocupadas, N),
    numlist(1, N, Is),
    maplist(hueco(Ocupadas), Is, Hs),
    sum(Hs, #=, H).

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

%!  evaluar(+Oferta, +Horario:list, -N:integer) is det.
%
%   N es el costo de Horario, un horario ya resuelto: los días con clase
%   más los huecos de cada año. Cuenta sin restricciones, para verificar
%   el costo que calcula costo/3.
evaluar(Oferta, Horario, N) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    aggregate_all(count,
                  ( grupo(Oferta, anio(Anio)),
                    between(1, Dias, Dia),
                    once(con_clase(Oferta, Horario, Anio, Dia, _)) ),
                  Viene),
    aggregate_all(count,
                  ( grupo(Oferta, anio(Anio)),
                    between(1, Dias, Dia),
                    between(1, Franjas, F),
                    \+ con_clase(Oferta, Horario, Anio, Dia, F),
                    once(( con_clase(Oferta, Horario, Anio, Dia, Antes),
                           Antes < F )),
                    once(( con_clase(Oferta, Horario, Anio, Dia, Despues),
                           Despues > F )) ),
                  Huecos),
    N is Viene + Huecos.

%!  con_clase(+Oferta, +Horario:list, ?Anio, ?Dia, ?Franja) is nondet.
%
%   El año Anio tiene una clase de Horario en la franja Franja del día
%   Dia.
con_clase(Oferta, Horario, Anio, Dia, Franja) :-
    member(asignada(C, _, S, _), Horario),
    clase(Oferta, C, _, Anio, _, _),
    momento(Oferta, S, Dia, Franja).

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

%!  ver_optimo(+Nombre, +Anio:integer) is semidet.
%
%   Escribe la grilla del año Anio en el horario de costo mínimo de la
%   oferta de ejemplo Nombre, y su costo.
ver_optimo(Nombre, Anio) :-
    oferta(Nombre, Oferta),
    optimo(Oferta, cotas, Horario, Costo),
    mostrar_anio(Oferta, Horario, Anio),
    format("costo: ~w~n", [Costo]).

%!  garantia(+Nombre, +Limite:integer, -Garantia) is semidet.
%
%   Garantia es la que da mejor_con_limite/4 para la oferta de ejemplo
%   Nombre con Limite inferencias por búsqueda.
garantia(Nombre, Limite, Garantia) :-
    oferta(Nombre, Oferta),
    mejor_con_limite(Oferta, Limite, _, Garantia).

%!  ganadora(+Nombre, -Estrategia) is semidet.
%
%   Estrategia es la que gana la carrera de carrera/3 para la oferta de
%   ejemplo Nombre.
ganadora(Nombre, Estrategia) :-
    oferta(Nombre, Oferta),
    carrera(Oferta, Estrategia, _).
