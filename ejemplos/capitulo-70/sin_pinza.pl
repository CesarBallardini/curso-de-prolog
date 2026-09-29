:- encoding(utf8).

% Capítulo 70 - Versión 4: el mundo sin pinza del capítulo 40, descrito
% desde sus operadores STRIPS.
%
% soluciones_strips.pl, la solución del ejercicio 10 del capítulo 40,
% describe el mundo de bloques sin pinza, con la acción mover(B, De, A)
% sin variables. Es el mundo de cubos.pl, con otra descripción. La
% traducción es la de pinza.pl, y el archivo trae también su planificador
% de medios y fines, en el módulo mfs.
%
% solo-local: carga ../capitulo-40/soluciones_strips.pl y warplan.pl.
%
%?- planificar(sin_pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan).
%?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).

:- module(sin_pinza,
          [ agrega/2,
            borra/2,
            puede/2,
            imposible/1,
            siempre/1,
            prueba/1,
            dado/2,
            medios_fines/3
          ]).

:- use_module(library(lists)).
:- reexport(warplan, [planificar/5]).
:- load_files(mfs:'../capitulo-40/soluciones_strips', [if(not_loaded)]).

%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que agrega el operador de Accion.
agrega(Hecho, Accion) :-
    mfs:operador(Accion, _, Agrega, _),
    member(Hecho, Agrega).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que borra el operador de Accion.
borra(Hecho, Accion) :-
    mfs:operador(Accion, _, _, Borra),
    member(Hecho, Borra).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Precondiciones son las del operador de Accion.
puede(Accion, Pre) :-
    mfs:operador(Accion, Pre, _, _).

% Los operadores del capítulo 40 no declaran combinaciones imposibles,
% hechos que valgan siempre ni pruebas: los tres predicados no tienen
% cláusulas.
:- dynamic imposible/1, siempre/1, prueba/1.

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio; sussman es el estado inicial
%   de la anomalía en el ejercicio 10 del capítulo 40.
dado(sussman, Hecho) :-
    mfs:sussman(Estado),
    member(Hecho, Estado).

%!  medios_fines(+Inicio, +Metas:list, -Plan:list) is semidet.
%
%   Plan es el primer plan que da el planificador de medios y fines del
%   capítulo 40, con su cota de longitud, desde el estado inicial Inicio.
medios_fines(sussman, Metas, Plan) :-
    mfs:sussman(Estado),
    once(mfs:planificar(Estado, Metas, Plan)).
