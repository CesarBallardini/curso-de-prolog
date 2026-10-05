:- encoding(utf8).

:- begin_tests(conjuntos).

% Con conjuntos, el total es el mismo con cualquier estrategia.
test(ticket, [forall(member(E, [orden, lex, mea])), true(T == 680)]) :-
    items(I),
    ticket(ticket, conjuntos(E), I, T).

% Sin conjuntos, LEX suma la línea de la leche antes de la oferta.
test(plano, [true(T1-T2 == 680-740)]) :-
    items(I),
    ticket(ticket_plano, orden, I, T1),
    ticket(ticket_plano, lex, I, T2).

test(en_conjunto, [true(R == (r :: [conjunto(c), p] ---> [q]))]) :-
    en_conjunto(c, r :: [p] ---> [q], R).

test(agregar_conjunto, [true(Rs == [(r :: [conjunto(c), p] ---> [q]), x])]) :-
    agregar_conjunto(c-[r :: [p] ---> [q]], Rs, [x]).

test(con_conjuntos, [true(Ns-Cs == [r, s, k]-[k])]) :-
    con_conjuntos(prueba, [a-[r :: [p] ---> [q]], b-[s :: [p] ---> [q]]],
                  [k :: [conjunto(a)] ---> [parar(listo)]], Rs),
    findall(N, member(N :: _ ---> _, Rs), Ns),
    findall(C, control(prueba, C), Cs).

% Una regla de control queda detrás de las demás.
test(clave, [true(K1-K2 == c(0, 0)-c(1, 0))]) :-
    con_conjuntos(prueba, [], [k :: [] ---> []], _),
    clave_estrategia(conjuntos(orden), instanciacion(k, [], 0, []), K1),
    clave_estrategia(conjuntos(orden), instanciacion(r, [], 0, []), K2).

items([item(pan, 2), item(leche, 3), item(queso, 1)]).

:- end_tests(conjuntos).
