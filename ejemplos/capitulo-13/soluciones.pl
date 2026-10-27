:- encoding(utf8).

% Capítulo 13 - Soluciones de los ejercicios.
%
%?- puede_entrar(Quien).
%?- paridad(7, Que).
%?- \+ remar.
%?- q(e, b).
%?- r(X, X), s(X, Y).

% --- Ejercicio 3 -----------------------------------------------------------

% gato(X): X es un gato.
gato(felix).
gato(gaturro).

% perro(X): X es un perro.
perro(rocco).

%!  animal(?X) is nondet.
%
%   Para todo X, si X es gato entonces X es animal.
animal(X) :-
    gato(X).
animal(X) :-
    perro(X).

% --- Ejercicio 4 -----------------------------------------------------------

% progenitor(P, H): P es el padre o la madre de H.
progenitor(juan, ana).
progenitor(marta, ana).
progenitor(juan, pedro).
progenitor(marta, pedro).
progenitor(pedro, luis).
progenitor(pedro, eva).

%!  tiene_nieto(?A) is nondet.
%
%   A tiene algún nieto: A es progenitor de alguien que es progenitor de
%   alguien.
tiene_nieto(A) :-
    progenitor(A, P),
    progenitor(P, _).

% --- Ejercicio 7 -----------------------------------------------------------

% socio(P): P es socio.
socio(ana).
socio(pedro).

% invita(S, P): S invita a P.
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

% --- Ejercicio 8 -----------------------------------------------------------

%!  paridad(+N, -P) is det.
%
%   P indica si N es par o impar. No es una afirmación con una disyunción en
%   la conclusión: son dos reglas, cada una con su condición.
paridad(N, par) :-
    0 =:= N mod 2.
paridad(N, impar) :-
    1 =:= N mod 2.

% --- Ejercicio 9 -----------------------------------------------------------

% persona(P): P es una de las personas de la base.
persona(ana).
persona(luis).
persona(eva).

%!  tiene_mascota(?P) is nondet.
%
%   Todo el que tiene un gato tiene una mascota. La implicación se escribe como
%   una regla: la conclusión a la izquierda, la condición a la derecha.
tiene_mascota(P) :-
    tiene_gato(P).

% tiene_gato(P): P tiene un gato.
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

% --- Ejercicio 16 ----------------------------------------------------------

% templado: el día está templado.
templado.

% llueve: llueve.
llueve.

%!  picnic is semidet.
%
%   Se hace el picnic: el día está templado y no se puede probar que llueva.
picnic :-
    templado,
    \+ llueve.

%!  remar is semidet.
%
%   Se rema: se hace el picnic. La restricción «no se rema cuando llueve» no
%   se puede escribir en el programa.
remar :-
    picnic.

% --- Ejercicio 20 ----------------------------------------------------------

%!  concatenar(+A, ?B, -C) is det.
%!  concatenar(?A, ?B, +C) is nondet.
%
%   C es la lista A seguida de la lista B. Es el predicado de la sección 7.4,
%   copiado con su encabezado.
concatenar([], B, B).
concatenar([X|RestoA], B, [X|RestoC]) :-
    concatenar(RestoA, B, RestoC).

% --- Ejercicio 22 ----------------------------------------------------------

% p(X, Y): hay un arco de X a Y.
p(a, b).
p(a, e).
p(b, c).
p(b, d).
p(e, f).

%!  q(?X, ?Y) is nondet.
%
%   Hay un camino de dos arcos de X a Y.
q(X, Y) :-
    p(X, Z),
    p(Z, Y).

%!  r(?X, ?Y) is nondet.
%
%   X e Y tienen un origen común: hay arcos de un mismo Z a X y a Y.
r(X, Y) :-
    p(Z, X),
    p(Z, Y).

%!  s(?X, ?Y) is nondet.
%
%   Hay un arco de Z a Y, y Z y X tienen un origen común.
s(X, Y) :-
    p(Z, Y),
    r(Z, X).

% --- Ejercicio 23 ----------------------------------------------------------

% persona/1 está definido en el ejercicio 9.

% tiene(P, M): P tiene la mascota M.
tiene(ana, felix).

%!  sin_mascota(?P) is nondet.
%
%   P es una persona para la que no se puede probar que tenga mascota.
sin_mascota(P) :-
    persona(P),
    \+ tiene(P, _).
