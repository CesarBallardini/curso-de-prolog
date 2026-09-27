:- encoding(utf8).

% Capítulo 19 - Reglas como datos: un sistema experto con encadenamiento hacia
% atrás.
%
% Las reglas que identifican un animal son hechos regla/2, escritos con los
% operadores si, entonces e y. prueba/3 es el intérprete: para probar una
% conclusión busca una regla que la tenga como consecuencia y prueba sus
% condiciones, hasta llegar a las observaciones. El árbol de la prueba es la
% respuesta a la pregunta «¿cómo se llegó a esta conclusión?».
%
%?- caso(1, Obs), identificar(Obs, Animal).
%?- caso(1, Obs), como(Obs, guepardo).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no_vuela y nada entonces pinguino).
regla(r12, si ave y no_vuela y peso(P) y P > 50 entonces avestruz).

% hipotesis(H): H es una de las conclusiones finales que el sistema busca.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).
hipotesis(avestruz).

% caso(N, Observaciones): las observaciones de un animal de ejemplo.
caso(1, [tiene_pelo, come_carne, color_leonado, manchas_oscuras]).
caso(2, [da_leche, tiene_cascos, rayas_negras]).
caso(3, [tiene_plumas, no_vuela, peso(90)]).
caso(4, [tiene_plumas, no_vuela, nada, peso(30)]).
caso(5, [tiene_pelo, tiene_cascos]).

%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   Meta se prueba a partir de Observaciones y de las reglas; Arbol es la
%   prueba: observado(M), una comparación que se cumple, deducido(M, Regla,
%   ArbolDeLasCondiciones), o dos árboles unidos con y. Una respuesta por
%   cada prueba distinta.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(X > Y, _, X > Y) :-
    X > Y.
prueba(X < Y, _, X < Y) :-
    X < Y.
prueba(Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba(Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    prueba(Condiciones, Observaciones, Arbol).

%!  identificar(+Observaciones:list, -Animal) is nondet.
%
%   Animal es una de las hipótesis que se prueban a partir de Observaciones.
%   once/1 deja una sola prueba por animal: basta con que exista.
identificar(Observaciones, Animal) :-
    hipotesis(Animal),
    once(prueba(Animal, Observaciones, _)).

%!  como(+Observaciones:list, +Animal) is semidet.
%
%   Escribe cómo se llega a Animal a partir de Observaciones: una línea por
%   conclusión, observación o comparación, con las condiciones de cada regla
%   sangradas debajo de su conclusión. Falla si Animal no se prueba.
como(Observaciones, Animal) :-
    once(prueba(Animal, Observaciones, Arbol)),
    explicar(Arbol, 0).

%!  explicar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria.
explicar(A y B, Sangria) :-
    explicar(A, Sangria),
    explicar(B, Sangria).
explicar(observado(M), Sangria) :-
    format("~t~*|~w: observado~n", [Sangria, M]).
explicar(X > Y, Sangria) :-
    format("~t~*|~w > ~w: se cumple~n", [Sangria, X, Y]).
explicar(X < Y, Sangria) :-
    format("~t~*|~w < ~w: se cumple~n", [Sangria, X, Y]).
explicar(deducido(M, Regla, Arbol), Sangria) :-
    format("~t~*|~w: por ~w~n", [Sangria, M, Regla]),
    Siguiente is Sangria + 2,
    explicar(Arbol, Siguiente).
