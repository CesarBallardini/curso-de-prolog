:- encoding(utf8).

% Capítulo 68 - Versión 4: usar el espacio de versiones antes de que
% converja, y elegir los ejemplos.
%
% Un espacio de versiones que todavía no convergió ya clasifica algunas
% instancias: si todo concepto de S la cubre, la cubre todo concepto del
% espacio, y es positiva; si ningún concepto de G la cubre, es negativa;
% en otro caso los conceptos del espacio no están de acuerdo, y la clase
% se desconoce.
%
% Un aprendiz pasivo recibe los ejemplos en el orden en que llegan. Un
% aprendiz activo elige la próxima instancia y pregunta su clase: la que
% divide el espacio de versiones en dos partes lo más parecidas posible,
% porque cualquiera sea la respuesta descarta muchos conceptos. Los dos
% empiezan con el mismo ejemplo positivo. El maestro es objetivo/3: la
% clase de una instancia según el concepto que se quiere enseñar.
%
% solo-local: carga espacio.pl, que carga un archivo de otro capítulo.
%
%?- eliminar_de(esfera_roja, 3, EV),
%   clasificar(EV, pieza(esfera, rojo, chico, metal), K).
%?- activo(pieza(_, verde, _, metal), Ps, E).

:- module(preguntas,
          [ clasificar/3,
            votos/4,
            objetivo/3,
            primer_positivo/2,
            mejor_pregunta/2,
            activo/3,
            pasivo/3,
            promedios/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(aggregate)).
:- reexport(candidatos).

%!  clasificar(+EV, +I, -Clase) is det.
%
%   Clase es positivo, negativo o desconocido: lo que el espacio de
%   versiones EV dice de la instancia I.
clasificar(ev(S, G), I, Clase) :-
    (   S \== [],
        forall(member(C, S), cubre(C, I))
    ->  Clase = positivo
    ;   \+ ( member(C, G),
             cubre(C, I) )
    ->  Clase = negativo
    ;   Clase = desconocido
    ).

%!  votos(+EV, +I, -Si:integer, -No:integer) is det.
%
%   De los conceptos del espacio de versiones EV, Si cubren la instancia I
%   y No no la cubren.
votos(EV, I, Si, No) :-
    conceptos_entre(EV, Cs),
    aggregate_all(count, ( member(C, Cs), cubre(C, I) ), Si),
    length(Cs, N),
    No is N - Si.

%!  conceptos_entre(+EV, -Cs:list) is det.
%
%   Cs son los conceptos del lenguaje que están entre los bordes de EV.
conceptos_entre(ev(S, G), Cs) :-
    findall(C, ( concepto(C),
                 once(( member(X, S), generaliza(C, X) )),
                 once(( member(Y, G), generaliza(Y, C) )) ), Cs).

%!  objetivo(+C, +I, -Ej) is det.
%
%   Ej es la instancia I con la clase que le da el concepto C: pos(I) si
%   C la cubre, neg(I) si no.
objetivo(C, I, Ej) :-
    (   cubre(C, I)
    ->  Ej = pos(I)
    ;   Ej = neg(I)
    ).

%!  primer_positivo(+C, -I) is semidet.
%
%   I es la primera instancia, en el orden de instancia/1, que el concepto
%   C cubre. Falla si C no cubre ninguna.
primer_positivo(C, I) :-
    instancia(I),
    cubre(C, I),
    !.

%!  mejor_pregunta(+EV, -I) is semidet.
%
%   I es la instancia de clase desconocida que divide el espacio de
%   versiones EV de la manera más pareja: la que hace máximo el menor de
%   sus votos a favor y en contra. Entre varias igualmente buenas, la
%   primera en el orden de instancia/1. Falla si todas las instancias
%   tienen clase conocida.
mejor_pregunta(EV, I) :-
    conceptos_entre(EV, Cs),
    length(Cs, N),
    aggregate_all(max(M, I0),
                  ( instancia(I0),
                    clasificar(EV, I0, desconocido),
                    aggregate_all(count, ( member(C, Cs), cubre(C, I0) ),
                                  Si),
                    M is min(Si, N - Si) ),
                  max(_, I)).

%!  activo(+C, -Ps:list, -E) is det.
%
%   Ps son los ejemplos que usa un aprendiz activo para aprender el
%   concepto C: el primer positivo de C y, después, en cada paso, la
%   mejor pregunta con la respuesta de objetivo/3. Se detiene cuando el
%   espacio converge o colapsa, y E es su estado final.
activo(C, [pos(I)|Ps], E) :-
    primer_positivo(C, I),
    inicial(EV0),
    actualizar(pos(I), EV0, EV),
    preguntar(C, EV, Ps, E).

%!  preguntar(+C, +EV, -Ps:list, -E) is det.
%
%   Ps son las preguntas que siguen desde el espacio EV hasta que converge
%   o colapsa, y E es el estado final.
preguntar(C, EV, Ps, E) :-
    estado(EV, E0),
    (   E0 == abierto,
        mejor_pregunta(EV, I)
    ->  objetivo(C, I, Ej),
        actualizar(Ej, EV, EV1),
        Ps = [Ej|Ps1],
        preguntar(C, EV1, Ps1, E)
    ;   Ps = [],
        E = E0
    ).

%!  pasivo(+C, -N:integer, -E) is det.
%
%   Un aprendiz pasivo recibe el primer positivo de C y después cada
%   instancia en el orden de instancia/1, con su clase. N es la cantidad
%   de ejemplos que recibe hasta que el espacio converge o colapsa, o
%   todos si no llega a hacerlo, y E es el estado final.
pasivo(C, N, E) :-
    primer_positivo(C, I),
    findall(Ej, ( instancia(J),
                  J \== I,
                  objetivo(C, J, Ej) ), Ejs),
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

%!  promedios(-Activo:float, -Pasivo:float, -Peor:pair) is det.
%
%   Para cada concepto del lenguaje distinto de vacio, cuenta los
%   ejemplos que necesitan el aprendiz activo y el pasivo, el primer
%   positivo incluido. Activo y Pasivo son los promedios, redondeados a
%   dos decimales, y Peor es el par A-P de los máximos.
promedios(Activo, Pasivo, MaxA-MaxP) :-
    findall(A-P, ( concepto(C),
                   C \== vacio,
                   activo(C, Ps, _),
                   length(Ps, A),
                   pasivo(C, P, _) ), Pares),
    length(Pares, K),
    aggregate_all(sum(A), member(A-_, Pares), SumaA),
    aggregate_all(sum(P), member(_-P, Pares), SumaP),
    aggregate_all(max(A), member(A-_, Pares), MaxA),
    aggregate_all(max(P), member(_-P, Pares), MaxP),
    Activo is round(SumaA / K * 100) / 100.0,
    Pasivo is round(SumaP / K * 100) / 100.0.
