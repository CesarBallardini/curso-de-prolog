# El árbol de preguntas y su compilación

Esta página contiene las secciones
[66.5](index.md#665-version-4-el-arbol-de-preguntas) y
[66.6](index.md#666-version-5-el-arbol-compilado) del
[capítulo 66](index.md): el árbol de preguntas construido a partir de las
reglas colapsadas de la
[sección 66.4](index.md#664-version-3-colapsar-las-reglas), con tres
estrategias medidas, y su compilación en cláusulas, comparada con el
encadenamiento hacia atrás del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md).
Los ejemplos están en `arbol.pl` y `compilado.pl`, en
`ejemplos/capitulo-66/`, con sus pruebas; cargan las versiones anteriores
y se ejecutan localmente.

## Versión 4: el árbol de preguntas

Un **árbol de preguntas** hace una pregunta en cada nodo y sigue por la
rama de la respuesta; en cada hoja hay una hipótesis, o `ninguna`.
`arbol.pl` lo construye a partir de las reglas colapsadas, siguiendo el
procedimiento de Rowe con una diferencia: las reglas de esta base solo
tienen condiciones afirmativas. Una respuesta afirmativa quita la pregunta
de las reglas que la tienen, y las demás siguen en juego; una negativa
descarta las reglas que la tienen. La primera regla que se queda sin
preguntas prueba su hipótesis.

<!-- ejemplo: capitulo-66/arbol.pl predicado: arbol/2 construir/4 -->
```prolog
%!  arbol(+Estrategia, -Arbol) is det.
%
%   Arbol es el árbol de preguntas de las reglas colapsadas, con las
%   preguntas elegidas por Estrategia.
arbol(Estrategia, Arbol) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    construir(Estrategia, Reglas, Prototipos, Arbol).

%!  construir(+Estrategia, +Reglas:list, +Prototipos:list, -Arbol) is det.
%
%   Arbol decide entre Reglas, pares Hipotesis-Preguntas: la hoja de la
%   primera regla sin preguntas, hoja(ninguna) si no queda ninguna regla,
%   o una pregunta con un subárbol para cada respuesta. Prototipos son los
%   pares Hipotesis-Observaciones que llegan al nodo; solo los usa la
%   estrategia informacion.
construir(Estrategia, Reglas, Prototipos, Arbol) :-
    (   Reglas == []
    ->  Arbol = hoja(ninguna)
    ;   memberchk(H-[], Reglas)
    ->  Arbol = hoja(H)
    ;   elegir(Estrategia, Reglas, Prototipos, P),
        Arbol = pregunta(P, Si, No),
        maplist(sin_pregunta(P), Reglas, ReglasSi),
        exclude(con_pregunta(P), Reglas, ReglasNo),
        partition(prototipo_si(P), Prototipos, PrototiposSi, PrototiposNo),
        construir(Estrategia, ReglasSi, PrototiposSi, Si),
        construir(Estrategia, ReglasNo, PrototiposNo, No)
    ).
```

La **estrategia** elige la pregunta de cada nodo. `orden` toma la primera
pregunta de la primera regla que queda, que es lo que haría el
encadenamiento hacia atrás. `frecuente` toma la que aparece en más reglas,
el primer criterio de Rowe. `informacion` usa la **ganancia de
información** del algoritmo ID3 de Quinlan sobre una población de
**prototipos**, un animal por regla colapsada con las observaciones justas
para cumplirla: la entropía de las hipótesis de los prototipos que llegan
al nodo menos la entropía media que queda después de la respuesta,

$$
G(P) = H(S) - \frac{|S_{si}|}{|S|}\,H(S_{si}) - \frac{|S_{no}|}{|S|}\,H(S_{no}),
\qquad H(S) = -\sum_h q_h \log_2 q_h ,
$$

donde $q_h$ es la fracción de los prototipos de $S$ que son de la hipótesis
$h$.

<!-- ejemplo: capitulo-66/arbol.pl predicado: elegir/4 ganancia/3 entropia/2 -->
```prolog
%!  elegir(+Estrategia, +Reglas:list, +Prototipos:list, -P) is det.
%
%   P es la pregunta que Estrategia elige para decidir entre Reglas, que
%   no es vacía. Entre preguntas empatadas, la primera que aparece.
%   Cuando ninguna pregunta separa los prototipos, informacion elige como
%   orden.
elegir(orden, [_-[P|_]|_], _, P).
elegir(frecuente, Reglas, _, P) :-
    foldl(agregar_preguntas, Reglas, [], Candidatas),
    maplist(cuantas(Reglas), Candidatas, Valores),
    primera_mejor(Valores, Candidatas, P).
elegir(informacion, Reglas, Prototipos, P) :-
    foldl(agregar_preguntas, Reglas, [], Candidatas),
    maplist(ganancia(Prototipos), Candidatas, Valores),
    max_list(Valores, Maximo),
    (   Maximo > 1.0e-9
    ->  primera_mejor(Valores, Candidatas, P)
    ;   elegir(orden, Reglas, Prototipos, P)
    ).

%!  ganancia(+Prototipos:list, +P, -G:float) is det.
%
%   G es la información, en bits, que la respuesta a P da sobre la
%   hipótesis de los Prototipos: la entropía de sus hipótesis menos la
%   entropía media que queda en cada rama.
ganancia(Prototipos, P, G) :-
    partition(prototipo_si(P), Prototipos, Si, No),
    length(Prototipos, N),
    length(Si, NSi),
    length(No, NNo),
    entropia(Prototipos, H),
    entropia(Si, HSi),
    entropia(No, HNo),
    G is H - (NSi * HSi + NNo * HNo) / max(N, 1).

%!  entropia(+Prototipos:list, -H:float) is det.
%
%   H es la entropía, en bits, de las hipótesis de Prototipos; 0.0 para
%   una lista vacía.
entropia(Prototipos, H) :-
    length(Prototipos, N),
    pairs_keys(Prototipos, Hs),
    msort(Hs, Ordenadas),
    clumped(Ordenadas, Cuentas),
    foldl(sumar_plogp(N), Cuentas, 0.0, S),
    H is -S.
```

Cuando los prototipos que llegan a un nodo son todos de la misma
hipótesis, ninguna pregunta da información sobre ellos, pero el árbol
todavía tiene que confirmar la regla; ahí `informacion` elige como
`orden`. `consultar/4` recorre el árbol con las respuestas de una lista, y
`consulta/4` construye el árbol de una estrategia y lo consulta:

<!-- ejemplo: capitulo-66/arbol.pl predicado: consultar/4 consulta/4 -->
```prolog
%!  consultar(+Arbol, +Fuente, -Hipotesis, -Preguntas:list) is det.
%
%   Recorre Arbol con las respuestas de Fuente, lista(Observaciones), hasta
%   una hoja: Hipotesis es la de la hoja y Preguntas, las que se hicieron,
%   en orden.
consultar(hoja(H), _, H, []).
consultar(pregunta(P, Si, No), Fuente, H, [P|Ps]) :-
    (   responde_si(Fuente, P)
    ->  consultar(Si, Fuente, H, Ps)
    ;   consultar(No, Fuente, H, Ps)
    ).

%!  consulta(+Estrategia, +Observaciones:list, -Hipotesis,
%!           -Preguntas:list) is det.
%
%   Consulta el árbol de Estrategia con las respuestas de Observaciones.
consulta(Estrategia, Observaciones, Hipotesis, Preguntas) :-
    arbol(Estrategia, Arbol),
    consultar(Arbol, lista(Observaciones), Hipotesis, Preguntas).
```

```prolog
?- caso(1, Os), consulta(orden, Os, H, Ps).
Os = Ps, Ps = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
H = guepardo.

?- caso(5, Os), consulta(orden, Os, H, Ps).
Os = [tiene_pelo, tiene_cascos],
H = ninguna,
Ps = [tiene_pelo, come_carne, tiene_cascos, cuello_largo, rayas_negras, tiene_plumas, vuela].
```

El caso 5, pelo y cascos, es un ungulado sin rasgos de ninguna especie
conocida: el árbol lo descarta con siete preguntas. Ninguna consulta pasa
de catorce, una por pregunta distinta, porque cada pregunta sale de las
reglas en cuanto se responde.

`medir/4` da el tamaño del árbol de cada estrategia y la cantidad media
de preguntas en dos poblaciones: los doce prototipos, y los 24 576
animales que genera `observaciones/1`, todas las combinaciones de las trece
observaciones sin valor con tres pesos posibles. La segunda población es
casi toda imposible, un animal con plumas, cascos y rayas, pero es la que
pone a prueba el árbol en todas sus ramas.

<!-- ejemplo: capitulo-66/arbol.pl predicado: medidas/2 medir/4 promedio/3 -->
```prolog
%!  medidas(+Arbol, -Medidas) is det.
%
%   Medidas es m(Preguntas, Hojas, Profundidad): los nodos que preguntan,
%   las hojas y la mayor cantidad de preguntas de una consulta.
medidas(hoja(_), m(0, 1, 0)).
medidas(pregunta(_, Si, No), m(N, H, P)) :-
    medidas(Si, m(N1, H1, P1)),
    medidas(No, m(N2, H2, P2)),
    N is N1 + N2 + 1,
    H is H1 + H2,
    P is max(P1, P2) + 1.

%!  medir(?Estrategia, -Medidas, -EnPrototipos:float,
%!        -EnTodos:float) is nondet.
%
%   Medidas son las del árbol de Estrategia, y EnPrototipos y EnTodos, la
%   cantidad media de preguntas que hace para cada población.
medir(Estrategia, Medidas, EnPrototipos, EnTodos) :-
    estrategia(Estrategia),
    arbol(Estrategia, Arbol),
    medidas(Arbol, Medidas),
    promedio(Arbol, prototipos, EnPrototipos),
    promedio(Arbol, todos, EnTodos).

%!  promedio(+Arbol, +Poblacion, -Promedio:float) is det.
%
%   Promedio es la cantidad media de preguntas que hace Arbol para los
%   animales de Poblacion, con dos decimales: prototipos, uno por regla
%   colapsada, o todos, los de observaciones/1.
promedio(Arbol, Poblacion, Promedio) :-
    aggregate_all(count-sum(N),
                  ( poblacion(Poblacion, Os),
                    consultar(Arbol, lista(Os), _, Ps),
                    length(Ps, N) ),
                  Total-Suma),
    Promedio is round(100 * Suma / Total) / 100.0.
```

```prolog
?- medir(E, M, P1, P2).
E = orden,
M = m(165, 166, 14),
P1 = 5.67,
P2 = 6.05 ;
E = frecuente,
M = m(178, 179, 14),
P1 = 6.17,
P2 = 5.96 ;
E = informacion,
M = m(209, 210, 14),
P1 = 5.67,
P2 = 6.5.
```

| Estrategia | Preguntas del árbol | Hojas | Máximo | Media, prototipos | Media, todos |
|---|---|---|---|---|---|
| `orden` | 165 | 166 | 14 | 5,67 | 6,05 |
| `frecuente` | 178 | 179 | 14 | 6,17 | 5,96 |
| `informacion` | 209 | 210 | 14 | 5,67 | 6,50 |

El resultado contradice la intuición de que la pregunta más informativa
siempre gana. Para los prototipos, `orden` ya es óptimo: una búsqueda
exhaustiva de todos los árboles, que hace el [ejercicio 8](index.md#ejercicios)
con tabulación, da como mínimo 68 preguntas para los doce, 5,67 por
animal. La razón está en la forma de las reglas: confirmar una hipótesis
exige preguntar todas las condiciones de una de sus reglas, en cualquier
orden, y lo único que una estrategia puede ahorrar son las preguntas que
descartan. `informacion` iguala a `orden` en los prototipos, para los que
fue calculada, y es la peor en la población completa, que no vio;
`frecuente`, que no mira ninguna población, es la mejor en esa. Qué
pregunta conviene hacer primero depende de qué animales van a llegar: el
[ejercicio 9](index.md#ejercicios) pesa los prototipos por su frecuencia.

La prueba `igual_que_33` de `arbol.plt` recorre los 24 576 animales con los
tres árboles y comprueba que la hoja es siempre una hipótesis que el
sistema del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md)
prueba, o `ninguna` cuando no prueba ninguna.

!!! question "Actividad"
    Predecir qué preguntas hace el árbol `orden` con el caso 2,
    `[da_leche, tiene_cascos, rayas_negras]`, y por qué la primera es
    `tiene_pelo` aunque la cebra del caso da leche. Comprobarlo con
    `consulta/4` y compararlo con las de `informacion`.

## Versión 5: el árbol compilado

El árbol es un término, y consultarlo es recorrerlo. Rowe propone
convertirlo en código: un nombre para cada nodo y una regla por nodo que
elige el siguiente según la respuesta. `compilado.pl` lo hace al cargar el
archivo, con `term_expansion/2`, como el
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md#357-las-reglas-compiladas)
convierte las reglas en cláusulas: el término `arbol_compilado(orden)` del
archivo se expande en las cláusulas de `nodo/3`, una por nodo, numerados
en preorden. Es el
[Patrón 49](../patrones.md#49-expandir-al-cargar), y el resultado es un
intérprete de árboles especializado en un árbol, como pide el
[Patrón 50](../patrones.md#50-especializar-el-interprete).

<!-- ejemplo: capitulo-66/compilado.pl predicado: term_expansion/2 clausulas//3 -->
```prolog
%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Expande arbol_compilado(Estrategia) en las cláusulas de nodo/3 del
%   árbol de Estrategia.
term_expansion(arbol_compilado(Estrategia), Clausulas) :-
    arbol(Estrategia, Arbol),
    phrase(clausulas(Arbol, 1, _), Clausulas).

%!  clausulas(+Arbol, +N:integer, -Siguiente:integer)// is det.
%
%   Las cláusulas de nodo/3 de Arbol, cuya raíz es el nodo N; Siguiente es
%   el primer número libre después de sus nodos.
clausulas(hoja(H), N, Siguiente) -->
    { Siguiente is N + 1 },
    [ nodo(N, _, H) ].
clausulas(pregunta(P, Si, No), N, Siguiente) -->
    { NSi is N + 1 },
    [ ( nodo(N, Fuente, H) :-
            (   responde(Fuente, P)
            ->  nodo(NSi, Fuente, H)
            ;   nodo(NNo, Fuente, H)
            ) ) ],
    clausulas(Si, NSi, NNo),
    clausulas(No, NNo, Siguiente).
```

La gramática emite la cláusula de un nodo antes de generar sus hijos, y
el número del hijo negativo, `NNo`, queda libre en la cláusula hasta que
la numeración del subárbol afirmativo lo liga: una variable lógica como
etiqueta, igual que en el ensamblador del
[capítulo 45](../capitulo-45-proyecto-compilador/index.md).

```prolog
?- clause(nodo(1, F, H), Cuerpo).
Cuerpo = (responde(F, tiene_pelo)->nodo(2, F, H);nodo(157, F, H)).

?- aggregate_all(count, clause(nodo(_, _, _), _), N).
N = 331.
```

La **fuente** de las respuestas es un argumento: `lista(Os)` responde con
las observaciones; `usuario` pregunta y lee la respuesta con `read/1`. Una
pregunta con una comparación pide el valor y la comparación decide.

<!-- ejemplo: capitulo-66/compilado.pl predicado: identificar_compilado/2 consulta_interactiva/1 responde/2 -->
```prolog
%!  identificar_compilado(+Observaciones:list, -Hipotesis) is det.
%
%   Hipotesis es la que da el árbol compilado con las respuestas de
%   Observaciones, o ninguna.
identificar_compilado(Observaciones, Hipotesis) :-
    nodo(1, lista(Observaciones), Hipotesis).

%!  consulta_interactiva(-Hipotesis) is det.
%
%   Recorre el árbol compilado con las respuestas del usuario, leídas de
%   la entrada actual, y le dice el resultado.
consulta_interactiva(Hipotesis) :-
    nodo(1, usuario, Hipotesis),
    (   Hipotesis == ninguna
    ->  format("Con tus respuestas no se identifica ningún animal.~n")
    ;   format("Tu animal es: ~w.~n", [Hipotesis])
    ).

%!  responde(+Fuente, +Pregunta) is semidet.
%
%   La respuesta de Fuente a Pregunta es afirmativa. Con el usuario, una
%   pregunta sobre un valor pide el valor, y la comparación decide.
responde(lista(Observaciones), Pregunta) :-
    responde_si(lista(Observaciones), Pregunta).
responde(usuario, Pregunta) :-
    (   Pregunta = (Observacion y Comparacion)
    ->  Observacion =.. [Nombre, Valor],
        format("¿Cuánto vale ~w? Responde con un número, o no. ",
               [Nombre]),
        read(Respuesta),
        number(Respuesta),
        \+ \+ ( Valor = Respuesta,
                call(Comparacion) )
    ;   format("¿~w? Responde si o no. ", [Pregunta]),
        read(Respuesta),
        Respuesta == si
    ).
```

La consulta con el usuario se prueba con las respuestas leídas de una
cadena, como en el
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica):

```prolog
test(interactiva, [true(H-S == guepardo-"¿tiene_pelo? Responde si o no. \c
    ¿come_carne? Responde si o no. ¿color_leonado? Responde si o no. \c
    ¿manchas_oscuras? Responde si o no. Tu animal es: guepardo.\n")]) :-
    con_entrada("si. si. si. si.",
                with_output_to(string(S), consulta_interactiva(H))).
```

Para comparar con el encadenamiento hacia atrás hacen falta las preguntas
que hace `consultar/1` del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica)
con las mismas respuestas. Ese intérprete lee del teclado, y qué pregunta
viene depende de las respuestas anteriores, así que no se le puede dar una
lista preparada de antemano. `preguntas_encadenando/2` la construye de a
una: consulta con las respuestas que tiene; cuando la entrada se acaba, la
pregunta que quedó sin respuesta aparece en `respondida/2` con
`end_of_file`, recibe la respuesta de las observaciones y la consulta se
repite desde el principio.

<!-- ejemplo: capitulo-66/compilado.pl predicado: preguntas_encadenando/2 repetir/3 -->
```prolog
%!  preguntas_encadenando(+Observaciones:list, -Preguntas:list) is det.
%
%   Preguntas son las que hace consultar/1 del capítulo 33 hasta la
%   primera hipótesis, cuando el usuario responde según Observaciones. La
%   consulta se repite: cada vez que la entrada se acaba, la pregunta que
%   quedó sin respuesta recibe la de Observaciones y se vuelve a empezar.
preguntas_encadenando(Observaciones, Preguntas) :-
    repetir(Observaciones, [], Preguntas).

%!  repetir(+Observaciones:list, +Respuestas:list, -Preguntas:list) is det.
%
%   Consulta con Respuestas como entrada; si faltó una, la agrega y
%   repite.
repetir(Observaciones, Respuestas, Preguntas) :-
    with_output_to(string(Texto),
                   forall(member(R, Respuestas),
                          format("~q. ", [R]))),
    setup_call_cleanup(
        open_string(Texto, Entrada),
        with_output_to(string(_),
                       consultar_con(Entrada)),
        close(Entrada)),
    findall(P-R, user:respondida(P, R), Pares),
    retractall(user:respondida(_, _)),
    (   member(P-end_of_file, Pares)
    ->  respuesta(Observaciones, P, R),
        append(Respuestas, [R], Respuestas1),
        repetir(Observaciones, Respuestas1, Preguntas)
    ;   pairs_keys(Pares, Preguntas)
    ).
```

```prolog
?- caso(3, Os), preguntas_encadenando(Os, Ps).
Os = [tiene_plumas, no_vuela, peso(90)],
Ps = [tiene_pelo, da_leche, tiene_plumas, no_vuela, nada, vuela, peso(_)].

?- caso(3, Os), identificar_compilado(Os, H).
Os = [tiene_plumas, no_vuela, peso(90)],
H = avestruz.
```

El encadenamiento pregunta `vuela`: al fallar `nada` para el pingüino,
retrocede y busca otra prueba de `ave`, con la regla r4, aunque una
segunda prueba de ave no puede hacer nadar al animal. El árbol llega al
avestruz con seis preguntas. Las mediciones, con el árbol `orden`:

| | Encadenamiento ([capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md)) | Árbol |
|---|---|---|
| preguntas, doce prototipos | 72 | 68 |
| preguntas, casos 1 a 5 | 4, 6, 7, 5, 8 | 4, 6, 6, 5, 7 |
| inferencias, 24 576 animales | 6 697 856 | 2 089 511 (interpretado), 2 262 662 (compilado) |

Las inferencias salen de `time/1` sobre la lista de todos los animales,
con la primera hipótesis de `identificar/2` como respuesta del
encadenamiento. El árbol hace un tercio del trabajo, porque no busca
reglas ni retrocede; la prueba `igual_que_33` de `compilado.plt` comprueba
además que el árbol compilado da exactamente la primera hipótesis de
`identificar/2` para los 24 576. Compilarlo no reduce las inferencias: el
costo está en responder cada pregunta con `demostrar/4`, no en recorrer el
término. Lo que se gana es un programa sin el árbol ni las reglas: el
[ejercicio 10](index.md#ejercicios) escribe las cláusulas en un archivo que se
carga solo.

!!! question "Actividad"
    Predecir cuántas preguntas hacen el encadenamiento y el árbol con el
    caso 5, `[tiene_pelo, tiene_cascos]`, y cuál pregunta de más el
    encadenamiento. Comprobarlo con `preguntas_encadenando/2` y
    `consulta/4`.
