:- encoding(utf8).

:- begin_tests(hechos).

test(juan_es_padre_de_ana) :-
    padre(juan, ana).

test(ana_no_es_padre_de_juan, [fail]) :-
    padre(ana, juan).

test(marta_es_madre_de_dos, all(H == [ana, pedro])) :-
    madre(marta, H).

% Ningún hecho indica quién es el padre de sofia: no se puede probar.
test(sofia_no_tiene_padre_conocido, [fail]) :-
    padre(_, sofia).

test(cuatro_mujeres, all(P == [marta, ana, eva, sofia])) :-
    mujer(P).

% Un predicado no definido no responde false: produce un error.
test(hermano_no_existe, [throws(error(existence_error(procedure, _), _))]) :-
    hechos:hermano(ana, pedro).

:- end_tests(hechos).
