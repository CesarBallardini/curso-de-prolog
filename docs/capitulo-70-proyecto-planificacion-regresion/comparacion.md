# El mundo del capítulo 40

Esta página contiene la versión 4 del [capítulo 70](index.md), la
[sección 70.6](index.md#706-version-4-el-mundo-del-capitulo-40): los operadores STRIPS del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) traducidos a la descripción que usa WARPLAN, y la
comparación de los dos planificadores sobre el mismo mundo. Los ejemplos
son `pinza.pl` y `sin_pinza.pl`, en `ejemplos/capitulo-70/`, con sus
pruebas; cargan archivos de ese capítulo y se ejecutan en una instalación
local.

## El mundo del capítulo 40

`strips.pl`, del [capítulo 40](../capitulo-40-busqueda-y-planificacion/planificacion.md#planificacion-operadores-strips-y-analisis-de-medios-y-fines),
describe el mundo de bloques con pinza de otra manera: cada acción es un
operador STRIPS con sus precondiciones y las listas de lo que agrega y lo
que borra, y las acciones se generan sin variables. `pinza.pl` carga ese
archivo en un módulo propio, `mf`, con `load_files/2`, como la
[sección 43.2](../capitulo-43-proyecto-resolver-ecuaciones/index.md#432-version-1-el-aislamiento), y traduce: una acción agrega los hechos
de su lista `Agrega` y borra los de su lista `Borra`. El mundo no se copia;
el planificador de medios y fines del mismo archivo queda disponible como
`medios_fines/3`:

<!-- ejemplo: capitulo-70/pinza.pl predicado: agrega/2 borra/2 puede/2 dado/2 medios_fines/3 -->
```prolog
%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que agrega el operador de Accion.
agrega(Hecho, Accion) :-
    mf:operador(Accion, _, Agrega, _),
    member(Hecho, Agrega).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que borra el operador de Accion.
borra(Hecho, Accion) :-
    mf:operador(Accion, _, _, Borra),
    member(Hecho, Borra).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Precondiciones son las del operador de Accion.
puede(Accion, Pre) :-
    mf:operador(Accion, Pre, _, _).

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio; sussman es el estado inicial
%   de la anomalía en el capítulo 40.
dado(sussman, Hecho) :-
    mf:sussman(Estado),
    member(Hecho, Estado).

%!  medios_fines(+Inicio, +Metas:list, -Plan:list) is semidet.
%
%   Plan es el primer plan que da el planificador de medios y fines del
%   capítulo 40, con su cota de longitud, desde el estado inicial Inicio.
medios_fines(sussman, Metas, Plan) :-
    mf:sussman(Estado),
    once(mf:planificar(Estado, Metas, Plan)).
```

Con pinza, los dos planificadores dan el mismo plan de seis acciones:

<!-- contexto: capitulo-70/pinza.pl -->
```prolog
?- once(planificar(pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan)).
Plan = [desapilar(c, a), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].

?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).
Plan = [desapilar(c, a), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].
```

`sin_pinza.pl` hace lo mismo con el mundo sin pinza de la solución del
[ejercicio 10 del capítulo 40](../capitulo-40-busqueda-y-planificacion/soluciones.md#10), que es el de los cubos con
otra descripción. Allí aparece la diferencia:

<!-- contexto: capitulo-70/sin_pinza.pl -->
```prolog
?- once(planificar(sin_pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan)).
Plan = [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)].

?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).
Plan = [mover(c, a, mesa), mover(b, mesa, a), mover(b, a, c), mover(a, mesa, b)].
```

Las mediciones, en esta máquina y con las bibliotecas ya cargadas:

| Mundo | Metas | WARPLAN | Medios y fines |
|---|---|---|---|
| con pinza | `sobre(a, b)`, `sobre(b, c)` | 6 acciones, 115 765 inferencias | 6 acciones, 130 827 inferencias |
| sin pinza | `sobre(a, b)`, `sobre(b, c)` | 3 acciones, 11 530 inferencias | 4 acciones, 17 076 inferencias |
| sin pinza | `sobre(b, c)`, `sobre(a, b)` | 3 acciones, 10 640 inferencias | 4 acciones, 13 786 inferencias |
| cubos (con variables) | `sobre(a, b)`, `sobre(b, c)` | 3 acciones, 5 455 inferencias | — |

Con pinza, la intercalación no hace falta: el plan de medios y fines ya es
el más corto, y los dos cuestan lo mismo. Sin pinza, WARPLAN da el plan de
tres acciones que el análisis de medios y fines no puede construir, y
cuesta menos. La última fila es el mismo mundo y el mismo planificador con
la descripción de `cubos.pl`: menos de la mitad de las inferencias. Los operadores del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) generan cada acción sin variables, y para lograr
`libre(a)` el planificador prueba cada bloque y cada destino; con
`mover(U, a, W)`, la precondición `sobre(U, a)` liga U al cubo que
realmente está sobre a. Sin la cota, con los operadores de ese capítulo,
con pinza y sin ella, la búsqueda de WARPLAN agota la pila: la
descripción con variables es la que el algoritmo de Warren supone.
