:- encoding(utf8).

% Capítulo 35 - Desplegar y plegar: dos transformaciones de programas que
% conservan lo que el programa prueba.
%
% Un programa es una lista de cláusulas Cabeza :- Cuerpo, con el cuerpo como
% lista de objetivos ([] para un hecho): los programas transformados son
% datos, no predicados cargados. desplegar/4 reemplaza un objetivo del
% cuerpo por el cuerpo de cada cláusula cuya cabeza unifica con él; plegar/4
% hace lo inverso, y reemplaza una parte del cuerpo por la cabeza de una
% definición. derivar/1 obtiene así una definición recursiva de
% consecutivos/3 a partir de la que usa append/3.
%
%?- desplegada(Cs).
%?- derivar(Cs).
%?- numlist(1, 5, L), consecutivos(X, Y, L).

% programa_append(P): P son las cláusulas de append/3 como datos.
programa_append([ (append([], L, L) :- []),
                  (append([X|Xs], Ys, [X|Zs]) :- [append(Xs, Ys, Zs)]) ]).

% definicion(D): X e Y están seguidos en la lista L.
definicion((consecutivos(X, Y, L) :- [append(_, [X, Y|_], L)])).

%!  desplegar(+Clausula, +N:integer, +Programa:list, -Clausulas:list) is det.
%
%   Clausulas son las resolventes de Clausula con las cláusulas de Programa
%   en el objetivo N de su cuerpo, contando desde 1.
desplegar((Cabeza :- Cuerpo), N, Programa, Clausulas) :-
    N1 is N - 1,
    length(Antes, N1),
    append(Antes, [Objetivo|Despues], Cuerpo),
    findall((Cabeza :- Cuerpo1),
            ( member(Clausula, Programa),
              copy_term(Clausula, (Objetivo :- CuerpoObjetivo)),
              append([Antes, CuerpoObjetivo, Despues], Cuerpo1) ),
            Clausulas).

%!  plegar(+Clausula, +N:integer, +Definicion, -Plegada) is semidet.
%
%   Plegada es Clausula con los objetivos desde la posición N, si son una
%   instancia del cuerpo de Definicion, reemplazados por su cabeza.
plegar((Cabeza :- Cuerpo), N, Definicion, (Cabeza :- Cuerpo1)) :-
    copy_term(Definicion, (CabezaDef :- CuerpoDef)),
    length(CuerpoDef, K),
    N1 is N - 1,
    length(Antes, N1),
    length(Medio, K),
    append(Antes, Resto, Cuerpo),
    append(Medio, Despues, Resto),
    subsumes_term(CuerpoDef, Medio),
    CuerpoDef = Medio,
    append(Antes, [CabezaDef|Despues], Cuerpo1).

%!  desplegada(-Clausulas:list) is det.
%
%   Clausulas es la definición de consecutivos/3 desplegada en su único
%   objetivo, con las cláusulas de append/3.
desplegada(Clausulas) :-
    definicion(D),
    programa_append(P),
    desplegar(D, 1, P, Clausulas).

%!  derivar(-Clausulas:list) is det.
%
%   Clausulas es la definición de consecutivos/3 sin append/3: la
%   definición desplegada, con la segunda resolvente plegada con la
%   definición.
derivar([C1, C2]) :-
    desplegada([C1, C2a]),
    definicion(D),
    plegar(C2a, 1, D, C2).

%!  consecutivos_append(?X, ?Y, ?L:list) is nondet.
%
%   X e Y están seguidos en L. Construye con append/3 la parte de L
%   anterior a X, y la descarta.
consecutivos_append(X, Y, L) :-
    append(_, [X, Y|_], L).

%!  consecutivos(?X, ?Y, ?L:list) is nondet.
%
%   X e Y están seguidos en L: las cláusulas que obtiene derivar/1.
consecutivos(X, Y, [X, Y|_]).
consecutivos(X, Y, [_|Zs]) :-
    consecutivos(X, Y, Zs).

%!  mostrar(+Clausulas:list) is det.
%
%   Escribe cada cláusula de Clausulas en una línea, con las variables
%   nombradas A, B, ..., y _ para las que aparecen una sola vez.
mostrar(Clausulas) :-
    forall(member(C, Clausulas),
           ( numbervars(C, 0, _, [singletons(true)]),
             format("~W~n", [C, [numbervars(true), quoted(true),
                                 spacing(next_argument)]]) )).
