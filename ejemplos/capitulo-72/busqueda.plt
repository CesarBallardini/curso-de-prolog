:- encoding(utf8).

% Un problema mínimo, definido en el módulo user, para probar que el puente
% delega en el módulo que se le indica: contar de Desde a Hasta sumando 1
% o 2, con costo 1 por paso.

%!  inicial(+Problema, -N:integer) is det.
%
%   cuenta(Desde, Hasta) empieza en Desde.
inicial(cuenta(Desde, _), Desde).

%!  meta(+Problema, +N:integer) is semidet.
%
%   cuenta(Desde, Hasta) termina en Hasta.
meta(cuenta(_, Hasta), Hasta).

%!  sucesor(+Problema, +N:integer, -Accion, -M:integer, -Costo) is nondet.
%
%   Desde N se suma 1 o 2, con costo 1, sin pasar de Hasta.
sucesor(cuenta(_, Hasta), N, mas(D), M, 1) :-
    member(D, [1, 2]),
    M is N + D,
    M =< Hasta.

%!  heuristica(+Problema, +N:integer, -H:integer) is det.
%
%   H es la mitad de lo que falta, redondeada hacia arriba.
heuristica(cuenta(_, Hasta), N, H) :-
    H is (Hasta - N + 1) // 2.

:- begin_tests(busqueda).

test(a_estrella, [true(C == 4)]) :-
    buscar(mejor(a_estrella), problema(user, cuenta(0, 7)), _, C, _).

test(plan, [true(P == [mas(2), mas(2), mas(2), mas(1)])]) :-
    buscar(mejor(a_estrella), problema(user, cuenta(0, 7)), P, _, _).

test(anchura, [true(C == 4)]) :-
    buscar(anchura, problema(user, cuenta(0, 7)), _, C, _).

test(ida_estrella, [true(C == 4)]) :-
    ida_estrella(problema(user, cuenta(0, 7)), _, C, _).

test(sin_plan, [fail]) :-
    buscar(mejor(a_estrella), problema(user, cuenta(5, 3)), _, _, _).

test(puzzle_intacto, [true(C == 8)]) :-
    buscar(mejor(a_estrella), puzzle([2, 4, 3, 7, 1, 5, 0, 8, 6], manhattan),
           _, C, _).

:- end_tests(busqueda).
