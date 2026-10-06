:- encoding(utf8).

% Capítulo 51 - De un autómata a una expresión regular.
%
% La construcción de Kleene, en la forma de McNaughton y Yamada: con los
% estados numerados de 0 a N - 1, R(I, J, K) es la expresión de las
% palabras que llevan del estado I al J sin pasar por estados intermedios
% de número K o mayor. Con K = 0 son los símbolos de I a J, y la palabra
% vacía si I = J; un estado más, K, agrega los caminos que pasan por él:
%
%   R(I, J, K+1) = R(I, J, K) | R(I, K, K) R(K, K, K)* R(K, J, K)
%
% La expresión del autómata es la unión de R(0, F, N) para cada estado
% final F. r/5 está tabulada: cada R se calcula una vez, como en el
% esbozo de Warren. Los constructores simplifican mientras construyen:
% nada es el lenguaje vacío, que no tiene notación en el texto.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- expresion_de(ciclo, E).
%?- expresion_texto(termina_ab, T).
%?- expresion_texto(termina_ab, T), equivalentes(er(T), termina_ab).

:- module(kleene,
          [ expresion_de/2,
            expresion_texto/2,
            texto/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(expresiones).

%!  expresion_de(+M, -E) is det.
%
%   E es una expresión regular, un término de expresiones.pl o nada, del
%   lenguaje del autómata M. Se construye sobre el autómata mínimo de M,
%   con sus estados numerados por tabla/2.
expresion_de(M, E) :-
    tabla(min(M), A),
    A = automata(N, Finales, _),
    foldl(union_final(A, N), Finales, nada, E).

%!  expresion_texto(+M, -Texto:string) is semidet.
%
%   Texto es la expresión regular del lenguaje de M, escrita. Falla si el
%   lenguaje es vacío.
expresion_texto(M, Texto) :-
    expresion_de(M, E),
    texto(E, Texto).

%!  union_final(+A, +N:integer, +F:integer, +E0, -E) is det.
%
%   E es la unión de E0 con R(0, F, N) en el autómata numerado A.
union_final(A, N, F, E0, E) :-
    r(A, 0, F, N, R),
    alt(E0, R, E).

:- table r/5.

%!  r(+A, +I:integer, +J:integer, +K:integer, -E) is det.
%
%   E es R(I, J, K) en el autómata numerado A: las palabras que llevan de
%   I a J sin pasar por un estado intermedio de número K o mayor.
r(automata(_, _, Delta), I, J, 0, E) :-
    !,
    findall(sim(S), member(I-S-J, Delta), Simbolos),
    foldl(alt_acumulado, Simbolos, nada, E0),
    (   I =:= J
    ->  alt(E0, vacia, E)
    ;   E = E0
    ).
r(A, I, J, K1, E) :-
    K is K1 - 1,
    r(A, I, J, K, Directo),
    r(A, I, K, K, Entrada),
    r(A, K, K, K, Ciclo),
    r(A, K, J, K, Salida),
    estrella(Ciclo, Ciclos),
    cat(Entrada, Ciclos, E1),
    cat(E1, Salida, Pasando),
    alt(Directo, Pasando, E).

%!  alt_acumulado(+E1, +E0, -E) is det.
%
%   E es la unión de E0 con E1, en ese orden.
alt_acumulado(E1, E0, E) :-
    alt(E0, E1, E).

%!  alt(+E1, +E2, -E) is det.
%
%   E es la unión de E1 y E2, simplificada: nada es su neutro, una
%   expresión unida consigo misma es ella misma, y lo que ya está en una
%   estrella, unido a ella, sobra.
alt(nada, E, E) :-
    !.
alt(E, nada, E) :-
    !.
alt(E, E, E) :-
    !.
alt(E1, estrella(E), estrella(E)) :-
    en_estrella(E1, E),
    !.
alt(estrella(E), E2, estrella(E)) :-
    en_estrella(E2, E),
    !.
alt(E1, E2, alt(E1, E2)).

%!  en_estrella(+E1, +E) is semidet.
%
%   E1 es la palabra vacía, E, o la unión de E con la palabra vacía:
%   está contenida en la estrella de E, y también en la de E E*.
en_estrella(vacia, _).
en_estrella(E, E).
en_estrella(alt(E, vacia), E).
en_estrella(alt(vacia, E), E).

%!  cat(+E1, +E2, -E) is det.
%
%   E es la concatenación de E1 y E2, simplificada: nada la anula, la
%   palabra vacía es su neutro, y una estrella absorbe, a cualquiera de
%   sus dos lados, la estrella misma o su expresión con la palabra vacía.
cat(nada, _, nada) :-
    !.
cat(_, nada, nada) :-
    !.
cat(vacia, E, E) :-
    !.
cat(E, vacia, E) :-
    !.
cat(E1, estrella(E), estrella(E)) :-
    absorbida(E1, E),
    !.
cat(estrella(E), E2, estrella(E)) :-
    absorbida(E2, E),
    !.
cat(E1, E2, cat(E1, E2)).

%!  absorbida(+E1, +E) is semidet.
%
%   E1 es la estrella de E o la unión de E con la palabra vacía:
%   concatenada con la estrella de E, da la estrella de E.
absorbida(estrella(E), E).
absorbida(alt(E, vacia), E).
absorbida(alt(vacia, E), E).

%!  estrella(+E0, -E) is det.
%
%   E es la clausura de E0, simplificada: la de nada y la de la palabra
%   vacía son la palabra vacía, la de una estrella es ella misma, y la
%   palabra vacía dentro de una unión sobra.
estrella(nada, vacia) :-
    !.
estrella(vacia, vacia) :-
    !.
estrella(estrella(E), estrella(E)) :-
    !.
estrella(alt(vacia, E), estrella(E)) :-
    !.
estrella(alt(E, vacia), estrella(E)) :-
    !.
estrella(E, estrella(E)).

%!  texto(+E, -Texto:string) is semidet.
%
%   Texto es la expresión E escrita con la notación de expresiones.pl,
%   con los paréntesis que hacen falta. Falla con nada, el lenguaje
%   vacío, que la notación no puede escribir.
texto(E, Texto) :-
    E \== nada,
    phrase(escribir(E, 0), Codigos),
    string_codes(Texto, Codigos).

%!  escribir(+E, +Contexto:integer)// is det.
%
%   Los caracteres de E dentro de un Contexto: 0 en una unión o en el
%   nivel superior, 1 dentro de una concatenación, 2 bajo una estrella.
%   Una subexpresión menos ligada que su contexto va entre paréntesis.
escribir(E, Contexto) -->
    { nivel(E, Nivel) },
    (   { Nivel < Contexto }
    ->  "(", escribir_sin(E), ")"
    ;   escribir_sin(E)
    ).

%!  nivel(+E, -Nivel:integer) is det.
%
%   Nivel es 0 para una unión, 1 para una concatenación y 2 para las
%   demás expresiones.
nivel(alt(_, _), 0) :-
    !.
nivel(cat(_, _), 1) :-
    !.
nivel(_, 2).

%!  escribir_sin(+E)// is det.
%
%   Los caracteres de E, sin paréntesis alrededor.
escribir_sin(vacia) -->
    "()".
escribir_sin(sim(C)) -->
    simbolo(C).
escribir_sin(alt(A, B)) -->
    escribir(A, 0), "|", escribir(B, 0).
escribir_sin(cat(A, B)) -->
    escribir(A, 1), escribir(B, 1).
escribir_sin(estrella(A)) -->
    escribir(A, 2), "*".

%!  simbolo(+C)// is det.
%
%   Los caracteres del símbolo C, precedido por \ si es especial.
simbolo(C) -->
    { atom_codes(C, Cs) },
    (   { especial(C) }
    ->  [0'\\]
    ;   []
    ),
    Cs.

%!  especial(+C) is semidet.
%
%   C tiene un significado en la notación de las expresiones: es un
%   operador, un paréntesis, una llave o la barra invertida.
especial(C) :-
    atom_codes(Barra, [92]),
    memberchk(C, ['(', ')', '[', ']', '|', '*', '+', '?', '{', '}', Barra]).
