:- encoding(utf8).

% Capítulo 8 - Evaluación aritmética y comparaciones.
%
% is/2 evalúa una expresión y liga el resultado. Los operadores de comparación
% operan sobre dos valores ya instanciados. Ninguno de los dos genera valores
% para las variables libres.
%
%?- edad_en_meses(eva, Meses).
%?- mayor_de_edad(Quien).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).

%!  edad_en_meses(?P, -M) is nondet.
%
%   M es la edad de P expresada en meses.
edad_en_meses(P, M) :-
    edad(P, A),
    M is A * 12.

%!  mayor_de_edad(?P) is nondet.
%
%   P tiene 18 años o más.
mayor_de_edad(P) :-
    edad(P, A),
    A >= 18.

%!  diferencia_de_edad(?A, ?B, -D) is nondet.
%
%   D es la diferencia de edad entre A y B, en años.
diferencia_de_edad(A, B, D) :-
    edad(A, EdadA),
    edad(B, EdadB),
    EdadA >= EdadB,
    D is EdadA - EdadB.

%!  promedio_de_edad(?A, ?B, -P) is nondet.
%
%   P es el promedio de las edades de A y B.
promedio_de_edad(A, B, P) :-
    edad(A, EdadA),
    edad(B, EdadB),
    P is (EdadA + EdadB) / 2.

%!  misma_decada(?A, ?B) is nondet.
%
%   Las edades de A y B están en la misma década.
misma_decada(A, B) :-
    edad(A, EdadA),
    edad(B, EdadB),
    EdadA // 10 =:= EdadB // 10.

%!  doble(+N, -D) is det.
%
%   D es el doble de N. Muestra el comportamiento de is/2 cuando N no está
%   instanciada.
doble(N, D) :-
    D is N * 2.
