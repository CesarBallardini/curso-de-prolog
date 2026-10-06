:- encoding(utf8).

:- begin_tests(comparar).

% Con las bibliotecas del programa cargadas, prolog_xref y el análisis del
% capítulo encuentran los mismos dos predicados sin llamadas.
test(iguales, [true(Nuestros-DeXref == Esperados-Esperados)]) :-
    Esperados = [legajo/2, resultado_json/3],
    comparar(inscripciones, Nuestros, DeXref).

% Sobre un archivo propio: b/0 lo llama a/0, y c/0 no lo llama nadie; un
% predicado exportado no cuenta.
test(sin_llamadas_xref_de, [true(Ps == [a/0, c/0])]) :-
    tmp_file_stream(text, Archivo, S),
    format(S, ":- module(m, [e/0]).~ne :- true.~na :- b.~nb.~nc.~n", []),
    close(S),
    sin_llamadas_xref_de([Archivo], Ps),
    xref_clean(Archivo),
    delete_file(Archivo).

:- end_tests(comparar).
