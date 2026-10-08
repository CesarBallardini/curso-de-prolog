:- encoding(utf8).

% Capítulo 15 - El condicional: casos que no se superponen, sin corte rojo.
%
% Los predicados del capítulo 9 que usaban el corte para elegir un caso,
% reescritos con ( Condicion -> Entonces ; Si_no ). La salida se liga dentro
% de cada rama, después de la condición: los predicados son estables y no
% dejan alternativas pendientes.
%
%?- categoria(sofia, C).
%?- sacar(a, [a, b, a], R).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

%!  categoria(?P, ?C) is nondet.
%!  categoria(+P, ?C) is semidet.
%
%   C es la categoría de P según su edad: bebe, chico o adulto. Con P ligada
%   hay una respuesta, o ninguna si P no tiene edad registrada.
categoria(P, C) :-
    edad(P, A),
    (   A < 4
    ->  C = bebe
    ;   A < 13
    ->  C = chico
    ;   C = adulto
    ).

%!  signo(+N:number, -S:atom) is det.
%!  signo(+N:number, +S:atom) is semidet.
%
%   S es negativo, cero o positivo, según N.
signo(N, S) :-
    (   N < 0
    ->  S = negativo
    ;   N =:= 0
    ->  S = cero
    ;   S = positivo
    ).

%!  sacar(+X, +L:list, -R:list) is semidet.
%
%   R es L sin la primera aparición de X; falla si X no está en L. El
%   condicional elige una de las dos ramas y no deja la otra pendiente.
sacar(X, [Y|Ys], R) :-
    (   X == Y
    ->  R = Ys
    ;   R = [Y|R0],
        sacar(X, Ys, R0)
    ).

%!  sin_repetidos(++L:list, -R:list) is det.
%
%   R es L sin repetidos; conserva la primera aparición de cada elemento.
sin_repetidos(L, R) :-
    sin_los_vistos(L, [], R).

%!  sin_los_vistos(++L:list, +Vistos:list, -R:list) is det.
%
%   R es L sin los elementos de Vistos y sin repetidos. memberchk/2 se cumple
%   a lo sumo una vez: equivale a member/2 seguido de un corte.
sin_los_vistos([], _, []).
sin_los_vistos([X|Resto], Vistos, R) :-
    (   memberchk(X, Vistos)
    ->  R = R0
    ;   R = [X|R0]
    ),
    sin_los_vistos(Resto, [X|Vistos], R0).

%!  primer_mayor_de_edad(-P) is semidet.
%
%   P es la primera persona mayor de edad de la base, y solo ella.
primer_mayor_de_edad(P) :-
    once(( edad(P, A),
           A >= 18 )).

%!  presentar(+P) is det.
%
%   Escribe el nombre de P y, si se conoce, su edad. ignore/1 ejecuta el
%   objetivo opcional y se cumple aunque ese objetivo falle.
presentar(P) :-
    format("~w", [P]),
    ignore(( edad(P, A),
             format(" (~d años)", [A]) )),
    nl.
