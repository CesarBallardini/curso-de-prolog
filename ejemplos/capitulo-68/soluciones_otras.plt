:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(soluciones_otras).

% La primera hipótesis usa una sola cláusula, la más larga, para los
% tres ejemplos.
test(ej12, [true(H =@= [(abuelo(A, B) :- [varon(A), padre(A, C),
                                          progenitor(C, B)])])]) :-
    inducibles(abuelo, Is),
    modelo_fondo(M),
    ejemplos(abuelo, Pos, _),
    once(inducir_todos(Pos, Is, M, H)).

test(ej12_sin_instanciar, [fail]) :-
    inducibles(abuelo, Is),
    modelo_fondo(M),
    once(inducir_todos([abuelo(juan, luis)], Is, M, H)),
    ground(H).

test(ej12_fondo, [nondet, true(H == [])]) :-
    modelo_fondo(M),
    inducir_todos([padre(juan, pedro)], [], M, H).

test(ej12_falla, [fail]) :-
    modelo_fondo(M),
    inducir_todos([abuelo(ana, luis)], [], M, _).

test(inducir_general_reutiliza, [nondet, true(H == [R])]) :-
    R = (abuelo(A, B) :- [padre(A, C), progenitor(C, B)]),
    modelo_fondo(M),
    inducir_general([], M, abuelo(pedro, sofia), [R], H).

test(ej13, [true(H =@= [(listnum([A|B], [C|D]) :- [listnum(B, D), num(C, A)]),
                        (listnum([E|F], [G|I]) :- [listnum(F, I), num(E, G)]),
                        (listnum([], []) :- [])])]) :-
    numerales_corregidos(H).

:- end_tests(soluciones_otras).
