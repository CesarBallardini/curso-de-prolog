:- encoding(utf8).

% Capítulo 66 - Versión 3: colapsar las reglas.
%
% Para decidir qué preguntar primero hace falta ver, de cada hipótesis,
% qué observaciones la prueban. colapsada/2 despliega las conclusiones
% intermedias (mamifero, ave, carnivoro, ungulado) hasta que en el cuerpo
% de cada regla quedan solo preguntas: observaciones, o una observación
% seguida de las comparaciones sobre su valor. Una conclusión intermedia
% con dos reglas duplica la regla que la usa. se_cumple/2 responde una
% pregunta con una lista de observaciones, con el intérprete del
% capítulo 33.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- colapsada(guepardo, Ps).
%?- colapsadas(Rs), length(Rs, N).
%?- preguntas(Ps), length(Ps, N).

:- module(colapsar,
          [ colapsada/2,
            colapsadas/1,
            preguntas/1,
            agregar_preguntas/3,
            se_cumple/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- ensure_loaded(user:'../capitulo-33/experto').

%!  colapsada(?Hipotesis, -Preguntas:list) is nondet.
%
%   Una regla colapsada prueba Hipotesis cuando se cumplen todas las
%   Preguntas. Una respuesta por cada combinación de reglas que prueba
%   Hipotesis.
colapsada(Hipotesis, Preguntas) :-
    hipotesis(Hipotesis),
    regla(_, si Condiciones entonces Hipotesis),
    desplegar(Condiciones, Literales),
    agrupar(Literales, Preguntas).

%!  colapsadas(-Reglas:list) is det.
%
%   Reglas tiene un par Hipotesis-Preguntas por cada regla colapsada, en
%   el orden de las hipótesis y de las reglas.
colapsadas(Reglas) :-
    findall(H-Ps, colapsada(H, Ps), Reglas).

%!  desplegar(+Condicion, -Literales:list) is nondet.
%
%   Literales son las observaciones y comparaciones que prueban Condicion,
%   con cada conclusión intermedia reemplazada por el cuerpo de una de sus
%   reglas.
desplegar(A y B, Literales) :-
    desplegar(A, LA),
    desplegar(B, LB),
    append(LA, LB, Literales).
desplegar(Comparacion, [Comparacion]) :-
    comparacion(Comparacion).
desplegar(Meta, [Meta]) :-
    observable(Meta).
desplegar(Meta, Literales) :-
    regla(_, si Condiciones entonces Meta),
    desplegar(Condiciones, Literales).

%!  agrupar(+Literales:list, -Preguntas:list) is det.
%
%   Preguntas es Literales con cada comparación unida con y a la
%   observación que la precede: peso(P) y P > 50 es una sola pregunta.
agrupar([], []).
agrupar([A|Resto], Preguntas) :-
    (   Resto = [C|Resto1],
        comparacion(C)
    ->  agrupar([A y C|Resto1], Preguntas)
    ;   Preguntas = [A|Preguntas1],
        agrupar(Resto, Preguntas1)
    ).

%!  preguntas(-Preguntas:list) is det.
%
%   Preguntas son las preguntas distintas de las reglas colapsadas, en el
%   orden en que aparecen. Dos preguntas son la misma si son variantes.
preguntas(Preguntas) :-
    colapsadas(Reglas),
    foldl(agregar_preguntas, Reglas, [], Preguntas).

%!  agregar_preguntas(+Regla, +Antes:list, -Despues:list) is det.
%
%   Despues es Antes con las preguntas de Regla que no tenía, al final.
agregar_preguntas(_-Ps, Antes, Despues) :-
    foldl(agregar_pregunta, Ps, Antes, Despues).

%!  agregar_pregunta(+P, +Antes:list, -Despues:list) is det.
%
%   Despues es Antes con P al final, si no tenía una variante de P.
agregar_pregunta(P, Antes, Despues) :-
    (   member(Q, Antes),
        Q =@= P
    ->  Despues = Antes
    ;   append(Antes, [P], Despues)
    ).

%!  se_cumple(+Pregunta, +Observaciones:list) is semidet.
%
%   Pregunta se prueba con Observaciones, con demostrar/4 del capítulo 33.
%   No liga las variables de Pregunta: la misma pregunta sirve para otras
%   observaciones.
se_cumple(Pregunta, Observaciones) :-
    \+ \+ demostrar(Pregunta, lista(Observaciones), [], _).
