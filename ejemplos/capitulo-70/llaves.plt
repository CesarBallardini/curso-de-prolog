:- encoding(utf8).

:- use_module(warplan, []).

:- begin_tests(llaves).

test(inicial, [true(N == 7)]) :-
    aggregate_all(count, dado(michie, _), N).

test(ir, [all(H == [robot(mesa)])]) :-
    agrega(H, ir(mesa)).

test(llevar_agrega, [true(Hs == [robot(mesa), vacio(puerta),
                                 esta(rojo, mesa), solo(rojo, mesa)])]) :-
    findall(H, agrega(H, llevar(rojo, puerta, mesa)), Hs0),
    msort(Hs0, Hs).

test(juntar_borra, [nondet]) :-
    borra(solo(llave1, puerta), juntar(llave2, caja2, puerta, llave1)).

test(sacar_exige_llaves, [nondet]) :-
    puede(sacar(rojo, mesa), Pre),
    memberchk(esta(llave1, puerta), Pre),
    memberchk(esta(llave2, puerta), Pre).

test(imposible, [nondet]) :-
    imposible([vacio(L), esta(_, L)]).

test(siempre, [all(L == [mesa, caja1, caja2, puerta])]) :-
    siempre(adentro(L)).

test(distinto_libre, [fail]) :-
    distinto(_, mesa).

test(prueba) :-
    prueba(distinto(a, b)).

% El plan del memo de Warren, comprobado por regresión.
test(plan_de_warren) :-
    plan_de_warren(P),
    saca_el_rojo(P).

% Sin las llaves en la puerta, el objeto no sale.
test(sin_llaves, [fail]) :-
    saca_el_rojo([ir(puerta), llevar(rojo, puerta, mesa), sacar(rojo, mesa)]).

% La búsqueda con cota encuentra el mismo plan de ocho acciones.
test(warplan, [true(P == Q)]) :-
    plan_de_warren(Q),
    once(warplan:planificar(llaves, michie, [esta(rojo, afuera)], 8, P)).

:- end_tests(llaves).
