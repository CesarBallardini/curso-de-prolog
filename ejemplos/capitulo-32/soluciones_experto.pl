:- encoding(utf8).

% Capítulo 32 - Solución del ejercicio 10: lo que el sistema experto de la
% sección 19.3 debe observar.
%
% Las reglas son las del capítulo 19, con sus operadores. preguntables/1
% reúne los átomos de las condiciones y les quita las conclusiones: lo que
% queda no se deduce con ninguna regla.
%
%?- preguntables(Ps).

:- use_module(library(terms)).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no_vuela y nada entonces pinguino).
regla(r12, si ave y no_vuela y peso(P) y P > 50 entonces avestruz).

%!  preguntables(-Preguntables:list(atom)) is det.
%
%   Preguntables es el conjunto ordenado de los átomos que aparecen en las
%   condiciones de alguna regla y no son la conclusión de ninguna.
preguntables(Preguntables) :-
    findall(C, regla(_, si C entonces _), Condiciones),
    atomos(Condiciones, EnCondiciones),
    findall(Conclusion, regla(_, si _ entonces Conclusion), Conclusiones0),
    sort(Conclusiones0, Conclusiones),
    ord_subtract(EnCondiciones, Conclusiones, Preguntables).

%!  atomos(+Termino, -Atomos:list(atom)) is det.
%
%   Atomos es el conjunto ordenado de los átomos que aparecen en Termino.
atomos(T, Atomos) :-
    foldsubterms(agregar_atomo, T, [], Atomos).

%!  agregar_atomo(+Subtermino, +Conjunto0:list, -Conjunto:list) is semidet.
%
%   Conjunto es Conjunto0 con Subtermino agregado. Falla si Subtermino no
%   es un átomo, y entonces foldsubterms/4 sigue por sus argumentos.
agregar_atomo(X, Conjunto0, Conjunto) :-
    atom(X),
    ord_add_element(Conjunto0, X, Conjunto).
