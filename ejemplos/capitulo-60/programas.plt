:- encoding(utf8).

:- begin_tests(programas).

test(bien_formados, all(N == [mcd, mcd_invertido, mcd_mal, ordenar, luz, contador])) :-
    programa(N, Modulos),
    maplist(bien_formado, Modulos).

test(accion_desconocida, [fail]) :-
    bien_formado(m :: [a] ---> [borrar(a)]).

test(patron_variable, [fail]) :-
    bien_formado(m :: [_] ---> []).

test(prueba_como_hecho, [fail]) :-
    bien_formado(m :: [a] ---> [agregar({b})]).

test(negacion_de_prueba, [fail]) :-
    bien_formado(m :: [no({a})] ---> []).

test(posiciones, H == [pos(1, c), pos(2, a), pos(3, b)]) :-
    posiciones([c, a, b], H).

test(valores, L == [c, a, b]) :-
    valores([pos(3, b), pos(1, c), pos(2, a)], L).

test(ida_y_vuelta, L == [x, y, x]) :-
    posiciones([x, y, x], H),
    valores(H, L).

:- end_tests(programas).
