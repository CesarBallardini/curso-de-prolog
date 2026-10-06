:- encoding(utf8).

% Capítulo 77 - Soluciones de los ejercicios.
%
% Carga las versiones del capítulo sin modificarlas. Los predicados que
% no exportan se llaman con el nombre del módulo delante.
%
% solo-local: carga otros archivos.
%
%?- mayor_distancia(D).
%?- conocimiento_final(1, K), frontera(K, F).

:- module(soluciones,
          [ distancia/3,
            mayor_distancia/1,
            jugada_estricta/5,
            conocimiento_final/2,
            seguras_por_reglas2/2,
            comparar_reglas2/2,
            satisfacible/1,
            seguras_dpll/2,
            comparar_dpll/2,
            barrer_umbrales/2,
            mundo_sembrado/3,
            medir_tamano/3,
            cazar_k/4,
            medir_caza_k/3,
            soluble/1,
            contar_solubles/2,
            jugar_humano/2,
            tiene_oro/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(library(ordsets)).
:- use_module(library(dcg/basics)).
:- use_module(azar).
:- reexport(cueva).
:- reexport(enfoques).
:- reexport(riesgo).
:- reexport(cazador).
:- reexport(temporal).

% --- Ejercicio 2 ------------------------------------------------------------

%!  distancia(+A, +B, -D:integer) is det.
%
%   D es la cantidad mínima de túneles de la sala A a la sala B.
distancia(A, B, D) :-
    distancia_([A], [A], B, 0, D).

%!  distancia_(+Nivel:list, +Vistas:list, +B, +D0:integer, -D:integer)
%!      is det.
%
%   Búsqueda en anchura por niveles: Nivel son las salas a distancia D0.
distancia_(Nivel, Vistas, B, D0, D) :-
    (   memberchk(B, Nivel)
    ->  D = D0
    ;   findall(V,
                ( member(S, Nivel), tunel(S, V), \+ memberchk(V, Vistas) ),
                Vs0),
        sort(Vs0, Siguiente),
        append(Vistas, Siguiente, Vistas1),
        D1 is D0 + 1,
        distancia_(Siguiente, Vistas1, B, D1, D)
    ).

%!  mayor_distancia(-D:integer) is det.
%
%   D es la mayor distancia entre dos salas de la cueva.
mayor_distancia(D) :-
    aggregate_all(max(X), ( sala(A), sala(B), distancia(A, B, X) ), D).

% --- Ejercicio 3 ------------------------------------------------------------

%!  jugada_estricta(+Orden, +E0, -E, -Resultado, -Mensajes:list) is det.
%
%   Como jugada/5, pero una ruta que pasa por la sala del jugador o repite
%   la sala de dos pasos antes se rechaza con el mensaje ruta_invalida.
jugada_estricta(disparar(Ruta), E0, E, Resultado, Mensajes) :-
    E0 = j(J, _, _, _, _, _),
    (   memberchk(J, Ruta)
    ;   append(_, [A, _, A|_], [J|Ruta])
    ),
    !,
    E = E0,
    Resultado = sigue,
    Mensajes = [ruta_invalida].
jugada_estricta(Orden, E0, E, Resultado, Mensajes) :-
    jugada(Orden, E0, E, Resultado, Mensajes).

% --- Ejercicio 4 ------------------------------------------------------------

%!  conocimiento_final(+Semilla:integer, -K) is det.
%
%   K es el conocimiento del agente prudente al terminar su partida en el
%   mundo sembrado con Semilla: las celdas que visitó, en orden, con sus
%   percepciones.
conocimiento_final(Semilla, K) :-
    mundo_sembrado(Semilla, M),
    jugar(M, final(_, _, Acciones)),
    findall(C, member(ir(C), Acciones), Cs),
    foldl(enfoques:agregar_nueva, Cs, [1-1], Celdas),
    maplist(enfoques:con_percepciones(M), Celdas, Vs),
    conocer(4, Vs, K).

% --- Ejercicio 5 ------------------------------------------------------------

%!  seguras_por_reglas2(+K, -Seguras:list) is det.
%
%   Las celdas que prueban seguras las reglas de enfoques.pl más la regla
%   de dos hedores.
seguras_por_reglas2(K, Seguras) :-
    enfoques:sin_visitar(K, Cs),
    include(segura2(K), Cs, Seguras).

%!  segura2(+K, +C) is semidet.
%
%   Las reglas, con la de dos hedores, prueban que C es segura.
segura2(K, C) :-
    enfoques:sin_pozo(K, C),
    (   enfoques:sin_wumpus(K, C)
    ->  true
    ;   dos_hedores(K, W),
        W \== C
    ).

%!  dos_hedores(+K, -W) is semidet.
%
%   Dos celdas visitadas con hedor tienen una sola vecina común sin
%   visitar que no está descartada por una vecina visitada sin hedor: el
%   wumpus está en W.
dos_hedores(K, W) :-
    K = c(N, _, _, _, _, _, _),
    once(( enfoques:percibio(K, A, hedor),
           enfoques:percibio(K, B, hedor),
           A @< B,
           findall(D,
                   ( vecina(N, A, D),
                     vecina(N, B, D),
                     \+ enfoques:visitada(K, D),
                     \+ ( vecina(N, D, E),
                          enfoques:visitada(K, E),
                          \+ enfoques:percibio(K, E, hedor) ) ),
                   [W]) )).

%!  comparar_reglas2(+Semillas:list, -Resultado) is det.
%
%   Resultado es r(Seguras, Distintas) de seguras_por_reglas2/2 en las
%   instantáneas de Semillas, frente a los mundos consistentes.
comparar_reglas2(Semillas, r(Seguras, Distintas)) :-
    instantaneas(Semillas, Ks),
    maplist(seguras_por_reglas2, Ks, Ss),
    maplist(seguras, Ks, Rs),
    maplist(length, Ss, Ls),
    sum_list(Ls, Seguras),
    foldl(enfoques:contar_distinta, Ss, Rs, 0, Distintas).

% --- Ejercicio 6 ------------------------------------------------------------

%!  satisfacible(+Clausulas:list) is semidet.
%
%   Las Clausulas, listas de literales +A y -A sin variables, tienen un
%   modelo: DPLL con propagación unitaria y separación de casos.
satisfacible(Clausulas) :-
    (   Clausulas == []
    ->  true
    ;   memberchk([], Clausulas)
    ->  fail
    ;   member([L], Clausulas)
    ->  asignar(L, Clausulas, Resto),
        satisfacible(Resto)
    ;   Clausulas = [[L|_]|_],
        (   asignar(L, Clausulas, Resto)
        ;   opuesto(L, M),
            asignar(M, Clausulas, Resto)
        ),
        satisfacible(Resto)
    ->  true
    ).

%!  asignar(+L, +Clausulas:list, -Resto:list) is det.
%
%   Resto son las Clausulas con L verdadero: sin las que contienen L, y
%   sin el opuesto de L en las demás.
asignar(L, Clausulas, Resto) :-
    opuesto(L, M),
    exclude(memberchk(L), Clausulas, Sin),
    maplist(quitar(M), Sin, Resto).

%!  quitar(+M, +C0:list, -C:list) is det.
%
%   C es la cláusula C0 sin el literal M.
quitar(M, C0, C) :-
    exclude(==(M), C0, C).

%!  opuesto(+L, -M) is det.
%
%   M es el literal opuesto de L.
opuesto(+A, -A).
opuesto(-A, +A).

%!  clausulas_conocimiento(+K, -Cs:list) is det.
%
%   Cs es el conocimiento K en forma clausal: celdas visitadas sin
%   peligros, cada percepción como disyunción de los peligros vecinos o
%   como su ausencia, y exactamente un wumpus.
clausulas_conocimiento(K, Cs) :-
    K = c(N, _, Vs, _, _, _, _),
    findall([-P], ( member(C-_, Vs),
                    member(P, [pozo(C), wumpus(C)]) ), Libres),
    findall(Cl,
            ( member(C-Ps, Vs),
              member(Senal-Peligro, [brisa-pozo, hedor-wumpus]),
              findall(A, ( vecina(N, C, V), A =.. [Peligro, V] ), As),
              (   memberchk(Senal, Ps)
              ->  findall(+A, member(A, As), Cl)
              ;   member(A, As),
                  Cl = [-A]
              ) ),
            Percepciones),
    findall(X-Y, ( between(1, N, X), between(1, N, Y) ), Todas),
    findall(+wumpus(C), member(C, Todas), AlMenosUno),
    findall([-wumpus(A), -wumpus(B)],
            ( member(A, Todas), member(B, Todas), A @< B ),
            ASumoUno),
    append([Libres, Percepciones, [AlMenosUno], ASumoUno], Cs).

%!  seguras_dpll(+K, -Seguras:list) is det.
%
%   Seguras son las celdas sin visitar C para las que el conocimiento con
%   pozo(C) y el conocimiento con wumpus(C) son insatisfacibles.
seguras_dpll(K, Seguras) :-
    clausulas_conocimiento(K, Cs),
    enfoques:sin_visitar(K, Celdas),
    include(segura_dpll(Cs), Celdas, Seguras).

%!  segura_dpll(+Cs:list, +C) is semidet.
%
%   Cs no tiene modelo con un pozo ni con el wumpus en C.
segura_dpll(Cs, C) :-
    \+ satisfacible([[+pozo(C)]|Cs]),
    \+ satisfacible([[+wumpus(C)]|Cs]).

%!  comparar_dpll(+Semillas:list, -Resultado) is det.
%
%   Resultado es r(Seguras, Distintas, Inferencias) de seguras_dpll/2 en
%   las instantáneas de Semillas.
comparar_dpll(Semillas, r(Seguras, Distintas, Inferencias)) :-
    instantaneas(Semillas, Ks),
    statistics(inferences, I0),
    maplist(seguras_dpll, Ks, Ss),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    maplist(seguras, Ks, Rs),
    maplist(length, Ss, Ls),
    sum_list(Ls, Seguras),
    foldl(enfoques:contar_distinta, Ss, Rs, 0, Distintas).

% --- Ejercicio 7 ------------------------------------------------------------

%!  barrer_umbrales(+Semillas:list, -Resultados:list) is det.
%
%   Resultados son pares Umbral-r(Oro, Muertes, SinOro, Media) para los
%   umbrales 0.1 a 0.9.
barrer_umbrales(Semillas, Resultados) :-
    findall(U-R,
            ( between(1, 9, I),
              U is I / 10,
              medir(riesgo(U), Semillas, R) ),
            Resultados).

% --- Ejercicio 8 ------------------------------------------------------------

%!  mundo_sembrado(+N:integer, +Semilla:integer, -M) is det.
%
%   Como mundo_sembrado/2, en una cueva de N x N.
mundo_sembrado(N, Semilla, mundo(N, Pozos, Wumpus, Oro)) :-
    findall(X-Y, ( between(1, N, X), between(1, N, Y), X-Y \== 1-1 ),
            Celdas),
    foldl(grilla:tal_vez_pozo, Celdas, Pozos0, Semilla, S1),
    exclude(==(sin_pozo), Pozos0, Pozos),
    elegir(Celdas, Wumpus, S1, S2),
    elegir(Celdas, Oro, S2, _).

%!  medir_tamano(+N:integer, +Semillas:list, -Resultado) is det.
%
%   Resultado es r(Oro, Inferencias, Frontera): los oros del agente
%   prudente en las cuevas de N x N de Semillas, las inferencias medias
%   por partida y la mayor frontera de sus instantáneas.
medir_tamano(N, Semillas, r(Oro, Media, MaxF)) :-
    statistics(inferences, I0),
    findall(Fin-Cs,
            ( member(S, Semillas),
              mundo_sembrado(N, S, M),
              jugar(M, final(Fin, _, As)),
              findall(C, member(ir(C), As), Cs) ),
            Partidas),
    statistics(inferences, I1),
    length(Semillas, L),
    Media is round((I1 - I0) / L),
    aggregate_all(count, member(salio(si)-_, Partidas), Oro),
    aggregate_all(max(F),
                  ( member(S, Semillas),
                    mundo_sembrado(N, S, M),
                    jugar(M, final(_, _, As)),
                    findall(C, member(ir(C), As), Cs),
                    foldl(enfoques:agregar_nueva, Cs, [1-1], Celdas),
                    append(Prefijo, _, Celdas),
                    Prefijo \== [],
                    maplist(enfoques:con_percepciones(M), Prefijo, Vs),
                    conocer(N, Vs, K),
                    frontera(K, Fr),
                    length(Fr, F) ),
                  MaxF).

% --- Ejercicio 9 ------------------------------------------------------------

%!  cazar_k(+Kmax:integer, +Semilla:integer, -Resultado, -Ordenes:list)
%!      is det.
%
%   Como cazar/3, pero el agente dispara cuando el wumpus puede estar en a
%   lo sumo Kmax salas, hacia la primera.
cazar_k(Kmax, Semilla, Resultado, Ordenes) :-
    nueva_partida(Semilla, E),
    observacion(E, obs(S, _, Avisos, Flechas)),
    K = k(S, [S-Avisos], [S-Avisos], [], Flechas),
    turno_k(Kmax, 100, E, K, Resultado, Ordenes).

%!  turno_k(+Kmax:integer, +N:integer, +E, +K, -Resultado, -Ordenes:list)
%!      is det.
%
%   Juega a lo sumo N jugadas con la regla de disparo de Kmax salas.
turno_k(_, 0, _, _, limite, []) :-
    !.
turno_k(Kmax, N, E0, K0, Resultado, [Orden|Ordenes]) :-
    decidir_k(Kmax, K0, Orden),
    jugada(Orden, E0, E, R, Ms),
    (   R == sigue
    ->  observacion(E, Obs),
        cazador:aprender(Orden, Ms, Obs, K0, K),
        N1 is N - 1,
        turno_k(Kmax, N1, E, K, Resultado, Ordenes)
    ;   Resultado = R,
        Ordenes = []
    ).

%!  decidir_k(+Kmax:integer, +K, -Orden) is det.
%
%   Dispara hacia la primera sala posible del wumpus si hay a lo sumo Kmax;
%   si no, decide como el agente de cazador.pl.
decidir_k(Kmax, K, Orden) :-
    K = k(Sala, _, _, _, Flechas),
    mundos(K, wumpus, 1, Wumpus),
    append(Wumpus, Ws0),
    sort(Ws0, Ws),
    length(Ws, NW),
    (   Flechas > 0,
        NW > 0,
        NW =< Kmax
    ->  Ws = [Blanco|_],
        once(cazador:camino(Sala, Blanco, _, Ruta)),
        Orden = disparar(Ruta)
    ;   cazador:decidir(K, Orden)
    ).

%!  medir_caza_k(+Kmax:integer, +Semillas:list, -Resultados:list) is det.
%
%   Como medir_caza/2, con cazar_k/4.
medir_caza_k(Kmax, Semillas, Resultados) :-
    findall(R, ( member(S, Semillas), cazar_k(Kmax, S, R, _) ), Rs),
    msort(Rs, Ordenados),
    clumped(Ordenados, Resultados).

% --- Ejercicio 10 -----------------------------------------------------------

%!  soluble(+M) is semidet.
%
%   En el mundo M, el oro está en una celda sin pozo a la que se llega
%   desde (1, 1) sin pasar por pozos.
soluble(mundo(N, Pozos, _, Oro)) :-
    \+ memberchk(Oro, Pozos),
    alcanzable(N, Pozos, [1-1], [1-1], Oro).

%!  alcanzable(+N:integer, +Pozos:list, +Frontera:list, +Vistas:list,
%!             +Meta) is semidet.
%
%   Meta se alcanza desde las celdas de Frontera sin pasar por Pozos.
alcanzable(N, Pozos, Frontera, Vistas, Meta) :-
    (   memberchk(Meta, Frontera)
    ->  true
    ;   findall(V,
                ( member(C, Frontera),
                  vecina(N, C, V),
                  \+ memberchk(V, Pozos),
                  \+ memberchk(V, Vistas) ),
                Vs0),
        sort(Vs0, Siguiente),
        Siguiente \== [],
        append(Vistas, Siguiente, Vistas1),
        alcanzable(N, Pozos, Siguiente, Vistas1, Meta)
    ).

%!  contar_solubles(+Semillas:list, -N:integer) is det.
%
%   N es la cantidad de mundos solubles entre los de Semillas.
contar_solubles(Semillas, N) :-
    aggregate_all(count,
                  ( member(S, Semillas),
                    mundo_sembrado(S, M),
                    soluble(M) ),
                  N).

% --- Ejercicio 11 -----------------------------------------------------------

%!  jugar_humano(+In, +M) is det.
%
%   Juega el mundo M con las acciones que llegan, una por línea, por el
%   stream In, hasta que la partida termina o la entrada se acaba.
jugar_humano(In, M) :-
    estado_inicial(E),
    humano(In, M, E, [], 0).

%!  humano(+In, +M, +E, +Extras:list, +P0:integer) is det.
%
%   Muestra las percepciones del estado E, lee una acción y la ejecuta.
humano(In, M, E0, Extras, P0) :-
    E0 = e(C, _, _, _),
    percepciones(M, E0, Ps0),
    append(Ps0, Extras, Ps),
    format("Estás en la celda ~w.~n", [C]),
    forall(member(P, Ps), ( texto_percepcion(P, T), format("~w~n", [T]) )),
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   string_codes(Linea, Codigos),
        phrase(accion(A), Codigos),
        catch(actuar(M, A, E0, E, Extras1, Fin),
              error(domain_error(celda_vecina, _), _), fail)
    ->  grilla:costo(A, Fin, Costo),
        P is P0 + Costo,
        (   Fin == sigue
        ->  humano(In, M, E, Extras1, P)
        ;   texto_fin(Fin, T),
            format("~w Tu puntaje es ~w.~n", [T, P])
        )
    ;   format("No entiendo. Escribe ir X Y, tomar, ~w~n",
               ["disparar y una dirección, o salir."]),
        humano(In, M, E0, Extras, P0)
    ).

%!  accion(-A)// is semidet.
%
%   Una acción escrita.
accion(ir(X-Y)) -->
    blanks, "ir", blank, blanks, integer(X), blank, blanks, integer(Y),
    blanks.
accion(tomar) -->
    blanks, "tomar", blanks.
accion(salir) -->
    blanks, "salir", blanks.
accion(disparar(D)) -->
    blanks, "disparar", blank, blanks, string_without(" ", Cs), blanks,
    { atom_codes(D, Cs),
      memberchk(D, [norte, sur, este, oeste]) }.

% texto_percepcion(P, T): T es lo que se le dice al jugador que percibe P.
texto_percepcion(hedor, 'Sientes un hedor.').
texto_percepcion(brisa, 'Sientes una brisa.').
texto_percepcion(brillo, 'Ves un brillo.').
texto_percepcion(golpe, 'Chocas contra una pared.').
texto_percepcion(grito, 'Oyes un grito.').

% texto_fin(Fin, T): T es el mensaje final de la partida que terminó en Fin.
texto_fin(salio(si), 'Sales de la cueva con el oro.').
texto_fin(salio(no), 'Sales de la cueva sin el oro.').
texto_fin(murio(pozo), 'Caes en un pozo.').
texto_fin(murio(wumpus), 'El wumpus te come.').

% --- Ejercicio 12 -------------------------------------------------------------

%!  tiene_oro(+H, +T:integer) is semidet.
%
%   En el momento T de la historia H el agente lleva el oro: en un momento
%   anterior lo tomó mientras percibía el brillo. Ninguna acción lo suelta,
%   así que una vez tomado se conserva.
tiene_oro(H, T) :-
    T > 0,
    T0 is T - 1,
    (   hizo(H, tomar, T0),
        percibio(H, brillo, T0)
    ->  true
    ;   tiene_oro(H, T0)
    ).
