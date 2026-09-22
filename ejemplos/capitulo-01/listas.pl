:- encoding(utf8).

% Capítulo 1 - Listas.
%
% Una lista se escribe entre corchetes, con los elementos separados por comas.
% La notación [Primero|Resto] descompone una lista en su primer elemento y la
% lista de los restantes.
%
%?- esta_invitado(luis).
%?- cuantos_invitados(N).

% invitados(L): L es la lista de invitados a la fiesta, en orden de llegada.
invitados([ana, luis, eva, sofia]).

% esta_invitado(P): P está en la lista de invitados.
esta_invitado(P) :-
    invitados(Lista),
    member(P, Lista).

% cuantos_invitados(N): N es la cantidad de invitados.
cuantos_invitados(N) :-
    invitados(Lista),
    length(Lista, N).

% primero_en_llegar(P): P es el primer elemento de la lista.
primero_en_llegar(P) :-
    invitados([P|_]).

% los_demas(Resto): Resto es la lista sin su primer elemento.
los_demas(Resto) :-
    invitados([_|Resto]).

% con_uno_mas(P, Lista): Lista es la lista de invitados con P agregado al final.
con_uno_mas(P, Lista) :-
    invitados(Invitados),
    append(Invitados, [P], Lista).
