:- encoding(utf8).

% Capítulo 48 - Solución del ejercicio 10: transistores CMOS.
%
% Un transistor es la relación de sus estados estables (Spivey, capítulo
% 12). Un transistor p conecta la fuente con el drenador cuando su
% compuerta está en 0, y entonces los dos tienen el mismo valor; con la
% compuerta en 1 no los conecta, y cada uno tiene cualquier valor. Un
% transistor n se comporta al revés.
%
%?- nand_cmos(1, 1, Z).
%?- inversor_cmos(X, X).

% ptran(F, G, D): estado estable de un transistor p con fuente F,
% compuerta G y drenador D.
ptran(X, 0, X).
ptran(_, 1, _).

% ntran(F, G, D): estado estable de un transistor n con fuente F,
% compuerta G y drenador D.
ntran(X, 1, X).
ntran(_, 0, _).

%!  inversor_cmos(?A, ?Z) is nondet.
%
%   Z es la salida del inversor CMOS con entrada A: un transistor p entre
%   el 1 y la salida, y uno n entre la salida y el 0.
inversor_cmos(A, Z) :-
    ptran(1, A, Z),
    ntran(Z, A, 0).

%!  nand_cmos(?A, ?B, ?Z) is nondet.
%
%   Z es la salida de la compuerta NAND CMOS con entradas A y B: dos
%   transistores p en paralelo entre el 1 y la salida, y dos n en serie
%   entre la salida y el 0, unidos por el cable interno W.
nand_cmos(A, B, Z) :-
    ptran(1, A, Z),
    ptran(1, B, Z),
    ntran(Z, A, W),
    ntran(W, B, 0).
