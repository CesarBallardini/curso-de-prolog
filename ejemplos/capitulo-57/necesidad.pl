:- encoding(utf8).

% Capítulo 57 - Versión 5: evaluación perezosa por necesidad.
%
% Agrega a perezoso.pl una segunda clase de promesa, memo(E, Entorno,
% Valor), cuyo tercer argumento es una variable libre hasta que la promesa
% se fuerza por primera vez. forzar/3 la liga entonces al valor, y las
% veces siguientes la encuentra instanciada y no vuelve a evaluar nada.
% Como la promesa es un término, todos los lugares que la comparten (el
% entorno de cada clausura, la cola de una lista, la tabla de las
% definiciones) ven la misma variable: la unificación hace de memoria.
%
% solo-local: carga perezoso.pl, y SWISH no carga otros archivos.
%
%?- ejecutar_perezoso(necesidad, "tomar 10 primos", "", V).
%?- ejecutar_perezoso(necesidad, "nesimo 50 fibs", "", V).

:- ensure_loaded(perezoso).

% prometer/4, declarada en perezoso.pl: la promesa por necesidad.
prometer(necesidad, E, Ent, memo(E, Ent, _)).

% forzar/3, declarada en perezoso.pl: la primera vez que se fuerza una
% promesa por necesidad se evalúa y se liga su tercer argumento; las demás
% veces se usa ese valor.
forzar(memo(E, Ent, Valor), Ctx, V) :-
    (   nonvar(Valor)
    ->  V = Valor
    ;   valor_perezoso(E, Ent, Ctx, V),
        Valor = V
    ).
