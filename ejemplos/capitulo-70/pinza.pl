:- encoding(utf8).

% Capítulo 70 - Versión 4: el mundo con pinza del capítulo 40, descrito
% desde sus operadores STRIPS.
%
% strips.pl, del capítulo 40, describe el mundo de bloques con pinza por
% operadores: operador(Accion, Pre, Agrega, Borra), con las acciones sin
% variables. Este módulo carga ese archivo en un módulo propio, mf, y
% traduce la descripción a la de WARPLAN: una acción agrega los hechos de
% su lista Agrega y borra los de su lista Borra. El archivo trae también
% el planificador de medios y fines del capítulo 40; medios_fines/3 lo
% ejecuta desde el mismo estado inicial, y planificar/5 es el de
% warplan.pl: los dos planificadores trabajan sobre el mismo mundo.
%
% solo-local: carga ../capitulo-40/strips.pl y warplan.pl.
%
%?- planificar(pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan).
%?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).

:- module(pinza,
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
:- load_files(mf:'../capitulo-40/strips', [if(not_loaded)]).

%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que agrega el operador de Accion.
agrega(Hecho, Accion) :-
    mf:operador(Accion, _, Agrega, _),
    member(Hecho, Agrega).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que borra el operador de Accion.
borra(Hecho, Accion) :-
    mf:operador(Accion, _, _, Borra),
    member(Hecho, Borra).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Precondiciones son las del operador de Accion.
puede(Accion, Pre) :-
    mf:operador(Accion, Pre, _, _).

% Los operadores del capítulo 40 no declaran combinaciones imposibles,
% hechos que valgan siempre ni pruebas: los tres predicados no tienen
% cláusulas.
:- dynamic imposible/1, siempre/1, prueba/1.

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio; sussman es el estado inicial
%   de la anomalía en el capítulo 40.
dado(sussman, Hecho) :-
    mf:sussman(Estado),
    member(Hecho, Estado).

%!  medios_fines(+Inicio, +Metas:list, -Plan:list) is semidet.
%
%   Plan es el primer plan que da el planificador de medios y fines del
%   capítulo 40, con su cota de longitud, desde el estado inicial Inicio.
medios_fines(sussman, Metas, Plan) :-
    mf:sussman(Estado),
    once(mf:planificar(Estado, Metas, Plan)).
