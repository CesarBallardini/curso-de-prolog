:- encoding(utf8).

% Capítulo 71 - El ta-te-ti del capítulo 41, en un módulo.
%
% tateti.pl del capítulo 41 no es un módulo: se carga dentro del módulo
% capitulo41, sin copiarlo, y este archivo exporta los predicados del
% juego que usa juego.pl y ganada/2, la posición ganada decidida
% recorriendo el árbol de la partida.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)).

:- module(capitulo41,
          [ jugada/4,
            fin/3,
            ganada/2
          ]).

:- load_files(capitulo41:'../capitulo-41/tateti', []).
