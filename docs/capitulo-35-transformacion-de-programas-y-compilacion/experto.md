# Las reglas compiladas

Esta página completa la [sección 35.7](index.md#357-las-reglas-compiladas): compila las reglas del sistema
experto del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) con `term_expansion/2`, de la
[sección 35.1](index.md#351-term_expansion2-y-goal_expansion2-en-swi-prolog), y con el evaluador parcial de la
[sección 35.4](index.md#354-evaluacion-parcial). El código está en `ejemplos/capitulo-35/experto.pl`, con
sus pruebas en `experto.plt`, y corre solo en `swipl`.

El sistema experto de la [sección 33.7](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica) interpreta sus reglas con
`demostrar/4`. En cada consulta, el intérprete examina la forma de cada
condición, prueba si es una observación y busca en `regla/2` las reglas que
la concluyen, aunque las reglas no cambien entre consultas: es el caso de la
[sección 35.4](index.md#354-evaluacion-parcial), con `term_expansion/2` para especializar al
cargar cada regla.

`experto.pl` conserva `demostrar/4`, con las observaciones en una lista, y
define su versión compilada, `concluir/4`. Cada término `regla/2` se expande
en dos: la regla, que sigue siendo un dato para el intérprete y las
explicaciones, y una cláusula de `concluir/4`, que es la última cláusula de
`demostrar/4` evaluada parcialmente sobre las condiciones de esa regla:

<!-- ejemplo: capitulo-35/experto.pl fragmento: %!  term_expansion(+Termino, -Clausulas:list) is semidet. .. control, Cuerpo). consulta: caso(3, Obs), identificar_compilado(Obs, Animal). -->
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

<!-- ejemplo: capitulo-35/experto.pl fragmento: %!  control(+Meta, -Accion) is semidet. .. control(regla(_, _), desplegar). -->
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
es menor que en la [sección 35.4](index.md#354-evaluacion-parcial) porque el intérprete del sistema
experto hacía poco por regla; lo que queda, recorrer las observaciones con
`member/2`, depende de los datos de cada consulta. Las explicaciones de la
[sección 33.7](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica) funcionan sin cambios sobre los árboles de
`concluir/4`.

La compilación cambia cuándo se leen las reglas. En `experto.pl`, `regla/2`
es estática, y `assertz/1` produce un error de permiso; declarada dinámica,
una regla agregada durante la ejecución la ve `demostrar/4`, que busca las
reglas en cada consulta, y no `concluir/4`, cuyas cláusulas se generaron al
cargar. Un sistema cuyas reglas se editan mientras corre necesita el
intérprete; uno cuyas reglas se fijan antes de usarlo, la versión compilada.
