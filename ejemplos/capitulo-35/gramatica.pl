:- encoding(utf8).

% Capítulo 35 - Cómo se traduce una gramática.
%
% a_b/1 reconoce una lista de aes seguida de una lista de bes partiendo la
% lista con append/3: prueba cada partición. traducir/2 traduce una regla
% de gramática a una cláusula con dos argumentos más, la lista y lo que
% queda de ella, como hace SWI-Prolog al cargar. Con term_expansion/2, las
% reglas escritas después de su definición, como a_b//0, se cargan con la
% traducción de traducir/2 en lugar de la del sistema.
%
%?- traducir((saludo --> [hola], nombre), C).
%?- length(As, 3), maplist(=(a), As), append(As, [b, b], L), phrase(a_b, L).
%?- traducir((digito(D) --> [D], { code_type(D, digit) }), C).

%!  a_b_append(+Lista:list) is semidet.
%
%   Lista tiene aes seguidas de bes. Prueba cada partición de Lista en dos
%   partes, de la más corta a la más larga.
a_b_append(Lista) :-
    append(As, Bs, Lista),
    solo(a, As),
    solo(b, Bs),
    !.

%!  solo(+X, +Lista:list) is semidet.
%
%   Todos los elementos de Lista son X.
solo(_, []).
solo(X, [X|Xs]) :-
    solo(X, Xs).

%!  traducir(+Regla, -Clausula) is det.
%
%   Clausula es la traducción de la regla de gramática Regla, Cabeza -->
%   Cuerpo, con dos argumentos más: la lista y lo que queda de ella.
traducir((Cabeza --> Cuerpo), (Cabeza1 :- Cuerpo1)) :-
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S, Cuerpo1).

%!  cuerpo(+Cuerpo, ?S0, ?S, -Meta) is det.
%
%   Meta reconoce con Cuerpo la parte de S0 anterior a S.
cuerpo(Var, S0, S, phrase(Var, S0, S)) :-
    var(Var),
    !.
cuerpo((A, B), S0, S, (A1, B1)) :-
    !,
    cuerpo(A, S0, S1, A1),
    cuerpo(B, S1, S, B1).
cuerpo((A ; B), S0, S, (A1 ; B1)) :-
    !,
    cuerpo(A, S0, S, A1),
    cuerpo(B, S0, S, B1).
cuerpo(\+ A, S0, S, (\+ A1, S = S0)) :-
    !,
    cuerpo(A, S0, _, A1).
cuerpo({G}, S0, S, (G, S = S0)) :-
    !.
cuerpo(!, S0, S, (!, S = S0)) :-
    !.
cuerpo([], S0, S, S0 = S) :-
    !.
cuerpo([X|Xs], S0, S, S0 = Lista) :-
    !,
    append([X|Xs], S, Lista).
cuerpo(NoTerminal, S0, S, Meta) :-
    no_terminal(NoTerminal, S0, S, Meta).

%!  no_terminal(+NoTerminal, ?S0, ?S, -Meta) is det.
%
%   Meta es NoTerminal con S0 y S agregados al final de sus argumentos.
no_terminal(NoTerminal, S0, S, Meta) :-
    NoTerminal =.. Lista0,
    append(Lista0, [S0, S], Lista),
    Meta =.. Lista.

%!  term_expansion(+Regla, -Clausula) is semidet.
%
%   Las reglas de gramática que siguen se cargan con la traducción de
%   traducir/2.
term_expansion(Regla, Clausula) :-
    Regla = (_ --> _),
    traducir(Regla, Clausula).

%!  a_b// is nondet.
%
%   Aes seguidas de bes.
a_b -->
    aes,
    bes.

%!  aes// is nondet.
%
%   Cero o más aes.
aes -->
    [].
aes -->
    [a],
    aes.

%!  bes// is nondet.
%
%   Cero o más bes.
bes -->
    [].
bes -->
    [b],
    bes.

%!  aes_bes(+N:integer, -Lista:list) is det.
%
%   Lista tiene N aes seguidas de N bes.
aes_bes(N, Lista) :-
    length(As, N),
    maplist(=(a), As),
    length(Bs, N),
    maplist(=(b), Bs),
    append(As, Bs, Lista).
