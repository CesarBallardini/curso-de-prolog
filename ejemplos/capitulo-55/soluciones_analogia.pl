:- encoding(utf8).

% Capítulo 55 - Solución del ejercicio 9: ANALOGY con diagramas anidados.
%
% en_exterior(Op) aplica la operación Op a la segunda parte de una
% relación, que puede ser a su vez una relación. La cláusula se agrega a
% transformacion/3, que analogia.pl declara multifile, igual que el
% problema nuevo.
%
% solo-local: carga analogia.pl, y SWISH no permite cargar otro archivo.
%
%?- resolver(anidado, N, Ops).

:- ensure_loaded(analogia).

transformacion(en_exterior(Op), D1, D2) :-
    partes(D1, R, A, B),
    transformacion(Op, B, B2),
    partes(D2, R, A, B2).

problema(anidado, dentro(circulo, encima(cuadrado, triangulo)),
         dentro(circulo, encima(triangulo, cuadrado)),
         dentro(rombo, encima(circulo, cuadrado)),
         [dentro(rombo, encima(circulo, cuadrado)),
          dentro(rombo, encima(cuadrado, circulo)),
          encima(circulo, cuadrado)]).
