:- encoding(utf8).

% Capítulo 48 - Retardos en cascada y el registro de N etapas.
%
% Clocksin (Clause and Effect, 8.5) define un retardo unitario, cuya salida
% es la entrada del pulso anterior, y conecta N retardos en serie con una
% recursión sobre la lista de sus estados: la cantidad de etapas es la
% longitud de esa lista, no una constante del programa. retardo/4 es esa
% cascada, y retardar/3 la recorre pulso a pulso con foldl/6. El mismo
% circuito, descrito para el simulador del capítulo, es un registro de
% desplazamiento de N etapas: la regla de circuitos:circuito/3 genera los
% nombres de sus cables a partir de N.
%
% solo-local: carga los módulos circuitos y secuenciales, y SWISH no admite
% módulos propios.
%
%?- retardar([1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 0], Qs).
%?- ejecutar(desplazamiento(3), [0, 0, 0], [[1], [1], [0], [0]], Ss).

:- module(retardos,
          [ retardo/4,
            retardar/3,
            etapas/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(circuitos).
:- reexport(secuenciales).

:- multifile circuitos:circuito/3, secuenciales:secuencial/3.

%!  retardo(?Estado0:list, ?A, ?Q, ?Estado:list) is det.
%
%   Una cascada de tantos retardos unitarios como elementos tiene Estado0:
%   con la entrada A, la salida es Q, el estado de la última etapa, y
%   Estado es el estado del pulso siguiente: la primera etapa toma A, y
%   cada una de las demás, el estado de la anterior. Sin etapas, Q es A.
%   Estado0 o Estado debe tener longitud conocida. El estado va primero,
%   para que la indexación distinga la lista vacía de la que no lo es.
retardo([], A, A, []).
retardo([S|Ss], A, Q, [A|Zs]) :-
    retardo(Ss, S, Q, Zs).

%!  retardar(?Entradas:list, +Estado0:list, ?Salidas:list) is det.
%
%   Salidas son las salidas de la cascada de retardo/4 en cada pulso,
%   desde el Estado0, cuando Entradas son sus entradas. Una de las dos
%   listas debe tener longitud conocida.
retardar(Entradas, Estado0, Salidas) :-
    foldl(retardo_en_pulso, Entradas, Salidas, Estado0, _).

%!  retardo_en_pulso(?A, ?Q, +Estado0:list, -Estado:list) is det.
%
%   retardo/4 con los argumentos en el orden de foldl/6.
retardo_en_pulso(A, Q, Estado0, Estado) :-
    retardo(Estado0, A, Q, Estado).

%!  etapas(+N:integer, -Nombres:list(atom)) is det.
%
%   Nombres son los nombres de los cables de estado de un registro de N
%   etapas: q1, q2, ..., qN.
etapas(N, Nombres) :-
    findall(Q,
            ( between(1, N, I),
              atom_concat(q, I, Q) ),
            Nombres).

% desplazamiento(N): un registro de desplazamiento de N etapas, para
% cualquier N positivo. La parte combinacional son solo cables: la salida
% es la última etapa, la entrada pasa a la primera y cada etapa a la
% siguiente.
secuenciales:secuencial(desplazamiento(N), desplazamiento_c(N), N) :-
    integer(N),
    N > 0.

circuitos:circuito(desplazamiento_c(N), [x|Qs], [Ultima, x|Previas]) :-
    integer(N),
    N > 0,
    etapas(N, Qs),
    N1 is N - 1,
    length(Previas, N1),
    append(Previas, [Ultima], Qs).
