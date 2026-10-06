:- encoding(utf8).

% Capítulo 86 - Versión 2: la gramática de las sentencias.
%
% La segunda etapa del análisis: una gramática sobre la lista de tokens de
% lexico.pl que relaciona cada sentencia con un término, su sintaxis
% abstracta. Toy-Sequel traduce cada comando directamente a una meta de
% Prolog; aquí la gramática da un término y la traducción es otra etapa,
% para que el mismo término sirva a los dos compiladores del capítulo
% (ingenuo.pl y consultas.pl) y a las vistas.
%
% Cuando una sentencia no se puede analizar, el error nombra los tokens
% desde el punto más lejano al que llegó el análisis, como el informe de
% errores de Toy-Sequel, que muestra el token problemático y los que le
% siguen.
%
% solo-local: es un módulo que cargan los otros archivos del capítulo.
%
%?- analizar("SELECT nombre FROM alumnos WHERE carrera = 'civil'", S).
%?- catch(analizar("SELECT nombre alumnos", S), E, true).

:- module(sintaxis,
          [ analizar/2,
            analizar_tokens/2
          ]).

:- use_module(lexico).
:- use_module(library(lists)).

%!  analizar(+Texto, -Sentencia) is det.
%
%   Sentencia es la sintaxis abstracta de la sentencia SQL Texto. Lanza
%   error(sql(sintaxis(Cerca)), _) si Texto no es una sentencia, con Cerca
%   los tokens desde el punto más lejano al que llegó el análisis.
analizar(Texto, Sentencia) :-
    tokens(Texto, Tokens),
    analizar_tokens(Tokens, Sentencia).

%!  analizar_tokens(+Tokens:list, -Sentencia) is det.
%
%   Lo mismo, sobre una lista de tokens. Se queda con el primer análisis.
analizar_tokens(Tokens, Sentencia) :-
    nb_setval(sintaxis_lejos, Tokens),
    (   phrase(sentencia_completa(S), Tokens)
    ->  Sentencia = S
    ;   nb_getval(sintaxis_lejos, Resto),
        cerca(Resto, Cerca),
        throw(error(sql(sintaxis(Cerca)), _))
    ).

%!  cerca(+Resto:list, -Cerca) is det.
%
%   Cerca son hasta tres tokens de Resto, o fin si no queda ninguno.
cerca([], fin) :-
    !.
cerca(Resto, Cerca) :-
    length(Resto, N),
    K is min(N, 3),
    length(Cerca, K),
    append(Cerca, _, Resto).

% Los terminales

%!  t(?Token)// is semidet.
%
%   El próximo token es Token. Antes de mirarlo anota la posición, si es
%   la más lejana alcanzada hasta ahora.
t(Token, S0, S) :-
    anotar(S0),
    S0 = [Token|S].

%!  anotar(+Resto:list) is det.
%
%   Guarda Resto si es más corto que el resto más corto guardado.
anotar(S0) :-
    nb_getval(sintaxis_lejos, Lejos),
    length(Lejos, L),
    length(S0, N),
    (   N < L
    ->  nb_setval(sintaxis_lejos, S0)
    ;   true
    ).

%!  k(+Palabra)// is semidet.
%
%   El próximo token es la palabra clave Palabra.
k(Palabra) -->
    t(n(Palabra)).

%!  nombre(-Nombre)// is semidet.
%
%   Un nombre de tabla, de columna o de alias: una palabra que no es
%   reservada.
nombre(Nombre) -->
    t(n(Nombre)),
    { \+ reservada(Nombre) }.

% reservada(P): P es una palabra clave y no puede ser un nombre.
reservada(P) :-
    memberchk(P, [ all, and, as, asc, avg, between, by, count, create,
                   delete, desc, describe, distinct, drop, except, exists,
                   from, group, having, in, inner, insert, int, integer,
                   intersect, into, is, join, key, limit, max, min, not,
                   null, on, or, order, primary, select, set, show, sum,
                   table, tables, text, union, update, values, view,
                   where ]).

%!  opcional(+Token)// is det.
%
%   Token, si es el próximo; si no, nada.
opcional(Token) -->
    (   t(Token)
    ->  []
    ;   []
    ).

% Las sentencias

%!  sentencia_completa(-S)// is semidet.
%
%   Una sentencia, con un punto y coma final optativo.
sentencia_completa(S) -->
    sentencia(S),
    opcional(;).

%!  sentencia(-S)// is nondet.
%
%   Una sentencia: una consulta, o una de las que cambian las tablas, el
%   catálogo o lo muestran.
sentencia(Q) -->
    consulta(Q).
sentencia(crear_tabla(T, Columnas, Clave)) -->
    k(create), k(table), nombre(T),
    t('('), elementos(Es), t(')'),
    { columnas_y_clave(Es, Columnas, Clave) }.
sentencia(borrar_tabla(T)) -->
    k(drop), k(table), nombre(T).
sentencia(crear_vista(V, Q)) -->
    k(create), k(view), nombre(V), k(as), consulta(Q).
sentencia(borrar_vista(V)) -->
    k(drop), k(view), nombre(V).
sentencia(insertar(T, Columnas, Fuente)) -->
    k(insert), k(into), nombre(T),
    columnas_destino(Columnas),
    fuente(Fuente).
sentencia(eliminar(T, C)) -->
    k(delete), k(from), nombre(T), donde(C).
sentencia(actualizar(T, Asignaciones, C)) -->
    k(update), nombre(T), k(set), asignaciones(Asignaciones), donde(C).
sentencia(tablas) -->
    k(show), k(tables).
sentencia(describir(T)) -->
    k(describe), nombre(T).

%!  elementos(-Es:list)// is nondet.
%
%   Las definiciones de columnas y la clave de un CREATE TABLE.
elementos([E|Es]) -->
    elemento(E),
    (   t(',')
    ->  elementos(Es)
    ;   { Es = [] }
    ).

%!  elemento(-E)// is nondet.
%
%   columna(Nombre, Tipo, Restricciones), o clave(Columnas) para
%   PRIMARY KEY (c1, …).
elemento(clave(Cs)) -->
    k(primary), k(key), t('('), nombres(Cs), t(')').
elemento(columna(C, Tipo, Rs)) -->
    nombre(C), tipo(Tipo), restricciones(Rs).

%!  tipo(-Tipo)// is semidet.
%
%   entero para INTEGER o INT, texto para TEXT.
tipo(entero) --> k(integer).
tipo(entero) --> k(int).
tipo(texto) --> k(text).

%!  restricciones(-Rs:list)// is nondet.
%
%   no_nulo por NOT NULL y clave por PRIMARY KEY, en cualquier orden.
restricciones([no_nulo|Rs]) -->
    k(not), k(null), restricciones(Rs).
restricciones([clave|Rs]) -->
    k(primary), k(key), restricciones(Rs).
restricciones([]) -->
    [].

%!  columnas_y_clave(+Es:list, -Columnas:list, -Clave:list) is det.
%
%   Columnas son los columna(Nombre, Tipo, Nulo) de Es, con Nulo no_nulo o
%   nulo, y Clave las columnas de la clave primaria, de la columna marcada o
%   de PRIMARY KEY (…). Las columnas de la clave no admiten NULL.
columnas_y_clave(Es, Columnas, Clave) :-
    findall(C, member(columna(C, _, [clave|_]), Es), Cs1),
    findall(C, ( member(columna(C, _, Rs), Es), memberchk(clave, Rs) ), Cs2),
    findall(Cs, member(clave(Cs), Es), Css),
    append([Cs1, Cs2|Css], Cs0),
    list_to_set(Cs0, Clave),
    findall(columna(C, T, Nulo),
            ( member(columna(C, T, Rs), Es),
              (   ( memberchk(no_nulo, Rs) ; memberchk(C, Clave) )
              ->  Nulo = no_nulo
              ;   Nulo = nulo
              ) ),
            Columnas).

%!  columnas_destino(-Columnas)// is det.
%
%   La lista de columnas de un INSERT, o todas si no se nombran.
columnas_destino(Cs) -->
    t('('), nombres(Cs), t(')'),
    !.
columnas_destino(todas) -->
    [].

%!  fuente(-Fuente)// is nondet.
%
%   valores(Filas), con cada fila una lista de expresiones, o una consulta.
fuente(valores([F|Fs])) -->
    k(values), fila(F), filas(Fs).
fuente(Q) -->
    consulta(Q).

%!  filas(-Filas:list)// is nondet.
%
%   Más filas de VALUES, cada una precedida por una coma.
filas([F|Fs]) -->
    t(','), fila(F), filas(Fs).
filas([]) -->
    [].

%!  fila(-Expresiones:list)// is nondet.
%
%   Una fila de VALUES: expresiones entre paréntesis.
fila(Es) -->
    t('('), expresiones(Es), t(')').

%!  asignaciones(-As:list)// is nondet.
%
%   Las asignaciones Columna = Expresión de un UPDATE, como C-E.
asignaciones([C-E|As]) -->
    nombre(C), t(=), expresion(E),
    (   t(',')
    ->  asignaciones(As)
    ;   { As = [] }
    ).

%!  donde(-Condicion)// is nondet.
%
%   La condición de WHERE, o cierto si no la hay.
donde(C) -->
    k(where), condicion(C).
donde(cierto) -->
    [].

% Las consultas

%!  consulta(-Q)// is nondet.
%
%   consulta(Cuerpo, Orden, Limite): una o más selecciones unidas por
%   operaciones de conjuntos, con ORDER BY y LIMIT optativos.
consulta(consulta(Cuerpo, Orden, Limite)) -->
    nucleo(N),
    resto_compuesta(N, Cuerpo),
    orden(Orden),
    limite(Limite).

%!  resto_compuesta(+A, -Cuerpo)// is nondet.
%
%   Las operaciones de conjuntos que siguen a A, asociadas a izquierda.
resto_compuesta(A, Cuerpo) -->
    operacion(Op),
    nucleo(B),
    { T =.. [Op, A, B] },
    resto_compuesta(T, Cuerpo).
resto_compuesta(A, A) -->
    [].

%!  operacion(-Op)// is semidet.
%
%   Una operación de conjuntos entre dos selecciones.
operacion(union_todo) --> k(union), k(all), !.
operacion(union) --> k(union).
operacion(interseccion) --> k(intersect).
operacion(diferencia) --> k(except).

%!  nucleo(-S)// is nondet.
%
%   seleccion(Distinto, Items, Desde, Donde, Grupo, Teniendo). Las
%   condiciones ON de los JOIN se agregan a la de WHERE.
nucleo(seleccion(D, Items, Desde, Donde, Grupo, Teniendo)) -->
    k(select), distinto(D), items(Items),
    k(from), desde(Desde, Ons),
    donde(C),
    { append(Ons, [C], Cs),
      conjuncion(Cs, Donde) },
    grupo(Grupo),
    teniendo(Teniendo).

%!  conjuncion(+Cs:list, -C) is det.
%
%   C es la conjunción y/2 de las condiciones Cs, sin las que son cierto.
conjuncion(Cs0, C) :-
    exclude(==(cierto), Cs0, Cs),
    conjuntar(Cs, C).

%!  conjuntar(+Cs:list, -C) is det.
%
%   C es y(…y(C1, C2)…, Cn), o cierto si Cs es [].
conjuntar([], cierto).
conjuntar([C|Cs], Y) :-
    conjuntar(Cs, C, Y).

%!  conjuntar(+Cs:list, +A, -Y) is det.
%
%   Y agrega las condiciones Cs a la izquierda de A.
conjuntar([], A, A).
conjuntar([C|Cs], A, Y) :-
    conjuntar(Cs, y(A, C), Y).

%!  distinto(-D)// is det.
%
%   si para DISTINCT, no si no está.
distinto(si) --> k(distinct), !.
distinto(no) --> [].

%!  items(-Items)// is nondet.
%
%   todo para *, o la lista de los ítems de la selección.
items(todo) -->
    t(*).
items([I|Is]) -->
    item(I),
    mas_items(Is).

%!  mas_items(-Items:list)// is nondet.
%
%   Más ítems de la selección, cada uno precedido por una coma.
mas_items([I|Is]) -->
    t(','), item(I), mas_items(Is).
mas_items([]) -->
    [].

%!  item(-I)// is nondet.
%
%   todas(Alias) para Alias.*, o item(Expresion, Nombre), con Nombre el
%   alias de AS o sin_alias.
item(todas(A)) -->
    nombre(A), t('.'), t(*).
item(item(E, Alias)) -->
    expresion(E),
    alias_columna(Alias).

%!  alias_columna(-Alias)// is det.
%
%   El nombre que AS da a una columna del resultado, o sin_alias.
alias_columna(A) -->
    k(as), !, nombre(A).
alias_columna(A) -->
    nombre(A), !.
alias_columna(sin_alias) -->
    [].

%!  desde(-Desde:list, -Ons:list)// is nondet.
%
%   Las tablas de FROM, cada una desde(Tabla, Alias), separadas por comas
%   o por JOIN … ON; Ons son las condiciones de los ON.
desde([R|Rs], Ons) -->
    referencia(R),
    mas_desde(Rs, Ons).

%!  mas_desde(-Rs:list, -Ons:list)// is nondet.
%
%   Las tablas que siguen a la primera.
mas_desde([R|Rs], Ons) -->
    t(','), referencia(R),
    mas_desde(Rs, Ons).
mas_desde([R|Rs], [C|Ons]) -->
    opcional(n(inner)), k(join), referencia(R), k(on), condicion(C),
    mas_desde(Rs, Ons).
mas_desde([], []) -->
    [].

%!  referencia(-R)// is nondet.
%
%   desde(Tabla, Alias): una tabla con su alias, o con su propio nombre
%   como alias.
referencia(desde(T, A)) -->
    nombre(T),
    (   k(as)
    ->  nombre(A)
    ;   nombre(A)
    ;   { A = T }
    ).

%!  grupo(-Columnas:list)// is nondet.
%
%   Las columnas de GROUP BY, o [].
grupo([C|Cs]) -->
    k(group), k(by), columna(C), mas_columnas(Cs).
grupo([]) -->
    [].

%!  mas_columnas(-Cs:list)// is nondet.
%
%   Más columnas de GROUP BY, precedidas por comas.
mas_columnas([C|Cs]) -->
    t(','), columna(C), mas_columnas(Cs).
mas_columnas([]) -->
    [].

%!  teniendo(-Condicion)// is nondet.
%
%   La condición de HAVING, o cierto.
teniendo(C) -->
    k(having), condicion(C).
teniendo(cierto) -->
    [].

%!  orden(-Orden:list)// is nondet.
%
%   Las claves de ORDER BY, cada una orden(Expresion, asc o desc), o [].
orden([O|Os]) -->
    k(order), k(by), clave_orden(O), mas_orden(Os).
orden([]) -->
    [].

%!  mas_orden(-Os:list)// is nondet.
%
%   Más claves de ORDER BY.
mas_orden([O|Os]) -->
    t(','), clave_orden(O), mas_orden(Os).
mas_orden([]) -->
    [].

%!  clave_orden(-O)// is nondet.
%
%   Una clave de ORDER BY con su dirección; asc si no se indica.
clave_orden(orden(E, D)) -->
    expresion(E),
    (   k(desc)
    ->  { D = desc }
    ;   opcional(n(asc)),
        { D = asc }
    ).

%!  limite(-Limite)// is det.
%
%   El número de LIMIT, o sin_limite.
limite(N) -->
    k(limit), !, t(i(N)).
limite(sin_limite) -->
    [].

% Las condiciones: OR, AND y NOT, de menor a mayor precedencia

%!  condicion(-C)// is nondet.
%
%   Una condición: o/2, y/2, no/1, comparar/3, es_nulo/1, en/2, existe/1.
condicion(C) -->
    conjuncion_sql(A),
    resto_o(A, C).

%!  resto_o(+A, -C)// is nondet.
%
%   Las disyunciones que siguen a A, asociadas a izquierda.
resto_o(A, C) -->
    k(or), conjuncion_sql(B),
    resto_o(o(A, B), C).
resto_o(A, A) -->
    [].

%!  conjuncion_sql(-C)// is nondet.
%
%   Una o más negaciones unidas por AND.
conjuncion_sql(C) -->
    negacion(A),
    resto_y(A, C).

%!  resto_y(+A, -C)// is nondet.
%
%   Las conjunciones que siguen a A, asociadas a izquierda.
resto_y(A, C) -->
    k(and), negacion(B),
    resto_y(y(A, B), C).
resto_y(A, A) -->
    [].

%!  negacion(-C)// is nondet.
%
%   NOT seguido de una negación, o un predicado.
negacion(no(C)) -->
    k(not), negacion(C).
negacion(C) -->
    predicado(C).

%!  predicado(-C)// is nondet.
%
%   EXISTS, una comparación, IS NULL, IN, BETWEEN, o una condición entre
%   paréntesis.
predicado(existe(Q)) -->
    k(exists), t('('), consulta(Q), t(')').
predicado(C) -->
    expresion(E),
    resto_predicado(E, C).
predicado(C) -->
    t('('), condicion(C), t(')').

%!  resto_predicado(+E, -C)// is nondet.
%
%   Lo que sigue a la expresión E en un predicado.
resto_predicado(E, comparar(Op, E, F)) -->
    comparador(Op), expresion(F).
resto_predicado(E, es_nulo(E)) -->
    k(is), k(null).
resto_predicado(E, no(es_nulo(E))) -->
    k(is), k(not), k(null).
resto_predicado(E, en(E, Conjunto)) -->
    k(in), conjunto(Conjunto).
resto_predicado(E, no(en(E, Conjunto))) -->
    k(not), k(in), conjunto(Conjunto).
resto_predicado(E, y(comparar(>=, E, A), comparar(<=, E, B))) -->
    k(between), expresion(A), k(and), expresion(B).

%!  comparador(-Op)// is semidet.
%
%   Un operador de comparación.
comparador(Op) -->
    t(Op),
    { memberchk(Op, [=, <>, <, >, <=, >=]) }.

%!  conjunto(-Conjunto)// is nondet.
%
%   El lado derecho de IN: subconsulta(Q) o lista(Expresiones).
conjunto(subconsulta(Q)) -->
    t('('), consulta(Q), t(')').
conjunto(lista(Es)) -->
    t('('), expresiones(Es), t(')').

% Las expresiones: + y -, después * y /, después los factores

%!  expresiones(-Es:list)// is nondet.
%
%   Una o más expresiones separadas por comas.
expresiones([E|Es]) -->
    expresion(E),
    (   t(',')
    ->  expresiones(Es)
    ;   { Es = [] }
    ).

%!  expresion(-E)// is nondet.
%
%   Una expresión: sumas y restas de términos, asociadas a izquierda.
expresion(E) -->
    termino(T),
    resto_suma(T, E).

%!  resto_suma(+A, -E)// is nondet.
%
%   Las sumas y restas que siguen a A.
resto_suma(A, E) -->
    t(+), termino(B), resto_suma(A + B, E).
resto_suma(A, E) -->
    t(-), termino(B), resto_suma(A - B, E).
resto_suma(A, A) -->
    [].

%!  termino(-T)// is nondet.
%
%   Productos y cocientes de factores, asociados a izquierda.
termino(T) -->
    factor(F),
    resto_producto(F, T).

%!  resto_producto(+A, -T)// is nondet.
%
%   Los productos y cocientes que siguen a A.
resto_producto(A, T) -->
    t(*), factor(B), resto_producto(A * B, T).
resto_producto(A, T) -->
    t(/), factor(B), resto_producto(A / B, T).
resto_producto(A, A) -->
    [].

%!  factor(-F)// is nondet.
%
%   ent(N), cad(A), nulo, menos(F), agregado(Funcion, Distinto, Argumento),
%   subconsulta(Q), una expresión entre paréntesis, columna(Tabla, C) o
%   columna(C).
factor(ent(N)) -->
    t(i(N)).
factor(cad(A)) -->
    t(s(A)).
factor(nulo) -->
    k(null).
factor(menos(F)) -->
    t(-), factor(F).
factor(agregado(count, no, todo)) -->
    k(count), t('('), t(*), t(')').
factor(agregado(F, D, E)) -->
    funcion(F), t('('), distinto(D), expresion(E), t(')').
factor(subconsulta(Q)) -->
    t('('), consulta(Q), t(')').
factor(E) -->
    t('('), expresion(E), t(')').
factor(C) -->
    columna(C).

%!  funcion(-F)// is semidet.
%
%   Una función de agregación.
funcion(F) -->
    t(n(F)),
    { memberchk(F, [count, sum, avg, min, max]) }.

%!  columna(-C)// is nondet.
%
%   columna(Tabla, Columna) para Tabla.Columna, o columna(Columna).
columna(columna(T, C)) -->
    nombre(T), t('.'), nombre(C).
columna(columna(C)) -->
    nombre(C).

%!  nombres(-Ns:list)// is nondet.
%
%   Uno o más nombres separados por comas.
nombres([N|Ns]) -->
    nombre(N),
    (   t(',')
    ->  nombres(Ns)
    ;   { Ns = [] }
    ).
