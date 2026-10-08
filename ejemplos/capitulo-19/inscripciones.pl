:- encoding(utf8).

% Capítulo 19 - El proyecto Inscripciones: los motivos de rechazo como reglas.
%
% Respecto del capítulo 18, las condiciones que rechazan una inscripción se
% escriben además como reglas si ... entonces ..., datos que lee el intérprete
% prueba/3 de la sección 19.4, con una cláusula más para la negación no.
% situacion/3 traduce la base al vocabulario de las reglas, y
% motivos_de_rechazo/3 reúne todos los motivos, no solo el primero que
% encuentra inscripcion_posible/3.
%
%?- motivos_de_rechazo(102, am2, Motivos).
%?- motivos_de_rechazo(101, log, Motivos).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).
:- op(770, fy, no).

:- meta_predicate
    informe(2, +, -).

% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia se debe aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Estado): el alumno se inscribió en la materia;
% Estado es cursando, o nota(N) con la nota final N, de 1 a 10.
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
inscripcion(101, log, nota(10)).
inscripcion(101, am2, nota(7)).
inscripcion(101, pp,  cursando).
inscripcion(102, am1, nota(4)).
inscripcion(102, log, nota(6)).
inscripcion(102, alg, nota(2)).
inscripcion(103, am1, nota(7)).
inscripcion(103, alg, nota(5)).
inscripcion(103, am2, cursando).
inscripcion(104, log, nota(9)).
inscripcion(104, alg, nota(7)).
inscripcion(104, pp,  nota(8)).
inscripcion(105, am1, cursando).
inscripcion(106, log, nota(3)).
inscripcion(106, am1, nota(6)).

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia.
nota_minima(6).

%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota. Con Legajo y Materia ligados
%   hay una respuesta o ninguna; con Nota ligada, además, se comprueba la
%   nota.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota >= Minima.

%!  cursa(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo está cursando Materia, todavía sin nota.
cursa(Legajo, Materia) :-
    inscripcion(Legajo, Materia, cursando).

% vacantes(Materia, N): quedan N lugares en la materia.
vacantes(am1, 30).
vacantes(alg, 30).
vacantes(log, 0).
vacantes(am2, 25).
vacantes(pp,  25).
vacantes(ssl, 20).
vacantes(bd,  15).

%!  inscripcion_posible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es aceptada si el alumno Legajo se puede inscribir en Materia,
%   o rechazada(Motivo) con el primer motivo que lo impide: alumno_inexistente,
%   materia_inexistente, ya_aprobada, ya_la_cursa, falta(Requisito) o
%   sin_vacantes. Una materia desaprobada se puede volver a cursar.
inscripcion_posible(Legajo, Materia, Resultado) :-
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   aprobada(Legajo, Materia, _)
    ->  Resultado = rechazada(ya_aprobada)
    ;   cursa(Legajo, Materia)
    ->  Resultado = rechazada(ya_la_cursa)
    ;   correlativa(Materia, Requisito),
        \+ aprobada(Legajo, Requisito, _)
    ->  Resultado = rechazada(falta(Requisito))
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   Resultado = aceptada
    ).

%!  puede_inscribirse(+Legajo:integer, +Materia:atom) is semidet.
%
%   El alumno Legajo se puede inscribir en Materia.
puede_inscribirse(Legajo, Materia) :-
    inscripcion_posible(Legajo, Materia, aceptada).

%!  aprobada_por_nombre(?Nombre:atom, ?Materia:atom) is nondet.
%
%   El alumno llamado Nombre aprobó Materia. El primer objetivo es el que el
%   nombre selecciona: con el orden inverso, la consulta recorre todas las
%   inscripciones de la materia antes de examinar el nombre (sección 16.5).
aprobada_por_nombre(Nombre, Materia) :-
    alumno(Legajo, Nombre, _, _),
    aprobada(Legajo, Materia, _Nota).

%!  inscriptos(+Materia:atom, -Legajos:list(integer)) is det.
%
%   Legajos son los alumnos inscriptos en Materia, en orden y sin repetidos;
%   la lista vacía si no hay ninguno.
inscriptos(Materia, Legajos) :-
    findall(Legajo, inscripcion(Legajo, Materia, _), Todos),
    sort(Todos, Legajos).

%!  legajos(-Legajos:list(integer)) is det.
%
%   Legajos son los legajos de todos los alumnos, en el orden de los hechos.
legajos(Legajos) :-
    findall(Legajo, alumno(Legajo, _, _, _), Legajos).

%!  tiene_nota(+Legajo:integer) is semidet.
%
%   El alumno Legajo tiene al menos una nota.
tiene_nota(Legajo) :-
    once(inscripcion(Legajo, _, nota(_))).

%!  sin_notas(-Legajos:list(integer)) is det.
%
%   Legajos son los alumnos que no tienen ninguna nota: los que no se
%   inscribieron en nada y los que solo están cursando.
sin_notas(Legajos) :-
    legajos(Todos),
    exclude(tiene_nota, Todos, Legajos).

%!  promedio(+Notas:list(number), -Promedio:number) is semidet.
%
%   Promedio es el promedio de Notas. Falla con la lista vacía. Un solo
%   recorrido cuenta y suma a la vez: el valor acumulado es el par
%   Cantidad-Suma.
promedio(Notas, Promedio) :-
    foldl(contar_y_sumar, Notas, 0-0, Cantidad-Suma),
    Cantidad > 0,
    Promedio is Suma / Cantidad.

%!  contar_y_sumar(+Nota:number, +Hasta:pair, -Total:pair) is det.
%
%   Total es el par Cantidad-Suma de Hasta con Nota agregada.
contar_y_sumar(Nota, Cantidad0-Suma0, Cantidad-Suma) :-
    Cantidad is Cantidad0 + 1,
    Suma is Suma0 + Nota.

%!  promedio_de_materia(+Materia:atom, -Promedio:number) is semidet.
%
%   Promedio es el promedio de las notas de Materia. Falla si la materia no
%   tiene ninguna nota.
promedio_de_materia(Materia, Promedio) :-
    findall(N, inscripcion(_, Materia, nota(N)), Notas),
    promedio(Notas, Promedio).

%!  promedio_de_alumno(?Legajo:integer, -Promedio:number) is nondet.
%
%   Promedio es el promedio de las notas del alumno Legajo, para cada alumno
%   con al menos una nota.
promedio_de_alumno(Legajo, Promedio) :-
    alumno(Legajo, _, _, _),
    findall(N, inscripcion(Legajo, _, nota(N)), Notas),
    promedio(Notas, Promedio).

%!  aprobadas(+Legajo:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de materias que aprobó el alumno Legajo.
aprobadas(Legajo, Cantidad) :-
    aggregate_all(count, aprobada(Legajo, _, _), Cantidad).

%!  informe(:Calculo, +Legajos:list(integer), -Filas:list(pair)) is det.
%
%   Filas tiene un par Legajo-Valor por cada alumno de Legajos para el que
%   call(Calculo, Legajo, Valor) se cumple, con su primer Valor; los demás
%   se omiten.
informe(Calculo, Legajos, Filas) :-
    convlist({Calculo}/[Legajo, Legajo-Valor]>>
                 once(call(Calculo, Legajo, Valor)),
             Legajos, Filas).

%!  mostrar_informe(+Titulo:atom, +Filas:list(pair)) is semidet.
%
%   Escribe Titulo y una línea por fila, con el legajo, el nombre y el valor.
%   Falla en la primera fila cuyo legajo no es de un alumno.
mostrar_informe(Titulo, Filas) :-
    format("~w~n", [Titulo]),
    maplist(mostrar_fila, Filas).

%!  mostrar_fila(+Fila:pair) is semidet.
%
%   Escribe una fila Legajo-Valor de un informe. Falla si Legajo no es de un
%   alumno.
mostrar_fila(Legajo-Valor) :-
    alumno(Legajo, Nombre, _, _),
    format("  ~d ~w: ~w~n", [Legajo, Nombre, Valor]).

%!  mejores(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Ranking es la lista de los Cantidad mejores promedios, de mayor a menor,
%   como pares Legajo-Promedio.
mejores(Cantidad, Ranking) :-
    findall(Legajo-Promedio,
            limit(Cantidad,
                  order_by([desc(Promedio)],
                           promedio_de_alumno(Legajo, Promedio))),
            Ranking).

% regla(Nombre, si Condiciones entonces Conclusion): los motivos que rechazan
% una inscripción, escritos sobre la situación del alumno frente a la materia.
regla(v1, si materia(M) y aprobada(M) entonces rechazada(ya_aprobada)).
regla(v2, si materia(M) y cursando(M) entonces rechazada(ya_la_cursa)).
regla(v3, si requisito(R) y no aprobada(R) entonces rechazada(falta(R))).
regla(v4, si vacantes(0) entonces rechazada(sin_vacantes)).

%!  situacion(+Legajo:integer, +Materia:atom, -Observaciones:list) is det.
%
%   Observaciones describe la situación del alumno Legajo frente a Materia
%   en el vocabulario de las reglas: la lista de las observaciones de
%   observacion/3, en el orden de sus cláusulas.
situacion(Legajo, Materia, Observaciones) :-
    findall(Obs, observacion(Legajo, Materia, Obs), Observaciones).

%!  observacion(+Legajo:integer, +Materia:atom, -Obs) is nondet.
%
%   Obs es una observación sobre el alumno Legajo y la materia Materia:
%   materia(Materia); aprobada(M) por cada materia que el alumno aprobó;
%   cursando(M) por cada una que cursa; requisito(R) por cada correlativa de
%   Materia; y vacantes(N), los lugares que quedan.
observacion(_, Materia, materia(Materia)).
observacion(Legajo, _, aprobada(M)) :-
    aprobada(Legajo, M, _).
observacion(Legajo, _, cursando(M)) :-
    cursa(Legajo, M).
observacion(_, Materia, requisito(R)) :-
    correlativa(Materia, R).
observacion(_, Materia, vacantes(N)) :-
    vacantes(Materia, N).

%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   El intérprete de la sección 19.4 con una cláusula más: no Meta se cumple
%   cuando Meta no se puede probar, y su árbol es no Meta. Meta debe llegar
%   sin variables libres.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
prueba(X > Y, _, X > Y) :-
    X > Y.
prueba(X < Y, _, X < Y) :-
    X < Y.
prueba(Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba(Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    prueba(Condiciones, Observaciones, Arbol).

%!  motivos_de_rechazo(+Legajo:integer, +Materia:atom, -Motivos:list) is det.
%
%   Motivos son todos los motivos por los que se rechaza la inscripción del
%   alumno Legajo en Materia, uno por cada prueba de rechazada(Motivo) con
%   las reglas; la lista vacía si se acepta. inscripcion_posible/3 da solo
%   el primero. Supone que el alumno y la materia existen: esas dos
%   condiciones las verifica inscripcion_posible/3 antes que cualquier regla.
motivos_de_rechazo(Legajo, Materia, Motivos) :-
    situacion(Legajo, Materia, Observaciones),
    findall(Motivo, prueba(rechazada(Motivo), Observaciones, _), Motivos).
