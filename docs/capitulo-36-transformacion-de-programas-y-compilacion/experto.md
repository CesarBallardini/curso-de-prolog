# Las reglas compiladas

Esta página continúa el [capítulo 36](index.md) después de la
[sección 36.6](index.md#366-archivos-qlf), con la
[sección 36.7](#367-las-reglas-compiladas): compila las reglas del sistema
experto del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) con `term_expansion/2`, de la
[sección 36.1](index.md#361-term_expansion2-y-goal_expansion2-en-swi-prolog), y con el evaluador parcial de la
[sección 36.4](index.md#364-evaluacion-parcial). El código está en `ejemplos/capitulo-36/experto.pl`, con
sus pruebas en `experto.plt`, y corre solo en `swipl`.

## 36.7 Las reglas compiladas

El sistema experto de la [sección 34.7](../capitulo-34-introspeccion-y-metainterpretes/index.md#347-el-sistema-experto-explica) interpreta sus reglas con
`demostrar/4`. En cada consulta, el intérprete examina la forma de cada
condición, prueba si es una observación y busca en `regla/2` las reglas que
la concluyen, aunque las reglas no cambien entre consultas: es el caso de la
[sección 36.4](index.md#364-evaluacion-parcial), con `term_expansion/2` para especializar al
cargar cada regla.

`experto.pl` conserva `demostrar/4`, con las observaciones en una lista, y
define su versión compilada, `concluir/4`. Cada término `regla/2` se expande
en dos: la regla, que sigue siendo un dato para el intérprete y las
explicaciones, y una cláusula de `concluir/4`, que es la última cláusula de
`demostrar/4` evaluada parcialmente con `parcial/3` sobre las condiciones de
esa regla:

<!-- ejemplo: capitulo-36/experto.pl fragmento: %!  term_expansion(+Termino, -Clausulas:list) is semidet. .. control, Cuerpo). consulta: caso(3, Obs), identificar_compilado(Obs, Animal). -->
```prolog
%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Una regla regla(R, si Condiciones entonces Meta) se carga como dato y
%   como una cláusula de concluir/4: la de demostrar/4 que usa la regla,
%   evaluada parcialmente sobre sus condiciones.
term_expansion(regla(R, si Condiciones entonces Meta),
               [ regla(R, si Condiciones entonces Meta),
                 (concluir(Meta, Fuente, Pila, deducido(Meta, R, Arbol)) :-
                      Cuerpo) ]) :-
    parcial(demostrar(Condiciones, Fuente, [R-Meta|Pila], Arbol),
            control, Cuerpo).
```

El control despliega `demostrar/4` sobre las conjunciones, las comparaciones
y las observaciones, y lo deja como llamada a `concluir/4` sobre la
conclusión de otra regla:

<!-- ejemplo: capitulo-36/experto.pl fragmento: %!  control(+Meta, -Accion) is semidet. .. control(regla(_, _), desplegar). -->
```prolog
%!  control(+Meta, -Accion) is semidet.
%
%   Al compilar una regla, demostrar/4 se despliega sobre una conjunción,
%   una comparación o una observación, y queda como llamada a concluir/4
%   sobre una conclusión de otra regla. observable/1 y regla/2 se
%   despliegan: cuando no tienen cláusulas para la condición, la rama del
%   intérprete que las llama desaparece. Por eso observable/1 se define
%   antes que las reglas.
control(demostrar(C, Fuente, Pila, Arbol), Accion) :-
    (   simple(C),
        \+ observable(C)
    ->  Accion = dejar(concluir(C, Fuente, Pila, Arbol))
    ;   Accion = desplegar
    ).
control(observable(_), desplegar).
control(regla(_, _), desplegar).
```

Al desplegar, `clause/2` devuelve también las cláusulas del intérprete que
no corresponden: la de las observaciones para una conjunción, la de las
reglas para una observación. El control despliega `observable/1` y
`regla/2`, que no tienen cláusulas para esas condiciones, y esas ramas
desaparecen: lo que el intérprete descartaba en cada consulta se descarta
una vez. Por eso `observable/1` está antes que las reglas en el archivo: al
expandir cada regla, sus hechos ya están cargados. La regla r12, compilada,
según `listing(concluir/4)`:

```text
concluir(avestruz, A, B, deducido(avestruz, r12, C y observado(no_vuela)y observado(peso(D))y D>50)) :-
    concluir(ave, A, [r12-avestruz|B], C),
    observar(A, no_vuela, [r12-avestruz|B]),
    observar(A, peso(D), [r12-avestruz|B]),
    D>50.
```

Cada regla agrega una cláusula, indexada por su conclusión; como llegan
alternadas con las de `regla/2`, el archivo declara los dos predicados
`discontiguous`. Los árboles son los del intérprete, en el mismo orden
(prueba `arboles`), e `identificar_compilado/2` identifica los mismos
animales:

```prolog
?- caso(3, Obs), identificar_compilado(Obs, Animal).
Obs = [tiene_plumas, no_vuela, peso(90)],
Animal = avestruz.
```

`identificar_casos/2` identifica mil veces los animales de los cinco casos:

```text
?- time(identificar_casos(identificar, 1000)).
% 1,167,737 inferences, 0.156 CPU in 0.177 seconds (88% CPU, 7473517 Lips)

?- time(identificar_casos(identificar_compilado, 1000)).
% 657,737 inferences, 0.078 CPU in 0.086 seconds (91% CPU, 8419034 Lips)
```

Algo más de la mitad de las inferencias y la mitad del tiempo. La ganancia
es menor que en la [sección 36.4](index.md#364-evaluacion-parcial) porque el intérprete del sistema
experto hacía poco por regla; lo que queda, recorrer las observaciones con
`member/2`, depende de los datos de cada consulta. Las explicaciones de la
[sección 34.7](../capitulo-34-introspeccion-y-metainterpretes/index.md#347-el-sistema-experto-explica) funcionan sin cambios sobre los árboles de
`concluir/4`.

La compilación cambia cuándo se leen las reglas. En `experto.pl`, `regla/2`
es estática, y `assertz/1` produce un error de permiso; declarada dinámica,
una regla agregada durante la ejecución la ve `demostrar/4`, que busca las
reglas en cada consulta, y no `concluir/4`, cuyas cláusulas se generaron al
cargar. Un sistema cuyas reglas se editan mientras corre necesita el
intérprete; uno cuyas reglas se fijan antes de usarlo, la versión compilada.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado de los transformadores declara sus modos: `traducir/2` y `desplegar/4` son `det`, `plegar/4` es `semidet`, `parcial/3` es `nondet`, una respuesta por combinación de cláusulas desplegadas; los ganchos `term_expansion/2` y `goal_expansion/2` son `semidet`, porque fallan con lo que no expanden |
    | C4 | `traducir/2`, `desplegar/4` y `plegar/4` no dejan alternativas: sus pruebas no declaran `nondet` |
    | C7 | 73 pruebas en los ocho archivos del capítulo; cada transformación se compara con el original: la traducción con `dcg_translate_rule/2` en doce reglas (`como_el_sistema`), la derivación con las cláusulas cargadas (`derivar`), la versión especializada y la compilada con el intérprete, árbol por árbol (`como_el_interprete`, `arboles`), el `.qlf` con el fuente (`qlf`) |
    | C2, C3 del programa transformado | se conservan: la versión especializada y las reglas compiladas dan las mismas respuestas y los mismos árboles, en el mismo orden, que el intérprete |
    | lo que se pierde | la posibilidad de cambiar el programa durante la ejecución: una regla agregada con `assertz/1` no se compila; el corte y los efectos laterales en lo que se despliega, porque el evaluador parcial trata programas puros; y la lectura directa del código, que `listing/1` muestra ya transformado |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

14. ★ **(2)** Agregar a `experto.pl` la regla
    `regla(r13, si mamifero y vuela entonces murcielago)` y la hipótesis
    `murcielago`. Mostrar su cláusula compilada y comprobar con un caso que
    `identificar/2` e `identificar_compilado/2` la usan. ¿Qué ocurre si una
    regla se agrega con `assertz/1` después de cargar el archivo, con
    `regla/2` estática y con `regla/2` dinámica?
15. **(3)** Escribir la expansión de las reglas de `experto.pl` sin el
    evaluador parcial: `compilar_condicion/5` traduce las condiciones de una
    regla directamente al cuerpo de `concluir/4`. Comprobar que produce las
    mismas cláusulas que `experto.pl`, y explicar qué relación tiene con el
    control de la [sección 36.7](#367-las-reglas-compiladas).

## Resumen

| | |
|---|---|
| `term_expansion/2` | gancho que reemplaza, al cargar, un término leído por otro, por una lista de términos o por ninguno; se aplica una vez, a lo que se lee después de su definición |
| `goal_expansion/2` | gancho que reemplaza, al cargar, un objetivo de un cuerpo; se aplica hasta que el objetivo no cambia |
| `expand_term/2` | los pasos de la carga de un término: compilación condicional, `term_expansion/2`, gramáticas, `goal_expansion/2` |
| `expand_goal/2` | la expansión de un objetivo, como la hace la carga |
| `dcg_translate_rule/2` | la traducción de una regla de gramática que hace SWI-Prolog |
| `subsumes_term/2` | el segundo término es una instancia del primero, sin ligar sus variables |
| `compile_aux_clauses/1` | compilar, desde una expansión, cláusulas auxiliares que se guardan también en un `.qlf` |
| `qcompile/1` | compilar un fuente a `.qlf`: las cláusulas ya expandidas, en instrucciones de la máquina virtual de esa versión |
| bandera `optimise_apply` | `true` activa las expansiones de `library(apply_macros)`; con `default`, las activa `swipl -O` |
| bandera `abi_version` | las versiones de los formatos de los que dependen los `.qlf` |
| desplegar y plegar | reemplazar un objetivo por los cuerpos de sus cláusulas, y una parte de un cuerpo por la cabeza de una definición; plegar sin haber desplegado puede crear una recursión que no avanza |
| evaluación parcial | ejecutar de antemano lo que no depende de los datos; un control decide qué se despliega y dónde se detiene |
| `findnsols/4` | como `findall/3`, hasta una cantidad de soluciones; en las pruebas |
| `unload_file/1` | descarga las cláusulas de un archivo; en las pruebas |
| **Patrones 49, 50** | expandir al cargar; especializar el intérprete |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Qué conservan el despliegue y el plegado: el modelo mínimo del programa | [capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/index.md) |
| Una directiva que cambia al cargar cómo se ejecuta un predicado: `:- table` | [capítulo 40](../capitulo-40-tabulacion/index.md) |
| La reescritura de expresiones en un programa que resuelve ecuaciones | [capítulo 44](../capitulo-44-proyecto-resolver-ecuaciones/index.md) |
| El intérprete de un lenguaje evaluado parcialmente, comparado con su compilador | [capítulo 46](../capitulo-46-proyecto-compilador/index.md) |

## Referencias

- Fernando Pereira y Stuart Shieber, *Prolog and Natural-Language
  Analysis*, CSLI, 1987 — apartado «Partial Execution and Compilers».
  [Edición digital de Microtome](http://www.mtome.com/Publications/PNLA/pnla-digital.html).
  Esta página aplica a las reglas del sistema experto la compilación por
  evaluación parcial de un intérprete.

El código del capítulo es propio, escrito para el curso: las fuentes
aportan técnicas y definiciones, no código copiado ni adaptado.
