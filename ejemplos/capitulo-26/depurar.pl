:- encoding(utf8).

% Capítulo 26 - Depurar sin el depurador: debug/3, assertion/1, y la
% depuración declarativa.
%
% promedio_mal/2 tiene un error plantado: responde 5 para [6, 9], en lugar de
% 7.5. abuelo_mal/2 tiene otro: no encuentra ningún nieto. El capítulo los
% encuentra de dos formas: con el depurador, y preguntando a las partes.
%
%?- promedio_mal([6, 9], P).
%?- contar_y_sumar_mal(9, 1-6, R).

:- use_module(library(debug)).

% --- Una respuesta incorrecta ----------------------------------------------

%!  promedio_mal(+Notas:list(number), -Promedio:number) is semidet.
%
%   Debería ser el promedio de Notas; tiene un error plantado en
%   contar_y_sumar_mal/3.
promedio_mal(Notas, Promedio) :-
    foldl(contar_y_sumar_mal, Notas, 0-0, Cantidad-Suma),
    debug(promedio, "cantidad ~w, suma ~w", [Cantidad, Suma]),
    Cantidad > 0,
    Promedio is Suma / Cantidad.

%!  contar_y_sumar_mal(+Nota:number, +Hasta:pair, -Total:pair) is det.
%
%   Debería ser el par Cantidad-Suma de Hasta con Nota agregada. El error: la
%   suma parte de la cantidad anterior, C0, en lugar de la suma anterior, S0.
contar_y_sumar_mal(Nota, C0-_S0, C-S) :-
    C is C0 + 1,
    S is C0 + Nota.

% --- Una respuesta que falta ------------------------------------------------

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  abuelo_mal(?A, ?N) is nondet.
%
%   Debería ser: A es abuelo de N. El error: el segundo objetivo tiene los
%   argumentos invertidos.
abuelo_mal(A, N) :-
    padre(A, P),
    padre(N, P).

:- op(920, fy, *).

%!  *(+Objetivo) is det.
%
%   Tacha Objetivo: *G se cumple siempre, sin ejecutar G. Un objetivo tachado
%   se quita de una cláusula sin borrarlo, para ver si el error depende de él.
*(_).

%!  abuelo_recortado(?A, ?N) is nondet.
%
%   abuelo_mal/2 con el segundo objetivo tachado: si abuelo_recortado(juan,
%   luis) se cumple, el error está en el objetivo tachado.
abuelo_recortado(A, N) :-
    padre(A, P),
    * padre(N, P).

% --- Aserciones -------------------------------------------------------------

%!  nota_valida(+N) is det.
%
%   Comprueba con assertion/1 que N es una nota de 1 a 10. Una aserción que
%   no se cumple indica un error del programa, no de los datos.
nota_valida(N) :-
    assertion(integer(N)),
    assertion(between(1, 10, N)).
