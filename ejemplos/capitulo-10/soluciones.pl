:- encoding(utf8).

% Capítulo 10 - Soluciones de los ejercicios.
%
%?- sin_hermanos(Quien).
%?- solo_en_la_primera([ana, luis, eva], [luis], R).

% persona(P): P es una de las personas de la base.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% tiene(P, M): P tiene la mascota M.
tiene(ana, gato).
tiene(luis, perro).

% casado(A, B): A está casado con B.
casado(juan, marta).

% --- Ejercicio 3 -----------------------------------------------------------

%!  no_es_hijo_de(?H, +P) is nondet.
%
%   H es una persona que no es hijo de P. persona(H) se escribe primero para
%   que \+ opere sobre un valor instanciado.
no_es_hijo_de(H, P) :-
    persona(H),
    \+ padre(P, H).

% --- Ejercicio 4 -----------------------------------------------------------

%!  tiene_hermano(?P) is nondet.
%
%   P tiene algún hermano.
tiene_hermano(P) :-
    padre(Padre, P),
    padre(Padre, Otro),
    Otro \== P.

%!  sin_hermanos(?P) is nondet.
%
%   P no tiene hermanos.
sin_hermanos(P) :-
    persona(P),
    \+ tiene_hermano(P).

% --- Ejercicio 6 -----------------------------------------------------------

%!  nadie_tiene(+Cosa) is semidet.
%
%   Nadie tiene Cosa. Es correcto con Cosa instanciada.
nadie_tiene(Cosa) :-
    \+ tiene(_, Cosa).

% --- Ejercicio 7 -----------------------------------------------------------

%!  soltero(?P) is nondet.
%
%   P no está casado. Con los objetivos en el orden correcto.
soltero(P) :-
    persona(P),
    \+ casado(P, _).

% --- Ejercicio 8 -----------------------------------------------------------

%!  solo_en_la_primera(+L1, +L2, -R) is det.
%
%   R contiene los elementos de L1 que no están en L2. El corte descarta las
%   demás soluciones de member/2: es suficiente que X aparezca una vez en L2.
solo_en_la_primera([], _, []).
solo_en_la_primera([X|Resto], L2, [X|RestoR]) :-
    \+ member(X, L2),
    solo_en_la_primera(Resto, L2, RestoR).
solo_en_la_primera([X|Resto], L2, R) :-
    member(X, L2),
    !,
    solo_en_la_primera(Resto, L2, R).

% --- Ejercicio 15 ------------------------------------------------------------

%!  solo_en_la_segunda(+L1, +L2, -R) is det.
%
%   R contiene los elementos de L2 que no están en L1. L1 no debe tener
%   elementos sin valor.
solo_en_la_segunda(L1, L2, R) :-
    solo_en_la_primera(L2, L1, R).

% --- Ejercicio 12 ----------------------------------------------------------

%!  sin_mascota_correcto(?P) is nondet.
%
%   P es una persona que no tiene ninguna mascota. persona(P) se escribe
%   primero, para que \+ opere sobre un valor concreto.
sin_mascota_correcto(P) :-
    persona(P),
    \+ tiene(P, _).

% --- Ejercicio 13 ----------------------------------------------------------

%!  ninguno_es(+X, +L) is semidet.
%
%   Ningún elemento de L es X. Con \+ sobre la pertenencia.
ninguno_es(X, L) :-
    \+ esta_en_lista(X, L).

%!  esta_en_lista(?X, ?L) is nondet.
%
%   X es un elemento de L.
esta_en_lista(X, [X|_]).
esta_en_lista(X, [_|Resto]) :-
    esta_en_lista(X, Resto).

%!  ninguno_es_recorriendo(+X, +L) is semidet.
%
%   Ningún elemento de L es X: lo mismo, sin \+, con la plantilla 11.
ninguno_es_recorriendo(_, []).
ninguno_es_recorriendo(X, [Otro|Resto]) :-
    X \== Otro,
    ninguno_es_recorriendo(X, Resto).

% --- Ejercicio 16 ----------------------------------------------------------

% nota(A, M, N): el alumno A obtuvo la nota N en la materia M.
nota(ana, logica, 9).
nota(luis, logica, 7).
nota(eva, logica, 9).
nota(ana, algebra, 6).
nota(luis, algebra, 8).
nota(eva, algebra, 5).

%!  mejor_de(?M, ?A) is nondet.
%
%   A tiene la nota más alta de la materia M: ninguna nota de M es mayor que
%   la suya. Con empate, todos los empatados son respuestas.
mejor_de(M, A) :-
    nota(A, M, N),
    \+ ( nota(_, M, Otra),
         Otra > N ).

% --- Ejercicio 17 ----------------------------------------------------------

%!  llego_despues(?X, ?Y, +L) is nondet.
%
%   En la lista L, Y aparece después de X.
llego_despues(X, Y, [X|Resto]) :-
    esta_en_lista(Y, Resto).
llego_despues(X, Y, [_|Resto]) :-
    llego_despues(X, Y, Resto).

%!  ultimo(?X, +L) is semidet.
%
%   X es el último de L, una lista sin repetidos: nadie aparece después de X.
ultimo(X, L) :-
    esta_en_lista(X, L),
    \+ llego_despues(X, _, L).

% --- Versiones sin \+ -------------------------------------------------------
%
% Cada solución que usa \+, escrita de dos maneras más: con corte y falla, y
% sin negación. Las versiones sin negación necesitan los datos en listas, que
% repiten la información de los hechos.

% hijos(P, L): L es la lista de los hijos de P. Repite padre/2.
hijos(juan, [ana, pedro]).
hijos(pedro, [luis, eva]).
hijos(ana, []).
hijos(luis, []).
hijos(eva, []).

% sin_padre(P): P no tiene padre registrado. Repite en positivo lo que padre/2
% no dice.
sin_padre(juan).

% cosas_tenidas(L): L es la lista de las cosas que alguien tiene. Repite tiene/2.
cosas_tenidas([gato, perro]).

% casados(L): L es la lista de las personas casadas. Repite casado/2.
casados([juan]).

% con_mascota(L): L es la lista de las personas con mascota. Repite tiene/2.
con_mascota([ana, luis]).

% notas_de(M, L): L es la lista de pares Alumno-Nota de la materia M. Repite
% nota/3.
notas_de(logica, [ana-9, luis-7, eva-9]).
notas_de(algebra, [ana-6, luis-8, eva-5]).

% Ejercicio 3

%!  no_es_hijo_de_con_corte(?H, +P) is nondet.
%
%   H es una persona que no es hijo de P, con corte y falla.
no_es_hijo_de_con_corte(H, P) :-
    persona(H),
    no_es_padre_de(P, H).

%!  no_es_padre_de(+P, +H) is semidet.
%
%   P no es el padre de H.
no_es_padre_de(P, H) :-
    padre(P, H),
    !,
    fail.
no_es_padre_de(_, _).

%!  no_es_hijo_de_sin_negacion(?H, +P) is nondet.
%
%   H es una persona que no está en la lista de hijos de P.
no_es_hijo_de_sin_negacion(H, P) :-
    persona(H),
    hijos(P, Hijos),
    ninguno_es_recorriendo(H, Hijos).

% Ejercicio 4

%!  sin_hermanos_con_corte(?P) is nondet.
%
%   P no tiene hermanos, con corte y falla.
sin_hermanos_con_corte(P) :-
    persona(P),
    no_tiene_hermano(P).

%!  no_tiene_hermano(+P) is semidet.
%
%   P no tiene ningún hermano.
no_tiene_hermano(P) :-
    tiene_hermano(P),
    !,
    fail.
no_tiene_hermano(_).

%!  sin_hermanos_sin_negacion(?P) is nondet.
%
%   P no tiene padre registrado, o es el único elemento de la lista de hijos
%   de su padre.
sin_hermanos_sin_negacion(P) :-
    sin_padre(P).
sin_hermanos_sin_negacion(P) :-
    hijos(_, [P]).

% Ejercicio 6

%!  nadie_tiene_con_corte(+Cosa) is semidet.
%
%   Nadie tiene Cosa, con corte y falla.
nadie_tiene_con_corte(Cosa) :-
    tiene(_, Cosa),
    !,
    fail.
nadie_tiene_con_corte(_).

%!  nadie_tiene_sin_negacion(+Cosa) is semidet.
%
%   Cosa no está en la lista de las cosas que alguien tiene.
nadie_tiene_sin_negacion(Cosa) :-
    cosas_tenidas(Cosas),
    ninguno_es_recorriendo(Cosa, Cosas).

% Ejercicio 7

%!  soltero_con_corte(?P) is nondet.
%
%   P no está casado, con corte y falla.
soltero_con_corte(P) :-
    persona(P),
    no_casado(P).

%!  no_casado(+P) is semidet.
%
%   P no está casado con nadie.
no_casado(P) :-
    casado(P, _),
    !,
    fail.
no_casado(_).

%!  soltero_sin_negacion(?P) is nondet.
%
%   P no está en la lista de las personas casadas.
soltero_sin_negacion(P) :-
    persona(P),
    casados(Casados),
    ninguno_es_recorriendo(P, Casados).

% Ejercicio 8

%!  solo_en_la_primera_con_corte(+L1, +L2, -R) is det.
%
%   R contiene los elementos de L1 que no están en L2. La cláusula que
%   descarta va primero, y su corte hace innecesaria la condición de la
%   tercera: es un corte rojo.
solo_en_la_primera_con_corte([], _, []).
solo_en_la_primera_con_corte([X|Resto], L2, R) :-
    member(X, L2),
    !,
    solo_en_la_primera_con_corte(Resto, L2, R).
solo_en_la_primera_con_corte([X|Resto], L2, [X|RestoR]) :-
    solo_en_la_primera_con_corte(Resto, L2, RestoR).

%!  solo_en_la_primera_sin_negacion(+L1, +L2, -R) is det.
%
%   R contiene los elementos de L1 que no están en L2. La no pertenencia se
%   verifica recorriendo L2.
solo_en_la_primera_sin_negacion([], _, []).
solo_en_la_primera_sin_negacion([X|Resto], L2, [X|RestoR]) :-
    ninguno_es_recorriendo(X, L2),
    solo_en_la_primera_sin_negacion(Resto, L2, RestoR).
solo_en_la_primera_sin_negacion([X|Resto], L2, R) :-
    member(X, L2),
    !,
    solo_en_la_primera_sin_negacion(Resto, L2, R).

% Ejercicio 9

%!  no_tiene_hijos_con_corte(?P) is nondet.
%
%   P no es padre de nadie, con corte y falla.
no_tiene_hijos_con_corte(P) :-
    persona(P),
    no_es_padre(P).

%!  no_es_padre(+P) is semidet.
%
%   P no es padre de nadie.
no_es_padre(P) :-
    padre(P, _),
    !,
    fail.
no_es_padre(_).

%!  no_tiene_hijos_sin_negacion(?P) is nondet.
%
%   La lista de hijos de P está vacía.
no_tiene_hijos_sin_negacion(P) :-
    hijos(P, []).

% Ejercicio 12

%!  sin_mascota_con_corte(?P) is nondet.
%
%   P no tiene ninguna mascota, con corte y falla.
sin_mascota_con_corte(P) :-
    persona(P),
    no_tiene_mascota(P).

%!  no_tiene_mascota(+P) is semidet.
%
%   P no tiene ninguna mascota.
no_tiene_mascota(P) :-
    tiene(P, _),
    !,
    fail.
no_tiene_mascota(_).

%!  sin_mascota_sin_negacion(?P) is nondet.
%
%   P no está en la lista de las personas con mascota.
sin_mascota_sin_negacion(P) :-
    persona(P),
    con_mascota(Con),
    ninguno_es_recorriendo(P, Con).

% Ejercicio 13

%!  ninguno_es_con_corte(+X, +L) is semidet.
%
%   Ningún elemento de L es X, con corte y falla.
ninguno_es_con_corte(X, L) :-
    esta_en_lista(X, L),
    !,
    fail.
ninguno_es_con_corte(_, _).

% Ejercicio 16

%!  mejor_de_con_corte(?M, ?A) is nondet.
%
%   A tiene la nota más alta de la materia M, con corte y falla.
mejor_de_con_corte(M, A) :-
    nota(A, M, N),
    ninguna_nota_mayor(M, N).

%!  ninguna_nota_mayor(+M, +N) is semidet.
%
%   Ninguna nota de la materia M es mayor que N.
ninguna_nota_mayor(M, N) :-
    nota(_, M, Otra),
    Otra > N,
    !,
    fail.
ninguna_nota_mayor(_, _).

%!  mejor_de_sin_negacion(?M, ?A) is nondet.
%
%   A tiene la nota más alta de la materia M: recorre la lista de notas de M
%   y conserva la mayor vista. Con empate, responde solo el primero.
mejor_de_sin_negacion(M, A) :-
    notas_de(M, [A0-N0|Resto]),
    mejor_desde(Resto, A0, N0, A).

%!  mejor_desde(+L, +Hasta, +N, -A) is det.
%
%   A es el alumno de mayor nota entre Hasta, de nota N, y los pares de L.
mejor_desde([], A, _, A).
mejor_desde([A1-N1|Resto], _, N, A) :-
    N1 > N,
    mejor_desde(Resto, A1, N1, A).
mejor_desde([_-N1|Resto], Hasta, N, A) :-
    N1 =< N,
    mejor_desde(Resto, Hasta, N, A).

% Ejercicio 17

%!  ultimo_con_corte(?X, +L) is semidet.
%
%   X es el último de L, una lista sin repetidos, con corte y falla.
ultimo_con_corte(X, L) :-
    esta_en_lista(X, L),
    nadie_despues(X, L).

%!  nadie_despues(+X, +L) is semidet.
%
%   En la lista L nadie aparece después de X.
nadie_despues(X, L) :-
    llego_despues(X, _, L),
    !,
    fail.
nadie_despues(_, _).

%!  ultimo_sin_negacion(?X, +L) is semidet.
%
%   X es el último elemento de L: el único de una lista de un elemento, o el
%   último del resto. Admite repetidos.
ultimo_sin_negacion(X, [X]).
ultimo_sin_negacion(X, [_|Resto]) :-
    ultimo_sin_negacion(X, Resto).
