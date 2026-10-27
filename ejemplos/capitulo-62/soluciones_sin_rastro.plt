:- encoding(utf8).

:- use_module(programas).

:- begin_tests(sin_rastro).

test(antepasado, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

% Las mismas medidas que la versión 3, sin rastro.
test(medir, [true(M == [ respuestas-1, pasos-506, intentos-407, metas-4,
                         elecciones-101, rastro-0, celdas-914
                       ])]) :-
    medir(listas, suma_hasta(100, _), M).

% El punto de elección guarda el almacén de antes de la unificación, y
% volver/3 lo retoma para usar la cláusula siguiente.
test(llamar, [true(L0-L == []-[0-a])]) :-
    clausulas(C1, C2),
    estado_inicial(E0),
    sin_rastro:llamar([C1, C2], p('$v'(0)), [r], E0,
                      sigue(m([r], [guardado(_, [C2], A0)], A, [], _, _))),
    assoc_to_list(A0, L0),
    assoc_to_list(A, L).

test(volver, [true(Ms-P == [q('$v'(1)), r]-[])]) :-
    clausulas(C1, C2),
    estado_inicial(E0),
    sin_rastro:llamar([C1, C2], p('$v'(0)), [r], E0, sigue(E1)),
    almacen:compilar([], T),
    sin_rastro:volver(T, E1, sigue(m(Ms, P, _, _, _, _))).

test(volver_fin, [true(R == fin(E0))]) :-
    estado_inicial(E0),
    almacen:compilar([], T),
    sin_rastro:volver(T, E0, R).

clausulas(C1, C2) :-
    almacen:compilar_clausula((p(a) :- true), _-C1),
    almacen:compilar_clausula((p(X) :- q(X)), _-C2).

estado_inicial(m([], [], A, [], 1, med(0, 0, 0, 0, 0))) :-
    empty_assoc(A).

:- end_tests(sin_rastro).
