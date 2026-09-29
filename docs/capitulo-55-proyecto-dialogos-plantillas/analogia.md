# ANALOGY

Esta página contiene la sección
[55.7](index.md#557-analogy-analogias-geometricas) del
[capítulo 54](index.md): el programa que resuelve analogías geométricas,
`analogia.pl`. El archivo está en `ejemplos/capitulo-55/`, con sus pruebas;
no es un módulo ni carga otros archivos, y corre en SWISH.

## ANALOGY: analogías geométricas

Un problema de analogía muestra tres diagramas, A, B y C, y una lista de
respuestas, y pregunta: «A es a B como C es a cuál». Evans resolvía el
problema en tres pasos: encontrar una operación que convierte A en B,
aplicarla a C y buscar el resultado entre las respuestas. En la
reconstrucción de Sterling y Shapiro los tres pasos son tres objetivos de
una sola cláusula, y los dos primeros llaman al mismo predicado: el primero,
con los dos diagramas, encuentra la operación; el segundo, con la operación y
un diagrama, construye el otro.

**Los diagramas.** Una figura es un átomo (`circulo`, `cuadrado`,
`triangulo`, `rombo`), y un diagrama es una figura o una relación entre dos
diagramas: `dentro(A, B)` es A dentro de B, y `encima(A, B)`, A encima de B.
Sterling y Shapiro advierten que la representación hace buena parte del
trabajo: el programa original de Evans recibía dibujos de líneas y tenía que
reconocer en ellos los triángulos y los cuadrados, que aquí vienen dados.

**Las operaciones.** `transformacion(Op, D1, D2)` dice que la operación `Op`
convierte `D1` en `D2`. `partes/4` separa una relación en su nombre y sus
dos partes con `=..`, de la
[sección 32.3](../capitulo-32-inspeccion-de-terminos/index.md#323-y-compound_name_arguments3),
y sirve en los dos sentidos: separa un diagrama dado y construye uno nuevo.
Cada operación exige que el diagrama cambie, para que una sucesión de
operaciones no contenga pasos vacíos:

<!-- ejemplo: capitulo-55/analogia.pl predicado: partes/4 transformacion/3 -->
```prolog
%!  partes(?D, ?R, ?A, ?B) is semidet.
%
%   El diagrama D es la relación R entre A y B. Con D instanciado o con R
%   instanciado.
partes(D, R, A, B) :-
    relacion(R),
    D =.. [R, A, B].

%!  transformacion(?Op, +D1, ?D2) is nondet.
%
%   La operación Op convierte el diagrama D1 en el diagrama D2, distinto
%   de D1: invertir intercambia las dos partes de una relación;
%   relacion(R) cambia la relación por R; interior(F) y exterior(F)
%   reemplazan la primera o la segunda parte por la figura F; quitar_
%   exterior deja la primera parte sola; y cambiar(F) reemplaza una figura
%   por la figura F.
transformacion(invertir, D1, D2) :-
    partes(D1, R, A, B),
    A \== B,
    partes(D2, R, B, A).
transformacion(relacion(R2), D1, D2) :-
    partes(D1, R1, A, B),
    relacion(R2),
    R2 \== R1,
    partes(D2, R2, A, B).
transformacion(interior(F), D1, D2) :-
    partes(D1, R, A, B),
    figura(F),
    F \== A,
    partes(D2, R, F, B).
transformacion(exterior(F), D1, D2) :-
    partes(D1, R, A, B),
    figura(F),
    F \== B,
    partes(D2, R, A, F).
transformacion(quitar_exterior, D1, A) :-
    partes(D1, _, A, _).
transformacion(cambiar(F), F0, F) :-
    figura(F0),
    figura(F),
    F \== F0.
```

```prolog
?- transformacion(Op, dentro(cuadrado, triangulo), dentro(triangulo, cuadrado)).
Op = invertir ;
false.

?- transformacion(invertir, dentro(circulo, cuadrado), D).
D = dentro(cuadrado, circulo) ;
false.
```

En la primera consulta los dos diagramas están dados y la operación es la
incógnita; en la segunda, la incógnita es el diagrama. `interior(F)` también
convierte el primer diagrama en el segundo, pero solo si cambia la figura
interior, y aquí las dos cambian: hace falta una sucesión de dos operaciones.

**Sucesiones de operaciones.** `transforma/3` aplica una lista de
operaciones en orden. `analogia/4` busca la sucesión más corta con
`length/2` y `between/3`, la profundización iterativa de la
[sección 40.4](../capitulo-40-busqueda-y-planificacion/index.md#404-profundidad-limitada-y-profundizacion-iterativa):
primero todas las operaciones sueltas, después los pares, después las
ternas. La sucesión más corta es la explicación más simple de lo que pasa
entre A y B, y el corte final se queda con la primera que lleva a una de las
respuestas:

<!-- ejemplo: capitulo-55/analogia.pl predicado: transforma/3 analogia/4 -->
```prolog
%!  transforma(?Ops:list, +D0, ?D) is nondet.
%
%   Las operaciones Ops, aplicadas en orden, convierten D0 en D.
transforma([], D, D).
transforma([Op|Ops], D0, D) :-
    transformacion(Op, D0, D1),
    transforma(Ops, D1, D).

%!  analogia(+Par1, +Par2, +Respuestas:list, -Ops:list) is semidet.
%
%   Como analogia/3; Ops son las operaciones que la explican.
analogia(A es_a B, C es_a X, Respuestas, Ops) :-
    between(1, 3, N),
    length(Ops, N),
    transforma(Ops, A, B),
    transforma(Ops, C, X),
    memberchk(X, Respuestas),
    !.
```

`Ops` tiene que llegar libre: con una lista dada, el corte no elige nada.
El problema de la figura 14.5 de Sterling y Shapiro, escrito con los nombres
del capítulo, es `problema(invertir, …)`:

```prolog
?- resolver(invertir, N, Ops).
N = 2,
Ops = [invertir].

?- resolver(quitar, N, Ops).
N = 2,
Ops = [quitar_exterior].

?- resolver(sin_respuesta, N, Ops).
false.
```

**Dos lecturas.** Entre `dentro(circulo, cuadrado)` y
`dentro(cuadrado, circulo)` hay dos explicaciones: invertir, o reemplazar la
figura interior por un cuadrado y la exterior por un círculo. Aplicadas a
`dentro(triangulo, rombo)` dan respuestas distintas, `dentro(rombo,
triangulo)` y `dentro(cuadrado, circulo)`. `analogia/4` prefiere la más
corta, pero solo entre las que llevan a alguna respuesta de la lista:

```prolog
?- resolver(dos_lecturas, N, Ops).
N = 2,
Ops = [invertir].

?- analogia(dentro(circulo, cuadrado) es_a dentro(cuadrado, circulo), dentro(triangulo, rombo) es_a X, [dentro(cuadrado, circulo)], Ops).
X = dentro(cuadrado, circulo),
Ops = [interior(cuadrado), exterior(circulo)].
```

Las respuestas que se ofrecen deciden qué explicación se usa. Evans resolvía
el conflicto de otro modo: entre las reglas que explican el paso de A a B,
prefería la que conservaba más detalle.

!!! question "Actividad"
    Predecir qué responde `resolver(dos_pasos, N, Ops)` si la lista de
    respuestas de ese problema se reordena para que
    `encima(circulo, rombo)` quede última, y si se quita
    `encima(rombo, circulo)`. Comprobarlo con `analogia/4`, y explicar cada
    resultado con el orden en que `transforma/3` genera las sucesiones de
    dos operaciones.
