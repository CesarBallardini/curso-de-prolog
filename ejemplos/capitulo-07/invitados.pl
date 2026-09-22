:- encoding(utf8).

% Capítulo 7 - Predicados de listas predefinidos.
%
% Los mismos recorridos del ejemplo anterior, con los predicados predefinidos
% de Prolog. Son los que se usan en el resto del curso.
%
%?- esta_invitado(Quien).
%?- en_el_puesto(2, Quien).

% invitados(L): L es la lista de invitados, en orden de llegada.
invitados([ana, luis, eva, sofia]).

% esta_invitado(P): P está en la lista.
esta_invitado(P) :-
    invitados(Lista),
    member(P, Lista).

% cuantos(N): N es la cantidad de invitados.
cuantos(N) :-
    invitados(Lista),
    length(Lista, N).

% en_el_puesto(N, P): P es quien llegó en la posición N, contando desde 1.
en_el_puesto(N, P) :-
    invitados(Lista),
    nth1(N, Lista, P).

% ultimo_en_llegar(P): P es el último de la lista.
ultimo_en_llegar(P) :-
    invitados(Lista),
    last(Lista, P).

% orden_de_salida(L): L es la lista de invitados en orden inverso.
orden_de_salida(L) :-
    invitados(Lista),
    reverse(Lista, L).

% con_uno_mas(P, L): L es la lista de invitados con P agregado al final.
con_uno_mas(P, L) :-
    invitados(Lista),
    append(Lista, [P], L).
