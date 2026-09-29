:- encoding(utf8).

:- begin_tests(comparar).

% Con las bibliotecas del programa cargadas, prolog_xref y el análisis del
% capítulo encuentran los mismos dos predicados sin llamadas.
test(iguales, [true(Nuestros-DeXref == Esperados-Esperados)]) :-
    Esperados = [legajo/2, resultado_json/3],
    comparar(inscripciones, Nuestros, DeXref).

:- end_tests(comparar).
