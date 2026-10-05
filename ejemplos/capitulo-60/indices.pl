:- encoding(utf8).

% Capítulo 60 - Versión 6: una memoria con índice y fases con metarreglas.
%
% Las dos mejoras del emparejamiento que propone Bratko al cerrar su
% capítulo. La primera es indexar la memoria: los hechos se guardan en un
% library(assoc) por su nombre y su aridad, de modo que un patrón solo se
% compara con los hechos que pueden unificar con él. Cada hecho lleva una
% marca de tiempo, un entero que crece con cada hecho agregado, como las
% marcas de los sistemas OPS; la estrategia reciente compara marcas en
% lugar de posiciones en una lista.
%
% La segunda es partir los módulos en fases, y dejar activa una sola por
% vez. Una metarregla, una regla sobre las reglas, decide la transición:
% cuando ningún módulo de la fase activa se puede aplicar, se pasa a la
% fase siguiente, y el programa termina después de la última.
%
% solo-local: carga conflictos.pl con ensure_loaded/1.
%
%?- ejecutar_indexado(mcd, primera, [numero(25), numero(10)], M, R).
%?- ejecutar_fases_de(mcd_fases, especifica,
%   [numero(25), numero(10), numero(15)], M, R).

:- ensure_loaded(conflictos).

% La memoria indexada: m(Indice, Reloj). Indice asocia cada clave
% Nombre/Aridad con la lista de los hechos T-F de esa clave, del más
% reciente al más antiguo; Reloj es la marca del próximo hecho.

%!  indexar(+Hechos:list, -Memoria) is det.
%
%   Memoria es la memoria indexada de la lista Hechos, cuyo primer hecho es
%   el más reciente, como en las versiones 2 y 3.
indexar(Hechos, Memoria) :-
    empty_assoc(Vacio),
    reverse(Hechos, Antiguos),
    foldl(agregar_hecho, Antiguos, m(Vacio, 1), Memoria).

%!  hechos(+Memoria, -Hechos:list) is det.
%
%   Hechos es la lista de los hechos de Memoria, del más reciente al más
%   antiguo.
hechos(m(Indice, _), Hechos) :-
    assoc_to_values(Indice, Listas),
    append(Listas, Marcados),
    sort(1, @>=, Marcados, Ordenados),
    pairs_values(Ordenados, Hechos).

%!  clave(+F, -Clave) is det.
%
%   Clave es el nombre y la aridad del hecho o patrón F.
clave(F, Nombre/Aridad) :-
    functor(F, Nombre, Aridad).

%!  agregar_hecho(+F, +Memoria0, -Memoria) is det.
%
%   Memoria es Memoria0 con el hecho F agregado como el más reciente.
agregar_hecho(F, m(Indice0, T), m(Indice, T1)) :-
    clave(F, K),
    (   get_assoc(K, Indice0, Lista)
    ->  true
    ;   Lista = []
    ),
    put_assoc(K, Indice0, [T-F|Lista], Indice),
    T1 is T + 1.

%!  quitar_hecho(+F, +Memoria0, -Memoria) is semidet.
%
%   Memoria es Memoria0 sin el hecho más reciente que unifica con F. Falla
%   si no hay ninguno.
quitar_hecho(F, m(Indice0, T), m(Indice, T)) :-
    clave(F, K),
    get_assoc(K, Indice0, Lista0),
    selectchk(_-F, Lista0, Lista),
    put_assoc(K, Indice0, Lista, Indice).

%!  hecho_en(?F, +Memoria, -T:integer) is nondet.
%
%   F unifica con un hecho de Memoria que tiene la marca T. Solo se recorren
%   los hechos de la clave de F, del más reciente al más antiguo.
hecho_en(F, m(Indice, _), T) :-
    clave(F, K),
    get_assoc(K, Indice, Lista),
    member(T-F, Lista).

%!  satisface_i(+Condiciones:list, +Memoria, -Marcas:list) is nondet.
%
%   Memoria cumple las Condiciones. Marcas son las marcas de los hechos que
%   cumplen los patrones, en el orden de las condiciones.
satisface_i([], _, []).
satisface_i([C|Cs], Memoria, Marcas) :-
    condicion_i(C, Memoria, Marcas, Resto),
    satisface_i(Cs, Memoria, Resto).

% condicion_i(C, Memoria, Marcas, Resto): Memoria cumple C; Marcas es Resto
% precedida por la marca del hecho que cumple un patrón.
condicion_i({Meta}, _, Resto, Resto) :-
    call(Meta).
condicion_i(no(F), Memoria, Resto, Resto) :-
    \+ hecho_en(F, Memoria, _).
condicion_i(F, Memoria, [T|Resto], Resto) :-
    patron(F),
    hecho_en(F, Memoria, T).

%!  acciones_i(+Acciones:list, +Memoria0, -Memoria, -Fin) is semidet.
%
%   Como acciones/4 de la versión 2, sobre la memoria indexada.
acciones_i([], Memoria, Memoria, seguir).
acciones_i([A|As], Memoria0, Memoria, Fin) :-
    (   A = parar(R)
    ->  Memoria = Memoria0,
        Fin = parar(R)
    ;   accion_i(A, Memoria0, Memoria1),
        acciones_i(As, Memoria1, Memoria, Fin)
    ).

% accion_i(A, Memoria0, Memoria): Memoria es Memoria0 después de la acción
% A, que no es parar/1.
accion_i({Meta}, Memoria, Memoria) :-
    once(Meta).
accion_i(agregar(F), Memoria0, Memoria) :-
    agregar_hecho(F, Memoria0, Memoria).
accion_i(quitar(F), Memoria0, Memoria) :-
    quitar_hecho(F, Memoria0, Memoria).
accion_i(reemplazar(F, G), Memoria0, Memoria) :-
    quitar_hecho(F, Memoria0, Memoria1),
    agregar_hecho(G, Memoria1, Memoria).

%!  conflicto_i(+Modulos:list, +Memoria, -Instancias:list) is det.
%
%   Como conflicto/3 de la versión 3, sobre la memoria indexada: las
%   instancias llevan las marcas de los hechos en lugar de sus posiciones.
conflicto_i(Modulos, Memoria, Instancias) :-
    findall(instancia(Nombre, N, Marcas, Acciones),
            ( member(Modulo, Modulos),
              copy_term(Modulo, Nombre :: Condiciones ---> Acciones),
              length(Condiciones, N),
              satisface_i(Condiciones, Memoria, Marcas)
            ),
            Instancias).

%!  elegir_i(+Estrategia, +Instancias:list, -Elegida) is det.
%
%   Como elegir/4 de la versión 3. Con reciente, la clave es la mayor marca
%   de la instancia, cambiada de signo, o 0 si no usa ningún hecho.
elegir_i(Estrategia, Instancias, Elegida) :-
    map_list_to_pairs(clave_i(Estrategia), Instancias, Pares),
    keysort(Pares, [_-Elegida|_]).

% clave_i(Estrategia, Instancia, Clave): la clave de orden de la Instancia.
clave_i(primera, _, 0).
clave_i(reciente, instancia(_, _, Marcas, _), Clave) :-
    max_list([0|Marcas], M),
    Clave is -M.
clave_i(especifica, instancia(_, N, _, _), Clave) :-
    Clave is -N.

%!  ciclo_i(+Modulos:list, +Estrategia, +N0:integer, -N:integer,
%!          +Memoria0, -Memoria, -Resultado) is semidet.
%
%   El ciclo de reconocimiento y acción de la versión 3 sobre la memoria
%   indexada. N es N0 más la cantidad de ciclos que aplican un módulo.
%   Falla si falla una acción de la instancia elegida.
ciclo_i(Modulos, Estrategia, N0, N, Memoria0, Memoria, Resultado) :-
    conflicto_i(Modulos, Memoria0, Instancias),
    (   Instancias == []
    ->  N = N0,
        Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   elegir_i(Estrategia, Instancias, instancia(_, _, _, Acciones)),
        N1 is N0 + 1,
        acciones_i(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  N = N1,
            Memoria = Memoria1,
            Resultado = R
        ;   ciclo_i(Modulos, Estrategia, N1, N, Memoria1, Memoria,
                    Resultado)
        )
    ).

%!  ejecutar_indexado(+Programa, +Estrategia, +Hechos0:list,
%!                    -Hechos:list, -Resultado) is semidet.
%
%   Como ejecutar/5 de la versión 3, con la memoria indexada. Hechos0 y
%   Hechos son listas, del hecho más reciente al más antiguo. Falla si
%   falla una acción de la instancia elegida.
ejecutar_indexado(Programa, Estrategia, Hechos0, Hechos, Resultado) :-
    programa(Programa, Modulos),
    indexar(Hechos0, Memoria0),
    ciclo_i(Modulos, Estrategia, 0, _, Memoria0, Memoria, Resultado),
    hechos(Memoria, Hechos).

% Fases y una metarregla.

% programa_fases(Nombre, Fases): un programa partido en fases, una lista
% de pares Fase-Modulos que se activan en ese orden. Es multifile,
% para que otros archivos agreguen programas.
:- multifile programa_fases/2.

programa_fases(mcd_fases,
    [ calcular - [ resta :: [numero(X), numero(Y), {X > Y}]
                        ---> [{Z is X - Y},
                              reemplazar(numero(X), numero(Z))] ],
      informar - [ resultado :: [numero(X)]
                        ---> [parar(X)] ]
    ]).

%!  ejecutar_fases(+Fases:list, +Estrategia, +Hechos0:list, -Hechos:list,
%!                 -Resultado) is semidet.
%
%   Ejecuta las Fases en orden sobre la memoria indexada de Hechos0. En
%   cada ciclo solo compiten los módulos de la fase activa; la metarregla
%   pasa a la fase siguiente cuando ninguno se aplica. Resultado es el de
%   parar/1, o nada_aplicable si la última fase termina sin parar. Falla
%   si falla una acción de la instancia elegida.
ejecutar_fases(Fases, Estrategia, Hechos0, Hechos, Resultado) :-
    indexar(Hechos0, Memoria0),
    fases(Fases, Estrategia, Memoria0, Memoria, Resultado),
    hechos(Memoria, Hechos).

%!  ejecutar_fases_de(+Nombre, +Estrategia, +Hechos0:list, -Hechos:list,
%!                    -Resultado) is semidet.
%
%   Como ejecutar_fases/5, con el programa por fases llamado Nombre, y
%   falla en los mismos casos.
ejecutar_fases_de(Nombre, Estrategia, Hechos0, Hechos, Resultado) :-
    programa_fases(Nombre, Fases),
    ejecutar_fases(Fases, Estrategia, Hechos0, Hechos, Resultado).

%!  fases(+Fases:list, +Estrategia, +Memoria0, -Memoria, -Resultado) is semidet.
%
%   Ejecuta cada fase de Fases hasta que ninguno de sus módulos se aplica,
%   y sigue con la siguiente: la metarregla de las transiciones. Falla si
%   falla una acción de la instancia elegida.
fases([], _, Memoria, Memoria, nada_aplicable).
fases([_-Modulos|Fases], Estrategia, Memoria0, Memoria, Resultado) :-
    ciclo_i(Modulos, Estrategia, 0, _, Memoria0, Memoria1, R),
    (   R == nada_aplicable
    ->  fases(Fases, Estrategia, Memoria1, Memoria, Resultado)
    ;   Memoria = Memoria1,
        Resultado = R
    ).
