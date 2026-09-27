:- encoding(utf8).

% Capítulo 16 - Soluciones de los ejercicios.
%
%?- suma_lista_acc([3, 1, 4], S).
%?- contar_bien([a, b, c], N).

% --- Ejercicio 3 -----------------------------------------------------------

%!  suma_lista_acc(+L:list(number), -S:number) is det.
%
%   S es la suma de los números de L, con un acumulador: la llamada recursiva
%   es el último objetivo, y la pila no crece con el largo de la lista.
suma_lista_acc(L, S) :-
    sumando(L, 0, S).

%!  sumando(+L:list(number), +Hasta:number, -S:number) is det.
%
%   S es Hasta más la suma de los números de L.
sumando([], S, S).
sumando([X|Resto], Hasta, S) :-
    Ahora is Hasta + X,
    sumando(Resto, Ahora, S).

% --- Ejercicio 4 -----------------------------------------------------------

%!  contar_bien(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L. La lista es el primer argumento del
%   auxiliar, que se distingue en [] y [_|_].
contar_bien(L, N) :-
    contar_desde(L, 0, N).

%!  contar_desde(+L:list, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más la cantidad de elementos de L.
contar_desde([], N, N).
contar_desde([_|Resto], Hasta, N) :-
    Ahora is Hasta + 1,
    contar_desde(Resto, Ahora, N).

% --- Ejercicio 5 -----------------------------------------------------------

%!  esta_en(?X, ?L:list) is nondet.
%
%   X es uno de los elementos de L.
esta_en(X, [X|_]).
esta_en(X, [_|Resto]) :-
    esta_en(X, Resto).

%!  todos_estan_corte(+Buscados:list, +L:list) is semidet.
%
%   Todos los elementos de Buscados están en L. El corte descarta las demás
%   apariciones de X en L: alcanza con encontrarlo una vez.
todos_estan_corte([], _).
todos_estan_corte([X|Resto], L) :-
    esta_en(X, L),
    !,
    todos_estan_corte(Resto, L).

% --- Ejercicio 7 -----------------------------------------------------------

%!  aplanar_izq(+Listas:list(list), -L:list) is det.
%
%   L es la concatenación de las listas de Listas. Acumula por la izquierda:
%   cada append/3 recorre todo lo acumulado.
aplanar_izq(Listas, L) :-
    aplanando(Listas, [], L).

%!  aplanando(+Listas:list(list), +Hasta:list, -L:list) is det.
%
%   L es Hasta seguida de la concatenación de Listas.
aplanando([], L, L).
aplanando([X|Resto], Hasta, L) :-
    append(Hasta, X, Ahora),
    aplanando(Resto, Ahora, L).

%!  aplanar_der(+Listas:list(list), -L:list) is det.
%
%   La misma relación, pegando cada lista delante del resto ya aplanado: cada
%   append/3 recorre solo la lista que agrega.
aplanar_der([], []).
aplanar_der([X|Resto], L) :-
    aplanar_der(Resto, RestoAplanado),
    append(X, RestoAplanado, L).

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa Objetivo hasta agotar todas sus
%   respuestas.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    forall(Objetivo, true),
    statistics(inferences, I1),
    I is I1 - I0.
