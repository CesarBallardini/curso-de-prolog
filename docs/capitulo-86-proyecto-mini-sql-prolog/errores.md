# Los errores de sintaxis y de tipos

Esta página contiene dos partes de las secciones
[86.4](index.md#864-version-2-la-gramatica-de-las-sentencias) y
[86.7](index.md#867-version-5-condiciones-de-tres-valores) del
[capítulo 86](index.md): cómo la gramática de `sintaxis.pl` señala dónde
falla una sentencia, y cómo el compilador de `consultas.pl` rechaza una
comparación entre tipos distintos. El código está en
`ejemplos/capitulo-86/`, con sus pruebas.

## Los errores de sintaxis

<!-- contexto: capitulo-86/sintaxis.pl -->

Una gramática que falla no dice dónde: la
vuelta atrás prueba todas las alternativas y, al final, `phrase/2`
falla. Toy-Sequel muestra el token problemático y los que le siguen. El
mini-SQL lo obtiene con un único terminal, `t//1`, por el que pasan
todos los tokens: antes de mirar el próximo token anota el resto de la
entrada si es el más corto alcanzado hasta ahora. Cuando el análisis
entero falla, el resto anotado es el punto más lejano al que llegó
alguna alternativa, y el error nombra los tres tokens que empiezan ahí.

<!-- ejemplo: capitulo-86/sintaxis.pl predicado: analizar_tokens/2 t/3 anotar/1 -->
```prolog
%!  analizar_tokens(+Tokens:list, -Sentencia) is det.
%
%   Lo mismo, sobre una lista de tokens. Se queda con el primer análisis.
analizar_tokens(Tokens, Sentencia) :-
    nb_setval(sintaxis_lejos, Tokens),
    (   phrase(sentencia_completa(S), Tokens)
    ->  Sentencia = S
    ;   nb_getval(sintaxis_lejos, Resto),
        cerca(Resto, Cerca),
        throw(error(sql(sintaxis(Cerca)), _))
    ).

%!  t(?Token)// is semidet.
%
%   El próximo token es Token. Antes de mirarlo anota la posición, si es
%   la más lejana alcanzada hasta ahora.
t(Token, S0, S) :-
    anotar(S0),
    S0 = [Token|S].

%!  anotar(+Resto:list) is det.
%
%   Guarda Resto si es más corto que el resto más corto guardado.
anotar(S0) :-
    nb_getval(sintaxis_lejos, Lejos),
    length(Lejos, L),
    length(S0, N),
    (   N < L
    ->  nb_setval(sintaxis_lejos, S0)
    ;   true
    ).
```

```prolog
?- catch(analizar("SELECT nombre FROM WHERE x = 1", S), E, true).
E = error(sql(sintaxis([n(where), n(x), =])), _).
```

`t/3` está escrito como un predicado con los dos argumentos de la lista
diferencia a la vista, porque necesita examinar la entrada antes de
consumirla; para el resto de la gramática es un no terminal más. El
resto se guarda con `nb_setval/2`, que sobrevive a la vuelta atrás.

La técnica es el patrón 99:

!!! example "Patrón 99 — El error en el punto más lejano"
    **Problema.** Una gramática que no reconoce la entrada falla, y la
    falla no dice dónde. La vuelta atrás prueba todas las alternativas, y
    cuando la última falla, `phrase/2` falla sin ninguna información.

    **Versión ingenua.** Informar sobre la entrada entera («sentencia
    incorrecta»), o lanzar el error en la primera alternativa que no
    reconoce un token. Lo primero no ayuda a corregir; lo segundo lo
    lanza demasiado pronto: una alternativa que falla es lo normal en una
    gramática con vuelta atrás, y otra alternativa podía reconocer la
    entrada.

    **Patrón.** Pasar todos los tokens por un único terminal, `t//1`,
    que antes de examinar el próximo token anota el resto de la entrada
    si es el más corto alcanzado hasta ahora (`anotar/1`), en una
    variable global que sobrevive a la vuelta atrás. Si el análisis
    entero falla, el resto anotado es el **punto más lejano** al que llegó
    alguna alternativa, y el error nombra los tokens que empiezan ahí
    (`analizar_tokens/2`). La gramática no cambia: solo su terminal. El
    error es un término, `error(sql(sintaxis(Cerca)), _)`, que quien lo
    captura examina como en el
    [Patrón 30](../patrones.md#30-capturar-lo-justo-y-relanzar).

    **Cuándo no usarlo.** Cuando la gramática es determinista y no vuelve
    atrás, como un analizador que lee la entrada de izquierda a derecha
    con un token de anticipación: el punto en que falla ya es el más
    lejano, y basta con lanzar el error allí. Y cuando una alternativa
    avanza mucho por un camino equivocado antes de fallar: el punto más
    lejano es el de ese camino, y el mensaje señala un lugar que no es el
    error que quien escribió la sentencia cometió.

!!! question "Actividad"
    Predecir el error de `analizar/2` con `"SELECT nombre, FROM alumnos"`
    y con `"SELECT nombre FROM alumnos WHERE nota >"`. Comprobarlo, y
    explicar por qué en el primer caso el punto más lejano no es la coma.

## Los errores de tipos

<!-- contexto: capitulo-86/consultas.pl -->

`expresion/7` da el tipo de cada expresión —`entero`,
`real`, `texto`, o `nulo` para la constante `NULL`— y `compatibles/3`
rechaza una comparación entre un número y un texto antes de ejecutar
nada. Kluźniak y Szpakowicz observan que Prolog es «demasiado fuerte»
para usarlo directamente como lenguaje de una base de datos: conviene
una interfaz restringida que analice los comandos, verifique los tipos y
la integridad, y solo entonces los traduzca. El mini-SQL es esa
interfaz.

```prolog
?- catch(filas("SELECT nombre FROM alumnos WHERE nombre = 3", _, _), E, true).
E = error(sql(tipos(texto, entero)), _).
```
