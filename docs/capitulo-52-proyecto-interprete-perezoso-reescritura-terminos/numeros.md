# Números de descripción

Esta página contiene la
[sección 52.6](index.md#526-numeros-de-descripcion) del
[capítulo 52](index.md): la forma estándar de una máquina, su descripción
estándar y su número de descripción, de la sección 5 del artículo de
Turing. Los ejemplos están en `numeros.pl`, en `ejemplos/capitulo-52/`, con
sus pruebas; el módulo carga la versión 5, `completa.pl`, y usa su
expansión.

## La forma estándar

En la sección 5 Turing lleva cada tabla a una **forma estándar**, en la
que cada instrucción imprime un símbolo —el mismo que lee, si no cambia
nada— y después mueve el cabezal a la izquierda, a la derecha o no lo
mueve. Una fila con más operaciones se parte en varias, con
configuraciones nuevas. `numeros.pl` escribe la instrucción estándar como
`e(W, Mov)` y nombra cada configuración auxiliar con un término,
`resto(Ops, Q1)`: la que todavía tiene que ejecutar las operaciones Ops y
después pasar a Q1. La expansión de la versión 5 la trata como a
cualquier otra, con `estandar/5` como relación de paso:

<!-- ejemplo: capitulo-52/numeros.pl predicado: estandar/5 grupo/5 -->
```prolog
%!  estandar(+M, +Q, +S, -Accion, -Q1) is semidet.
%
%   Desde Q leyendo S, la máquina M ejecuta la instrucción estándar
%   Accion = e(W, Mov) y pasa a Q1. Q puede ser una configuración de M o
%   una auxiliar resto(Ops, Q2).
estandar(M, Q, S, e(W, Mov), Q1) :-
    (   Q = resto(Ops, Q2)
    ->  true
    ;   transicion(M, Q, S, Ops, Q2)
    ),
    grupo(Ops, S, W, Mov, Resto),
    (   Resto == []
    ->  Q1 = Q2
    ;   Q1 = resto(Resto, Q2)
    ).

%!  grupo(+Ops0:list, +S, -W, -Mov, -Ops:list) is det.
%
%   La primera instrucción estándar de las operaciones Ops0, leyendo S,
%   imprime W y mueve Mov; quedan las operaciones Ops.
grupo(Ops0, S, W, Mov, Ops) :-
    (   Ops0 = [p(X)|Ops1]
    ->  W = X
    ;   Ops0 = [e|Ops1]
    ->  W = blanco
    ;   W = S,
        Ops1 = Ops0
    ),
    (   Ops1 = [l|Ops]
    ->  Mov = l
    ;   Ops1 = [r|Ops]
    ->  Mov = r
    ;   Mov = n,
        Ops = Ops1
    ).
```

## La descripción estándar y el número

La tabla estándar de la máquina II tiene 15 configuraciones y 70
instrucciones: la fila inicial, de diez operaciones, se parte en seis.
Después, Turing numera las configuraciones desde q₁, la inicial, y los
símbolos desde S₀, el blanco, con S₁ = 0 y S₂ = 1; escribe cada
instrucción con la letra D seguida de A repetida i veces para qᵢ y de C
repetida j veces para Sⱼ, y obtiene la **descripción estándar**. Una
gramática del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) la
escribe:

<!-- ejemplo: capitulo-52/numeros.pl predicado: instrucciones//3 letras//2 -->
```prolog
%!  instrucciones(+Is:list, +Es:list, +Ss:list)// is det.
%
%   Las instrucciones Is escritas en la descripción estándar, con las
%   configuraciones numeradas por su posición en Es y los símbolos por
%   su posición en Ss, desde 0.
instrucciones([], _, _) -->
    [].
instrucciones([i(Q, S, e(W, Mov), Q1)|Is], Es, Ss) -->
    { once(nth1(I, Es, Q)),
      once(nth0(J, Ss, S)),
      once(nth0(K, Ss, W)),
      once(nth1(N, Es, Q1))
    },
    "D", letras(0'A, I), "D", letras(0'C, J), "D", letras(0'C, K),
    movimiento(Mov),
    "D", letras(0'A, N), ";",
    instrucciones(Is, Es, Ss).

%!  letras(+C, +N:integer)// is det.
%
%   N veces el carácter de código C.
letras(C, N) -->
    (   { N =:= 0 }
    ->  []
    ;   [C],
        { N1 is N - 1 },
        letras(C, N1)
    ).
```

Reemplazando A, C, D, L, R, N y ; por 1 a 7 se obtiene el **número de
descripción**, un entero que describe la máquina entera:

```prolog
?- descripcion(i, b, [0, 1], SD).
SD = "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;".

?- numero(i, b, [0, 1], N).
N = 31332531173113353111731113322531111731111335317.
```

Los dos son los que Turing calcula para la máquina I al final de la
sección 5. Las configuraciones se numeran en el orden de la expansión, y
por eso el número depende también de él; Turing señala que una misma
sucesión tiene muchos números de descripción. La tabla de `contador` no
tiene número: `numero/4` falla, porque su tabla completa no termina. A
partir de aquí el artículo construye la máquina universal, que lee la
descripción estándar de otra máquina en su cinta y calcula lo mismo que
ella; el ejercicio 9 da un paso en esa dirección, en Prolog: ejecuta una
máquina a partir de su número.
