:- encoding(utf8).

:- begin_tests(generaciones).

test(de_juan_a_ana, all(N == [1])) :-
    generaciones(juan, ana, N).

test(de_juan_a_eva, all(N == [3])) :-
    generaciones(juan, eva, N).

% Consulta en sentido inverso: quiénes están dos generaciones debajo de juan.
test(a_dos_escalones_de_juan, all(Q == [luis])) :-
    generaciones(juan, Q, 2).

test(todos_los_descendientes, all(Q-N == [ana-1, luis-2, eva-3])) :-
    generaciones(juan, Q, N).

test(eva_no_tiene_descendientes, [fail]) :-
    generaciones(eva, _, _).

test(nadie_desciende_de_si_mismo, [fail]) :-
    generaciones(ana, ana, _).

:- end_tests(generaciones).
