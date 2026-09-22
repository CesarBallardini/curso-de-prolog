:- encoding(utf8).

% Capítulo 1 - Términos compuestos.
%
% Un argumento no tiene que ser necesariamente un nombre simple. Puede ser un
% término con componentes, como mascota(gato, felix), que se puede consultar
% completo o por componentes.
%
%?- tiene(ana, mascota(Especie, Nombre)).
%?- tiene(Quien, mascota(gato, _)).

% tiene(P, M): P tiene la mascota M.
tiene(ana, mascota(gato, felix)).
tiene(luis, mascota(perro, rocco)).
tiene(eva, mascota(gato, gaturro)).
tiene(pedro, mascota(tortuga, manuelita)).

% propietario_de_gato(P): P tiene por lo menos un gato.
propietario_de_gato(P) :-
    tiene(P, mascota(gato, _)).
