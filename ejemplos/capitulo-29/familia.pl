:- encoding(utf8).

% Capítulo 29 - Las reglas que consulta el programa de Python.
%
% Un árbol genealógico con edades. ficha/2 reúne los datos de una persona en
% un dict, que Janus convierte en un diccionario de Python; edad_de/2 valida
% su argumento y produce un error ISO si no es un átomo.
%
% solo-local: los ejemplos del capítulo se ejecutan desde Python, con Janus.
%
%?- abuelo(juan, Nieto).
%?- ficha(ana, Ficha).

:- use_module(library(error)).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(ana, eva).

% edad(Persona, Anios): la edad de Persona.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  edad_de(+Persona:atom, -Anios:integer) is semidet.
%
%   Anios es la edad de Persona. Falla si no se conoce.
%
%   @error type_error(atom, Persona) si Persona no es un átomo.
edad_de(Persona, Anios) :-
    must_be(atom, Persona),
    edad(Persona, Anios).

%!  ficha(+Persona:atom, -Ficha:dict) is semidet.
%
%   Ficha es un dict con el nombre, la edad y la lista de hijos de Persona.
%   Falla si no se conoce su edad.
ficha(Persona, _{nombre: Persona, edad: Anios, hijos: Hijos}) :-
    edad_de(Persona, Anios),
    findall(H, padre(Persona, H), Hijos).
