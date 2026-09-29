:- encoding(utf8).

% Capítulo 38 - Resolución SLD y SLDNF sobre un programa leído como datos.
%
% Los programas objeto son cláusulas comunes de este archivo, que
% clausulas/2 lee con clause/2; otros archivos agregan programas con
% generado/2. Como en semantica.pl, cada predicado tiene dos formas: el que
% termina en _de trabaja sobre la lista de cláusulas, y el otro recibe el
% nombre del programa. paso/4 da un paso de resolución SLD con una regla de
% selección, izquierda (la de Prolog) o derecha, y arbol_sld/5 recorre el
% árbol SLD entero hasta una profundidad. sldnf/2 agrega la negación como
% falla finita con una regla de selección segura, y complecion/3 construye
% la compleción de Clark de un predicado.
%
%?- paso(izquierda, familia, [abuelo(juan, Q)], R).
%?- arbol_sld(derecha, enlaces, [conexion(a, X)], 8, A).
%?- sldnf(aves, [vuela_mal(X)]).
%?- complecion(aves, vuela/1, F).

% programa(Nombre, Predicados): los predicados que forman el programa Nombre.
programa(familia, [padre/2, abuelo/2]).
programa(enlaces, [enlace/2, conexion/2]).
programa(aves, [ave/1, pinguino/1, vuela/1, vuela_mal/1]).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

% enlace(X, Y): hay un enlace directo de X a Y.
enlace(a, b).
enlace(b, c).
enlace(c, d).

%!  conexion(?X, ?Y) is nondet.
%
%   Hay una sucesión de enlaces de X a Y. Con la recursión a la izquierda,
%   Prolog no termina después de la última respuesta.
conexion(X, Y) :-
    enlace(X, Y).
conexion(X, Y) :-
    conexion(X, Z),
    enlace(Z, Y).

% ave(X): X es un ave.
ave(piolin).
ave(pingu).

% pinguino(X): X es un pingüino.
pinguino(pingu).

%!  vuela(?X) is nondet.
%
%   X es un ave que no es un pingüino.
vuela(X) :-
    ave(X),
    \+ pinguino(X).

%!  vuela_mal(+X) is semidet.
%
%   vuela/1 con los objetivos al revés: con X libre, la negación se evalúa
%   antes de ligarla, y la consulta falla.
vuela_mal(X) :-
    \+ pinguino(X),
    ave(X).

%!  clausulas(+Programa, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas del programa llamado Programa, como
%   términos Cabeza :- Cuerpo: las de sus predicados si está en programa/2,
%   o las que construye generado/2. Error de existencia si no es ninguno
%   de los dos.
clausulas(Programa, Clausulas) :-
    must_be(callable, Programa),
    (   programa(Programa, Indicadores)
    ->  findall(Cabeza :- Cuerpo,
                ( member(Nombre/Aridad, Indicadores),
                  functor(Cabeza, Nombre, Aridad),
                  clause(Cabeza, Cuerpo) ),
                Clausulas)
    ;   generado(Programa, Generadas)
    ->  Clausulas = Generadas
    ;   existence_error(programa, Programa)
    ).

% generado(Programa, Clausulas): las cláusulas de un programa construido
% como datos. Este archivo no define ninguno; otros archivos los agregan.
:- multifile generado/2.

%!  paso_de(+Seleccion, +Clausulas:list, +Metas:list, -Resolvente:list)
%!      is nondet.
%
%   Resolvente se obtiene de Metas en un paso de resolución SLD: la regla
%   Seleccion, izquierda o derecha, elige un átomo; una cláusula con
%   variables nuevas cuya cabeza unifica con él lo reemplaza por su cuerpo.
%   La sustitución queda aplicada a Metas y a Resolvente. Una respuesta por
%   cada cláusula que se puede usar.
paso_de(Seleccion, Clausulas, Metas, Resolvente) :-
    seleccionar(Seleccion, Metas, Antes, Atomo, Despues),
    member(Clausula, Clausulas),
    copy_term(Clausula, Atomo :- Cuerpo),
    conjuncion_lista(Cuerpo, Literales),
    append([Antes, Literales, Despues], Resolvente).

%!  paso(+Seleccion, +Programa, +Metas:list, -Resolvente:list) is nondet.
%
%   paso_de/4 con las cláusulas del programa llamado Programa.
paso(Seleccion, Programa, Metas, Resolvente) :-
    clausulas(Programa, Clausulas),
    paso_de(Seleccion, Clausulas, Metas, Resolvente).

%!  seleccionar(+Regla, +Metas:list, -Antes:list, -Atomo, -Despues:list)
%!      is semidet.
%
%   Atomo es el átomo de Metas que elige Regla: el primero (izquierda) o el
%   último (derecha). Antes y Despues son los que lo rodean. Falla con
%   Metas vacía.
seleccionar(izquierda, [Atomo|Despues], [], Atomo, Despues).
seleccionar(derecha, Metas, Antes, Atomo, []) :-
    once(append(Antes, [Atomo], Metas)).

%!  conjuncion_lista(+Cuerpo, -Literales:list) is det.
%
%   Literales son las partes de la conjunción Cuerpo, de izquierda a
%   derecha; el cuerpo true no tiene ninguna.
conjuncion_lista(Cuerpo, Literales) :-
    (   Cuerpo == true
    ->  Literales = []
    ;   Cuerpo = (A, B)
    ->  conjuncion_lista(A, La),
        conjuncion_lista(B, Lb),
        append(La, Lb, Literales)
    ;   Literales = [Cuerpo]
    ).

%!  arbol_sld_de(+Seleccion, +Clausulas:list, +Consulta:list,
%!            +Limite:integer, -Resumen) is det.
%
%   Recorre el árbol SLD de Consulta con la regla Seleccion hasta la
%   profundidad Limite. Resumen es arbol(Respuestas, Nodos, Fallos,
%   Cortadas): Consulta instanciada en cada hoja de éxito, en el orden del
%   recorrido; la cantidad de nodos; las hojas de fallo; y las ramas que
%   llegan al límite sin terminar.
arbol_sld_de(Seleccion, Clausulas, Consulta, Limite,
          arbol(Respuestas, Nodos, Fallos, Cortadas)) :-
    findall(Nodo, nodo(Seleccion, Clausulas, Consulta, Consulta, Limite, Nodo),
            Todos),
    findall(R, member(exito(R), Todos), Respuestas),
    length(Todos, Nodos),
    aggregate_all(count, member(fallo, Todos), Fallos),
    aggregate_all(count, member(cortada, Todos), Cortadas).

%!  arbol_sld(+Seleccion, +Programa, +Consulta:list, +Limite:integer,
%!            -Resumen) is det.
%
%   arbol_sld_de/5 con las cláusulas del programa llamado Programa.
arbol_sld(Seleccion, Programa, Consulta, Limite, Resumen) :-
    clausulas(Programa, Clausulas),
    arbol_sld_de(Seleccion, Clausulas, Consulta, Limite, Resumen).

%!  nodo(+Seleccion, +Clausulas:list, ?Consulta, +Metas:list,
%!       +Limite:integer, -Nodo) is multi.
%
%   Nodo es uno de los nodos del árbol SLD de Metas, en profundidad y de
%   izquierda a derecha: exito(Consulta) en una hoja de éxito, fallo en una
%   de fallo, cortada donde se alcanza el límite, e interno en los demás.
nodo(Seleccion, Clausulas, Consulta, Metas, Limite, Nodo) :-
    (   Metas == []
    ->  Nodo = exito(Consulta)
    ;   Limite =:= 0
    ->  Nodo = cortada
    ;   \+ paso_de(Seleccion, Clausulas, Metas, _)
    ->  Nodo = fallo
    ;   (   Nodo = interno
        ;   Limite1 is Limite - 1,
            paso_de(Seleccion, Clausulas, Metas, Resolvente),
            nodo(Seleccion, Clausulas, Consulta, Resolvente, Limite1, Nodo)
        )
    ).

%!  sldnf_de(+Clausulas:list, +Metas:list) is nondet.
%
%   Metas se refuta por resolución SLDNF. Se elige el primer literal
%   seguro: un átomo, o un literal negado \+ A con A sin variables, que se
%   cumple si el árbol de A es finito y no tiene éxitos. Error de
%   instanciación si solo quedan literales negados con variables: la
%   derivación no puede seguir.
sldnf_de(Clausulas, Metas) :-
    (   Metas == []
    ->  true
    ;   once(( append(Antes, [Literal|Despues], Metas),
               seguro(Literal) ))
    ->  resolver(Literal, Clausulas, Antes, Despues)
    ;   instantiation_error(Metas)
    ).

%!  sldnf(+Programa, +Metas:list) is nondet.
%
%   Metas se refuta por resolución SLDNF con el programa llamado Programa.
sldnf(Programa, Metas) :-
    clausulas(Programa, Clausulas),
    sldnf_de(Clausulas, Metas).

%!  seguro(+Literal) is semidet.
%
%   Literal se puede elegir: es un átomo, o está negado y no tiene
%   variables.
seguro(Literal) :-
    (   Literal = (\+ A)
    ->  ground(A)
    ;   true
    ).

%!  resolver(+Literal, +Clausulas:list, +Antes:list, +Despues:list)
%!      is nondet.
%
%   Resuelve Literal, elegido entre Antes y Despues, y sigue con el
%   resolvente.
resolver(\+ A, Clausulas, Antes, Despues) :-
    \+ sldnf_de(Clausulas, [A]),
    append(Antes, Despues, Resto),
    sldnf_de(Clausulas, Resto).
resolver(Atomo, Clausulas, Antes, Despues) :-
    Atomo \= (\+ _),
    member(Clausula, Clausulas),
    copy_term(Clausula, Atomo :- Cuerpo),
    conjuncion_lista(Cuerpo, Literales),
    append([Antes, Literales, Despues], Resolvente),
    sldnf_de(Clausulas, Resolvente).

%!  complecion_de(+Clausulas:list, +Indicador, -Formula) is det.
%
%   Formula es la definición completada del predicado Indicador:
%   sii(Cabeza, Definicion), con los argumentos de Cabeza distintos y
%   libres. Definicion es falso si el predicado no tiene cláusulas, o la
%   disyunción, con ;, de una alternativa por cláusula: la conjunción de
%   las igualdades que la cabeza exige y del cuerpo, dentro de
%   existe(Variables, Conjuncion) si tiene variables propias.
complecion_de(Clausulas, Nombre/Aridad, sii(Cabeza, Definicion)) :-
    functor(Cabeza, Nombre, Aridad),
    findall(Cabeza-Alternativa,
            ( member(Clausula, Clausulas),
              copy_term(Clausula, H :- Cuerpo),
              functor(H, Nombre, Aridad),
              alternativa(Cabeza, H, Cuerpo, Alternativa) ),
            Pares),
    maplist(unir_cabeza(Cabeza), Pares, Alternativas),
    disyuncion(Alternativas, Definicion).

%!  complecion(+Programa, +Indicador, -Formula) is det.
%
%   Formula es la definición completada del predicado Indicador del
%   programa llamado Programa.
complecion(Programa, Indicador, Formula) :-
    clausulas(Programa, Clausulas),
    complecion_de(Clausulas, Indicador, Formula).

%!  unir_cabeza(?Cabeza, +Par, -Alternativa) is det.
%
%   Par es C-Alternativa, copiado por findall/3: C unifica con Cabeza y
%   liga así las variables de Alternativa a las de Cabeza.
unir_cabeza(Cabeza, Cabeza-Alternativa, Alternativa).

%!  alternativa(+Cabeza, +H, +Cuerpo, -Alternativa) is det.
%
%   Alternativa es la parte de la definición completada que aporta la
%   cláusula H :- Cuerpo, con los argumentos de Cabeza.
alternativa(Cabeza, H, Cuerpo, Alternativa) :-
    Cabeza =.. [_|Xs],
    H =.. [_|Ts],
    foldl(igualdad(Xs), Xs, Ts, [], Igualdades0),
    reverse(Igualdades0, Igualdades),
    conjuncion_lista(Cuerpo, Literales),
    append(Igualdades, Literales, Partes),
    conjuncion(Partes, Conjuncion),
    term_variables(Conjuncion, Todas),
    exclude(en(Xs), Todas, Existenciales),
    (   Existenciales == []
    ->  Alternativa = Conjuncion
    ;   Alternativa = existe(Existenciales, Conjuncion)
    ).

%!  igualdad(+Xs:list, +X, +T, +Igualdades0:list, -Igualdades:list) is det.
%
%   X es un argumento de la cabeza completada, cuyos argumentos son Xs, y T
%   el mismo argumento de la cláusula. Si T es una variable que no es
%   todavía una de Xs, la reemplaza por X; si no, agrega la igualdad X = T.
igualdad(Xs, X, T, Igualdades0, Igualdades) :-
    (   var(T),
        \+ en(Xs, T)
    ->  T = X,
        Igualdades = Igualdades0
    ;   Igualdades = [X = T|Igualdades0]
    ).

%!  en(+Variables:list, +V) is semidet.
%
%   V es, idéntica, una de Variables.
en(Variables, V) :-
    once(( member(W, Variables),
           W == V )).

%!  conjuncion(+Partes:list, -Conjuncion) is det.
%
%   Conjuncion une Partes con , de izquierda a derecha; sin partes, es
%   true.
conjuncion([], true).
conjuncion([P|Ps], Conjuncion) :-
    unir(Ps, P, ',', Conjuncion).

%!  disyuncion(+Alternativas:list, -Definicion) is det.
%
%   Definicion une Alternativas con ; de izquierda a derecha; sin
%   alternativas, es falso.
disyuncion([], falso).
disyuncion([A|As], Definicion) :-
    unir(As, A, (;), Definicion).

%!  unir(+Resto:list, +Primero, +Operador, -Termino) is det.
%
%   Termino une Primero y los de Resto con Operador, asociado a la derecha.
unir([], P, _, P).
unir([Q|Qs], P, Operador, Termino) :-
    Termino =.. [Operador, P, T],
    unir(Qs, Q, Operador, T).
