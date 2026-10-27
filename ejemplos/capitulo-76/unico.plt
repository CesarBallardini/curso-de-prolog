:- encoding(utf8).

:- begin_tests(unico).

test(canonica_rota_y_ordena, [true(F == [1-1, 1-2, 2-2, 2-1])]) :-
    canonica([2-1, 1-1, 1-2, 2-2], F).

test(canonica_invierte, [true(F == [1-1, 1-2, 2-2, 2-1])]) :-
    canonica([2-2, 1-2, 1-1, 2-1], F).

test(canonica_de_las_escrituras, [true(Fs == [[1-1, 1-2, 2-2, 2-1]])]) :-
    L = [1-1, 1-2, 2-2, 2-1],
    findall(F,
            ( member(K, [0, 1, 2, 3]), length(Pre, K), append(Pre, Post, L),
              append(Post, Pre, R), member(E, [R, Inv]), reverse(R, Inv),
              canonica(E, F) ),
            Fs0),
    sort(Fs0, Fs).

test(en_un_sentido) :-
    en_un_sentido([1-1, 1-2, 2-2, 2-1]).

test(en_el_otro_sentido, [fail]) :-
    en_un_sentido([1-1, 2-1, 2-2, 1-2]).

test(semilla, [true(S == 1-4)]) :-
    semilla(csenki1, S).

test(escrituras, [true(Ns == [18, 2, 1])]) :-
    findall(N, ( member(M, [todas, semilla, sentido]),
                 escrituras(M, csenki1, Ls), length(Ls, N) ),
            Ns).

test(conteo, [true(N == 2)]) :-
    conteo(csenki1, semilla, N, I),
    I > 0.

test(distintos, [true(N-K == 1-36)]) :-
    distintos(csenki1, [F|Fs]),
    length([F|Fs], N),
    length(F, K).

:- end_tests(unico).
