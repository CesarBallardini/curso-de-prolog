:- encoding(utf8).

:- begin_tests(soluciones_perfil).

test(usados, [true(R-Arcos == [a]-[ '<consulta>'-inversa/2,
                                     inversa/2-concatenar/3,
                                     inversa/2-inversa/2 ])]) :-
    arcos_usados(inversa([a], R), Arcos).

% Con un elemento, concatenar/3 usa solo su primera cláusula: la llamada
% recursiva queda sin recorrer. Con dos elementos se recorre todo.
test(sin_recorrer_uno, [true(Arcos == [concatenar/3-concatenar/3])]) :-
    sin_recorrer(inversa([a], _), [inversa/2, concatenar/3], Arcos).

test(sin_recorrer_dos, [true(Arcos == [])]) :-
    sin_recorrer(inversa([a, b], _), [inversa/2, concatenar/3], Arcos).

% También se anotan los arcos de una ejecución que falla.
test(falla, [true(Arcos == [ '<consulta>'-inversa/2,
                             inversa/2-concatenar/3,
                             inversa/2-inversa/2 ])]) :-
    arcos_usados(inversa([a], [b]), Arcos).

:- end_tests(soluciones_perfil).
