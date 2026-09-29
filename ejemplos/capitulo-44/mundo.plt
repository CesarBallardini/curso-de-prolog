:- encoding(utf8).

:- begin_tests(mundo).

test(salidas_del_vestibulo, all(P-S == [puerta_biblioteca-biblioteca,
                                        puerta_taller-taller])) :-
    conecta(P, vestibulo, S).

test(en_los_dos_sentidos, all(S == [sotano, vestibulo])) :-
    conecta(_, taller, S).

test(paso_entre_dos_salas, [nondet]) :-
    conecta(escalera, cupula, biblioteca).

test(sin_paso, fail) :-
    conecta(_, vestibulo, cupula).

test(objetos, all(O == [perchero, escritorio, llave, catalogo, linterna,
                        banco, baul, lente, telescopio])) :-
    objeto(O).

% Los datos son coherentes: cada puerta une dos salas, cada cosa del
% estado inicial tiene nombre, y cada lugar es una sala o un recipiente.
test(puertas_entre_salas, true) :-
    forall(puerta(_, S1, S2), ( sala(S1, _), sala(S2, _) )).

test(todo_tiene_nombre, true) :-
    forall(( sala(X, _) ; puerta(X, _, _) ; inicio(esta_en(X, _)) ),
           nombre(X, _, _)).

test(lugares_validos, true) :-
    forall(inicio(esta_en(_, L)), ( sala(L, _) ; recipiente(L) )).

test(un_solo_lugar_inicial, true(N == 1)) :-
    aggregate_all(count, inicio(aqui(_)), N).

:- end_tests(mundo).
