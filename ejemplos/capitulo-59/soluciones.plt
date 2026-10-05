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

% Una cadena: r es la raíz; a no tiene llamadas, y al quitarlo b tampoco, y
% después c.
test(sin_llamadas_hasta_el_fin_de, [true(Ps == [a/0, b/0, c/0])]) :-
    sin_llamadas_hasta_el_fin_de([(r :- d), d, (a :- b), (b :- c), c], [r/0],
                                 Ps).

test(sin_llamadas_hasta_el_fin_de_nada, [true(Ps == [])]) :-
    sin_llamadas_hasta_el_fin_de([(r :- d), d], [r/0], Ps).

% Un ciclo forma una sola capa, antes de lo que llama.
test(capas_de, [true(Cs == [[a/0], [b/0, c/0], [d/0]])]) :-
    capas_de([(a :- b), (b :- c), (c :- b, d), d], Cs).

test(componente_de, [true(C1-C2 == [b/0, c/0]-[d/0])]) :-
    Clausura = [a/0-[b/0, c/0, d/0], b/0-[b/0, c/0, d/0], c/0-[b/0, c/0, d/0],
                d/0-[]],
    componente_de(Clausura, b/0, C1),
    componente_de(Clausura, d/0, C2).

:- end_tests(soluciones).
