:- encoding(utf8).

% Capítulo 86 - Versión 7: las sentencias que cambian las tablas.
%
% CREATE TABLE agrega una relación al catálogo y declara su predicado en el
% módulo relaciones; DROP TABLE la quita. INSERT, DELETE y UPDATE calculan
% primero, sobre el estado anterior, todas las filas que la tabla tendrá
% después; verifican los tipos, NOT NULL, los rangos y la clave primaria
% sobre ese resultado; y solo entonces reemplazan las filas de la tabla,
% en el orden en que estaban. Así una sentencia cambia todas las filas o
% ninguna, y una subconsulta de su condición ve la tabla como estaba antes
% de la sentencia, como exige SQL. Toy-Sequel, en cambio, retira y agrega
% cada tupla dentro de un bucle de falla.
%
% solo-local: carga los módulos del capítulo y modifica la base.
%
%?- modificar(insertar(alumnos, todas, valores([[ent(108), cad(hugo), cad(civil), ent(2025)]])), R).
%?- catch(modificar(insertar(alumnos, todas, valores([[ent(101), cad(zoe), cad(civil), ent(2025)]])), R), E, true).

:- module(modificaciones,
          [ modificar/2
          ]).

:- use_module(catalogo).
:- use_module(consultas).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  modificar(+Sentencia, -Resultado) is det.
%
%   Ejecuta una sentencia que cambia una tabla o el catálogo. Resultado
%   es creada(T), borrada(T), insertadas(N), eliminadas(N) o
%   actualizadas(N). Lanza error(sql(Motivo), _), sin cambiar nada, si la
%   sentencia no se puede ejecutar.
modificar(crear_tabla(T, Columnas, Clave), creada(T)) :-
    crear_tabla(T, Columnas, Clave).
modificar(borrar_tabla(T), borrada(T)) :-
    tabla(T, Generador, _),
    retractall(Generador),
    retractall(relacion(T, _, _, _)),
    retractall(restriccion(T, _)).
modificar(insertar(T, Destino, Fuente), insertadas(N)) :-
    insertar(T, Destino, Fuente, N).
modificar(eliminar(T, Condicion), eliminadas(N)) :-
    eliminar(T, Condicion, N).
modificar(actualizar(T, Asignaciones, Condicion), actualizadas(N)) :-
    actualizar(T, Asignaciones, Condicion, N).

%!  crear_tabla(+T, +Columnas:list, +Clave:list) is det.
%
%   Agrega al catálogo la tabla T, guardada en relaciones:T, con sus
%   columnas columna(Nombre, Tipo, Nulo) y su clave primaria.
crear_tabla(T, Columnas, Clave) :-
    (   relacion(T, _, _, _)
    ->  throw(error(sql(ya_existe(T)), _))
    ;   true
    ),
    maplist(nombre_definicion, Columnas, Nombres),
    (   append(_, [C|Resto], Nombres),
        memberchk(C, Resto)
    ->  throw(error(sql(columna_repetida(C)), _))
    ;   true
    ),
    (   member(K, Clave),
        \+ memberchk(K, Nombres)
    ->  throw(error(sql(columna_desconocida(K)), _))
    ;   true
    ),
    maplist(columna_catalogo, Columnas, Cols, Variables),
    Cabeza =.. [T|Variables],
    length(Variables, Aridad),
    dynamic(relaciones:T/Aridad),
    assertz(relacion(T, tabla, relaciones:Cabeza, Cols)),
    (   Clave == []
    ->  true
    ;   assertz(restriccion(T, clave(Clave)))
    ).

% nombre_definicion(Def, C): C es el nombre de la columna definida.
nombre_definicion(columna(C, _, _), C).

% columna_catalogo(Def, Col, V): la columna del catálogo de una definición.
columna_catalogo(columna(C, T, Nulo), col(C, T, Nulo, V), V).

%!  tabla(+T, -Generador, -Columnas:list) is det.
%
%   El generador y las columnas de la tabla T. Lanza un error si T no
%   está en el catálogo o es una vista.
tabla(T, Generador, Columnas) :-
    (   relacion(T, Clase, Generador, Columnas)
    ->  (   Clase == tabla
        ->  true
        ;   throw(error(sql(no_es_tabla(T)), _))
        )
    ;   throw(error(sql(tabla_desconocida(T)), _))
    ).

%!  variables(+Columnas:list, -Vs:list) is det.
%
%   Las variables de las columnas, en orden.
variables(Columnas, Vs) :-
    maplist(variable_columna, Columnas, Vs).

% variable_columna(Col, V): V es la variable de la columna Col.
variable_columna(col(_, _, _, V), V).

%!  insertar(+T, +Destino, +Fuente, -N:integer) is det.
%
%   Agrega a T las N filas de Fuente: valores(Filas) o una consulta.
%   Destino son las columnas que reciben los valores, o todas; las demás
%   reciben NULL.
insertar(T, Destino, Fuente, N) :-
    tabla(T, Generador, Columnas),
    posiciones(Destino, Columnas, Posiciones),
    length(Posiciones, K),
    filas_fuente(Fuente, K, Nuevas0),
    length(Columnas, Aridad),
    maplist(fila_completa(Aridad, Posiciones), Nuevas0, Nuevas),
    variables(Columnas, Vs),
    findall(Vs, Generador, Viejas),
    append(Viejas, Nuevas, Todas),
    verificar(T, Columnas, Nuevas, Todas),
    maplist(guardar(Generador), Nuevas),
    length(Nuevas, N).

%!  posiciones(+Destino, +Columnas:list, -Posiciones:list) is det.
%
%   Las posiciones en la tabla de las columnas de Destino.
posiciones(todas, Columnas, Posiciones) :-
    !,
    length(Columnas, N),
    numlist(1, N, Posiciones).
posiciones(Nombres, Columnas, Posiciones) :-
    maplist(posicion(Columnas), Nombres, Posiciones).

% posicion(Columnas, C, I): la columna C es la número I.
posicion(Columnas, C, I) :-
    (   nth1(I, Columnas, col(C, _, _, _))
    ->  true
    ;   throw(error(sql(columna_desconocida(C)), _))
    ).

%!  filas_fuente(+Fuente, +K:integer, -Filas:list) is det.
%
%   Las filas de valores de un INSERT, cada una de K valores.
filas_fuente(valores(Expresiones), K, Filas) :-
    !,
    maplist(fila_valores, Expresiones, Filas),
    maplist(cantidad(K), Filas).
filas_fuente(Q, K, Filas) :-
    compilar_consulta(Q, [], Meta, Vs, _),
    findall(Vs, Meta, Filas),
    length(Vs, L),
    cantidad(K, Vs),
    L =:= K.

% cantidad(K, Fila): Fila tiene K valores.
cantidad(K, Fila) :-
    (   length(Fila, K)
    ->  true
    ;   throw(error(sql(cantidad_de_valores), _))
    ).

% fila_valores(Es, Vs): Vs son los valores de las expresiones Es.
fila_valores(Es, Vs) :-
    maplist(valor_constante, Es, Vs).

% valor_constante(E, V): V es el valor de E, que no nombra columnas.
valor_constante(E, V) :-
    expresion(E, fila, [], V, _, _, Meta),
    once(Meta).

%!  fila_completa(+Aridad:integer, +Posiciones:list, +Valores:list,
%!                -Fila:list) is det.
%
%   Fila tiene Aridad valores: los Valores en sus Posiciones, y NULL en
%   las demás.
fila_completa(Aridad, Posiciones, Valores, Fila) :-
    numlist(1, Aridad, Is),
    maplist(valor_en(Posiciones, Valores), Is, Fila).

% valor_en(Posiciones, Valores, I, V): V es el valor de la posición I, o
% NULL si ningún valor va en ella.
valor_en(Posiciones, Valores, I, V) :-
    (   nth1(K, Posiciones, I)
    ->  nth1(K, Valores, V)
    ;   V = null
    ).

%!  eliminar(+T, +Condicion, -N:integer) is det.
%
%   Quita de T las N filas para las que Condicion es verdadera.
eliminar(T, Condicion, N) :-
    filtro_tabla(T, Condicion, Generador, [[marco(_, Columnas)]], Filtro),
    variables(Columnas, Vs),
    findall(Vs-Sale,
            ( Generador,
              (   Filtro
              ->  Sale = si
              ;   Sale = no
              ) ),
            Pares),
    pares_con(Pares, no, Quedan),
    pares_con(Pares, si, Salen),
    length(Salen, N),
    reemplazar(Generador, Quedan).

%!  pares_con(+Pares:list, +Marca, -Filas:list) is det.
%
%   Filas son las filas de los pares Fila-Marca con esa Marca, en orden.
pares_con([], _, []).
pares_con([Fila-M|Ps], Marca, Filas) :-
    (   M == Marca
    ->  Filas = [Fila|Resto]
    ;   Filas = Resto
    ),
    pares_con(Ps, Marca, Resto).

%!  filtro_tabla(+T, +Condicion, -Generador, -Pila:list, -Filtro) is det.
%
%   El generador de T, la tabla de símbolos con su único marco, y la meta
%   que se cumple una vez para las filas en que Condicion es verdadera.
filtro_tabla(T, Condicion, Generador, Pila, once(Filtro)) :-
    tabla(T, _, _),
    marcos([desde(T, T)], [Generador], Marcos),
    Pila = [Marcos],
    condicion(Condicion, fila, Pila, verdadera, Filtro).

%!  actualizar(+T, +Asignaciones:list, +Condicion, -N:integer) is det.
%
%   Cambia en las N filas de T para las que Condicion es verdadera las
%   columnas de Asignaciones, cada una C-Expresion, calculadas con los
%   valores anteriores de la fila.
actualizar(T, Asignaciones, Condicion, N) :-
    filtro_tabla(T, Condicion, Generador, Pila, Filtro),
    Pila = [[marco(_, Columnas)]],
    variables(Columnas, Vs),
    asignar(Asignaciones, Pila, Vs, Nuevos, Calculos),
    conjuncion_lista(Calculos, Calculo),
    findall(Fila-Cambia,
            ( Generador,
              (   Filtro
              ->  Calculo,
                  Fila = Nuevos,
                  Cambia = si
              ;   Fila = Vs,
                  Cambia = no
              ) ),
            Pares),
    pairs_keys(Pares, Todas),
    pares_con(Pares, si, Cambiadas),
    length(Cambiadas, N),
    verificar(T, Columnas, Cambiadas, Todas),
    reemplazar(Generador, Todas).

%!  asignar(+Asignaciones:list, +Pila:list, +Nuevos0:list, -Nuevos:list,
%!          -Calculos:list) is det.
%
%   Nuevos es Nuevos0 con el valor de E en la columna C, para cada C-E de
%   Asignaciones; Calculos son las metas que calculan esos valores.
asignar([], _, Nuevos, Nuevos, []).
asignar([C-E|As], Pila, Nuevos0, Nuevos, [Meta|Ms]) :-
    Pila = [[marco(_, Columnas)]],
    (   nth1(I, Columnas, col(C, Tipo, _, _))
    ->  true
    ;   throw(error(sql(columna_desconocida(C)), _))
    ),
    expresion(E, fila, Pila, V, TE, _, Meta),
    compatibles(Tipo, TE, _),
    reemplazar_i(I, Nuevos0, V, Nuevos1),
    asignar(As, Pila, Nuevos1, Nuevos, Ms).

% reemplazar_i(I, L0, X, L): L es L0 con X en la posición I.
reemplazar_i(I, L0, X, L) :-
    I0 is I - 1,
    length(Antes, I0),
    append(Antes, [_|Despues], L0),
    append(Antes, [X|Despues], L).

% compatibles(T, TE, C): los tipos de la columna y del valor asignado.
compatibles(T1, T2, C) :-
    consultas:compatibles(T1, T2, C).

% conjuncion_lista(Metas, Meta): la conjunción de Metas.
conjuncion_lista([], true).
conjuncion_lista([M|Ms], (M, Resto)) :-
    conjuncion_lista(Ms, Resto).

%!  verificar(+T, +Columnas:list, +Nuevas:list, +Todas:list) is det.
%
%   Las filas Nuevas respetan los tipos, NOT NULL y los rangos de T, y
%   Todas, las filas que T tendrá, no repiten la clave primaria. Si no,
%   lanza error(sql(Motivo), _).
verificar(T, Columnas, Nuevas, Todas) :-
    forall(member(Fila, Nuevas),
           forall(nth1(I, Columnas, Col),
                  ( nth1(I, Fila, V),
                    verificar_valor(T, Col, V) ))),
    (   restriccion(T, clave(Clave))
    ->  findall(I, ( member(C, Clave),
                     nth1(I, Columnas, col(C, _, _, _)) ),
                Is),
        findall(K, ( member(Fila, Todas),
                     findall(X, ( member(I, Is), nth1(I, Fila, X) ), K) ),
                Ks),
        msort(Ks, Ordenadas),
        (   append(_, [K1, K2|_], Ordenadas),
            K1 == K2
        ->  throw(error(sql(clave_repetida(T, K1)), _))
        ;   true
        )
    ;   true
    ).

%!  verificar_valor(+T, +Col, +V) is det.
%
%   V es un valor admitido por la columna Col de T.
verificar_valor(T, col(C, Tipo, Nulo, _), V) :-
    (   V == null
    ->  (   Nulo == nulo
        ->  true
        ;   throw(error(sql(nulo(T, C)), _))
        )
    ;   del_tipo(Tipo, V)
    ->  (   restriccion(T, rango(C, Min, Max)),
            \+ between(Min, Max, V)
        ->  throw(error(sql(rango(T, C, V)), _))
        ;   true
        )
    ;   throw(error(sql(tipo(T, C, V)), _))
    ).

% del_tipo(Tipo, V): V es un valor de Tipo.
del_tipo(entero, V) :-
    integer(V).
del_tipo(texto, V) :-
    atom(V).

%!  guardar(+Generador, +Fila:list) is det.
%
%   Agrega Fila al final de la tabla de Generador.
guardar(M:Cabeza, Fila) :-
    functor(Cabeza, P, _),
    Hecho =.. [P|Fila],
    assertz(M:Hecho).

%!  reemplazar(+Generador, +Filas:list) is det.
%
%   La tabla de Generador queda con Filas, en ese orden.
reemplazar(M:Cabeza, Filas) :-
    functor(Cabeza, P, A),
    functor(Vacia, P, A),
    retractall(M:Vacia),
    maplist(guardar(M:Cabeza), Filas).
