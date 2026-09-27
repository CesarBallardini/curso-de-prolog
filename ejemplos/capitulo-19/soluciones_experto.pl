:- encoding(utf8).

% Capítulo 19 - Soluciones de los ejercicios 4, 5, 7 y 8: el sistema experto.
%
% Ejercicio 4: la disyunción o en el lenguaje de reglas. Ejercicio 5: un
% intérprete que recibe la base de reglas como argumento, y una segunda base
% para diagnosticar por qué un auto no arranca. Ejercicio 7: explicar/2, que
% escribe el árbol de la prueba. Ejercicio 8: la negación no en el intérprete;
% las reglas r11 y r12 dicen no vuela en lugar de la observación no_vuela.
%
%?- identificar([da_leche, come_carne, color_leonado, rayas_negras], A).
%?- diagnosticar(regla_auto, [no_gira_el_motor, luces_debiles], D).
%?- como([tiene_plumas, peso(90)], avestruz).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(785, xfy, o).
:- op(780, xfy, y).
:- op(770, fy, no).

:- meta_predicate
    prueba_con(2, +, +, -),
    diagnosticar(2, +, -).

% --- Ejercicios 4 y 8 ---------------------------------------------------------

% regla(Nombre, si Condiciones entonces Conclusion): las reglas del texto,
% con r1 y r2 unidas en una sola regla (ejercicio 4) y no vuela en lugar de
% la observación no_vuela (ejercicio 8).
regla(r1,  si tiene_pelo o da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no vuela y nada entonces pinguino).
regla(r12, si ave y no vuela y peso(P) y P > 50 entonces avestruz).

% hipotesis(H): H es una de las conclusiones finales que el sistema busca.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).
hipotesis(avestruz).

%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   El intérprete del texto, con dos cláusulas para o —una prueba de A o B
%   es una prueba de A o una de B, y el árbol es el de la que se cumple— y
%   una para no: no Meta se cumple cuando Meta no se puede probar, y su
%   árbol es no Meta. Meta debe llegar sin variables libres.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(A o _, Observaciones, Arbol) :-
    prueba(A, Observaciones, Arbol).
prueba(_ o B, Observaciones, Arbol) :-
    prueba(B, Observaciones, Arbol).
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
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
identificar(Observaciones, Animal) :-
    hipotesis(Animal),
    once(prueba(Animal, Observaciones, _)).

% --- Ejercicio 5 --------------------------------------------------------------

% regla_auto(Nombre, si Condiciones entonces Conclusion): por qué un auto no
% arranca.
regla_auto(a1, si no_gira_el_motor y luces_debiles entonces bateria).
regla_auto(a2, si no_gira_el_motor y luces_normales entonces burro_de_arranque).
regla_auto(a3, si gira_el_motor y olor_a_nafta entonces motor_ahogado).
regla_auto(a4, si gira_el_motor y tanque(L) y L < 1 entonces sin_combustible).

%!  prueba_con(:Reglas, +Meta, +Observaciones:list, -Arbol) is nondet.
%
%   Como prueba/3, con las reglas de Reglas: un predicado de dos argumentos,
%   el nombre de la regla y la regla.
prueba_con(Reglas, A y B, Observaciones, ArbolA y ArbolB) :-
    prueba_con(Reglas, A, Observaciones, ArbolA),
    prueba_con(Reglas, B, Observaciones, ArbolB).
prueba_con(Reglas, A o _, Observaciones, Arbol) :-
    prueba_con(Reglas, A, Observaciones, Arbol).
prueba_con(Reglas, _ o B, Observaciones, Arbol) :-
    prueba_con(Reglas, B, Observaciones, Arbol).
prueba_con(Reglas, no Meta, Observaciones, no Meta) :-
    \+ prueba_con(Reglas, Meta, Observaciones, _).
prueba_con(_, X > Y, _, X > Y) :-
    X > Y.
prueba_con(_, X < Y, _, X < Y) :-
    X < Y.
prueba_con(_, Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba_con(Reglas, Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    call(Reglas, Regla, si Condiciones entonces Meta),
    prueba_con(Reglas, Condiciones, Observaciones, Arbol).

%!  diagnosticar(:Reglas, +Observaciones:list, -Conclusion) is nondet.
%
%   Conclusion es la conclusión de una regla de Reglas que se prueba a partir
%   de Observaciones; una respuesta por conclusión.
diagnosticar(Reglas, Observaciones, Conclusion) :-
    setof(C, N^Si^call(Reglas, N, Si entonces C), Conclusiones),
    member(Conclusion, Conclusiones),
    once(prueba_con(Reglas, Conclusion, Observaciones, _)).

% --- Ejercicio 7 --------------------------------------------------------------

%!  como(+Observaciones:list, +Animal) is semidet.
%
%   Escribe cómo se llega a Animal a partir de Observaciones: una línea por
%   conclusión, observación, comparación o negación, con las condiciones de
%   cada regla sangradas debajo de su conclusión. Falla si Animal no se
%   prueba.
como(Observaciones, Animal) :-
    once(prueba(Animal, Observaciones, Arbol)),
    explicar(Arbol, 0).

%!  explicar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria: una cláusula por cada
%   forma de nodo, como prueba/3. ~t~*| completa con espacios hasta la
%   columna Sangria, y cada regla sangra sus condiciones dos columnas más.
explicar(A y B, Sangria) :-
    explicar(A, Sangria),
    explicar(B, Sangria).
explicar(observado(M), Sangria) :-
    format("~t~*|~w: observado~n", [Sangria, M]).
explicar(no M, Sangria) :-
    format("~t~*|no ~w: no se prueba~n", [Sangria, M]).
explicar(X > Y, Sangria) :-
    format("~t~*|~w > ~w: se cumple~n", [Sangria, X, Y]).
explicar(X < Y, Sangria) :-
    format("~t~*|~w < ~w: se cumple~n", [Sangria, X, Y]).
explicar(deducido(M, Regla, Arbol), Sangria) :-
    format("~t~*|~w: por ~w~n", [Sangria, M, Regla]),
    Siguiente is Sangria + 2,
    explicar(Arbol, Siguiente).
