:- encoding(utf8).

% Capítulo 13 - Unificadores.
%
% Este archivo no define predicados: reúne las consultas con = de las
% secciones 13.8 y 13.9, para que las transcripciones del texto se ejecuten
% sobre un archivo del capítulo. Cada consulta muestra el unificador más
% general de dos términos, o informa que no existe ninguno. Las pruebas
% comprueban las mismas ligaduras.
%
%?- padre(Z, diego) = padre(jorge, diego).
%?- tio(X, diego) = tio(W, diego).
%?- p(q(X, Y), X, h(4)) = p(q(3, Z), W, h(Z)).
%?- r([X|Y]) = r([[a, b], c, d]).
%?- r([X|Y]) = r([]).
%?- [[X, 2], [Y]] = [A|[B|C]].
%?- T = abuelo(A, N), A = juan, N = Quien.
