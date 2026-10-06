:- encoding(utf8).

% Capítulo 67 - La inducción como abducción.
%
% inducir/5 es un metaintérprete abductivo como el del capítulo 49, pero lo
% que supone no son hechos sino cláusulas: para probar un objetivo usa un
% hecho del modelo de fondo, una cláusula que ya supuso, o una cláusula
% nueva tomada de una lista de cláusulas posibles, que agrega a la
% hipótesis y cuyo cuerpo prueba a continuación. Las cláusulas supuestas
% quedan instanciadas con el ejemplo; lgg_clausula/3 de la versión 2
% generaliza las explicaciones de dos ejemplos en una sola regla.
%
% solo-local: carga familia.pl, que carga archivos de otros capítulos.
%
%?- inducibles(abuelo, Is), modelo_fondo(M), inducir(abuelo(juan, luis), Is, M, [], H).
%?- explicaciones_comunes(abuelo(juan, luis), abuelo(pedro, sofia), C).

:- module(abductiva,
          [ inducibles/2,
            inducir/5,
            explicaciones/3,
            explicaciones_comunes/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- reexport(familia).
:- reexport(subsuncion).

%!  inducibles(+Relacion, -Clausulas:list) is semidet.
%
%   Clausulas son las cláusulas que se pueden suponer para Relacion: las
%   de cabeza Relacion(A, B) cuyo cuerpo es una de las combinaciones de
%   literales de la lista, de la más larga a la vacía.
inducibles(abuelo, Clausulas) :-
    findall((abuelo(A, B) :- Cuerpo),
            cuerpo_posible(A, B, Cuerpo),
            Clausulas).

%!  cuerpo_posible(?A, ?B, -Cuerpo:list) is nondet.
%
%   Cuerpo es una sublista de la lista de literales candidatos para
%   abuelo(A, B), en su orden.
cuerpo_posible(A, B, Cuerpo) :-
    Candidatos = [varon(A), padre(A, C), progenitor(C, B)],
    sublista(Candidatos, Cuerpo).

%!  sublista(+L:list, -S:list) is multi.
%
%   S tiene algunos elementos de L, en el mismo orden; primero las más
%   largas.
sublista([], []).
sublista([X|Xs], [X|Ys]) :-
    sublista(Xs, Ys).
sublista([_|Xs], Ys) :-
    sublista(Xs, Ys).

%!  inducir(+Meta, +Inducibles:list, +Fondo:list, +H0:list, -H:list)
%!      is nondet.
%
%   Meta se prueba con los hechos de Fondo, las cláusulas de H0 y las de
%   Inducibles; H es H0 con las cláusulas de Inducibles que la prueba
%   supone, instanciadas. Una respuesta por cada prueba.
inducir(Meta, _, Fondo, H, H) :-
    member(Meta, Fondo).
inducir(Meta, Inducibles, Fondo, H0, H) :-
    member((Meta :- Cuerpo), H0),
    inducir_cuerpo(Cuerpo, Inducibles, Fondo, H0, H).
inducir(Meta, Inducibles, Fondo, H0, H) :-
    member(R, Inducibles),
    copy_term(R, (Meta :- Cuerpo)),
    \+ ( member(C, H0),
         C =@= (Meta :- Cuerpo) ),
    inducir_cuerpo(Cuerpo, Inducibles, Fondo, [(Meta :- Cuerpo)|H0], H).

%!  inducir_cuerpo(+Cuerpo:list, +Inducibles:list, +Fondo:list, +H0:list,
%!                 -H:list) is nondet.
%
%   Cada literal de Cuerpo se prueba con inducir/5, de izquierda a
%   derecha, acumulando las cláusulas supuestas.
inducir_cuerpo([], _, _, H, H).
inducir_cuerpo([L|Ls], Inducibles, Fondo, H0, H) :-
    inducir(L, Inducibles, Fondo, H0, H1),
    inducir_cuerpo(Ls, Inducibles, Fondo, H1, H).

%!  explicaciones(+Ejemplo, +Relacion, -Cs:list) is det.
%
%   Cs son las cláusulas instanciadas que explican Ejemplo, una por cada
%   prueba que supone una sola cláusula de la relación, sin repetidos.
explicaciones(Ejemplo, Relacion, Cs) :-
    inducibles(Relacion, Is),
    modelo_fondo(M),
    findall(C, inducir(Ejemplo, Is, M, [], [C]), Cs0),
    list_to_set(Cs0, Cs).

%!  explicaciones_comunes(+E1, +E2, -C) is nondet.
%
%   C es la lgg de una explicación de E1 y una de E2 que salen de la misma
%   cláusula posible: una regla que explica a los dos. Una respuesta por
%   cada cláusula posible que explica a los dos ejemplos.
explicaciones_comunes(E1, E2, C) :-
    functor(E1, Relacion, _),
    inducibles(Relacion, Is),
    modelo_fondo(M),
    member(R, Is),
    once(inducir(E1, [R], M, [], [C1])),
    once(inducir(E2, [R], M, [], [C2])),
    lgg_clausula(C1, C2, C).
