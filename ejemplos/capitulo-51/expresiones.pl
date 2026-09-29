:- encoding(utf8).

% Capítulo 51 - Versión 5: expresiones regulares.
%
% Una expresión regular se escribe como texto, con la notación usual:
% ab concatena, a|b es la unión, a* la clausura de Kleene, a+ una o más
% veces, a? cero o una vez, [a-z0-9] una clase de caracteres, los
% paréntesis agrupan, y \ quita el significado especial al carácter que
% sigue. Una gramática la convierte en un término:
%
%   vacia           la palabra vacía;
%   sim(C)          el símbolo C, un carácter;
%   clase(Cs)       uno cualquiera de los caracteres de la lista Cs;
%   cat(E1, E2)     la concatenación;
%   alt(E1, E2)     la unión;
%   estrella(E)     cero o más repeticiones.
%
% er(Texto) es el autómata de la expresión, por la construcción de
% Thompson: cada subexpresión tiene un fragmento con un estado inicial y
% uno final, unidos a los de sus subexpresiones por transiciones ε. Los
% estados se nombran por la posición de la subexpresión en el árbol.
% ingenua(Texto) los nombra por la subexpresión misma, y dos
% subexpresiones iguales comparten entonces sus estados.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- expresion("(a|b)*abb", E).
%?- acepta(er("(a|b)*abb"), [b, a, b, b]).
%?- acepta(ingenua("aa"), [a]).
%?- tabla(min(er("(a|b)*abb")), T).

:- module(expresiones,
          [ expresion/2,
            subexpresion/3
          ]).

:- use_module(library(lists)).
:- reexport(minimizar).

:- set_prolog_flag(double_quotes, chars).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

:- multifile sufijos//2.

:- table arbol/2.

%!  expresion(+Texto, -E) is det.
%
%   E es el término de la expresión regular Texto, un string o un átomo.
%   Produce un error de sintaxis si Texto no es una expresión.
expresion(Texto, E) :-
    arbol(Texto, E).

%!  arbol(+Texto, -E) is det.
%
%   Como expresion/2, tabulada: cada texto se analiza una sola vez.
arbol(Texto, E) :-
    atom_chars(Texto, Cs),
    (   once(phrase(alternativa(E0), Cs))
    ->  E = E0
    ;   syntax_error(expresion_regular(Texto))
    ).

%!  alternativa(-E)// is nondet.
%
%   Una o más concatenaciones separadas por |.
alternativa(E) -->
    concatenacion(E0),
    mas_alternativas(E0, E).

%!  mas_alternativas(+E0, -E)// is nondet.
%
%   E es la unión de E0 con las concatenaciones que siguen, cada una
%   precedida por |.
mas_alternativas(E0, E) -->
    "|",
    concatenacion(E1),
    mas_alternativas(alt(E0, E1), E).
mas_alternativas(E, E) -->
    [].

%!  concatenacion(-E)// is nondet.
%
%   Cero o más factores seguidos; ninguno es la palabra vacía.
concatenacion(E) -->
    factor(E0),
    mas_factores(E0, E).
concatenacion(vacia) -->
    [].

%!  mas_factores(+E0, -E)// is nondet.
%
%   E es la concatenación de E0 con los factores que siguen.
mas_factores(E0, E) -->
    factor(E1),
    mas_factores(cat(E0, E1), E).
mas_factores(E, E) -->
    [].

%!  factor(-E)// is nondet.
%
%   Un átomo seguido de cero o más operadores *, + y ?.
factor(E) -->
    atomo(E0),
    sufijos(E0, E).

%!  sufijos(+E0, -E)// is nondet.
%
%   E es E0 con los operadores que siguen: E+ es E E*, y E? es E | vacía.
%   Otros archivos pueden agregar operadores posfijos con cláusulas
%   expresiones:sufijos(E0, E, S0, S).
sufijos(E0, E) -->
    "*",
    sufijos(estrella(E0), E).
sufijos(E0, E) -->
    "+",
    sufijos(cat(E0, estrella(E0)), E).
sufijos(E0, E) -->
    "?",
    sufijos(alt(E0, vacia), E).
sufijos(E, E) -->
    [].

%!  atomo(-E)// is nondet.
%
%   Una expresión entre paréntesis, una clase entre corchetes, un
%   carácter precedido por \, o un carácter sin significado especial.
atomo(E) -->
    "(",
    alternativa(E),
    ")".
atomo(clase(Cs)) -->
    "[",
    caracteres(Cs0),
    "]",
    { sort(Cs0, Cs) }.
atomo(sim(C)) -->
    "\\",
    [C].
atomo(sim(C)) -->
    [C],
    { \+ especial(C) }.

% especial(C): C tiene un significado en la notación de las expresiones.
% Las llaves quedan reservadas para operadores que agreguen otros archivos.
especial('(').
especial(')').
especial('[').
especial(']').
especial('|').
especial('*').
especial('+').
especial('?').
especial('\\').
especial('{').
especial('}').

%!  caracteres(-Cs:list)// is nondet.
%
%   Los caracteres de una clase: rangos como a-z y caracteres sueltos.
caracteres(Cs) -->
    [A],
    "-",
    [B],
    { B \== ']',
      rango(A, B, Rango) },
    caracteres(Cs1),
    { append(Rango, Cs1, Cs) }.
caracteres([C|Cs]) -->
    [C],
    { C \== ']' },
    caracteres(Cs).
caracteres([]) -->
    [].

%!  rango(+A, +B, -Cs:list) is det.
%
%   Cs son los caracteres desde A hasta B, en el orden de sus códigos.
rango(A, B, Cs) :-
    char_code(A, CA),
    char_code(B, CB),
    numlist(CA, CB, Codigos),
    atom_codes(Atomo, Codigos),
    atom_chars(Atomo, Cs).

%!  subexpresion(+E, ?P:list, ?Sub) is nondet.
%
%   Sub es la subexpresión de E en la posición P: la lista de los números
%   de hijo, 1 o 2, desde Sub hasta la raíz. La raíz está en [].
subexpresion(E, P, Sub) :-
    subexpresion(E, [], P, Sub).

%!  subexpresion(+E, +P0:list, ?P:list, ?Sub) is nondet.
%
%   Como subexpresion/3, para E en la posición P0.
subexpresion(E, P, P, E).
subexpresion(cat(A, _), P0, P, Sub) :-
    subexpresion(A, [1|P0], P, Sub).
subexpresion(cat(_, B), P0, P, Sub) :-
    subexpresion(B, [2|P0], P, Sub).
subexpresion(alt(A, _), P0, P, Sub) :-
    subexpresion(A, [1|P0], P, Sub).
subexpresion(alt(_, B), P0, P, Sub) :-
    subexpresion(B, [2|P0], P, Sub).
subexpresion(estrella(A), P0, P, Sub) :-
    subexpresion(A, [1|P0], P, Sub).

%!  arco(+Sub, ?I, ?F, ?I1, ?F1, ?I2, ?F2, ?Arco) is nondet.
%
%   Arco es una transición del fragmento de Thompson de la subexpresión
%   Sub, cuyos estados inicial y final son I y F, y los de sus hijos I1,
%   F1 e I2, F2. Arco es t(Q, S, Q1), una transición con el símbolo S, o
%   e(Q, Q1), una transición ε.
arco(sim(C), I, F, _, _, _, _, t(I, C, F)).
arco(clase(Cs), I, F, _, _, _, _, t(I, C, F)) :-
    member(C, Cs).
arco(vacia, I, F, _, _, _, _, e(I, F)).
arco(cat(_, _), I, F, I1, F1, I2, F2, Arco) :-
    member(Arco, [e(I, I1), e(F1, I2), e(F2, F)]).
arco(alt(_, _), I, F, I1, F1, I2, F2, Arco) :-
    member(Arco, [e(I, I1), e(I, I2), e(F1, F), e(F2, F)]).
arco(estrella(_), I, F, I1, F1, _, _, Arco) :-
    member(Arco, [e(I, I1), e(I, F), e(F1, I1), e(F1, F)]).

%!  arco_er(+Texto, ?Arco) is nondet.
%
%   Arco es una transición del autómata de Thompson de Texto, con los
%   estados nombrados por posiciones.
arco_er(Texto, Arco) :-
    arbol(Texto, E),
    subexpresion(E, P, Sub),
    arco(Sub, i(P), f(P), i([1|P]), f([1|P]), i([2|P]), f([2|P]), Arco).

%!  arco_ingenuo(+Texto, ?Arco) is nondet.
%
%   Como arco_er/2, con los estados nombrados por las subexpresiones:
%   i(Sub) y f(Sub).
arco_ingenuo(Texto, Arco) :-
    arbol(Texto, E),
    subexpresion(E, _, Sub),
    hijos(Sub, A, B),
    arco(Sub, i(Sub), f(Sub), i(A), f(A), i(B), f(B), Arco).

%!  hijos(+Sub, -A, -B) is det.
%
%   A y B son las subexpresiones de Sub; las que no tiene quedan libres.
hijos(cat(A, B), A, B) :- !.
hijos(alt(A, B), A, B) :- !.
hijos(estrella(A), A, _) :- !.
hijos(_, _, _).

%!  alfabeto_er(+Texto, -Sigma:list) is det.
%
%   Sigma son los caracteres que aparecen en la expresión Texto.
alfabeto_er(Texto, Sigma) :-
    arbol(Texto, E),
    findall(C,
            ( subexpresion(E, _, Sub),
              arco(Sub, _, _, _, _, _, _, t(_, C, _)) ),
            Cs),
    sort(Cs, Sigma).

automatas:alfabeto(er(Texto), Sigma) :-
    alfabeto_er(Texto, Sigma).
automatas:inicial(er(_), i([])).
automatas:final(er(_), f([])).
automatas:delta(er(Texto), Q, S, Q1) :-
    arco_er(Texto, t(Q, S, Q1)).
automatas:epsilon(er(Texto), Q, Q1) :-
    arco_er(Texto, e(Q, Q1)).

automatas:alfabeto(ingenua(Texto), Sigma) :-
    alfabeto_er(Texto, Sigma).
automatas:inicial(ingenua(Texto), Q0) :-
    arbol(Texto, E),
    Q0 = i(E).
automatas:final(ingenua(Texto), Q) :-
    arbol(Texto, E),
    Q = f(E).
automatas:delta(ingenua(Texto), Q, S, Q1) :-
    arco_ingenuo(Texto, t(Q, S, Q1)).
automatas:epsilon(ingenua(Texto), Q, Q1) :-
    arco_ingenuo(Texto, e(Q, Q1)).
