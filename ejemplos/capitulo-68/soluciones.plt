:- encoding(utf8).

:- begin_tests(soluciones).

test(ejemplos_de, [true(N-P == 36-12)]) :-
    ejemplos_de(pieza(_, rojo, _, _), Ejs),
    length(Ejs, N),
    aggregate_all(count, member(pos(_), Ejs), P).

test(todos_convergen, [true]) :-
    todos_convergen.

test(vacio_colapsa, [true(EV-E == ev([vacio], [])-colapso)]) :-
    ejemplos_de(vacio, Ejs),
    eliminar(Ejs, EV),
    estado(EV, E).

test(interior_fuera_del_lenguaje, [true(C =@= pieza(esfera, A, chico, madera, A))]) :-
    con_interior(( generalizacion(pieza(esfera, rojo, chico, madera, rojo),
                                  pieza(esfera, verde, chico, madera, verde),
                                  C),
                   \+ ( concepto(D), D =@= C ) )).

test(interior_ingenua, [true(C =@= pieza(esfera, _, chico, madera, _))]) :-
    generalizacion_ingenua(pieza(esfera, rojo, chico, madera, rojo),
                           pieza(esfera, verde, chico, madera, verde), C).

test(interior_se_quita, [true(N == 4)]) :-
    con_interior(true),
    aggregate_all(count, atributo(_, _), N).

test(cuenta_clases, [true(P-N-D == 4-16-16)]) :-
    cuenta_clases(P, N, D).

test(desconocidas, [true]) :-
    desconocidas_esperadas.

test(promedio_inverso, [true(P =:= 18.74)]) :-
    promedio_inverso(P).

test(descarte_tercero, [true(D == [neg(pieza(esfera, rojo, grande, madera))])]) :-
    eliminar_con_descarte_de(3, EV, D),
    estado(EV, convergio(_)).

test(descarte_primero, [true(D == [pos(pieza(esfera, rojo, grande, metal))])]) :-
    eliminar_con_descarte_de(0, _, D).

test(reglas_abuelo, [true(L == 2)]) :-
    reglas_abuelo(Rs),
    length(Rs, L).

test(cobertura_abuelo, [true(P-N == 3-0)]) :-
    cobertura_abuelo(P, N).

test(reglas_de_tazas, [true(L == 2)]) :-
    reglas_de_tazas(Rs),
    length(Rs, L).

test(costo_crece, [true]) :-
    costo_con(2, N2),
    costo_con(4, N4),
    costo_con(8, N8),
    N2 < N4,
    N4 < N8.

test(relevantes, [true(L == 9)]) :-
    relevantes(taza, taza1, taza(taza1), U),
    length(U, L).

test(irrelevantes, [true(O == [material(taza1, loza), color(taza1, blanco),
                               color(cuerpo1, blanco)])]) :-
    irrelevantes(taza, taza1, taza(taza1), O).

test(relevantes_familia, [true(U == [varon(juan), padre(juan, pedro),
                                     padre(pedro, luis)])]) :-
    relevantes(familia, familia, abuelo(juan, luis), U).

test(eliminar_todos, [true(EV =@= ev([pieza(A, verde, B, metal)],
                                     [pieza(C, verde, D, metal)]))]) :-
    eliminar_todos(pieza(_, verde, _, metal), EV),
    EV = ev([pieza(A, _, B, _)], [pieza(C, _, D, _)]).

test(pasivo_inverso, [true(N-E =@= 7-convergio(pieza(_, verde, _, metal)))]) :-
    pasivo_inverso(pieza(_, verde, _, metal), N, E).

% El negativo contradice al positivo anterior: se descarta.
test(eliminar_con_descarte,
     [true(D == [neg(pieza(esfera, rojo, chico, madera))])]) :-
    eliminar_con_descarte([pos(pieza(esfera, rojo, chico, madera)),
                           neg(pieza(esfera, rojo, chico, madera))], EV, D),
    EV = ev([pieza(esfera, rojo, chico, madera)], _).

test(eliminar_con_descarte_vacio, [true(EV-D =@= ev([vacio], [T])-[])]) :-
    eliminar_con_descarte([], EV, D),
    inicial(ev(_, [T])).

test(con_descarte_acepta, [true(Ds == [x])]) :-
    inicial(EV0),
    con_descarte(pos(pieza(cubo, azul, chico, metal)), EV0-[x], EV-Ds),
    EV = ev([pieza(cubo, azul, chico, metal)], _).

test(sin_subsumidas, [true(Rs =@= [(p(X) :- [q(X)]), (r(Y) :- [])])]) :-
    sin_subsumidas([(p(X) :- [q(X)]), (p(a) :- [q(a), s(a)]), (r(Y) :- []),
                    (r(b) :- [])], Rs).

test(sin_subsumidas_vacia, [true(Rs == [])]) :-
    sin_subsumidas([], Rs).

:- end_tests(soluciones).
