:- encoding(utf8).

:- begin_tests(laberinto).

test(andar, all(S == [l3])) :-
    andar(entrada, [abajo, norte, sur], S).

test(andar_sin_direcciones, all(S == [l2])) :-
    andar(l2, [], S).

test(andar_bloqueado, fail) :-
    andar(entrada, [norte], _).

test(andar_dos_pasos, all(Ds == [[abajo, norte], [abajo, este]])) :-
    length(Ds, 2),
    andar(entrada, Ds, S),
    memberchk(S, [l1, l2]).

test(retorno_retorcido, all(S == [l3])) :-
    andar(l1, [norte, sur], S).

test(salas, true(Ss == [entrada, l1, l2, l3, l4, l5, pozo, tesoro])) :-
    salas(Ss).

test(camino_ida, true(Ds == [abajo, norte, sur, abajo, este])) :-
    camino(entrada, tesoro, Ds).

test(camino_vuelta, true(Ds == [oeste, arriba, oeste, arriba])) :-
    camino(tesoro, entrada, Ds).

test(camino_vacio, true(Ds == [])) :-
    camino(l3, l3, Ds).

test(camino_sin_salida, fail) :-
    camino(pozo, entrada, _).

test(camino_mas_corto, true(L == 5)) :-
    camino(entrada, tesoro, Ds),
    length(Ds, L),
    \+ ( between(0, 4, L1), length(Ds1, L1), andar(entrada, Ds1, tesoro) ).

test(retorcidos, true(Rs == [l1-norte, l1-este, l2-oeste, l3-oeste,
                             l4-sur, l4-abajo])) :-
    findall(S-D, retorcido(S, D), Rs).

test(no_retorcido, fail) :-
    retorcido(l2, este).

test(explorar, true(Ss == [entrada, l1, l2, l3, l5, tesoro, l4, pozo])) :-
    explorar(entrada, Ss).

test(explorar_desde_el_pozo, true(Ss == [pozo])) :-
    explorar(pozo, Ss).

test(explorar_alcanza_todo, true(Ss == Todas)) :-
    explorar(entrada, Ss0),
    msort(Ss0, Ss),
    salas(Todas).

test(marcar_ya_marcada, true(Ms == [l2, l1])) :-
    laberinto:marcar(l1, [l2, l1], Ms).

test(opuesta_simetrica, true) :-
    forall(opuesta(D, O), opuesta(O, D)).

:- end_tests(laberinto).
