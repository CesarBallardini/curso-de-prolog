:- encoding(utf8).

% Capítulo 72 - El ta-te-ti del capítulo 42, en un módulo.
%
% tateti.pl del capítulo 42 no es un módulo: se carga dentro del módulo
% capitulo42, sin copiarlo, y este archivo exporta los predicados del
% juego que usa juego.pl y ganada/2, la posición ganada decidida
% recorriendo el árbol de la partida.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)).

:- module(capitulo42,
          [ jugada/4,
            fin/3,
            ganada/2
          ]).

:- load_files(capitulo42:'../capitulo-42/tateti', []).
