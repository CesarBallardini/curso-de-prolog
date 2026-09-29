:- encoding(utf8).

:- begin_tests(etapas).

test(candidatos, [true(Ns == [1-18, 2-15, 3-11, 4-11, 5-20])]) :-
    findall(E-N, ( between(1, 5, E),
                   aggregate_all(count, candidato(E, _, _, _), N) ), Ns).

test(orientar, [true(Ms == [l, u, -l])]) :-
    orientar(1, [f, u, -f], Ms).

test(orientar_cuatro_vuelve, [true(Ms == [r, -u, b])]) :-
    orientar(4, [r, -u, b], Ms).

test(criterio, [true(Libres == 51)]) :-
    criterio(['DFR'], Cr),
    Cr =.. [c|Casillas],
    include(var, Casillas, Vs),
    length(Vs, Libres).

test(criterio_y_resuelto, [nondet]) :-
    findall(P, ( etapa(_, Ps), member(P, Ps) ), Todas),
    criterio(Todas, Cr),
    resuelto(Cr).

test(colocar, [true(Ms == [-f])]) :-
    resuelto(C),
    mover(f, C, C1),
    criterio(['DF'], Cr),
    colocar(1, C1, Cr, Ms, _).

test(resuelve, [true(C2 == C)]) :-
    mezcla(7, 20, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    resolver(C1, Pasos),
    foldl(aplicar_paso, Pasos, C1, C2).

test(veinte_pasos, [true(N == 20)]) :-
    mezcla(8, 20, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    resolver(C1, Pasos),
    length(Pasos, N).

test(veinte_mezclas, [true(Mal == [])]) :-
    resuelto(C),
    findall(S, ( between(1, 20, S),
                 mezcla(S, 25, Ms),
                 aplicar(Ms, C, C1),
                 resolver(C1, Pasos),
                 foldl(aplicar_paso, Pasos, C1, C2),
                 C2 \== C ), Mal).

aplicar_paso(paso(_, _, Ms), C0, C) :-
    aplicar(Ms, C0, C).

test(resolver_mezcla, [true(P-T == [1-14, 2-39, 3-56, 4-25, 5-42]-176)]) :-
    resolver_mezcla(7, 20, P, T).

:- end_tests(etapas).
