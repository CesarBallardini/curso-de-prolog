:- encoding(utf8).

:- begin_tests(recolectar).

% Una sola respuesta: la lista completa, en el orden de los hechos.
test(lista_personas, all(L == [[andres, maria, lucas]])) :-
    lista_personas(L).

% Con el acumulador ya cargado, solo se recolectan las que faltan.
test(armar_desde_andres, all(L == [[maria, lucas]])) :-
    armar_lista_personas(L, [andres]).

test(armar_sin_faltantes, all(L == [[]])) :-
    armar_lista_personas(L, [andres, maria, lucas]).

% Sin el corte, la cláusula de cierre y las demás personas producen otras
% quince respuestas.
test(sin_corte, all(L == [[andres, maria, lucas], [andres, maria],
                          [andres, lucas, maria], [andres, lucas], [andres],
                          [maria, andres, lucas], [maria, andres],
                          [maria, lucas, andres], [maria, lucas], [maria],
                          [lucas, andres, maria], [lucas, andres],
                          [lucas, maria, andres], [lucas, maria], [lucas],
                          []])) :-
    armar_sin_corte(L, []).

% Con L ya ligado, la cláusula de cierre acepta una lista incompleta.
test(acepta_una_lista_incompleta) :-
    lista_personas([andres]).

test(materia_sin_aprobar, all(M == [algebra])) :-
    materia_sin_aprobar(santiago, 1, M).

% Con el alumno libre, \+ aprobo(A, M) pregunta si nadie aprobó M.
test(materia_sin_aprobar_alumno_libre, [fail]) :-
    materia_sin_aprobar(_, 1, _).

test(todo_el_primer_ciclo, all(A == [jorge, romina])) :-
    todas_aprobadas_en_ciclo(A, 1).

test(santiago_no, [fail]) :-
    todas_aprobadas_en_ciclo(santiago, 1).

% Con el ciclo libre, la negación abarca las materias de todos los ciclos.
test(jorge_ciclo_libre, [fail]) :-
    todas_aprobadas_en_ciclo(jorge, _).

test(romina_ciclo_libre, [nondet]) :-
    todas_aprobadas_en_ciclo(romina, _).

test(aprobados_primer_ciclo, all(L == [[jorge, romina]])) :-
    aprobados_ciclo(1, L).

test(aprobados_segundo_ciclo, all(L == [[romina]])) :-
    aprobados_ciclo(2, L).

:- end_tests(recolectar).
