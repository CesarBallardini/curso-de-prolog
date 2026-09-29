:- encoding(utf8).

% Capítulo 64 - Versión 7: las pruebas de un solo hecho, en la red alfa.
%
% Una prueba {G} que sigue a un patrón F y que solo mira ese hecho puede
% ejecutarse en el nodo alfa de F, antes de cualquier unión: el nodo alfa
% guarda entonces solo los hechos que la cumplen. Mira solo ese hecho si
% cada variable de G que aparece en las condiciones anteriores a F
% aparece también en F, que el hecho liga. Antes de agrupar, una prueba
% {A, B} se separa en {A} y {B}, para mover la parte que se puede mover.
% La traducción cambia la red, no las reglas: compilar_red/3 recibe otro
% agrupador de pasos.
%
% solo-local: carga medida.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- pasos_con_pruebas([p(X), q(X, Y), {Y > 2, X \== Y}], Pasos).
%?- pasos_de_regla(configurador, candidato_procesador, P).

:- ensure_loaded(medida).

:- table red_con_pruebas/2.

%!  red_con_pruebas(+Programa, -Red) is det.
%
%   Red es la red del Programa con las pruebas de un solo hecho en los
%   nodos alfa.
red_con_pruebas(Programa, Red) :-
    programa(Programa, Reglas),
    compilar_red(pasos_con_pruebas, Reglas, Red).

%!  pasos_con_pruebas(+Condiciones:list, -Pasos:list) is det.
%
%   Pasos son los de las Condiciones con cada prueba conjuntiva separada y
%   las pruebas que siguen a un patrón y solo miran su hecho dentro del
%   paso alfa(F, Pruebas). Comparte las variables con Condiciones.
pasos_con_pruebas(Condiciones, Pasos) :-
    separar(Condiciones, Separadas),
    agrupar(Separadas, [], Pasos).

%!  separar(+Condiciones:list, -Separadas:list) is det.
%
%   Separadas son las Condiciones con cada {A, B} reemplazada por {A} y
%   {B}, a cualquier profundidad de la conjunción.
separar([], []).
separar([C|Cs], Separadas) :-
    (   C = {Meta}
    ->  conjuntos(Meta, Metas),
        entre_llaves(Metas, Pruebas),
        append(Pruebas, Resto, Separadas)
    ;   Separadas = [C|Resto]
    ),
    separar(Cs, Resto).

%!  conjuntos(+Meta, -Metas:list) is det.
%
%   Metas son las metas de la conjunción Meta, en orden.
conjuntos(Meta, Metas) :-
    (   nonvar(Meta),
        Meta = (A, B)
    ->  conjuntos(A, As),
        conjuntos(B, Bs),
        append(As, Bs, Metas)
    ;   Metas = [Meta]
    ).

%!  entre_llaves(+Metas:list, -Pruebas:list) is det.
%
%   Pruebas son las Metas entre llaves, con las mismas variables.
entre_llaves([], []).
entre_llaves([M|Ms], [{M}|Ps]) :-
    entre_llaves(Ms, Ps).

%!  agrupar(+Condiciones:list, +Anteriores:list, -Pasos:list) is det.
%
%   Pasos son los de las Condiciones, que siguen a los pasos Anteriores:
%   un patrón se lleva al paso alfa las pruebas que lo siguen y que solo
%   miran su hecho.
agrupar([], _, []).
agrupar([C|Cs], Anteriores, [Paso|Pasos]) :-
    (   ( C = {_} ; C = no(_) )
    ->  Paso = C,
        Resto = Cs
    ;   tomar_pruebas(Cs, C, Anteriores, Pruebas, Resto),
        Paso = alfa(C, Pruebas)
    ),
    agrupar(Resto, [Paso|Anteriores], Pasos).

%!  tomar_pruebas(+Condiciones:list, +F, +Anteriores:list, -Pruebas:list,
%!                -Resto:list) is det.
%
%   Pruebas son las metas de las pruebas del principio de Condiciones que
%   solo miran el hecho del patrón F, y Resto, las condiciones que siguen.
tomar_pruebas(Condiciones, F, Anteriores, Pruebas, Resto) :-
    (   Condiciones = [{G}|Cs],
        solo_del_hecho(G, F, Anteriores)
    ->  Pruebas = [G|Gs],
        tomar_pruebas(Cs, F, Anteriores, Gs, Resto)
    ;   Pruebas = [],
        Resto = Condiciones
    ).

%!  solo_del_hecho(+G, +F, +Anteriores:list) is semidet.
%
%   Cada variable de la meta G que aparece en los pasos Anteriores aparece
%   también en el patrón F.
solo_del_hecho(G, F, Anteriores) :-
    term_variables(G, EnG),
    term_variables(Anteriores, EnAnteriores),
    term_variables(F, EnF),
    forall(( member(V, EnG),
             contiene(EnAnteriores, V) ),
           contiene(EnF, V)).

%!  contiene(+Variables:list, +V) is semidet.
%
%   V es idéntica a una de las Variables. No unifica: compara con ==/2.
contiene(Variables, V) :-
    member(X, Variables),
    X == V,
    !.

%!  ejecutar_con_pruebas(+Programa, +Estrategia, +Hechos:list,
%!                       -Ciclos:integer, -Memoria, -Resultado) is det.
%
%   Como ejecutar_rete/7 sin traza, con la red de red_con_pruebas/2.
ejecutar_con_pruebas(Programa, Estrategia, Hechos, Ciclos, Memoria,
                     Resultado) :-
    red_con_pruebas(Programa, Red),
    ejecutar_red(Red, Estrategia, sin_traza, Hechos, Ciclos, Memoria,
                 Resultado).

%!  iguales_con_pruebas(+Programa, +Estrategia, +Hechos:list) is semidet.
%
%   Como iguales/3, con la red de red_con_pruebas/2.
iguales_con_pruebas(Programa, Estrategia, Hechos) :-
    ejecutar_produccion(Programa, Estrategia, sin_traza, Hechos, C, M, R),
    ejecutar_con_pruebas(Programa, Estrategia, Hechos, C1, M1, R1),
    C-M-R == C1-M1-R1.

%!  comparar_con_pruebas(+K:integer, -Fila) is det.
%
%   Como comparar/2, con las dos redes: Fila es
%   fila(Hechos, Capitulo63, Carga, Ciclos, CargaP, CiclosP), donde las
%   dos últimas son las de la red con las pruebas en los nodos alfa.
comparar_con_pruebas(K, fila(N, I63, Carga, Ciclos, CargaP, CiclosP)) :-
    comparar(K, fila(N, I63, Carga, Ciclos)),
    pedido_ampliado(K, Hechos),
    red_con_pruebas(configurador, Red),
    medir_red(Red, mea, Hechos, _, CargaP, CiclosP).

%!  pasos_de_regla(+Programa, +Nombre, -Pasos:list) is semidet.
%
%   Pasos son los de pasos_con_pruebas/2 para la regla Nombre del
%   Programa.
pasos_de_regla(Programa, Nombre, Pasos) :-
    programa(Programa, Reglas),
    memberchk(Nombre :: Condiciones ---> _, Reglas),
    pasos_con_pruebas(Condiciones, Pasos).

%!  tamano_con_pruebas(+Programa, -Alfas:integer, -Betas:integer,
%!                     -Condiciones:integer) is det.
%
%   Como tamano_red/4, con la red de red_con_pruebas/2.
tamano_con_pruebas(Programa, Alfas, Betas, Condiciones) :-
    red_con_pruebas(Programa, Red),
    medidas_red(Red, Alfas, Betas, Condiciones).

%!  perfil_con_pruebas(+K:integer, -Inferencias:list(integer)) is det.
%
%   Como perfil_pedido/2, con la red de red_con_pruebas/2.
perfil_con_pruebas(K, Inferencias) :-
    red_con_pruebas(configurador, Red),
    pedido_ampliado(K, Hechos),
    perfil_red(Red, mea, Hechos, Filas),
    findall(I, member(ciclo(_, I), Filas), Inferencias).

%!  ciclos_que_cambian_con_pruebas(+K:integer, -Ciclos:list(integer))
%!      is det.
%
%   Como ciclos_que_cambian/2, con la red de red_con_pruebas/2.
ciclos_que_cambian_con_pruebas(K, Ciclos) :-
    red_con_pruebas(configurador, Red),
    ciclos_distintos(Red, K, Ciclos).

%!  mostrar_pasos(+Programa, +Nombre) is semidet.
%
%   Escribe un paso por línea de la regla Nombre del Programa, agrupada
%   con pasos_con_pruebas/2, con las variables como A, B, ...
mostrar_pasos(Programa, Nombre) :-
    pasos_de_regla(Programa, Nombre, Pasos),
    \+ \+ ( numbervars(Pasos, 0, _),
            forall(member(Paso, Pasos),
                   ( escribir_paso(Paso),
                     nl )) ).
