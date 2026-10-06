# Las correlativas, con una tabla

Esta página contiene una parte de la
[sección 87.6](index.md#876-version-3-evaluar-y-explicar) del
[capítulo 87](index.md): `pasos/3`, la relación tabulada de las
correlativas, y `cadena/3`, que explica cada requisito con la cadena más
corta. El código está en `evaluar.pl`, en `ejemplos/capitulo-87/`, con
sus pruebas.

## Las correlativas, con una tabla

<!-- contexto: capitulo-87/evaluar.pl -->

«¿Qué necesita bases de datos?» pide las correlativas de bases de datos,
las correlativas de esas, y así hasta el final de la cadena. `necesitar/2` se define con `pasos/3`, que
guarda para cada par de materias la menor cantidad de correlativas que
las une. Está escrita con la recursión a la izquierda, que Prolog no
termina sin tabla, y con la subsunción de respuestas `min` de la
[sección 39.3](../capitulo-39-tabulacion/index.md#393-subsuncion-de-respuestas):
la tabla guarda una respuesta por par, la menor, y termina aunque el plan
de estudios tuviera un ciclo, como `requisito/2` de la
[sección 39.7](../capitulo-39-tabulacion/index.md#397-el-interprete-con-tablas-las-correlativas).

<!-- ejemplo: capitulo-87/evaluar.pl predicado: pasos/3 cadena/3 -->
```prolog
%!  pasos(?Materia, ?Requisito, ?N:integer) is nondet.
%
%   Requisito es una correlativa de Materia, directa o a través de otras,
%   y N es la menor cantidad de correlativas de la cadena que las une.
pasos(M, R, 1) :-
    correlativa(M, R).
pasos(M, R, N) :-
    pasos(M, I, N0),
    correlativa(I, R),
    N is N0 + 1.

%!  cadena(+Materia, +Requisito, -Cadena:list) is semidet.
%
%   Cadena es una de las cadenas más cortas de hechos correlativa/2 que
%   lleva de Materia a Requisito. Cada paso elige una correlativa que
%   está un paso más cerca, según pasos/3, así que termina siempre.
cadena(M, R, [correlativa(M, I)|Resto]) :-
    pasos(M, R, N),
    correlativa(M, I),
    (   I == R, N =:= 1
    ->  Resto = []
    ;   N > 1,
        pasos(I, R, N1),
        N1 =:= N - 1
    ->  cadena(I, R, Resto)
    ),
    !.
```

La cantidad de pasos guía la explicación: `cadena/3` elige en cada paso
una correlativa que está un paso más cerca del requisito, y así termina
con una cadena de las más cortas.

```prolog
?- setof(R-N, pasos(bd, R, N), Ps).
Ps = [alg-2, log-2, pp-1, ssl-1].

?- cadena(bd, log, C).
C = [correlativa(bd, pp), correlativa(pp, log)].
```

Las respuestas de una tabla salen en un orden que puede cambiar de una
plataforma a otra; `setof/3` las ordena. La respuesta en castellano
muestra la cadena de cada requisito:

<!-- contexto: capitulo-87/preguntas.pl -->
```prolog
?- preguntar("¿Qué necesita bases de datos?").
álgebra, lógica, paradigmas y sintaxis
  álgebra: correlativa(bd, ssl), correlativa(ssl, alg)
  lógica: correlativa(bd, pp), correlativa(pp, log)
  paradigmas: correlativa(bd, pp)
  sintaxis: correlativa(bd, ssl)
true.
```

Las tablas no siguen los cambios de la base. Si se agrega una correlativa
con `assertz/1`, `pasos/3` sigue dando las respuestas viejas hasta que se
vacían las tablas, o hasta que se declaran incrementales, como en la
[sección 39.5](../capitulo-39-tabulacion/index.md#395-tabulacion-incremental).
