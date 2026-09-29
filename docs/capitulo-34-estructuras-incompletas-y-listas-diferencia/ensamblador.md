# La tabla de símbolos del compilador

Esta página completa la [sección 34.7](index.md#347-la-tabla-de-simbolos-del-compilador): la tabla de símbolos
de un ensamblador, que combina el diccionario incompleto de la
[sección 34.4](index.md#344-diccionarios-incompletos) con la gramática como lista diferencia de la
[sección 34.5](index.md#345-las-gramaticas-como-listas-diferencia). El código está en `ejemplos/capitulo-34/simbolos.pl`, con
sus pruebas en `simbolos.plt`; el [capítulo 45](../capitulo-45-proyecto-compilador/index.md) aplica las mismas técnicas en su compilador.

Un compilador traduce un programa a instrucciones numeradas, y un salto
dirige la ejecución a otra instrucción por su número. En el programa fuente,
el destino de un salto es una **etiqueta**, un nombre que marca una posición.
Un salto hacia atrás usa una etiqueta ya marcada, cuyo número se conoce; uno
hacia adelante usa una etiqueta que se marca más abajo, cuyo número todavía no
se conoce. La solución habitual es recorrer el programa dos veces: la primera
calcula los números de las etiquetas, la segunda los usa.

Con un diccionario incompleto alcanza una sola pasada. La **tabla de
símbolos**, que asocia cada etiqueta con su dirección, se consulta con
`buscar/3`. Un salto hacia adelante agrega la etiqueta con la dirección libre y
escribe esa variable en la instrucción; la marca, al aparecer, busca la misma
etiqueta y liga la variable al número de la instrucción que la sigue. El
programa de ejemplo, para una máquina de pila, escribe 3, 2 y 1:

<!-- ejemplo: capitulo-34/simbolos.pl predicado: programa/2 consulta: listar(cuenta). -->
```prolog
% programa(Nombre, Instrucciones): un programa de ejemplo. cuenta escribe
% 3, 2 y 1.
programa(cuenta, [ apilar(3), guardar(n),
                   etiqueta(inicio),
                   cargar(n), saltar_si_cero(fin),
                   cargar(n), escribir,
                   cargar(n), apilar(1), restar, guardar(n),
                   saltar(inicio),
                   etiqueta(fin) ]).
```

`ensamblar/2` produce el código con una gramática, es decir, como lista
diferencia, y lleva la tabla de símbolos como diccionario incompleto:

<!-- ejemplo: capitulo-34/simbolos.pl predicado: ensamblar/2 consulta: ensamblar([saltar(fin), sumar, etiqueta(fin)], C). -->
```prolog
%!  ensamblar(+Programa:list, -Codigo:list) is semidet.
%
%   Codigo es Programa con las marcas de etiqueta quitadas y cada salto
%   dirigido al número de instrucción de su etiqueta, contando desde 0.
%   Produce un error de existencia si un salto usa una etiqueta que no se
%   marca; falla si una etiqueta se marca dos veces en direcciones
%   distintas.
ensamblar(Programa, Codigo) :-
    phrase(codigo(Programa, 0, Tabla), Codigo),
    etiquetas_definidas(Tabla).
```

`codigo//3` pasa cada instrucción, con su dirección, a `instruccion//4`.
Una marca no ocupa lugar en el código; un salto ocupa una dirección, y busca en
la tabla la de su etiqueta:

<!-- ejemplo: capitulo-34/simbolos.pl fragmento: instruccion(etiqueta(E) .. Dir1 is Dir + 1 }. -->
```prolog
instruccion(etiqueta(E), Dir, Dir, Tabla) -->
    { buscar(E, Tabla, Dir) }.
instruccion(saltar(E), Dir, Dir1, Tabla) -->
    [saltar(D)],
    { buscar(E, Tabla, D),
      Dir1 is Dir + 1 }.
```

El programa de ejemplo, ensamblado:

```prolog
?- listar(cuenta).
0   apilar(3)
1   guardar(n)
2   cargar(n)
3   saltar_si_cero(11)
4   cargar(n)
5   escribir
6   cargar(n)
7   apilar(1)
8   restar
9   guardar(n)
10  saltar(2)
true.
```

`saltar_si_cero(fin)`, en la dirección 3, se tradujo antes de llegar a
`etiqueta(fin)`: su dirección, 11, llegó por unificación cuando la marca
apareció al final. Una etiqueta a la que se salta y que nunca se marca deja su
dirección libre; `etiquetas_definidas/1` recorre la tabla al terminar y lo
informa con un error de existencia, del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md):

```prolog
?- ensamblar([saltar(fin), sumar, etiqueta(fin)], C).
C = [saltar(2), sumar].

?- ensamblar([saltar(fin), sumar], C).
ERROR: etiqueta `fin' does not exist
```

Una etiqueta marcada dos veces en lugares distintos hace fallar el
ensamblado: la segunda marca unifica con otro número una dirección ya
ligada, y la unificación falla. Dos marcas seguidas tienen el mismo número, y pasan sin aviso. El
[ejercicio 13](index.md#ejercicios) convierte los dos casos en un error. El [capítulo 45](../capitulo-45-proyecto-compilador/index.md)
genera este código a partir de un lenguaje con asignaciones, `si` y
`mientras`, guarda las variables en el diccionario incompleto de la
[sección 34.4](index.md#344-diccionarios-incompletos) y deja las etiquetas como variables que el
ensamblado liga por unificación, y escribe la máquina de pila que lo ejecuta.
