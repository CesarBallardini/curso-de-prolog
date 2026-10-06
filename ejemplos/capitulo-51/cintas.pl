:- encoding(utf8).

% Capítulo 51 - Pila vacía y varias cintas.
%
% Dos variantes de las máquinas de maquinas.pl. Un autómata de pila
% puede aceptar por pila vacía en lugar de por estado final: acepta W si,
% leída toda la palabra, la pila quedó vacía, en cualquier estado.
% vacia(M) es el autómata que acepta por pila vacía el lenguaje que M
% acepta por estado final: hace lo mismo que M y, en un estado final,
% puede pasar a vaciar la pila. La construcción supone, como cumplen los
% autómatas del capítulo, que M nunca desapila el fondo.
%
% Una máquina de Turing de varias cintas lee un símbolo en cada una,
% escribe uno en cada una y mueve cada cabezal por separado, a izq, a der
% o quieto. La entrada está en la primera cinta; las demás empiezan en
% blanco. Una transición es
%
%   turing_k(M, Q, Leidos, Escritos, Movimientos, Q1)
%
% con una lista de símbolos o de movimientos por cinta.
%
% solo-local: carga maquinas.pl, y SWISH no carga otros archivos.
%
%?- acepta_vacia(anbn, [a, a, b, b]).
%?- acepta_vacia(vacia(parentesis), ['(', ')']).
%?- turing_cintas(palindromo_2c, [a, b, b, a], 100, R).

:- ensure_loaded(maquinas).

:- multifile inicial/2, final/2, fondo/2, pila/6.
:- discontiguous inicial/2, final/2, fondo/2, pila/6.

% anbn acepta por pila vacía a^n b^n, con n de 0 en adelante: apila una a
% por cada a, desapila una por cada b, y quita el fondo al terminar.
inicial(anbn, q0).
fondo(anbn, z).
pila(anbn, q0, [a], X, [a, X], q0) :-
    member(X, [z, a]).
pila(anbn, q0, [b], a, [], q1).
pila(anbn, q1, [b], a, [], q1).
pila(anbn, Q, [], z, [], Q) :-
    member(Q, [q0, q1]).

% vacia(M): las transiciones de M, y desde un estado final, el paso al
% estado vaciar, que desapila todo sin leer.
inicial(vacia(M), Q0) :-
    inicial(M, Q0).
fondo(vacia(M), Z) :-
    fondo(M, Z).
pila(vacia(M), Q, Lee, X, Apila, Q1) :-
    pila(M, Q, Lee, X, Apila, Q1).
pila(vacia(M), Q, [], _X, [], vaciar) :-
    final(M, Q).
pila(vacia(_), vaciar, [], _X, [], vaciar).

%!  acepta_vacia(+M, ?W:list) is nondet.
%
%   El autómata de pila M acepta W por pila vacía: una respuesta por cada
%   cómputo que lee W y vacía la pila.
acepta_vacia(M, W) :-
    inicial(M, Q0),
    fondo(M, Z),
    vaciar(M, Q0, W, [Z]).

%!  vaciar(+M, +Q, ?W:list, +Pila:list) is nondet.
%
%   Desde el estado Q con la Pila, M lee W y termina con la pila vacía.
vaciar(_M, _Q, [], []).
vaciar(M, Q, W, [X|Pila]) :-
    pila(M, Q, Lee, X, Apila, Q1),
    append(Lee, W1, W),
    append(Apila, Pila, Pila1),
    vaciar(M, Q1, W1, Pila1).

% palindromo_2c reconoce los palíndromos sobre {a, b} con dos cintas:
% copia la entrada en la segunda, vuelve con el primer cabezal al
% comienzo, y compara la primera cinta hacia la derecha con la segunda
% hacia la izquierda.
inicial(palindromo_2c, copiar).
final(palindromo_2c, acepta).

% turing_k(M, Q, Leidos, Escritos, Movimientos, Q1): una transición de la
% máquina de Turing de varias cintas M.
turing_k(palindromo_2c, copiar, [S, blanco], [S, S], [der, der], copiar) :-
    member(S, [a, b]).
turing_k(palindromo_2c, copiar, [blanco, blanco], [blanco, blanco],
         [izq, izq], volver).
turing_k(palindromo_2c, volver, [S, T], [S, T], [izq, quieto], volver) :-
    member(S, [a, b]),
    member(T, [a, b, blanco]).
turing_k(palindromo_2c, volver, [blanco, T], [blanco, T], [der, quieto],
         comparar) :-
    member(T, [a, b, blanco]).
turing_k(palindromo_2c, comparar, [S, S], [S, S], [der, izq], comparar) :-
    member(S, [a, b]).
turing_k(palindromo_2c, comparar, [blanco, blanco], [blanco, blanco],
         [quieto, quieto], acepta).

%!  turing_cintas(+M, +Entrada:list, +Limite:integer, -R) is det.
%
%   R es el resultado de ejecutar la máquina de varias cintas M con la
%   Entrada en la primera, con a lo sumo Limite pasos: acepta(Cintas),
%   rechaza(Cintas) o limite(Q, Cintas), con el contenido de cada cinta.
turing_cintas(M, Entrada, Limite, R) :-
    inicial(M, Q0),
    once(turing_k(M, Q0, Leidos, _, _, _)),
    length(Leidos, K),
    (   Entrada = [S|Derecha]
    ->  true
    ;   S = blanco,
        Derecha = []
    ),
    K1 is K - 1,
    length(Vacias, K1),
    maplist(=(c([], blanco, [])), Vacias),
    ejecutar_cintas(M, Q0, [c([], S, Derecha)|Vacias], Limite, R).

%!  ejecutar_cintas(+M, +Q, +Cintas:list, +Limite:integer, -R) is det.
%
%   R es el resultado de continuar desde el estado Q con las Cintas, con
%   a lo sumo Limite pasos más.
ejecutar_cintas(M, Q, Cintas, Limite, R) :-
    maplist(bajo_cabezal, Cintas, Leidos),
    (   turing_k(M, Q, Leidos, Escritos, Movimientos, Q1)
    ->  (   Limite =:= 0
        ->  maplist(contenido, Cintas, Contenidos),
            R = limite(Q, Contenidos)
        ;   maplist(mover_cinta, Movimientos, Escritos, Cintas, Cintas1),
            Limite1 is Limite - 1,
            ejecutar_cintas(M, Q1, Cintas1, Limite1, R)
        )
    ;   maplist(contenido, Cintas, Contenidos),
        (   final(M, Q)
        ->  R = acepta(Contenidos)
        ;   R = rechaza(Contenidos)
        )
    ).

%!  bajo_cabezal(+Cinta, -S) is det.
%
%   S es el símbolo bajo el cabezal de la Cinta.
bajo_cabezal(c(_, S, _), S).

%!  mover_cinta(+Mov, +E, +Cinta0, -Cinta) is det.
%
%   Cinta es Cinta0 con E escrito bajo el cabezal y el cabezal movido
%   según Mov: izq, der o quieto.
mover_cinta(quieto, E, c(I, _, D), c(I, E, D)) :-
    !.
mover_cinta(Mov, E, Cinta0, Cinta) :-
    mover_cabezal(Mov, E, Cinta0, Cinta).

%!  pasos_cintas(+M, +W:list, -N:integer) is semidet.
%
%   N es la menor cantidad de pasos con la que la máquina de varias
%   cintas M se detiene con la entrada W, buscada entre 0 y 10 000.
pasos_cintas(M, W, N) :-
    between(0, 10000, N),
    turing_cintas(M, W, N, R),
    R \= limite(_, _),
    !.
