:- encoding(utf8).

% Capítulo 77 - La cueva y el agente del capítulo 20, en un módulo.
%
% wumpus.pl del capítulo 20 no es un módulo: se carga con load_files/2 y
% el nombre de un módulo delante del archivo, sin copiarlo. De él se usan
% los hechos de la cueva de la figura 7.2 de Russell y Norvig y el agente
% que explora solo las celdas que prueba seguras.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- cueva_20(Pozos, Wumpus, Oro).
%?- explorar(Resultado), recorrido(Celdas).

:- module(capitulo20,
          [ cueva_20/3,
            explorar/1,
            recorrido/1
          ]).

:- load_files(capitulo20:'../capitulo-20/wumpus', []).

%!  cueva_20(-Pozos:list, -Wumpus, -Oro) is det.
%
%   Pozos son las celdas con pozos de la cueva del capítulo 20, en orden, y
%   Wumpus y Oro las celdas del wumpus y del oro.
cueva_20(Pozos, Wumpus, Oro) :-
    findall(C, pozo(C), Pozos0),
    sort(Pozos0, Pozos),
    once(wumpus(Wumpus)),
    once(oro(Oro)).
