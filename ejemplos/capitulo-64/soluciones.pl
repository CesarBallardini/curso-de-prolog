:- encoding(utf8).

% Capítulo 64 - Soluciones de los ejercicios.
%
% Carga pruebas.pl, que carga todas las versiones del capítulo, y agrega
% los programas y predicados de las soluciones sin modificar ningún
% archivo del capítulo.
%
% solo-local: carga pruebas.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- mostrar_programa(tienda).
%?- ciclos_para_ganar(800, C).

:- ensure_loaded(pruebas).

% Ejercicio 1. Tres reglas sobre productos y clientes.
programa(tienda,
    [ oferta :: [producto(P, C), {C > 100}, cliente(_, P)] ---> [],
      aviso :: [producto(_, C), {C > 100}] ---> [],
      venta :: [producto(Q, _), cliente(_, Q)] ---> []
    ]).

%!  mostrar_programa(+Programa) is det.
%
%   Escribe con mostrar/1 la red del Programa, compilada con pasos/2.
mostrar_programa(Programa) :-
    programa(Programa, Reglas),
    compilar_red(pasos, Reglas, Red),
    mostrar(Red).

% Ejercicio 2. hermanos con la prueba antes de tiempo y con las dos
% condiciones en el orden inverso, junto a antepasado_1.
programa(hermanos_variantes,
    [ antepasado_1 :: [progenitor(A, D)] ---> [agregar(antepasado(A, D))],
      temprana :: [progenitor(P, A), {A \== B}, progenitor(P, B)]
           ---> [agregar(hermanos(A, B))],
      invertida :: [progenitor(P, B), progenitor(P, A), {A \== B}]
           ---> [agregar(hermanos(A, B))],
      hermanos :: [progenitor(P, A), progenitor(P, B), {A \== B}]
           ---> [agregar(hermanos(A, B))]
    ]).

% Ejercicio 3.

%!  primera_ascendente(+Programa, +Hechos:list, -Elegida) is det.
%
%   Elegida es la instanciación que elige orden si el conjunto de conflicto
%   de la red, con los Hechos, se ordena por la clave K-Sellos: por la
%   regla y, dentro de ella, del hecho más antiguo al más reciente.
primera_ascendente(Programa, Hechos, Elegida) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, _, Rete),
    conjunto_rete(Rete, Is),
    Red = red(_, _, _, Terminales),
    findall((K-Sellos)-I,
            ( member(I, Is),
              I = instanciacion(Nombre, Sellos, _, _),
              once(gen_assoc(K, Terminales, regla(Nombre, _, _, _))) ),
            Pares),
    keysort(Pares, [_-Elegida|_]).

%!  primera_descendente(+Programa, +Hechos:list, -Elegida) is det.
%
%   Elegida es la instanciación que elige orden con el conjunto de la red.
primera_descendente(Programa, Hechos, Elegida) :-
    reconocer_rete(Programa, Hechos, Is),
    preferida(orden, Is, Elegida).

% Ejercicio 4. Un programa sin prueba que descarte el par de un hecho
% consigo mismo.
programa(pares, [ par :: [p(X), p(Y)] ---> [agregar(par(X, Y))] ]).

%!  conjunto_invertido(+Programa, +Hechos:list, -Sellos:list) is det.
%
%   Sellos son los de las instanciaciones del conjunto de conflicto de la
%   red del Programa con los Hechos, cargados activando los sucesores de
%   cada nodo alfa del menos profundo al más profundo.
conjunto_invertido(Programa, Hechos, Sellos) :-
    red_de(Programa, Red),
    cargar_con(@=<, activar_derecha(mas), Red, Hechos, Rete),
    conjunto_rete(Rete, Is),
    findall(S, member(instanciacion(_, S, _, _), Is), Sellos).

%!  cargar_con(+Orden, :Activar, +Red, +Hechos:list, -Rete) is det.
%
%   Como cargar/4, sin la memoria de trabajo: los Hechos, que son
%   distintos, entran con los sellos 1, 2, ..., y los sucesores de sus
%   nodos alfa se ordenan con sort/4 y Orden, y se activan con
%   call(Activar, Sello, Red, Nodo-Paso, Rete0, Rete).
cargar_con(Orden, Activar, Red, Hechos, Rete) :-
    rete_vacio(Red, Rete0),
    foldl(entrar_con(Orden, Activar, Red), Hechos, Rete0-1, Rete-_).

%!  entrar_con(+Orden, :Activar, +Red, +Hecho, +Rete0S0, -ReteS) is det.
%
%   Hecho entra con el sello S0, y S es el sello siguiente.
entrar_con(Orden, Activar, Red, Hecho, rete(Alfas0, Betas, C)-S0,
           Rete-S) :-
    entrar_alfa(mas, S0, Hecho, Red, Alfas0, Alfas, Entradas),
    Red = red(_, Info, _, _),
    findall(B-Paso,
            ( member(A-Paso, Entradas),
              get_assoc(A, Info, a(_, Sucesores)),
              member(B, Sucesores) ),
            Activaciones0),
    sort(1, Orden, Activaciones0, Activaciones),
    foldl(call(Activar, S0, Red), Activaciones, rete(Alfas, Betas, C),
          Rete),
    S is S0 + 1.

% Ejercicio 6.

%!  ciclo_sin_registro(+Programa, +Estrategia, +Limite:integer,
%!                     +Hechos:list, -Memoria:list, -Resultado) is det.
%
%   Ejecuta el Programa en la red sin el registro de las disparadas: la
%   elegida sale del conjunto de conflicto y nada más. Resultado es el de
%   parar/1, nada_aplicable, o limite(Limite) si se llega al límite de
%   ciclos.
ciclo_sin_registro(Programa, Estrategia, Limite, Hechos, Memoria,
                   Resultado) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, Mt0, Rete0),
    sin_registro(Red, Estrategia, Limite, 0, Mt0-Rete0, Mt, Resultado),
    hechos(Mt, Memoria).

%!  sin_registro(+Red, +Estrategia, +Limite:integer, +N:integer, +Estado,
%!               -Memoria, -Resultado) is det.
%
%   Sigue el ciclo después de N ciclos, desde el par Memoria-Rete Estado.
sin_registro(Red, Estrategia, Limite, N, Mt0-Rete0, Mt, Resultado) :-
    conjunto_rete(Rete0, Is),
    (   Is == []
    ->  Mt = Mt0,
        Resultado = nada_aplicable
    ;   N >= Limite
    ->  Mt = Mt0,
        Resultado = limite(Limite)
    ;   preferida(Estrategia, Is, Elegida),
        Elegida = instanciacion(_, _, _, Acciones),
        quitar_elegida(Red, Elegida, Rete0, Rete1),
        acciones_rete(Acciones, Red, Mt0-Rete1, Estado, Fin),
        (   Fin = parar(R)
        ->  Estado = Mt-_,
            Resultado = R
        ;   N1 is N + 1,
            sin_registro(Red, Estrategia, Limite, N1, Estado, Mt, Resultado)
        )
    ).

% Ejercicio 7.

%!  carga_siempre(+K:integer, -Inferencias:integer) is det.
%
%   Inferencias son las de cargar pedido_ampliado(K, _) en la red del
%   configurador activando por la derecha cada sucesor, aunque su padre no
%   tenga tokens.
carga_siempre(K, Inferencias) :-
    red_de(configurador, Red),
    pedido_ampliado(K, Hechos),
    inferencias(cargar_con(@>=, siempre_derecha, Red, Hechos, _),
                Inferencias).

%!  carga_normal(+K:integer, -Inferencias:integer) is det.
%
%   Como carga_siempre/2, con activar_derecha/6, que no activa un nodo
%   cuyo padre no tiene tokens.
carga_normal(K, Inferencias) :-
    red_de(configurador, Red),
    pedido_ampliado(K, Hechos),
    inferencias(cargar_con(@>=, activar_derecha(mas), Red, Hechos, _),
                Inferencias).

%!  siempre_derecha(+Sello:integer, +Red, +Activacion, +Rete0, -Rete)
%!      is det.
%
%   Como activar_derecha/6 con el signo mas, sin mirar la memoria del
%   padre.
siempre_derecha(Sello, Red, Nodo-Paso, Rete0, Rete) :-
    Red = red(_, _, Nodos, _),
    get_assoc(Nodo, Nodos, beta(Tipo, Padre, Prefijo, _, _)),
    derecha(Tipo, mas, Sello-Paso, Padre-Nodo, Prefijo, Red, Rete0, Rete).

% Ejercicio 9.

%!  rastrear_cambios(+Programa, +Estrategia, +Hechos:list, -Resultado)
%!      is det.
%
%   Ejecuta el Programa en la red y escribe, en cada ciclo, la regla
%   elegida y los pares Regla-Sellos que entraron en el conjunto de
%   conflicto y los que salieron por las acciones del ciclo, sin contar la
%   elegida.
rastrear_cambios(Programa, Estrategia, Hechos, Resultado) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, Mt, Rete),
    con_cambios(Red, Estrategia, 1, [], Mt-Rete, Resultado).

%!  con_cambios(+Red, +Estrategia, +N:integer, +Disparadas:list, +Estado,
%!              -Resultado) is det.
%
%   Hace el ciclo N con un_ciclo/9 y escribe sus cambios.
con_cambios(Red, Estrategia, N, Disparadas0, Estado0, Resultado) :-
    Estado0 = _-Rete0,
    identidades(Rete0, Antes),
    un_ciclo(Red, Estrategia, breve, N, Disparadas0, Disparadas, Estado0,
             Estado, Fin),
    (   Fin == nada_aplicable
    ->  Resultado = nada_aplicable
    ;   Estado = _-Rete,
        identidades(Rete, Despues),
        ord_subtract(Despues, Antes, Entraron),
        ord_subtract(Antes, Despues, Salieron0),
        ord_subtract(Salieron0, Disparadas, Salieron),
        format("   entran ~w, salen ~w~n", [Entraron, Salieron]),
        (   Fin = parar(R)
        ->  Resultado = R
        ;   N1 is N + 1,
            con_cambios(Red, Estrategia, N1, Disparadas, Estado, Resultado)
        )
    ).

%!  identidades(+Rete, -Identidades:list) is det.
%
%   Identidades es el conjunto ordenado de los pares Regla-Sellos del
%   conjunto de conflicto de Rete.
identidades(Rete, Identidades) :-
    conjunto_rete(Rete, Is),
    findall(N-S, member(instanciacion(N, S, _, _), Is), Pares),
    sort(Pares, Identidades).

% Ejercicio 10.

%!  tokens_al_final(+N:integer, -Tokens:integer, -Antepasados:integer)
%!      is det.
%
%   Tokens son los de todas las memorias beta de la red de familia al
%   terminar cadena(N, _) con orden, y Antepasados, los hechos
%   antepasado/2 de la memoria final.
tokens_al_final(N, Tokens, Antepasados) :-
    cadena(N, Hechos),
    red_de(familia, Red),
    cargar(Red, Hechos, Mt0, Rete0),
    ciclo_rete(Red, orden, sin_traza, 0, _, [], Mt0-Rete0, Mt-Rete, _),
    Red = red(_, _, Nodos, _),
    aggregate_all(sum(T),
                  ( gen_assoc(B, Nodos, _),
                    tokens(B, Rete, Ts),
                    length(Ts, T) ),
                  Tokens),
    aggregate_all(count, elemento(_, antepasado(_, _), Mt), Antepasados).

% Ejercicio 11.

%!  pasos_forzados(+Condiciones:list, -Pasos:list) is det.
%
%   Como pasos_con_pruebas/2, pero cada patrón se lleva todas las pruebas
%   que lo siguen, sin mirar sus variables.
pasos_forzados(Condiciones, Pasos) :-
    separar(Condiciones, Separadas),
    forzar(Separadas, Pasos).

%!  forzar(+Condiciones:list, -Pasos:list) is det.
%
%   Pasos son los de las Condiciones con todas las pruebas que siguen a un
%   patrón dentro de su paso alfa.
forzar([], []).
forzar([C|Cs], [Paso|Pasos]) :-
    (   ( C = {_} ; C = no(_) )
    ->  Paso = C,
        Resto = Cs
    ;   pruebas_siguientes(Cs, Pruebas, Resto),
        Paso = alfa(C, Pruebas)
    ),
    forzar(Resto, Pasos).

%!  pruebas_siguientes(+Condiciones:list, -Pruebas:list, -Resto:list)
%!      is det.
%
%   Pruebas son las metas de las pruebas del principio de Condiciones, y
%   Resto, las condiciones que siguen.
pruebas_siguientes(Condiciones, Pruebas, Resto) :-
    (   Condiciones = [{G}|Cs]
    ->  Pruebas = [G|Gs],
        pruebas_siguientes(Cs, Gs, Resto)
    ;   Pruebas = [],
        Resto = Condiciones
    ).

%!  configurar_forzado(+Pedido:list, -Resultado) is det.
%
%   Resultado es ok(Componentes) si el configurador con la red de
%   pasos_forzados/2 termina para el Pedido, o error(E) si lanza el
%   error E.
configurar_forzado(Pedido, Resultado) :-
    programa(configurador, Reglas),
    compilar_red(pasos_forzados, Reglas, Red),
    memoria_del_pedido(Pedido, Hechos),
    catch(( ejecutar_red(Red, mea, sin_traza, Hechos, _, Mt, _),
            hechos(Mt, Memoria),
            componentes(Memoria, Componentes, _),
            Resultado = ok(Componentes) ),
          E,
          Resultado = error(E)).

% Ejercicio 12.

%!  ciclos_para_ganar(+K:integer, -C) is det.
%
%   C es la menor cantidad de ciclos para la cual la red con pruebas alfa
%   cuesta menos que el capítulo 63 en el configurador con
%   pedido_ampliado(K, _), si cada ciclo cuesta el promedio de los 21
%   medidos en cada intérprete, o nunca si el ciclo promedio de la red no
%   es más barato.
ciclos_para_ganar(K, C) :-
    comparar_con_pruebas(K, fila(_, I63, _, _, Carga, Ciclos)),
    Por63 is I63 / 21,
    PorRed is Ciclos / 21,
    (   Por63 > PorRed
    ->  C is floor(Carga / (Por63 - PorRed)) + 1
    ;   C = nunca
    ).
