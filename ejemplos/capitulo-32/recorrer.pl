:- encoding(utf8).

% Capítulo 32 - Recorrer cualquier término: subtérminos, sustitución y el
% recorrido genérico, escrito a mano y con library(terms).
%
% subtermino_ingenuo/2 compara con unificación y liga las variables del
% término que examina; subtermino/2 enumera los subtérminos sin ligar nada,
% y contiene/2 compara con ==. transformar/3 es el recorrido genérico: la
% operación que se aplica a cada nodo es un argumento.
%
%?- subtermino(S, f(a, g(b))).
%?- sustituir(x, 3, x * x + y, T).
%?- transformar(duplicar, f(1, g(2), a), T).

:- use_module(library(terms)).

:- meta_predicate transformar(2, +, -).

%!  subtermino_ingenuo(?S, +Termino) is nondet.
%
%   S es un subtérmino de Termino: Termino mismo o un subtérmino de alguno de
%   sus argumentos. Compara por unificación, así que liga las variables de
%   Termino.
subtermino_ingenuo(S, S).
subtermino_ingenuo(S, T) :-
    compound(T),
    T =.. [_|Args],
    member(A, Args),
    subtermino_ingenuo(S, A).

%!  subtermino(-S, +Termino) is multi.
%
%   S es un subtérmino de Termino, en preorden: primero Termino, después los
%   subtérminos de cada argumento, de izquierda a derecha. S debe llegar
%   libre; las variables de Termino se enumeran como subtérminos, sin
%   ligarlas.
subtermino(T, T).
subtermino(S, T) :-
    compound(T),
    arg(_, T, A),
    subtermino(S, A).

%!  contiene(+Termino, @S) is semidet.
%
%   S aparece en Termino: es idéntico (==) a alguno de sus subtérminos.
contiene(T, S) :-
    subtermino(X, T),
    X == S,
    !.

%!  sustituir(@Viejo, ?Nuevo, +Termino0, -Termino) is det.
%
%   Termino es Termino0 con Nuevo en el lugar de cada subtérmino idéntico
%   (==) a Viejo.
sustituir(Viejo, Nuevo, T0, T) :-
    (   T0 == Viejo
    ->  T = Nuevo
    ;   compound(T0)
    ->  mapargs(sustituir(Viejo, Nuevo), T0, T)
    ;   T = T0
    ).

%!  transformar(:P, +Termino0, -Termino) is det.
%
%   Termino es Termino0 transformado de abajo hacia arriba: primero se
%   transforman los argumentos, y después se aplica call(P, Nodo, Nuevo) al
%   nodo resultante, y se toma su primer resultado. Donde P falla, el nodo
%   queda como está. Las variables de Termino0 no se transforman.
transformar(P, T0, T) :-
    (   var(T0)
    ->  T = T0
    ;   (   compound(T0)
        ->  mapargs(transformar(P), T0, T1)
        ;   T1 = T0
        ),
        (   call(P, T1, T2)
        ->  T = T2
        ;   T = T1
        )
    ).

%!  duplicar(+N:number, -M:number) is semidet.
%
%   M es el doble de N. Falla si N no es un número.
duplicar(N, M) :-
    number(N),
    M is 2 * N.

%!  atomos(+Termino, -Atomos:list(atom)) is det.
%
%   Atomos es el conjunto ordenado de los átomos que aparecen en Termino.
atomos(T, Atomos) :-
    foldsubterms(agregar_atomo, T, [], Atomos).

%!  agregar_atomo(+Subtermino, +Conjunto0:list, -Conjunto:list) is semidet.
%
%   Conjunto es Conjunto0 con Subtermino agregado. Falla si Subtermino no
%   es un átomo, y entonces foldsubterms/4 sigue por sus argumentos.
agregar_atomo(X, Conjunto0, Conjunto) :-
    atom(X),
    ord_add_element(Conjunto0, X, Conjunto).
