:- encoding(utf8).

% Capítulo 52 - El programa terminado.
%
% Carga la última versión, que vuelve a exportar las anteriores: el
% intérprete perezoso con alias y tablas, la biblioteca de funciones de
% configuración m de Turing, la traza, la expansión a la tabla completa y
% los números de descripción.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- figuras(ii, b, 15, Fs).
%?- figuras(contador, inicio, 15, Fs).
%?- cinta_de([schwa, schwa, 1, a, 0, a], 0, C0), ejecutar(biblioteca, ce(fin, a), C0, 1000, detenida(Q, C)), contenido(C, Ss).
%?- completa(contador, inicio, [0, 1, schwa], 1000, R).
%?- numero(i, b, [0, 1], N).

:- use_module(numeros).
