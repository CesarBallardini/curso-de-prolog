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

% Las tres reglas del modelo fuerte, en el orden en que se prueban.
test(regla_fuerte, all(B == [(estado([g], ok), tabla(and, [1, 1], 1)),
                             (bit(1), estado([g], pegada(1)))])) :-
    abduccion:regla(salida(fuerte, [g], and, [1, 1], 1), B),
    B \= (estado(_, invertida), _).

test(regla_hecho, all(B == [true])) :-
    abduccion:regla(negacion(0, 1), B).

% Con la salida libre, la conducta abductiva da una salida por estado.
test(abductiva, all(S-Sp == [1-[[g]-ok], 0-[[g]-pegada(0)],
                             1-[[g]-pegada(1)], 0-[[g]-invertida]])) :-
    abductiva(fuerte, Sp, [g], or, [0, 1], S),
    cerrar(Sp).

test(explicar, all(S == [[[x1]-ok, [y1]-ok], [[x1]-ok, [y1]-pegada(1)],
                         [[x1]-pegada(0), [y1]-ok],
                         [[x1]-pegada(0), [y1]-pegada(1)]])) :-
    explicar(fuerte, semisumador, [[1, 1]-[0, 1]], S).

test(observar, all(S == [[[x1]-ok, [y1]-ok], [[x1]-ok, [y1]-pegada(1)],
                         [[x1]-pegada(0), [y1]-ok],
                         [[x1]-pegada(0), [y1]-pegada(1)]])) :-
    abduccion:observar(fuerte, semisumador, S, [1, 1]-[0, 1]),
    cerrar(S).

test(sin_observaciones, all(D == [[]])) :-
    diagnostico(fuerte, sumador, [], D).

test(cerrar_libre, [true(D == [])]) :-
    cerrar(D).

test(cerrar_abierto, [true(D == [a, b])]) :-
    D = [a, b|_],
    cerrar(D).

test(fallas, [true(F == [[a]-pegada(0), [c]-invertida])]) :-
    fallas([[b]-ok, [c]-invertida, [a]-pegada(0)], F).

:- end_tests(abduccion).
