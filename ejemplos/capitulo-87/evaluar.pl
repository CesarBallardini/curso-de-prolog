:- encoding(utf8).

% Capítulo 87 - Versión 3: la forma lógica evaluada, con explicaciones.
%
% probar/2 es un intérprete de las fórmulas de la gramática, como los
% metaintérpretes del capítulo 33: devuelve, además de las ligaduras, el
% árbol de prueba. Cada predicado de la forma lógica (alumno/1, cursar/2,
% aprobar/2, …) se define por los hechos de la base del capítulo 42 que lo
% prueban, y esos hechos son las hojas del árbol. no/1 es negación por
% falla, y todo/3 se evalúa como «no hay un caso de la restricción que no
% cumpla el alcance», la doble negación que Pereira y Warren usan en
% Chat-80.
%
% Cuando una pregunta de sí o no da «no», por_que_no/2 explica la falla
% como no_cubierto/2 y explicacion/3 del capítulo 33: baja por la primera
% condición que no se cumple. Una pregunta con «todos» cuya restricción no
% tiene ningún caso no se responde «sí»: su presuposición, que hay casos,
% no se cumple (Dahl 1981).
%
% necesitar/2 es la cadena de correlativas. Está definida con la
% recursión a la izquierda y una tabla con subsunción de respuestas
% (capítulo 39): pasos/3 guarda, para cada par, la menor cantidad de
% correlativas que los une, y termina aunque el plan tuviera un ciclo.
%
% solo-local: carga módulos.
%
%?- evaluar(cuantos(X, y(alumno(X), aprobar(X, alg))), R).
%?- explicar(si_no(aprobar(102, alg)), E).

:- module(evaluar,
          [ evaluar/2,
            explicar/2,
            probar/2,
            por_que_no/2,
            hojas/2,
            pasos/3,
            cadena/3
          ]).

:- use_module('../capitulo-42/base').

% Otros archivos pueden agregar clases de preguntas y predicados de la
% forma lógica.
:- multifile evaluar/2, explicar/2, definicion/2.

%!  evaluar(+Forma, -Respuesta) is det.
%
%   Respuesta responde la pregunta Forma: lista(Claves), las claves que
%   cumplen la condición, ordenadas; numero(N), cuántas son; si o no; o
%   presupone(R), si la pregunta con «todos» supone que R tiene casos y
%   no los tiene.
evaluar(cual(X, F), lista(Xs)) :-
    findall(X, probar(F, _), Xs0),
    sort(Xs0, Xs).
evaluar(cuantos(X, F), numero(N)) :-
    findall(X, probar(F, _), Xs0),
    sort(Xs0, Xs),
    length(Xs, N).
evaluar(si_no(F), Respuesta) :-
    (   presuposicion_falla(F, R)
    ->  Respuesta = presupone(R)
    ;   probar(F, _)
    ->  Respuesta = si
    ;   Respuesta = no
    ).

%!  presuposicion_falla(+F, -R) is semidet.
%
%   F es todo(X, R, A) y ningún X cumple R.
presuposicion_falla(todo(_, R, _), R) :-
    \+ probar(R, _).

%!  explicar(+Forma, -Explicacion) is det.
%
%   Explicacion justifica la respuesta de Forma. Para cual/2 y cuantos/2
%   es una lista Clave-Arbol, la primera prueba de cada respuesta; para
%   si_no/1, prueba(Arbol) si la respuesta es sí, falla(Motivo) si es no,
%   y sin_casos(R) si la presuposición no se cumple.
explicar(cual(X, F), Pruebas) :-
    pruebas(X, F, Pruebas).
explicar(cuantos(X, F), Pruebas) :-
    pruebas(X, F, Pruebas).
explicar(si_no(F), Explicacion) :-
    (   presuposicion_falla(F, R)
    ->  Explicacion = sin_casos(R)
    ;   once(probar(F, Arbol))
    ->  Explicacion = prueba(Arbol)
    ;   por_que_no(F, Motivo),
        Explicacion = falla(Motivo)
    ).

%!  pruebas(?X, +F, -Pruebas:list) is det.
%
%   Pruebas tiene un par Clave-Arbol por cada valor de X que cumple F, en
%   orden: el árbol es la primera prueba de F con ese valor.
pruebas(X, F, Pruebas) :-
    findall(X, probar(F, _), Xs0),
    sort(Xs0, Xs),
    findall(Clave-Arbol,
            ( member(Clave, Xs),
              copy_term(X-F, Clave-F1),
              once(probar(F1, Arbol)) ),
            Pruebas).

% --- El intérprete -------------------------------------------------------

%!  probar(+F, -Arbol) is nondet.
%
%   F se cumple en la base, con la prueba Arbol: una respuesta por cada
%   prueba. Las variables de F que quedan ligadas son las que la prueba
%   instancia.
probar(y(A, B), y(TA, TB)) :-
    probar(A, TA),
    probar(B, TB).
probar(alguno(_, R, A), alguno(T)) :-
    once(probar(y(R, A), T)).
probar(no(A), no_se_prueba(A, Motivo)) :-
    \+ probar(A, _),
    por_que_no(A, Motivo).
probar(todo(X, R, A), todos(Casos)) :-
    \+ ( probar(R, _), \+ probar(A, _) ),
    findall(X-T, ( probar(R, _), once(probar(A, T)) ), Casos0),
    sort(1, @<, Casos0, Casos).
probar(Atomo, prueba(Atomo, Hechos)) :-
    definicion(Atomo, Hechos).

%!  definicion(?Atomo, -Hechos:list) is nondet.
%
%   Hechos son los hechos de la base, y las comparaciones, que prueban
%   Atomo, un predicado de la forma lógica.
definicion(alumno(L), [alumno(L, N, C, I)]) :-
    alumno(L, N, C, I).
definicion(materia(M), [materia(M, N, A)]) :-
    materia(M, N, A).
definicion(carrera(L, C), [alumno(L, N, C, I)]) :-
    alumno(L, N, C, I).
definicion(cursar(L, M), [inscripcion(L, M, N)]) :-
    inscripcion(L, M, N).
definicion(aprobar(L, M), [inscripcion(L, M, N), N >= 6]) :-
    aprobada(L, M, N).
definicion(necesitar(M, R), Cadena) :-
    pasos(M, R, _),
    cadena(M, R, Cadena).

% --- Las correlativas, tabuladas -------------------------------------------

:- table pasos(_, _, min).

%!  pasos(?Materia, ?Requisito, ?N:integer) is nondet.
%
%   Requisito es una correlativa de Materia, directa o a través de otras,
%   y N es la menor cantidad de correlativas de la cadena que las une.
pasos(M, R, 1) :-
    correlativa(M, R).
pasos(M, R, N) :-
    pasos(M, I, N0),
    correlativa(I, R),
    N is N0 + 1.

%!  cadena(+Materia, +Requisito, -Cadena:list) is semidet.
%
%   Cadena es una de las cadenas más cortas de hechos correlativa/2 que
%   lleva de Materia a Requisito. Cada paso elige una correlativa que
%   está un paso más cerca, según pasos/3, así que termina siempre.
cadena(M, R, [correlativa(M, I)|Resto]) :-
    pasos(M, R, N),
    correlativa(M, I),
    (   I == R, N =:= 1
    ->  Resto = []
    ;   N > 1,
        pasos(I, R, N1),
        N1 =:= N - 1
    ->  cadena(I, R, Resto)
    ),
    !.

% --- Por qué no ------------------------------------------------------------

%!  por_que_no(+F, -Motivo) is det.
%
%   Motivo explica por qué F, que no se prueba, falla: en una conjunción,
%   la primera condición que falla con la primera prueba de las
%   anteriores; en todo/3, el primer caso de la restricción que no cumple
%   el alcance; en alguno/3, por qué falla cada caso de la restricción.
por_que_no(F, Motivo) :-
    (   conectiva(F)
    ->  por_que_no_conectiva(F, Motivo)
    ;   motivo(F, Motivo)
    ).

% conectiva(F): F es una fórmula compuesta, no un predicado de la base.
conectiva(y(_, _)).
conectiva(todo(_, _, _)).
conectiva(alguno(_, _, _)).
conectiva(no(_)).

%!  por_que_no_conectiva(+F, -Motivo) is det.
%
%   Motivo explica por qué falla F, una fórmula compuesta.
por_que_no_conectiva(y(A, B), Motivo) :-
    (   once(probar(A, _))
    ->  por_que_no(B, Motivo)
    ;   por_que_no(A, Motivo)
    ).
por_que_no_conectiva(todo(X, R, A), contraejemplo(X, Motivo)) :-
    once(( probar(R, _), \+ probar(A, _) )),
    por_que_no(A, Motivo).
por_que_no_conectiva(alguno(X, R, A), ninguno(Casos)) :-
    findall(X-M, ( probar(R, _), por_que_no(A, M) ), Casos0),
    sort(1, @<, Casos0, Casos).
por_que_no_conectiva(no(A), se_prueba(Arbol)) :-
    once(probar(A, Arbol)).

%!  motivo(+Atomo, -Motivo) is det.
%
%   Motivo dice qué falta en la base para probar Atomo: aprobar/2 con una
%   inscripción cuya nota no alcanza o falta; cualquier otro predicado,
%   sin hechos que lo prueben.
motivo(aprobar(L, M), Motivo) :-
    inscripcion(L, M, N),
    !,
    (   N == null
    ->  Motivo = sin_nota(inscripcion(L, M, N))
    ;   Motivo = no_alcanza(inscripcion(L, M, N), N < 6)
    ).
motivo(Atomo, sin_hechos(Atomo)).

% --- Las hojas -------------------------------------------------------------

%!  hojas(+Arbol, -Hojas:list) is det.
%
%   Hojas son los hechos y las condiciones de Arbol, de izquierda a
%   derecha: lo que la base aporta a la prueba. Una negación aporta el
%   motivo por el que su meta no se prueba.
hojas(prueba(_, Hechos), Hechos).
hojas(y(A, B), Hojas) :-
    hojas(A, HA),
    hojas(B, HB),
    append(HA, HB, Hojas).
hojas(alguno(T), Hojas) :-
    hojas(T, Hojas).
hojas(no_se_prueba(_, Motivo), [Motivo]).
hojas(todos(Casos), Hojas) :-
    foldl(hojas_caso, Casos, [], Hojas).

%!  hojas_caso(+Caso, +Hojas0:list, -Hojas:list) is det.
%
%   Agrega a Hojas0 las hojas del árbol de Caso, un par X-Arbol.
hojas_caso(_-Arbol, Hojas0, Hojas) :-
    hojas(Arbol, H),
    append(Hojas0, H, Hojas).
