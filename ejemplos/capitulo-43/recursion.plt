:- encoding(utf8).

:- begin_tests(recursion).

test(jefe_directora, [fail]) :-
    jefe(1, _).

test(superior, [all(J == [7, 3, 1])]) :-
    superior(8, J).

test(subordinados, [true(Es == [2, 3, 4, 5, 6, 7, 8, 9])]) :-
    findall(E, superior(E, 1), Es0),
    msort(Es0, Es).

% Con la recursión a la izquierda da las tres respuestas y después no
% termina.
test(superior_izq_primeras, [true(Js == [7, 3, 1])]) :-
    findall(J, limit(3, superior_izq(8, J)), Js).

test(superior_izq_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(findall(J, superior_izq(8, J), _),
                              100000, R).

test(destino_sin_tabla_repite, [true(Ds == [cor, mdz, brc, ush, aep, mdz,
                                            sla, cor])]) :-
    findall(D, limit(8, destino_sin_tabla(aep, D)), Ds).

test(destino, [true(Ds == [aep, brc, cor, mdz, sla, ush])]) :-
    findall(D, destino(aep, D), Ds0),
    length(Ds0, 6),
    msort(Ds0, Ds).

test(destino_inverso, [true(Os == [aep, cor, igr, ros])]) :-
    findall(O, destino(O, sla), Os0),
    msort(Os0, Os).

test(iteraciones, [true(Is == [[brc, cor, mdz, ush], [aep, sla], []])]) :-
    iteraciones(aep, Is).

% La unión de las iteraciones es el resultado de la tabla.
test(iteraciones_como_tabla, [true(Todos == Ds)]) :-
    iteraciones(aep, Is),
    append(Is, Todos0),
    sort(Todos0, Todos),
    findall(D, destino(aep, D), Ds0),
    sort(Ds0, Ds).

test(sin_vuelos, [true(Is == [[]])]) :-
    iteraciones(brc, Is).

test(tarifa, [true(Ts == [aep-50, brc-160, cor-120, mdz-140, sla-200,
                          ush-200])]) :-
    findall(D-P, tarifa(ros, D, P), Ts0),
    msort(Ts0, Ts).

:- end_tests(recursion).
