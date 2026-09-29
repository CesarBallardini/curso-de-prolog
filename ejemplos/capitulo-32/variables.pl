:- encoding(utf8).

% Capítulo 32 - Variables como datos: copy_term/2, term_variables/2, la
% comparación de variables y numbervars/3.
%
% Una función se representa como un término fn(X, Cuerpo), con la variable
% X en el cuerpo. Aplicarla liga X; para aplicarla más de una vez, cada
% aplicación trabaja sobre una copia con variables nuevas.
%
%?- cuadrado(F), evaluar_en(F, 2, A), evaluar_en(F, 3, B).
%?- variables_de(f(X, g(Y, X)), N).
%?- escribir_con_nombres(f(X, g(Y, X))).

% cuadrado(F): F es la función que eleva al cuadrado.
cuadrado(fn(X, X * X)).

%!  evaluar_en_ingenuo(+F, +A:number, -V:number) is semidet.
%
%   V es el valor de la función F en A. Liga la variable de F, de modo que
%   la misma F no se puede aplicar a otro valor.
evaluar_en_ingenuo(F, A, V) :-
    F = fn(X, Cuerpo),
    X = A,
    V is Cuerpo.

%!  evaluar_en(+F, +A:number, -V:number) is det.
%
%   V es el valor de la función F en A. Aplica una copia de F, así que F no
%   cambia.
evaluar_en(F, A, V) :-
    copy_term(F, fn(X, Cuerpo)),
    X = A,
    V is Cuerpo.

%!  variables_de(@Termino, -N:integer) is det.
%
%   N es la cantidad de variables distintas de Termino.
variables_de(T, N) :-
    term_variables(T, Vs),
    length(Vs, N).

%!  escribir_con_nombres(@Termino) is det.
%
%   Escribe Termino con sus variables nombradas A, B, C… en el orden en que
%   aparecen. Termino no queda ligado: la doble negación deshace las
%   ligaduras de numbervars/3.
escribir_con_nombres(T) :-
    \+ \+ ( numbervars(T, 0, _),
            print(T),
            nl ).
