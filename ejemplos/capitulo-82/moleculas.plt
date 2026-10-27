:- encoding(utf8).

:- begin_tests(moleculas).

test(elemento, [true(E == cloro)]) :-
    elemento(clorotolueno, cl1, E).

test(enlazados_simetrico) :-
    once(enlazados(clorotolueno, c2, cl1)),
    once(enlazados(clorotolueno, cl1, c2)).

test(enlazados_vecinos, [true(Vs == [c1, c5, cl1])]) :-
    findall(V, enlazados(clorotolueno, c2, V), Vs0),
    msort(Vs0, Vs).

test(metilo_v1_repite, [true(Cs == [c3, c3, c3, c3, c3, c3])]) :-
    findall(C, metilo_v1(clorotolueno, C), Cs).

test(metilo, [true(Cs == [c3])]) :-
    findall(C, metilo(clorotolueno, C), Cs).

test(metilo_metanol, [true(Cs == [c1])]) :-
    findall(C, metilo(metanol, C), Cs).

test(anillo_v1_doce, [true(N == 12)]) :-
    aggregate_all(count, anillo_v1(clorotolueno, _), N).

test(anillo_v1_mismo_conjunto, [true(Cs == [[c1, c2, c4, c5, c6, c7]])]) :-
    setof(C, A^( anillo_v1(clorotolueno, A), msort(A, C) ), Cs).

test(anillo, [true(As == [[c1, c2, c5, c7, c6, c4]])]) :-
    findall(A, anillo(clorotolueno, 6, A), As).

test(anillos_difenilo, [true(N == 2)]) :-
    aggregate_all(count, anillo(difenilo, 6, _), N).

test(sin_anillo_de_cinco, [fail]) :-
    anillo(clorotolueno, 5, _).

test(anillo_metilado, [true(Es == [[c3, c1, c2, c5, c7, c6, c4]])]) :-
    findall(E, anillo_metilado(clorotolueno, E), Es).

test(hidroxilo, [true(Os == [o1])]) :-
    findall(O, hidroxilo(fenol, O), Os).

test(sin_hidroxilo, [fail]) :-
    hidroxilo(clorotolueno, _).

test(nitro, [true(Ns == [n1, n2, n3])]) :-
    findall(N, nitro(tnt, N), Ns).

test(hidroxilamina_no_es_nitro, [fail]) :-
    nitro(hidroxilamina, _).

test(formulas, [true(Fs == ['C7H7Cl', 'C6H6O', 'CH4O', 'C12H10',
                            'C7H5N3O6', 'H3NO'])]) :-
    maplist(formula, [clorotolueno, fenol, metanol, difenilo, tnt,
                      hidroxilamina], Fs).

test(kekule, [true(Ks == [2, 2, 1, 4, 0, 1])]) :-
    findall(K,
            ( member(M, [clorotolueno, fenol, metanol, difenilo, tnt,
                         hidroxilamina]),
              aggregate_all(count, ordenes(M, _), K) ),
            Ks).

test(dobles_fenol, [true(Ds == [[c2-c3, c4-c5, c6-c1],
                                [c1-c2, c3-c4, c5-c6]])]) :-
    findall(D, dobles(fenol, D), Ds).

test(ordenes_metanol, [true(Os == [1, 1, 1, 1, 1])]) :-
    once(ordenes(metanol, Ordenes)),
    findall(O, member(_-_-O, Ordenes), Os).

:- end_tests(moleculas).
