:- encoding(utf8).

% Capítulo 86 - Soluciones de los ejercicios que piden código.
%
% Cargan el intérprete completo sin modificarlo. columnas_usadas/2
% (ejercicio 4) resuelve cada columna de una consulta a su tabla;
% actualizar_tupla/2 (ejercicio 5) es el UPDATE de Toy-Sequel, tupla por
% tupla; traducir_ordenado/2 (ejercicio 6) pone primero los generadores con
% más argumentos ligados; insertar_verificado/2 (ejercicio 7) verifica las
% referencias del capítulo 42; recursiva/5 (ejercicio 8) calcula una
% consulta recursiva repitiendo un INSERT … SELECT hasta que no agrega
% nada.
%
% solo-local: carga los módulos del capítulo y modifica la base.
%
%?- columnas_usadas("SELECT a.nombre FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND nota > 6", Cs).

:- module(soluciones,
          [ columnas_usadas/2,
            actualizar_tupla/2,
            traducir_ordenado/2,
            generadores/3,
            insertar_verificado/2,
            recursiva/5
          ]).

:- reexport(minisql).
:- reexport(costos).
:- use_module(library(lists)).
:- use_module(library(apply)).

% Ejercicio 4

%!  columnas_usadas(+Texto, -Columnas:list) is det.
%
%   Columnas son las columnas que nombra el SELECT Texto, de un solo
%   nivel, cada una Tabla-Columna, sin repetidas y en orden alfabético.
columnas_usadas(Texto, Columnas) :-
    analizar(Texto, consulta(seleccion(_, Items, Desde, Donde, Grupo, Ten),
                             _, _)),
    marcos(Desde, _, Marcos),
    findall(R, ( sub_term(R, f(Items, Donde, Grupo, Ten)),
                 ( R = columna(_) ; R = columna(_, _) ) ),
            Refs),
    maplist(tabla_de_columna(Desde, Marcos), Refs, Cs),
    sort(Cs, Columnas).

%!  tabla_de_columna(+Desde:list, +Marcos:list, +Ref, -TC) is det.
%
%   TC es Tabla-Columna para la referencia Ref, buscada en Marcos.
tabla_de_columna(Desde, Marcos, Ref, Tabla-C) :-
    buscar_columna(Ref, [Marcos], col(C, _, _, V), _),
    member(marco(Alias, Cs), Marcos),
    member(col(_, _, _, W), Cs),
    W == V,
    !,
    memberchk(desde(Tabla, Alias), Desde).

% Ejercicio 5

%!  actualizar_tupla(+Texto, -N:integer) is det.
%
%   Ejecuta el UPDATE Texto como Toy-Sequel: para cada fila que cumple la
%   condición, retira la tupla y agrega la nueva, dentro del recorrido.
%   N es la cantidad de filas cambiadas. La condición ve la tabla a medio
%   cambiar.
actualizar_tupla(Texto, N) :-
    analizar(Texto, actualizar(T, Asignaciones, Condicion)),
    marcos([desde(T, T)], [Generador], Marcos),
    Marcos = [marco(_, Columnas)],
    Pila = [Marcos],
    condicion(Condicion, fila, Pila, verdadera, Filtro),
    maplist([col(_, _, _, V), V]>>true, Columnas, Viejos),
    nuevos(Columnas, Asignaciones, Pila, Nuevos, Calculos),
    Generador = M:Cabeza,
    Cabeza =.. [P|Viejos],
    Nueva =.. [P|Nuevos],
    aggregate_all(count,
                  ( Generador,
                    once(Filtro),
                    Calculos,
                    retract(M:Cabeza),
                    assertz(M:Nueva) ),
                  N).

%!  nuevos(+Columnas:list, +Asignaciones:list, +Pila:list, -Nuevos:list,
%!         -Calculos) is det.
%
%   Nuevos son los valores nuevos de las columnas: el de su asignación, o
%   el viejo; Calculos es la meta que calcula los asignados.
nuevos([], _, _, [], true).
nuevos([col(C, _, _, V)|Cs], Asignaciones, Pila, [N|Ns], (M, Ms)) :-
    (   memberchk(C-E, Asignaciones)
    ->  expresion(E, fila, Pila, N, _, _, M)
    ;   N = V,
        M = true
    ),
    nuevos(Cs, Asignaciones, Pila, Ns, Ms).

% Ejercicio 6

%!  traducir_ordenado(+Texto, -Traduccion) is det.
%
%   Traduccion es Fila-Meta, la traducción de la consulta Texto con sus
%   generadores ordenados de más a menos argumentos ligados al compilar.
traducir_ordenado(Texto, Fila-Meta) :-
    traducir(Texto, _, Fila-Meta0),
    generadores(Meta0, Gs, Resto),
    map_list_to_pairs(ligados, Gs, Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_values(Ordenados, Gs1),
    (   Resto == true
    ->  Metas = Gs1
    ;   append(Gs1, [Resto], Metas)
    ),
    encadenar(Metas, Meta).

% encadenar(Metas, Meta): Meta es (M1, (M2, …)).
encadenar([M], M) :-
    !.
encadenar([M|Ms], (M, Resto)) :-
    encadenar(Ms, Resto).

%!  generadores(+Meta, -Generadores:list, -Resto) is det.
%
%   Generadores son las llamadas a tablas con que empieza la conjunción
%   Meta, y Resto la meta que sigue.
generadores((G, Resto0), [G|Gs], Resto) :-
    generador(G),
    !,
    generadores(Resto0, Gs, Resto).
generadores(G, [G], true) :-
    generador(G),
    !.
generadores(Resto, [], Resto).

% generador(G): G llama a una tabla o una vista.
generador(M:_) :-
    memberchk(M, [base, relaciones]).

% ligados(G, K): K es la cantidad de argumentos de G ligados al compilar.
ligados(_:G, K) :-
    G =.. [_|Args],
    include(nonvar, Args, Ligados),
    length(Ligados, K).

% Ejercicio 7

%!  insertar_verificado(+Texto, -Resultado) is det.
%
%   Ejecuta el INSERT Texto y verifica después las restricciones del
%   esquema del capítulo 42 con violacion/1. Si alguna no se cumple,
%   repone el estado anterior y lanza error(sql(Violacion), _).
insertar_verificado(Texto, Resultado) :-
    estado(E),
    sql(Texto, Resultado),
    (   base:violacion(V)
    ->  restaurar(E),
        throw(error(sql(V), _))
    ;   true
    ).

% Ejercicio 8

%!  recursiva(+Tabla, +Crear, +Base, +Paso, -Rondas:integer) is det.
%
%   Calcula una consulta recursiva en la tabla Tabla, que crea la
%   sentencia Crear: la llena con el SELECT Base y después repite
%   INSERT INTO Tabla Paso EXCEPT SELECT * FROM Tabla, donde Paso nombra
%   a Tabla, hasta que no agrega ninguna fila. Rondas es la cantidad de
%   veces que se ejecutó Paso.
recursiva(Tabla, Crear, Base, Paso, Rondas) :-
    sql(Crear, _),
    format(atom(Inicio), "INSERT INTO ~w ~w", [Tabla, Base]),
    sql(Inicio, _),
    format(atom(Insertar), "INSERT INTO ~w ~w EXCEPT SELECT * FROM ~w",
           [Tabla, Paso, Tabla]),
    rondas(Insertar, 1, Rondas).

%!  rondas(+Insertar, +K0:integer, -K:integer) is det.
%
%   Ejecuta Insertar hasta que no agrega filas; K cuenta las ejecuciones.
rondas(Insertar, K0, K) :-
    sql(Insertar, insertadas(N)),
    (   N =:= 0
    ->  K = K0
    ;   K1 is K0 + 1,
        rondas(Insertar, K1, K)
    ).
