:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_2, [true(Ps == [ setup_call_cleanup/3, abrir/0, usar/0,
                                cerrar/0, with_output_to/2, p/0,
                                call_cleanup/2, q/0, r/0, not/1, s/0 ])]) :-
    metas(( setup_call_cleanup(abrir, usar, cerrar),
            with_output_to(string(_), p),
            call_cleanup(q, r),
            not(s) ),
          Ms),
    maplist(indicador, Ms, Ps).

% varianza/2 no tiene llamadas; desvio2/3 sí, desde varianza/2.
test(ejercicio_3, [true(Ps == [varianza/2])]) :-
    sin_llamadas(notas, Ps).

% Quitar una y otra vez los que no tienen llamadas lleva a los no usados.
test(ejercicio_3_hasta_el_fin, [true(Ps == Us)]) :-
    sin_llamadas_hasta_el_fin(notas, Ps),
    no_usados(notas, Us).

% Dos predicados que se llaman entre sí tienen llamadas, y no se alcanzan.
test(ejercicio_3_ciclo, [true(Ps-Us == []-[a/0, b/0])]) :-
    Cs = [p, (a :- b), (b :- a)],
    sin_llamadas_de(Cs, [p/0], Ps),
    no_usados_de(Cs, [p/0], Us).

test(ejercicio_11, [true(Capas == [ [informe/0], [varianza/2], [alumnos/1],
                                    [mejor/1], [mostrar/1], [desvio2/3],
                                    [promedo/2], [mediana/2], [notas/2],
                                    [promedio/2],
                                    [longitud_impar/1, longitud_par/1],
                                    [suma/2] ])]) :-
    capas(notas, Capas).

% El grafo sin condensar tiene ciclos: top_sort/2 falla.
test(ejercicio_11_ciclos, [fail]) :-
    clausulas(notas, Cs),
    grafo(Cs, G),
    top_sort(G, _).

:- end_tests(soluciones).
