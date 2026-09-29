# Resolución SLD y SLDNF

Esta página contiene las secciones [38.2](index.md#382-resolucion-sld) y
[38.3](index.md#383-negacion-como-falla-la-complecion-de-clark-y-sldnf) del
[capítulo 38](index.md): la resolución SLD enunciada con precisión, con un
paso de resolución y el árbol SLD escritos en Prolog, y la negación como
falla, con la compleción de Clark y la resolución SLDNF. Los ejemplos están
en `sld.pl`, en `ejemplos/capitulo-38/`, salvo el programa `circular` del
final, que está en `semantica.pl`; los dos corren en SWISH. Como en la
[sección 38.1](index.md#381-modelos-y-consecuencia-logica), cada predicado tiene dos formas: la terminada en
`_de` recibe la lista de cláusulas, y la otra, el nombre del programa.

## Resolución SLD

La resolución del [capítulo 12](../capitulo-12-prolog-y-la-logica/index.md#125-como-prueba-prolog) y el árbol del [capítulo 5](../capitulo-05-como-responde-prolog/index.md)
se enuncian con precisión así. Una consulta es una lista de átomos,
$\leftarrow A_1, \dots, A_n$. Un **paso de resolución SLD** tiene tres
decisiones:

1. la **regla de selección** elige un átomo $A_i$ de la consulta;
2. se toma una cláusula del programa, **renombrada** con variables nuevas,
   cuya cabeza unifica con $A_i$ mediante el unificador más general θ;
3. el **resolvente** es la consulta con $A_i$ reemplazado por el cuerpo de la
   cláusula, y con θ aplicada a todo.

Una **derivación SLD** es una sucesión de pasos; una **refutación** es una
derivación que llega a la consulta vacía, y la composición de sus
sustituciones, restringida a las variables de la consulta, es la
**respuesta calculada**. `paso_de/4`, en `sld.pl`, da un paso con la regla
`izquierda`, la de Prolog, o `derecha`, que elige el último átomo:

<!-- ejemplo: capitulo-38/sld.pl predicado: paso_de/4 seleccionar/5 -->
```prolog
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

%!  seleccionar(+Regla, +Metas:list, -Antes:list, -Atomo, -Despues:list)
%!      is semidet.
%
%   Atomo es el átomo de Metas que elige Regla: el primero (izquierda) o el
%   último (derecha). Antes y Despues son los que lo rodean. Falla con
%   Metas vacía.
seleccionar(izquierda, [Atomo|Despues], [], Atomo, Despues).
seleccionar(derecha, Metas, Antes, Atomo, []) :-
    once(append(Antes, [Atomo], Metas)).
```

`copy_term/2` hace dos cosas a la vez: renombra la cláusula y unifica su
cabeza con el átomo elegido. `paso/4` recibe en su lugar el nombre del
programa, como el `familia` de la
[sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion):

```prolog
?- paso(izquierda, familia, [abuelo(juan, Q)], R).
R = [padre(juan, _A), padre(_A, Q)].

?- paso(izquierda, familia, [padre(juan, P), padre(P, Q)], R).
P = ana,
R = [padre(ana, Q)] ;
P = pedro,
R = [padre(pedro, Q)] ;
false.

?- paso(derecha, familia, [padre(juan, P), padre(P, Q)], R).
P = juan,
Q = ana,
R = [padre(juan, juan)] ;
P = juan,
Q = pedro,
R = [padre(juan, juan)] ;
P = pedro,
Q = luis,
R = [padre(juan, pedro)] ;
false.
```

Cada respuesta es un arco del árbol, con su sustitución aplicada. Con la
regla de la derecha, el mismo nodo tiene tres hijos en lugar de dos.
`arbol_sld_de/5` recorre el árbol entero hasta una profundidad, y lo resume en
las respuestas, la cantidad de nodos, las hojas de fallo y las ramas que
llegan al límite sin terminar:

<!-- ejemplo: capitulo-38/sld.pl predicado: arbol_sld_de/5 nodo/6 -->
```prolog
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
```

```prolog
?- arbol_sld(izquierda, familia, [abuelo(juan, Q)], 5, A).
A = arbol([[abuelo(juan, luis)]], 5, 1, 0).

?- arbol_sld(derecha, familia, [abuelo(juan, Q)], 5, A).
A = arbol([[abuelo(juan, luis)]], 6, 2, 0).
```

El árbol de la izquierda es el de la [sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion): cinco nodos y un
fallo. El de la derecha tiene otra forma, y la misma respuesta. Con la
recursión a la izquierda de `conexion/2`, sobre enlaces de `a` a `b`, de `b`
a `c` y de `c` a `d`, la diferencia es mayor:

<!-- ejemplo: capitulo-38/sld.pl predicado: enlace/2 conexion/2 -->
```prolog
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
```

```prolog
?- arbol_sld(izquierda, enlaces, [conexion(a, X)], 8, A).
A = arbol([[conexion(a, b)], [conexion(a, c)], [conexion(a, d)]], 32, 1, 5).

?- arbol_sld(izquierda, enlaces, [conexion(a, X)], 12, A).
A = arbol([[conexion(a, b)], [conexion(a, c)], [conexion(a, d)]], 52, 5, 5).

?- arbol_sld(derecha, enlaces, [conexion(a, X)], 8, A).
A = arbol([[conexion(a, b)], [conexion(a, c)], [conexion(a, d)]], 24, 7, 0).
```

Con la regla de la izquierda, cada nivel del árbol vuelve a elegir un átomo
`conexion/2` y siempre hay ramas que llegan al límite: el árbol es infinito,
y con un límite mayor crece sin agregar respuestas. Con la regla de la
derecha se elige primero `enlace/2`, que liga la variable intermedia, y el
árbol es finito: 24 nodos con cualquier límite desde 8. Las tres respuestas
son las mismas.

Tres teoremas ordenan lo observado, demostrados por Nilsson y Małuszyński
(apartados 3.4 y 3.5):

- **Corrección.** Toda respuesta calculada θ es correcta: $P \models \forall
  (G\theta)$, la consulta instanciada es consecuencia lógica del programa.
- **Completitud.** Toda respuesta correcta es una instancia de alguna
  respuesta calculada.
- **Independencia de la regla de selección.** Con cualquier regla de
  selección, el árbol SLD tiene las mismas respuestas calculadas, aunque
  cambien su forma, su tamaño y su finitud.

La completitud se refiere al árbol, no a la forma de recorrerlo. Prolog usa
la regla de la izquierda y recorre el árbol en profundidad, y un recorrido
en profundidad no llega a las ramas que están a la derecha de una rama
infinita ([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)); un recorrido en anchura las alcanza todas. Y la
corrección supone la unificación con verificación de ocurrencia: sin ella,
que SWI-Prolog omite por defecto ([sección 12.6](../capitulo-12-prolog-y-la-logica/index.md#126-lo-que-excede-la-logica)), una refutación
puede calcular un término infinito que no corresponde a ninguna respuesta.
`unify_with_occurs_check/2` hace la unificación completa, y la bandera
`occurs_check` la activa en todo el programa.

!!! question "Actividad"
    Predecir el resultado de `arbol_sld/5` con la consulta
    `[conexion(X, d)]` y límite 8, con cada regla: cuántas respuestas, y si
    hay ramas cortadas. Comprobarlo, y explicar por qué la regla de la
    izquierda sigue produciendo un árbol infinito aunque el destino esté
    ligado.

## Negación como falla: la compleción de Clark y SLDNF

Un programa definido no tiene consecuencias negativas: la base de Herbrand
entera es un modelo, y en ella todo es verdadero. Cuando `\+ A` tiene éxito,
lo que se sabe es que A no se pudo probar, y para leer eso como $\lnot A$
hace falta agregar al programa lo que el programa calla: que sus cláusulas
son **todas** las razones por las que un átomo es verdadero. Keith Clark
(1978) lo formalizó como la **compleción** del programa, comp(P): cada
predicado se define con un «si y solo si» que reúne sus cláusulas, y se
agregan los axiomas de la igualdad sintáctica, que dicen, entre otras cosas,
que dos constantes distintas denotan objetos distintos.

`sld.pl` tiene el programa `aves`, con la negación:

<!-- ejemplo: capitulo-38/sld.pl predicado: ave/1 pinguino/1 vuela/1 -->
```prolog
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
```

Su compleción, para los tres predicados:

$$\forall X \; \bigl( \mathit{ave}(X) \leftrightarrow X = \mathit{piolin} \lor X = \mathit{pingu} \bigr)$$

$$\forall X \; \bigl( \mathit{pinguino}(X) \leftrightarrow X = \mathit{pingu} \bigr)$$

$$\forall X \; \bigl( \mathit{vuela}(X) \leftrightarrow \mathit{ave}(X) \land \lnot \mathit{pinguino}(X) \bigr)$$

Con los axiomas de la igualdad, que dan $\mathit{piolin} \neq \mathit{pingu}$,
de la segunda fórmula se deduce $\lnot \mathit{pinguino}(\mathit{piolin})$:
ahora sí es una consecuencia lógica. `complecion_de/3` construye la definición
completada de un predicado: los argumentos de la cabeza pasan a ser
variables distintas, cada argumento que no es una variable nueva se vuelve
una igualdad, y las variables que solo aparecen en el cuerpo quedan
cuantificadas existencialmente:

<!-- ejemplo: capitulo-38/sld.pl predicado: complecion_de/3 alternativa/4 igualdad/5 -->
```prolog
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
```

```prolog
?- complecion(aves, ave/1, F).
F = sii(ave(_A), (_A=piolin;_A=pingu)).

?- complecion(aves, vuela/1, F).
F = sii(vuela(_A), (ave(_A), \+pinguino(_A))).

?- complecion(familia, abuelo/2, F).
F = sii(abuelo(_A, _B), existe([_C], (padre(_A, _C), padre(_C, _B)))).
```

La última es
$\forall A \, \forall N \, \bigl( \mathit{abuelo}(A, N) \leftrightarrow \exists P \, (\mathit{padre}(A, P) \land \mathit{padre}(P, N)) \bigr)$:
la variable P, que en la cláusula está cuantificada universalmente sobre
toda la regla, en la compleción queda existencial, como anticipaba la
[sección 12.3](../capitulo-12-prolog-y-la-logica/index.md#123-las-variables-y-los-cuantificadores). Un predicado sin cláusulas se completa como
$p \leftrightarrow \mathit{falso}$.

Clark demostró que la negación como falla es correcta respecto de la
compleción: si el árbol SLD de A es **finito y sin éxitos**, entonces
$\mathrm{comp}(P) \models \lnot A$ (Nilsson y Małuszyński, apartados 4.2 y
4.3). La **resolución SLDNF** combina los pasos SLD con esa regla: un literal
$\lnot A$ elegido se cumple si A falla finitamente, y falla si A tiene una
refutación.

### Una regla de selección segura

La corrección de SLDNF exige que un literal negado se elija solo cuando **no
tiene variables**: `\+ pinguino(X)` con X libre pregunta si no se puede
probar que algo es un pingüino, no si X no lo es
([sección 10.3](../capitulo-10-negacion-como-falla/index.md#103-por-que-no-es-la-negacion-de-la-logica)). Prolog elige siempre el primer literal, y no
verifica esa condición. `vuela_mal/1` tiene los objetivos de `vuela/1` en el
otro orden:

<!-- ejemplo: capitulo-38/sld.pl predicado: vuela_mal/1 -->
```prolog
%!  vuela_mal(+X) is semidet.
%
%   vuela/1 con los objetivos al revés: con X libre, la negación se evalúa
%   antes de ligarla, y la consulta falla.
vuela_mal(X) :-
    \+ pinguino(X),
    ave(X).
```

```prolog
?- vuela_mal(X).
false.
```

La respuesta es incorrecta: la compleción dice que piolín vuela. `sldnf_de/2`
elige el primer literal **seguro**: un átomo, o una negación sin variables.
Si solo quedan negaciones con variables, la derivación no puede seguir, y
lanza un error de instanciación; el nombre de esa situación en la
bibliografía es *floundering*:

<!-- ejemplo: capitulo-38/sld.pl predicado: sldnf_de/2 seguro/1 resolver/4 -->
```prolog
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
```

```prolog
?- sldnf(aves, [vuela_mal(X)]).
X = piolin ;
false.

?- sldnf(aves, [\+ pinguino(X)]).
ERROR: Arguments are not sufficiently instantiated
```

Con `vuela_mal(X)`, la regla segura deja la negación para después de
`ave(X)`, y la respuesta es la de la compleción. Decidir antes de ejecutar
si un literal negado llegará sin variables no es posible en general. Una
condición suficiente es que el programa y la consulta sean **permitidos**
—que cada variable de una cláusula aparezca en un literal positivo de su
cuerpo— y que la regla de selección sea segura. `vuela/1` y `vuela_mal/1`
son los dos permitidos; la diferencia está en la regla: la de Prolog elige
la negación de `vuela_mal/1` antes de que `ave(X)` ligue X.

### Un predicado definido por su propia negación

La compleción puede ser contradictoria. El programa `circular` de
`semantica.pl` tiene cuatro predicados con negación:

<!-- ejemplo: capitulo-38/semantica.pl predicado: p/0 q/0 r/0 s/0 -->
```prolog
%!  p is semidet.
%
%   p se cumple si q no se cumple.
p :-
    \+ q.

%!  q is semidet.
%
%   q se cumple si p no se cumple.
q :-
    \+ p.

%!  r is semidet.
%
%   r se cumple si r no se cumple: Prolog no termina.
r :-
    \+ r.

%!  s is semidet.
%
%   s se cumple si t, que no tiene cláusulas, no se cumple.
s :-
    \+ t.
```

La compleción de `r/0` es $r \leftrightarrow \lnot r$, que ninguna
interpretación satisface: comp(P) no tiene modelos, y de ella se deduce
cualquier cosa. En Prolog, `r` se llama a sí misma a través de `\+` y agota
la pila; `p` también, a través de `q`. La compleción de `p` y `q`,
$p \leftrightarrow \lnot q$ y $q \leftrightarrow \lnot p$, no es
contradictoria, pero tiene dos modelos, uno con p y otro con q, y no decide
entre ellos. Las dos secciones siguientes dan dos respuestas a qué significan
estos programas: la estratificación los excluye, y la semántica bien fundada
les asigna un tercer valor.
