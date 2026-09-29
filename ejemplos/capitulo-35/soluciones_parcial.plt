:- encoding(utf8).

:- begin_tests(soluciones_parcial).

% Ejercicio 9: especializar el intérprete vainilla devuelve el programa.
test(vainilla, forall(member(P, [antepasado(_, _), mayor_que(_, _)]))) :-
    findall((P :- C), clause(P, C), Originales),
    findall(E, ( clause(P, C), especializar_vainilla((P :- C), E) ),
            Especializadas),
    assertion(Especializadas =@= Originales).

test(abuelo,
     true(C =@= (abuelo(A, N) :- padre(A, P), padre(P, N)))) :-
    especializar_vainilla((abuelo(A, N) :- padre(A, P), padre(P, N)), C).

% Ejercicio 10: un residuo por elemento.
test(es_letra,
     true(Cs == [ (es_letra(a) :- true), (es_letra(b) :- true),
                  (es_letra(c) :- true) ])) :-
    es_letra([a, b, c], Cs).

test(es_letra_vacia, true(Cs == [])) :-
    es_letra([], Cs).

:- end_tests(soluciones_parcial).
