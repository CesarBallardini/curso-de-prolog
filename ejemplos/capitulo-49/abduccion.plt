:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(fallas).

:- begin_tests(abduccion).

test(una_compuerta, [true(Ss == [[[g]-pegada(0)], [[g]-invertida]])]) :-
    findall(S, ( abducir(salida(fuerte, [g], and, [1, 1], 0), S),
                 cerrar(S) ),
            Ss).

% Un componente tiene un solo estado: el supuesto anterior se respeta.
test(supuesto_previo, [fail]) :-
    abducir(salida(fuerte, [g], and, [1, 1], 0), [[g]-ok|_]).

test(primero_sin_fallas, [nondet, true(D == [])]) :-
    diagnostico(fuerte, sumador, [[1, 0, 1]-[0, 1]], D).

test(cantidad, [true(N == 256)]) :-
    aggregate_all(count, diagnostico(fuerte, sumador, [[0, 0, 1]-[0, 1]], _),
                  N).

% Cada diagnóstico de la versión 2 explica la observación en la versión 1.
test(como_version_1, [true]) :-
    Obs = [[0, 0, 1]-[0, 1], [1, 1, 0]-[0, 1]],
    forall(diagnostico(fuerte, sumador, Obs, D),
           explica(sumador, Obs, D)).

% Las dos observaciones comparten los supuestos.
test(dos_observaciones, [true(N0 > N)]) :-
    aggregate_all(count, diagnostico(fuerte, sumador, [[0, 0, 1]-[0, 1]], _),
                  N0),
    aggregate_all(count, diagnostico(fuerte, sumador,
                                     [[0, 0, 1]-[0, 1], [1, 1, 0]-[0, 1]],
                                     _),
                  N).

:- end_tests(abduccion).
