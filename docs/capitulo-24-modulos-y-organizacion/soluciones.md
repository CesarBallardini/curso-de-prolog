# Soluciones del capítulo 24 — Módulos y organización

El código de esta página está en `ejemplos/capitulo-24/soluciones/`, un
archivo por módulo, cada uno con su archivo de pruebas, y pasa sus pruebas.
Los módulos que usan el proyecto lo cargan de
`ejemplos/capitulo-24/inscripciones/` con una ruta relativa.

## 1

| Consulta | Respuesta | Por qué |
|---|---|---|
| `alumno(101, N, _, _).` | `N = ana.` | `datos` exporta `alumno/4`, y cargar el módulo lo importa |
| `requisitos_de(am2, R).` | un error de existencia | `requisitos_de/2` es de `reglas`, que no se cargó |
| `reglas:requisitos_de(am2, R).` | un error de existencia | calificar no carga el módulo: `reglas` no existe todavía |

La calificación dice en qué módulo buscar, pero el módulo tiene que estar
cargado. Con `inscripciones.pl` cargado, las dos últimas responden
`R = [alg, am1]`.

## 2

`use_module(informes, [ranking/1])` carga el módulo entero, pero importa solo
`ranking/1`. `ranking(R)` responde el ranking; `mejores(2, R)` produce un error
de existencia: `mejores/2` está cargado, en el módulo `informes`, pero no
importado. `informes:mejores(2, R)` lo encuentra.

## 3

<!-- ejemplo: capitulo-24/soluciones/familia.pl fragmento: :- module(familia .. padre(P, N). consulta: abuelo(juan, N). -->
```prolog
:- module(familia, [abuelo/2]).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
```

La prueba `privado` verifica que `padre/2` no existe fuera del módulo, y
`calificado` que `familia:padre(juan, H)` lo encuentra:

```prolog
% padre/2 no se exporta: sin calificar, no existe fuera del módulo.
test(privado, [error(existence_error(procedure, _), _)]) :-
    call(padre(_, _)).
```

`call/1` hace que la llamada ocurra al ejecutar la prueba: escrita
directamente, `padre(_, _)` produciría una advertencia al cargar el archivo de
pruebas, porque el predicado no existe.

## 4

Un módulo `choque` que importa enteros `saludo_a` y `saludo_b`, que exportan los
dos `saludo/1`, produce un error al cargarse:

```text
ERROR:    import/1: No permission to import saludo_b:saludo/1 into choque (already imported from saludo_a)
```

Hay tres salidas: importar uno solo de los dos con `use_module/2`, calificar las
llamadas al segundo, o importarlo con otro nombre:

<!-- ejemplo: capitulo-24/soluciones/sin_choque.pl fragmento: :- module(sin_choque .. despedida(D). consulta: saludos(L). -->
```prolog
:- module(sin_choque, [saludos/1]).

:- use_module(saludo_a).
:- use_module(saludo_b, [saludo/1 as despedida]).

%!  saludos(-L:list) is det.
%
%   L tiene el saludo de cada módulo.
saludos([S, D]) :-
    saludo(S),
    despedida(D).
```

## 5

<!-- ejemplo: capitulo-24/soluciones/utiles.pl fragmento: :- module(utiles .. length(Cumplen, N). consulta: contar_cumplen(integer, [1, a, 2], N). -->
```prolog
:- module(utiles, [contar_cumplen/3]).

:- meta_predicate
    contar_cumplen(1, +, -).

%!  contar_cumplen(:Condicion, +L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L que cumplen Condicion. Condicion se
%   llama en el módulo que llama a contar_cumplen/3.
contar_cumplen(Condicion, L, N) :-
    include(Condicion, L, Cumplen),
    length(Cumplen, N).
```

<!-- ejemplo: capitulo-24/soluciones/usa_utiles.pl fragmento: :- module(usa_utiles .. contar_cumplen(par, L, N). consulta: cuantos_pares([1, 2, 3, 4], N). -->
```prolog
:- module(usa_utiles, [cuantos_pares/2]).

:- use_module(utiles).

%!  par(+N:integer) is semidet.
%
%   N es par.
par(N) :-
    0 =:= N mod 2.

%!  cuantos_pares(+L:list(integer), -N:integer) is det.
%
%   N es la cantidad de números pares de L.
cuantos_pares(L, N) :-
    contar_cumplen(par, L, N).
```

`par/1` es privado de `usa_utiles`. Con la declaración `meta_predicate`,
`contar_cumplen/3` recibe `usa_utiles:par`, y `include/3` lo encuentra.

## 6

<!-- ejemplo: capitulo-24/soluciones/comprobar.pl predicado: comprobar_vacantes/0 consulta: comprobar_vacantes. -->
```prolog
%!  comprobar_vacantes is det.
%
%   Escribe en la salida de errores una advertencia por cada materia con
%   vacantes negativas.
comprobar_vacantes :-
    forall(( vacantes(M, N),
             N < 0 ),
           format(user_error, "Vacantes negativas: ~w tiene ~d~n", [M, N])).
```

`format/3` con `user_error` como primer argumento escribe la advertencia en la
salida de errores, que SWI-Prolog tiene abierta siempre, y no en la salida
estándar, donde el programa escribe sus respuestas; `comprobar_datos/0` escribe
así sus advertencias. La prueba `sin_advertencias` verifica que con los datos
del proyecto no se escribe nada, y `con_vacantes_negativas` captura lo escrito
en la salida de errores con una materia de vacantes negativas: dentro de
`with_output_to/2`, `current_output/1` liga su argumento al stream de la salida
actual, que es la capturada, y la prueba le da el alias `user_error`. El
[capítulo 25](../capitulo-25-errores-y-excepciones/index.md#257-mensajes-para-el-usuario)
cambia estas advertencias por `print_message/2`, que separa el término del
mensaje de su texto, y el [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#271-streams)
presenta los streams.

## 7

<!-- ejemplo: capitulo-24/soluciones/salida.pl fragmento: :- module(salida .. format("  ~d ~w: ~w~n", [Legajo, Nombre, Valor]). consulta: informe(aprobadas, [101, 105], F), mostrar_informe(aprobadas, F). -->
```prolog
:- module(salida, [mostrar_informe/2]).

:- use_module('../inscripciones/datos').
:- use_module('../inscripciones/informes', except([mostrar_informe/2])).

%!  mostrar_informe(+Titulo:atom, +Filas:list(pair)) is semidet.
%
%   Escribe Titulo y una línea por fila, con el legajo, el nombre y el valor.
mostrar_informe(Titulo, Filas) :-
    format("~w~n", [Titulo]),
    maplist(mostrar_fila, Filas).

%!  mostrar_fila(+Fila:pair) is semidet.
%
%   Escribe una fila Legajo-Valor de un informe.
mostrar_fila(Legajo-Valor) :-
    alumno(Legajo, Nombre, _, _),
    format("  ~d ~w: ~w~n", [Legajo, Nombre, Valor]).
```

`except([mostrar_informe/2])` importa todo `informes` menos el predicado que el
módulo `salida` redefine. Sin esa exclusión, la definición local chocaría con
la importada. En el proyecto, el paso siguiente es quitar `mostrar_informe/2`
de `informes`, que queda sin salida.

## 8

<!-- ejemplo: capitulo-24/soluciones/operaciones.pl fragmento: :- module(operaciones .. dar_de_baja/2]). consulta: inscribir(104, ssl, R). -->
```prolog
:- module(operaciones, []).

:- reexport('../inscripciones/reglas', [inscribir/3, dar_de_baja/2]).
```

El módulo no define nada: `reexport/2` carga `reglas` y vuelve a exportar dos
de sus predicados. Quien importa `operaciones` puede inscribir y dar de baja,
y no ve `aprobada/3` ni las demás reglas; la prueba `solo_operaciones` lo
verifica.

## 9

<!-- ejemplo: capitulo-24/soluciones/intruso.pl predicado: agregar_mal/2 consulta: agregar_mal(104, ssl), inscripcion(104, ssl, E). -->
```prolog
%!  agregar_mal(+Legajo:integer, +Materia:atom) is det.
%
%   Agrega una inscripción con assertz/1, sin pasar por la interfaz de datos.
agregar_mal(Legajo, Materia) :-
    assertz(inscripcion(Legajo, Materia, cursando)).
```

El hecho llega al módulo `datos`: `assertz/1` sobre un predicado importado
modifica el del módulo que lo define. La prueba `modifica_datos` lo verifica con
`datos:inscripcion(104, ssl, Estado)`.

Los módulos de SWI-Prolog separan los **nombres**, no protegen los **datos**:
exportar `inscripcion/3` para que otros la consulten también permite que la
modifiquen. Que solo `datos` lo haga es una convención del programa —el
[Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz)—, y una revisión del código, o una prueba que busque `assertz` fuera de
`datos`, es lo que la hace cumplir. Distinto es el caso del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md): el módulo de las pruebas no importaba el predicado, lo heredaba de
`user`, y `assertz/1` creaba uno nuevo en el módulo de las pruebas.

## 10

<!-- ejemplo: capitulo-24/soluciones/rutas.pl fragmento: :- multifile .. use_module(proyecto(datos)). consulta: alumno(101, Nombre, _, _). -->
```prolog
:- multifile user:file_search_path/2.

:- prolog_load_context(directory, Aqui),
   atom_concat(Aqui, '/../inscripciones', Directorio),
   assertz(user:file_search_path(proyecto, Directorio)).

:- use_module(proyecto(datos)).
```

`file_search_path/2` es un predicado de `user` al que cada biblioteca agrega
cláusulas: por eso se declara `multifile`. El directorio se calcula a partir
del de este archivo, con `prolog_load_context/2`, para que el alias funcione
desde cualquier lugar: mientras se carga un archivo,
`prolog_load_context(directory, D)` liga `D` al directorio de ese archivo.

## 11

<!-- ejemplo: capitulo-24/soluciones/tablero.pl fragmento: :- module(tablero .. mostrar/1]). consulta: tablero(3, 4, [1-1, 2-3], T), valor(T, 2-2, V). -->
```prolog
:- module(tablero, [tablero/4, valor/3, vecina/4, mostrar/1]).
```

<!-- ejemplo: capitulo-24/soluciones/resolver.pl fragmento: :- module(resolver .. use_module(tablero, [vecina/4]). consulta: deducir(["#100", "1211", "01##", "01##"], Seguras, Minas). -->
```prolog
:- module(resolver, [deducir/3, deducir/4]).

:- use_module(library(clpfd)).
:- use_module(tablero, [vecina/4]).
```

Los predicados son los de los capítulos [22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) y [22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md). `resolver` importa de
`tablero` solo `vecina/4`, que antes estaba repetida en los dos archivos. La
prueba `coherente` une los dos módulos: construye el tablero con las minas
deducidas y verifica un número visible. Es el primer paso hacia el Buscaminas
completo del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), que tiene un módulo por responsabilidad.

## 12

<!-- ejemplo: capitulo-24/soluciones/renombrar.pl fragmento: :- module(renombrar .. append/3 as pegar]). consulta: pegar([a], [b], L). -->
```prolog
:- module(renombrar, [pegar/3]).

:- use_module(library(lists), [append/3 as pegar]).
```

El módulo exporta `pegar/3` sin definirlo: lo importa con ese nombre, y lo
reexporta. `pegar([a], [b], L)` responde `L = [a, b]`.

## 13

<!-- ejemplo: capitulo-24/soluciones/consultas.pl fragmento: :- module(consultas .. reexport('../inscripciones/horarios'). consulta: ranking(R). -->
```prolog
:- module(consultas, []).

:- reexport('../inscripciones/informes').
:- reexport('../inscripciones/horarios').
```

Un módulo que reexporta sirve de **fachada**: quien solo consulta importa
`consultas`, y no necesita saber en qué módulos están los informes y el
calendario.
