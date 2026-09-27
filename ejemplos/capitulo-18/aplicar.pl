:- encoding(utf8).

% Capítulo 18 - Un predicado como argumento: call/N, maplist, foldl, include
% y las lambdas de library(yall).
%
% Cada predicado de este archivo recibe el nombre de otro predicado, o un
% objetivo al que le faltan argumentos, y lo llama con call/N.
%
%?- cumplen(mayor_de_edad, Personas).
%?- edades([juan, ana, eva], Edades).
%?- suma_de_edades([juan, ana, eva], Suma).

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

%!  mayor_de_edad(?P) is nondet.
%
%   P tiene 18 años o más.
mayor_de_edad(P) :-
    edad(P, E),
    E >= 18.

%!  menor_de_edad(?P) is nondet.
%
%   P tiene menos de 18 años.
menor_de_edad(P) :-
    edad(P, E),
    E < 18.

%!  cumplen(:Condicion, -Personas:list) is det.
%
%   Personas son las personas de la base que cumplen Condicion, un predicado
%   de un argumento.
cumplen(Condicion, Personas) :-
    findall(P, ( edad(P, _), call(Condicion, P) ), Personas).

%!  edades(?Personas:list, ?Edades:list(integer)) is nondet.
%
%   Edades son las edades de Personas, en el mismo orden. Con Personas
%   ligada hay una respuesta.
edades(Personas, Edades) :-
    maplist(edad, Personas, Edades).

%!  todos_mayores(+Personas:list) is semidet.
%
%   Todas las Personas son mayores de edad.
todos_mayores(Personas) :-
    maplist(mayor_de_edad, Personas).

%!  mostrar_edades(+Personas:list) is semidet.
%
%   Escribe una línea por persona, con su edad. Falla, después de escribir las
%   anteriores, en la primera persona sin edad registrada.
mostrar_edades(Personas) :-
    maplist(mostrar_edad, Personas).

%!  mostrar_edad(+P) is semidet.
%
%   Escribe el nombre y la edad de P. Falla si P no tiene edad registrada.
mostrar_edad(P) :-
    edad(P, E),
    format("~w: ~d~n", [P, E]).

%!  suma_de_edades(+Personas:list, -Suma:integer) is semidet.
%
%   Suma es la suma de las edades de Personas.
suma_de_edades(Personas, Suma) :-
    edades(Personas, Edades),
    foldl(sumar, Edades, 0, Suma).

%!  sumar(+X:number, +Hasta:number, -Total:number) is det.
%
%   Total es Hasta más X: el paso de foldl/4 recibe primero el elemento y
%   después el valor acumulado.
sumar(X, Hasta, Total) :-
    Total is Hasta + X.

%!  mayor(+L:list(number), -Mayor:number) is semidet.
%
%   Mayor es el mayor elemento de L. Falla con la lista vacía, que no tiene
%   mayor elemento.
mayor([Primero|Resto], Mayor) :-
    foldl(el_mayor, Resto, Primero, Mayor).

%!  el_mayor(+X:number, +Hasta:number, -Mayor:number) is det.
%
%   Mayor es el mayor entre X y Hasta.
el_mayor(X, Hasta, Mayor) :-
    Mayor is max(X, Hasta).

%!  separar_por_edad(+Personas:list, -Mayores:list, -Menores:list) is det.
%
%   Mayores son las Personas mayores de edad y Menores las demás, cada una en
%   el orden de Personas.
separar_por_edad(Personas, Mayores, Menores) :-
    partition(mayor_de_edad, Personas, Mayores, Menores).

%!  edades_conocidas(+Personas:list, -Edades:list(integer)) is det.
%
%   Edades son las edades de las Personas que la tienen registrada; las demás
%   se omiten.
edades_conocidas(Personas, Edades) :-
    convlist(edad, Personas, Edades).

%!  sumar_a_todos(+N:number, +L:list(number), -R:list(number)) is det.
%
%   R es la lista de los elementos de L más N. {N} declara que la lambda
%   comparte N con la cláusula.
sumar_a_todos(N, L, R) :-
    maplist({N}/[X, Y]>>(Y is X + N), L, R).

%!  mayores_que(+Umbral:integer, +Personas:list, -Mayores:list) is det.
%
%   Mayores son las Personas cuya edad supera Umbral. Umbral se comparte con
%   la cláusula; E es local a la lambda y toma un valor para cada persona.
mayores_que(Umbral, Personas, Mayores) :-
    include({Umbral}/[P]>>( edad(P, E), E > Umbral ), Personas, Mayores).
