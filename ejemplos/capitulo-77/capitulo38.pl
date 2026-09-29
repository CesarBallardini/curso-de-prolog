:- encoding(utf8).

% Capítulo 77 - La evaluación de abajo hacia arriba del capítulo 38, en
% un módulo.
%
% semantica.pl del capítulo 38 no es un módulo: se carga con load_files/2
% y el nombre de un módulo delante del archivo, sin copiarlo. De él se usa
% modelo_estandar_de/2, que recibe un programa estratificado como una
% lista de cláusulas Cabeza :- Cuerpo, con negaciones y comparaciones
% aritméticas, y calcula su modelo estándar estrato por estrato, con la
% evaluación semi-ingenua.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- modelo_estandar_de([(p :- true), (q :- p, \+ r)], M).

:- module(capitulo38,
          [ modelo_estandar_de/2
          ]).

:- load_files(capitulo38:'../capitulo-38/semantica', []).
