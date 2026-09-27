:- encoding(utf8).

% Capítulo 17 - Soluciones de los ejercicios.
%
%?- abuelos_con_nietos(A, Nietos).
%?- los_mejores_de_cada_carrera(Carrera, Legajo).

% --- Ejercicios 2, 3, 4 y 7: una familia con una nieta más que la del texto --

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).
padre(ana, sofia).

% edad(P, A): P tiene A años. juan y marta empatan en la mayor edad.
edad(juan, 68).
edad(marta, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

%!  nietos_de(+Abuelo, -Nietos:list) is det.
%
%   Nietos es la lista de los nietos de Abuelo.
nietos_de(Abuelo, Nietos) :-
    findall(N, ( padre(Abuelo, P), padre(P, N) ), Nietos).

%!  abuelos_con_nietos(?Abuelo, -Nietos:list) is nondet.
%
%   Una respuesta por abuelo, con la lista de sus nietos. P^ hace que el
%   progenitor intermedio no agrupe.
abuelos_con_nietos(Abuelo, Nietos) :-
    bagof(N, P^( padre(Abuelo, P), padre(P, N) ), Nietos).

%!  edades_ordenadas(-Edades:list(integer)) is semidet.
%
%   Edades es la lista ordenada y sin repetidos de las edades de la base.
edades_ordenadas(Edades) :-
    setof(E, P^edad(P, E), Edades).

%!  edades_ordenadas_2(-Edades:list(integer)) is det.
%
%   La misma lista con findall/3 y sort/2, que también elimina los repetidos.
%   Con la base vacía da la lista vacía, en lugar de fallar.
edades_ordenadas_2(Edades) :-
    findall(E, edad(_, E), Todas),
    sort(Todas, Edades).

%!  menor_edad(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la menor edad de la base.
menor_edad(Quien, Edad) :-
    aggregate_all(min(E, P), edad(P, E), min(Edad, Quien)).

%!  mayor_edad_2(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la mayor edad, con findall/3 y max_member/2. Con empate, el
%   mayor par Edad-Quien en el orden estándar: el nombre posterior.
mayor_edad_2(Quien, Edad) :-
    findall(E-P, edad(P, E), Pares),
    max_member(Edad-Quien, Pares).

% --- Ejercicio 14: el tablero del Buscaminas del texto -----------------------

% tamanio(Filas, Columnas): las dimensiones del tablero.
tamanio(5, 5).

% mina(Fila, Columna): hay una mina en esa celda.
mina(1, 1).
mina(2, 3).
mina(4, 2).
mina(4, 5).

%!  vecina(+F:integer, +C:integer, -VF:integer, -VC:integer) is nondet.
%
%   (VF, VC) es una de las celdas vecinas de (F, C), dentro del tablero.
vecina(F, C, VF, VC) :-
    tamanio(Filas, Columnas),
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  minas_alrededor(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de minas en las celdas vecinas de (F, C).
minas_alrededor(F, C, N) :-
    aggregate_all(count, ( vecina(F, C, VF, VC), mina(VF, VC) ), N).

%!  simbolo(+F:integer, +C:integer, -S) is det.
%
%   S es * si hay una mina en (F, C), y la cantidad de minas vecinas si no.
simbolo(F, C, S) :-
    (   mina(F, C)
    ->  S = '*'
    ;   minas_alrededor(F, C, S)
    ).

%!  tablero_texto(-Lineas:list(string)) is det.
%
%   Lineas son las filas del tablero como cadenas, una por fila.
tablero_texto(Lineas) :-
    tamanio(Filas, _),
    findall(Linea,
            ( between(1, Filas, F),
              fila_texto(F, Linea) ),
            Lineas).

%!  fila_texto(+F:integer, -Linea:string) is det.
%
%   Linea es la fila F del tablero, con un símbolo por celda.
fila_texto(F, Linea) :-
    tamanio(_, Columnas),
    findall(S, ( between(1, Columnas, C), simbolo(F, C, S) ), Simbolos),
    atomic_list_concat(Simbolos, Atomo),
    atom_string(Atomo, Linea).

% --- Ejercicios 5, 6, 8, 9, 10, 11, 13, 15 y 16: Inscripciones --------------

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

%!  sin_notas(-Legajos:list(integer)) is det.
%
%   Legajos son los alumnos que no tienen ninguna nota: los que no se
%   inscribieron en nada y los que solo están cursando.
sin_notas(Legajos) :-
    findall(Legajo,
            ( alumno(Legajo, _, _, _),
              \+ inscripcion(Legajo, _, nota(_)) ),
            Legajos).

%!  promedio_de_materia(+Materia:atom, -Promedio:number) is semidet.
%
%   Promedio es el promedio de las notas de Materia. Falla si la materia no
%   tiene ninguna nota.
promedio_de_materia(Materia, Promedio) :-
    aggregate_all(count, inscripcion(_, Materia, nota(_)), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(N), inscripcion(_, Materia, nota(N)), Suma),
    Promedio is Suma / Cantidad.

%!  promedio_de_alumno(?Legajo:integer, -Promedio:number) is nondet.
%
%   Promedio es el promedio de las notas del alumno Legajo, para cada alumno
%   con al menos una nota.
promedio_de_alumno(Legajo, Promedio) :-
    alumno(Legajo, _, _, _),
    aggregate_all(count, inscripcion(Legajo, _, nota(_)), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(N), inscripcion(Legajo, _, nota(N)), Suma),
    Promedio is Suma / Cantidad.

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

%!  materia_de_anio(+Anio:integer, -Materias:list(atom)) is det.
%
%   Materias son los códigos de las materias de Anio, en el orden en que
%   aparecen en la base; la lista vacía si no hay ninguna.
materia_de_anio(Anio, Materias) :-
    findall(M, materia(M, _, Anio), Materias).

%!  requisitos_faltantes_2(+Legajo:integer, +Materia:atom,
%!                         -Faltan:list(atom)) is det.
%
%   Faltan son los requisitos de Materia que el alumno Legajo no aprobó, sin
%   repetir las correlatividades en una tabla aparte.
requisitos_faltantes_2(Legajo, Materia, Faltan) :-
    findall(R,
            ( correlativa(Materia, R),
              \+ aprobada(Legajo, R, _) ),
            Faltan).

%!  todos_aprobados(+Legajo:integer) is semidet.
%
%   El alumno Legajo se inscribió en alguna materia y aprobó todas en las que
%   se inscribió. Sin la primera condición, forall/2 se cumpliría para un
%   alumno sin inscripciones.
todos_aprobados(Legajo) :-
    once(inscripcion(Legajo, _, _)),
    forall(inscripcion(Legajo, Materia, _),
           aprobada(Legajo, Materia, _)).

%!  cantidad_por_materia(?Materia:atom, -N:integer) is nondet.
%
%   N es la cantidad de inscriptos en Materia, una respuesta por materia con
%   al menos uno.
cantidad_por_materia(Materia, N) :-
    aggregate(count, Legajo^Estado^inscripcion(Legajo, Materia, Estado), N).

%!  mejor_de_materia(+Materia:atom, -Legajo:integer, -Nota:integer) is semidet.
%
%   Legajo tiene la nota más alta de Materia. Con empate, el primero.
mejor_de_materia(Materia, Legajo, Nota) :-
    aggregate_all(max(N, L), inscripcion(L, Materia, nota(N)),
                  max(Nota, Legajo)).

%!  listar_inscriptos(+Materia:atom) is det.
%
%   Escribe una línea por alumno inscripto en Materia, con su nombre.
listar_inscriptos(Materia) :-
    forall(( inscripcion(Legajo, Materia, _),
             alumno(Legajo, Nombre, _, _) ),
           format("~w ~w~n", [Legajo, Nombre])).

%!  los_mejores_de_cada_carrera(?Carrera:atom, -Legajo:integer) is nondet.
%
%   Legajo tiene el mejor promedio de Carrera, una respuesta por carrera con
%   algún alumno con notas. aggregate/3 agrupa por Carrera; los demás
%   argumentos de alumno/4 se marcan con ^ para que no agrupen.
los_mejores_de_cada_carrera(Carrera, Legajo) :-
    aggregate(max(P, L),
              Nombre^Ingreso^( alumno(L, Nombre, Carrera, Ingreso),
                               promedio_de_alumno(L, P) ),
              max(_, Legajo)).

%!  mejores_2(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Como mejores/2, con findall/3, sort/4 y los primeros Cantidad elementos.
mejores_2(Cantidad, Ranking) :-
    findall(L-P, promedio_de_alumno(L, P), Pares),
    sort(2, @>=, Pares, Ordenados),
    primeros(Cantidad, Ordenados, Ranking).

%!  primeros(+N:integer, +L:list, -Primeros:list) is det.
%
%   Primeros son los N primeros elementos de L, o todos si tiene menos.
primeros(N, L, Primeros) :-
    (   N =< 0
    ->  Primeros = []
    ;   L = []
    ->  Primeros = []
    ;   L = [X|Resto],
        N1 is N - 1,
        Primeros = [X|Resto1],
        primeros(N1, Resto, Resto1)
    ).
