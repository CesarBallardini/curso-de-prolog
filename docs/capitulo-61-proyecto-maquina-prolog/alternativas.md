# Una pila de alternativas

Esta página contiene la [sección 61.3](index.md#613-una-pila-de-alternativas) del
[capítulo 61](index.md): la segunda versión de la máquina, que convierte la
búsqueda en un ciclo sobre una pila de alternativas. El ejemplo es
`alternativas.pl`, en `ejemplos/capitulo-61/`, con sus pruebas; carga el
módulo `programas`, y se ejecuta localmente.

## La búsqueda como un ciclo

La segunda versión, `alternativas.pl`, sigue el primer planteo de Spivey: la
búsqueda en profundidad es un ciclo sobre una lista de resolventes, en el
que cada paso reemplaza la primera por todas las que se derivan de ella en un
paso de resolución, y deja las demás detrás. Cada alternativa es
`alt(Metas, R)`: una resolvente y la instancia de la consulta que le
corresponde, con variables propias, porque `findall/3` copia cada una:

<!-- ejemplo: capitulo-61/alternativas.pl predicado: buscar/4 desde/6 expandir/5 -->
```prolog
%!  buscar(+Pila:list, +Clausulas:list, +Medidas, -Evento) is multi.
%
%   Evento es, en orden, respuesta(R) por cada respuesta R que se obtiene
%   de la Pila de alternativas, y por último fin(Medidas).
buscar([], _, Medidas, fin(Medidas)).
buscar([alt(Metas, R)|Pila], Clausulas, Medidas, Evento) :-
    desde(Metas, R, Pila, Clausulas, Medidas, Evento).

%!  desde(+Metas:list, +R, +Pila:list, +Clausulas:list, +Medidas,
%!        -Evento) is multi.
%
%   Continúa la búsqueda con la alternativa Metas, cuya consulta es R,
%   encima de la Pila.
desde([], R, Pila, Clausulas, Medidas, Evento) :-
    (   Evento = respuesta(R)
    ;   buscar(Pila, Clausulas, Medidas, Evento)
    ).
desde([Meta|Metas], R, Pila, Clausulas, Medidas0, Evento) :-
    clase(Meta, Clase),
    expandir(Clase, Metas, R, Clausulas, Nuevas),
    append(Nuevas, Pila, Pila1),
    contar(Clase, Nuevas, Pila1, Medidas0, Medidas),
    buscar(Pila1, Clausulas, Medidas, Evento).

%!  expandir(+Clase, +Metas:list, +R, +Clausulas:list, -Nuevas:list)
%!      is det.
%
%   Nuevas son las alternativas que resultan de probar una meta de la
%   Clase dada, seguida de Metas, con la consulta R: ninguna, una o una
%   por cada cláusula cuya cabeza unifica con la meta.
expandir(verdad, Metas, R, _, [alt(Metas, R)]).
expandir(conjuncion(A, B), Metas, R, _, [alt([A, B|Metas], R)]).
expandir(corte, Metas, R, _, [alt(Metas, R)]).
expandir(predefinida(Meta), Metas, R, _, Nuevas) :-
    (   ejecutar(Meta)
    ->  Nuevas = [alt(Metas, R)]
    ;   Nuevas = []
    ).
expandir(usuario(Meta), Metas, R, Clausulas, Nuevas) :-
    findall(alt([Cuerpo|Metas], R),
            ( member(Clausula, Clausulas),
              copy_term(Clausula, (Meta :- Cuerpo))
            ),
            Nuevas).
```

El ciclo no deja puntos de elección de Prolog, salvo el de la disyunción de
`desde/6`, que entrega las respuestas de a una y es lo que ve el nivel
superior. La máquina ya tiene las alternativas como datos; su problema es el
precio. Cada alternativa es una copia completa de la resolvente, y en
`suma_hasta(N, S)` la resolvente contiene la lista de `N` números que se
está sumando. `medir/3` cuenta las celdas que `findall/3` copió, medidas con
`term_size/2`:

```prolog
?- medir(listas, suma_hasta(100, S), M).
M = [pasos-810, respuestas-1, alternativas-2, copiado-37229].

?- medir(listas, suma_hasta(200, S), M).
M = [pasos-1610, respuestas-1, alternativas-2, copiado-134329].
```

Al duplicar la lista, los pasos se duplican y lo copiado se multiplica por
3,6: el costo de cada paso crece con el largo de lo que queda por sumar, y el
total es cuadrático. En tiempo, medido en la máquina donde se escribió el
capítulo, `suma_hasta(8000, S)` tarda 6,7 segundos en esta versión y 1,8 en
la versión 5.

!!! question "Actividad"
    Predecir el valor de `copiado` para `suma_hasta(400, S)` a partir de las
    dos cifras anteriores, y comprobarlo. ¿Qué parte de la resolvente se
    copia en cada paso, y por qué no se puede compartir entre dos
    alternativas mientras sus variables sean variables de Prolog?
