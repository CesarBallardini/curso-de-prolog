# Otras formas de inducir

Esta página contiene la sección
[67.7](index.md#677-version-6-otras-formas-de-inducir) del
[capítulo 67](index.md): las partes del capítulo «Inductive reasoning» de
Flach que las versiones 1 a 5 no cubren. La inducción planteada como
abducción, la búsqueda descendente incremental del sistema MIS de
Shapiro, que retira la cláusula falsa de la prueba de un negativo, los
tipos que permiten aprender relaciones entre listas, y el aprendizaje de
un programa con acumulador. Los ejemplos están en `abductiva.pl`, `mis.pl`
y `acumulador.pl`, en `ejemplos/capitulo-67/`, con sus pruebas; se
ejecutan localmente.

## La inducción como abducción

El metaintérprete abductivo del
[capítulo 49](../capitulo-49-proyecto-diagnostico-abduccion/index.md)
supone hechos para probar una observación. Flach abre su capítulo con
una variante que supone **cláusulas**: para probar un objetivo usa un
hecho del fondo, una cláusula que ya supuso, o una cláusula nueva de una
lista de cláusulas posibles, que agrega a la hipótesis y cuyo cuerpo
prueba a continuación. Las cláusulas posibles para `abuelo/2` son las
ocho que combinan `varon(A)`, `padre(A, C)` y `progenitor(C, B)`, de la
más larga a la vacía:

<!-- ejemplo: capitulo-67/abductiva.pl predicado: inducir/5 -->
```prolog
%!  inducir(+Meta, +Inducibles:list, +Fondo:list, +H0:list, -H:list)
%!      is nondet.
%
%   Meta se prueba con los hechos de Fondo, las cláusulas de H0 y las de
%   Inducibles; H es H0 con las cláusulas de Inducibles que la prueba
%   supone, instanciadas. Una respuesta por cada prueba.
inducir(Meta, _, Fondo, H, H) :-
    member(Meta, Fondo).
inducir(Meta, Inducibles, Fondo, H0, H) :-
    member((Meta :- Cuerpo), H0),
    inducir_cuerpo(Cuerpo, Inducibles, Fondo, H0, H).
inducir(Meta, Inducibles, Fondo, H0, H) :-
    member(R, Inducibles),
    copy_term(R, (Meta :- Cuerpo)),
    \+ ( member(C, H0),
         C =@= (Meta :- Cuerpo) ),
    inducir_cuerpo(Cuerpo, Inducibles, Fondo, [(Meta :- Cuerpo)|H0], H).
```

La cláusula supuesta queda instanciada con el ejemplo: es una
**explicación** de ese ejemplo, no una regla.

```prolog
?- inducir(abuelo(juan, luis), [(abuelo(A, B) :- [padre(A, C), progenitor(C, B)])], [padre(juan, pedro), progenitor(pedro, luis)], [], H).
H = [(abuelo(juan, luis):-[padre(juan, pedro), progenitor(pedro, luis)])] ;
false.

?- explicaciones(abuelo(juan, luis), abuelo, Cs), length(Cs, N).
Cs = [(abuelo(juan, luis):-[varon(juan), padre(juan, pedro), progenitor(pedro, luis)]), (abuelo(juan, luis):-[varon(juan), padre(juan, ana)]), (abuelo(juan, luis):-[varon(juan), padre(juan, pedro)]), (abuelo(juan, luis):-[varon(juan), progenitor(pedro, luis)]), (abuelo(juan, luis):-[varon(juan)]), (abuelo(juan, luis):-[padre(juan, pedro), progenitor(..., ...)]), (abuelo(juan, luis):-[padre(..., ...)]), (abuelo(..., ...):-[...]), (... :- ...)|...],
N = 10.
```

Hay diez explicaciones distintas de un solo ejemplo, porque cada
cláusula posible que se cumple da una, y `padre(A, C)` sin el eslabón
siguiente se cumple con los dos hijos de juan. Para obtener una regla,
Flach propone dos caminos: procesar todos los ejemplos a la vez con
cláusulas sin instanciar (el
[ejercicio 12](index.md#ejercicios)), o **generalizar** las
explicaciones. El segundo ya está escrito: es la lgg de cláusulas de la
[sección 67.3](index.md#673-version-2-subsuncion-y-lgg-de-clausulas).
`explicaciones_comunes/3` explica dos ejemplos con la misma cláusula
posible y devuelve la lgg de las dos explicaciones:

<!-- ejemplo: capitulo-67/abductiva.pl predicado: explicaciones_comunes/3 -->
```prolog
%!  explicaciones_comunes(+E1, +E2, -C) is nondet.
%
%   C es la lgg de una explicación de E1 y una de E2 que salen de la misma
%   cláusula posible: una regla que explica a los dos. Una respuesta por
%   cada cláusula posible que explica a los dos ejemplos.
explicaciones_comunes(E1, E2, C) :-
    functor(E1, Relacion, _),
    inducibles(Relacion, Is),
    modelo_fondo(M),
    member(R, Is),
    once(inducir(E1, [R], M, [], [C1])),
    once(inducir(E2, [R], M, [], [C2])),
    lgg_clausula(C1, C2, C).
```

```prolog
?- aggregate_all(count, explicaciones_comunes(abuelo(juan, luis), abuelo(pedro, sofia), _), N).
N = 8.
```

Las ocho cláusulas posibles explican a los dos abuelos, desde la regla
esperada hasta `abuelo(_, _)`, y nada las distingue: sin ejemplos
negativos, la abducción no tiene con qué rechazar las más generales. Por
eso Flach abandona este planteo, que además exige enumerar de antemano
todas las cláusulas posibles, y pasa a buscar en el espacio ordenado por
la θ-subsunción, como las versiones 3 a 5.

## Tipos y términos

El lenguaje de la versión 4 tiene literales cuyos argumentos son
variables de la cláusula. No puede escribir `append([X|Xs], Ys,
[X|Zs])`: le faltan los términos. Flach agrega un segundo tipo de
refinamiento, reemplazar una variable por un término, y **tipos** que
dicen qué términos y qué variables van en cada lugar. En `mis.pl`, cada
nodo de la búsqueda es `n(Clausula, Tipos)`, con la lista de las
variables de la cláusula envueltas en su tipo, `elemento(X)` o
`lista(Y)`, y cada problema declara sus literales y sus términos:

<!-- ejemplo: capitulo-67/mis.pl predicado: literal/3 termino/3 -->
```prolog
% literal(P, L, Ts): en el problema P se puede usar el literal L, con los
% tipos Ts para sus variables.
literal(concatenar, append(X, Y, Z), [lista(X), lista(Y), lista(Z)]).
literal(numerales, listnum(X, Y), [lista(X), lista(Y)]).
literal(numerales, num(X, Y), [elemento(X), elemento(Y)]).

% termino(P, T, Ts): en el problema P, una variable de tipo T se puede
% reemplazar por el término de T, con los tipos Ts para sus variables.
termino(_, lista([]), []).
termino(_, lista([X|Y]), [elemento(X), lista(Y)]).
```

Un refinamiento agrega un literal, une dos variables del mismo tipo, o
reemplaza una variable de tipo lista por `[]` o por `[X|Y]`, con dos
variables nuevas de sus tipos. El literal agregado usa algunas de las
variables de la cláusula, no todas: la restricción de Flach que excluye
las tautologías, como `append(X, Y, Z) :- append(X, Y, Z)`.

<!-- ejemplo: capitulo-67/mis.pl predicado: refinar_tipado/3 -->
```prolog
%!  refinar_tipado(+P, +Nodo0, -Nodo) is nondet.
%
%   Nodo0 y Nodo son términos n(Clausula, Tipos), con Tipos la lista de
%   las variables de la cláusula con su tipo. Nodo es un refinamiento de
%   Nodo0 en el lenguaje de P, en este orden: un literal más con algunas
%   de las variables de la cláusula, dos variables del mismo tipo unidas,
%   o una variable reemplazada por un término de su tipo. Nodo0 no queda
%   ligado.
refinar_tipado(P, Nodo0, n((H :- B), Ts)) :-
    copy_term(Nodo0, n((H :- B0), Ts)),
    literal(P, L, TsL),
    length(TsL, NL),
    length(Ts, N),
    NL < N,
    elegir_variables(TsL, Ts),
    L \== H,
    \+ ( member(Otro, B0),
         Otro == L ),
    append(B0, [L], B).
refinar_tipado(_, Nodo0, n(C, Ts)) :-
    copy_term(Nodo0, n(C, Ts0)),
    append(Antes, [T|Despues], Ts0),
    append(Medio, [T2|Final], Despues),
    T =.. [Tipo, X],
    T2 =.. [Tipo, Y],
    X = Y,
    append([Antes, [T|Medio], Final], Ts).
refinar_tipado(P, Nodo0, n(C, Ts)) :-
    copy_term(Nodo0, n(C, Ts0)),
    select(T, Ts0, Resto),
    termino(P, T, TsNuevos),
    append(Resto, TsNuevos, Ts).
```

```prolog
?- aggregate_all(count, refinar_tipado(concatenar, n((append(X, Y, Z) :- []), [lista(X), lista(Y), lista(Z)]), _), N).
N = 9.
```

La cláusula más general de `append/3` tiene nueve refinamientos: tres
uniones de dos variables y seis reemplazos, ninguno por un literal,
porque `append/3` usaría las tres variables de la cabeza. Los tipos
podan: `num(X, Y)`, con dos elementos, solo admite `num(X, X)`.

## Refutar la cláusula falsa

La versión 4 recibe todos los ejemplos juntos. El sistema MIS de
Shapiro, que Flach reproduce, los recibe **de a uno** y mantiene una
hipótesis que corrige:

- si un positivo no se deduce de la hipótesis, busca con profundidad
  creciente una cláusula que lo cubra en forma extensional y que no
  cubra ningún negativo visto, y la agrega;
- si un negativo se deduce, la hipótesis tiene al menos una cláusula
  falsa: la busca en la prueba del negativo y la quita.

Después de cada cambio vuelve a procesar todos los ejemplos vistos, del
más reciente al más antiguo, porque quitar una cláusula puede dejar
positivos sin cubrir. La prueba se hace en forma intensional, con un
intérprete con límite de profundidad, como el de la
[sección 67.6](recursion.md#una-definicion-recursiva), que además
devuelve el árbol de la prueba:

<!-- ejemplo: capitulo-67/mis.pl predicado: probar_arbol/5 -->
```prolog
%!  probar_arbol(+D:integer, +P, +H:list, +Meta, -Arbol) is nondet.
%
%   Meta se deduce de las cláusulas de H y de los hechos de fondo de P con
%   a lo sumo D pasos con cláusulas de H; Arbol es la prueba: fondo(Meta)
%   o regla(Meta, C, Hijos), con C la cláusula usada.
probar_arbol(_, P, _, Meta, fondo(Meta)) :-
    fondo(P, Meta).
probar_arbol(D, P, H, Meta, regla(Meta, C, Hijos)) :-
    D > 0,
    D1 is D - 1,
    member(C, H),
    copy_term(C, (Meta :- Cuerpo)),
    maplist(probar_arbol(D1, P, H), Cuerpo, Hijos).
```

Una cláusula es **falsa** en una prueba si su cabeza no es un ejemplo
positivo y todo su cuerpo, en esa prueba, es verdadero: hechos del fondo
o positivos. `clausula_falsa/3` recorre el árbol desde la raíz; un nodo
cuyo objetivo es un positivo no se acusa, y si ningún hijo contiene una
cláusula falsa, la cláusula del nodo es la culpable. Es la idea central
de la depuración algorítmica de Shapiro: el error está en la cláusula
más alta que deriva algo falso de premisas verdaderas.

<!-- ejemplo: capitulo-67/mis.pl predicado: clausula_falsa/3 primera_falsa/4 -->
```prolog
%!  clausula_falsa(+Arbol, +Vistos:list, -X) is det.
%
%   X es una cláusula de la prueba Arbol que es falsa: su cuerpo, en esa
%   prueba, tiene solo hechos de fondo y positivos de Vistos, y su cabeza
%   no es un positivo. X es ok si la prueba no tiene una.
clausula_falsa(fondo(_), _, ok).
clausula_falsa(regla(Meta, C, Hijos), Vistos, X) :-
    (   memberchk(pos(Meta), Vistos)
    ->  X = ok
    ;   foldl(primera_falsa(Vistos), Hijos, ok, X0),
        (   X0 == ok
        ->  X = C
        ;   X = X0
        )
    ).

%!  primera_falsa(+Vistos:list, +Arbol, +X0, -X) is det.
%
%   X es X0 si ya es una cláusula falsa; si no, la de Arbol.
primera_falsa(Vistos, Arbol, X0, X) :-
    (   X0 == ok
    ->  clausula_falsa(Arbol, Vistos, X)
    ;   X = X0
    ).
```

El ciclo de los ejemplos:

<!-- ejemplo: capitulo-67/mis.pl predicado: procesar/7 procesar_uno/7 -->
```prolog
%!  procesar(+P, +Ejs:list, +Vistos:list, +H0:list, -H:list,
%!           -Traza:list, ?Resto:list) is semidet.
%
%   Procesa los ejemplos Ejs con la hipótesis H0, después de los Vistos
%   (el más reciente primero). Traza-Resto es la lista de los cambios.
procesar(_, [], _, H, H, T, T).
procesar(P, [Ej|Ejs], Vistos, H0, H, T0, T) :-
    procesar_uno(P, Ej, Vistos, H0, H1, T0, T1),
    procesar(P, Ejs, [Ej|Vistos], H1, H, T1, T).

%!  procesar_uno(+P, +Ej, +Vistos:list, +H0:list, -H:list, -Traza:list,
%!               ?Resto:list) is semidet.
%
%   H es la hipótesis después de ver Ej: igual a H0 si la clasifica bien;
%   si no, generalizada o especializada, y vuelta a probar con Ej y todos
%   los ejemplos vistos, del más reciente al más antiguo.
procesar_uno(P, pos(E), Vistos, H0, H, T0, T) :-
    (   deducido(P, H0, E)
    ->  H = H0,
        T0 = T
    ;   buscar_tipada(P, E, [pos(E)|Vistos], 4, C, _),
        T0 = [agregada(C)|T1],
        procesar(P, [pos(E)|Vistos], [], [C|H0], H, T1, T)
    ).
procesar_uno(P, neg(E), Vistos, H0, H, T0, T) :-
    (   once(probar_arbol(10, P, H0, E, Arbol))
    ->  clausula_falsa(Arbol, Vistos, C),
        C \== ok,
        once(select(C, H0, H1)),
        T0 = [quitada(C)|T1],
        procesar(P, [neg(E)|Vistos], [], H1, H, T1, T)
    ;   H = H0,
        T0 = T
    ).
```

Los ejemplos de `concatenar` son tres positivos y cuatro negativos:
`append([], [c], [c])`, `append([], [c, d], [c, d])` y `append([a], [c,
d], [a, c, d])` pertenecen a la relación; `append([], [a, b], [b, a])`,
`append([a, b], [c], [c])` y dos variantes de `append([a], [c, d], [a,
c, d])` con un elemento cambiado, no. La consulta `mostrar_mis(concatenar)`
escribe:

```text
agregada: append(_, _, _).
quitada: append(_, _, _).
agregada: append(_, A, A).
quitada: append(_, A, A).
agregada: append([], A, A).
agregada: append([A|B], C, [A|D]) :-
    append(B, C, D).
Hipótesis:
append([A|B], C, [A|D]) :-
    append(B, C, D).
append([], A, A).
```

El primer positivo se explica con la cláusula más general, que afirma
que todo es la concatenación de todo. El primer negativo la refuta; la
búsqueda propone entonces `append(_, A, A)`, que el segundo negativo
refuta, y después `append([], A, A)`, que es correcta. El último
positivo necesita cuatro refinamientos —dos reemplazos, una unión y un
literal— y da la cláusula recursiva. Es el resultado de Flach, con el
mismo orden de los refinamientos: el literal primero. Con el orden de la
versión 4, que prueba antes las uniones, la búsqueda encuentra a la misma
profundidad `append([A|_], B, [A|B])`, que estos negativos no refutan.

Con `numerales`, que traduce listas de números a listas de numerales con
los hechos de fondo `num(1, uno)` a `num(4, cuatro)`, el resultado es:

```text
listnum([A|B], [C|D]) :-
    listnum(B, D),
    num(C, A).
listnum([A|B], [C|D]) :-
    listnum(B, D),
    num(A, C).
listnum([], _).
```

Dos cláusulas recursivas, una para cada sentido de la traducción, como
en Flach, y una cláusula base demasiado general: ningún negativo dice que
`listnum([], [uno])` es falso. El
[ejercicio 13](index.md#ejercicios) la corrige.

## Un programa con acumulador

La restricción de Flach —un literal del cuerpo usa menos variables que la
cabeza— excluye las tautologías, pero también los programas con
acumulador. En `reverse(L, A, R)`, R es la inversa de L seguida de A, y
la cláusula recursiva

```prolog
reverse([H|T], A, R) :-
    reverse(T, [H|A], R).
```

tiene en el cuerpo todas las variables de la cabeza. El ejercicio 9.4 de
Flach pide otra manera de excluir las tautologías que admita
`reverse/3`. La versión 3 ya tiene una: conserva los literales enlazados
con la cabeza y quita solo la cabeza misma. Con nueve positivos que
forman cadenas completas y cinco negativos, el algoritmo de cobertura de
la versión 3 aprende sin embargo otra cosa. La consulta
`aprender_reverse(rlgg, H), maplist(mostrar, H)` escribe:

```text
reverse(_, _, [A|B]) :-
    reverse([A], B, [A|B]).
```

La cláusula cubre los nueve positivos en forma extensional: para cada
uno, el cuerpo es un positivo de un solo elemento, que figura entre los
ejemplos. Es otra tautología disfrazada, como la de `hermano/2` en la
[sección 67.6](recursion.md#cuando-la-cobertura-extensional-engana): el
literal recursivo no es más chico que la cabeza. La condición que falta
es que la recursión **descienda**: el primer argumento del literal
recursivo es una parte propia del primer argumento de la cabeza.

<!-- ejemplo: capitulo-67/acumulador.pl predicado: parte_propia/2 bien_fundada/2 -->
```prolog
%!  parte_propia(@S, @T) is semidet.
%
%   S es un subtérmino de T distinto de T: un argumento de T o una parte
%   propia de uno. Se compara con ==, sin unificar.
parte_propia(S, T) :-
    compound(T),
    arg(_, T, A),
    (   A == S
    ->  true
    ;   parte_propia(S, A)
    ),
    !.

%!  bien_fundada(+H, +L) is semidet.
%
%   El literal L del cuerpo de una cláusula de cabeza H no es recursivo, o
%   lo es y su primer argumento es una parte propia del primer argumento
%   de H.
bien_fundada(H, L) :-
    (   functor(H, Nombre, Aridad),
        functor(L, Nombre, Aridad)
    ->  arg(1, H, X),
        arg(1, L, Y),
        parte_propia(Y, X)
    ;   true
    ).
```

Con esa condición aplicada a la rlgg antes de reducirla, la consulta
`aprender_reverse(rlgg_bien_fundada, H), maplist(mostrar, H)` escribe:

```text
reverse([A|B], C, [D|E]) :-
    reverse(B, [A|C], [D|E]).
reverse([], [A|B], [A|B]).
```

Es el programa con acumulador, con una diferencia que Flach señala en su
respuesta al ejercicio: el tercer argumento es siempre una lista no
vacía, porque así son todos los ejemplos. Por la misma razón el caso
base exige un acumulador no vacío, y la lista vacía no se invierte:

```prolog
?- aprender_reverse(rlgg_bien_fundada, H), invertir(H, [1, 2, 3, 4], R).
H = [(reverse([_A|_B], _C, [_D|_E]):-[reverse(_B, [_A|_C], [_D|_E])]), (reverse([], [_F|_G], [_F|_G]):-[])],
R = [4, 3, 2, 1] ;
false.

?- aprender_reverse(rlgg_bien_fundada, H), invertir(H, [], R).
false.
```

!!! question "Actividad"
    Agregar a los ejemplos de `ejemplos_reverse/2` el positivo
    `reverse([], [], [])` y predecir qué cláusula base aprende
    `aprender_reverse(rlgg_bien_fundada, H)`. Comprobarlo, y verificar
    con `invertir/3` si la lista vacía se invierte.
