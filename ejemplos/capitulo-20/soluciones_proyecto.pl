:- encoding(utf8).

% Capítulo 20 - Soluciones de los ejercicios 13, 14 y 15: el proyecto.
%
% Es inscripciones.pl con tres agregados: registrar_nota/3 (ejercicio 13),
% el historial de operaciones (ejercicio 14) y el promedio memorizado que se
% invalida cuando cambia una nota (ejercicio 15).
%
%?- registrar_nota(101, pp, 9), promedio_memo(101, P).
%?- inscribir(104, ssl, _), dar_de_baja(104, ssl), historial(H).

:- meta_predicate
    informe(2, +, -).

:- dynamic inscripcion/3, vacantes/2, operaciones/1, requisitos_guardados/2,
    registro/2, promedio_guardado/2.

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

% operaciones(N): se realizaron N operaciones de inscripción o de baja.
operaciones(0).

%!  inscribir(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Si inscripcion_posible/3 acepta la inscripción, la registra con estado
%   cursando y descuenta una vacante. Resultado es el de
%   inscripcion_posible/3. Cuenta la operación en los dos casos.
inscribir(Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado),
    (   Resultado == aceptada
    ->  assertz(inscripcion(Legajo, Materia, cursando)),
        cambiar_vacantes(Materia, -1)
    ;   true
    ),
    contar_operacion(inscribir(Legajo, Materia, Resultado)).

%!  dar_de_baja(+Legajo:integer, +Materia:atom) is semidet.
%
%   Quita la inscripción del alumno Legajo en Materia, que debe estar
%   cursando, y devuelve la vacante. Falla si no la está cursando.
dar_de_baja(Legajo, Materia) :-
    retract(inscripcion(Legajo, Materia, cursando)),
    cambiar_vacantes(Materia, 1),
    contar_operacion(dar_de_baja(Legajo, Materia)).

%!  cambiar_vacantes(+Materia:atom, +Cambio:integer) is det.
%
%   Suma Cambio a las vacantes de Materia.
cambiar_vacantes(Materia, Cambio) :-
    retract(vacantes(Materia, N0)),
    N is N0 + Cambio,
    assertz(vacantes(Materia, N)).

%!  contar_operacion(+Operacion) is det.
%
%   Suma uno al contador de operaciones y registra Operacion en el historial
%   con ese número (ejercicio 14).
contar_operacion(Operacion) :-
    retract(operaciones(N0)),
    N is N0 + 1,
    assertz(operaciones(N)),
    assertz(registro(N, Operacion)).

%!  historial(-Operaciones:list) is det.
%
%   Operaciones son las operaciones registradas, en el orden en que se
%   hicieron, como pares Numero-Operacion.
historial(Operaciones) :-
    findall(N-Op, registro(N, Op), Operaciones).

%!  requisitos_de(+Materia:atom, -Requisitos:list(atom)) is det.
%
%   Requisitos son todas las materias que se debe aprobar antes de cursar
%   Materia, directa o indirectamente, en orden y sin repetidos. El resultado
%   se guarda la primera vez que se calcula.
requisitos_de(Materia, Requisitos) :-
    (   requisitos_guardados(Materia, Guardados)
    ->  Requisitos = Guardados
    ;   findall(R, requisito(Materia, R), Todos),
        sort(Todos, Calculados),
        assertz(requisitos_guardados(Materia, Calculados)),
        Requisitos = Calculados
    ).

%!  requisito(+Materia:atom, -Requisito:atom) is nondet.
%
%   Requisito es una correlativa de Materia, o una correlativa de una de
%   ellas.
requisito(Materia, Requisito) :-
    correlativa(Materia, Requisito).
requisito(Materia, Requisito) :-
    correlativa(Materia, Intermedia),
    requisito(Intermedia, Requisito).

%!  estado(-Estado) is det.
%
%   Estado reúne los datos que cambian durante la ejecución: las
%   inscripciones, las vacantes, el contador de operaciones y el historial.
estado(estado(Inscripciones, Vacantes, Operaciones, Registros)) :-
    findall(inscripcion(L, M, E), inscripcion(L, M, E), Inscripciones),
    findall(vacantes(M, N), vacantes(M, N), Vacantes),
    operaciones(Operaciones),
    findall(registro(N, Op), registro(N, Op), Registros).

%!  restaurar(+Estado) is det.
%
%   Reemplaza los datos que cambian durante la ejecución por los de Estado,
%   obtenido antes con estado/1, y borra los promedios guardados.
restaurar(estado(Inscripciones, Vacantes, Operaciones, Registros)) :-
    retractall(inscripcion(_, _, _)),
    retractall(vacantes(_, _)),
    retractall(operaciones(_)),
    retractall(registro(_, _)),
    retractall(promedio_guardado(_, _)),
    maplist(assertz, Inscripciones),
    maplist(assertz, Vacantes),
    assertz(operaciones(Operaciones)),
    maplist(assertz, Registros).

% --- Ejercicio 13 -------------------------------------------------------------

%!  registrar_nota(+Legajo:integer, +Materia:atom, +Nota:integer) is semidet.
%
%   Registra la nota final Nota, de 1 a 10, del alumno Legajo en Materia,
%   que debe estar cursando. Falla si no la está cursando o si la nota no es
%   válida. Borra el promedio guardado del alumno (ejercicio 15).
registrar_nota(Legajo, Materia, Nota) :-
    integer(Nota),
    between(1, 10, Nota),
    retract(inscripcion(Legajo, Materia, cursando)),
    assertz(inscripcion(Legajo, Materia, nota(Nota))),
    retractall(promedio_guardado(Legajo, _)),
    contar_operacion(registrar_nota(Legajo, Materia, Nota)).

% --- Ejercicio 15 -------------------------------------------------------------

%!  promedio_memo(+Legajo:integer, -Promedio:number) is semidet.
%
%   El promedio de promedio_de_alumno/2, guardado en promedio_guardado/2 la
%   primera vez que se calcula. registrar_nota/3 lo borra, porque deja de
%   ser correcto.
promedio_memo(Legajo, Promedio) :-
    (   promedio_guardado(Legajo, Guardado)
    ->  Promedio = Guardado
    ;   promedio_de_alumno(Legajo, Calculado),
        assertz(promedio_guardado(Legajo, Calculado)),
        Promedio = Calculado
    ).
