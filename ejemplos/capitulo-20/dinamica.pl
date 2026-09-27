:- encoding(utf8).

% Capítulo 20 - Predicados dinámicos: una familia que cambia con el tiempo.
%
% padre/2 y edad/2 se declaran dinámicos: el programa les agrega y les quita
% cláusulas durante la ejecución. visita/2 es dinámico y no tiene ningún
% hecho: la consulta falla en lugar de producir un error.
%
%?- nace(sofia, pedro), padre(pedro, Hijo).
%?- cumple_anios(eva), edad(eva, Edad).

:- dynamic padre/2, edad/2, visita/2, numero/1.

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% visita(P, Q): P visita a Q. Ningún hecho todavía.

% numero(N): los números de la sección 19.3.
numero(1).
numero(2).

%!  nace(+Hijo, +Padre) is det.
%
%   Registra el nacimiento de Hijo, hijo de Padre, con edad 0.
nace(Hijo, Padre) :-
    assertz(padre(Padre, Hijo)),
    assertz(edad(Hijo, 0)).

%!  cumple_anios(+P) is semidet.
%
%   P cumple un año más: su edad se reemplaza por la siguiente. Falla si P no
%   tiene edad registrada.
cumple_anios(P) :-
    retract(edad(P, E)),
    E1 is E + 1,
    assertz(edad(P, E1)).

%!  olvidar(+P) is det.
%
%   Quita todo lo que la base registra de P: su edad y sus relaciones.
olvidar(P) :-
    retractall(edad(P, _)),
    retractall(padre(P, _)),
    retractall(padre(_, P)).

%!  multiplicar_por_diez is det.
%
%   Agrega el décuplo de cada número que había al empezar. La vista lógica
%   de actualización hace que el recorrido no vea los números que agrega.
multiplicar_por_diez :-
    forall(numero(N),
           ( M is N * 10,
             assertz(numero(M)) )).
