:- encoding(utf8).

% Capítulo 51 - Soluciones de los ejercicios 2 a 9, 12 y 13.
%
% Carga los módulos del proyecto y agrega autómatas, construcciones, un
% operador de las expresiones regulares y dos clases de componentes
% léxicos con cláusulas multifile.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- equivalentes(par_par, interseccion(a_par, b_par)).
%?- equivalentes(ciclo, sin_epsilon(ciclo)).
%?- numero_estados(min(enesima(3)), N).
%?- transducir(complemento2, [0, 1, 1, 0], S).
%?- moore(moore_de(gray, 0), [1, 0, 1, 1], S).

:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(lexico).
:- use_module(secuencial).
:- use_module(kleene).
:- use_module(moore).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

% Ejercicio 2: par_par cuenta las a y las b módulo 2; el estado es el
% par de restos. a_par y b_par cuentan una letra cada uno.

automatas:alfabeto(par_par, [a, b]).
automatas:inicial(par_par, 0-0).
automatas:final(par_par, 0-0).
automatas:delta(par_par, 0-B, a, 1-B) :- member(B, [0, 1]).
automatas:delta(par_par, 1-B, a, 0-B) :- member(B, [0, 1]).
automatas:delta(par_par, A-0, b, A-1) :- member(A, [0, 1]).
automatas:delta(par_par, A-1, b, A-0) :- member(A, [0, 1]).

automatas:alfabeto(a_par, [a, b]).
automatas:inicial(a_par, 0).
automatas:final(a_par, 0).
automatas:delta(a_par, 0, a, 1).
automatas:delta(a_par, 1, a, 0).
automatas:delta(a_par, R, b, R) :- member(R, [0, 1]).

automatas:alfabeto(b_par, [a, b]).
automatas:inicial(b_par, 0).
automatas:final(b_par, 0).
automatas:delta(b_par, 0, b, 1).
automatas:delta(b_par, 1, b, 0).
automatas:delta(b_par, R, a, R) :- member(R, [0, 1]).

% Ejercicio 3: sin_epsilon(M) tiene los estados de M; una transición con
% S es ε, S, ε en M, y un estado es final si su clausura tiene un final.

automatas:alfabeto(sin_epsilon(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(sin_epsilon(M), Q0) :-
    inicial(M, Q0).
automatas:final(sin_epsilon(M), Q) :-
    alcanzable(sin_epsilon(M), Q),
    once(( clausura(M, Q, Q1),
           final(M, Q1) )).
automatas:delta(sin_epsilon(M), Q, S, Q1) :-
    clausura(M, Q, Q2),
    delta(M, Q2, S, Q3),
    clausura(M, Q3, Q1).

% contra acepta solo b; x se alcanza con a, y también con ε desde el
% final f. Tomar como finales los estados a los que se llega con ε desde
% un final haría aceptar a.

automatas:alfabeto(contra, [a, b]).
automatas:inicial(contra, q0).
automatas:final(contra, f).
automatas:delta(contra, q0, a, x).
automatas:delta(contra, q0, b, f).
automatas:epsilon(contra, f, x).

% Ejercicio 4: diferencia(M1, M2), el producto de los deterministas con
% los pares finales en M1 y no finales en M2.

automatas:alfabeto(diferencia(M1, M2), Sigma) :-
    alfabeto(M1, Sigma1),
    alfabeto(M2, Sigma2),
    ord_union(Sigma1, Sigma2, Sigma).
automatas:inicial(diferencia(M1, M2), D1-D2) :-
    inicial(det(M1), D1),
    inicial(det(M2), D2).
automatas:final(diferencia(M1, M2), D1-D2) :-
    alcanzable(diferencia(M1, M2), D1-D2),
    contiene_final(M1, D1),
    \+ contiene_final(M2, D2).
automatas:delta(diferencia(M1, M2), D1-D2, S, E1-E2) :-
    alfabeto(diferencia(M1, M2), Sigma),
    member(S, Sigma),
    mover(M1, S, D1, E1),
    mover(M2, S, D2, E2).

%!  contiene_final(+M, +D:list) is semidet.
%
%   El conjunto de estados D de M contiene un estado final.
contiene_final(M, D) :-
    member(Q, D),
    final(M, Q),
    !.

% Ejercicio 5: enesima(N), la letra N-ésima desde el final es a. El
% estado 0 lee cualquier cosa y apuesta por la a; los estados 1 a N
% cuentan las letras que siguen.

automatas:alfabeto(enesima(_), [a, b]).
automatas:inicial(enesima(_), 0).
automatas:final(enesima(N), N).
automatas:delta(enesima(_), 0, S, 0) :-
    member(S, [a, b]).
automatas:delta(enesima(_), 0, a, 1).
automatas:delta(enesima(N), I, S, I1) :-
    between(1, N, I),
    I < N,
    member(S, [a, b]),
    I1 is I + 1.

%!  explosion(+N:integer, -Filas:list) is det.
%
%   Filas tiene un término K-Det-Min por cada K de 1 a N: la cantidad de
%   estados de det(enesima(K)) y de min(enesima(K)).
explosion(N, Filas) :-
    findall(K-D-M,
            ( between(1, N, K),
              numero_estados(det(enesima(K)), D),
              numero_estados(min(enesima(K)), M) ),
            Filas).

% Ejercicio 6: E{n}, con n un dígito, es E concatenada n veces.

expresiones:sufijos(E0, E, ['{', D, '}'|S0], S) :-
    char_type(D, digit(N)),
    repetir(N, E0, R),
    expresiones:sufijos(R, E, S0, S).

%!  repetir(+N:integer, +E, -R) is det.
%
%   R es la concatenación de N copias de E; con N = 0, la palabra vacía.
repetir(0, _, vacia) :-
    !.
repetir(1, E, E) :-
    !.
repetir(N, E, cat(E, R)) :-
    N1 is N - 1,
    repetir(N1, E, R).

% Ejercicio 7: comentarios hasta el fin de la línea y cadenas entre
% comillas. [ -~] son los caracteres imprimibles, sin el fin de línea;
% [ !#-~], los mismos sin la comilla doble.

lexico:regla(comentario, "#[ -~]*").
lexico:regla(cadena, "\"[ !#-~]*\"").

lexico:componente(comentario, _, Cs, Cs).
lexico:componente(cadena, Lexema, [cadena(A)|Cs], Cs) :-
    once(append(['"'|Caracteres], ['"'], Lexema)),
    atom_chars(A, Caracteres).

% Ejercicio 8: complemento a dos, el bit menos significativo primero:
% copia hasta el primer 1 inclusive, y después invierte.

automatas:inicial(complemento2, copia).
automatas:final(complemento2, copia).
automatas:final(complemento2, invierte).
automatas:delta(complemento2, copia, [0]:[0], copia).
automatas:delta(complemento2, copia, [1]:[1], invierte).
automatas:delta(complemento2, invierte, [0]:[1], invierte).
automatas:delta(complemento2, invierte, [1]:[0], invierte).

% Ejercicio 9: un contador de dos bits cuya salida es 1 cuando vale 0 o
% 2, es decir, cuando su bit menos significativo es 0.

:- multifile secuenciales:secuencial/3.
:- multifile circuitos:circuito/3, circuitos:componente/5.

secuenciales:secuencial(par2, par2_c, 2).
circuitos:circuito(par2_c, [b0, b1], [n0, n0, n1]).
circuitos:componente(par2_c, i1, inv, [b0], [n0]).
circuitos:componente(par2_c, x1, xor, [b1, b0], [n1]).

% Ejercicio 12: la expresión de multiplo3 por la construcción de Kleene,
% y una más corta escrita a mano.

%!  expresion_corta(-T:string) is det.
%
%   T es una expresión regular del lenguaje de multiplo3 escrita a mano.
%   Desde el resto 0, un 0 no lo cambia, y 1(01*0)*1 vuelve a él: el
%   primer 1 lleva al resto 1, cada 01*0 va al resto 2 y vuelve al 1, y
%   el último 1 vuelve al 0.
expresion_corta("(0|1(01*0)*1)*").

% Ejercicio 13: la máquina de Moore de una máquina de Mealy. Sus estados
% son pares Q-S: el estado de la máquina de Mealy y la salida que escribió
% al llegar. El estado inicial escribe S0, que no viene de ninguna
% transición.

automatas:inicial(moore_de(M, S0), Q0-S0) :-
    inicial(M, Q0).
automatas:final(moore_de(_, _), _).
automatas:delta(moore_de(M, _), Q-_, E, Q1-S) :-
    delta(M, Q, [E]:[S], Q1).

moore:salida_estado(moore_de(_, _), _-S, S).
