:- encoding(utf8).

% Capítulo 21 - Soluciones de los ejercicios 14, 15 y 16: el proyecto.
%
% Es inscripciones.pl con el comando vacantes (ejercicio 14), texto_de/2
% (ejercicio 15) y una respuesta de uso para los comandos mal escritos
% (ejercicio 16).
%
%?- ejecutar("vacantes de logica", Respuesta).
%?- ejecutar("inscribir 104", Respuesta).

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

% correlativa(Materia, Requisito): para cursar Materia hay que aprobar
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
%   Requisitos son todas las materias que hay que aprobar antes de cursar
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
%   listado, promedio(P) o sin_notas para un promedio, vacantes(N) para las
%   vacantes de una materia (ejercicio 14). Si el texto no es un comando pero
%   empieza con la palabra de uno, Respuesta es uso(Ejemplo), con un comando
%   de ejemplo que empieza igual (ejercicio 16); si no, no_entendido.
ejecutar(Texto, Respuesta) :-
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  realizar(Comando, Respuesta)
    ;   phrase(palabras([Verbo|_]), Codigos),
        once(phrase(comando(_), [Verbo|Resto]))
    ->  atomic_list_concat([Verbo|Resto], ' ', Ejemplo),
        Respuesta = uso(Ejemplo)
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
comando(vacantes(M)) -->
    [vacantes, de], materia_por_nombre(M).

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
realizar(vacantes(M), vacantes(N)) :-
    vacantes(M, N).
realizar(promedio(L), Respuesta) :-
    (   promedio_de_alumno(L, P)
    ->  Respuesta = promedio(P)
    ;   Respuesta = sin_notas
    ).

%!  texto_de(+Comando, -Texto:atom) is semidet.
%
%   Texto es el texto de Comando, generado con la misma gramática que lo
%   analiza (ejercicio 15).
texto_de(Comando, Texto) :-
    once(phrase(comando(Comando), Palabras)),
    atomic_list_concat(Palabras, ' ', Texto).
