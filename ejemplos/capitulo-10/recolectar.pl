:- encoding(utf8).

% Capítulo 10 - Recolectar soluciones.
%
% Una lista con todas las respuestas de una consulta, armada con una lista
% auxiliar de lo ya recolectado, la prueba \+ pertenece/2, un corte y una
% cláusula de cierre. Después, los alumnos que aprobaron todas las materias
% de un ciclo, con la negación de "hay una materia sin aprobar".
%
%?- lista_personas(L).
%?- aprobados_ciclo(1, L).

% persona(P): P es una persona registrada.
persona(andres).
persona(maria).
persona(lucas).

%!  lista_ingenua(-L) is det.
%
%   L es la lista de todas las personas. Primer intento, incorrecto: la
%   recursión no termina y X siempre toma la primera persona.
lista_ingenua([X|L]) :-
    persona(X),
    lista_ingenua(L).

%!  pertenece(?X, ?L) is nondet.
%
%   X es uno de los elementos de L.
%   X es el primer elemento, o es un elemento del resto. Con L libre, enumera
%   listas cada vez más largas que contienen a X, sin fin.
pertenece(X, [X|_]).
pertenece(X, [_|Resto]) :-
    pertenece(X, Resto).

%!  concatenar(+A, ?B, -C) is det.
%!  concatenar(?A, ?B, +C) is nondet.
%
%   C es la lista A seguida de la lista B.
concatenar([], B, B).
concatenar([X|RestoA], B, [X|RestoC]) :-
    concatenar(RestoA, B, RestoC).

%!  lista_personas(-L) is det.
%
%   L es la lista de todas las personas, en el orden de los hechos. L debe
%   llegar libre.
lista_personas(L) :-
    armar_lista_personas(L, []).

%!  armar_lista_personas(-L, +YaIncluidas) is det.
%
%   L es la lista de las personas que no están en YaIncluidas. YaIncluidas
%   es el acumulador: lleva, en orden, las personas ya incluidas en la
%   lista. El corte descarta las demás personas y la cláusula de cierre una
%   vez que se encontró una nueva.
armar_lista_personas([X|L], YaIncluidas) :-
    persona(X),
    \+ pertenece(X, YaIncluidas),
    !,
    concatenar(YaIncluidas, [X], YaIncluidasConX),
    armar_lista_personas(L, YaIncluidasConX).
armar_lista_personas([], _).

%!  armar_sin_corte(-L, +YaIncluidas) is det.
%
%   L es la lista de las personas que no están en YaIncluidas. La misma
%   regla sin el corte: incorrecta, porque la cláusula de cierre y las demás
%   personas agregan respuestas.
armar_sin_corte([X|L], YaIncluidas) :-
    persona(X),
    \+ pertenece(X, YaIncluidas),
    concatenar(YaIncluidas, [X], YaIncluidasConX),
    armar_sin_corte(L, YaIncluidasConX).
armar_sin_corte([], _).

% alumno(A): A es un alumno de la carrera.
alumno(jorge).
alumno(santiago).
alumno(romina).
alumno(daniel).

% materia(M, C): la materia M corresponde al ciclo C de la carrera.
materia(analisis1, 1).
materia(algebra, 1).
materia(algoritmos, 1).
materia(analisis2, 2).
materia(paradigmas, 2).

% aprobo(A, M): el alumno A aprobó la materia M.
aprobo(jorge, analisis1).
aprobo(jorge, algebra).
aprobo(jorge, algoritmos).
aprobo(santiago, analisis1).
aprobo(santiago, algoritmos).
aprobo(romina, analisis1).
aprobo(romina, algebra).
aprobo(romina, algoritmos).
aprobo(romina, analisis2).
aprobo(romina, paradigmas).

%!  materia_sin_aprobar(+A, ?C, ?M) is nondet.
%
%   M es una materia del ciclo C que el alumno A no aprobó. A debe llegar
%   ligado: \+ aprobo(A, M) con A libre pregunta si nadie aprobó M.
materia_sin_aprobar(A, C, M) :-
    materia(M, C),
    \+ aprobo(A, M).

%!  todas_aprobadas_en_ciclo(?A, +C) is nondet.
%
%   El alumno A aprobó todas las materias del ciclo C: no le queda ninguna
%   sin aprobar. C debe llegar ligado.
todas_aprobadas_en_ciclo(A, C) :-
    alumno(A),
    \+ materia_sin_aprobar(A, C, _).

%!  aprobados_ciclo(+C, -L) is det.
%
%   L es la lista de los alumnos que aprobaron todas las materias del ciclo
%   C. L debe llegar libre.
aprobados_ciclo(C, L) :-
    armar_aprobados_ciclo(C, L, []).

%!  armar_aprobados_ciclo(+C, -L, +YaIncluidas) is det.
%
%   L es la lista de los alumnos que aprobaron todo el ciclo C y no están en
%   YaIncluidas.
armar_aprobados_ciclo(C, [A|L], YaIncluidas) :-
    todas_aprobadas_en_ciclo(A, C),
    \+ pertenece(A, YaIncluidas),
    !,
    concatenar(YaIncluidas, [A], YaIncluidasConA),
    armar_aprobados_ciclo(C, L, YaIncluidasConA).
armar_aprobados_ciclo(_, [], _).
