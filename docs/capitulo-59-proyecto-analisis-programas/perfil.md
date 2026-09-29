# Un intérprete que cuenta

Esta página contiene la [sección 59.5](index.md#595-un-interprete-que-cuenta) del
[capítulo 59](index.md): un metaintérprete que ejecuta el programa y cuenta las
llamadas a cada predicado, con predicados espiados como los del rastreador de
Kluźniak y Szpakowicz. El ejemplo es `perfil.pl`, en `ejemplos/capitulo-59/`,
con sus pruebas, y corre en SWISH.

## Un intérprete que cuenta

El análisis anterior no ejecuta nada. `perfil.pl` ejecuta el programa con un
metaintérprete como el de la [sección 33.6](../capitulo-33-introspeccion-y-metainterpretes/index.md#336-un-depurador-en-prolog), que cuenta cada llamada a
cada predicado del programa en un hecho dinámico `cuenta/2`, también las de
las ramas que después fallan. Los predicados predefinidos que el programa
usa están en la tabla `sistema/1`, y el intérprete los ejecuta con
`ejecutar/1`, de modo que el intérprete corre en SWISH:

<!-- ejemplo: capitulo-59/perfil.pl predicado: resolver/1 perfil/3 consulta: perfil(inversa([a, b, c, d], R), Resultado, Cuentas). -->
```prolog
%!  resolver(+Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa, y cada llamada a un
%   predicado del programa se cuenta.
resolver(true).
resolver((A, B)) :-
    resolver(A),
    resolver(B).
resolver((C -> T ; E)) :-
    (   resolver(C)
    ->  resolver(T)
    ;   resolver(E)
    ).
resolver((A ; B)) :-
    A \= (_ -> _),
    (   resolver(A)
    ;   resolver(B)
    ).
resolver(\+ A) :-
    \+ resolver(A).
resolver(G) :-
    sistema(G),
    ejecutar(G).
resolver(G) :-
    del_programa(G),
    functor(G, Nombre, Aridad),
    contar(Nombre/Aridad),
    (   espiado(Nombre/Aridad)
    ->  resolver_espiado(G)
    ;   clause(G, Cuerpo),
        resolver(Cuerpo)
    ).

%!  perfil(+Meta, -Resultado, -Cuentas:list(pair)) is det.
%
%   Ejecuta Meta con el intérprete hasta su primera respuesta. Resultado es
%   exito, con Meta ligada a esa respuesta, o falla. Cuentas son los pares
%   Predicado-N, ordenados, con las llamadas a cada predicado del programa.
perfil(Meta, Resultado, Cuentas) :-
    retractall(cuenta(_, _)),
    (   resolver(Meta)
    ->  Resultado = exito
    ;   Resultado = falla
    ),
    findall(P-N, cuenta(P, N), Cuentas0),
    msort(Cuentas0, Cuentas).
```

El programa que se ejecuta tiene dos maneras de invertir una lista: la
ingenua, que concatena cada elemento al final, y la que usa un acumulador.
`invertir(N)` invierte con la primera la lista de los enteros de 1 a `N`, e
`invertir_rapido(N)`, con la segunda.

```prolog
?- perfil(inversa([a, b, c, d], R), Resultado, Cuentas).
R = [d, c, b, a],
Resultado = exito,
Cuentas = [concatenar/3-10, inversa/2-5].

?- perfil(invertir(30), Resultado, Cuentas).
Resultado = exito,
Cuentas = [concatenar/3-465, inversa/2-31, invertir/1-1, lista/2-1].

?- perfil(invertir_rapido(30), Resultado, Cuentas).
Resultado = exito,
Cuentas = [inversa_acumulada/3-31, inversa_rapida/2-1, invertir_rapido/1-1, lista/2-1].
```

Para una lista de $n$ elementos, la inversa ingenua concatena listas de
largo $0, 1, \ldots, n-1$, y concatenar una de largo $k$ hace $k + 1$
llamadas: en total $n(n+1)/2$, que para $n = 30$ son 465. La prueba
`formula` de `perfil.plt` compara la cuenta con la fórmula para $n$ de 1 a 12.
La inversa con acumulador hace $n + 1$ llamadas a `inversa_acumulada/3`.

`espiar/1` marca un predicado, como el `spy` del rastreador de Kluźniak y
Szpakowicz: el intérprete escribe `+` y la meta cada vez que una llamada
tiene éxito, y `-` y la llamada original cuando ya no tiene más respuestas.

<!-- ejemplo: capitulo-59/perfil.pl predicado: resolver_espiado/1 -->
```prolog
%!  resolver_espiado(+G) is nondet.
%
%   Prueba G como resolver/1, y escribe + G por cada respuesta y - con la
%   llamada original cuando no hay más.
resolver_espiado(G) :-
    copy_term(G, Llamada),
    (   clause(G, Cuerpo),
        resolver(Cuerpo),
        escribir('+', G)
    ;   escribir('-', Llamada),
        fail
    ).
```

!!! question "Actividad"
    Con `concatenar/3` espiado, predecir las líneas que escribe
    `perfil(inversa([a, b], [a, b]), R, Cuentas)`, que falla, y cuántas llamadas
    a cada predicado cuenta. Comprobarlo:

    ```prolog
    ?- espiar(concatenar/3), perfil(inversa([a, b], [a, b]), R, Cuentas).
    + concatenar([], [b], [b])
    - concatenar([b], [a], [a, b])
    - concatenar([], [b], A)
    R = falla,
    Cuentas = [concatenar/3-2, inversa/2-3].
    ```
