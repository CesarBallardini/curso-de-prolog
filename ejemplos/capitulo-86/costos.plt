:- encoding(utf8).

% Las cifras medidas que el capítulo imprime, dentro de una banda del 10 %
% (en_banda/2), porque las inferencias cambian de una versión de
% SWI-Prolog a otra.



:- begin_tests(costos).

reunion("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'").
reunion_negada("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE NOT (a.legajo <> i.legajo) AND NOT (i.materia <> 'am1')").

% Sección 86.6: la reunión de alumnos e inscripciones, con las
% igualdades resueltas al compilar y escritas para que no se resuelvan.
test(reunion_inscripciones) :-
    reunion(T1),
    reunion_negada(T2),
    inferencias(T1, N1),
    inferencias(T2, N2),
    en_banda(N1, 22),
    en_banda(N2, 158).

test(mismas_filas, [true(F1 == F2)]) :-
    reunion(T1),
    reunion_negada(T2),
    filas(T1, _, F1),
    filas(T2, _, F2).

% Sección 86.6: la tabla numeros con 300 filas, reunida consigo misma.
test(reunion_numeros, [ setup(estado(E)), cleanup(restaurar(E)) ]) :-
    numeros(300),
    inferencias("SELECT a.n FROM numeros a, numeros b WHERE a.n = b.n", N1),
    inferencias("SELECT a.n FROM numeros a, numeros b WHERE NOT (a.n <> b.n)", N2),
    en_banda(N1, 910),
    en_banda(N2, 270610).

test(numeros, [ setup(estado(E)), cleanup(restaurar(E)),
                true(K == [[300]]) ]) :-
    numeros(300),
    filas("SELECT COUNT(*) FROM numeros", _, K).

test(en_banda) :-
    en_banda(105, 100),
    \+ en_banda(111, 100).

:- end_tests(costos).
