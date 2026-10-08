:- encoding(utf8).

% Capítulo 21 - Una gramática es un conjunto de cláusulas.
%
% oracion//1 reconoce oraciones sobre la familia, como [juan, es, el, padre,
% de, ana], y las relaciona con el término que dicen: padre(juan, ana). La
% misma gramática sirve para analizar y para generar. saludo//0 muestra los
% terminales escritos entre comillas dobles, y siguiente//1 el pushback.
%
%?- phrase(oracion(Hecho), [juan, es, el, padre, de, ana]).
%?- phrase(oracion(madre(marta, pedro)), Palabras).

% persona(P): P es una de las personas de las que se puede hablar.
persona(juan).
persona(ana).
persona(pedro).
persona(marta).

%!  oracion(?Hecho)// is nondet.
%
%   Una oración que afirma Hecho: «juan es el padre de ana» afirma
%   padre(juan, ana).
oracion(Hecho) -->
    nombre(A),
    [es],
    relacion(A, B, Hecho),
    [de],
    nombre(B).

%!  relacion(?A, ?B, ?Hecho)// is nondet.
%
%   El artículo y el sustantivo de una relación, con el Hecho que forma
%   entre A y B.
relacion(A, B, padre(A, B)) --> [el, padre].
relacion(A, B, madre(A, B)) --> [la, madre].

%!  nombre(?P)// is nondet.
%
%   El nombre de una persona conocida.
nombre(P) -->
    [P],
    { persona(P) }.

%!  saludo// is semidet.
%
%   Los códigos del texto hola.
saludo --> "hola".

%!  siguiente(-C)// is semidet.
%
%   C es el próximo elemento de la entrada, que no se consume: se devuelve a
%   la entrada con el pushback.
siguiente(C), [C] --> [C].

%!  palabra_o_numero(-T)// is semidet.
%
%   T es numero si el próximo código es un dígito, o palabra si no. Examina
%   el código con siguiente//1, sin consumirlo.
palabra_o_numero(T) -->
    siguiente(C),
    { code_type(C, digit) -> T = numero ; T = palabra }.

%!  seq(?L:list)// is nondet.
%
%   Cualquier secuencia de elementos, L, en la entrada.
seq([]) --> [].
seq([E|Es]) -->
    [E],
    seq(Es).

%!  menciona(?Palabra, +Oracion:list) is nondet.
%
%   Palabra aparece en la lista Oracion: hay una secuencia antes y otra
%   después.
menciona(Palabra, Oracion) :-
    phrase(( seq(_), [Palabra], seq(_) ), Oracion).
