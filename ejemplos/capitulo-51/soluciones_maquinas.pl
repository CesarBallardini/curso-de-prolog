:- encoding(utf8).

% Capítulo 51 - Soluciones de los ejercicios 10 y 11.
%
% Agregan un autómata de pila y una máquina de Turing a los de
% maquinas.pl, que se carga con ensure_loaded/1.
%
% solo-local: carga otro archivo, y SWISH no lo permite.
%
%?- acepta_pila(iguales, [a, b, b, a, b, a]).
%?- turing(palindromo_mt, [a, b, a], 1000, R).

:- ensure_loaded(maquinas).

:- multifile inicial/2, final/2, fondo/2, pila/6, turing/6.
:- discontiguous inicial/2, final/2, fondo/2, pila/6, turing/6.

% Ejercicio 10: iguales guarda en la pila el excedente de a o de b: una
% letra igual al tope se apila, y una distinta lo desapila.

inicial(iguales, q).
final(iguales, fin).
fondo(iguales, z).

pila(iguales, q, [S], z, [S, z], q) :-
    member(S, [a, b]).
pila(iguales, q, [S], S, [S, S], q) :-
    member(S, [a, b]).
pila(iguales, q, [S], T, [], q) :-
    member(S-T, [a-b, b-a]).
pila(iguales, q, [], z, [z], fin).

% Ejercicio 11: palindromo_mt borra el primer símbolo, recuerda cuál era
% con el estado, va hasta el último, lo compara y lo borra, y vuelve.

inicial(palindromo_mt, q0).
final(palindromo_mt, acepta).

turing(palindromo_mt, q0, a, blanco, der, qa).
turing(palindromo_mt, q0, b, blanco, der, qb).
turing(palindromo_mt, q0, blanco, blanco, der, acepta).
turing(palindromo_mt, qa, S, S, der, qa) :-
    member(S, [a, b]).
turing(palindromo_mt, qa, blanco, blanco, izq, qa_fin).
turing(palindromo_mt, qb, S, S, der, qb) :-
    member(S, [a, b]).
turing(palindromo_mt, qb, blanco, blanco, izq, qb_fin).
turing(palindromo_mt, qa_fin, a, blanco, izq, volver).
turing(palindromo_mt, qa_fin, blanco, blanco, der, acepta).
turing(palindromo_mt, qb_fin, b, blanco, izq, volver).
turing(palindromo_mt, qb_fin, blanco, blanco, der, acepta).
turing(palindromo_mt, volver, S, S, izq, volver) :-
    member(S, [a, b]).
turing(palindromo_mt, volver, blanco, blanco, der, q0).

%!  pasos(+M, +W:list, -N:integer) is semidet.
%
%   N es la menor cantidad de pasos con la que la máquina de Turing M se
%   detiene con la entrada W, buscada entre 0 y 10 000.
pasos(M, W, N) :-
    between(0, 10000, N),
    turing(M, W, N, R),
    R \= limite(_, _),
    !.
