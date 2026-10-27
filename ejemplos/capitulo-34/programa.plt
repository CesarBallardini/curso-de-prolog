:- encoding(utf8).

:- begin_tests(programa).

% Un hecho tiene el cuerpo true.
test(clause_hecho, all(H-C == [ana-true, pedro-true])) :-
    clause(padre(juan, H), C).

% El cuerpo de una regla es un término: la conjunción es ','/2.
test(clause_regla, true(C =@= (padre(A, P), padre(P, N)))) :-
    clause(abuelo(A, N), C).

test(clause_dinamico, all(P == [ana])) :-
    clause(visita(P), true).

% clause/2 falla, sin error, con un predicado que no existe.
test(clause_no_definido, [fail]) :-
    clause(no_definido(_), _).

test(clause_predefinido,
     [error(permission_error(access, private_procedure, atom_length/2))]) :-
    clause(atom_length(_, _), _).

test(clause_libre, [error(instantiation_error)]) :-
    clause(_, _).

test(clausulas, true(Cs =@= [ (antepasado(A, D) :- padre(A, D)),
                              (antepasado(B, E) :- padre(B, H),
                                                   antepasado(H, E)) ])) :-
    clausulas(antepasado/2, Cs).

test(clausulas_no_definido, [fail]) :-
    clausulas(no_definido/3, _).

test(describir_estatico, true(D == estatico(2))) :-
    describir(antepasado/2, D).

test(describir_dinamico, true(D == dinamico(1))) :-
    describir(visita/1, D).

test(describir_predefinido, true(D == predefinido)) :-
    describir(atom_length/2, D).

test(describir_no_definido, [fail]) :-
    describir(no_definido/1, _).

% La cantidad de cláusulas de un predicado dinámico cambia con assertz/1.
test(describir_despues_de_assertz,
     [ setup(assertz(user:visita(luis))),
       cleanup(retract(user:visita(luis))),
       true(D == dinamico(2)) ]) :-
    describir(visita/1, D).

:- end_tests(programa).
