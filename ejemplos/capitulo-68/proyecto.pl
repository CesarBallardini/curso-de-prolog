:- encoding(utf8).

% Capítulo 68 - El proyecto completo: el espacio de versiones con
% preguntas (versión 4) y la generalización basada en la explicación
% (versión 6). Las dos versiones definen inferencias/2 con el mismo
% significado; se usa el de la versión 4.
%
% solo-local: carga archivos de otros capítulos.
%
%?- traza(esfera_roja).
%?- aprender(taza, taza1, taza(taza1), R), mostrar(R).

:- use_module(preguntas).
:- use_module(ebg, except([inferencias/2])).
