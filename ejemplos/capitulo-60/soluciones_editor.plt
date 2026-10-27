:- encoding(utf8).

:- begin_tests(soluciones_editor, [cleanup(reponer)]).

reponer :-
    retractall(user:nota(_, _)),
    forall(member(A-N, [ana-7, luis-5, eva-8]), assertz(user:nota(A, N))).

% Las dos cláusulas del archivo quedan después de ana, y el cursor en la
% última insertada.
test(ej12_insertar_archivo, [true(C-Ns == 3-[ana, rosa, juan, luis, eva])]) :-
    reponer,
    tmp_file_stream(text, F, S),
    format(S, "nota(rosa, 10).~nnota(juan, 6).~n", []),
    close(S),
    abrir(nota/2, E0),
    comando(s, E0, E1),
    insertar_archivo(F, E1, editor(_, C, _)),
    delete_file(F),
    findall(A, user:nota(A, _), Ns).

test(ej12_archivo_vacio, [true(E == E0)]) :-
    reponer,
    tmp_file_stream(text, F, S),
    close(S),
    abrir(nota/2, E0),
    insertar_archivo(F, E0, E),
    delete_file(F).

:- end_tests(soluciones_editor).
