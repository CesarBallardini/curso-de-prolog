:- encoding(utf8).

% Capítulo 86 - Versión 3: el catálogo y la tabla de símbolos.
%
% El catálogo guarda, para cada relación, su nombre, si es una tabla o una
% vista, un generador de sus filas y un marco: la lista de sus columnas,
% cada una col(Nombre, Tipo, Nulo, Variable), con la variable que la columna
% ocupa en el generador. Es el procedimiento 'r e l'/3 de Toy-Sequel, con
% la admisión de NULL agregada. Una cláusula del catálogo tiene variables;
% cada vez que se la consulta, Prolog da una copia nueva, y las columnas
% siguen ligadas a los argumentos de su copia del generador.
%
% Al cargarse, el catálogo describe las cuatro tablas de Inscripciones del
% capítulo 42 a partir de su esquema como hechos (tabla/3, clave/2,
% admite_nulo/2, rango/4), sin copiarlas: el generador de alumnos es
% base:alumno/4. Las tablas y vistas que se crean después viven en el
% módulo relaciones, donde no chocan con ningún otro predicado.
%
% solo-local: carga el módulo base del capítulo 42.
%
%?- relacion(materias, Clase, Generador, Columnas).
%?- marcos([desde(alumnos, a), desde(inscripciones, i)], Gs, Ms), buscar_columna(columna(legajo), [Ms], C, N).

:- module(catalogo,
          [ relacion/4,
            restriccion/2,
            iniciar_catalogo/0,
            marcos/3,
            buscar_columna/4,
            relaciones/1,
            estado/1,
            restaurar/1
          ]).

:- use_module('../capitulo-42/base', []).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- dynamic relacion/4, restriccion/2.

% relacion(Nombre, Clase, Generador, Columnas): la relación Nombre, tabla o
% vista, cuyas filas da la meta Generador; Columnas son sus col(Nombre,
% Tipo, Nulo, Variable), en el orden de las columnas.

% restriccion(Tabla, R): Tabla debe cumplir R, clave(Columnas) o
% rango(Columna, Minimo, Maximo).

%!  iniciar_catalogo is det.
%
%   Deja el catálogo con las cuatro tablas del capítulo 42 y borra las
%   tablas y vistas creadas en el módulo relaciones.
iniciar_catalogo :-
    forall(relacion(_, _, relaciones:Cabeza, _),
           retractall(relaciones:Cabeza)),
    retractall(relacion(_, _, _, _)),
    retractall(restriccion(_, _)),
    forall(base:tabla(T, Predicado, Columnas),
           describir_tabla(T, Predicado, Columnas)).

%!  describir_tabla(+T, +Predicado, +Columnas:list) is det.
%
%   Agrega al catálogo la tabla T del capítulo 42, guardada en
%   base:Predicado, con sus columnas Nombre-Tipo, su clave y sus rangos.
describir_tabla(T, Predicado, Columnas) :-
    maplist(columna_de(T), Columnas, Cols, Variables),
    Cabeza =.. [Predicado|Variables],
    assertz(relacion(T, tabla, base:Cabeza, Cols)),
    forall(base:clave(T, Cs), assertz(restriccion(T, clave(Cs)))),
    forall(base:rango(T, C, Min, Max),
           assertz(restriccion(T, rango(C, Min, Max)))).

%!  columna_de(+T, +NombreTipo, -Col, -Variable) is det.
%
%   Col es la descripción de la columna Nombre-Tipo de T, con Variable.
columna_de(T, Nombre-Tipo, col(Nombre, Tipo, Nulo, V), V) :-
    (   base:admite_nulo(T, Nombre)
    ->  Nulo = nulo
    ;   Nulo = no_nulo
    ).

:- initialization(iniciar_catalogo).

%!  marcos(+Desde:list, -Generadores:list, -Marcos:list) is det.
%
%   Para las tablas de un FROM, cada una desde(Relacion, Alias), da sus
%   generadores y sus marcos marco(Alias, Columnas). Lanza
%   error(sql(tabla_desconocida(R)), _) si una relación no está en el
%   catálogo, y error(sql(alias_repetido(A)), _) si dos usan el mismo alias.
marcos(Desde, Generadores, Marcos) :-
    maplist(marco, Desde, Generadores, Marcos),
    maplist(alias_de, Marcos, Alias),
    (   append(_, [A|Resto], Alias),
        memberchk(A, Resto)
    ->  throw(error(sql(alias_repetido(A)), _))
    ;   true
    ).

% alias_de(Marco, A): A es el alias de Marco.
alias_de(marco(A, _), A).

%!  marco(+Desde, -Generador, -Marco) is det.
%
%   El generador y el marco de una relación del FROM, con variables nuevas.
marco(desde(R, Alias), Generador, marco(Alias, Columnas)) :-
    (   relacion(R, _, Generador, Columnas)
    ->  true
    ;   throw(error(sql(tabla_desconocida(R)), _))
    ).

%!  buscar_columna(+Ref, +Pila:list, -Col, -Nivel:integer) is det.
%
%   Col es la columna col(Nombre, Tipo, Nulo, Variable) a la que se refiere
%   Ref, columna(C) o columna(Alias, C), en la tabla de símbolos Pila: una
%   lista de niveles, el de la consulta actual primero y después los de
%   las consultas que la contienen; cada nivel es la lista de los marcos
%   de su FROM. Nivel es 0 si la columna es de la consulta actual. Un
%   nombre sin calificar debe estar en un solo marco de su nivel.
buscar_columna(Ref, Pila, Col, Nivel) :-
    buscar(Pila, 0, Ref, Col, Nivel).

%!  buscar(+Pila:list, +N:integer, +Ref, -Col, -Nivel:integer) is det.
%
%   Busca Ref desde el nivel N de Pila hacia afuera.
buscar([], _, Ref, _, _) :-
    nombre_ref(Ref, Nombre),
    throw(error(sql(columna_desconocida(Nombre)), _)).
buscar([Marcos|Pila], N, Ref, Col, Nivel) :-
    candidatas(Ref, Marcos, Cols),
    (   Cols = [Col]
    ->  Nivel = N
    ;   Cols = [_, _|_]
    ->  nombre_ref(Ref, Nombre),
        throw(error(sql(columna_ambigua(Nombre)), _))
    ;   N1 is N + 1,
        buscar(Pila, N1, Ref, Col, Nivel)
    ).

%!  candidatas(+Ref, +Marcos:list, -Cols:list) is det.
%
%   Cols son las columnas de Marcos que Ref puede nombrar. Una columna
%   calificada con un alias de este nivel que no está en su marco es un
%   error.
candidatas(columna(A, C), Marcos, Cols) :-
    (   memberchk(marco(A, Cs), Marcos)
    ->  (   memberchk(col(C, T, Nulo, V), Cs)
        ->  Cols = [col(C, T, Nulo, V)]
        ;   nombre_ref(columna(A, C), Nombre),
            throw(error(sql(columna_desconocida(Nombre)), _))
        )
    ;   Cols = []
    ).
candidatas(columna(C), Marcos, Cols) :-
    con_columna(Marcos, C, Cols).

%!  con_columna(+Marcos:list, +C, -Cols:list) is det.
%
%   Cols tiene la columna C de cada marco de Marcos que la tiene. Las
%   variables quedan compartidas con los marcos: no se copian.
con_columna([], _, []).
con_columna([marco(_, Cs)|Ms], C, Cols) :-
    (   memberchk(col(C, T, Nulo, V), Cs)
    ->  Cols = [col(C, T, Nulo, V)|Resto]
    ;   Cols = Resto
    ),
    con_columna(Ms, C, Resto).

%!  nombre_ref(+Ref, -Nombre) is det.
%
%   El nombre de la columna Ref, como se escribe en SQL.
nombre_ref(columna(C), C).
nombre_ref(columna(A, C), Nombre) :-
    atomic_list_concat([A, '.', C], Nombre).

%!  relaciones(-Nombres:list) is det.
%
%   Nombres son las relaciones del catálogo, en orden alfabético.
relaciones(Nombres) :-
    findall(R, relacion(R, _, _, _), Rs),
    sort(Rs, Nombres).

%!  estado(-Estado) is det.
%
%   Estado es una copia del catálogo, de las filas de cada tabla y de las
%   cláusulas de cada vista; restaurar/1 lo repone. Lo usan las pruebas.
estado(estado(Catalogo, Restricciones, Datos)) :-
    findall(relacion(R, C, G, Cs), relacion(R, C, G, Cs), Catalogo),
    findall(restriccion(T, X), restriccion(T, X), Restricciones),
    findall(G-Clausulas,
            ( relacion(_, _, G, _),
              findall((G :- B), clause(G, B), Clausulas) ),
            Datos).

%!  restaurar(+Estado) is det.
%
%   Repone el catálogo, las tablas y las vistas guardados por estado/1.
restaurar(estado(Catalogo, Restricciones, Datos)) :-
    forall(relacion(_, _, G, _), retractall(G)),
    retractall(relacion(_, _, _, _)),
    retractall(restriccion(_, _)),
    maplist(assertz, Catalogo),
    maplist(assertz, Restricciones),
    forall(member(G-Clausulas, Datos),
           ( retractall(G),
             maplist(reponer, Clausulas) )).

%!  reponer(+Clausula) is det.
%
%   Agrega Clausula, M:Cabeza :- Cuerpo, a su módulo: un hecho si el
%   cuerpo es true.
reponer((M:Cabeza :- true)) :-
    !,
    assertz(M:Cabeza).
reponer((M:Cabeza :- Cuerpo)) :-
    assertz(M:(Cabeza :- Cuerpo)).
