:- encoding(utf8).

% Capítulo 52 - Versión 4: la traza de las configuraciones completas y
% la medida de un cómputo.
%
% Una configuración completa (Turing, §2) es la configuración m, la cinta
% y la casilla leída. configuraciones/5 es pura: da la lista de las
% configuraciones completas de los primeros pasos, como términos
% conf(N, Q, Cinta), con Q ya resuelta por los alias; linea/2 convierte
% una en una cadena, y traza/4 escribe las líneas. En la cadena, ə es el
% átomo schwa, un punto es una casilla en blanco y la casilla leída va
% entre corchetes.
%
% medir/4 ejecuta una máquina hasta que imprime N figuras y cuenta los
% pasos que tocan la cinta, las reescrituras con alias y el tamaño mayor
% que alcanzó el término de la configuración.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- traza(ii, b, 6).
%?- medir(contador, inicio, 15, M).

:- module(traza, [configuraciones/5, linea/2, traza/3, traza/4, medir/4,
                  tamano/2]).

:- reexport(biblioteca).

%!  configuraciones(+M, +Q0, +Cinta0, +N:integer, -Cs:list) is det.
%
%   Cs son las configuraciones completas conf(I, Q, Cinta) de los
%   primeros N pasos de M desde Q0 con la Cinta0, numeradas desde 1. Q
%   es la configuración resuelta por los alias. La lista es más corta si
%   la máquina se detiene: la última configuración es la detenida.
configuraciones(M, Q0, Cinta0, N, Cs) :-
    configuraciones(M, Q0, Cinta0, 1, N, Cs).

%!  configuraciones(+M, +Q, +Cinta, +I:integer, +N:integer, -Cs:list) is det.
%
%   Cs son las configuraciones completas desde el paso I hasta el N.
configuraciones(M, Q, Cinta, I, N, Cs) :-
    (   I > N
    ->  Cs = []
    ;   resolver(M, Q, Qr, _),
        Cs = [conf(I, Qr, Cinta)|Cs1],
        (   paso(M, Q, Cinta, Q1, Cinta1, _)
        ->  I1 is I + 1,
            configuraciones(M, Q1, Cinta1, I1, N, Cs1)
        ;   Cs1 = []
        )
    ).

%!  linea(+Conf, -Linea:string) is det.
%
%   Linea es la configuración completa Conf escrita en una línea: el
%   número de paso, la cinta y la configuración m.
linea(conf(I, Q, c(Izq, S, Der)), Linea) :-
    reverse(Izq, Izq1),
    maplist(glifo, Izq1, Gs1),
    glifo(S, G),
    maplist(glifo, Der, Gs2),
    atomic_list_concat(Gs1, A1),
    atomic_list_concat(Gs2, A2),
    format(string(Linea), "~t~d~3|  ~w[~w]~w~t~22|~p", [I, A1, G, A2, Q]).

%!  glifo(+S, -G) is det.
%
%   G es el carácter con el que se escribe el símbolo S en una traza.
glifo(S, G) :-
    (   S == schwa
    ->  G = 'ə'
    ;   S == blanco
    ->  G = '.'
    ;   G = S
    ).

%!  traza(+M, +Q0, +N:integer) is det.
%
%   Escribe las configuraciones completas de los primeros N pasos de M
%   desde Q0 con la cinta en blanco.
traza(M, Q0, N) :-
    cinta_vacia(Cinta),
    traza(M, Q0, Cinta, N).

%!  traza(+M, +Q0, +Cinta0, +N:integer) is det.
%
%   Escribe las configuraciones completas de los primeros N pasos de M
%   desde Q0 con la Cinta0.
traza(M, Q0, Cinta0, N) :-
    configuraciones(M, Q0, Cinta0, N, Cs),
    maplist(linea, Cs, Lineas),
    forall(member(L, Lineas), writeln(L)).

%!  medir(+M, +Q0, +N:integer, -Medida) is semidet.
%
%   Medida es medida(Pasos, Reescrituras, Tamano): la máquina M, desde Q0
%   con la cinta en blanco, imprime N figuras en Pasos pasos que tocan
%   la cinta y Reescrituras reescrituras con alias, y el término mayor
%   por el que pasa tiene Tamano nodos. Falla si M se detiene antes.
medir(M, Q0, N, medida(Pasos, Reescrituras, Tamano)) :-
    cinta_vacia(Cinta),
    medir(M, Q0, Cinta, N, medida(0, 0, 0), medida(Pasos, Reescrituras,
                                                    Tamano)).

%!  medir(+M, +Q, +Cinta, +N:integer, +Medida0, -Medida) is semidet.
%
%   Medida es Medida0 más lo que cuesta imprimir N figuras desde Q.
medir(M, Q, Cinta, N, Medida0, Medida) :-
    (   N =< 0
    ->  Medida = Medida0
    ;   leer(Cinta, S),
        seleccionar(M, Q, S, Qr, R, _, _),
        paso(M, Q, Cinta, Q1, Cinta1, Fs),
        tamano(Q, T0),
        tamano(Qr, T1),
        Medida0 = medida(P0, R0, T),
        P1 is P0 + 1,
        R1 is R0 + R,
        Tmax is max(T, max(T0, T1)),
        length(Fs, K),
        N1 is N - K,
        medir(M, Q1, Cinta1, N1, medida(P1, R1, Tmax), Medida)
    ).

%!  tamano(+T, -N:integer) is det.
%
%   N es la cantidad de nodos del término T: uno por cada átomo, número
%   o variable, y uno por cada término compuesto más los de sus
%   argumentos.
tamano(T, N) :-
    (   compound(T)
    ->  T =.. [_|Args],
        foldl(sumar_tamano, Args, 1, N)
    ;   N = 1
    ).

%!  sumar_tamano(+T, +N0:integer, -N:integer) is det.
%
%   N es N0 más el tamaño de T.
sumar_tamano(T, N0, N) :-
    tamano(T, N1),
    N is N0 + N1.
