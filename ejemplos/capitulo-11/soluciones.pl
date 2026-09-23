:- encoding(utf8).

% Capítulo 11 - Soluciones de los ejercicios.
%
%?- puede_entrar(Quien).
%?- paridad(7, Que).

% --- Ejercicio 2 -----------------------------------------------------------

gato(felix).
gato(gaturro).
perro(rocco).

%!  animal(?X) is nondet.
%
%   Para todo X, si X es gato entonces X es animal.
animal(X) :-
    gato(X).
animal(X) :-
    perro(X).

% --- Ejercicio 4 -----------------------------------------------------------

socio(ana).
socio(pedro).
invita(ana, luis).
invita(pedro, eva).

%!  puede_entrar(?P) is nondet.
%
%   P es socio, o lo invita un socio. Las dos cláusulas expresan la
%   disyunción.
puede_entrar(P) :-
    socio(P).
puede_entrar(P) :-
    invita(S, P),
    socio(S).

% --- Ejercicio 5 -----------------------------------------------------------

%!  paridad(+N, -P) is det.
%
%   P indica si N es par o impar. No es una afirmación con una disyunción en
%   la conclusión: son dos reglas, cada una con su condición.
paridad(N, par) :-
    0 =:= N mod 2.
paridad(N, impar) :-
    1 =:= N mod 2.

% --- Ejercicio 7 -----------------------------------------------------------

persona(ana).
persona(luis).
persona(eva).
tiene(ana, felix).

%!  sin_mascota(?P) is nondet.
%
%   P es una persona para la que no se puede probar que tenga mascota.
sin_mascota(P) :-
    persona(P),
    \+ tiene(P, _).

% --- Ejercicio 10 ----------------------------------------------------------

%!  tiene_mascota(?P) is nondet.
%
%   Todo el que tiene un gato tiene una mascota. La implicación se escribe como
%   una regla: la conclusión a la izquierda, la condición a la derecha.
tiene_mascota(P) :-
    tiene_gato(P).

tiene_gato(ana).
tiene_gato(eva).

% padre(P, H): P es el padre de H.
padre(luis, eva).

%!  no_es_padre_de_si_mismo(?P) is nondet.
%
%   Nadie es padre de sí mismo. La negación del enunciado se escribe con \+, y
%   no como una cláusula de Horn.
no_es_padre_de_si_mismo(P) :-
    persona(P),
    \+ padre(P, P).
