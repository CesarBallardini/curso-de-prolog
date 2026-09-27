:- encoding(utf8).

% Capítulo 22 - Dicts y opciones.
%
% Un dict reúne valores con nombre: _{nombre: ana, edad: 41}. persona/2
% construye el dict de una persona, y cumple_anios/2 da uno nuevo con la edad
% siguiente. presentar/3 recibe una lista de opciones, con valores por
% omisión para las que faltan. Los dicts son propios de SWI-Prolog.
%
%?- persona(ana, D), E = D.edad.
%?- presentar(ana, [saludo(buenas)], Texto).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(eva, 8).

%!  persona(?Nombre, -Dict) is nondet.
%
%   Dict es el dict de la persona Nombre, con las claves nombre y edad.
persona(Nombre, persona{nombre: Nombre, edad: Edad}) :-
    edad(Nombre, Edad).

%!  cumple_anios(+Dict0, -Dict) is det.
%
%   Dict es Dict0 con la edad siguiente. Dict0 no cambia.
cumple_anios(Dict0, Dict) :-
    Edad is Dict0.edad + 1,
    Dict = Dict0.put(edad, Edad).

%!  mayores(-Nombres:list) is det.
%
%   Nombres son los nombres de las personas de 18 años o más.
mayores(Nombres) :-
    findall(N, ( persona(N, D), get_dict(edad, D, E), E >= 18 ), Nombres).

%!  presentar(+Nombre, +Opciones:list, -Texto:string) is det.
%
%   Texto presenta a Nombre. Opciones: saludo(S), el saludo, hola si falta;
%   con_edad(B), si se dice la edad, true si falta.
presentar(Nombre, Opciones, Texto) :-
    option(saludo(Saludo), Opciones, hola),
    option(con_edad(ConEdad), Opciones, true),
    (   ConEdad == true,
        edad(Nombre, Edad)
    ->  format(string(Texto), "~w, ~w (~d)", [Saludo, Nombre, Edad])
    ;   format(string(Texto), "~w, ~w", [Saludo, Nombre])
    ).
