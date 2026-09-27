:- encoding(utf8).

% Capítulo 23 - Soluciones de los ejercicios 14, 15 y 16: el proyecto.
%
% Es inscripciones.pl con horario_minimo/3 (ejercicio 14), horario_separado/3
% (ejercicio 15) y horario_con_aulas/3 (ejercicio 16).
%
%?- horario_minimo(20, Dias, Horario).
%?- horario_con_aulas([4, 6], 5, Horario).

:- use_module(library(clpfd)).
:- use_module(library(dcg/basics)).

:- meta_predicate
    informe(2, +, -).

:- dynamic inscripcion/3, vacantes/2, operaciones/1, requisitos_guardados/2.

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

% correlativa(Materia, Requisito): para cursar Materia es necesario aprobar
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
%   inscripciones de la materia antes de mirar el nombre (sección 16.5).
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

%!  ranking(-Ranking:list(pair)) is det.
%
%   Ranking son los pares Legajo-Promedio de los alumnos con alguna nota, de
%   mayor a menor promedio; con el mismo promedio, en el orden de los legajos.
ranking(Ranking) :-
    findall(Legajo-Promedio, promedio_de_alumno(Legajo, Promedio), Pares),
    sort(2, @>=, Pares, Ranking).

%!  mejores(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Ranking es la lista de los Cantidad mejores promedios, de mayor a menor,
%   como pares Legajo-Promedio.
mejores(Cantidad, Ranking) :-
    ranking(Todos),
    findall(Par, limit(Cantidad, member(Par, Todos)), Ranking).

%!  indice_por_alumno(-Indice) is det.
%
%   Indice es un assoc de cada legajo con inscripciones a la lista de sus
%   pares Materia-Estado, en el orden de los hechos.
indice_por_alumno(Indice) :-
    findall(Legajo-(Materia-Estado),
            inscripcion(Legajo, Materia, Estado),
            Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    list_to_assoc(Grupos, Indice).

%!  materias_de(+Indice, +Legajo:integer, -Materias:list(pair)) is det.
%
%   Materias son los pares Materia-Estado del alumno Legajo en Indice; la
%   lista vacía si no tiene inscripciones.
materias_de(Indice, Legajo, Materias) :-
    (   get_assoc(Legajo, Indice, Encontradas)
    ->  Materias = Encontradas
    ;   Materias = []
    ).

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
    contar_operacion.

%!  dar_de_baja(+Legajo:integer, +Materia:atom) is semidet.
%
%   Quita la inscripción del alumno Legajo en Materia, que debe estar
%   cursando, y devuelve la vacante. Falla si no la está cursando.
dar_de_baja(Legajo, Materia) :-
    retract(inscripcion(Legajo, Materia, cursando)),
    cambiar_vacantes(Materia, 1),
    contar_operacion.

%!  cambiar_vacantes(+Materia:atom, +Cambio:integer) is det.
%
%   Suma Cambio a las vacantes de Materia.
cambiar_vacantes(Materia, Cambio) :-
    retract(vacantes(Materia, N0)),
    N is N0 + Cambio,
    assertz(vacantes(Materia, N)).

%!  contar_operacion is det.
%
%   Suma uno al contador de operaciones.
contar_operacion :-
    retract(operaciones(N0)),
    N is N0 + 1,
    assertz(operaciones(N)).

%!  requisitos_de(+Materia:atom, -Requisitos:list(atom)) is det.
%
%   Requisitos son todas las materias que se deben aprobar antes de cursar
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
%   inscripciones, las vacantes y el contador de operaciones.
estado(estado(Inscripciones, Vacantes, Operaciones)) :-
    findall(inscripcion(L, M, E), inscripcion(L, M, E), Inscripciones),
    findall(vacantes(M, N), vacantes(M, N), Vacantes),
    operaciones(Operaciones).

%!  restaurar(+Estado) is det.
%
%   Reemplaza los datos que cambian durante la ejecución por los de Estado,
%   obtenido antes con estado/1.
restaurar(estado(Inscripciones, Vacantes, Operaciones)) :-
    retractall(inscripcion(_, _, _)),
    retractall(vacantes(_, _)),
    retractall(operaciones(_)),
    maplist(assertz, Inscripciones),
    maplist(assertz, Vacantes),
    assertz(operaciones(Operaciones)).

%!  ejecutar(+Texto:string, -Respuesta) is det.
%
%   Analiza el comando Texto y lo ejecuta. Respuesta es el resultado:
%   aceptada o rechazada(Motivo) para una inscripción, baja o
%   rechazada(no_la_cursa) para una baja, inscriptos(Legajos) para un
%   listado, promedio(P) o sin_notas para un promedio, y no_entendido si el
%   texto no es un comando.
ejecutar(Texto, Respuesta) :-
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  realizar(Comando, Respuesta)
    ;   Respuesta = no_entendido
    ).

%!  palabras(-Palabras:list)// is det.
%
%   Palabras son las palabras y los números del texto, separados por
%   blancos. Una palabra es un átomo; un número, un entero.
palabras([P|Ps]) -->
    blanks,
    palabra(P),
    !,
    palabras(Ps).
palabras([]) -->
    blanks.

%!  palabra(-P)// is semidet.
%
%   P es un entero, si el texto empieza con dígitos, o un átomo formado por
%   letras, dígitos y guiones bajos.
palabra(N) -->
    integer(N),
    !.
palabra(A) -->
    csym(A).

%!  comando(?Comando)// is nondet.
%
%   La lista de palabras de Comando: inscribir(Legajo, Materia),
%   baja(Legajo, Materia), listar(Materia) o promedio(Legajo). Las materias
%   se escriben con su nombre, no con su código.
comando(inscribir(L, M)) -->
    [inscribir, a], legajo(L), [en], materia_por_nombre(M).
comando(baja(L, M)) -->
    [dar, de, baja, a], legajo(L), [en], materia_por_nombre(M).
comando(listar(M)) -->
    [listar], materia_por_nombre(M).
comando(promedio(L)) -->
    [promedio, de], legajo(L).

%!  legajo(?L)// is semidet.
%
%   El legajo de un alumno.
legajo(L) -->
    [L],
    { alumno(L, _, _, _) }.

%!  materia_por_nombre(?Codigo)// is semidet.
%
%   El nombre de la materia de código Codigo.
materia_por_nombre(Codigo) -->
    [Nombre],
    { materia(Codigo, Nombre, _) }.

%!  realizar(+Comando, -Respuesta) is det.
%
%   Ejecuta Comando, ya analizado, y da su Respuesta.
realizar(inscribir(L, M), Respuesta) :-
    inscribir(L, M, Respuesta).
realizar(baja(L, M), Respuesta) :-
    (   dar_de_baja(L, M)
    ->  Respuesta = baja
    ;   Respuesta = rechazada(no_la_cursa)
    ).
realizar(listar(M), inscriptos(Legajos)) :-
    inscriptos(M, Legajos).
realizar(promedio(L), Respuesta) :-
    (   promedio_de_alumno(L, P)
    ->  Respuesta = promedio(P)
    ;   Respuesta = sin_notas
    ).

%!  horario(+Dias:integer, +Capacidad:integer, -Horario:list(pair)) is nondet.
%
%   Horario son pares Materia-Dia, con días de 1 a Dias, tales que dos
%   materias con un alumno inscripto en común rinden en días distintos y la
%   cantidad de alumnos que rinden cada día no supera Capacidad.
horario(Dias, Capacidad, Horario) :-
    findall(M-_, materia(M, _, _), Horario),
    pairs_values(Horario, Ds),
    Ds ins 1..Dias,
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dias_distintos(Horario), Conflictos),
    numlist(1, Dias, Todos),
    maplist(capacidad_del_dia(Horario, Capacidad), Todos),
    label(Ds).

%!  conflicto(?M1:atom, ?M2:atom) is nondet.
%
%   M1 y M2 son materias distintas, M1 antes que M2 en orden alfabético, con
%   al menos un alumno inscripto en las dos. Una respuesta por par.
conflicto(M1, M2) :-
    materia(M1, _, _),
    materia(M2, _, _),
    M1 @< M2,
    once(( inscripcion(L, M1, _),
           inscripcion(L, M2, _) )).

%!  dias_distintos(+Horario:list(pair), +Conflicto:pair) is semidet.
%
%   Las dos materias de Conflicto tienen el examen en días distintos.
dias_distintos(Horario, M1-M2) :-
    memberchk(M1-D1, Horario),
    memberchk(M2-D2, Horario),
    D1 #\= D2.

%!  capacidad_del_dia(+Horario:list(pair), +Capacidad:integer, +Dia:integer)
%!      is semidet.
%
%   Los alumnos inscriptos en las materias que rinden el día Dia no son más
%   que Capacidad. Cada materia aporta sus inscriptos si su día es Dia: la
%   comparación se refleja en una variable 0 o 1.
capacidad_del_dia(Horario, Capacidad, Dia) :-
    maplist(rinde_ese_dia(Dia), Horario, Rinden),
    maplist(cantidad_de_inscriptos, Horario, Cantidades),
    scalar_product(Cantidades, Rinden, #=<, Capacidad).

%!  rinde_ese_dia(+Dia:integer, +MateriaDia:pair, -B) is det.
%
%   B es 1 si la materia rinde el día Dia, y 0 si no.
rinde_ese_dia(Dia, _-D, B) :-
    B #<==> (D #= Dia).

%!  cantidad_de_inscriptos(+MateriaDia:pair, -N:integer) is det.
%
%   N es la cantidad de alumnos inscriptos en la materia.
cantidad_de_inscriptos(M-_, N) :-
    inscriptos(M, Legajos),
    length(Legajos, N).

% --- Ejercicio 14 ---------------------------------------------------------

%!  horario_minimo(+Capacidad:integer, -Dias:integer, -Horario:list(pair))
%!      is semidet.
%
%   Dias es la menor cantidad de días con la que hay un horario, y Horario el
%   primero de esos horarios. Prueba 1, 2, … días, hasta la cantidad de
%   materias. Falla si no hay horario con ninguna cantidad de días.
horario_minimo(Capacidad, Dias, Horario) :-
    aggregate_all(count, materia(_, _, _), Materias),
    between(1, Materias, Dias),
    horario(Dias, Capacidad, Horario),
    !.

% --- Ejercicio 15 ---------------------------------------------------------

%!  horario_separado(+Dias:integer, +Capacidad:integer, -Horario:list(pair))
%!      is nondet.
%
%   Como horario/3, con dos días al menos entre los exámenes de dos materias
%   con un alumno en común.
horario_separado(Dias, Capacidad, Horario) :-
    findall(M-_, materia(M, _, _), Horario),
    pairs_values(Horario, Ds),
    Ds ins 1..Dias,
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dias_separados(Horario), Conflictos),
    numlist(1, Dias, Todos),
    maplist(capacidad_del_dia(Horario, Capacidad), Todos),
    label(Ds).

%!  dias_separados(+Horario:list(pair), +Conflicto:pair) is semidet.
%
%   Los exámenes de las dos materias de Conflicto están a dos días o más.
dias_separados(Horario, M1-M2) :-
    memberchk(M1-D1, Horario),
    memberchk(M2-D2, Horario),
    abs(D1 - D2) #>= 2.

% --- Ejercicio 16 ---------------------------------------------------------

%!  horario_con_aulas(+Capacidades:list(integer), +Dias:integer,
%!                    -Horario:list) is nondet.
%
%   Horario tiene un término examen(Materia, Dia, Aula) por materia. Las
%   aulas son 1, 2, … con las Capacidades dadas: cada aula tiene un examen
%   por día como máximo, y los inscriptos de la materia caben en el aula.
%   Dos materias con un alumno en común rinden en días distintos.
horario_con_aulas(Capacidades, Dias, Horario) :-
    length(Capacidades, Aulas),
    findall(examen(M, _, _), materia(M, _, _), Horario),
    maplist(dominio_de_examen(Dias, Aulas, Capacidades), Horario),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(examenes_en_dias_distintos(Horario), Conflictos),
    turnos_distintos(Horario),
    append_variables(Horario, Vs),
    label(Vs).

%!  dominio_de_examen(+Dias, +Aulas, +Capacidades, +Examen) is semidet.
%
%   El día del Examen va de 1 a Dias, el aula de 1 a Aulas, y la capacidad
%   del aula elegida alcanza para los inscriptos de la materia.
dominio_de_examen(Dias, Aulas, Capacidades, examen(M, Dia, Aula)) :-
    Dia in 1..Dias,
    Aula in 1..Aulas,
    inscriptos(M, Legajos),
    length(Legajos, N),
    element(Aula, Capacidades, Capacidad),
    N #=< Capacidad.

%!  examenes_en_dias_distintos(+Horario:list, +Conflicto:pair) is det.
%
%   Las dos materias de Conflicto rinden en días distintos.
examenes_en_dias_distintos(Horario, M1-M2) :-
    memberchk(examen(M1, D1, _), Horario),
    memberchk(examen(M2, D2, _), Horario),
    D1 #\= D2.

%!  turnos_distintos(+Horario:list) is det.
%
%   Dos exámenes no ocupan la misma aula el mismo día: cada par Dia-Aula se
%   codifica como un número distinto.
turnos_distintos(Horario) :-
    maplist([examen(_, D, A), T]>>(T #= D * 100 + A), Horario, Turnos),
    all_different(Turnos).

%!  append_variables(+Horario:list, -Vs:list) is det.
%
%   Vs son las variables de día y aula de Horario, en orden.
append_variables(Horario, Vs) :-
    foldl([examen(_, D, A), V0, V]>>append(V0, [D, A], V), Horario, [], Vs).
