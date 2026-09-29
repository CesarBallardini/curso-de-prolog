:- encoding(utf8).

% Capítulo 51 - Versión 7: transductores.
%
% Un transductor finito es un autómata cuyos símbolos son pares
% Entrada:Salida, donde Entrada y Salida son listas de símbolos: la
% cadena que la transición lee y la que escribe. [a]:[b] cambia a por b,
% [a]:[] borra a, y []:[e, s] inserta es. Se describe con las mismas
% relaciones del módulo automatas, y todo lo que se define para
% autómatas, como det/1, interseccion/2 o min/1, se aplica a él tomando
% cada par como un símbolo.
%
% transducir/3 relaciona una palabra de entrada con una de salida y se
% consulta en los dos sentidos: con la entrada da las salidas, y con la
% salida, las entradas. Una máquina de Mealy es el caso en el que cada
% transición lee un símbolo y escribe uno.
%
% Las construcciones propias de los transductores son otros nombres:
%
%   inversa(T)          intercambia la entrada y la salida de T;
%   compuesta(T1, T2)   la salida de T1 es la entrada de T2;
%   identidad(Sigma)    copia cada símbolo de la lista Sigma.
%
% El capítulo 53 carga este módulo para la morfología de dos niveles.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- transducir(gray, [1, 0, 1, 1], G).
%?- transducir(gray, B, [1, 1, 1, 0]).
%?- transducir(plural, [l, u, z], P).
%?- transducir(plural, W, [l, u, c, e, s]).

:- module(transductores,
          [ transducir/3,
            letra/1
          ]).

:- use_module(library(lists)).
:- reexport(minimizar).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

%!  transducir(+T, ?Entrada:list, ?Salida:list) is nondet.
%
%   El transductor T transforma la palabra Entrada en la palabra Salida:
%   hay un camino desde su estado inicial hasta uno final cuyas entradas,
%   concatenadas, son Entrada, y cuyas salidas son Salida. Una de las dos
%   palabras debe llegar ligada. Da cada par una vez, y termina si T no
%   tiene ciclos que lean nada en el sentido consultado.
transducir(T, Entrada, Salida) :-
    inicial(T, Q0),
    traducir(T, Q0, Entrada, Salida, Q),
    final(T, Q).

:- table traducir/5.

%!  traducir(+T, +Q0, ?Entrada:list, ?Salida:list, -Q) is nondet.
%
%   T pasa de Q0 a Q leyendo Entrada y escribiendo Salida. Tabulada: los
%   ciclos de transiciones ε no impiden que termine, y cada respuesta
%   aparece una vez.
traducir(_T, Q, [], [], Q).
traducir(T, Q0, Entrada, Salida, Q) :-
    epsilon(T, Q0, Q1),
    traducir(T, Q1, Entrada, Salida, Q).
traducir(T, Q0, Entrada, Salida, Q) :-
    delta(T, Q0, E:S, Q1),
    E-S \== []-[],
    append(E, Entrada1, Entrada),
    append(S, Salida1, Salida),
    traducir(T, Q1, Entrada1, Salida1, Q).

% inversa(T): los pares de T, al revés.

automatas:alfabeto(inversa(T), Sigma) :-
    alfabeto(T, Sigma0),
    findall(S:E, member(E:S, Sigma0), Sigma1),
    sort(Sigma1, Sigma).
automatas:inicial(inversa(T), Q0) :-
    inicial(T, Q0).
automatas:final(inversa(T), Q) :-
    final(T, Q).
automatas:delta(inversa(T), Q, S:E, Q1) :-
    delta(T, Q, E:S, Q1).
automatas:epsilon(inversa(T), Q, Q1) :-
    epsilon(T, Q, Q1).

% compuesta(T1, T2): los estados son pares Q1-Q2. Una transición de T1
% que escribe un símbolo avanza con una de T2 que lo lee; las que escriben
% la palabra vacía, y las de T2 que no leen nada, avanzan solas. Las
% transiciones deben leer y escribir a lo sumo un símbolo.

automatas:inicial(compuesta(T1, T2), Q1-Q2) :-
    inicial(T1, Q1),
    inicial(T2, Q2).
automatas:final(compuesta(T1, T2), Q1-Q2) :-
    final(T1, Q1),
    final(T2, Q2).
automatas:delta(compuesta(T1, T2), Q1-Q2, E:S, R1-R2) :-
    delta(T1, Q1, E:[M], R1),
    delta(T2, Q2, [M]:S, R2).
automatas:delta(compuesta(T1, _T2), Q1-Q2, E:[], R1-Q2) :-
    delta(T1, Q1, E:[], R1).
automatas:delta(compuesta(_T1, T2), Q1-Q2, []:S, Q1-R2) :-
    delta(T2, Q2, []:S, R2).
automatas:epsilon(compuesta(T1, _T2), Q1-Q2, R1-Q2) :-
    epsilon(T1, Q1, R1).
automatas:epsilon(compuesta(_T1, T2), Q1-Q2, Q1-R2) :-
    epsilon(T2, Q2, R2).

% identidad(Sigma): un solo estado, inicial y final, que copia cada
% símbolo de Sigma.

automatas:alfabeto(identidad(Sigma), Pares) :-
    findall([S]:[S], member(S, Sigma), Pares0),
    sort(Pares0, Pares).
automatas:inicial(identidad(_), q).
automatas:final(identidad(_), q).
automatas:delta(identidad(Sigma), q, [S]:[S], q) :-
    member(S, Sigma).

% gray: una máquina de Mealy que convierte un número binario, el bit más
% significativo primero, en su código Gray: cada bit de salida es el de
% entrada XOR el anterior. El estado es el bit anterior.

% alfabeto(gray, Pares): los pares que usa gray.
automatas:alfabeto(gray, [[0]:[0], [0]:[1], [1]:[0], [1]:[1]]).
automatas:inicial(gray, b0).
automatas:final(gray, b0).
automatas:final(gray, b1).
automatas:delta(gray, b0, [0]:[0], b0).
automatas:delta(gray, b0, [1]:[1], b1).
automatas:delta(gray, b1, [0]:[1], b0).
automatas:delta(gray, b1, [1]:[0], b1).

% plural: el plural de un sustantivo escrito en minúsculas, sin tildes:
% agrega s después de una vocal y es después de una consonante, y cambia
% la z final por c. Al leer una z, elige si es la última letra: si lo
% es, la escribe como c y solo puede terminar con es; si no, la copia y
% no puede terminar allí.

automatas:inicial(plural, inicio).
automatas:final(plural, fin).
automatas:delta(plural, Q, [L]:[L], Q1) :-
    member(Q, [inicio, vocal, consonante, z]),
    letra(L),
    L \== z,
    (   vocal(L)
    ->  Q1 = vocal
    ;   Q1 = consonante
    ).
automatas:delta(plural, Q, [z]:[z], z) :-
    member(Q, [inicio, vocal, consonante, z]).
automatas:delta(plural, Q, [z]:[c], z_final) :-
    member(Q, [inicio, vocal, consonante, z]).
automatas:delta(plural, vocal, []:[s], fin).
automatas:delta(plural, consonante, []:[e, s], fin).
automatas:delta(plural, z_final, []:[e, s], fin).

%!  letra(?L) is nondet.
%
%   L es una letra minúscula sin tilde.
letra(L) :-
    atom_chars(abcdefghijklmnopqrstuvwxyz, Ls),
    member(L, Ls).

% vocal(V): V es una vocal.
vocal(a).
vocal(e).
vocal(i).
vocal(o).
vocal(u).
