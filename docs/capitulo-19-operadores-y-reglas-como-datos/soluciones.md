# Soluciones del capítulo 19 — Operadores y reglas como datos

El código de esta página está en `ejemplos/capitulo-19/soluciones_operadores.pl`,
`ejemplos/capitulo-19/soluciones_experto.pl` y
`ejemplos/capitulo-19/soluciones_inscripciones.pl`, y pasa sus pruebas. Los
ejercicios de operadores, los del sistema experto y los del proyecto tienen su
propio archivo porque declaran operadores distintos: `y` es un operador de
precedencia 200 en el ejercicio 1 y de precedencia 780 en el 4, y en un
archivo no pueden regir las dos a la vez: una segunda declaración reemplaza a
la primera para todo lo que se lee después.

## 1

<!-- ejemplo: capitulo-19/soluciones_operadores.pl fragmento: op(300, xfx, [son, es_un]) .. op(100, fy, famoso). consulta: X = (merlin es_un famoso mago), write_canonical(X). -->
```prolog
:- op(300, xfx, [son, es_un]).
:- op(300, fx, gusta_de).
:- op(200, xfy, y).
:- op(100, fy, famoso).
```

```prolog
?- X = (merlin es_un famoso mago), write_canonical(X), nl.
es_un(merlin,famoso(mago))
X = merlin es_un famoso mago.

?- X = (ana y luis y eva son amigos), write_canonical(X), nl.
son(y(ana,y(luis,eva)),amigos)
X = ana y luis y eva son amigos.
```

| Expresión | Forma canónica |
|---|---|
| `X es_un mago` | `es_un(X, mago)` |
| `ana y luis y eva son amigos` | `son(y(ana, y(luis, eva)), amigos)` |
| `ana es_un maga y gusta_de ajedrez` | error de sintaxis |
| `merlin es_un famoso mago` | `es_un(merlin, famoso(mago))` |

`y` es `xfy`, y por eso `ana y luis y eva` se agrupa a la derecha. En la
tercera, `gusta_de ajedrez` es un término de precedencia 300, y `y`, de
precedencia 200, solo admite argumentos de precedencia menor que 200. Ninguna
lectura es válida, y SWI-Prolog informa `operator_clash`. En la cuarta,
`famoso` (100) es un prefijo `fy` de menor precedencia que `es_un` (300), y
queda como argumento derecho.

## 2

<!-- ejemplo: capitulo-19/soluciones_operadores.pl fragmento: op(800, xfx, es) .. el_auto de la_hermana de ana es rojo. consulta: X de Y es rojo. -->
```prolog
:- op(800, xfx, es).
:- op(400, yfx, de).

% X es C: X es de color C.
el_auto de la_hermana de ana es rojo.
```

```prolog
?- X es rojo.
X = el_auto de la_hermana de ana.

?- X de Y es rojo.
X = el_auto de la_hermana,
Y = ana.

?- el_auto de X es rojo.
false.
```

`de` es `yfx`: el hecho se lee `es(de(de(el_auto, la_hermana), ana), rojo)`.
`X de Y` unifica con el `de` principal, y `Y` queda ligada al último operando,
ana. `el_auto de X` falla porque el primer operando del `de` principal no es
`el_auto` sino `el_auto de la_hermana`.

Con `de` declarado `xfy`, el hecho se lee `es(de(el_auto, de(la_hermana, ana)),
rojo)`, agrupado a la derecha. `X de Y es rojo` responde entonces
`X = el_auto, Y = la_hermana de ana`, y `el_auto de X es rojo` se cumple con
`X = la_hermana de ana`. La prueba `de_como_xfy` de `soluciones_operadores.plt`
cambia la declaración, lee el mismo texto y verifica esa forma.

## 3

<!-- ejemplo: capitulo-19/soluciones_operadores.pl fragmento: op(150, fy, no) .. disyuncion(f, f, f). consulta: valor(no (v y f) implica f, V). -->
```prolog
:- op(150, fy, no).
:- op(250, xfy, o).
:- op(300, xfy, implica).

%!  valor(+Formula, -V) is det.
%
%   V es el valor de verdad, v o f, de Formula: una fórmula con las
%   constantes v y f y los operadores no, y, o e implica.
valor(v, v).
valor(f, f).
valor(no A, V) :-
    valor(A, VA),
    negacion(VA, V).
valor(A y B, V) :-
    valor(A, VA),
    valor(B, VB),
    conjuncion(VA, VB, V).
valor(A o B, V) :-
    valor(A, VA),
    valor(B, VB),
    disyuncion(VA, VB, V).
valor(A implica B, V) :-
    valor(no A o B, V).

% negacion(A, V): V es la negación de A.
negacion(v, f).
negacion(f, v).

% conjuncion(A, B, V): V es la conjunción de A y B.
conjuncion(v, v, v).
conjuncion(v, f, f).
conjuncion(f, v, f).
conjuncion(f, f, f).

% disyuncion(A, B, V): V es la disyunción de A y B.
disyuncion(v, v, v).
disyuncion(v, f, v).
disyuncion(f, v, v).
disyuncion(f, f, f).
```

```prolog
?- valor(no (v y f) implica f, V).
V = f.

?- valor(v o f y f, V).
V = v.
```

Las precedencias siguen el orden habitual de la lógica: `no` liga más que `y`,
`y` más que `o`, y `o` más que `implica`. Por eso `v o f y f` se lee
`v o (f y f)`. `y` reutiliza la declaración del ejercicio 1. `implica` se
define por su equivalencia con `no A o B`, sin una tabla propia. Cada fórmula
tiene una sola cláusula aplicable según su functor, y `valor/2` es `det`.

## 4

<!-- ejemplo: capitulo-19/soluciones_experto.pl fragmento: op(800, xfx, entonces) .. op(780, xfy, y). consulta: identificar([da_leche, come_carne, color_leonado, rayas_negras], A). -->
```prolog
:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(785, xfy, o).
:- op(780, xfy, y).
```

`o` va entre `y` (780) y `si` (790): `si a y b o c entonces d` se lee
`si ((a y b) o c) entonces d`, como en la lógica, donde la conjunción liga más
que la disyunción. Con una precedencia menor que la de `y`, la misma regla se
leería `si (a y (b o c)) entonces d`.

<!-- ejemplo: capitulo-19/soluciones_experto.pl predicado: prueba/3 consulta: identificar([da_leche, come_carne, color_leonado, rayas_negras], A). -->
```prolog
%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   El intérprete del texto, con dos cláusulas para o —una prueba de A o B
%   es una prueba de A o una de B, y el árbol es el de la que se cumple— y
%   una para no: no Meta se cumple cuando Meta no se puede probar, y su
%   árbol es no Meta. Meta debe llegar sin variables libres.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(A o _, Observaciones, Arbol) :-
    prueba(A, Observaciones, Arbol).
prueba(_ o B, Observaciones, Arbol) :-
    prueba(B, Observaciones, Arbol).
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
prueba(X > Y, _, X > Y) :-
    X > Y.
prueba(X < Y, _, X < Y) :-
    X < Y.
prueba(Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba(Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    prueba(Condiciones, Observaciones, Arbol).
```

La regla r1 queda `si tiene_pelo o da_leche entonces mamifero`, y r2
desaparece. El archivo acumula las soluciones de los ejercicios 4, 5, 7 y 8:
la cláusula de `no` pertenece al [ejercicio 8](#8).

```prolog
?- identificar([da_leche, come_carne, color_leonado, rayas_negras], A).
A = tigre ;
false.
```

Las dos cláusulas de `o` dan una prueba por cada alternativa que se cumple, y
el árbol es el de esa alternativa: `explicar/2` no necesita cambios, porque el
árbol no tiene nodos `o`.

La actividad de la [sección 19.4](index.md#194-el-interprete-y-la-pregunta-como): con el intérprete del texto,
`prueba(mamifero, [tiene_pelo, da_leche], Arbol)` tiene dos respuestas,
`deducido(mamifero, r1, observado(tiene_pelo))` y
`deducido(mamifero, r2, observado(da_leche))`, una por cada regla que concluye
`mamifero` y se cumple con esas observaciones: `prueba/3` responde una vez por
cada prueba distinta. `identificar/2` llama a `prueba/3` dentro de `once/1`
para responder cada animal una sola vez, aunque tenga varias pruebas. Con la
regla r1 de esta solución, la consulta sigue teniendo dos respuestas, las dos
por r1: una por cada alternativa de `tiene_pelo o da_leche` que se cumple.

## 5

<!-- ejemplo: capitulo-19/soluciones_experto.pl fragmento: regla_auto(Nombre .. once(prueba_con(Reglas, Conclusion, Observaciones, _)). consulta: diagnosticar(regla_auto, [no_gira_el_motor, luces_debiles], D). -->
```prolog
% regla_auto(Nombre, si Condiciones entonces Conclusion): por qué un auto no
% arranca.
regla_auto(a1, si no_gira_el_motor y luces_debiles entonces bateria).
regla_auto(a2, si no_gira_el_motor y luces_normales entonces burro_de_arranque).
regla_auto(a3, si gira_el_motor y olor_a_nafta entonces motor_ahogado).
regla_auto(a4, si gira_el_motor y tanque(L) y L < 1 entonces sin_combustible).

%!  prueba_con(:Reglas, +Meta, +Observaciones:list, -Arbol) is nondet.
%
%   Como prueba/3, con las reglas de Reglas: un predicado de dos argumentos,
%   el nombre de la regla y la regla.
prueba_con(Reglas, A y B, Observaciones, ArbolA y ArbolB) :-
    prueba_con(Reglas, A, Observaciones, ArbolA),
    prueba_con(Reglas, B, Observaciones, ArbolB).
prueba_con(Reglas, A o _, Observaciones, Arbol) :-
    prueba_con(Reglas, A, Observaciones, Arbol).
prueba_con(Reglas, _ o B, Observaciones, Arbol) :-
    prueba_con(Reglas, B, Observaciones, Arbol).
prueba_con(Reglas, no Meta, Observaciones, no Meta) :-
    \+ prueba_con(Reglas, Meta, Observaciones, _).
prueba_con(_, X > Y, _, X > Y) :-
    X > Y.
prueba_con(_, X < Y, _, X < Y) :-
    X < Y.
prueba_con(_, Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba_con(Reglas, Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    call(Reglas, Regla, si Condiciones entonces Meta),
    prueba_con(Reglas, Condiciones, Observaciones, Arbol).

%!  diagnosticar(:Reglas, +Observaciones:list, -Conclusion) is nondet.
%
%   Conclusion es la conclusión de una regla de Reglas que se prueba a partir
%   de Observaciones; una respuesta por conclusión.
diagnosticar(Reglas, Observaciones, Conclusion) :-
    setof(C, N^Si^call(Reglas, N, Si entonces C), Conclusiones),
    member(Conclusion, Conclusiones),
    once(prueba_con(Reglas, Conclusion, Observaciones, _)).
```

```prolog
?- diagnosticar(regla_auto, [no_gira_el_motor, luces_debiles], D).
D = bateria ;
false.

?- diagnosticar(regla, [tiene_plumas, peso(90)], A).
A = ave ;
A = avestruz ;
false.
```

`prueba_con/4` es `prueba/3` con un argumento más: el predicado de las reglas,
que se llama con `call/3`. `diagnosticar/3` obtiene las conclusiones posibles
de la base misma, con `setof/3`, en lugar de una lista de hipótesis aparte:
con la base de los animales responde también las conclusiones intermedias,
como `ave`. Las dos bases usan el mismo intérprete sin cambiarlo. La
declaración `:- meta_predicate prueba_con(2, +, +, -), diagnosticar(2, +, -).`
indica que `Reglas` se llama con dos argumentos más.

## 6

Con `op(700, xfx, ->)`, `->` pasa a tener la precedencia de `>`, `=` e `is`, y
a no admitir a ninguno de ellos como argumento:

- `( X > 0 -> t ; e )` deja de ser un término válido: `X > 0` tiene
  precedencia 700, y el argumento izquierdo de un `xfx` de 700 debe tener
  menos. SWI-Prolog informa `operator_clash`.
- `( a, b -> c ; d )` sigue siendo válido, pero cambia de forma: la coma
  (1000) ya no puede ser argumento de `->`, y es `->` el que queda como
  argumento de la coma. El término pasa de `;(->(','(a, b), c), d)` a
  `;(','(a, ->(b, c)), d)`: la condición ya no es `a, b` sino solo `b`.

```prolog
?- op(700, xfx, ->), term_string(T, "( a, b -> c ; d )"), op(1050, xfy, ->), write_canonical(T), nl.
;(','(a,->(b,c)),d)
T = (a, (b->c);d).
```

`term_string(T, Texto)`, con `Texto` instanciado, lee la cadena como un
término con los operadores vigentes en ese momento y liga `T` a ese término;
con `T` instanciado y `Texto` libre, escribe el término en una cadena.
La consulta restaura la declaración en el mismo objetivo, porque un operador
redefinido alcanza a todo lo que se lee después, incluidas las consultas
siguientes. Las pruebas hacen lo mismo con `setup` y `cleanup`:

```prolog
test(flecha_redefinida_agrupa,
     [ setup(op(700, xfx, ->)),
       cleanup(op(1050, xfy, ->)),
       true(C == ";(','(a,->(b,c)),d)") ]) :-
    leer("( a, b -> c ; d )", C).
```

Los operadores de Prolog no se redefinen porque todo el código que se carga
después —el propio programa, las bibliotecas, las pruebas— se lee con la
declaración nueva, y un condicional escrito de la forma habitual pasa a ser un
error de sintaxis o, peor, un término distinto que se carga sin aviso.

## 7

<!-- ejemplo: capitulo-19/soluciones_experto.pl predicado: como/2 explicar/2 consulta: como([tiene_plumas, peso(90)], avestruz). -->
```prolog
%!  como(+Observaciones:list, +Animal) is semidet.
%
%   Escribe cómo se llega a Animal a partir de Observaciones: una línea por
%   conclusión, observación, comparación o negación, con las condiciones de
%   cada regla sangradas debajo de su conclusión. Falla si Animal no se
%   prueba.
como(Observaciones, Animal) :-
    once(prueba(Animal, Observaciones, Arbol)),
    explicar(Arbol, 0).

%!  explicar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria: una cláusula por cada
%   forma de nodo, como prueba/3. ~t~*| completa con espacios hasta la
%   columna Sangria, y cada regla sangra sus condiciones dos columnas más.
explicar(A y B, Sangria) :-
    explicar(A, Sangria),
    explicar(B, Sangria).
explicar(observado(M), Sangria) :-
    format("~t~*|~w: observado~n", [Sangria, M]).
explicar(no M, Sangria) :-
    format("~t~*|no ~w: no se prueba~n", [Sangria, M]).
explicar(X > Y, Sangria) :-
    format("~t~*|~w > ~w: se cumple~n", [Sangria, X, Y]).
explicar(X < Y, Sangria) :-
    format("~t~*|~w < ~w: se cumple~n", [Sangria, X, Y]).
explicar(deducido(M, Regla, Arbol), Sangria) :-
    format("~t~*|~w: por ~w~n", [Sangria, M, Regla]),
    Siguiente is Sangria + 2,
    explicar(Arbol, Siguiente).
```

```prolog
?- como([tiene_plumas, peso(90)], avestruz).
avestruz: por r12
  ave: por r3
    tiene_plumas: observado
  no vuela: no se prueba
  peso(90): observado
  90 > 50: se cumple
true.
```

`explicar/2` tiene la misma estructura que `prueba/3`: una cláusula por cada
forma de nodo del árbol. Una conjunción escribe sus dos partes con la misma
sangría; una conclusión deducida escribe su regla y después sus condiciones
dos columnas más adentro, con `Siguiente is Sangria + 2`. En `format/2`, la
directiva `~t~*|` toma un argumento, la columna, y rellena con espacios hasta
ella; con `Sangria` igual a 0 no escribe nada. La cláusula de `no` es la del
[ejercicio 8](#8). La prueba `como_avestruz` compara la salida completa con
`with_output_to/2`.

## 8

La declaración es `:- op(770, fy, no).`, por debajo de `y` (780): así
`ave y no vuela y nada` se lee `ave y ((no vuela) y nada)`, con la negación
aplicada solo a `vuela`. La cláusula del intérprete está en el `prueba/3` de
la [solución 4](#4):

```prolog
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
```

<!-- ejemplo: capitulo-19/soluciones_experto.pl fragmento: regla(r11, .. regla(r12, si ave y no vuela y peso(P) y P > 50 entonces avestruz). consulta: identificar([tiene_plumas, nada, peso(30)], A). -->
```prolog
regla(r11, si ave y no vuela y nada entonces pinguino).
regla(r12, si ave y no vuela y peso(P) y P > 50 entonces avestruz).
```

```prolog
?- identificar([tiene_plumas, nada, peso(30)], A).
A = pinguino ;
false.

?- identificar([tiene_plumas, vuela, nada, peso(30)], A).
false.
```

El caso 3 ya no necesita la observación `no_vuela`: `[tiene_plumas, peso(90)]`
alcanza para el avestruz, como muestra la [solución 7](#7). La diferencia es
lo que el sistema supone sobre lo que nadie observó. Con la observación
`no_vuela`, quien describe al animal afirma que no vuela; con `no vuela`, el
intérprete lo concluye de que `vuela` no está en la lista: es el supuesto de
mundo cerrado de la [sección 10.1](../capitulo-10-negacion-como-falla/index.md#101-el-supuesto-de-mundo-cerrado), aplicado a las observaciones. Un
animal del que nadie anotó si vuela se trata como uno que no vuela, y un ave
sin más datos que las plumas y el peso se identifica como avestruz. La regla
sirve cuando las observaciones son completas; con observaciones parciales, la
forma positiva `no_vuela` es la que no concluye nada de más.

## 9

```prolog
?- write_canonical(1 + 2 * 3 ^ 2), nl.
+(1,*(2,^(3,2)))
true.

?- write_canonical(- 1 + 2), nl.
+(-(1),2)
true.

?- forall(current_op(700, T, _), T == xfx).
true.
```

- `a = b = c` no es un término: `=` es `xfx`, y ninguno de sus lados admite
  otro operador de precedencia 700. SWI-Prolog informa `operator_clash`, y la
  prueba `igual_no_se_encadena` lo verifica con `term_string/2`.
- `1 + 2 * 3 ^ 2` es `+(1, *(2, ^(3, 2)))`: `^` (200) liga más que `*` (400),
  que liga más que `+` (500). La evaluación da 19.
- `- 1 + 2` es `+(-(1), 2)`: el `-` prefijo (200, `fy`) se aplica al 1, y el
  resultado es el argumento izquierdo de `+`.

Los operadores de precedencia 700 son los de comparación y unificación —`=`,
`\=`, `==`, `\==`, `is`, `<`, `>`, `=<`, `>=`, `=:=`, `=\=`, `@<` y los
demás—, y todos son `xfx`: una comparación no se encadena, y `a < b < c` es
un error de sintaxis, no un término con dos comparaciones.

La actividad de la [sección 19.2](index.md#192-precedencia-y-asociatividad) se responde con la misma tabla.
`X = (a :- b, c), X = (H :- B)` liga `H = a` y `B = (b, c)`: `:-` (1200) es el
operador principal y la coma (1000) queda entera en su segundo argumento.
`write_canonical((p :- q ; r, s))` escribe `:-(p,;(q,','(r,s)))`: `;` (1100)
contiene a la coma (1000), y las dos quedan dentro de `:-`.
`write_canonical(- 1 + 2)` escribe `+(-(1),2)`, como en la segunda
predicción de este ejercicio.

## 10

<!-- ejemplo: capitulo-19/soluciones_inscripciones.pl predicado: por_que/2 consulta: por_que(102, am2). -->
```prolog
%!  por_que(+Legajo:integer, +Materia:atom) is det.
%
%   Escribe la prueba de cada motivo por el que se rechaza la inscripción
%   del alumno Legajo en Materia, con explicar/2. No escribe nada si no hay
%   ningún motivo.
por_que(Legajo, Materia) :-
    situacion(Legajo, Materia, Observaciones),
    forall(prueba(rechazada(_), Observaciones, Arbol),
           explicar(Arbol, 0)).
```

```prolog
?- por_que(102, am2).
rechazada(falta(am1)): por v3
  requisito(am1): observado
  no aprobada(am1): no se prueba
rechazada(falta(alg)): por v3
  requisito(alg): observado
  no aprobada(alg): no se prueba
true.
```

`forall/2`, del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md#176-forall2), recorre las pruebas de
`rechazada(_)` y escribe cada árbol, sin reunirlos en una lista: es el bucle
por falla de la [sección 15.7](../capitulo-15-control/index.md#157-bucles-por-falla) escrito con `forall/2`. `explicar/2`
es el del [ejercicio 7](#7) con la cláusula para los nodos `no`, que escribe
la condición y «no se prueba». `soluciones_inscripciones.pl` repite las reglas
y los datos que necesitan, porque el archivo de soluciones tiene que cargarse
solo.

## 11

<!-- ejemplo: capitulo-19/soluciones_inscripciones.pl fragmento: regla(v5, .. regla(v5, si no rechazada(_) entonces aceptada). consulta: se_acepta(104, ssl). -->
```prolog
regla(v5, si no rechazada(_) entonces aceptada).
```

<!-- ejemplo: capitulo-19/soluciones_inscripciones.pl predicado: se_acepta/2 consulta: se_acepta(104, ssl). -->
```prolog
%!  se_acepta(+Legajo:integer, +Materia:atom) is semidet.
%
%   La inscripción del alumno Legajo en Materia se acepta: la regla v5 se
%   prueba, porque ningún rechazada(Motivo) se puede probar.
se_acepta(Legajo, Materia) :-
    situacion(Legajo, Materia, Observaciones),
    once(prueba(aceptada, Observaciones, _)).
```

```prolog
?- se_acepta(104, ssl).
true.

?- se_acepta(102, am2).
false.
```

`no rechazada(_)` con la variable libre pregunta si **ninguna** instancia de
`rechazada(Motivo)` se puede probar: `\+ prueba(rechazada(_), …)` falla en
cuanto encuentra un motivo, cualquiera sea, y se cumple solo cuando no hay
ninguno. Es el uso de `\+` con una variable libre de la [sección 10.2](../capitulo-10-negacion-como-falla/index.md#102-no-se-puede-probar), y
aquí es el sentido buscado: la aceptación es la ausencia de todo rechazo. La
regla v5 no se aplica a sí misma porque su conclusión es `aceptada`, que no
unifica con `rechazada(_)`: al buscar reglas para `rechazada(_)`, el
intérprete solo encuentra v1 a v4. `se_acepta/2` usa `once/1` porque
`prueba/3` deja pendientes las demás reglas después de probar v5, y el
predicado es `semidet`.

La actividad de la [sección 19.5](index.md#195-el-proyecto-los-motivos-de-rechazo-como-reglas): `situacion(103, am2, Obs)` da
`[materia(am2), aprobada(am1), cursando(am2), requisito(am1), requisito(alg), vacantes(25)]`.
Con esa lista, v1 no se prueba (am2 no está aprobada), v2 sí (am2 está entre
las materias que cursa), v3 solo para alg (am1 está aprobada) y v4 no (quedan
25 vacantes): `motivos_de_rechazo(103, am2, M)` responde
`M = [ya_la_cursa, falta(alg)]`.

## 12

<!-- ejemplo: capitulo-19/soluciones_operadores.pl fragmento: op(700, xfx, requiere) .. entre(X, X). consulta: correlativa(am2, R). -->
```prolog
:- op(700, xfx, requiere).

% Materia requiere Requisitos: para cursar Materia se debe aprobar cada uno
% de los Requisitos, unidos con y.
am2 requiere am1 y alg.
pp  requiere log.
ssl requiere log y alg.
bd  requiere pp y ssl.

%!  correlativa(?Materia:atom, ?Requisito:atom) is nondet.
%
%   Para cursar Materia se debe aprobar Requisito: la relación del proyecto,
%   obtenida de los hechos requiere.
correlativa(Materia, Requisito) :-
    Materia requiere Requisitos,
    entre(Requisito, Requisitos).

%!  entre(?X, +Conjuncion) is nondet.
%
%   X es uno de los términos de Conjuncion, unidos con y: a y b y c son a, b
%   y c. Un término que no es una conjunción es él mismo.
entre(X, A y B) :-
    !,
    (   entre(X, A)
    ;   entre(X, B)
    ).
entre(X, X).
```

```prolog
?- correlativa(am2, R).
R = am1 ;
R = alg.

?- correlativa(M, log).
M = pp ;
M = ssl ;
false.
```

`requiere` se declara en 700, como `es_padre_de` en la [sección 19.1](index.md#191-operadores-propios), y `y`
conserva la precedencia 200 del ejercicio 1: `am1 y alg` es un argumento
válido. Los requisitos de una materia no son una lista sino un término
`y(am1, alg)`, y `entre/2` lo recorre como `member/2` recorre una lista: si el
término es una conjunción, busca en cada lado; si no, es el requisito mismo.
El corte hace que un término `y` no se tome además como requisito entero.
`correlativa/2` responde una correlativa por vez, en los dos sentidos, como la
relación de hechos del proyecto: las pruebas del capítulo que la usan no
necesitan cambios.
