:- encoding(utf8).

% Capítulo 51 - Versión 2: el módulo automatas y la clausura ε tabulada.
%
% Un autómata finito M = (Q, Σ, δ, q0, F) se describe con cinco relaciones,
% declaradas multifile para que otros archivos agreguen autómatas con
% cláusulas automatas:delta(...), automatas:inicial(...), etc.:
%
%   alfabeto(M, Sigma)    Sigma es el alfabeto de M, una lista ordenada;
%   inicial(M, Q0)        Q0 es el estado inicial de M;
%   final(M, Q)           Q es un estado final de M;
%   delta(M, Q, S, Q1)    M pasa de Q a Q1 leyendo el símbolo S;
%   epsilon(M, Q, Q1)     M pasa de Q a Q1 sin leer nada.
%
% El nombre M es un átomo para un autómata descrito con hechos, o un
% término para uno construido a partir de otros: las versiones siguientes
% definen det(M), complemento(M), min(M), er(Texto) y otros con reglas
% para estas mismas relaciones, que se consultan con M ligado.
%
% La clausura ε y los estados alcanzables están tabulados: terminan aunque
% las transiciones formen ciclos. El orden de las respuestas de una tabla
% cambia entre procesos; las pruebas comparan resultados ordenados.
%
% El módulo es también la base de los transductores de la versión 7 y del
% capítulo 53.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- acepta(ciclo, [a, a, b]).
%?- clausura(ciclo, s0, Q).
%?- palabras(termina_ab, 3, Ws).
%?- tabla(multiplo3, T).

:- module(automatas,
          [ alfabeto/2,
            inicial/2,
            final/2,
            delta/4,
            epsilon/3,
            clausura/3,
            clausura_conjunto/3,
            mover/4,
            acepta/2,
            reconoce/2,
            palabras/3,
            alcanzable/2,
            estados/2,
            numero_estados/2,
            tabla/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

:- multifile alfabeto/2, inicial/2, final/2, delta/4, epsilon/3.
:- discontiguous alfabeto/2, inicial/2, final/2, delta/4, epsilon/3.

% Los tres autómatas de la versión 1, con su alfabeto.

% alfabeto(M, Sigma): Sigma es el alfabeto de M.
alfabeto(multiplo3, [0, 1]).
alfabeto(termina_ab, [a, b]).
alfabeto(ciclo, [a, b]).

% inicial(M, Q0): Q0 es el estado inicial de M.
inicial(multiplo3, r0).
inicial(termina_ab, q0).
inicial(ciclo, s0).

% final(M, Q): Q es un estado final de M.
final(multiplo3, r0).
final(termina_ab, q2).
final(ciclo, s2).

% delta(M, Q, S, Q1): M pasa de Q a Q1 leyendo S.
delta(multiplo3, r0, 0, r0).
delta(multiplo3, r0, 1, r1).
delta(multiplo3, r1, 0, r2).
delta(multiplo3, r1, 1, r0).
delta(multiplo3, r2, 0, r1).
delta(multiplo3, r2, 1, r2).
delta(termina_ab, q0, a, q0).
delta(termina_ab, q0, b, q0).
delta(termina_ab, q0, a, q1).
delta(termina_ab, q1, b, q2).
delta(ciclo, s0, a, s0).
delta(ciclo, s1, b, s2).

% epsilon(M, Q, Q1): M pasa de Q a Q1 sin leer un símbolo.
epsilon(ciclo, s0, s1).
epsilon(ciclo, s1, s0).

:- table clausura/3.

%!  clausura(+M, +Q0, ?Q) is nondet.
%
%   Q está en la clausura ε de Q0 en el autómata M: se llega de Q0 a Q con
%   cero o más transiciones ε. Tabulada: cada estado aparece una vez, y la
%   consulta termina aunque las transiciones ε formen un ciclo.
clausura(_M, Q, Q).
clausura(M, Q0, Q) :-
    clausura(M, Q0, Q1),
    epsilon(M, Q1, Q).

%!  clausura_conjunto(+M, +Qs:list, -D:list) is det.
%
%   D es la clausura ε del conjunto de estados Qs, como lista ordenada.
clausura_conjunto(M, Qs, D) :-
    findall(Q, ( member(Q0, Qs), clausura(M, Q0, Q) ), Todos),
    sort(Todos, D).

%!  mover(+M, +S, +D:list, -D1:list) is det.
%
%   D1 es el conjunto de estados al que M llega desde alguno de los
%   estados de D leyendo S, con su clausura ε. Si ninguno tiene una
%   transición con S, D1 es el conjunto vacío. Los argumentos siguen el
%   orden de foldl/4: el símbolo, el conjunto anterior y el siguiente.
mover(M, S, D, D1) :-
    findall(Q1, ( member(Q, D), delta(M, Q, S, Q1) ), Qs),
    clausura_conjunto(M, Qs, D1).

%!  acepta(+M, +W:list) is semidet.
%
%   El autómata M acepta la palabra W. Recorre W una vez, llevando el
%   conjunto de estados en los que M puede estar.
acepta(M, W) :-
    inicial(M, Q0),
    clausura_conjunto(M, [Q0], D0),
    foldl(mover(M), W, D0, D),
    member(Q, D),
    final(M, Q),
    !.

%!  reconoce(+M, ?W:list) is nondet.
%
%   M acepta W, con una respuesta por cada camino que lo demuestra. Con W
%   libre enumera las palabras sin fin; con una longitud fija, termina.
reconoce(M, W) :-
    inicial(M, Q0),
    lee(M, Q0, W, Q),
    final(M, Q).

%!  lee(+M, +Q0, ?W:list, -Q) is nondet.
%
%   M pasa de Q0 a Q leyendo W, con transiciones ε en cualquier punto.
lee(M, Q0, [], Q) :-
    clausura(M, Q0, Q).
lee(M, Q0, [S|W], Q) :-
    clausura(M, Q0, Q1),
    delta(M, Q1, S, Q2),
    lee(M, Q2, W, Q).

%!  palabras(+M, +N:integer, -Ws:list) is det.
%
%   Ws son las palabras de longitud N que acepta M, ordenadas y sin
%   repetir.
palabras(M, N, Ws) :-
    length(W, N),
    findall(W, reconoce(M, W), Ws0),
    sort(Ws0, Ws).

:- table alcanzable/2.

%!  alcanzable(+M, ?Q) is nondet.
%
%   Q es un estado de M al que se llega desde el inicial. Tabulada: los
%   ciclos del grafo de estados no impiden que termine.
alcanzable(M, Q) :-
    inicial(M, Q).
alcanzable(M, Q) :-
    alcanzable(M, Q0),
    (   delta(M, Q0, _, Q)
    ;   epsilon(M, Q0, Q)
    ).

%!  estados(+M, -Qs:list) is det.
%
%   Qs son los estados alcanzables de M, ordenados.
estados(M, Qs) :-
    findall(Q, alcanzable(M, Q), Qs0),
    sort(Qs0, Qs).

%!  numero_estados(+M, -N:integer) is det.
%
%   N es la cantidad de estados alcanzables de M.
numero_estados(M, N) :-
    estados(M, Qs),
    length(Qs, N).

%!  tabla(+M, -T) is det.
%
%   T es automata(N, Finales, Delta): M con sus N estados alcanzables
%   numerados de 0 a N - 1 en el orden de un recorrido en anchura desde el
%   inicial, que recibe el 0, Finales la lista de los números de los
%   estados finales, y Delta la lista ordenada de las transiciones I-S-J.
%   Sirve para mostrar un autómata cuyos estados son términos grandes.
%   Las transiciones ε no aparecen: T describe autómatas sin ellas.
tabla(M, automata(N, Finales, Delta)) :-
    once(inicial(M, Q0)),
    anchura([Q0], M, [Q0], Orden),
    length(Orden, N),
    N1 is N - 1,
    numlist(0, N1, Numeros),
    pairs_keys_values(Pares, Orden, Numeros),
    sort(Pares, Indice),
    findall(I, ( member(Q-I, Indice), final(M, Q) ), Finales0),
    sort(Finales0, Finales),
    findall(I-S-J,
            ( member(Q-I, Indice),
              delta(M, Q, S, Q1),
              memberchk(Q1-J, Indice) ),
            Delta0),
    sort(Delta0, Delta).

%!  anchura(+Frontera:list, +M, +Vistos:list, -Orden:list) is det.
%
%   Orden son los estados de M en el orden en que un recorrido en anchura
%   los visita, desde la Frontera, sin repetir los Vistos.
anchura([], _M, _Vistos, []).
anchura([Q|Qs], M, Vistos, [Q|Orden]) :-
    findall(S-Q1, delta(M, Q, S, Q1), Arcos0),
    sort(Arcos0, Arcos),
    pairs_values(Arcos, Siguientes),
    nuevos(Siguientes, Vistos, Nuevos, Vistos1),
    append(Qs, Nuevos, Frontera),
    anchura(Frontera, M, Vistos1, Orden).

%!  nuevos(+Qs:list, +Vistos0:list, -Nuevos:list, -Vistos:list) is det.
%
%   Nuevos son los estados de Qs que no están en Vistos0, en el orden de
%   Qs y sin repetir; Vistos es Vistos0 con ellos.
nuevos([], Vistos, [], Vistos).
nuevos([Q|Qs], Vistos0, Nuevos, Vistos) :-
    (   memberchk(Q, Vistos0)
    ->  Nuevos = Nuevos1,
        Vistos1 = Vistos0
    ;   Nuevos = [Q|Nuevos1],
        Vistos1 = [Q|Vistos0]
    ),
    nuevos(Qs, Vistos1, Nuevos1, Vistos).
