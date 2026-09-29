:- encoding(utf8).

% Capítulo 62 - Versión 4: el verificador de refutaciones.
%
% Un programa pequeño e independiente del demostrador, que no carga
% ningún otro archivo del capítulo. Recibe una refutación como dato,
% prueba(Clausulas, Pasos), y la acepta solo si cada paso es correcto y
% alguno produce la cláusula vacía. Un paso r(I, J, R) afirma que R es un
% resolvente de las cláusulas número I y J; un paso f(I, R), que R es un
% factor de la cláusula número I. El verificador calcula cada paso otra
% vez, con copias de las cláusulas y unify_with_occurs_check/2, y compara
% el resultado con R salvo el orden de los literales y el nombre de las
% variables. Si el demostrador tiene un error, el verificador rechaza la
% prueba; para confiar en una prueba alcanza con confiar en este archivo.
%
%?- verificar(prueba([[+p], [+q, -p], [-q]], [r(1, 2, [+q]), r(3, 4, [])])).
%?- verificar(prueba([[+p], [+q, -p], [-q]], [r(1, 3, [])])).

%!  verificar(+Prueba) is semidet.
%
%   Prueba, de la forma prueba(Clausulas, Pasos), es una refutación
%   correcta de las Clausulas: cada paso es correcto y el último produce
%   la cláusula vacía.
verificar(prueba(Clausulas, Pasos)) :-
    verificar_pasos(Pasos, Clausulas, Ultima),
    Ultima == [].

%!  verificar_pasos(+Pasos:list, +Clausulas:list, -Ultima:list) is semidet.
%
%   Cada paso de Pasos es correcto con las Clausulas anteriores a él, y
%   Ultima es la cláusula que agrega el último.
verificar_pasos([], Clausulas, Ultima) :-
    last(Clausulas, Ultima).
verificar_pasos([Paso|Pasos], Clausulas, Ultima) :-
    paso_correcto(Paso, Clausulas, C),
    append(Clausulas, [C], Clausulas1),
    verificar_pasos(Pasos, Clausulas1, Ultima).

%!  paso_correcto(+Paso, +Clausulas:list, -C:list) is semidet.
%
%   Paso es correcto con las Clausulas anteriores, y agrega la cláusula C.
paso_correcto(r(I, J, C), Clausulas, C) :-
    integer(I),
    integer(J),
    nth1(I, Clausulas, C1),
    nth1(J, Clausulas, C2),
    once(( resolver(C1, C2, R),
           misma_clausula(R, C)
         )).
paso_correcto(f(I, C), Clausulas, C) :-
    integer(I),
    nth1(I, Clausulas, C1),
    once(( factorizar(C1, R),
           misma_clausula(R, C)
         )).

%!  resolver(+C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de copias de C1 y C2 sin variables comunes: un
%   literal de una unifica con el opuesto de un literal de la otra, y R
%   reúne los demás literales de las dos con el unificador aplicado.
resolver(C1, C2, R) :-
    copy_term(C1, D1),
    copy_term(C2, D2),
    select(L1, D1, R1),
    select(L2, D2, R2),
    opuestos(L1, L2),
    append(R1, R2, R0),
    sin_repetidos(R0, R).

%!  factorizar(+C:list, -R:list) is nondet.
%
%   R es un factor de una copia de C: dos literales del mismo signo
%   unifican, y R es la cláusula con el unificador aplicado.
factorizar(C, R) :-
    copy_term(C, D),
    select(L1, D, D1),
    member(L2, D1),
    mismo_signo(L1, L2),
    unify_with_occurs_check(L1, L2),
    sin_repetidos(D, R).

%!  opuestos(+L1, +L2) is semidet.
%
%   L1 y L2 tienen signos opuestos y sus fórmulas atómicas unifican, con
%   la comprobación de ocurrencia.
opuestos(+A, -B) :-
    unify_with_occurs_check(A, B).
opuestos(-A, +B) :-
    unify_with_occurs_check(A, B).

%!  mismo_signo(+L1, +L2) is semidet.
%
%   L1 y L2 son los dos positivos o los dos negativos.
mismo_signo(+_, +_).
mismo_signo(-_, -_).

%!  sin_repetidos(+Ls:list, -Rs:list) is det.
%
%   Rs es Ls sin los literales idénticos a uno anterior.
sin_repetidos([], []).
sin_repetidos([L|Ls], Rs) :-
    (   member(M, Ls),
        M == L
    ->  Rs = Rs1
    ;   Rs = [L|Rs1]
    ),
    sin_repetidos(Ls, Rs1).

%!  misma_clausula(+R:list, +C:list) is semidet.
%
%   R y C tienen los mismos literales, salvo el orden y el nombre de las
%   variables.
misma_clausula(R, C) :-
    same_length(R, C),
    permutation(R, P),
    P =@= C,
    !.
