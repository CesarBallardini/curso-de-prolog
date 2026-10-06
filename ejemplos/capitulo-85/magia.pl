:- encoding(utf8).

% Capítulo 85 - Versión 4: las consultas y la transformación mágica.
%
% respuestas/4 calcula el modelo entero y se queda con los átomos que
% unifican con la consulta. magico/3 reescribe el programa para una
% consulta, de modo que la evaluación de abajo hacia arriba derive solo lo
% que la consulta necesita. Cada predicado definido por reglas se
% «adorna» con los argumentos que llegan ligados (b) o libres (f), y su
% predicado mágico m_P_Adorno guarda los valores ligados con que se lo
% llamaría: camino(0, Y) es la consulta camino_bf, y su semilla, el hecho
% m_camino_bf(0). Cada regla adornada exige su hecho mágico, y cada
% literal de un predicado con reglas produce una regla mágica, que lo
% llama con lo que ligan la cabeza y los literales anteriores, de
% izquierda a derecha, como Prolog. Un predicado usado en un literal
% negado se evalúa completo, con sus reglas originales, para que la
% negación siga viendo su extensión entera. respuestas_magicas/4 evalúa el
% programa transformado y traduce las respuestas.
%
% solo-local: es un módulo que carga otros.
%
%?- magico([(arco(a, b) :- true), (camino(X, Y) :- arco(X, Y)), (camino(X, Y) :- camino(X, Z), arco(Z, Y))], camino(a, W), P).

:- module(magia,
          [ adorno/3,
            magico/3,
            respuestas/4,
            respuestas_magicas/4
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(library(ugraphs)).
:- use_module(seguro).
:- use_module(estratos).

%!  respuestas(+Clausulas:list, +Meta, -Respuestas:list, -Costo) is det.
%
%   Respuestas son, ordenadas, las instancias de Meta que están en el
%   modelo estándar de Clausulas, calculado entero con evaluar/3. Costo,
%   el de evaluar/3.
respuestas(Clausulas, Meta, Respuestas, Costo) :-
    evaluar(Clausulas, Modelo, Costo),
    findall(Meta, member(Meta, Modelo), Rs),
    sort(Rs, Respuestas).

%!  respuestas_magicas(+Clausulas:list, +Meta, -Respuestas:list, -Costo)
%!      is det.
%
%   Las mismas Respuestas que respuestas/4, con la evaluación del programa
%   que magico/3 transforma para Meta. Costo, el de esa evaluación.
respuestas_magicas(Clausulas, Meta, Respuestas, Costo) :-
    magico(Clausulas, Meta, Programa),
    evaluar(Programa, Modelo, Costo),
    adorno(Meta, [], Adorno),
    adornado(Meta, Adorno, MetaAdornada),
    findall(Meta, member(MetaAdornada, Modelo), Rs),
    sort(Rs, Respuestas).

%!  adorno(+Atomo, +Ligadas:list, -Adorno:atom) is det.
%
%   Adorno tiene una letra por argumento de Atomo: b si el argumento está
%   ligado, porque es una constante o una variable de Ligadas, un conjunto
%   ordenado de variables, y f si está libre.
adorno(Atomo, Ligadas, Adorno) :-
    Atomo =.. [_|Args],
    maplist(letra(Ligadas), Args, Letras),
    atomic_list_concat(Letras, Adorno).

%!  letra(+Ligadas:list, +Arg, -Letra) is det.
%
%   Letra es b si Arg está ligado y f si no.
letra(Ligadas, Arg, Letra) :-
    (   var(Arg),
        \+ ord_memberchk(Arg, Ligadas)
    ->  Letra = f
    ;   Letra = b
    ).

%!  adornado(+Atomo, +Adorno, -Adornado) is det.
%
%   Adornado es Atomo con el predicado Nombre_Adorno y los mismos
%   argumentos.
adornado(Atomo, Adorno, Adornado) :-
    Atomo =.. [Nombre|Args],
    atomic_list_concat([Nombre, Adorno], '_', Nombre1),
    Adornado =.. [Nombre1|Args].

%!  magico_de(+Atomo, +Adorno, -Magico) is det.
%
%   Magico es el átomo m_Nombre_Adorno con los argumentos de Atomo que el
%   Adorno marca con b.
magico_de(Atomo, Adorno, Magico) :-
    Atomo =.. [Nombre|Args],
    atom_chars(Adorno, Letras),
    foldl(ligado, Letras, Args, Ligados, []),
    atomic_list_concat([m, Nombre, Adorno], '_', Nombre1),
    Magico =.. [Nombre1|Ligados].

%!  ligado(+Letra, +Arg, -Ligados:list, ?Resto) is det.
%
%   Ligados es [Arg|Resto] si Letra es b, y Resto si es f.
ligado(b, Arg, [Arg|Resto], Resto).
ligado(f, _, Resto, Resto).

%!  magico(+Clausulas:list, +Meta, -Programa:list) is det.
%
%   Programa es la transformación mágica de Clausulas para la consulta
%   Meta, un átomo de un predicado definido por reglas: los hechos de los
%   predicados sin reglas, la semilla de Meta, las reglas adornadas y las
%   mágicas de cada predicado y adorno que la consulta alcanza, y las
%   cláusulas originales de los predicados que se usan negados y de los
%   que estos dependen. Error de dominio si Meta no tiene reglas.
magico(Clausulas, Meta, Programa) :-
    con_reglas(Clausulas, Idb),
    predicado(Meta, PM),
    (   ord_memberchk(PM, Idb)
    ->  true
    ;   domain_error(predicado_con_reglas, PM)
    ),
    adorno(Meta, [], Adorno),
    magico_de(Meta, Adorno, Semilla),
    transformar([PM-Adorno], [], Clausulas, Idb, Reglas, [], Negados),
    completos(Clausulas, Idb, Negados, Completos),
    include(original(Idb, Completos), Clausulas, Originales),
    append([Originales, [(Semilla :- true)], Reglas], Programa).

%!  original(+Idb:list, +Completos:list, +Clausula) is semidet.
%
%   Clausula pasa sin cambios al programa transformado: es un hecho de un
%   predicado sin reglas o una cláusula de un predicado de Completos.
original(Idb, Completos, H :- _) :-
    predicado(H, P),
    (   \+ ord_memberchk(P, Idb)
    ->  true
    ;   ord_memberchk(P, Completos)
    ).

%!  con_reglas(+Clausulas:list, -Idb:list) is det.
%
%   Idb son, ordenados, los predicados que tienen alguna cláusula cuyo
%   cuerpo no es true.
con_reglas(Clausulas, Idb) :-
    findall(P,
            ( member(H :- B, Clausulas),
              B \== true,
              predicado(H, P) ),
            Ps),
    sort(Ps, Idb).

%!  predicado(+Atomo, -Indicador) is det.
%
%   Indicador es Nombre/Aridad, el predicado de Atomo.
predicado(A, Nombre/Aridad) :-
    functor(A, Nombre, Aridad).

%!  transformar(+Pendientes:list, +Hechos:list, +Clausulas:list,
%!              +Idb:list, -Reglas:list, +Negados0:list, -Negados:list)
%!      is det.
%
%   Reglas son las reglas adornadas y mágicas de los pares
%   Predicado-Adorno de Pendientes y de los que estos llaman, sin repetir
%   los Hechos. Negados agrega a Negados0 los predicados con reglas que
%   aparecen en un literal negado.
transformar([], _, _, _, [], Negados, Negados).
transformar([PA|Pendientes], Hechos, Clausulas, Idb, Reglas,
            Negados0, Negados) :-
    (   memberchk(PA, Hechos)
    ->  transformar(Pendientes, Hechos, Clausulas, Idb, Reglas,
                    Negados0, Negados)
    ;   PA = P-Adorno,
        findall(Rs-Ns-Ls,
                ( member(C, Clausulas),
                  C = (H :- _),
                  predicado(H, P),
                  copy_term(C, Copia),
                  transformar_clausula(Copia, Adorno, Idb, Rs, Ns, Ls) ),
                Partes),
        findall(R, ( member(Rs-_-_, Partes), member(R, Rs) ), Reglas1),
        findall(N, ( member(_-Ns-_, Partes), member(N, Ns) ), Nuevos),
        findall(N, ( member(_-_-Ls, Partes), member(N, Ls) ), Negados1),
        append(Pendientes, Nuevos, Pendientes1),
        ord_union(Negados0, Negados1, Negados2),
        transformar(Pendientes1, [PA|Hechos], Clausulas, Idb, Reglas2,
                    Negados2, Negados),
        append(Reglas1, Reglas2, Reglas)
    ).

%!  transformar_clausula(+Clausula, +Adorno, +Idb:list, -Reglas:list,
%!                       -Llamados:list, -Negados:list) is det.
%
%   Reglas son la regla adornada de Clausula, con el hecho mágico de su
%   cabeza delante del cuerpo, y una regla mágica por cada literal de un
%   predicado de Idb. Llamados son los pares Predicado-Adorno de esos
%   literales, y Negados, ordenados, los predicados de Idb usados negados.
transformar_clausula(H :- B, Adorno, Idb, [Adornada|Magicas], Llamados,
                     Negados) :-
    literales(B, Ls),
    H =.. [_|Args],
    atom_chars(Adorno, Letras),
    foldl(ligado, Letras, Args, ArgsLigados, []),
    term_variables(ArgsLigados, Vs0),
    sort(Vs0, Ligadas),
    magico_de(H, Adorno, MH),
    cuerpo(Ls, Ligadas, MH, [], Idb, Cuerpo, Magicas, Llamados, Ns),
    sort(Ns, Negados),
    adornado(H, Adorno, HA),
    lista_conjuncion([MH|Cuerpo], C),
    Adornada = (HA :- C).

%!  cuerpo(+Literales:list, +Ligadas:list, +MH, +Antes:list, +Idb:list,
%!         -Cuerpo:list, -Magicas:list, -Llamados:list, -Negados:list)
%!      is det.
%
%   Cuerpo son los Literales con los de Idb adornados según las variables
%   Ligadas en cada punto, de izquierda a derecha. Antes son, en orden
%   inverso, los literales ya transformados; la regla mágica de un literal
%   de Idb tiene el cuerpo MH, el hecho mágico de la cabeza, seguido de
%   ellos.
cuerpo([], _, _, _, _, [], [], [], []).
cuerpo([L|Ls], Ligadas0, MH, Antes, Idb, [L1|Cuerpo], Magicas, Llamados,
       Negados) :-
    (   L = (\+ A)
    ->  L1 = L,
        Ligadas = Ligadas0,
        Magicas = Magicas1,
        Llamados = Llamados1,
        predicado(A, P),
        (   ord_memberchk(P, Idb)
        ->  Negados = [P|Negados1]
        ;   Negados = Negados1
        )
    ;   ( L = (_ is _) ; comparacion(L) )
    ->  L1 = L,
        term_variables(L, Vs0),
        sort(Vs0, Vs),
        ord_union(Ligadas0, Vs, Ligadas),
        Magicas = Magicas1,
        Llamados = Llamados1,
        Negados = Negados1
    ;   predicado(L, P),
        ord_memberchk(P, Idb)
    ->  adorno(L, Ligadas0, Adorno),
        adornado(L, Adorno, L1),
        magico_de(L, Adorno, ML),
        reverse(Antes, Previos),
        lista_conjuncion([MH|Previos], C),
        Magicas = [(ML :- C)|Magicas1],
        Llamados = [P-Adorno|Llamados1],
        Negados = Negados1,
        ligar(L, Ligadas0, Ligadas)
    ;   L1 = L,
        Magicas = Magicas1,
        Llamados = Llamados1,
        Negados = Negados1,
        ligar(L, Ligadas0, Ligadas)
    ),
    cuerpo(Ls, Ligadas, MH, [L1|Antes], Idb, Cuerpo, Magicas1, Llamados1,
           Negados1).

%!  ligar(+T, +Ligadas0:list, -Ligadas:list) is det.
%
%   Ligadas agrega a Ligadas0 las variables de T.
ligar(T, Ligadas0, Ligadas) :-
    term_variables(T, Vs0),
    sort(Vs0, Vs),
    ord_union(Ligadas0, Vs, Ligadas).

%!  lista_conjuncion(+Literales:list, -Cuerpo) is det.
%
%   Cuerpo es la conjunción de los Literales, o true si no hay ninguno.
lista_conjuncion([], true).
lista_conjuncion([L|Ls], C) :-
    (   Ls == []
    ->  C = L
    ;   C = (L, C1),
        lista_conjuncion(Ls, C1)
    ).

%!  completos(+Clausulas:list, +Idb:list, +Negados:list, -Completos:list)
%!      is det.
%
%   Completos son, ordenados, los predicados de Negados y los de Idb de
%   los que estos dependen, directa o indirectamente: se evalúan enteros,
%   con sus reglas originales.
completos(Clausulas, Idb, Negados, Completos) :-
    dependencias(Clausulas, Aristas),
    findall(P-Q, member(P-Q-_, Aristas), Arcos),
    vertices_edges_to_ugraph(Idb, Arcos, Grafo),
    findall(Q,
            ( member(P, Negados),
              reachable(P, Grafo, Qs),
              member(Q, Qs) ),
            Todos),
    sort(Todos, Completos).
