:- encoding(utf8).

% Capítulo 17 - Agregar: contar, sumar, el máximo, y comprobar para todos.
%
% aggregate_all/3 recorre las respuestas de un objetivo y calcula un valor
% sobre ellas, sin construir la lista. forall/2 comprueba que todas las
% respuestas de un objetivo cumplen una condición.
%
%?- mayor_edad(Quien, Edad).
%?- edad_promedio(Promedio).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  mayor_edad(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la mayor edad de la base, Edad. Con empate, la primera
%   persona. Falla si no hay ninguna edad registrada.
mayor_edad(Quien, Edad) :-
    aggregate_all(max(E, P), edad(P, E), max(Edad, Quien)).

%!  edad_promedio(-Promedio:number) is semidet.
%
%   Promedio es el promedio de las edades de la base. Falla si no hay
%   ninguna: el promedio de ninguna edad no existe.
edad_promedio(Promedio) :-
    aggregate_all(count, edad(_, _), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(E), edad(_, E), Suma),
    Promedio is Suma / Cantidad.

%!  todos_los_hijos_son_menores(+P) is semidet.
%
%   Todos los hijos de P son menores de 18 años. Se cumple también si P no
%   tiene hijos: no hay ninguno que no lo sea.
todos_los_hijos_son_menores(P) :-
    forall(padre(P, H),
           ( edad(H, E),
             E < 18 )).

%!  de_mayor_a_menor(-P, -E:integer) is multi.
%
%   Las personas de la base, de la mayor a la menor edad.
de_mayor_a_menor(P, E) :-
    order_by([desc(E)], edad(P, E)).

%!  los_dos_mayores(-P, -E:integer) is nondet.
%
%   Las dos personas de mayor edad, de la mayor a la menor.
los_dos_mayores(P, E) :-
    limit(2, de_mayor_a_menor(P, E)).
