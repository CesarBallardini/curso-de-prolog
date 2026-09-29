# Soluciones del capítulo 21 — Gramáticas (DCG)

El código de esta página está en `ejemplos/capitulo-21/soluciones.pl` y
`ejemplos/capitulo-21/soluciones_proyecto.pl`, y pasa sus pruebas.

## 1

| Consulta | Respuesta | Por qué |
|---|---|---|
| `phrase(oracion(H), [ana, es, la, madre, de, luis]).` | `false.` | luis no es una de las personas de `persona/1`, y `nombre//1` no lo acepta |
| `phrase(saludo, "hola").` | error de tipo: se esperaba una lista | fuera de una regla, `"hola"` es una cadena |
| `` phrase(fecha(F), `31/4/2026`). `` | `false.` | abril tiene 30 días, y `fecha_valida/3` rechaza el 31 |
| `` phrase(resta(V), `8-2-1`). `` | `V = 5.` | `(8 - 2) - 1`: el acumulador agrupa a la izquierda |

Cada consulta usa el archivo del capítulo que define su gramática:
`gramatica.pl`, `fechas.pl` y `expresiones.pl`.

## 2

<!-- ejemplo: capitulo-21/soluciones.pl predicado: ab//0 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  ab// is nondet.
%
%   Una o más a seguidas de la misma cantidad de b.
ab --> [a], [b].
ab --> [a], ab, [b].
```

```prolog
?- between(1, 6, N), length(L, N), phrase(ab, L).
N = 2,
L = [a, b] ;
N = 4,
L = [a, a, b, b] ;
N = 6,
L = [a, a, a, b, b, b] ;
false.
```

La primera regla es el caso base, `ab`, sin la cadena vacía; la segunda rodea
otra `ab` con una `a` y una `b`. `length/2` fija la longitud antes de llamar a
la gramática, y `between/3` la limita: las longitudes impares no tienen
ninguna lista.

## 3

<!-- ejemplo: capitulo-21/soluciones.pl predicado: saludo_a//1 saludo_a_traducido/3 nombre//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  saludo_a(?N)// is nondet.
%
%   Los códigos de "hola " seguidos del nombre N.
saludo_a(N) -->
    "hola ",
    nombre(N).

%!  saludo_a_traducido(?N, ?S0, ?S) is nondet.
%
%   La traducción de saludo_a//1 escrita a mano: los códigos de "hola " al
%   principio de S0, y el nombre en lo que sigue.
saludo_a_traducido(N, S0, S) :-
    S0 = [0'h, 0'o, 0'l, 0'a, 0' |S1],
    nombre(N, S1, S).

%!  nombre(?N)// is nondet.
%
%   Los códigos de uno de los nombres conocidos.
nombre(ana)  --> "ana".
nombre(luis) --> "luis".
```

La traducción agrega los dos argumentos: `S0`, la entrada, y `S`, lo que queda.
El terminal `"hola "` se vuelve una unificación: `S0` empieza con esos cinco
códigos, y `S1` es el resto. El no terminal `nombre//1` recibe `S1` y deja lo
que sobra en `S`. `listing(saludo_a//1)` muestra la misma forma, con otros
nombres de variables. La prueba `traduccion` verifica que las dos versiones
responden lo mismo.

## 4

<!-- ejemplo: capitulo-21/soluciones.pl predicado: frase//0 sujeto//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  frase// is nondet.
%
%   Un sujeto y un verbo que concuerdan en número: "el perro ladra" o "los
%   perros ladran", como listas de palabras.
frase -->
    sujeto(Numero),
    verbo(Numero).

%!  sujeto(?Numero)// is nondet.
%
%   Un artículo y un sustantivo en singular o en plural.
sujeto(Numero) -->
    articulo(Numero),
    sustantivo(Numero).
```

```prolog
?- phrase(frase, [los, perros, ladra]).
false.
```

El argumento `Numero` recorre la regla: el artículo, el sustantivo y el verbo
deben tener el mismo, porque es la misma variable. Una sola regla expresa la
concordancia, en lugar de una regla por cada combinación válida.

## 5

<!-- ejemplo: capitulo-21/soluciones.pl predicado: oracion_verdadera//1 verdadero/1 consulta: phrase(oracion_verdadera(H), P). -->
```prolog
%!  oracion_verdadera(?Hecho)// is nondet.
%
%   Una oración de la sección 21.1 que afirma Hecho, siempre que Hecho sea
%   uno de los hechos de la base.
oracion_verdadera(Hecho) -->
    nombre_de_persona(A),
    [es],
    relacion(A, B, Hecho),
    [de],
    nombre_de_persona(B),
    { verdadero(Hecho) }.

%!  verdadero(+Hecho) is semidet.
%
%   Hecho es uno de los hechos de padre/2 o de madre/2. Una cláusula por
%   relación, en lugar de call/1: el sandbox de SWISH no acepta llamar un
%   objetivo que no conoce de antemano.
verdadero(padre(A, B)) :-
    padre(A, B).
verdadero(madre(A, B)) :-
    madre(A, B).
```

```prolog
?- phrase(oracion_verdadera(Hecho), Palabras).
Hecho = padre(juan, ana),
Palabras = [juan, es, el, padre, de, ana] ;
Hecho = padre(juan, pedro),
Palabras = [juan, es, el, padre, de, pedro] ;
Hecho = madre(marta, ana),
Palabras = [marta, es, la, madre, de, ana] ;
Hecho = madre(marta, pedro),
Palabras = [marta, es, la, madre, de, pedro] ;
false.
```

La consulta más general genera solo las cuatro oraciones verdaderas, de las
32 que genera `oracion//1`. La comprobación va al final, cuando `Hecho` ya
está completo. `verdadero/1` tiene una cláusula por relación en lugar de
`call(Hecho)`: el sandbox de SWISH rechaza `call/1` sobre un objetivo que no
conoce de antemano, como explicó el [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md).

## 6

<!-- ejemplo: capitulo-21/soluciones.pl predicado: ab_invertida//0 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  ab_invertida// is nondet.
%
%   El mismo lenguaje que ab//0, con las reglas en el orden inverso
%   (ejercicio 6). Analiza bien, pero no genera: la primera regla es siempre
%   la recursiva, y la generación no llega nunca a una lista completa.
ab_invertida --> [a], ab_invertida, [b].
ab_invertida --> [a], [b].
```

`phrase(ab, L)` genera todas las listas del lenguaje, de la más corta a la más
larga: la primera regla es el caso base, y da `[a, b]`; al pedir otra
respuesta, la segunda regla rodea esa respuesta con una `a` y una `b`.

`ab_invertida//0` reconoce las mismas listas, porque las reglas son las mismas.
Al generar, en cambio, la primera regla es la recursiva: agrega una `a` y se
llama de nuevo, que vuelve a elegir la regla recursiva, sin llegar nunca al
caso base. La prueba `ab_invertida_no_genera` lo verifica con
`call_with_inference_limit/3`: la consulta agota un millón de inferencias sin
ninguna respuesta. Es la misma rama infinita del [capítulo 5](../capitulo-05-como-responde-prolog/index.md), en una
gramática.

## 7

<!-- ejemplo: capitulo-21/soluciones.pl predicado: preorden//1 simetrico//1 postorden//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  preorden(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno antes que sus subárboles. Un
%   árbol es nil o nodo(Nombre, Izquierdo, Derecho).
preorden(nil) --> [].
preorden(nodo(Nombre, I, D)) -->
    [Nombre],
    preorden(I),
    preorden(D).

%!  simetrico(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno entre sus dos subárboles.
simetrico(nil) --> [].
simetrico(nodo(Nombre, I, D)) -->
    simetrico(I),
    [Nombre],
    simetrico(D).

%!  postorden(+Arbol)// is det.
%
%   Los nombres de los nodos de Arbol, cada uno después de sus subárboles.
postorden(nil) --> [].
postorden(nodo(Nombre, I, D)) -->
    postorden(I),
    postorden(D),
    [Nombre].
```

```prolog
?- phrase(postorden(nodo(a, nodo(b, nil, nil), nodo(c, nil, nil))), L).
L = [b, c, a].
```

Los tres recorridos tienen las mismas partes; solo cambia dónde va el terminal
`[Nombre]`. Es la forma más directa de escribirlos: la gramática construye la
lista sin `append/3`.

## 8

<!-- ejemplo: capitulo-21/soluciones.pl predicado: balanceado//0 balanceado//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  balanceado// is semidet.
%
%   Los paréntesis, corchetes y llaves del texto están bien anidados; los
%   demás códigos se ignoran.
balanceado -->
    balanceado([]).

%!  balanceado(+Abiertos:list)// is semidet.
%
%   Abiertos son los cierres que faltan, el próximo primero.
balanceado([]) -->
    eos,
    !.
balanceado(Abiertos) -->
    [C],
    { apertura(C, Cierre) },
    !,
    balanceado([Cierre|Abiertos]).
balanceado([Cierre|Abiertos]) -->
    [Cierre],
    !,
    balanceado(Abiertos).
balanceado(Abiertos) -->
    [C],
    { \+ apertura(C, _),
      \+ apertura(_, C) },
    balanceado(Abiertos).
```

`balanceado//1` lleva una pila con los cierres que faltan: un signo de
apertura agrega su cierre; un cierre debe coincidir con el primero de la pila;
cualquier otro código se ignora. Al final de la entrada, la pila debe estar
vacía. Los cortes dicen que un signo de apertura o de cierre no puede
ignorarse como un código común. `([)]` falla porque `)` llega cuando la pila
espera `]`.

## 9

<!-- ejemplo: capitulo-21/soluciones.pl predicado: expresion//1 sumas//2 termino//1 productos//2 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  expresion(-V:number)// is semidet.
%
%   Una expresión con enteros, +, -, * y /, sin paréntesis. * y / se
%   evalúan antes que + y -, y operadores de la misma precedencia, de
%   izquierda a derecha.
expresion(V) -->
    termino(T),
    sumas(T, V).

%!  sumas(+Hasta:number, -V:number)// is det.
%
%   V es Hasta con las sumas y restas que siguen aplicadas en orden.
sumas(Hasta, V) -->
    "+",
    !,
    termino(T),
    { Ahora is Hasta + T },
    sumas(Ahora, V).
sumas(Hasta, V) -->
    "-",
    !,
    termino(T),
    { Ahora is Hasta - T },
    sumas(Ahora, V).
sumas(V, V) -->
    [].

%!  termino(-V:number)// is semidet.
%
%   Un producto o cociente de enteros, de izquierda a derecha.
termino(V) -->
    integer(N),
    productos(N, V).

%!  productos(+Hasta:number, -V:number)// is det.
%
%   V es Hasta con los productos y cocientes que siguen aplicados en orden.
productos(Hasta, V) -->
    "*",
    !,
    integer(N),
    { Ahora is Hasta * N },
    productos(Ahora, V).
productos(Hasta, V) -->
    "/",
    !,
    integer(N),
    { Ahora is Hasta / N },
    productos(Ahora, V).
productos(V, V) -->
    [].
```

```prolog
?- phrase(expresion(V), `2+3*4-6/2`).
V = 11.
```

Dos niveles, uno por precedencia, cada uno con el Patrón 20. `expresion//1`
suma y resta términos; `termino//1` multiplica y divide enteros. Como un
término se reconoce completo antes de volver a `sumas//2`, `3*4` se calcula
antes de sumarse. `/` da un resultado de punto flotante cuando la división no
es exacta, como `is/2`.

## 10

<!-- ejemplo: capitulo-21/soluciones.pl predicado: fecha_larga//1 nombre_de_mes//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  fecha_larga(?F)// is semidet.
%
%   El texto "24 de septiembre de 2026" de la fecha F = fecha(2026, 9, 24),
%   en los dos sentidos.
fecha_larga(fecha(Anio, Mes, Dia)) -->
    integer(Dia),
    " de ",
    nombre_de_mes(Mes),
    " de ",
    integer(Anio).

%!  nombre_de_mes(?Mes:integer)// is semidet.
%
%   Los códigos del nombre del mes número Mes. atom//1 escribe el nombre al
%   generar, y lo compara con la entrada al analizar.
nombre_de_mes(Mes) -->
    { nth1(Mes, [enero, febrero, marzo, abril, mayo, junio, julio, agosto,
                 septiembre, octubre, noviembre, diciembre], Nombre) },
    atom(Nombre).
```

```prolog
?- phrase(fecha_larga(fecha(2027, 1, 1)), Cs), atom_codes(A, Cs).
Cs = [49, 32, 100, 101, 32, 101, 110, 101, 114|...],
A = '1 de enero de 2027'.
```

`nombre_de_mes//1` obtiene el nombre con `nth1/3` antes de consumir nada, y
`atom//1` lo escribe al generar y lo compara con la entrada al analizar. Al
analizar, `nth1/3` prueba los meses en orden hasta encontrar el que coincide, y
queda una alternativa pendiente: la prueba `fecha_larga` la declara con
`nondet`.

## 11

<!-- ejemplo: capitulo-21/soluciones.pl predicado: enumeracion//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  enumeracion(-Nombres:list)// is semidet.
%
%   Los nombres separados por comas, con y antes del último: "ana",
%   "ana y luis", "ana, luis y eva". Solo analiza: csym//1 no genera.
enumeracion([N]) -->
    csym(N).
enumeracion([N1, N2]) -->
    csym(N1),
    " y ",
    csym(N2).
enumeracion([N1, N2, N3|Ns]) -->
    csym(N1),
    ", ",
    enumeracion([N2, N3|Ns]).
```

Tres casos según la cantidad de nombres: uno solo, dos unidos por «y», o uno
seguido de una coma y el resto. `sequence//3` no alcanza, porque el último
separador es distinto de los demás. La gramática solo analiza: `csym//1` no
genera texto a partir de un átomo, y al generar no termina.

## 12

<!-- ejemplo: capitulo-21/soluciones.pl predicado: problema//1 operaciones//2 operacion//1 aplicar/4 consulta: string_codes("cuanto es 5 mas 13 por 2", Cs), phrase(problema(V), Cs). -->
```prolog
%!  problema(-V:number)// is semidet.
%
%   "cuanto es 5 mas 13 por 2": V es el resultado de las operaciones,
%   aplicadas de izquierda a derecha, sin precedencia.
problema(V) -->
    "cuanto es ",
    integer(N),
    operaciones(N, V).

%!  operaciones(+Hasta:number, -V:number)// is semidet.
%
%   V es Hasta con cada " operación número" que sigue aplicada en orden.
operaciones(Hasta, V) -->
    " ",
    operacion(Op),
    " ",
    !,
    integer(N),
    { aplicar(Op, Hasta, N, Ahora) },
    operaciones(Ahora, V).
operaciones(V, V) -->
    [].

%!  operacion(?Op)// is nondet.
%
%   Los códigos de la palabra que nombra la operación Op.
operacion(suma)     --> "mas".
operacion(resta)    --> "menos".
operacion(producto) --> "por".
operacion(cociente) --> "dividido".

%!  aplicar(+Op, +A:number, +B:number, -R:number) is det.
%
%   R es el resultado de la operación Op entre A y B.
aplicar(suma, A, B, R)     :- R is A + B.
aplicar(resta, A, B, R)    :- R is A - B.
aplicar(producto, A, B, R) :- R is A * B.
aplicar(cociente, A, B, R) :- R is A / B.
```

```prolog
?- string_codes("cuanto es 5 mas 13 por 2", Cs), phrase(problema(V), Cs).
Cs = [99, 117, 97, 110, 116, 111, 32, 101, 115|...],
V = 36.
```

`operaciones//2` es el [Patrón 22](../patrones.md#22-gramatica-con-argumento-acumulador) con una sola precedencia: cada operación se
aplica al acumulado, en el orden en que aparece. `aplicar/4` separa la
aritmética de la gramática. Una pregunta que termina en una operación sin
número falla, y la prueba `problema_mal_escrito` lo verifica.

## 13

<!-- ejemplo: capitulo-21/soluciones.pl predicado: lista_de_enteros//1 consulta: phrase(expresion(V), `2+3*4-6/2`). -->
```prolog
%!  lista_de_enteros(?L:list(integer))// is semidet.
%
%   "[1, 2, 3]": enteros entre corchetes, separados por coma y espacio.
lista_de_enteros(L) -->
    sequence("[", integer, ", ", "]", L).
```

`sequence(Apertura, Elemento, Separador, Cierre, Lista)` reconoce los
delimitadores además de los elementos, y funciona en los dos sentidos:
`phrase(lista_de_enteros([4, 5]), Cs)` genera `[4, 5]`.

## 14

<!-- ejemplo: capitulo-21/soluciones_proyecto.pl predicado: comando//1 consulta: ejecutar("vacantes de logica", Respuesta). -->
```prolog
%!  comando(?Comando)// is nondet.
%
%   La lista de palabras de Comando: inscribir(Legajo, Materia),
%   baja(Legajo, Materia), listar(Materia) o promedio(Legajo). Las materias
%   se escriben con su nombre, no con su código.
comando(inscribir(L, M)) -->
    [inscribir, a], legajo(L), [en], materia_por_nombre(M).
comando(baja(L, M)) -->
    [dar, de, baja, a], legajo(L), [en], materia_por_nombre(M).
comando(listar(M)) -->
    [listar], materia_por_nombre(M).
comando(promedio(L)) -->
    [promedio, de], legajo(L).
comando(vacantes(M)) -->
    [vacantes, de], materia_por_nombre(M).
```

```prolog
?- ejecutar("vacantes de logica", Respuesta).
Respuesta = vacantes(0).
```

Una regla nueva en `comando//1` y una cláusula nueva en `realizar/2`.
`palabras//1` no cambia: el comando nuevo usa las mismas palabras y números.

## 15

<!-- ejemplo: capitulo-21/soluciones_proyecto.pl predicado: texto_de/2 consulta: ejecutar("vacantes de logica", Respuesta). -->
```prolog
%!  texto_de(+Comando, -Texto:atom) is semidet.
%
%   Texto es el texto de Comando, generado con la misma gramática que lo
%   analiza (ejercicio 15).
texto_de(Comando, Texto) :-
    once(phrase(comando(Comando), Palabras)),
    atomic_list_concat(Palabras, ' ', Texto).
```

```prolog
?- texto_de(baja(105, am1), T).
T = 'dar de baja a 105 en analisis_1'.
```

La prueba `ida_y_vuelta` genera el texto de `listar(M)` para cada materia, lo
separa en palabras con `palabras//1` y lo vuelve a analizar con
`comando//1`: debe dar el mismo comando. Es la prueba del Patrón 21.

## 16

<!-- ejemplo: capitulo-21/soluciones_proyecto.pl predicado: ejecutar/2 consulta: ejecutar("inscribir 104", Respuesta). -->
```prolog
%!  ejecutar(+Texto:string, -Respuesta) is det.
%
%   Analiza el comando Texto y lo ejecuta. Respuesta es el resultado:
%   aceptada o rechazada(Motivo) para una inscripción, baja o
%   rechazada(no_la_cursa) para una baja, inscriptos(Legajos) para un
%   listado, promedio(P) o sin_notas para un promedio, vacantes(N) para las
%   vacantes de una materia (ejercicio 14). Si el texto no es un comando pero
%   empieza con la palabra de uno, Respuesta es uso(Ejemplo), con un comando
%   de ejemplo que empieza igual (ejercicio 16); si no, no_entendido.
ejecutar(Texto, Respuesta) :-
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  realizar(Comando, Respuesta)
    ;   phrase(palabras([Verbo|_]), Codigos),
        once(phrase(comando(_), [Verbo|Resto]))
    ->  atomic_list_concat([Verbo|Resto], ' ', Ejemplo),
        Respuesta = uso(Ejemplo)
    ;   Respuesta = no_entendido
    ).
```

```prolog
?- ejecutar("inscribir 104", Respuesta).
Respuesta = uso('inscribir a 101 en analisis_1').
```

Cuando el texto no es un comando, `ejecutar/2` toma su primera palabra y le pide
a la gramática un comando que empiece con ella: `phrase(comando(_), [Verbo|Resto])`
con `Resto` libre genera uno, con el primer alumno y la primera materia de la
base. La ayuda sale de la misma gramática que analiza, y por eso no puede
quedar desactualizada.
