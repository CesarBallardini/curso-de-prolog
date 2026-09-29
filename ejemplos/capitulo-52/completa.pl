:- encoding(utf8).

% Capítulo 52 - Versión 5: la tabla completa, por expansión anticipada.
%
% Turing (§4) llama tabla completa a la que se obtiene de las tablas
% esqueleto por sustitución repetida: una tabla sin funciones de
% configuración, con una fila por cada configuración m y cada símbolo. La
% expansión la construye antes de ejecutar: recorre a lo ancho las
% configuraciones alcanzables desde la inicial, prueba cada una con cada
% símbolo del alfabeto y el blanco, y anota la instrucción
%
%   i(Q, S, Operaciones, Q1)
%
% cuando alguna fila se aplica. Las configuraciones se numeran en el orden
% en que aparecen. El recorrido termina solo si las configuraciones
% alcanzables son finitas; con infinitas, se detiene al pasar del límite
% y da incompleta(Estados).
%
% La cola del recorrido es una lista abierta, como las del capítulo 34:
% la cola por procesar y la lista de todas las configuraciones son la misma
% lista, vista desde dos puntos.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- completa(ii, b, [0, 1, schwa, x], 100, tabla(Es, Is)), length(Is, N).
%?- completa(contador, inicio, [0, 1, schwa], 100, R).

:- module(completa, [transicion/5, completa/5, cuantas/5, expandir/5,
                     figuras_tabla/3]).

:- reexport(traza).
:- use_module(library(assoc)).
:- use_module(plana, [leer/2, operar/5]).

:- meta_predicate expandir(4, +, +, +, -).

%!  transicion(+M, +Q, +S, -Ops:list, -Q1) is semidet.
%
%   En la máquina M, desde la configuración Q y leyendo S, se ejecutan
%   las operaciones Ops y se pasa a Q1: un paso de la versión 2 escrito
%   como relación, sin la cinta.
transicion(M, Q, S, Ops, Q1) :-
    seleccionar(M, Q, S, _, _, Ops, Q1).

%!  completa(+M, +Q0, +Alfabeto:list, +Limite:integer, -R) is det.
%
%   R es tabla(Estados, Instrucciones), la tabla completa de M desde Q0
%   con los símbolos del Alfabeto y el blanco, o incompleta(Estados) si
%   hay más de Limite configuraciones alcanzables.
completa(M, Q0, Alfabeto, Limite, R) :-
    expandir(transicion(M), Q0, [blanco|Alfabeto], Limite, R).

%!  cuantas(+M, +Q0, +Alfabeto:list, +Limite:integer, -N) is det.
%
%   N es la cantidad de configuraciones de la tabla completa de M desde
%   Q0 con el Alfabeto, o mas_de(Limite) si son más de Limite.
cuantas(M, Q0, Alfabeto, Limite, N) :-
    completa(M, Q0, Alfabeto, Limite, R),
    (   R = tabla(Es, _)
    ->  length(Es, N)
    ;   N = mas_de(Limite)
    ).

%!  expandir(:Paso, +Q0, +Simbolos:list, +Limite:integer, -R) is det.
%
%   R es tabla(Estados, Instrucciones) con las configuraciones alcanzables
%   desde Q0 por la relación call(Paso, Q, S, A, Q1) con los Simbolos, en
%   orden de aparición, y una instrucción i(Q, S, A, Q1) por cada
%   configuración y símbolo con transición; o incompleta(Estados) si las
%   configuraciones son más de Limite.
expandir(Paso, Q0, Simbolos, Limite, R) :-
    list_to_assoc([Q0-1], Vistos),
    Estados = [Q0|Fin],
    recorrer(Estados, Fin, 1, Vistos, Paso, Simbolos, Limite, Is, R0),
    (   R0 == completa
    ->  R = tabla(Estados, Is)
    ;   R = incompleta(Estados)
    ).

%!  recorrer(?Cola, ?Fin, +N, +Vistos, :Paso, +Ss, +Limite, -Is, -R) is det.
%
%   Procesa las configuraciones de la lista abierta Cola, cuyo final
%   libre es Fin; N es la cantidad de configuraciones vistas, y Vistos,
%   el conjunto de ellas. Is son las instrucciones. R es completa si la
%   cola se vació, o limite si se pasó del Limite; en los dos casos
%   cierra la lista.
recorrer(Cola, Fin, N, Vistos, Paso, Ss, Limite, Is, R) :-
    (   var(Cola)
    ->  Fin = [],
        Is = [],
        R = completa
    ;   N > Limite
    ->  Fin = [],
        Is = [],
        R = limite
    ;   Cola = [Q|Cola1],
        instrucciones(Ss, Q, Paso, Vistos, Vistos1, Fin, Fin1, N, N1,
                      Is, Is1),
        recorrer(Cola1, Fin1, N1, Vistos1, Paso, Ss, Limite, Is1, R)
    ).

%!  instrucciones(+Ss, +Q, :Paso, +V0, -V, ?Fin0, ?Fin, +N0, -N, -Is, ?Is0)
%!      is det.
%
%   Is son las instrucciones de Q con los símbolos Ss, seguidas de Is0.
%   Cada configuración siguiente que no está en V0 se agrega a V y a la
%   cola, cuyo final libre pasa de Fin0 a Fin; N cuenta las vistas.
instrucciones([], _, _, V, V, Fin, Fin, N, N, Is, Is).
instrucciones([S|Ss], Q, Paso, V0, V, Fin0, Fin, N0, N, Is, Is0) :-
    (   call(Paso, Q, S, A, Q1)
    ->  Is = [i(Q, S, A, Q1)|Is1],
        (   get_assoc(Q1, V0, _)
        ->  V1 = V0,
            Fin1 = Fin0,
            N1 = N0
        ;   N1 is N0 + 1,
            put_assoc(Q1, V0, N1, V1),
            Fin0 = [Q1|Fin1]
        )
    ;   Is = Is1,
        V1 = V0,
        Fin1 = Fin0,
        N1 = N0
    ),
    instrucciones(Ss, Q, Paso, V1, V, Fin1, Fin, N1, N, Is1, Is0).

%!  figuras_tabla(+Tabla, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime la tabla completa Tabla,
%   ejecutada como una máquina sin alias ni parámetros desde su primera
%   configuración con la cinta en blanco.
figuras_tabla(tabla([Q0|_], Is), N, Fs) :-
    cinta_vacia(Cinta),
    figuras_tabla(Is, Q0, Cinta, N, Fs0),
    length(Fs, N),
    append(Fs, _, Fs0).

%!  figuras_tabla(+Is:list, +Q, +Cinta, +N:integer, -Fs:list) is semidet.
%
%   Fs son las figuras que imprimen las instrucciones Is desde Q con la
%   Cinta hasta haber impreso por lo menos N.
figuras_tabla(Is, Q, Cinta, N, Fs) :-
    (   N =< 0
    ->  Fs = []
    ;   leer(Cinta, S),
        memberchk(i(Q, S, Ops, Q1), Is),
        operar(Ops, Cinta, Cinta1, Fs1, []),
        length(Fs1, K),
        N1 is N - K,
        append(Fs1, Fs2, Fs),
        figuras_tabla(Is, Q1, Cinta1, N1, Fs2)
    ).
