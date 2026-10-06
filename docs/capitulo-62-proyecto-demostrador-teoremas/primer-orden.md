# La lógica de predicados

Esta página contiene las secciones
[62.6](index.md#626-version-5-la-forma-clausal-de-la-logica-de-predicados) y
[62.7](index.md#627-version-6-resolucion-con-variables) del
[capítulo 62](index.md): la versión 5, `primer_orden.pl`, que completa la
forma clausal con los pasos que exigen los cuantificadores, y la versión 6,
`resolucion_fo.pl`, que resuelve cláusulas con variables. Los dos archivos
están en `ejemplos/capitulo-62/`, con sus pruebas, y cargan las versiones
anteriores.

## La forma clausal de la lógica de predicados

La forma normal negada de la versión 2 ya trata los cuantificadores: los
deja en su lugar y cambia cada uno por su dual cuando queda bajo una
negación. Lo que falta es quitarlos, y para eso hacen falta tres pasos.

**Una variable por cuantificador.** El lector da a cada cuantificador una
variable propia, pero la forma normal negada puede romper esa propiedad:
$A \leftrightarrow B$ se traduce a $(\lnot A \lor B) \land (A \lor \lnot
B)$, y $A$ aparece dos veces, con las mismas variables ligadas. Si una de
las dos apariciones tiene un $\exists$ y la otra un $\forall$, reemplazar
el existencial por un término de Skolem ligaría también al universal.
`renombrar/2` recorre la fórmula y, en cada cuantificador, reemplaza su
variable por una nueva en todo su alcance:

<!-- ejemplo: capitulo-62/primer_orden.pl predicado: renombrar/2 -->
```prolog
%!  renombrar(+F, -G) is det.
%
%   G es F con una variable nueva para cada cuantificador: dos
%   cuantificadores de G nunca ligan la misma variable.
renombrar(at(A), at(A)).
renombrar(no(F), no(G)) :-
    renombrar(F, G).
renombrar(y(A, B), y(RA, RB)) :-
    renombrar(A, RA),
    renombrar(B, RB).
renombrar(o(A, B), o(RA, RB)) :-
    renombrar(A, RA),
    renombrar(B, RB).
renombrar(todo(X, F), todo(Y, G)) :-
    reemplazar(X, Y, F, F1),
    renombrar(F1, G).
renombrar(existe(X, F), existe(Y, G)) :-
    reemplazar(X, Y, F, F1),
    renombrar(F1, G).
```

```prolog
?- leer_formula("(∀x p(x)) ↔ q", F), fnn(F, G).
F = sii(todo(_A, at(p(_A))), at(q)),
G = y(o(existe(_A, no(at(p(_A)))), at(q)), o(todo(_A, at(p(_A))), no(at(q)))).
```

En `G`, un $\exists$ y un $\forall$ ligan la misma variable `_A`;
`renombrar/2` les da dos distintas.

**La forma prenexa.** Con una variable distinta por cuantificador, los
cuantificadores se pueden llevar al frente sin cambiar el significado:
$(\forall x\, p(x)) \lor q$ equivale a $\forall x\, (p(x) \lor q)$
porque $x$ no aparece en $q$. `prenexa/3` separa la fórmula en la lista de
sus cuantificadores, en el orden en que aparecen, y la **matriz**, la
fórmula sin ellos:

<!-- ejemplo: capitulo-62/primer_orden.pl predicado: prenexa/3 -->
```prolog
%!  prenexa(+G, -Prefijo:list, -Matriz) is det.
%
%   Prefijo y Matriz forman la forma prenexa de G, una fórmula en forma
%   normal negada con una variable distinta por cuantificador: Prefijo es
%   la lista de los cuantificadores, todo(X) o existe(X), en el orden en
%   que aparecen de izquierda a derecha, y Matriz es G sin ellos.
prenexa(at(A), [], at(A)).
prenexa(no(A), [], no(A)).
prenexa(y(A, B), P, y(MA, MB)) :-
    prenexa(A, PA, MA),
    prenexa(B, PB, MB),
    append(PA, PB, P).
prenexa(o(A, B), P, o(MA, MB)) :-
    prenexa(A, PA, MA),
    prenexa(B, PB, MB),
    append(PA, PB, P).
prenexa(todo(X, F), [todo(X)|P], M) :-
    prenexa(F, P, M).
prenexa(existe(X, F), [existe(X)|P], M) :-
    prenexa(F, P, M).
```

**La skolemización.** Una variable existencial afirma que hay un valor, y
ese valor puede depender de las variables universales que la preceden:
en $\forall x\, \exists y\, \mathit{ama}(x, y)$, el $y$ que existe para
cada $x$ es una función de $x$. La skolemización le da un nombre nuevo a
esa función, `sk1`, y escribe $\forall x\, \mathit{ama}(x,
\mathit{sk1}(x))$. La fórmula que resulta no es equivalente a la
original, pero es satisfacible si y solo si la original lo es, y eso
alcanza para una refutación. Como la variable existencial es una variable
de Prolog, reemplazarla es ligarla:

<!-- ejemplo: capitulo-62/primer_orden.pl predicado: skolemizar/4 -->
```prolog
%!  skolemizar(+Prefijo:list, +Universales:list, +N0:integer,
%!             -N:integer) is det.
%
%   Como skolemizar/3; Universales son las variables universales ya
%   recorridas, en orden.
skolemizar([], _, N, N).
skolemizar([todo(X)|P], Us, N0, N) :-
    append(Us, [X], Us1),
    skolemizar(P, Us1, N0, N).
skolemizar([existe(X)|P], Us, N0, N) :-
    atom_concat(sk, N0, Nombre),
    (   Us == []
    ->  X = Nombre
    ;   compound_name_arguments(X, Nombre, Us)
    ),
    N1 is N0 + 1,
    skolemizar(P, Us, N1, N).
```

```prolog
?- leer_formula("∀x ∃y ∀z ∃w r(x, y, z, w)", F), prenexa(F, P, M), skolemizar(P, 1, N).
F = todo(_A, existe(sk1(_A), todo(_B, existe(sk2(_A, _B), at(r(_A, sk1(_A), _B, sk2(_A, _B))))))),
P = [todo(_A), existe(sk1(_A)), todo(_B), existe(sk2(_A, _B))],
M = at(r(_A, sk1(_A), _B, sk2(_A, _B))),
N = 3.
```

La ligadura alcanza a la fórmula original, a la lista de cuantificadores y
a la matriz, que comparten las variables: el término de Skolem aparece en
los tres. Sin los cuantificadores, las variables universales que quedan
en la matriz son variables de Prolog, y `fnc/2` de la versión 2 la pasa
a cláusulas sin cambios. `clausulas_fo/2` encadena los pasos y descarta
las cláusulas que son variantes de otra:

<!-- ejemplo: capitulo-62/primer_orden.pl predicado: clausulas_fo/2 -->
```prolog
%!  clausulas_fo(+F, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de F, una fórmula cerrada de la lógica
%   de predicados: una lista de cláusulas, ninguna tautológica, con las
%   variables universales como variables de Prolog y las existenciales
%   reemplazadas por términos de Skolem sk1, sk2…
clausulas_fo(F, Clausulas) :-
    fnn(F, G0),
    renombrar(G0, G),
    prenexa(G, Prefijo, Matriz),
    skolemizar(Prefijo, 1, _),
    fnc(Matriz, Cs),
    sin_variantes(Cs, Clausulas).
```

```prolog
?- clausulas_fo_texto("¬(∀x (hombre(x) → mortal(x)) ∧ hombre(socrates) → mortal(socrates))", Cs).
Cs = [[+mortal(_A), -hombre(_A)], [+hombre(socrates)], [-mortal(socrates)]].

?- clausulas_fo_texto("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", Cs).
Cs = [[+ama(_A, sk1(_A))], [-ama(sk2(_A, _B), _B)]].
```

En la segunda, `sk2` tiene dos argumentos, aunque el $\exists x$ de
$\exists x\, \lnot \mathit{ama}(x, y)$ está solo en el alcance de
$\forall y$: la forma prenexa lo puso después de los dos universales. El
resultado es correcto, pero los términos de Skolem más grandes hacen más
difícil la unificación. El apéndice de Clocksin y Mellish skolemiza antes
de sacar los cuantificadores, con solo los universales que rodean al
existencial; el [ejercicio 8](index.md#ejercicios) lo hace.

## Resolución con variables

Dos cláusulas con variables se resuelven como en la versión 3, con dos
diferencias. Primero, sus variables se **renombran**: las cláusulas están
cuantificadas universalmente cada una por su lado, y la `X` de una no
tiene nada que ver con la `X` de la otra. `copy_term/2` hace el renombrado
antes de cada paso, y así la misma cláusula se puede usar varias veces con
valores distintos. Segundo, los dos literales opuestos no tienen que ser
iguales, sino **unificables**, y el unificador se aplica al resto de las
dos cláusulas:

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: resolvente_fo/4 opuestos/3 -->
```prolog
%!  resolvente_fo(+Unificar, +C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de copias de C1 y C2 sin variables comunes: un
%   literal de una y el opuesto de un literal de la otra se unifican con
%   Unificar, y R reúne los demás, sin repetidos.
resolvente_fo(U, C1, C2, R) :-
    copy_term(C1, D1),
    copy_term(C2, D2),
    select(L1, D1, R1),
    select(L2, D2, R2),
    opuestos(L1, L2, U),
    append(R1, R2, R0),
    sort(R0, R).

%!  opuestos(+L1, +L2, +Unificar) is semidet.
%
%   L1 y L2 tienen signos opuestos y Unificar unifica sus fórmulas. L1 va
%   primero para que la indexación por su signo elija una sola cláusula.
opuestos(+A, -B, U) :-
    call(U, A, B).
opuestos(-A, +B, U) :-
    call(U, A, B).
```

El primer argumento de `resolvente_fo/4` es el predicado que unifica, para
poder medir qué pasa sin la comprobación de ocurrencia. `opuestos/3` lo
recibe en el último lugar: su primer argumento es el literal, y la
indexación por el signo elige una sola cláusula, sin dejar alternativas
pendientes. `demostrar_fo/3` usa
`unify_with_occurs_check/2`:

```prolog
?- demostrar_fo("∀x (hombre(x) → mortal(x)) ∧ hombre(socrates) → mortal(socrates)", 5, P), escribir_prueba(P).
  1.  mortal(A) ∨ ¬hombre(A)          premisa
  2.  hombre(socrates)                premisa
  3.  ¬mortal(socrates)               premisa
  4.  mortal(socrates)                resolvente de 1 y 2
  5.  □                               resolvente de 3 y 4
P = prueba([[+mortal(_A), -hombre(_A)], [+hombre(socrates)], [-mortal(socrates)]], [r(1, 2, [+mortal(socrates)]), r(3, 4, [])]).
```

### La comprobación de ocurrencia

$\forall x\, \exists y\, \mathit{ama}(x, y)$ —cada uno ama a alguien— no
implica $\exists y\, \forall x\, \mathit{ama}(x, y)$ —hay alguien a
quien todos aman—. Las dos cláusulas de la negación, calculadas arriba,
son `ama(A, sk1(A))` y `¬ama(sk2(A, B), B)`. Para resolverlas, `A` debería
ser `sk2(A, B)` y `B` debería ser `sk1(A)`: `A` tendría que contenerse a
sí misma. La unificación de Prolog, sin la comprobación, acepta ese
término cíclico:

<!-- ejemplo: capitulo-62/verificador.pl predicado: opuestos/2 -->
```prolog
%!  opuestos(+L1, +L2) is semidet.
%
%   L1 y L2 tienen signos opuestos y sus fórmulas atómicas unifican, con
%   la comprobación de ocurrencia.
opuestos(+A, -B) :-
    unify_with_occurs_check(A, B).
opuestos(-A, +B) :-
    unify_with_occurs_check(A, B).
```

```prolog
?- ama(X, sk1(X)) = ama(sk2(Z, Y), Y).
X = sk2(Z, sk1(X)),
Y = sk1(X).

?- unify_with_occurs_check(ama(X, sk1(X)), ama(sk2(Z, Y), Y)).
false.
```

Con `=` como unificación, el demostrador encuentra una «refutación» de un
paso de una fórmula que no es un teorema; el verificador, que unifica con
la comprobación, la rechaza:

```prolog
?- verificar(prueba([[+ama(X, sk1(X))], [-ama(sk2(Z, Y), Y)]], [r(1, 2, [])])).
false.
```

`refutar_con/4` recibe la unificación como una de sus opciones, que la
sección sobre la estrategia lineal describe:

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: refutar_con/4 -->
```prolog
%!  refutar_con(+Opciones, +Clausulas:list, +Max:integer, -Pasos:list)
%!      is semidet.
%
%   Como refutar_fo/3, con las Opciones opciones(Estrategia, Filtro,
%   Unificar, Factorizar). Estrategia es general (cada paso usa dos
%   cláusulas cualesquiera) o lineal (desde el segundo paso, cada uno usa
%   la cláusula que agregó el anterior). Filtro es repetida (se descarta
%   un resolvente que es una variante de una cláusula anterior) o
%   subsumida (se descarta si una cláusula anterior lo subsume). Unificar
%   es el predicado que unifica los literales, y Factorizar es si o no.
refutar_con(Opciones, Clausulas, Max, Pasos) :-
    between(0, Max, N),
    length(Pasos, N),
    derivar(Opciones, Pasos, Clausulas, ninguna),
    !.
```

```prolog
?- clausulas_fo_texto("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", Cs), refutar_con(opciones(lineal, repetida, =, si), Cs, 5, P).
Cs = [[+ama(_A, sk1(_A))], [-ama(sk2(_A, _B), _B)]],
P = [r(1, 2, [])].

?- demostrar_fo("(∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y)", 8, P).
false.
```

En la unificación de Prolog la comprobación de ocurrencia se omite por
eficiencia
([sección 34.2](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#342-de-append3-a-la-lista-diferencia)),
y un programa correcto rara vez la necesita. Un demostrador la necesita
siempre: los términos de Skolem producen exactamente las ecuaciones que
la omisión resuelve mal.

### La factorización

La paradoja del barbero afirma que hay alguien que afeita exactamente a
quienes no se afeitan a sí mismos. Su forma clausal tiene dos cláusulas de
dos literales:

```prolog
?- clausulas_fo_texto("∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", Cs).
Cs = [[-afeita(_A, _A), -afeita(sk1, _A)], [+afeita(_B, _B), +afeita(sk1, _B)]].
```

Cada resolvente de dos cláusulas de dos literales tiene, en general, dos
literales, y cada resolvente de estas dos es una tautología. La
resolución de a dos literales, sola, no llega a la cláusula vacía:

```prolog
?- clausulas_fo_texto("∃x ∀y (afeita(x, y) ↔ ¬afeita(y, y))", Cs), refutar_con(opciones(general, repetida, unify_with_occurs_check, no), Cs, 6, P).
false.
```

La **factorización** une dos literales del mismo signo de una cláusula
cuando unifican: con `A = sk1`, los dos literales de la primera cláusula
son `¬afeita(sk1, sk1)`, y la cláusula se reduce a uno solo. Es el paso
`f(I, R)` de la prueba del comienzo del capítulo, y con él la refutación
tiene tres pasos:

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: factor/3 -->
```prolog
%!  factor(+Unificar, +C:list, -R:list) is nondet.
%
%   R es un factor de una copia de C: dos literales del mismo signo se
%   unifican con Unificar, y quedan como uno solo.
factor(U, C, R) :-
    copy_term(C, D),
    select(L1, D, D1),
    member(L2, D1),
    mismo_signo(L1, L2),
    call(U, L1, L2),
    sort(D1, R).
```

La resolución con factorización es **completa para la refutación**: si un
conjunto de cláusulas es insatisfacible, hay una refutación. Con la
profundización iterativa, el demostrador la encuentra. La completitud no
alcanza a los no teoremas: si la fórmula no es un teorema, puede haber
infinitos resolventes nuevos, cada uno con términos de Skolem más
grandes, y la búsqueda sin máximo no termina. La lógica de predicados es
**semidecidible**, y el máximo de `demostrar_fo/3` es la manera explícita
de aceptarlo.

### La estrategia lineal

La profundización iterativa examina todas las listas de pasos de cada
longitud, y una misma prueba aparece en muchos órdenes: dos pasos
independientes se pueden hacer en cualquier orden. La **estrategia
lineal** exige que, desde el segundo paso, cada uno use la cláusula que
agregó el anterior, el **centro**; la otra puede ser cualquier cláusula
anterior, una de las iniciales o un centro de antes. La resolución lineal
sigue siendo completa, como demostró Loveland
([Referencias](index.md#referencias)), y cada prueba tiene menos órdenes
posibles.
`derivar/4` lleva el número del centro, y `centro/3` decide qué cláusula
debe usar el paso:

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: derivar/4 centro/3 -->
```prolog
%!  derivar(+Opciones, ?Pasos:list, +Clausulas:list, +Centro) is nondet.
%
%   Pasos, una lista de longitud conocida, lleva de Clausulas a una lista
%   que contiene la cláusula vacía. Centro es el número de la cláusula
%   que agregó el paso anterior, o ninguna antes del primero.
derivar(_, [], Clausulas, _) :-
    memberchk([], Clausulas).
derivar(Opciones, [Paso|Pasos], Clausulas, Centro) :-
    paso(Opciones, Clausulas, Centro, Paso, R),
    \+ tautologica(R),
    \+ redundante(Opciones, R, Clausulas),
    append(Clausulas, [R], Clausulas1),
    length(Clausulas1, Centro1),
    derivar(Opciones, Pasos, Clausulas1, Centro1).

%!  centro(+Estrategia, +Centro, -J) is det.
%
%   J es la cláusula que el paso debe usar: libre con la estrategia
%   general o en el primer paso, y Centro en los demás pasos lineales.
centro(general, _, _).
centro(lineal, ninguna, _) :-
    !.
centro(lineal, Centro, Centro).
```

Las opciones de `refutar_con/4`, `opciones(Estrategia, Filtro, Unificar,
Factorizar)`, permiten medir el efecto de cada una. La
tabla da las inferencias de la búsqueda para seis teoremas, con las dos
estrategias y los dos filtros, y la longitud de la refutación más corta
con cada estrategia:

| Teorema | Pasos | General, repetida | General, subsumida | Lineal, repetida | Lineal, subsumida |
|---|---|---|---|---|---|
| el barbero | 3 / 3 | 2 295 | 3 032 | 1 175 | 1 516 |
| p → q → r → s, sobre a | 4 / 4 | 39 617 | 63 315 | 4 095 | 6 012 |
| casos con dos disyuntos | 3 / 3 | 6 066 | 9 216 | 1 606 | 2 257 |
| p ∧ q por tres disyunciones | 3 / 4 | 5 770 | 7 786 | 4 177 | 5 705 |
| casos con tres disyuntos | 5 / 5 | 1 685 896 | 3 039 595 | 24 549 | 39 462 |
| el abuelo, con padre y progenitor | 5 / 5 | 1 966 159 | 3 698 925 | 27 692 | 44 428 |

La estrategia lineal reduce las inferencias entre 2 y 71 veces, y la
reducción crece con la longitud de la prueba. En un caso la prueba lineal
es un paso más larga: la más corta combina dos resolventes que no se
obtienen uno del otro. `refutar_fo/3` usa la estrategia lineal con el
filtro de las repetidas.

### La subsunción

Una cláusula C **subsume** a D si alguna sustitución convierte cada
literal de C en un literal de D: todo lo que D dice, C lo dice con más
fuerza, y D no aporta nada a una refutación. El
[capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/soluciones.md#8)
midió la subsunción en la lógica proposicional y dejó pendiente su
efecto cuando las cláusulas crecen. Rowe observa que con variables es
difícil de programar en Prolog, porque la unificación ligaría también las
variables de D. `subsume/2` congela las variables de D con `numbervars/3`,
que las reemplaza por términos sin variables, busca la sustitución, y
deshace todo con una doble negación:

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: subsume/2 -->
```prolog
%!  subsume(+C:list, +D:list) is semidet.
%
%   La cláusula C subsume a D: C no tiene más literales que D, y alguna
%   sustitución de las variables de C convierte cada literal de C en un
%   literal de D. Sin la condición sobre la cantidad, una cláusula
%   subsumiría a sus propios factores. C y D no comparten variables. Las
%   variables de D se congelan con numbervars/3, dentro de una doble
%   negación que deshace todas las ligaduras.
subsume(C, D) :-
    length(C, NC),
    length(D, ND),
    NC =< ND,
    \+ \+ ( numbervars(D, 0, _),
            subconjunto(C, D)
          ).
```

```prolog
?- subsume([+p(X, Y)], [+p(a, b), +q]).
true.

?- subsume([-p(X, X), -p(a, X)], [-p(a, a)]).
false.
```

La condición sobre la cantidad de literales no está en la definición
habitual, y su ausencia es un error que las pruebas encontraron: una
cláusula subsume a cada uno de sus factores —la segunda consulta, sin la
condición, se cumple con `X = a`—, y con ese filtro el barbero pierde su
refutación, porque el factor que la prueba necesita se descarta. La tabla
muestra además que la subsunción no ahorra trabajo en estas búsquedas: la
profundización iterativa ya encuentra la prueba más corta antes de que
las cláusulas subsumidas se acumulen, y comparar cada resolvente con
todas las cláusulas anteriores cuesta entre 1,3 y 1,9 veces más. La
saturación por niveles del [ejercicio 11](index.md#ejercicios), que agrega
todos los resolventes de cada nivel, es el lugar donde la subsunción
debería rendir, y la medición tampoco lo confirma para el principio del
palomar con 3 palomas: con el filtro llega a □ en el cuarto nivel con
257 372 inferencias, y sin él, con solo descartar las repetidas, en el
mismo nivel con 73 352. El beneficio exige conjuntos de cláusulas mucho
más grandes que los de este capítulo, donde las cláusulas descartadas
evitan más trabajo que el que cuesta encontrarlas.
