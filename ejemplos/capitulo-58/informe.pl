:- encoding(utf8).

% Capítulo 58 - El analizador terminado.
%
% informe/1 analiza un caso de concreto.pl con los tres análisis del
% capítulo y lo compara con las ejecuciones de la muestra. Escribe el
% programa y sus entradas; una fila por variable con su valor al terminar
% según cada análisis y el rango de valores concretos de la muestra; las
% alarmas de división por cero, las condiciones decididas y el código
% muerto (conjuntos es el análisis de signos.pl, signos e intervalos los
% dominios de reticulado.pl); y cuántas corridas de la muestra cubre cada
% análisis.
%
% solo-local: carga intervalos.pl con ensure_loaded/1.
%
%?- informe(cuenta).
%?- informe(cuadrado).

:- ensure_loaded(intervalos).

%!  informe(+Nombre) is semidet.
%
%   Escribe el informe del caso Nombre. Falla si Nombre no es un caso.
informe(Nombre) :-
    caso(Nombre, Entradas, Lineas),
    programa_caso(Nombre, P, Entradas),
    forall(member(L, Lineas), format("    ~s~n", [L])),
    format("entradas: ~w~n~n", [Entradas]),
    finales_signos(P, Entradas, Fs),
    muertas_signos(P, Entradas, Muertas),
    analisis(signos, P, Entradas, FS, OS),
    analisis(intervalos, P, Entradas, FI, OI),
    muestra(Nombre, Cs),
    format("~w~t~10|~w~t~26|~w~t~34|~w~t~50|~w~n",
           [variable, conjuntos, signos, intervalos, muestra]),
    variables(P, Xs),
    forall(member(X, Xs), fila(X, Fs, FS, FI, Cs)),
    nl,
    (   memberchk(error, Fs)
    ->  format("conjuntos: puede terminar dividiendo por cero~n")
    ;   true
    ),
    observaciones(signos, OS),
    observaciones(intervalos, OI),
    forall(member(S, Muertas),
           ( sentencia_texto(S, T),
             format("conjuntos: nunca se ejecuta ~w~n", [T]) )),
    cobertura(signos, FS, OS, Cs),
    cobertura(intervalos, FI, OI, Cs).

%!  fila(+X:atom, +Fs:list, +FS, +FI, +Cs:list) is det.
%
%   Escribe la fila de la variable X: sus signos en los estados finales Fs
%   de signos.pl, su valor en los estados FS y FI de los dos dominios de
%   reticulado.pl, y el rango de sus valores en las corridas Cs.
fila(X, Fs, FS, FI, Cs) :-
    findall(S, ( member(estado(E), Fs), valor(X, E, S) ), Ss0),
    sort(Ss0, Ss),
    atomic_list_concat(Ss, ',', Conjunto),
    valor_final(X, FS, VS),
    valor_final(X, FI, VI),
    rango_muestra(X, Cs, R),
    format("~w~t~10|{~w}~t~26|~w~t~34|~w~t~50|~w~n",
           [X, Conjunto, VS, VI, R]).

%!  valor_final(+X:atom, +E, -V) is det.
%
%   V es el valor de X en el estado final E, o nada si E no se alcanza.
valor_final(_, nada, nada).
valor_final(X, estado(_, Env), V) :-
    valor(X, Env, V).

%!  rango_muestra(+X:atom, +Cs:list, -R) is det.
%
%   R es el texto Min..Max, con los valores extremos de X en las corridas Cs que
%   terminan, o ninguna si ninguna termina.
rango_muestra(X, Cs, R) :-
    findall(N, ( member(corrida(_, fin(_, E)), Cs),
                 valor(X, E, N) ),
            Ns),
    (   Ns == []
    ->  R = ninguna
    ;   min_list(Ns, Min),
        max_list(Ns, Max),
        format(atom(R), "~w..~w", [Min, Max])
    ).

%!  observaciones(+D, +Obs:list) is det.
%
%   Escribe las alarmas de división y las condiciones decididas de Obs, las
%   observaciones del análisis en el dominio D.
observaciones(D, Obs) :-
    forall(member(O, Obs), observacion(D, O)).

%!  observacion(+D, +O) is det.
%
%   Escribe la observación O del dominio D, si es una alarma o una
%   condición decidida; escribe/2 no se escribe.
observacion(D, division(Exp, V)) :-
    en_texto(Exp, T),
    format("~w: el divisor de ~w puede ser cero (~w)~n", [D, T, V]).
observacion(D, nunca(C)) :-
    condicion_texto(C, T),
    format("~w: ~w nunca se cumple~n", [D, T]).
observacion(D, siempre(C)) :-
    condicion_texto(C, T),
    format("~w: ~w siempre se cumple~n", [D, T]).
observacion(_, escribe(_, _)).

%!  cobertura(+D, +Final, +Obs:list, +Cs:list) is det.
%
%   Escribe cuántas corridas de Cs cubre el resultado del dominio D.
cobertura(D, Final, Obs, Cs) :-
    length(Cs, N),
    aggregate_all(count, ( member(C, Cs), cubre(Final, Obs, C) ), K),
    format("~w: cubre ~d de ~d corridas~n", [D, K, N]).

%!  en_texto(+Exp, -T) is det.
%
%   T es la expresión de Mini Exp como término de Prolog, para escribirla.
en_texto(num(N), N).
en_texto(id(X), X).
en_texto(bin(Op, A, B), T) :-
    en_texto(A, TA),
    en_texto(B, TB),
    T =.. [Op, TA, TB].

%!  condicion_texto(+C, -T) is det.
%
%   T es el texto de la condición C.
condicion_texto(rel(Op, A, B), T) :-
    en_texto(A, TA),
    en_texto(B, TB),
    format(atom(T), "~w ~w ~w", [TA, Op, TB]).

%!  sentencia_texto(+S, -T) is det.
%
%   T es un texto breve de la sentencia S: la palabra y lo que la sigue.
sentencia_texto(asignar(X, E), T) :-
    en_texto(E, TE),
    format(atom(T), "~w := ~w", [X, TE]).
sentencia_texto(escribir(E), T) :-
    en_texto(E, TE),
    format(atom(T), "escribir ~w", [TE]).
sentencia_texto(si(C, _, _), T) :-
    condicion_texto(C, TC),
    format(atom(T), "si ~w", [TC]).
sentencia_texto(mientras(C, _), T) :-
    condicion_texto(C, TC),
    format(atom(T), "mientras ~w", [TC]).
