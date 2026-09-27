:- encoding(utf8).

:- begin_tests(texto).

test(inicial_de_juan, all(I == [j])) :-
    inicial(juan, I).

test(el_atomo_vacio_no_tiene_inicial, [fail]) :-
    inicial('', _).

test(iniciales_de_tres, all(L == [[j, a, e]])) :-
    iniciales([juan, ana, eva], L).

test(iniciales_de_ninguno, all(L == [[]])) :-
    iniciales([], L).

test(un_numero_escrito, all(N == [12])) :-
    numero_de_texto('12', N).

test(un_nombre_no_es_un_numero, [fail]) :-
    numero_de_texto(ana, _).

:- end_tests(texto).
