:- encoding(utf8).

% Capítulo 86 - Versiones 5 y 6: el compilador de consultas.
%
% Traduce la sintaxis abstracta de una consulta a una meta de Prolog. La
% versión 5 corrige las condiciones del compilador de Toy-Sequel
% (ingenuo.pl): cada condición se compila en dos metas, una que se cumple
% cuando la condición es verdadera y otra cuando es falsa; la tercera
% posibilidad de SQL, desconocida, es la que no cumple ninguna de las dos.
% NOT intercambia las dos metas. Las igualdades se resuelven al compilar
% solo en la conjunción de primer nivel de WHERE, donde son correctas. Las
% subconsultas de IN, EXISTS y las escalares se compilan con la tabla de
% símbolos de la consulta que las contiene: una columna de afuera es una
% variable que la consulta de afuera ya ligó.
%
% La versión 6 agrega lo que necesita el resultado entero y no una fila
% por vez: DISTINCT, GROUP BY con los agregados y HAVING, ORDER BY,
% LIMIT, UNION, INTERSECT y EXCEPT. La meta junta entonces las filas con
% findall/3, las procesa y las entrega de a una con member/2, de modo que
% toda consulta compilada tiene la misma forma: una meta que da una fila
% por solución.
%
% solo-local: carga los módulos del capítulo.
%
%?- filas("SELECT nombre FROM alumnos WHERE carrera = 'civil' OR carrera = 'industrial'", Cs, Fs).
%?- mostrar_traduccion("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'").

:- module(consultas,
          [ filas/3,
            traducir/3,
            mostrar_traduccion/1,
            compilar_consulta/5,
            condicion/5,
            expresion/7,
            igualdades/3,
            operar/4,
            escalar/3,
            grupos/3,
            agregados/3,
            procesar/3,
            combinar/4
          ]).

:- use_module(sintaxis).
:- use_module(catalogo).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(listing), [portray_clause/1]).

% La interfaz

%!  filas(+Texto, -Nombres:list, -Filas:list) is det.
%
%   Nombres son los nombres de las columnas del resultado de la consulta
%   Texto, y Filas sus filas, cada una una lista de valores.
filas(Texto, Nombres, Filas) :-
    traducir(Texto, Columnas, Fila-Meta),
    maplist(nombre_columna, Columnas, Nombres),
    findall(Fila, Meta, Filas).

% nombre_columna(Col, N): N es el nombre de la columna Col del resultado.
nombre_columna(col(N, _, _), N).

%!  traducir(+Texto, -Columnas:list, -Traduccion) is det.
%
%   Traduccion es Fila-Meta para la consulta Texto: cada solución de Meta
%   liga Fila a una fila del resultado. Columnas son sus col(Nombre, Tipo,
%   Nulo).
traducir(Texto, Columnas, Fila-Meta) :-
    analizar(Texto, Q),
    (   Q = consulta(_, _, _)
    ->  compilar_consulta(Q, [], Meta, Fila, Columnas)
    ;   throw(error(sql(no_es_consulta), _))
    ).

%!  mostrar_traduccion(+Texto) is det.
%
%   Escribe la traducción de la consulta Texto como una cláusula de
%   consulta/1, cuyo argumento es la fila.
mostrar_traduccion(Texto) :-
    traducir(Texto, _, Fila-Meta),
    portray_clause((consulta(Fila) :- Meta)).

% Las consultas

%!  compilar_consulta(+Q, +Pila:list, -Meta, -Valores:list,
%!                    -Columnas:list) is det.
%
%   Meta da, en cada solución, los Valores de una fila de la consulta Q,
%   con la tabla de símbolos Pila de las consultas que la contienen.
%   Columnas son los col(Nombre, Tipo, Nulo) del resultado.
compilar_consulta(consulta(Cuerpo, Orden, Limite), Pila, Meta, Valores,
                  Columnas) :-
    cuerpo(Cuerpo, Pila, Meta0, Valores0, Columnas, Pasos0),
    pasos_orden(Orden, Columnas, PasosOrden),
    pasos_limite(Limite, PasosLimite),
    append([Pasos0, PasosOrden, PasosLimite], Pasos),
    (   Pasos == []
    ->  Meta = Meta0,
        Valores = Valores0
    ;   length(Columnas, N),
        length(Valores, N),
        Meta = ( findall(Valores0, Meta0, Filas0),
                 consultas:procesar(Pasos, Filas0, Filas),
                 member(Valores, Filas) )
    ).

%!  cuerpo(+Cuerpo, +Pila:list, -Meta, -Valores:list, -Columnas:list,
%!         -Pasos:list) is det.
%
%   Compila una selección o una operación de conjuntos. Pasos son los
%   pasos que faltan sobre el resultado entero: [distinto] o [].
cuerpo(seleccion(D, Items, Desde, Donde, Grupo, Teniendo), Pila, Meta,
       Valores, Columnas, Pasos) :-
    marcos(Desde, Generadores, Marcos),
    Pila1 = [Marcos|Pila],
    igualdades(Donde, Pila1, Resto),
    condicion(Resto, fila, Pila1, verdadera, Filtro0),
    filtro(Filtro0, Filtro),
    (   agrupada(Items, Grupo, Teniendo)
    ->  grupo(Items, Grupo, Teniendo, Marcos, Pila1, Generadores, Filtro,
              Meta, Valores, Columnas)
    ;   proyeccion(Items, fila, Marcos, Pila1, Valores, Columnas, Calculo),
        append(Generadores, [Filtro, Calculo], Metas),
        conjuncion(Metas, Meta)
    ),
    (   D == si
    ->  Pasos = [distinto]
    ;   Pasos = []
    ).
cuerpo(union(A, B), Pila, Meta, Valores, Columnas, []) :-
    conjunto(union, A, B, Pila, Meta, Valores, Columnas).
cuerpo(union_todo(A, B), Pila, Meta, Valores, Columnas, []) :-
    conjunto(union_todo, A, B, Pila, Meta, Valores, Columnas).
cuerpo(interseccion(A, B), Pila, Meta, Valores, Columnas, []) :-
    conjunto(interseccion, A, B, Pila, Meta, Valores, Columnas).
cuerpo(diferencia(A, B), Pila, Meta, Valores, Columnas, []) :-
    conjunto(diferencia, A, B, Pila, Meta, Valores, Columnas).

%!  conjunto(+Op, +A, +B, +Pila:list, -Meta, -Valores:list,
%!           -Columnas:list) is det.
%
%   Compila la operación de conjuntos Op entre las selecciones A y B: las
%   dos se juntan enteras y combinar/4 las combina.
conjunto(Op, A, B, Pila, Meta, Valores, Columnas) :-
    cuerpo(A, Pila, MA, VA, CA, PA),
    cuerpo(B, Pila, MB, VB, CB, PB),
    union_columnas(CA, CB, Columnas),
    length(Columnas, N),
    length(Valores, N),
    juntar(MA, VA, PA, FA, JuntarA),
    juntar(MB, VB, PB, FB, JuntarB),
    Meta = ( JuntarA,
             JuntarB,
             consultas:combinar(Op, FA, FB, Filas),
             member(Valores, Filas) ).

%!  juntar(+Meta, +Valores:list, +Pasos:list, -Filas, -Juntar) is det.
%
%   Juntar es la meta que deja en Filas todas las filas de Meta, con los
%   Pasos aplicados.
juntar(Meta, Valores, [], Filas, findall(Valores, Meta, Filas)) :-
    !.
juntar(Meta, Valores, Pasos, Filas,
       ( findall(Valores, Meta, Filas0),
         consultas:procesar(Pasos, Filas0, Filas) )).

%!  union_columnas(+CA:list, +CB:list, -Columnas:list) is det.
%
%   Las columnas de una operación de conjuntos: los nombres de la
%   izquierda; los tipos deben ser compatibles columna a columna.
union_columnas(CA, CB, Columnas) :-
    length(CA, N),
    (   length(CB, N)
    ->  true
    ;   throw(error(sql(columnas_distintas), _))
    ),
    maplist(unir_columna, CA, CB, Columnas).

% unir_columna(A, B, C): C es la columna A con el tipo y la nulidad de A y B.
unir_columna(col(N, TA, NA), col(_, TB, NB), col(N, T, Nulo)) :-
    compatibles(TA, TB, _),
    tipo_comun(TA, TB, T),
    (   NA == nulo
    ->  Nulo = nulo
    ;   Nulo = NB
    ).

%!  tipo_comun(+TA, +TB, -T) is det.
%
%   El tipo de una columna que recibe valores de TA y de TB.
tipo_comun(nulo, T, T) :-
    !.
tipo_comun(T, nulo, T) :-
    !.
tipo_comun(T, T, T) :-
    !.
tipo_comun(_, _, real).

%!  filtro(+Meta0, -Meta) is det.
%
%   Meta prueba Meta0 una sola vez: una fila pasa el filtro o no, aunque
%   la condición se cumpla de varias formas. Las comparaciones no dejan
%   alternativas y no necesitan once/1.
filtro(Meta0, Meta) :-
    (   determinista(Meta0)
    ->  Meta = Meta0
    ;   Meta = once(Meta0)
    ).

%!  determinista(+Meta) is semidet.
%
%   Meta es una conjunción de pruebas que no dejan alternativas: las
%   comparaciones, \+, once/1 y los cálculos de operar/4 y escalar/3.
determinista(true).
determinista((A, B)) :-
    determinista(A),
    determinista(B).
determinista(\+ _).
determinista(once(_)).
determinista(consultas:operar(_, _, _, _)).
determinista(consultas:escalar(_, _, _)).
determinista(Prueba) :-
    functor(Prueba, Op, 2),
    memberchk(Op, [==, \==, =:=, =\=, <, >, =<, >=, @<, @>, @=<, @>=]).

%!  conjuncion(+Metas:list, -Meta) is det.
%
%   Meta es la conjunción de Metas, sin los true; true si no queda
%   ninguna.
conjuncion(Metas, Meta) :-
    exclude(==(true), Metas, Ms),
    encadenar(Ms, Meta).

%!  encadenar(+Metas:list, -Meta) is det.
%
%   Meta es (M1, (M2, …)), o true para la lista vacía.
encadenar([], true).
encadenar([M], M) :-
    !.
encadenar([M|Ms], (M, Resto)) :-
    encadenar(Ms, Resto).

% La proyección

%!  proyeccion(+Items, +Contexto, +Marcos:list, +Pila:list,
%!             -Valores:list, -Columnas:list, -Meta) is det.
%
%   Valores son los valores de los ítems de la selección, que Meta
%   calcula; Columnas, sus col(Nombre, Tipo, Nulo).
proyeccion(todo, Contexto, Marcos, Pila, Valores, Columnas, Meta) :-
    !,
    todas_las_columnas(Marcos, Items),
    proyeccion(Items, Contexto, Marcos, Pila, Valores, Columnas, Meta).
proyeccion(Items, Contexto, Marcos, Pila, Valores, Columnas, Meta) :-
    expandir(Items, Marcos, Items1),
    items(Items1, Contexto, Pila, Valores, Columnas, Metas),
    conjuncion(Metas, Meta).

%!  todas_las_columnas(+Marcos:list, -Items:list) is det.
%
%   Items nombra cada columna de cada marco, calificada con su alias.
todas_las_columnas([], []).
todas_las_columnas([M|Ms], Items) :-
    columnas_marco(M, Items, Resto),
    todas_las_columnas(Ms, Resto).

%!  columnas_marco(+Marco, -Items:list, ?Resto:list) is det.
%
%   Items-Resto nombra las columnas de Marco.
columnas_marco(marco(A, Cs), Items, Resto) :-
    columnas_alias(Cs, A, Items, Resto).

% columnas_alias(Cs, A, Items, Resto): un ítem por columna de Cs.
columnas_alias([], _, Resto, Resto).
columnas_alias([col(C, _, _, _)|Cs], A, [item(columna(A, C), sin_alias)|Is],
               Resto) :-
    columnas_alias(Cs, A, Is, Resto).

%!  expandir(+Items:list, +Marcos:list, -Items1:list) is det.
%
%   Items1 es Items con cada Alias.* reemplazado por las columnas de Alias.
expandir([], _, []).
expandir([todas(A)|Is], Marcos, Items) :-
    !,
    (   memberchk(marco(A, Cs), Marcos)
    ->  columnas_marco(marco(A, Cs), Items, Resto)
    ;   throw(error(sql(tabla_desconocida(A)), _))
    ),
    expandir(Is, Marcos, Resto).
expandir([I|Is], Marcos, [I|Resto]) :-
    expandir(Is, Marcos, Resto).

%!  items(+Items:list, +Contexto, +Pila:list, -Valores:list,
%!        -Columnas:list, -Metas:list) is det.
%
%   Compila cada ítem item(Expresion, Alias).
items([], _, _, [], [], []).
items([item(E, Alias)|Is], Contexto, Pila, [V|Vs], [col(N, T, Nulo)|Cs],
      [M|Ms]) :-
    expresion(E, Contexto, Pila, V, T, Nulo, M),
    nombre_item(E, Alias, N),
    items(Is, Contexto, Pila, Vs, Cs, Ms).

%!  nombre_item(+E, +Alias, -Nombre) is det.
%
%   El nombre de la columna del resultado: el alias, el de la columna, el
%   de la función de agregación, o expresion.
nombre_item(_, Alias, Alias) :-
    Alias \== sin_alias,
    !.
nombre_item(columna(C), _, C) :-
    !.
nombre_item(columna(_, C), _, C) :-
    !.
nombre_item(agregado(F, _, _), _, F) :-
    !.
nombre_item(_, _, expresion).

% Las expresiones

%!  expresion(+E, +Contexto, +Pila:list, -V, -Tipo, -Nulo, -Meta) is det.
%
%   Meta calcula en V el valor de la expresión E. Tipo es entero, real,
%   texto, o nulo para la constante NULL; Nulo es nulo si el valor puede
%   ser NULL y no_nulo si no. Contexto es fila, o grupo(Claves, Agregados)
%   en una consulta agrupada: una columna debe ser una de las Claves, y
%   cada agregado se anota en la lista abierta Agregados.
expresion(ent(N), _, _, N, entero, no_nulo, true).
expresion(cad(A), _, _, A, texto, no_nulo, true).
expresion(nulo, _, _, null, nulo, nulo, true).
expresion(columna(C), Contexto, Pila, V, T, Nulo, true) :-
    columna_expresion(columna(C), Contexto, Pila, V, T, Nulo).
expresion(columna(A, C), Contexto, Pila, V, T, Nulo, true) :-
    columna_expresion(columna(A, C), Contexto, Pila, V, T, Nulo).
expresion(menos(E), Contexto, Pila, V, T, Nulo, Meta) :-
    expresion(ent(0) - E, Contexto, Pila, V, T, Nulo, Meta).
expresion(A + B, Contexto, Pila, V, T, Nulo, Meta) :-
    aritmetica(+, A, B, Contexto, Pila, V, T, Nulo, Meta).
expresion(A - B, Contexto, Pila, V, T, Nulo, Meta) :-
    aritmetica(-, A, B, Contexto, Pila, V, T, Nulo, Meta).
expresion(A * B, Contexto, Pila, V, T, Nulo, Meta) :-
    aritmetica(*, A, B, Contexto, Pila, V, T, Nulo, Meta).
expresion(A / B, Contexto, Pila, V, T, Nulo, Meta) :-
    aritmetica(/, A, B, Contexto, Pila, V, T, Nulo, Meta).
expresion(subconsulta(Q), _, Pila, V, T, nulo, consultas:escalar(MQ, W, V)) :-
    compilar_consulta(Q, Pila, MQ, Ws, Cs),
    una_columna(Ws, Cs, W, col(_, T, _)).
expresion(agregado(F, D, A), Contexto, Pila, R, T, Nulo, true) :-
    (   Contexto = grupo(_, Agregados)
    ->  (   A == todo
        ->  VA = 1,
            TA = entero,
            MA = true
        ;   expresion(A, fila, Pila, VA, TA, _, MA)
        ),
        tipo_agregado(F, TA, T, Nulo),
        anotar(Agregados, a(F, D, VA, MA, R))
    ;   throw(error(sql(agregado_fuera_de_lugar(F)), _))
    ).

%!  columna_expresion(+Ref, +Contexto, +Pila:list, -V, -T, -Nulo) is det.
%
%   La variable, el tipo y la nulidad de la columna Ref.
columna_expresion(Ref, Contexto, Pila, V, T, Nulo) :-
    buscar_columna(Ref, Pila, col(C, T, Nulo, V), Nivel),
    agrupada_ok(Contexto, Nivel, C, V).

%!  aritmetica(+Op, +A, +B, +Contexto, +Pila:list, -V, -T, -Nulo, -Meta)
%!      is det.
%
%   Compila A Op B. Si los dos lados son números constantes, la
%   operación se hace al compilar.
aritmetica(Op, A, B, Contexto, Pila, V, T, Nulo, Meta) :-
    E =.. [Op, A, B],
    expresion(A, Contexto, Pila, VA, TA, NA, MA),
    expresion(B, Contexto, Pila, VB, TB, NB, MB),
    numerico(TA, E),
    numerico(TB, E),
    tipo_aritmetico(TA, TB, T),
    (   NA == no_nulo,
        NB == no_nulo
    ->  Nulo = no_nulo
    ;   Nulo = nulo
    ),
    (   number(VA),
        number(VB),
        \+ ( Op == (/), VB =:= 0 )
    ->  operar(Op, VA, VB, V),
        conjuncion([MA, MB], Meta)
    ;   conjuncion([MA, MB, consultas:operar(Op, VA, VB, V)], Meta)
    ).

%!  agrupada_ok(+Contexto, +Nivel, +C, +V) is det.
%
%   En una consulta agrupada, una columna de su propio nivel debe estar
%   en GROUP BY; si no, lanza error(sql(no_agrupada(C)), _).
agrupada_ok(fila, _, _, _).
agrupada_ok(grupo(Claves, _), Nivel, C, V) :-
    (   Nivel > 0
    ->  true
    ;   member(K, Claves),
        K == V
    ->  true
    ;   throw(error(sql(no_agrupada(C)), _))
    ).

%!  numerico(+Tipo, +E) is det.
%
%   Tipo es numérico o nulo; si no, lanza error(sql(tipos(E)), _).
numerico(T, E) :-
    (   memberchk(T, [entero, real, nulo])
    ->  true
    ;   throw(error(sql(tipos(E)), _))
    ).

%!  tipo_aritmetico(+TA, +TB, -T) is det.
%
%   real si alguno es real; entero si no.
tipo_aritmetico(TA, TB, T) :-
    (   ( TA == real ; TB == real )
    ->  T = real
    ;   T = entero
    ).

%!  una_columna(+Valores:list, +Columnas:list, -V, -Col) is det.
%
%   La subconsulta de un IN o escalar tiene una sola columna, V.
una_columna(Valores, Columnas, V, Col) :-
    (   Valores = [V],
        Columnas = [Col]
    ->  true
    ;   throw(error(sql(subconsulta_de_varias_columnas), _))
    ).

%!  tipo_agregado(+F, +TA, -T, -Nulo) is det.
%
%   El tipo del resultado de la función F sobre valores de tipo TA.
tipo_agregado(count, _, entero, no_nulo).
tipo_agregado(sum, TA, TA, nulo).
tipo_agregado(avg, _, real, nulo).
tipo_agregado(min, TA, TA, nulo).
tipo_agregado(max, TA, TA, nulo).

%!  anotar(?Lista, +A) is det.
%
%   Agrega A al final de la lista abierta Lista.
anotar(Lista, A) :-
    (   var(Lista)
    ->  Lista = [A|_]
    ;   Lista = [_|Resto],
        anotar(Resto, A)
    ).

% Las condiciones

%!  condicion(+C, +Contexto, +Pila:list, +Polaridad, -Meta) is det.
%
%   Meta se cumple cuando la condición C es verdadera, si Polaridad es
%   verdadera, o cuando es falsa, si Polaridad es falsa. Si C es
%   desconocida, no se cumple ninguna de las dos.
condicion(cierto, _, _, Pol, Meta) :-
    (   Pol == verdadera
    ->  Meta = true
    ;   Meta = fail
    ).
condicion(prueba(G), _, _, verdadera, G).
condicion(y(A, B), Contexto, Pila, Pol, Meta) :-
    condicion(A, Contexto, Pila, Pol, MA),
    condicion(B, Contexto, Pila, Pol, MB),
    (   Pol == verdadera
    ->  conjuncion([MA, MB], Meta)
    ;   Meta = (MA ; MB)
    ).
condicion(o(A, B), Contexto, Pila, Pol, Meta) :-
    condicion(A, Contexto, Pila, Pol, MA),
    condicion(B, Contexto, Pila, Pol, MB),
    (   Pol == verdadera
    ->  Meta = (MA ; MB)
    ;   conjuncion([MA, MB], Meta)
    ).
condicion(no(A), Contexto, Pila, Pol, Meta) :-
    opuesta(Pol, Pol1),
    condicion(A, Contexto, Pila, Pol1, Meta).
condicion(comparar(Op, E1, E2), Contexto, Pila, Pol, Meta) :-
    expresion(E1, Contexto, Pila, V1, T1, N1, M1),
    expresion(E2, Contexto, Pila, V2, T2, N2, M2),
    compatibles(T1, T2, Clase),
    (   Clase == nulo
    ->  Meta = fail
    ;   (   Pol == verdadera
        ->  Op1 = Op
        ;   negar(Op, Op1)
        ),
        prueba(Clase, Op1, V1, V2, Prueba),
        no_nulos([V1-N1, V2-N2], Controles),
        append([[M1, M2], Controles, [Prueba]], Metas),
        conjuncion(Metas, Meta)
    ).
condicion(es_nulo(E), Contexto, Pila, Pol, Meta) :-
    expresion(E, Contexto, Pila, V, _, Nulo, M),
    (   Nulo == no_nulo
    ->  (   Pol == verdadera
        ->  Meta = fail
        ;   Meta = M
        )
    ;   Pol == verdadera
    ->  conjuncion([M, V == null], Meta)
    ;   conjuncion([M, V \== null], Meta)
    ).
condicion(en(E, Conjunto), Contexto, Pila, Pol, Meta) :-
    pertenece(Conjunto, E, Contexto, Pila, Pol, Meta).
condicion(existe(Q), _, Pila, Pol, Meta) :-
    compilar_consulta(Q, Pila, MQ, _, _),
    (   Pol == verdadera
    ->  Meta = once(MQ)
    ;   Meta = (\+ MQ)
    ).

%!  pertenece(+Conjunto, +E, +Contexto, +Pila:list, +Polaridad, -Meta)
%!      is det.
%
%   La condición E IN Conjunto, con Conjunto lista(Expresiones) o
%   subconsulta(Q): verdadera si E es igual a un valor del conjunto, falsa
%   si E no es NULL, es distinto de todos y ninguno es NULL.
pertenece(lista(Es), E, Contexto, Pila, Pol, Meta) :-
    expresion(E, Contexto, Pila, V, T, N, M),
    lista_valores(Es, Contexto, Pila, T, Vs, Ms, Clase),
    no_nulos([V-N], Controles),
    prueba(Clase, =, V, X, Igual),
    (   Pol == verdadera
    ->  Busqueda = once(( member(X, Vs), X \== null, Igual ))
    ;   Busqueda = ( \+ memberchk(null, Vs),
                     \+ ( member(X, Vs), Igual ) )
    ),
    append([[M], Ms, Controles, [Busqueda]], Metas),
    conjuncion(Metas, Meta).
pertenece(subconsulta(Q), E, Contexto, Pila, Pol, Meta) :-
    expresion(E, Contexto, Pila, V, T, N, M),
    compilar_consulta(Q, Pila, MQ, Ws, Cs),
    una_columna(Ws, Cs, W, col(_, TW, NW)),
    compatibles(T, TW, Clase),
    no_nulos([V-N], Controles),
    prueba(Clase, =, V, W, Igual),
    (   NW == no_nulo
    ->  Hallar = (MQ, Igual),
        HayNulo = fail
    ;   Hallar = (MQ, W \== null, Igual),
        HayNulo = (MQ, W == null)
    ),
    (   Pol == verdadera
    ->  Busqueda = once(Hallar)
    ;   conjuncion([\+ HayNulo, \+ Hallar], Busqueda)
    ),
    append([[M], Controles, [Busqueda]], Metas),
    conjuncion(Metas, Meta).

%!  opuesta(?Pol, ?Opuesta) is det.
%
%   verdadera y falsa son opuestas.
opuesta(verdadera, falsa).
opuesta(falsa, verdadera).

%!  negar(+Op, -Negado) is det.
%
%   El operador de comparación que es verdadero cuando Op es falso.
negar(=, <>).
negar(<>, =).
negar(<, >=).
negar(>=, <).
negar(>, <=).
negar(<=, >).

%!  compatibles(+T1, +T2, -Clase) is det.
%
%   Clase es numerica, texto, o nulo si alguno es la constante NULL. Lanza
%   error(sql(tipos(T1, T2)), _) si no se pueden comparar.
compatibles(T1, T2, nulo) :-
    ( T1 == nulo ; T2 == nulo ),
    !.
compatibles(T1, T2, numerica) :-
    memberchk(T1, [entero, real]),
    memberchk(T2, [entero, real]),
    !.
compatibles(texto, texto, texto) :-
    !.
compatibles(T1, T2, _) :-
    throw(error(sql(tipos(T1, T2)), _)).

%!  prueba(+Clase, +Op, ?V1, ?V2, -Prueba) is det.
%
%   Prueba compara V1 y V2, que no son NULL, con Op.
prueba(numerica, Op, V1, V2, Prueba) :-
    once(op_prolog(Op, numerica, P)),
    Prueba =.. [P, V1, V2].
prueba(texto, Op, V1, V2, Prueba) :-
    once(op_prolog(Op, texto, P)),
    Prueba =.. [P, V1, V2].

% op_prolog(Op, Clase, P): P compara como Op dos valores de Clase.
op_prolog(=,  numerica, =:=).
op_prolog(<>, numerica, =\=).
op_prolog(<,  numerica, <).
op_prolog(>,  numerica, >).
op_prolog(<=, numerica, =<).
op_prolog(>=, numerica, >=).
op_prolog(=,  texto, ==).
op_prolog(<>, texto, \==).
op_prolog(<,  texto, @<).
op_prolog(>,  texto, @>).
op_prolog(<=, texto, @=<).
op_prolog(>=, texto, @>=).

%!  no_nulos(+Pares:list, -Controles:list) is det.
%
%   Controles tiene V \== null para cada V-Nulo de Pares que puede ser
%   NULL; un valor constante o de una columna NOT NULL no lo necesita.
no_nulos([], []).
no_nulos([V-Nulo|Ps], Controles) :-
    (   ( Nulo == no_nulo ; nonvar(V) )
    ->  Controles = Resto
    ;   Controles = [V \== null|Resto]
    ),
    no_nulos(Ps, Resto).

%!  lista_valores(+Es:list, +Contexto, +Pila:list, +T, -Vs:list,
%!                -Metas:list, -Clase) is det.
%
%   Los valores de la lista de IN, que deben ser compatibles con T.
lista_valores([], _, _, T, [], [], Clase) :-
    (   T == texto
    ->  Clase = texto
    ;   Clase = numerica
    ).
lista_valores([E|Es], Contexto, Pila, T, [V|Vs], [M|Ms], Clase) :-
    expresion(E, Contexto, Pila, V, TE, _, M),
    compatibles(T, TE, _),
    lista_valores(Es, Contexto, Pila, T, Vs, Ms, Clase).

%!  igualdades(+Condicion, +Pila:list, -Resto) is det.
%
%   Resuelve al compilar, unificando, las igualdades de la conjunción de
%   primer nivel de Condicion entre dos columnas del mismo tipo o entre
%   una columna y una constante, con al menos una columna de la consulta
%   actual. Resto es la condición que queda, con prueba(V \== null) si una
%   de las columnas unificadas puede ser NULL.
igualdades(Condicion, Pila, Resto) :-
    conjuntos(Condicion, Cs),
    maplist(igualdad(Pila), Cs, Restos),
    append(Restos, Quedan),
    reconstruir(Quedan, Resto).

%!  conjuntos(+C, -Cs:list) is det.
%
%   Cs son las condiciones de la conjunción C, sin los cierto.
conjuntos(y(A, B), Cs) :-
    !,
    conjuntos(A, CA),
    conjuntos(B, CB),
    append(CA, CB, Cs).
conjuntos(cierto, []) :-
    !.
conjuntos(C, [C]).

%!  reconstruir(+Cs:list, -C) is det.
%
%   C es la conjunción y/2 de Cs, o cierto.
reconstruir([], cierto).
reconstruir([C], C) :-
    !.
reconstruir([C|Cs], y(C, R)) :-
    reconstruir(Cs, R).

%!  igualdad(+Pila:list, +C, -Quedan:list) is det.
%
%   Si C es una igualdad que se puede resolver al compilar, la resuelve y
%   Quedan son los controles de NULL que hacen falta; si no, Quedan = [C].
igualdad(Pila, C, Quedan) :-
    C = comparar(=, E1, E2),
    simple(E1, Pila, V1, T1, N1, L1),
    simple(E2, Pila, V2, T2, N2, L2),
    unificable(L1, L2),
    compatibles(T1, T2, _),
    T1 == T2,
    V1 = V2,
    !,
    (   ( N1 == nulo ; N2 == nulo ),
        var(V1)
    ->  Quedan = [prueba(V1 \== null)]
    ;   Quedan = []
    ).
igualdad(_, C, [C]).

%!  simple(+E, +Pila:list, -V, -Tipo, -Nulo, -Lugar) is semidet.
%
%   E es una columna, con Lugar su nivel, o una constante que no es NULL,
%   con Lugar constante.
simple(ent(N), _, N, entero, no_nulo, constante).
simple(cad(A), _, A, texto, no_nulo, constante).
simple(Ref, Pila, V, T, Nulo, Nivel) :-
    ( Ref = columna(_) ; Ref = columna(_, _) ),
    buscar_columna(Ref, Pila, col(_, T, Nulo, V), Nivel).

%!  unificable(+L1, +L2) is semidet.
%
%   Una igualdad entre lugares L1 y L2 se puede resolver unificando: una
%   columna de la consulta actual con otra columna o con una constante.
unificable(0, _) :-
    !.
unificable(_, 0).

% La agrupación

%!  agrupada(+Items, +Grupo:list, +Teniendo) is semidet.
%
%   La consulta tiene GROUP BY, HAVING, o un agregado en la selección.
agrupada(_, Grupo, _) :-
    Grupo \== [],
    !.
agrupada(_, _, Teniendo) :-
    Teniendo \== cierto,
    !.
agrupada(Items, _, _) :-
    is_list(Items),
    sub_term(agregado(_, _, _), Items),
    !.

%!  grupo(+Items, +Grupo:list, +Teniendo, +Marcos:list, +Pila:list,
%!        +Generadores:list, +Filtro, -Meta, -Valores:list,
%!        -Columnas:list) is det.
%
%   Compila una selección agrupada. Meta junta, para cada fila que pasa
%   el filtro, los valores de las columnas de GROUP BY y los argumentos de
%   los agregados; forma los grupos; y para cada grupo liga las columnas
%   de GROUP BY, calcula los agregados, prueba HAVING y calcula la fila.
grupo(Items, Grupo, Teniendo, Marcos, Pila, Generadores, Filtro, Meta,
      Valores, Columnas) :-
    maplist(clave_grupo(Pila), Grupo, Claves),
    Contexto = grupo(Claves, Agregados),
    proyeccion(Items, Contexto, Marcos, Pila, Valores, Columnas, Calculo),
    condicion(Teniendo, Contexto, Pila, verdadera, Having0),
    filtro(Having0, Having),
    cerrar(Agregados),
    partes(Agregados, Funciones, Argumentos, MetasArgumentos, Resultados),
    append([Generadores, [Filtro], MetasArgumentos], Metas),
    conjuncion(Metas, MetaFila),
    (   Grupo == []
    ->  Global = si
    ;   Global = no
    ),
    conjuncion([ findall(Claves-Argumentos, MetaFila, Pares),
                 consultas:grupos(Global, Pares, Grupos),
                 member(Claves-Filas, Grupos),
                 consultas:agregados(Funciones, Filas, Resultados),
                 Having,
                 Calculo ],
               Meta).

%!  partes(+Agregados:list, -Funciones:list, -Argumentos:list,
%!         -Metas:list, -Resultados:list) is det.
%
%   Separa los agregados anotados a(F, D, Argumento, Meta, Resultado).
partes([], [], [], [], []).
partes([a(F, D, V, M, R)|As], [F-D|Fs], [V|Vs], [M|Ms], [R|Rs]) :-
    partes(As, Fs, Vs, Ms, Rs).

%!  clave_grupo(+Pila:list, +Ref, -V) is det.
%
%   V es la variable de la columna Ref de GROUP BY, de la consulta actual.
clave_grupo(Pila, Ref, V) :-
    buscar_columna(Ref, Pila, col(_, _, _, V), _).

%!  cerrar(?Lista) is det.
%
%   Cierra la lista abierta Lista.
cerrar([]) :-
    !.
cerrar([_|Resto]) :-
    cerrar(Resto).

% El orden y el límite

%!  pasos_orden(+Orden:list, +Columnas:list, -Pasos:list) is det.
%
%   [ordenar(Claves)] con cada clave Posicion-Direccion, o [] sin ORDER
%   BY. Una clave nombra una columna del resultado, o da su posición.
pasos_orden([], _, []) :-
    !.
pasos_orden(Orden, Columnas, [ordenar(Claves)]) :-
    maplist(clave_orden(Columnas), Orden, Claves).

%!  clave_orden(+Columnas:list, +O, -Clave) is det.
%
%   La posición de la columna del resultado que nombra O, con su
%   dirección.
clave_orden(Columnas, orden(E, D), I-D) :-
    (   E = ent(I)
    ->  true
    ;   ( E = columna(C) ; E = columna(_, C) ),
        nth1(I, Columnas, col(C, _, _))
    ->  true
    ;   throw(error(sql(orden_no_admitido(E)), _))
    ).

%!  pasos_limite(+Limite, -Pasos:list) is det.
%
%   [limite(N)], o [] sin LIMIT.
pasos_limite(sin_limite, []) :-
    !.
pasos_limite(N, [limite(N)]).

% Lo que se ejecuta: los predicados que llaman las metas compiladas

%!  operar(+Op, +A, +B, -V) is det.
%
%   V es A Op B, con Op +, -, * o /. NULL si alguno es NULL o si se divide
%   por cero; la división entre enteros es entera, como en SQLite.
operar(Op, A, B, V) :-
    (   ( A == null ; B == null )
    ->  V = null
    ;   Op == (/),
        B =:= 0
    ->  V = null
    ;   Op == (/),
        integer(A),
        integer(B)
    ->  V is A // B
    ;   E =.. [Op, A, B],
        V is E
    ).

:- meta_predicate escalar(0, ?, -).

%!  escalar(:Meta, ?W, -V) is det.
%
%   V es el único valor W de las soluciones de Meta, o NULL si no tiene
%   ninguna. Lanza error(sql(subconsulta_de_varias_filas), _) si tiene más
%   de una.
escalar(Meta, W, V) :-
    findall(W, Meta, Ws),
    (   Ws = []
    ->  V = null
    ;   Ws = [V]
    ->  true
    ;   throw(error(sql(subconsulta_de_varias_filas), _))
    ).

%!  grupos(+Global, +Pares:list, -Grupos:list) is det.
%
%   Grupos son los Clave-Filas de los pares Clave-Fila, ordenados por la
%   clave. Sin GROUP BY (Global = si) hay un solo grupo, aunque no haya
%   filas.
grupos(si, Pares, [[]-Filas]) :-
    pairs_values(Pares, Filas).
grupos(no, Pares, Grupos) :-
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos).

%!  agregados(+Funciones:list, +Filas:list, -Resultados:list) is det.
%
%   Resultados tiene, para la función F-D número I, su valor sobre la
%   columna I de Filas.
agregados(Funciones, Filas, Resultados) :-
    length(Funciones, N),
    numlist_0(N, Is),
    maplist(agregado_i(Filas), Is, Funciones, Resultados).

% numlist_0(N, Is): Is es [1, …, N], o [] si N es 0.
numlist_0(0, []) :-
    !.
numlist_0(N, Is) :-
    numlist(1, N, Is).

% agregado_i(Filas, I, F-D, R): R es la función F sobre la columna I.
agregado_i(Filas, I, F-D, R) :-
    maplist(nth1(I), Filas, Valores),
    agregar(F, D, Valores, R).

%!  agregar(+F, +Distinto, +Valores:list, -R) is det.
%
%   R es la función F sobre los Valores que no son NULL, sin repetidos si
%   Distinto es si. SUM, AVG, MIN y MAX de ningún valor son NULL; AVG es
%   de punto flotante.
agregar(F, D, Valores, R) :-
    exclude(==(null), Valores, Vs0),
    (   D == si
    ->  sort(Vs0, Vs)
    ;   Vs = Vs0
    ),
    (   F == count
    ->  length(Vs, R)
    ;   Vs == []
    ->  R = null
    ;   F == sum
    ->  sum_list(Vs, R)
    ;   F == avg
    ->  sum_list(Vs, S),
        length(Vs, K),
        R is float(S / K)
    ;   F == min
    ->  min_member(R, Vs)
    ;   max_member(R, Vs)
    ).

%!  procesar(+Pasos:list, +Filas0:list, -Filas:list) is det.
%
%   Aplica a Filas0, en orden, cada paso: distinto, ordenar(Claves) o
%   limite(N).
procesar([], Filas, Filas).
procesar([P|Ps], Filas0, Filas) :-
    paso(P, Filas0, Filas1),
    procesar(Ps, Filas1, Filas).

%!  paso(+Paso, +Filas0:list, -Filas:list) is det.
%
%   Un paso sobre el resultado entero.
paso(distinto, Filas0, Filas) :-
    list_to_set(Filas0, Filas).
paso(ordenar(Claves), Filas0, Filas) :-
    reverse(Claves, Inversas),
    foldl(ordenar_por, Inversas, Filas0, Filas).
paso(limite(N), Filas0, Filas) :-
    length(Filas0, L),
    (   L =< N
    ->  Filas = Filas0
    ;   length(Filas, N),
        append(Filas, _, Filas0)
    ).

%!  ordenar_por(+Clave, +Filas0:list, -Filas:list) is det.
%
%   Filas es Filas0 ordenada, de manera estable, por la columna I de
%   Clave = I-Direccion. NULL va primero en orden ascendente, como en
%   SQLite.
ordenar_por(I-D, Filas0, Filas) :-
    maplist(con_clave(I), Filas0, Pares),
    (   D == asc
    ->  sort(1, @=<, Pares, Ordenados)
    ;   sort(1, @>=, Pares, Ordenados)
    ),
    pairs_values(Ordenados, Filas).

% con_clave(I, Fila, K-Fila): K ordena NULL antes que cualquier valor.
con_clave(I, Fila, K-Fila) :-
    nth1(I, Fila, V),
    (   V == null
    ->  K = k(0)
    ;   K = k(1, V)
    ).

%!  combinar(+Op, +FA:list, +FB:list, -Filas:list) is det.
%
%   Filas es la operación de conjuntos Op entre las filas FA y FB: union
%   y union_todo, interseccion y diferencia. Todas menos union_todo
%   eliminan las filas repetidas.
combinar(union_todo, FA, FB, Filas) :-
    append(FA, FB, Filas).
combinar(union, FA, FB, Filas) :-
    append(FA, FB, F0),
    list_to_set(F0, Filas).
combinar(interseccion, FA, FB, Filas) :-
    list_to_set(FA, SA),
    findall(F, ( member(F, SA), memberchk(F, FB) ), Filas).
combinar(diferencia, FA, FB, Filas) :-
    list_to_set(FA, SA),
    findall(F, ( member(F, SA), \+ memberchk(F, FB) ), Filas).
