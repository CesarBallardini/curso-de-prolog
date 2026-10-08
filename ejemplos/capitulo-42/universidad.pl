:- encoding(utf8).

% Capítulo 42 - Prolog y SQL: las tablas académicas de Inscripciones.
%
% Las cuatro tablas de schema.sql (alumnos, materias, correlativas,
% inscripciones) como hechos: una tabla es un predicado, una fila es un
% hecho y una columna es una posición de argumento. El NULL de SQL es el
% átomo null. Siguen las vistas del capítulo (reglas), las consultas de
% agregación, el esquema como hechos (catálogo, claves y referencias) y las
% actualizaciones que respetan las restricciones del esquema.
%
%?- alumno(L, N, sistemas, _).
%?- acta(am1, Alumno, Nota).
%?- aggregate_all(count, aprobada(_, _, _), K).
%?- inscriptos(M, K).
%?- violacion(V).
%?- catch(insertar(alumno(101, zoe, civil, 2025)), E, true).

:- dynamic alumno/4, materia/3, correlativa/2, inscripcion/3.

% alumno(Legajo, Nombre, Carrera, Ingreso): la tabla alumnos.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la tabla materias.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia se debe aprobar
% Requisito. La tabla correlativas.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Nota): la tabla inscripciones. Nota es null
% mientras el alumno cursa la materia.
inscripcion(101, am1, 8).
inscripcion(101, alg, 9).
inscripcion(101, log, 10).
inscripcion(101, am2, 7).
inscripcion(101, pp,  null).
inscripcion(102, am1, 4).
inscripcion(102, log, 6).
inscripcion(102, alg, 2).
inscripcion(103, am1, 7).
inscripcion(103, alg, 5).
inscripcion(103, am2, null).
inscripcion(104, log, 9).
inscripcion(104, alg, 7).
inscripcion(104, pp,  8).
inscripcion(105, am1, null).
inscripcion(106, log, 3).
inscripcion(106, am1, 6).

% Vistas: el álgebra relacional en cláusulas

%!  aprobada(?Legajo, ?Materia, ?Nota) is nondet.
%
%   El alumno de Legajo aprobó Materia con Nota: una selección sobre
%   inscripciones. integer/1 descarta las filas con null antes de comparar.
aprobada(L, M, N) :-
    inscripcion(L, M, N),
    integer(N),
    N >= 6.

%!  de_carrera(?Carrera, ?Legajo, ?Nombre) is nondet.
%
%   Selección y proyección de alumnos: el legajo y el nombre de los alumnos
%   de Carrera.
de_carrera(Carrera, Legajo, Nombre) :-
    alumno(Legajo, Nombre, Carrera, _).

%!  acta(?Materia, ?Alumno, ?Nota) is nondet.
%
%   Reunión de inscripciones con alumnos por el legajo: el nombre de cada
%   alumno inscripto en Materia, con su nota.
acta(Materia, Alumno, Nota) :-
    inscripcion(Legajo, Materia, Nota),
    alumno(Legajo, Alumno, _, _).

%!  companeros(?Materia, ?Alumno1, ?Alumno2) is nondet.
%
%   Reunión de inscripciones consigo misma: dos alumnos distintos inscriptos
%   en la misma Materia, cada par una sola vez.
companeros(Materia, Alumno1, Alumno2) :-
    inscripcion(L1, Materia, _),
    inscripcion(L2, Materia, _),
    L1 < L2,
    alumno(L1, Alumno1, _, _),
    alumno(L2, Alumno2, _, _).

%!  vinculada(?Materia) is nondet.
%
%   Unión: Materia exige una correlativa o es correlativa de otra. Una
%   respuesta por cada fila de correlativas que la nombra.
vinculada(Materia) :-
    correlativa(Materia, _).
vinculada(Materia) :-
    correlativa(_, Materia).

%!  sin_correlativas(?Materia) is nondet.
%
%   Diferencia: las materias que no exigen ninguna correlativa. materia/3
%   liga Materia antes de la negación.
sin_correlativas(Materia) :-
    materia(Materia, _, _),
    \+ correlativa(Materia, _).

%!  en_ambas(?Materia1, ?Materia2, ?Legajo) is nondet.
%
%   Intersección: el alumno de Legajo está inscripto en las dos materias.
en_ambas(Materia1, Materia2, Legajo) :-
    inscripcion(Legajo, Materia1, _),
    inscripcion(Legajo, Materia2, _).

% Agregación

%!  inscriptos(?Materia, ?Cantidad) is nondet.
%
%   Cantidad de alumnos inscriptos en cada materia del plan, incluidas las
%   que no tienen ninguno.
inscriptos(Materia, Cantidad) :-
    materia(Materia, _, _),
    aggregate_all(count, inscripcion(_, Materia, _), Cantidad).

%!  inscriptos_grupo(?Materia, ?Cantidad) is nondet.
%
%   Lo mismo con bagof/3, que agrupa como GROUP BY: una materia sin
%   inscriptos no forma grupo.
inscriptos_grupo(Materia, Cantidad) :-
    bagof(L, N^inscripcion(L, Materia, N), Ls),
    length(Ls, Cantidad).

%!  promedio(?Materia, ?Promedio) is nondet.
%
%   Promedio de las notas de Materia, sin las filas con null, como AVG. Las
%   materias sin ninguna nota no tienen promedio.
promedio(Materia, Promedio) :-
    bagof(N, L^(inscripcion(L, Materia, N), integer(N)), Notas),
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    Promedio is Suma / Cantidad.

% El esquema como hechos

% tabla(Tabla, Predicado, Columnas): la tabla SQL Tabla se guarda en
% Predicado, con una columna Nombre-Tipo por argumento y en ese orden.
tabla(alumnos,       alumno,      [legajo-entero, nombre-texto,
                                   carrera-texto, ingreso-entero]).
tabla(materias,      materia,     [codigo-texto, nombre-texto, anio-entero]).
tabla(correlativas,  correlativa, [materia-texto, requisito-texto]).
tabla(inscripciones, inscripcion, [legajo-entero, materia-texto,
                                   nota-entero]).

% clave(Tabla, Columnas): Columnas forman la clave primaria de Tabla.
clave(alumnos,       [legajo]).
clave(materias,      [codigo]).
clave(correlativas,  [materia, requisito]).
clave(inscripciones, [legajo, materia]).

% referencia(Tabla, Columna, Referida, ColumnaReferida): cada valor de
% Columna en Tabla debe existir en ColumnaReferida de Referida.
referencia(correlativas,  materia,   materias, codigo).
referencia(correlativas,  requisito, materias, codigo).
referencia(inscripciones, legajo,    alumnos,  legajo).
referencia(inscripciones, materia,   materias, codigo).

% admite_nulo(Tabla, Columna): Columna de Tabla puede valer null.
admite_nulo(inscripciones, nota).

% rango(Tabla, Columna, Min, Max): el CHECK de Columna.
rango(inscripciones, nota, 1, 10).

%!  fila(?Tabla, ?Fila) is nondet.
%
%   Fila es un hecho guardado de Tabla: una cláusula por tabla.
fila(alumnos, alumno(L, N, C, I)) :-
    alumno(L, N, C, I).
fila(materias, materia(C, N, A)) :-
    materia(C, N, A).
fila(correlativas, correlativa(M, R)) :-
    correlativa(M, R).
fila(inscripciones, inscripcion(L, M, N)) :-
    inscripcion(L, M, N).

%!  valor(+Tabla, +Fila, ?Columna, ?Valor) is nondet.
%
%   Valor es el valor de Columna en Fila, una fila de Tabla.
valor(Tabla, Fila, Columna, Valor) :-
    tabla(Tabla, _, Columnas),
    nth1(Posicion, Columnas, Columna-_),
    arg(Posicion, Fila, Valor).

%!  tabla_de(+Fila, -Tabla) is semidet.
%
%   Fila tiene la forma de un hecho de Tabla.
tabla_de(Fila, Tabla) :-
    functor(Fila, Predicado, Aridad),
    tabla(Tabla, Predicado, Columnas),
    length(Columnas, Aridad).

%!  violacion_valor(+Tabla, +Fila, -Violacion) is nondet.
%
%   Un valor de Fila no respeta su columna: tipo, NOT NULL o CHECK.
violacion_valor(Tabla, Fila, nulo(Tabla, Columna)) :-
    valor(Tabla, Fila, Columna, null),
    \+ admite_nulo(Tabla, Columna).
violacion_valor(Tabla, Fila, tipo(Tabla, Columna, Valor)) :-
    tabla(Tabla, _, Columnas),
    member(Columna-Tipo, Columnas),
    valor(Tabla, Fila, Columna, Valor),
    Valor \== null,
    \+ es_del_tipo(Tipo, Valor).
violacion_valor(Tabla, Fila, rango(Tabla, Columna, Valor)) :-
    rango(Tabla, Columna, Min, Max),
    valor(Tabla, Fila, Columna, Valor),
    integer(Valor),
    \+ between(Min, Max, Valor).

%!  es_del_tipo(+Tipo, +Valor) is semidet.
%
%   Valor es del Tipo de una columna.
es_del_tipo(entero, Valor) :-
    integer(Valor).
es_del_tipo(texto, Valor) :-
    atom(Valor).

%!  violacion_referencia(+Tabla, +Fila, -Violacion) is nondet.
%
%   Un valor de Fila no existe en la tabla a la que su columna se refiere.
violacion_referencia(Tabla, Fila, referencia(Tabla, Columna, Valor)) :-
    referencia(Tabla, Columna, Referida, ColumnaReferida),
    valor(Tabla, Fila, Columna, Valor),
    \+ ( fila(Referida, Otra),
         valor(Referida, Otra, ColumnaReferida, Valor) ).

%!  misma_clave(+Tabla, +Fila, -Otra) is nondet.
%
%   Otra es una fila guardada de Tabla con la misma clave que Fila.
misma_clave(Tabla, Fila, Otra) :-
    clave(Tabla, Columnas),
    fila(Tabla, Otra),
    forall(member(C, Columnas),
           ( valor(Tabla, Fila, C, V), valor(Tabla, Otra, C, V) )).

%!  violacion(-Violacion) is nondet.
%
%   Violacion es una restricción del esquema que los hechos guardados no
%   cumplen. Sin respuestas, la base es consistente.
violacion(Violacion) :-
    tabla(Tabla, _, _),
    fila(Tabla, Fila),
    (   violacion_valor(Tabla, Fila, Violacion)
    ;   violacion_referencia(Tabla, Fila, Violacion)
    ).
violacion(clave(Tabla, Fila)) :-
    tabla(Tabla, _, _),
    fila(Tabla, Fila),
    aggregate_all(count, misma_clave(Tabla, Fila, _), N),
    N > 1.

% Actualizaciones

%!  insertar(+Fila) is semidet.
%
%   INSERT: agrega Fila al final de su tabla si cumple las restricciones
%   del esquema; si no, lanza error(restriccion(Violacion), _) y la base no
%   cambia. Falla si Fila no tiene la forma de una fila de alguna tabla.
insertar(Fila) :-
    tabla_de(Fila, Tabla),
    (   violacion_al_insertar(Tabla, Fila, Violacion)
    ->  throw(error(restriccion(Violacion), _))
    ;   guardar(Fila)
    ).

%!  violacion_al_insertar(+Tabla, +Fila, -Violacion) is nondet.
%
%   Fila no se puede agregar a Tabla por Violacion.
violacion_al_insertar(Tabla, Fila, Violacion) :-
    violacion_valor(Tabla, Fila, Violacion).
violacion_al_insertar(Tabla, Fila, clave(Tabla, Otra)) :-
    misma_clave(Tabla, Fila, Otra).
violacion_al_insertar(Tabla, Fila, Violacion) :-
    violacion_referencia(Tabla, Fila, Violacion).

%!  borrar(+Fila) is semidet.
%
%   DELETE de una fila: la quita de su tabla si ninguna otra fila se
%   refiere a ella; si alguna se refiere, lanza error(restriccion(_), _).
%   Falla si Fila no está guardada.
borrar(Fila) :-
    tabla_de(Fila, Tabla),
    fila(Tabla, Fila),
    (   referida(Tabla, Fila, Violacion)
    ->  throw(error(restriccion(Violacion), _))
    ;   quitar(Fila)
    ).

%!  referida(+Tabla, +Fila, -Violacion) is nondet.
%
%   Una fila de otra tabla se refiere a Fila, de Tabla.
referida(Tabla, Fila, referida(Tabla, Fila, Otra)) :-
    referencia(OtraTabla, Columna, Tabla, ColumnaReferida),
    valor(Tabla, Fila, ColumnaReferida, Valor),
    fila(OtraTabla, Otra),
    valor(OtraTabla, Otra, Columna, Valor).

%!  poner_nota(+Legajo, +Materia, +Nota) is semidet.
%
%   UPDATE de la nota de una inscripción: falla si la inscripción no
%   existe, y lanza error(restriccion(_), _) si Nota no respeta la columna.
poner_nota(Legajo, Materia, Nota) :-
    Nueva = inscripcion(Legajo, Materia, Nota),
    (   violacion_valor(inscripciones, Nueva, Violacion)
    ->  throw(error(restriccion(Violacion), _))
    ;   retract(inscripcion(Legajo, Materia, _)),
        assertz(Nueva)
    ).

%!  guardar(+Fila) is det.
%
%   Agrega Fila al final de su tabla, sin verificar nada. Una cláusula por
%   tabla, como fila/2: SWISH solo admite assertz/1 de hechos conocidos.
guardar(alumno(L, N, C, I)) :-
    assertz(alumno(L, N, C, I)).
guardar(materia(C, N, A)) :-
    assertz(materia(C, N, A)).
guardar(correlativa(M, R)) :-
    assertz(correlativa(M, R)).
guardar(inscripcion(L, M, N)) :-
    assertz(inscripcion(L, M, N)).

%!  quitar(+Fila) is semidet.
%
%   Quita de su tabla el primer hecho que unifica con Fila.
quitar(alumno(L, N, C, I)) :-
    retract(alumno(L, N, C, I)).
quitar(materia(C, N, A)) :-
    retract(materia(C, N, A)).
quitar(correlativa(M, R)) :-
    retract(correlativa(M, R)).
quitar(inscripcion(L, M, N)) :-
    retract(inscripcion(L, M, N)).
