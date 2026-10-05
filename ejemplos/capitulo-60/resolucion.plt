:- encoding(utf8).

:- begin_tests(resolucion).

test(clausulas_de_bratko, Cs == [[a], [b, -a], [c, -b], [-c]]) :-
    clausulas(-((a ==> b) & (b ==> c) ==> (a ==> c)), Cs).

test(distribucion, Cs == [[a, b], [a, c]]) :-
    clausulas(a v b & c, Cs).

test(de_morgan, Cs == [[-a], [-b]]) :-
    clausulas(-(a v b), Cs).

test(resolventes, all(R == [[b, c]])) :-
    resolvente([a, b], [c, -a], R).

test(tautologica) :-
    tautologica([a, b, -a]).

test(no_tautologica, [fail]) :-
    tautologica([a, -b]).

test(teoremas, all(F == [(p ==> q) ==> (-q ==> -p), p v -p,
                         ((p ==> q) ==> p) ==> p,
                         (p v q) & (p ==> r) & (q ==> r) ==> r])) :-
    member(F, [(p ==> q) ==> (-q ==> -p), p v -p, (p ==> q) ==> (q ==> p),
               ((p ==> q) ==> p) ==> p,
               (p v q) & (p ==> r) & (q ==> r) ==> r]),
    demostrar(F, primera, teorema).

test(no_teorema, V == no_teorema) :-
    demostrar((p ==> q) ==> (q ==> p), primera, V).

test(mismo_veredicto, all(E == [primera, reciente, especifica])) :-
    member(E, [primera, reciente, especifica]),
    demostrar((a ==> b) & (b ==> c) ==> (a ==> c), E, teorema).

% La especificidad prefiere resolver antes que verificar la contradicción.
test(ciclos, [P, R, E] == [4, 4, 7]) :-
    memoria_inicial((a ==> b) & (b ==> c) ==> (a ==> c), M),
    ciclos(resolucion, primera, M, P),
    ciclos(resolucion, reciente, M, R),
    ciclos(resolucion, especifica, M, E).

% Las cláusulas tautológicas de la entrada se quitan.
test(quita_tautologia, M == [clausula([a])]) :-
    ejecutar(resolucion, primera, [clausula([a]), clausula([b, -b])], M,
             sin_contradiccion).

test(traza, S == "1: resolver de 3, con [clausula([p]),clausula([-p])]\n\c
                  2: contradiccion de 2, con [clausula([])]\n") :-
    with_output_to(string(S), trazar_demostracion(p v -p, primera, _)).

test(fnc_literal, [true(Cs-Ds == [[a]]-[[-a]])]) :-
    fnc(a, Cs),
    fnc(-a, Ds).

% La disyunción distribuye: (a & b) v c da dos cláusulas.
test(fnc_distribuye, [true(Cs == [[a, c], [b, c]])]) :-
    fnc((a & b) v c, Cs).

test(fnc_conjuncion, [true(Cs == [[a], [-b], [c, d]])]) :-
    fnc(a & -b & (c v d), Cs).

:- end_tests(resolucion).
