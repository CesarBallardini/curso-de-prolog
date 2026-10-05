:- encoding(utf8).

:- begin_tests(editor, [setup(reponer), cleanup(reponer)]).

% reponer: vuelve nota/2 a sus tres hechos de editor.pl.
reponer :-
    retractall(user:nota(_, _)),
    forall(member(A-N, [ana-7, luis-5, eva-8]), assertz(user:nota(A, N))).

clausulas_de_nota(Cs) :-
    findall(nota(A, N) :- B, clause(user:nota(A, N), B), Cs).

test(abrir, [true(E == editor(nota/2, 0, [ (nota(ana, 7) :- true),
                                            (nota(luis, 5) :- true),
                                            (nota(eva, 8) :- true) ]))]) :-
    reponer,
    abrir(nota/2, E).

test(abrir_vacio, [true(E == editor(sin_clausulas/1, 0, []))]) :-
    dynamic(user:sin_clausulas/1),
    abrir(sin_clausulas/1, E).

% El cursor no pasa de la última cláusula ni baja de 0.
test(siguiente_y_anterior, [true(Cs == [1, 3, 3, 2, 0, 0, 3])]) :-
    E0 = editor(p/0, 0, [a, b, c]),
    comando(s, E0, editor(_, C1, _)),
    comando(u, E0, E3),
    E3 = editor(_, C3, _),
    comando(s, E3, editor(_, C4, _)),
    comando(a, E3, editor(_, C5, _)),
    comando(p, E3, editor(_, C6, _)),
    comando(a, E0, editor(_, C7, _)),
    comando(u, E0, editor(_, C8, _)),
    Cs = [C1, C3, C4, C5, C6, C7, C8].

test(borrar_medio, [true(E == editor(p/0, 2, [a, c]))]) :-
    comando(b, editor(p/0, 2, [a, b, c]), E).

% Borrar la última deja el cursor en la nueva última.
test(borrar_ultima, [true(E == editor(p/0, 2, [a, b]))]) :-
    comando(b, editor(p/0, 3, [a, b, c]), E).

test(borrar_en_cero, [true(E == editor(p/0, 0, [a]))]) :-
    comando(b, editor(p/0, 0, [a]), E).

test(insertar, [true(E == editor(p/0, 3, [a, x, y, b]))]) :-
    comando(i([x, y]), editor(p/0, 1, [a, b]), E).

test(insertar_al_principio, [true(E == editor(p/0, 1, [x, a]))]) :-
    comando(i([x]), editor(p/0, 0, [a]), E).

test(comando_desconocido, [fail]) :-
    comando(z, editor(p/0, 0, []), _).

test(grabar, [true(Cs == [(nota(eva, 8) :- true), (nota(ana, 7) :- true)])]) :-
    reponer,
    grabar(editor(nota/2, 1, [(nota(eva, 8) :- true),
                               (nota(ana, 7) :- true)])),
    clausulas_de_nota(Cs).

% Una sesión completa: borrar luis, insertar dos cláusulas después de eva.
test(sesion, [true(Cs-Ultima =@= [ (nota(ana, 7) :- true),
                                  (nota(eva, 8) :- true),
                                  (nota(rosa, 10) :- true),
                                  (nota(X, 0) :- X == nadie) ]-
                                "nota/2 4: nota(A, 0) :-\n    A==nadie.")]) :-
    reponer,
    setup_call_cleanup(
        open_string("s. s. b. i. nota(rosa, 10). (nota(X, 0) :- X == nadie). end. x.",
                    In),
        with_output_to(string(S), editar_desde(In, nota/2)),
        close(In)),
    clausulas_de_nota(Cs),
    split_string(S, "\n", "", Lineas),
    once(append(_, [L1, L2, ""], Lineas)),
    atomic_list_concat([L1, L2], '\n', A),
    atom_string(A, Ultima).

test(listar, [true(S == "   1  a.\n>  2  b.\n")]) :-
    with_output_to(string(S), listar(editor(p/0, 2, [(a :- true), (b :- true)]))).

test(mostrar_cursor_cero, [true(S == "p/0 0: (antes de la primera)\n")]) :-
    with_output_to(string(S), mostrar_cursor(editor(p/0, 0, [(a :- true)]))).

test(leer_clausulas, [true(Cs == [(a :- true), (b :- c)])]) :-
    setup_call_cleanup(open_string("a. b :- c. end. x.", In),
                       leer_clausulas(In, Cs),
                       close(In)).

% Un editor anidado borra la última cláusula de nota/2; al volver, el editor
% de afuera relee el predicado, su cursor queda en la nueva última, luis, y
% el b que sigue la borra.
test(anidado, [true(Cs == [(nota(ana, 7) :- true)])]) :-
    reponer,
    setup_call_cleanup(open_string("u. e(nota/2). u. b. x. b. x.", In),
                       with_output_to(string(_), editar_desde(In, nota/2)),
                       close(In)),
    clausulas_de_nota(Cs).

test(releer, [true(E == editor(nota/2, 3, [(nota(ana, 7) :- true),
                                           (nota(luis, 5) :- true),
                                           (nota(eva, 8) :- true)]))]) :-
    reponer,
    releer(editor(nota/2, 9, []), E).

test(desconocido_en_sesion, [true(S == "nota/2 0: (antes de la primera)\ncomando desconocido: zz\nnota/2 0: (antes de la primera)\n")]) :-
    reponer,
    setup_call_cleanup(open_string("zz. x.", In),
                       with_output_to(string(S), editar_desde(In, nota/2)),
                       close(In)).

test(editar_texto, [true(Ns == [ana, luis])]) :-
    reponer,
    with_output_to(string(_), editar_texto("u. b. x.", nota/2)),
    findall(A, user:nota(A, _), Ns).

:- end_tests(editor).
