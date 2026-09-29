:- encoding(utf8).

% Capítulo 68 - Las teorías del dominio y los ejemplos que explican.
%
% Una teoría es un conjunto de reglas, cada una un término Cabeza :-
% Cuerpo. La teoría taza dice qué hace falta para que un objeto sirva de
% taza: poder levantarlo, que contenga un líquido y que se apoye firme.
% La teoría familia son las reglas del capítulo 3, leídas con clause/2 del
% módulo familia3 en el que las carga el capítulo 67: no se copian.
%
% Un ejemplo se describe con una lista de hechos sin variables. La teoría
% y la descripción están separadas: la teoría no tiene hechos de ningún
% objeto, y la descripción no tiene reglas. Los predicados operacionales
% de una teoría son los que se pueden verificar directamente en la
% descripción de un ejemplo.
%
% solo-local: carga familia.pl del capítulo 67, que carga archivos de
% otros capítulos.
%
%?- regla(taza, R).
%?- hechos(taza1, Hs), length(Hs, N).

:- module(teorias,
          [ regla/2,
            hechos/2,
            operacionales/2,
            poblacion/1
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module('../capitulo-67/familia', [modelo_fondo/1]).

%!  regla(?T, -R) is nondet.
%
%   R es una regla de la teoría T: un término Cabeza :- Cuerpo.
regla(taza, (taza(X) :- se_levanta(X), contiene_liquido(X), estable(X))).
regla(taza, (se_levanta(X) :- liviano(X), tiene_asa(X))).
regla(taza, (liviano(X) :- peso(X, P), P < 400)).
regla(taza, (liviano(X) :- material(X, carton))).
regla(taza, (tiene_asa(X) :- parte(X, A), asa(A))).
regla(taza, (contiene_liquido(X) :- parte(X, R), concava(R),
                                     abierta_arriba(R))).
regla(taza, (estable(X) :- parte(X, B), base(B), plana(B))).
regla(familia, (Cabeza :- Cuerpo)) :-
    member(Cabeza, [progenitor(_, _), abuelo(_, _), abuela(_, _)]),
    clause(familia3:Cabeza, Cuerpo).

%!  hechos(+E, -Hs:list) is det.
%
%   Hs es la descripción del ejemplo E: taza1, una taza de loza; taza2,
%   una taza de cartón sin peso conocido; vaso1, un vaso sin asa; o
%   familia, el modelo mínimo de la familia de los capítulos 2 y 3.
hechos(taza1, [ peso(taza1, 300), material(taza1, loza),
                color(taza1, blanco), parte(taza1, asa1), asa(asa1),
                parte(taza1, cuerpo1), concava(cuerpo1),
                abierta_arriba(cuerpo1), color(cuerpo1, blanco),
                parte(taza1, base1), base(base1), plana(base1)
              ]).
hechos(taza2, [ material(taza2, carton), color(taza2, rojo),
                parte(taza2, asa2), asa(asa2), parte(taza2, cuerpo2),
                concava(cuerpo2), abierta_arriba(cuerpo2),
                parte(taza2, base2), base(base2), plana(base2)
              ]).
hechos(vaso1, [ peso(vaso1, 200), material(vaso1, vidrio),
                parte(vaso1, cuerpo3), concava(cuerpo3),
                abierta_arriba(cuerpo3), parte(vaso1, base3),
                base(base3), plana(base3)
              ]).
hechos(familia, M) :-
    modelo_fondo(M).

% operacionales(T, Ps): Ps son los predicados operacionales de la teoría T.
operacionales(taza, [ peso/2, material/2, color/2, parte/2, asa/1,
                      concava/1, abierta_arriba/1, base/1, plana/1 ]).
operacionales(familia, [varon/1, mujer/1, padre/2, madre/2]).

%!  poblacion(-Os:list) is det.
%
%   Os es una lista de pares Objeto-Hechos: 48 objetos que combinan un
%   peso (150, 900 o desconocido), un material (loza o carton), la
%   presencia del asa, un cuerpo abierto arriba o cerrado, y una base
%   plana o redonda.
poblacion(Os) :-
    findall(Pesos-Mat-Asa-Abierto-Base,
            ( member(Pesos, [[150], [900], []]),
              member(Mat, [loza, carton]),
              member(Asa, [si, no]),
              member(Abierto, [si, no]),
              member(Base, [plana, redonda]) ),
            Combinaciones),
    foldl(objeto, Combinaciones, Os, 1, _).

%!  objeto(+Combinacion, -O, +N0:integer, -N:integer) is det.
%
%   O es el par Objeto-Hechos del objeto número N0 con las características
%   de Combinacion, y N es N0 + 1.
objeto(Pesos-Mat-Asa-Abierto-Base, Obj-Hechos, N0, N) :-
    N is N0 + 1,
    format(atom(Obj), "o~d", [N0]),
    format(atom(A), "a~d", [N0]),
    format(atom(C), "c~d", [N0]),
    format(atom(B), "b~d", [N0]),
    findall(peso(Obj, P), member(P, Pesos), Peso),
    (   Asa == si
    ->  ConAsa = [parte(Obj, A), asa(A)]
    ;   ConAsa = []
    ),
    (   Abierto == si
    ->  Cuerpo = [parte(Obj, C), concava(C), abierta_arriba(C)]
    ;   Cuerpo = [parte(Obj, C), concava(C)]
    ),
    append([ Peso, [material(Obj, Mat)], ConAsa, Cuerpo,
             [parte(Obj, B), base(B)] ], Hechos0),
    (   Base == plana
    ->  append(Hechos0, [plana(B)], Hechos)
    ;   Hechos = Hechos0
    ).
