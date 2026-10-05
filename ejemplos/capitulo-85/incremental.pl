:- encoding(utf8).

% Capítulo 85 - Versión 5: hechos que llegan después.
%
% Un estado guarda las variantes de las reglas, una por cada literal
% positivo del cuerpo, y la base, que ya es un punto fijo. Agregar hechos
% es un paso semi-ingenuo más: los hechos que no estaban son los nuevos, y
% cada regla se evalúa tomando de ellos el literal de alguna posición; lo
% que derivan es nuevo a su vez, y así hasta que no hay nada nuevo. Solo
% se recorre lo que cambió. La evaluación inicial es el mismo caso,
% agregar todos los hechos a la base vacía. Sirve para programas sin
% negación: con una negación, un hecho nuevo puede invalidar algo ya
% derivado, y el paso semi-ingenuo solo agrega.
%
% solo-local: es un módulo que carga otros.
%
%?- iniciar([(arco(a, b) :- true), (camino(X, Y) :- arco(X, Y)), (camino(X, Y) :- camino(X, Z), arco(Z, Y))], E, C), agregar_hechos([arco(b, c)], E, E1, C1), modelo_estado(E1, M).

:- module(incremental,
          [ iniciar/3,
            agregar_hechos/4,
            modelo_estado/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(motor).

%!  iniciar(+Clausulas:list, -Estado, -Costo) is det.
%
%   Estado tiene las reglas de Clausulas, un programa Datalog seguro sin
%   negación, y su modelo mínimo, calculado agregando los hechos a la base
%   vacía con agregar_hechos/4. Costo, el de ese cálculo. Error de dominio
%   si el programa no es seguro o tiene una negación.
iniciar(Clausulas, Estado, Costo) :-
    exigir_definido(Clausulas),
    separar(Clausulas, Hechos, Reglas),
    findall(Ind,
            ( member(r(_, Ls), Reglas),
              member(L, Ls),
              functor(L, Nombre, Aridad),
              Ind = Nombre/Aridad ),
            Is),
    sort(Is, Predicados),
    variantes(Reglas, Predicados, Variantes),
    empty_assoc(Vacia),
    agregar_hechos(Hechos, estado(Variantes, Vacia), Estado, Costo).

%!  agregar_hechos(+Hechos:list, +Estado0, -Estado, -Costo) is det.
%
%   Estado tiene la base de Estado0 con los Hechos, sin variables, y todo
%   lo que se deriva de ellos, hasta el punto fijo. Costo es costo(Pasos,
%   Derivaciones) de los pasos semi-ingenuos que hicieron falta.
agregar_hechos(Hechos, estado(Variantes, Base0),
               estado(Variantes, Base), Costo) :-
    agregar(Hechos, Base0, Base1, Nuevos),
    iterar(Variantes, Base0, Base1, Nuevos, Base, costo(0, 0), Costo).

%!  modelo_estado(+Estado, -Modelo:list) is det.
%
%   Modelo son los átomos de la base de Estado, ordenados.
modelo_estado(estado(_, Base), Modelo) :-
    atomos(Base, Modelo).
