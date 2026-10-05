:- encoding(utf8).

% Capítulo 85 - El motor completo.
%
% Reúne las cinco versiones: seguro.pl (los programas que se aceptan),
% motor.pl (la base indexada y la evaluación semi-ingenua), estratos.pl
% (las componentes y la negación), magia.pl (las consultas y la
% transformación mágica) e incremental.pl (los hechos que llegan después),
% y los evaluadores del capítulo 38, con los que se compara. Agrega los
% programas del capítulo a clausulas/2 del capítulo 38, que nombra cada
% programa, y las formas que reciben el nombre del programa en lugar de la
% lista de sus cláusulas: modelo/3, consulta/4, consulta_magica/4 y
% agregar_a/4.
%
% solo-local: es un módulo que carga otros.
%
%?- modelo(nilsson, M, C).
%?- consulta_magica(cadena(40), camino(0, Y), Rs, C).
%?- mostrar_magico(nilsson, path(a, Y)).

:- module(datalog,
          [ modelo/3,
            consulta/4,
            consulta_magica/4,
            agregar_a/4,
            mostrar_magico/2
          ]).

:- reexport(seguro).
:- reexport(motor).
:- reexport(estratos).
:- reexport(magia).
:- reexport(incremental).
:- reexport(semantica38).

:- use_module(library(lists)).
:- use_module(library(listing), [portray_clause/1]).

% Los programas del capítulo se agregan a generado/2 del capítulo 38, que
% es multifile, con el módulo delante.
:- multifile capitulo38:generado/2.

%!  capitulo38:generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de este capítulo: nilsson, el del ejemplo 15.1 de
%   Nilsson y Małuszyński, y fila(N), los N arcos de cadena/2 con camino/2
%   recursivo a la derecha.
capitulo38:generado(nilsson,
                    [ (edge(a, b) :- true), (edge(b, a) :- true),
                      (path(X, Y) :- edge(X, Y)),
                      (path(X, Y) :- path(X, Z), edge(Z, Y)) ]).
capitulo38:generado(fila(N), Clausulas) :-
    capitulo38:cadena(N, Cadena),
    include(es_arco, Cadena, Arcos),
    append(Arcos,
           [ (camino(X, Y) :- arco(X, Y)),
             (camino(X, Y) :- arco(X, Z), camino(Z, Y)) ],
           Clausulas).

% es_arco(C): C es un hecho arco/2.
es_arco(arco(_, _) :- true).

%!  modelo(+Programa, -Modelo:list, -Costo) is det.
%
%   evaluar/3 sobre las cláusulas del programa llamado Programa.
modelo(Programa, Modelo, Costo) :-
    clausulas(Programa, Clausulas),
    evaluar(Clausulas, Modelo, Costo).

%!  consulta(+Programa, +Meta, -Respuestas:list, -Costo) is det.
%
%   respuestas/4 sobre las cláusulas del programa llamado Programa.
consulta(Programa, Meta, Respuestas, Costo) :-
    clausulas(Programa, Clausulas),
    respuestas(Clausulas, Meta, Respuestas, Costo).

%!  consulta_magica(+Programa, +Meta, -Respuestas:list, -Costo) is det.
%
%   respuestas_magicas/4 sobre las cláusulas del programa llamado
%   Programa.
consulta_magica(Programa, Meta, Respuestas, Costo) :-
    clausulas(Programa, Clausulas),
    respuestas_magicas(Clausulas, Meta, Respuestas, Costo).

%!  agregar_a(+Programa, +Hechos:list, -Costo, -Modelo:list) is det.
%
%   Modelo es el del programa llamado Programa, sin negación, después de
%   agregarle los Hechos con agregar_hechos/4; Costo, el de agregarlos.
agregar_a(Programa, Hechos, Costo, Modelo) :-
    clausulas(Programa, Clausulas),
    iniciar(Clausulas, Estado0, _),
    agregar_hechos(Hechos, Estado0, Estado, Costo),
    modelo_estado(Estado, Modelo).

%!  mostrar_magico(+Programa, +Meta) is det.
%
%   Escribe, una por línea, las cláusulas que magico/3 produce para el
%   programa llamado Programa y la consulta Meta, sin los hechos de los
%   predicados sin reglas.
mostrar_magico(Programa, Meta) :-
    clausulas(Programa, Clausulas),
    magico(Clausulas, Meta, Transformado),
    forall(( member(C, Transformado),
             \+ memberchk(C, Clausulas) ),
           portray_clause(C)).
