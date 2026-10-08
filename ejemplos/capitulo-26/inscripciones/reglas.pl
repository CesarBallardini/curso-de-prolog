:- encoding(utf8).

% Capítulo 26 - Inscripciones, módulo reglas: qué está aprobado, qué se
% puede cursar, y las operaciones que inscriben y dan de baja.
%
% Las operaciones modifican los datos a través de los predicados que exporta
% el módulo datos. requisitos_guardados/2, la tabla de requisitos_de/2, es
% privada: ningún otro módulo la ve.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- inscripcion_posible(102, am2, Resultado).

:- module(reglas,
          [ aprobada/3,
            cursa/2,
            inscripcion_posible/3,
            puede_inscribirse/2,
            aprobada_por_nombre/2,
            inscribir/3,
            dar_de_baja/2,
            requisitos_de/2
          ]).

:- use_module(library(error)).
:- use_module(datos).

:- dynamic requisitos_guardados/2.

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

%!  inscripcion_posible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es aceptada si el alumno Legajo se puede inscribir en Materia,
%   o rechazada(Motivo) con el primer motivo que lo impide: alumno_inexistente,
%   materia_inexistente, ya_aprobada, ya_la_cursa, falta(Requisito) o
%   sin_vacantes. Una materia desaprobada se puede volver a cursar.
%   Produce un error de instanciación o de tipo si Legajo no es un entero o
%   Materia no es un átomo.
inscripcion_posible(Legajo, Materia, Resultado) :-
    must_be(integer, Legajo),
    must_be(atom, Materia),
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

%!  inscribir(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Si inscripcion_posible/3 acepta la inscripción, la registra con estado
%   cursando y descuenta una vacante. Resultado es el de
%   inscripcion_posible/3. Cuenta la operación en los dos casos.
inscribir(Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado),
    (   Resultado == aceptada
    ->  agregar_inscripcion(Legajo, Materia, cursando),
        cambiar_vacantes(Materia, -1)
    ;   true
    ),
    contar_operacion.

%!  dar_de_baja(+Legajo:integer, +Materia:atom) is semidet.
%
%   Quita la inscripción del alumno Legajo en Materia, que debe estar
%   cursando, y devuelve la vacante. Falla si no la está cursando, y produce
%   un error si Legajo no es un entero o Materia no es un átomo.
dar_de_baja(Legajo, Materia) :-
    must_be(integer, Legajo),
    must_be(atom, Materia),
    quitar_inscripcion(Legajo, Materia, cursando),
    cambiar_vacantes(Materia, 1),
    contar_operacion.

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
