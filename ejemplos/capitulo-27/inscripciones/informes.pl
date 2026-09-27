:- encoding(utf8).

% Capítulo 27 - Inscripciones, módulo informes: listados, promedios, el
% ranking y el índice por alumno.
%
% Solo consulta los datos: no modifica nada. informe/3 recibe un predicado
% como argumento, y la directiva meta_predicate hace que ese predicado se
% busque en el módulo que llama a informe/3.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- ranking(R).

:- module(informes,
          [ inscriptos/2,
            legajos/1,
            sin_notas/1,
            promedio/2,
            promedio_de_materia/2,
            promedio_de_alumno/2,
            aprobadas/2,
            informe/3,
            mostrar_informe/2,
            ranking/1,
            mejores/2,
            indice_por_alumno/1,
            materias_de/3
          ]).

:- use_module(datos).
:- use_module(reglas).

:- meta_predicate
    informe(2, +, -).

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
