:- encoding(utf8).

% Capítulo 12 - Ejercicio 13: agencia de viajes.
%
% Un tour es una permutación de las ciudades elegidas en la que no se vuelve
% a ingresar a un país del que ya se salió.
%
%?- tour([roma, atenas, venecia], T).

% ciudad(C, P): la ciudad C pertenece al país P.
ciudad(dresde, alemania).
ciudad(basilea, suiza).
ciudad(roma, italia).
ciudad(hamburgo, alemania).
ciudad(atenas, grecia).
ciudad(venecia, italia).
ciudad(colonia, alemania).
ciudad(viena, austria).
ciudad(florencia, italia).
ciudad(munich, alemania).
ciudad(berna, suiza).

%!  selecciona(?X, +Xs, ?Ys) is nondet.
%!  selecciona(?X, ?Xs, +Ys) is nondet.
%
%   Ys es Xs sin una de las apariciones de X: una respuesta por cada
%   aparición. Con Ys dada y Xs libre, inserta X en cada posición de Ys.
selecciona(X, [X|Xs], Xs).
selecciona(X, [Y|Ys], [Y|Zs]) :-
    selecciona(X, Ys, Zs).

%!  permuta(+Xs, ?Ys) is nondet.
%
%   Ys es una permutación de Xs: elige el primer elemento con selecciona/3 y
%   permuta el resto. Una lista de n elementos distintos da n! respuestas.
permuta([], []).
permuta(Xs, [Z|Zs]) :-
    selecciona(Z, Xs, Ys),
    permuta(Ys, Zs).

%!  tour(+Lista, ?Tour) is nondet.
%
%   Tour tiene las ciudades de Lista en un orden que no vuelve a ingresar a
%   ningún país: no hay en Tour dos ciudades de un mismo país con una ciudad
%   de otro país entre ellas.
tour(Lista, Tour) :-
    permuta(Lista, Tour),
    \+ reingresa(Tour).

%!  reingresa(+Tour) is semidet.
%
%   En Tour hay una ciudad X, después una ciudad Y de otro país y después una
%   ciudad Z del país de X.
reingresa(Tour) :-
    append(_, [X|Despues], Tour),
    append(Medio, [Z|_], Despues),
    member(Y, Medio),
    ciudad(X, Pais),
    ciudad(Z, Pais),
    ciudad(Y, Otro),
    Otro \== Pais.
