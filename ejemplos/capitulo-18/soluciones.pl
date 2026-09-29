:- encoding(utf8).

% Capítulo 18 - Soluciones de los ejercicios 1 a 12.
%
%?- dobles([1, 2, 3], D).
%?- todos_hijos_de(P, [luis, eva]).
%?- jugar([1-6, 6-1], Resultado).

% --- Ejercicios 1 a 6: la familia del texto ----------------------------------

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

:- meta_predicate
    conservar(1, +, -),
    conservar_(+, 1, -),
    descartar(1, +, -),
    descartar_(+, 1, -),
    mi_foldl(3, +, +, -),
    mi_foldl_(+, 3, +, -),
    informe(2, +, -),
    mostrar_informe(2, +, +).

%!  doble(+N:number, -D:number) is det.
%
%   D es el doble de N.
doble(N, D) :-
    D is 2 * N.

%!  dobles(+L:list(number), -D:list(number)) is det.
%
%   D es la lista de los dobles de los elementos de L.
dobles(L, D) :-
    maplist(doble, L, D).

%!  positivo(+N:number) is semidet.
%
%   N es mayor que cero.
positivo(N) :-
    N > 0.

%!  todos_positivos(+L:list(number)) is semidet.
%
%   Todos los elementos de L son positivos.
todos_positivos(L) :-
    maplist(positivo, L).

%!  largo(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L.
largo(L, N) :-
    foldl(contar, L, 0, N).

%!  contar(+X, +Hasta:integer, -Total:integer) is det.
%
%   Total es Hasta más uno; X no interviene.
contar(_, Hasta, Total) :-
    Total is Hasta + 1.

%!  maximo(+L:list(number), -Max:number) is semidet.
%
%   Max es el mayor elemento de L. Falla con la lista vacía.
maximo([Primero|Resto], Max) :-
    foldl([X, M0, M]>>(M is max(X, M0)), Resto, Primero, Max).

%!  dar_vuelta(+L:list, -R:list) is det.
%
%   R tiene los elementos de L en el orden inverso.
dar_vuelta(L, R) :-
    foldl([X, Hasta, [X|Hasta]]>>true, L, [], R).

%!  conservar(:Condicion, +L:list, -Cumplen:list) is det.
%
%   Cumplen son los elementos de L que cumplen Condicion, en su orden.
conservar(Condicion, L, Cumplen) :-
    conservar_(L, Condicion, Cumplen).

%!  conservar_(+L:list, :Condicion, -Cumplen:list) is det.
%
%   El recorrido de conservar/3, con la lista primero.
conservar_([], _, []).
conservar_([X|Xs], Condicion, Cumplen) :-
    (   call(Condicion, X)
    ->  Cumplen = [X|Resto]
    ;   Cumplen = Resto
    ),
    conservar_(Xs, Condicion, Resto).

%!  descartar(:Condicion, +L:list, -NoCumplen:list) is det.
%
%   NoCumplen son los elementos de L que no cumplen Condicion, en su orden.
descartar(Condicion, L, NoCumplen) :-
    descartar_(L, Condicion, NoCumplen).

%!  descartar_(+L:list, :Condicion, -NoCumplen:list) is det.
%
%   El recorrido de descartar/3, con la lista primero.
descartar_([], _, []).
descartar_([X|Xs], Condicion, NoCumplen) :-
    (   call(Condicion, X)
    ->  NoCumplen = Resto
    ;   NoCumplen = [X|Resto]
    ),
    descartar_(Xs, Condicion, Resto).

%!  todos_hijos_de(?P, +Hijos:list) is nondet.
%
%   P es el padre de todos los Hijos. {P} hace que la lambda comparta P con
%   la cláusula: todas las llamadas buscan el mismo padre.
todos_hijos_de(P, Hijos) :-
    maplist({P}/[H]>>padre(P, H), Hijos).

%!  mi_foldl(:Paso, +L:list, +V0, -V) is semidet.
%
%   V es el resultado de aplicar Paso a cada elemento de L, de izquierda a
%   derecha, a partir de V0: call(Paso, X, Antes, Despues). Falla si Paso
%   falla para algún elemento; con un Paso det, es det.
mi_foldl(Paso, L, V0, V) :-
    mi_foldl_(L, Paso, V0, V).

%!  mi_foldl_(+L:list, :Paso, +V0, -V) is semidet.
%
%   El recorrido de mi_foldl/4, con la lista primero.
mi_foldl_([], _, V, V).
mi_foldl_([X|Xs], Paso, V0, V) :-
    call(Paso, X, V0, V1),
    mi_foldl_(Xs, Paso, V1, V).

% --- Ejercicios 7 y 8: Inscripciones del capítulo -----------------------------

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

%!  legajos(-Legajos:list(integer)) is det.
%
%   Legajos son los legajos de todos los alumnos, en el orden de los hechos.
legajos(Legajos) :-
    findall(Legajo, alumno(Legajo, _, _, _), Legajos).

%!  materias(-Materias:list(atom)) is det.
%
%   Materias son los códigos de todas las materias, en el orden de los hechos.
materias(Materias) :-
    findall(M, materia(M, _, _), Materias).

%!  promedio(+Notas:list(number), -Promedio:number) is semidet.
%
%   Promedio es el promedio de Notas. Falla con la lista vacía.
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

%!  informe(:Calculo, +Claves:list, -Filas:list(pair)) is det.
%
%   Filas tiene un par Clave-Valor por cada elemento de Claves para el que
%   call(Calculo, Clave, Valor) se cumple, con su primer Valor.
informe(Calculo, Claves, Filas) :-
    convlist({Calculo}/[Clave, Clave-Valor]>>
                 once(call(Calculo, Clave, Valor)),
             Claves, Filas).

%!  materias_cursando(+Legajo:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de materias que el alumno Legajo está cursando.
materias_cursando(Legajo, Cantidad) :-
    aggregate_all(count, inscripcion(Legajo, _, cursando), Cantidad).

%!  nombre_de_alumno(+Legajo:integer, -Nombre:atom) is semidet.
%
%   Nombre es el nombre del alumno Legajo.
nombre_de_alumno(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _).

%!  nombre_de_materia(+Codigo:atom, -Nombre:atom) is semidet.
%
%   Nombre es el nombre de la materia Codigo.
nombre_de_materia(Codigo, Nombre) :-
    materia(Codigo, Nombre, _).

%!  mostrar_informe(:Nombre, +Titulo:atom, +Filas:list(pair)) is semidet.
%
%   Escribe Titulo y una línea por fila, con la clave, el nombre que le da
%   call(Nombre, Clave, N) y el valor. Falla en la primera fila cuya clave no
%   tiene nombre.
mostrar_informe(Nombre, Titulo, Filas) :-
    format("~w~n", [Titulo]),
    maplist({Nombre}/[Clave-Valor]>>( call(Nombre, Clave, N),
                                      format("  ~w ~w: ~w~n",
                                             [Clave, N, Valor]) ),
            Filas).

% --- Ejercicios 9 y 10: el tablero del Buscaminas del texto -------------------

% tamanio(Filas, Columnas): las dimensiones del tablero.
tamanio(6, 6).

% mina(Fila, Columna): hay una mina en esa celda.
mina(1, 1).
mina(3, 2).
mina(4, 5).
mina(6, 3).

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

%!  descubrir(+Celda:pair, +Vistas:list, -Descubiertas:list) is det.
%
%   El recorrido en profundidad del texto: Descubiertas son las celdas de
%   Vistas más las que descubre un clic en Celda, que no tiene mina.
descubrir(F-C, Vistas, Descubiertas) :-
    (   memberchk(F-C, Vistas)
    ->  Descubiertas = Vistas
    ;   minas_alrededor(F, C, 0)
    ->  findall(VF-VC, vecina(F, C, VF, VC), Vecinas),
        foldl(descubrir, Vecinas, [F-C|Vistas], Descubiertas)
    ;   Descubiertas = [F-C|Vistas]
    ).

%!  jugar(+Jugadas:list(pair), -Resultado) is det.
%
%   Resultado es el estado de la partida después de Jugadas, una lista de
%   celdas Fila-Columna: perdida(Celda) si una jugada cae en una mina, ganada
%   si quedan descubiertas todas las celdas sin mina, o
%   en_curso(Descubiertas).
jugar(Jugadas, Resultado) :-
    foldl(jugada, Jugadas, en_curso([]), Resultado).

%!  jugada(+Celda:pair, +Antes, -Despues) is det.
%
%   Despues es el estado de la partida después de un clic en Celda. Una
%   partida perdida o ganada no cambia.
jugada(F-C, Antes, Despues) :-
    (   Antes \= en_curso(_)
    ->  Despues = Antes
    ;   mina(F, C)
    ->  Despues = perdida(F-C)
    ;   Antes = en_curso(Vistas),
        descubrir(F-C, Vistas, Descubiertas),
        (   todas_descubiertas(Descubiertas)
        ->  Despues = ganada
        ;   Despues = en_curso(Descubiertas)
        )
    ).

%!  todas_descubiertas(+Descubiertas:list) is semidet.
%
%   Toda celda sin mina del tablero está en Descubiertas.
todas_descubiertas(Descubiertas) :-
    tamanio(Filas, Columnas),
    forall(( between(1, Filas, F),
             between(1, Columnas, C),
             \+ mina(F, C) ),
           memberchk(F-C, Descubiertas)).

%!  descubrir_a_lo_ancho(+Celda:pair, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas que descubre un clic en Celda, en el orden en
%   que se descubren: primero la celda, después sus vecinas, después las
%   vecinas de estas. Pendientes es la cola de celdas por examinar.
descubrir_a_lo_ancho(Celda, Descubiertas) :-
    a_lo_ancho([Celda], [], Invertidas),
    reverse(Invertidas, Descubiertas).

%!  a_lo_ancho(+Pendientes:list, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que se descubren desde las
%   Pendientes, la última descubierta primero.
a_lo_ancho([], Vistas, Vistas).
a_lo_ancho([F-C|Pendientes], Vistas, Descubiertas) :-
    (   memberchk(F-C, Vistas)
    ->  a_lo_ancho(Pendientes, Vistas, Descubiertas)
    ;   minas_alrededor(F, C, 0)
    ->  findall(VF-VC, vecina(F, C, VF, VC), Vecinas),
        append(Pendientes, Vecinas, Siguientes),
        a_lo_ancho(Siguientes, [F-C|Vistas], Descubiertas)
    ;   a_lo_ancho(Pendientes, [F-C|Vistas], Descubiertas)
    ).

% --- Ejercicios 11 y 12: recorridos con estado y con dos listas ---------------

%!  promedios_parciales(+Notas:list(number), -Promedios:list(number)) is det.
%
%   El elemento i-ésimo de Promedios es el promedio de las i primeras Notas.
%   Un solo recorrido: el valor acumulado es el par Cantidad-Suma.
promedios_parciales(Notas, Promedios) :-
    foldl(promedio_parcial, Notas, Promedios, 0-0, _).

%!  promedio_parcial(+Nota:number, -Promedio:number, +Hasta:pair,
%!                   -Total:pair) is det.
%
%   Total es el par Cantidad-Suma de Hasta con Nota agregada, y Promedio es
%   el promedio de las notas que Total reúne.
promedio_parcial(Nota, Promedio, Cantidad0-Suma0, Cantidad-Suma) :-
    Cantidad is Cantidad0 + 1,
    Suma is Suma0 + Nota,
    Promedio is Suma / Cantidad.

%!  producto_interno(+V1:list(number), +V2:list(number),
%!                   -P:number) is semidet.
%
%   P es el producto interno de los vectores V1 y V2. Falla si los dos
%   vectores tienen distinto largo.
producto_interno(V1, V2, P) :-
    foldl(sumar_producto, V1, V2, 0, P).

%!  sumar_producto(+X:number, +Y:number, +Hasta:number,
%!                 -Total:number) is det.
%
%   Total es Hasta más el producto de X por Y.
sumar_producto(X, Y, Hasta, Total) :-
    Total is Hasta + X * Y.
