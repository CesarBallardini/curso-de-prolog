:- encoding(utf8).

% Capítulo 48 - Soluciones de los ejercicios 10 y 14: la compuerta NAND CMOS
% y la XOR sin uno de los transistores del par en paralelo.
%
% Con los transistores de transistores.pl (Spivey, capítulo 12), la NAND
% tiene dos transistores p en paralelo y dos n en serie.
%
% solo-local: carga transistores.pl, y SWISH no carga otros archivos.
%
%?- nand_cmos(1, 1, Z).
%?- nand_cmos(A, B, Z).

:- ensure_loaded(transistores).

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

%!  xor_sin_par_p(?A, ?B, ?Z) is nondet.
%
%   La XOR de seis transistores de xor_cmos/3 sin el transistor p del par
%   en paralelo: cinco transistores.
xor_sin_par_p(A, B, Z) :-
    inversor_cmos(A, NA),
    ntran(B, NA, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).

%!  xor_sin_par_n(?A, ?B, ?Z) is nondet.
%
%   La XOR de seis transistores de xor_cmos/3 sin el transistor n del par
%   en paralelo: cinco transistores.
xor_sin_par_n(A, B, Z) :-
    inversor_cmos(A, NA),
    ptran(B, A, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).
