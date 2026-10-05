:- encoding(utf8).

% Capítulo 49 - Abducción con negación.
%
% El intérprete de la versión 2 solo supone que algo es verdadero. Una
% teoría con negación, no(A), necesita también suponer que algo es falso:
% probar no(A) es refutar A, y refutar un átomo que tiene reglas es
% refutar el cuerpo de cada una. Los supuestos son un diccionario
% incompleto de pares Abducible-Valor, con Valor verdadero o falso: un
% abducible no puede quedar supuesto con los dos valores, y esa sola
% condición impide las explicaciones contradictorias. La idea es la de
% abduce/3 y abduce_not/3 en el apartado 8.3 de Simply Logical de Flach;
% la representación y el código son propios.
%
% Las reglas deben tener todas sus variables en la cabeza, y las metas
% que se refutan deben llegar sin variables: la refutación recorre los
% cuerpos de las reglas cuya cabeza es la meta.
%
% solo-local: carga diccionario.pl del capítulo 34, y SWISH no carga
% otros archivos.
%
%?- suponer(vuela(piolin), S), cerrar(S).
%?- suponer(no(enciende), S), cerrar(S).
%?- suponer((no(enciende), suena_la_radio), S), cerrar(S).

:- module(negacion,
          [ suponer/2,
            refutar/2,
            cerrar/1
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- ensure_loaded('../capitulo-34/diccionario').

:- multifile regla/2, abducible/1.

% abducible(A): A se puede suponer verdadero o falso; no tiene reglas.
abducible(pinguino(_)).
abducible(gorrion(_)).
abducible(muerto(_)).
abducible(hay_corriente).
abducible(lampara_sana).

% regla(Cabeza, Cuerpo): la teoría. Un ave vuela si no es anormal; un
% pingüino o un ave muerta es anormal. La luz enciende si hay corriente,
% la llave está cerrada y la lámpara está sana; la radio suena si hay
% corriente.
regla(vuela(X), (ave(X), no(anormal(X)))).
regla(vuela_bis(X), (no(anormal(X)), ave(X))).
regla(ave(X), pinguino(X)).
regla(ave(X), gorrion(X)).
regla(anormal(X), pinguino(X)).
regla(anormal(X), muerto(X)).
regla(enciende, (hay_corriente, llave_cerrada, lampara_sana)).
regla(llave_cerrada, true).
regla(suena_la_radio, hay_corriente).

%!  suponer(+Meta, ?Supuestos:list) is nondet.
%
%   Meta se prueba con la teoría y los Supuestos, un diccionario
%   incompleto de pares Abducible-Valor, que la prueba amplía: un
%   abducible que hace falta verdadero se supone verdadero, y no(A) se
%   prueba refutando A.
suponer(true, _).
suponer((A, B), Supuestos) :-
    suponer(A, Supuestos),
    suponer(B, Supuestos).
suponer(no(A), Supuestos) :-
    refutar(A, Supuestos).
suponer(A, Supuestos) :-
    abducible(A),
    buscar(A, Supuestos, verdadero).
suponer(A, Supuestos) :-
    regla(A, Cuerpo),
    suponer(Cuerpo, Supuestos).

%!  refutar(+Meta, ?Supuestos:list) is nondet.
%
%   Meta, sin variables, es falsa con la teoría y los Supuestos, que la
%   refutación amplía: una conjunción es falsa si lo es alguna de sus
%   partes, no(A) si A se prueba, un abducible si se supone falso, y un
%   átomo con reglas si se refuta el cuerpo de cada una. Un átomo sin
%   reglas que no es abducible es falso sin suponer nada.
refutar((A, B), Supuestos) :-
    !,
    (   refutar(A, Supuestos)
    ;   refutar(B, Supuestos)
    ).
refutar(no(A), Supuestos) :-
    !,
    suponer(A, Supuestos).
refutar(A, Supuestos) :-
    abducible(A),
    !,
    buscar(A, Supuestos, falso).
refutar(A, Supuestos) :-
    A \== true,
    findall(Cuerpo, regla(A, Cuerpo), Cuerpos),
    refutar_todos(Cuerpos, Supuestos).

%!  refutar_todos(+Cuerpos:list, ?Supuestos:list) is nondet.
%
%   Cada cuerpo de Cuerpos se refuta con los mismos Supuestos.
refutar_todos([], _).
refutar_todos([Cuerpo|Cuerpos], Supuestos) :-
    refutar(Cuerpo, Supuestos),
    refutar_todos(Cuerpos, Supuestos).

%!  cerrar(?Dic:list) is det.
%
%   Dic, un diccionario incompleto, queda cerrado: su final es [].
cerrar([]) :-
    !.
cerrar([_|Resto]) :-
    cerrar(Resto).
