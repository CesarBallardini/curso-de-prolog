:- encoding(utf8).

% Capítulo 57 - El intérprete funcional terminado.
%
% Carga las cinco versiones. lam/2 y lam/3 evalúan una expresión del
% lenguaje objeto, escrita como texto, por necesidad (necesidad.pl).
% inferencias/3 mide cuántas inferencias cuesta evaluar una expresión ya
% leída, con el evaluador estricto de entornos.pl o con uno de los dos
% perezosos; tabla_de_evaluacion/1 compara los tres, y
% tabla_de_sustitucion/1 compara la versión 1 con la 2 al invertir listas.
%
% solo-local: carga necesidad.pl, y SWISH no carga otros archivos.
%
%?- lam("map (fun x -> x * x) [1, 2, 3]", V).
%?- lam("tomar 10 primos", V).
%?- tabla_de_evaluacion(["suma (hasta 1 100)", "tomar 5 (desde 1)"]).

:- ensure_loaded(sustitucion).
:- ensure_loaded(necesidad).

%!  lam(+Texto, -Valor) is det.
%
%   Valor es el resultado de evaluar por necesidad la expresión de Texto,
%   con las definiciones del preludio.
lam(Texto, V) :-
    lam(Texto, "", V).

%!  lam(+Texto, +Definiciones, -Valor) is det.
%
%   Como lam/2, con las Definiciones de un segundo texto delante de las
%   del preludio.
lam(Texto, Definiciones, V) :-
    ejecutar_perezoso(necesidad, Texto, Definiciones, V).

%!  inferencias(+Modo, +Texto, -Costo) is det.
%
%   Costo es la cantidad de inferencias que usa la evaluación de la
%   expresión de Texto con el preludio, sin contar la lectura. Modo es
%   estricto (entornos.pl), nombre o necesidad. Costo es limite si la
%   evaluación pasa de 10 000 000 inferencias.
inferencias(Modo, Texto, Costo) :-
    preludio_leido(Prog),
    leer_expresion(Texto, E),
    meta_de(Modo, E, Prog, Meta),
    statistics(inferences, I0),
    call_with_inference_limit(Meta, 10_000_000, R),
    statistics(inferences, I1),
    (   R == inference_limit_exceeded
    ->  Costo = limite
    ;   Costo is I1 - I0
    ).

%!  meta_de(+Modo, +E, +Programa:list, -Meta) is det.
%
%   Meta evalúa la expresión E con el Programa en el Modo dado.
meta_de(estricto, E, Prog, evaluar(E, [], Prog, _)).
meta_de(nombre, E, Prog, Meta) :-
    meta_perezosa(nombre, E, Prog, Meta).
meta_de(necesidad, E, Prog, Meta) :-
    meta_perezosa(necesidad, E, Prog, Meta).

%!  meta_perezosa(+Modo, +E, +Programa:list, -Meta) is det.
%
%   Meta evalúa E por completo con promesas de la clase Modo.
meta_perezosa(Modo, E, Prog, Meta) :-
    contexto(Modo, Prog, Ctx),
    Meta = ( valor_perezoso(E, [], Ctx, V0),
             forzar_todo(V0, Ctx, _) ).

%!  tabla_de_evaluacion(+Textos:list) is det.
%
%   Escribe una fila por cada expresión de Textos con las inferencias de
%   los tres modos de evaluación.
tabla_de_evaluacion(Textos) :-
    format("~w~t~36|~t~w~48|~t~w~60|~t~w~72|~n",
           [expresion, estricto, nombre, necesidad]),
    forall(member(T, Textos), fila_de_evaluacion(T)).

%!  fila_de_evaluacion(+Texto) is det.
%
%   Escribe la fila de la expresión de Texto.
fila_de_evaluacion(Texto) :-
    maplist([M, C]>>inferencias(M, Texto, C),
            [estricto, nombre, necesidad], [A, B, C]),
    maplist(celda, [A, B, C], [Ca, Cb, Cc]),
    format("~s~t~36|~t~w~48|~t~w~60|~t~w~72|~n",
           [Texto, Ca, Cb, Cc]).

%!  celda(+Costo, -Celda) is det.
%
%   Celda es el texto de un Costo: el número, o un guion si es limite.
celda(limite, -) :-
    !.
celda(I, I).

%!  tabla_de_sustitucion(+Ns:list(integer)) is det.
%
%   Escribe, para cada N de Ns, las inferencias de invertir la lista de 1
%   a N con la versión 1 (sustitución) y con la versión 2 (entornos).
tabla_de_sustitucion(Ns) :-
    format("~w~t~6|~t~w~20|~t~w~32|~n", [n, sustitucion, entornos]),
    forall(member(N, Ns), fila_de_sustitucion(N)).

%!  fila_de_sustitucion(+N:integer) is det.
%
%   Escribe la fila de la lista de 1 a N.
fila_de_sustitucion(N) :-
    numlist(1, N, L),
    programa_ejemplo(Prog),
    contar(valor(invertir@[L], _), A),
    contar(evaluar(ap(id(invertir), id(l)), [l-L], Prog, _), B),
    format("~d~t~6|~t~d~20|~t~d~32|~n", [N, A, B]).

%!  contar(:Meta, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa Meta, que debe cumplirse.
contar(Meta, I) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    I is I1 - I0.
