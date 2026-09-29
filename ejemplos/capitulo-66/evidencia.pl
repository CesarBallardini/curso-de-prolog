:- encoding(utf8).

% Capítulo 66 - Versión 1: probabilidades en las reglas y en las
% observaciones.
%
% Las reglas del sistema experto del capítulo 33 no cambian: se cargan de
% ese capítulo. Este archivo les agrega una fuerza, la probabilidad de la
% conclusión cuando las condiciones son seguras, y admite observaciones
% inciertas, pares Hecho-Grado. grado/4 calcula el grado de una conclusión:
% combina con y las condiciones de cada regla y la fuerza de la regla, y
% combina con o lo que aporta cada regla que concluye lo mismo. Cómo se
% combina lo dice un método: independiente, conservador o liberal.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- grado(mamifero, [tiene_pelo-0.9], independiente, P).
%?- caso(1, Os), seguras(Os, Gs), grado(guepardo, Gs, independiente, P).
%?- ranking([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
%?-          manchas_oscuras-0.6, rayas_negras-0.3], independiente, R).

:- module(evidencia,
          [ fuerza/2,
            metodo/1,
            seguras/2,
            y/4,
            o/4,
            combinar/4,
            grado/4,
            ranking/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- ensure_loaded(user:'../capitulo-33/experto').

% Otro archivo puede agregar métodos, con cláusulas de estos tres
% predicados.
:- multifile metodo/1, y/4, o/4.

% fuerza(Regla, F): F es la probabilidad de la conclusión de Regla cuando
% todas sus condiciones son seguras.
fuerza(r1,  0.9).
fuerza(r2,  0.95).
fuerza(r3,  1.0).
fuerza(r4,  0.7).
fuerza(r5,  0.8).
fuerza(r6,  0.9).
fuerza(r7,  0.85).
fuerza(r8,  0.9).
fuerza(r9,  0.9).
fuerza(r10, 0.85).
fuerza(r11, 0.8).
fuerza(r12, 0.9).

% metodo(M): M es un método de combinación.
metodo(independiente).
metodo(conservador).
metodo(liberal).

%!  seguras(+Observaciones:list, -Grados:list) is det.
%
%   Grados es Observaciones con cada observación segura: el par
%   Hecho-1.0. Convierte los casos del capítulo 19.
seguras(Observaciones, Grados) :-
    maplist(segura, Observaciones, Grados).

%!  segura(?Hecho, ?Par) is det.
%
%   Par es Hecho con grado 1.0.
segura(Hecho, Hecho-1.0).

%!  y(+Metodo, +P1:float, +P2:float, -P:float) is det.
%
%   P es el grado de la conjunción de dos hechos de grados P1 y P2, según
%   Metodo.
y(independiente, P1, P2, P) :-
    P is P1 * P2.
y(conservador, P1, P2, P) :-
    P is max(0.0, P1 + P2 - 1).
y(liberal, P1, P2, P) :-
    P is min(P1, P2).

%!  o(+Metodo, +P1:float, +P2:float, -P:float) is det.
%
%   P es el grado de la disyunción de dos hechos de grados P1 y P2, según
%   Metodo.
o(independiente, P1, P2, P) :-
    P is P1 + P2 - P1 * P2.
o(conservador, P1, P2, P) :-
    P is max(P1, P2).
o(liberal, P1, P2, P) :-
    P is min(1.0, P1 + P2).

%!  combinar(+Operacion, +Metodo, +Grados:list, -P:float) is det.
%
%   P combina Grados con Operacion, y u o, según Metodo. Las fórmulas son
%   asociativas, así que alcanza con aplicar la binaria de a una. La lista
%   vacía da el neutro: 1.0 para y, 0.0 para o.
combinar(y, Metodo, Grados, P) :-
    foldl(y(Metodo), Grados, 1.0, P).
combinar(o, Metodo, Grados, P) :-
    foldl(o(Metodo), Grados, 0.0, P).

%!  grado(+Meta, +Observaciones:list, +Metodo, -P:float) is det.
%
%   P es el grado de Meta: la combinación con o de todo lo que la apoya,
%   redondeada a cuatro decimales. Sin nada que la apoye, P es 0.0.
grado(Meta, Observaciones, Metodo, P) :-
    findall(P1, apoyo(Meta, Observaciones, Metodo, P1), Ps),
    combinar(o, Metodo, Ps, P0),
    P is round(P0 * 10000) / 10000.0.

%!  apoyo(+Meta, +Observaciones:list, +Metodo, -P:float) is nondet.
%
%   P es lo que aporta a Meta una observación, o una regla que la concluye
%   y cuyas condiciones tienen algún grado: la fuerza de la regla combinada
%   con y con el grado de las condiciones.
apoyo(Meta, Observaciones, _, P) :-
    observable(Meta),
    member(Meta-P, Observaciones).
apoyo(Meta, Observaciones, Metodo, P) :-
    regla(Regla, si Condiciones entonces Meta),
    condicion(Condiciones, Observaciones, Metodo, PC),
    fuerza(Regla, F),
    y(Metodo, F, PC, P).

%!  condicion(+Condicion, +Observaciones:list, +Metodo, -P:float) is nondet.
%
%   P es el grado de Condicion: una conjunción, una comparación, que vale
%   1.0 si se cumple, o una meta. Una meta con variables da una respuesta
%   por cada observación que la liga.
condicion(A y B, Observaciones, Metodo, P) :-
    condicion(A, Observaciones, Metodo, PA),
    condicion(B, Observaciones, Metodo, PB),
    y(Metodo, PA, PB, P).
condicion(Comparacion, _, _, 1.0) :-
    comparacion(Comparacion),
    call(Comparacion).
condicion(Meta, Observaciones, _, P) :-
    observable(Meta),
    member(Meta-P, Observaciones).
condicion(Meta, Observaciones, Metodo, P) :-
    Meta \= (_ y _),
    \+ comparacion(Meta),
    \+ observable(Meta),
    grado(Meta, Observaciones, Metodo, P).

%!  ranking(+Observaciones:list, +Metodo, -Ranking:list) is det.
%
%   Ranking tiene un par P-Hipotesis por cada hipótesis de grado mayor que
%   0, de mayor a menor grado.
ranking(Observaciones, Metodo, Ranking) :-
    findall(P-H,
            ( hipotesis(H),
              grado(H, Observaciones, Metodo, P),
              P > 0 ),
            Pares),
    sort(1, @>=, Pares, Ranking).
