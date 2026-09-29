:- encoding(utf8).

% Capítulo 35 - term_expansion/2 y goal_expansion/2: el programa se
% transforma mientras se carga.
%
% term_expansion/2 reemplaza cada término padres(P, Hijos) por un hecho
% padre(P, H) por cada hijo: el programa se escribe en la forma compacta y
% se carga en la forma que Prolog indexa. goal_expansion/2 reemplaza cada
% llamada a x_de/2 en el cuerpo de una cláusula por la unificación que
% hace x_de/2. Las dos expansiones se aplican solo a lo que se lee después de
% su definición: suma_llamando/2, escrita antes, llama a x_de/2; suma_x/2,
% escrita después con el mismo cuerpo, no la llama.
%
%?- padre(P, luis).
%?- puntos(3, Ps), suma_x(Ps, S).

%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Un término padres(P, Hijos) se reemplaza, al cargarlo, por un hecho
%   padre(P, H) por cada H de Hijos. Falla con cualquier otro término, que
%   se carga sin cambios.
term_expansion(padres(P, Hijos), Hechos) :-
    findall(padre(P, H), member(H, Hijos), Hechos).

% padres(P, Hijos): P es el padre de cada uno de los Hijos; se carga como
% un hecho padre/2 por hijo.
padres(juan, [ana, pedro]).
padres(ana, [luis]).
padres(luis, [eva]).

% x_de(P, X): X es la abscisa del punto P.
x_de(punto(X, _), X).

%!  suma_llamando(+Puntos:list, -S:number) is det.
%
%   S es la suma de las abscisas de Puntos. Está escrita antes de la
%   definición de goal_expansion/2: llama a x_de/2 en cada punto.
suma_llamando([], 0).
suma_llamando([P|Ps], S) :-
    x_de(P, X),
    suma_llamando(Ps, S0),
    S is S0 + X.

%!  goal_expansion(+Meta, -Expandida) is semidet.
%
%   Una llamada x_de(P, X) en el cuerpo de una cláusula se reemplaza por la
%   unificación de P con punto(X, _).
goal_expansion(x_de(P, X), P = punto(X, _)).

%!  suma_x(+Puntos:list, -S:number) is det.
%
%   La misma relación que suma_llamando/2, escrita después de
%   goal_expansion/2: la llamada a x_de/2 se carga como una unificación.
suma_x([], 0).
suma_x([P|Ps], S) :-
    x_de(P, X),
    suma_x(Ps, S0),
    S is S0 + X.

%!  puntos(+N:integer, -Puntos:list) is det.
%
%   Puntos tiene los N puntos punto(1, 0), punto(2, 0), ..., punto(N, 0).
puntos(N, Puntos) :-
    numlist(1, N, Xs),
    findall(punto(X, 0), member(X, Xs), Puntos).
