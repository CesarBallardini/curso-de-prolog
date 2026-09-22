:- encoding(utf8).

:- begin_tests(generar).

% Sin corte: todos los múltiplos del rango.
test(los_multiplos_de_siete_desde_veinte, all(N == [21, 28, 35])) :-
    multiplo(7, 20, N),
    N =< 35.

% Con corte: solo el primero.
test(el_primer_multiplo, all(N == [21])) :-
    primer_multiplo(7, 20, N).

test(no_hay_multiplo_fuera_del_rango, [fail]) :-
    primer_multiplo(7, 500, _).

% Los pares se obtienen en los dos órdenes: la regla no fija cuál va primero.
test(los_que_suman_cincuenta, all(A-B == [ana-eva, eva-ana])) :-
    dos_que_suman(49, A, B).

test(un_par_solo, all(A-B == [ana-eva])) :-
    un_par_que_suma(49, A, B).

test(nadie_suma_mil, [fail]) :-
    dos_que_suman(1000, _, _).

% Ejercicio 15 del capítulo: el corte de primer_multiplo/3 es rojo.
test(primer_multiplo_responde, all(N == [21])) :-
    primer_multiplo(7, 20, N).

% Con el tercer argumento instanciado el corte no llega a podar nada, y el
% predicado acepta un múltiplo que no es el primero.
test(primer_multiplo_acepta_uno_que_no_es_el_primero) :-
    primer_multiplo(7, 20, 28).

:- end_tests(generar).
