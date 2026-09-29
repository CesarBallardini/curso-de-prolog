:- encoding(utf8).

% Capítulo 43 - Los predicados del capítulo 32 que usa el programa que
% resuelve ecuaciones, reunidos en un módulo.
%
% Los archivos del capítulo 32 no son módulos: se cargan, con
% load_files/2 y el nombre de un módulo delante del archivo, dentro de un
% módulo propio. simplificar.pl y soluciones.pl (apariciones/3 y
% evaluar/3) van a este módulo; soluciones_simplificar.pl, que define
% derivar/3 y otra versión de simplificar/2, va a un módulo aparte para
% que las dos versiones no se reemplacen.
%
% solo-local: carga archivos de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- simplificar((x * 2) * 3, E).
%?- apariciones(x * x + 1 = 3 * x, x, N).
%?- derivar(x ^ 3 - 2 * x - 5, x, D).
%?- evaluar(x ^ 3 - 2 * x - 5, [x-2], V).

:- module(capitulo32,
          [ simplificar/2,
            apariciones/3,
            derivar/3,
            evaluar/3
          ]).

:- load_files(capitulo32:'../capitulo-32/simplificar', []).
:- load_files(capitulo32:'../capitulo-32/soluciones', []).
:- load_files(derivadas32:'../capitulo-32/soluciones_simplificar', []).

%!  derivar(+E, +X:atom, -D) is det.
%
%   D es la derivada simplificada de la expresión cerrada E respecto de X,
%   calculada por derivar/3 del capítulo 32: E usa +, -, * y ^ con
%   exponente numérico, y cualquier otra operación produce un error de
%   dominio.
derivar(E, X, D) :-
    derivadas32:derivar(E, X, D).
