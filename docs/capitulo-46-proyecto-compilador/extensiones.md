# Otras máquinas y extensiones de Mini

Esta página continúa la página
[El intérprete especializado](especializacion.md#467-el-interprete-especializado)
del [capítulo 46](index.md), con las secciones
[46.8](#468-la-reduccion-de-fuerza) a
[46.12](#4612-funciones-y-marcos-de-pila): cinco partes de las fuentes que las versiones 1 a
6 no tienen. De *Clause and Effect* de Clocksin vienen la reducción de
fuerza y las otras dos máquinas del capítulo «A Compiler for Three Model
Computers», la de acumulador y la de registros; la asignación de registros
sigue el algoritmo de Sethi y Ullman (1970), que Aho y Ullman exponen en
*Principles of Compiler Design*. De *The Art of Prolog* viene la sentencia
de lectura del lenguaje PL de Sterling y Shapiro, y de «Thinking in States»
de Triska, las funciones recursivas con marcos de pila. Cada parte está en
su propio archivo de `ejemplos/capitulo-46/`, con sus pruebas, y carga las
versiones anteriores sin modificarlas: los predicados que cada extensión
amplía —las palabras reservadas, los símbolos, las sentencias, los
factores, el código de las sentencias y de las expresiones, las clases de
instrucciones y los pasos de la máquina— están declarados `multifile` en
los archivos del capítulo.

## 46.8 La reducción de fuerza

Reducir la fuerza de una operación es reemplazarla por otra más barata que
da el mismo resultado. Clocksin la presenta como el último paso del
preprocesamiento del árbol: sumar 0 o multiplicar por 1 no hace nada;
sumar 1 es un incremento, que muchas máquinas tienen como instrucción; y
multiplicar por una potencia de dos, $2^k$, es desplazar los bits $k$
lugares a la izquierda. `fuerza.pl` escribe esas identidades como una tabla,
`reduccion/4`, sobre la sintaxis abstracta, con dos nodos nuevos,
`incrementar(E)` y `desplazar(E, K)`:

<!-- ejemplo: capitulo-46/fuerza.pl predicado: reduccion/4 potencia_de_dos/2 -->
```prolog
%!  reduccion(+Op, +A, +B, -E) is semidet.
%
%   La operación Op entre A y B se escribe E, más barata. Falla si no hay
%   una reducción para ella.
reduccion(+, A, num(0), A).
reduccion(+, num(0), B, B).
reduccion(+, A, num(1), incrementar(A)).
reduccion(+, num(1), B, incrementar(B)).
reduccion(-, A, num(0), A).
reduccion(*, A, num(1), A).
reduccion(*, num(1), B, B).
reduccion(*, A, num(C), desplazar(A, K)) :-
    potencia_de_dos(C, K).
reduccion(*, num(C), B, desplazar(B, K)) :-
    potencia_de_dos(C, K).

%!  potencia_de_dos(+C:integer, -K:integer) is semidet.
%
%   C es 2^K, con K mayor que 0.
potencia_de_dos(C, K) :-
    C > 1,
    K is msb(C),
    C =:= 1 << K.
```

Clocksin usa una tabla de potencias de dos y advierte que un programa real
necesitaría una más completa; `potencia_de_dos/2` la calcula: `msb/1` da la
posición del bit más alto, y el número es una potencia de dos si no tiene
otro bit encendido. `reducir_expresion/2` reduce primero los operandos y
después la operación, de modo que una reducción puede habilitar otra:

<!-- ejemplo: capitulo-46/fuerza.pl predicado: reducir_expresion/2 -->
```prolog
%!  reducir_expresion(+E0, -E) is det.
%
%   E es la expresión E0 con la fuerza reducida: primero los operandos,
%   después la operación misma.
reducir_expresion(bin(Op, A0, B0), E) :-
    !,
    reducir_expresion(A0, A),
    reducir_expresion(B0, B),
    (   reduccion(Op, A, B, E1)
    ->  E = E1
    ;   E = bin(Op, A, B)
    ).
reducir_expresion(E, E).
```

```prolog
?- reducir_expresion(bin(+, bin(*, id(x), num(8)), num(1)), E).
E = incrementar(desplazar(id(x), 3)).
```

Clocksin supone que el preprocesamiento ya llevó las constantes al lado
derecho de las operaciones conmutativas; el reordenamiento de la
[sección 46.6](optimizacion.md#466-optimizacion) no lo hace, porque ordena por la
pila que necesita cada operando, y por eso la tabla tiene cada regla de `+`
y de `*` en los dos sentidos. Dos reducciones quedan fuera a propósito.
Clocksin también reduce `x * 0` a `0`, pero la reducción cambia el
comportamiento del programa: si `x` es `a / 0`, el programa original
produce un error de evaluación y el reducido escribe 0. Y la división por
una potencia de dos no se reduce a un desplazamiento a la derecha: Clocksin
la admite para enteros positivos, pero `/` de Mini trunca hacia cero y el
desplazamiento redondea hacia abajo, de modo que los dos difieren en los
negativos. La prueba `division_y_desplazamiento` de `fuerza.plt` lo
muestra: `-7 / 2` es `-3`, y `-7 >> 1` es `-4`.

Los nodos nuevos necesitan su código y sus instrucciones. `fuerza.pl`
agrega a `codigo_expresion//1` una cláusula por nodo, a `clase/2` las
instrucciones nuevas y a `paso//3` lo que hacen en la máquina:

<!-- ejemplo: capitulo-46/fuerza.pl fragmento: % El código de los dos nodos nuevos .. put_assoc(C, M0, 0, M) }. -->
```prolog
% El código de los dos nodos nuevos: el operando, y la instrucción.
codigo_expresion(incrementar(E)) -->
    codigo_expresion(E),
    [incrementar].
codigo_expresion(desplazar(E, K)) -->
    codigo_expresion(E),
    [desplazar(K)].

% Las instrucciones nuevas: dos fijas y una que nombra una celda.
clase(incrementar, fija).
clase(desplazar(_), fija).
clase(poner_cero(_), memoria).

% Lo que hacen en la máquina.
paso(incrementar, s(PC, [V|P], M), s(PC1, [V1|P], M)) -->
    { PC1 is PC + 1,
      V1 is V + 1 }.
paso(desplazar(K), s(PC, [V|P], M), s(PC1, [V1|P], M)) -->
    { PC1 is PC + 1,
      V1 is V << K }.
paso(poner_cero(C), s(PC, P, M0), s(PC1, P, M)) -->
    { PC1 is PC + 1,
      put_assoc(C, M0, 0, M) }.
```

La tercera instrucción, `poner_cero(C)`, viene de la mirilla de Clocksin:
apilar 0 y guardarlo es poner la celda en cero, como la instrucción `CLR`
de muchas máquinas. `modismo_fuerza/2` la agrega a los modismos de la
mirilla, y `compilar_reducido/2` aplica todo en orden: el plegado y el
reordenamiento, la reducción de fuerza y la mirilla ampliada.

<!-- ejemplo: capitulo-46/fuerza.pl predicado: modismo_fuerza/2 compilar_reducido/2 -->
```prolog
%!  modismo_fuerza(+Codigo0:list, -Codigo:list) is semidet.
%
%   Los modismos de modismo/2, y uno más: apilar 0 y guardarlo en una
%   variable es poner la variable en cero.
modismo_fuerza([apilar(0), guardar(X)|R], [poner_cero(X)|R]).
modismo_fuerza(Codigo0, Codigo) :-
    modismo(Codigo0, Codigo).

%!  compilar_reducido(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa Mini de Texto, optimizado
%   como en compilar_optimizado/2 y con la fuerza reducida. Falla si Texto
%   no es un programa Mini.
compilar_reducido(Texto, Objeto) :-
    analizar(Texto, Programa0),
    optimizar(Programa0, Programa1),
    transformar(reducir_expresion, Programa1, Programa),
    generar(Programa, Simbolico0),
    mirilla(modismo_fuerza, Simbolico0, Simbolico),
    ensamblar(Simbolico, Objeto, _).
```

```prolog
?- compilar_reducido("x := 0; y := x * 4 + 1; escribir y", O).
O = [poner_cero(0), cargar(0), desplazar(2), incrementar, guardar(1), cargar(1), escribir].
```

`compilar_optimizado/2` da para el mismo programa diez instrucciones; aquí
son siete. Las pruebas comparan la salida de `correr_reducido/2` con la del
intérprete en los cuatro programas de ejemplo y en expresiones con valores
negativos.

## 46.9 Una máquina de acumulador

La máquina de pila no nombra los operandos: los toma del tope. Clocksin
compila el mismo lenguaje para otras dos máquinas, y la primera es la más
antigua: un único registro, el **acumulador**, y operaciones que combinan el
acumulador con un valor de la memoria. Es también la máquina del capítulo
de Sterling y Shapiro. En `acumulador.pl` tiene tres instrucciones:
`cargar(V)` pone el valor `V` en el acumulador, `operar(Op, V)` lo reemplaza
por el resultado de operarlo con `V`, y `guardar(t(K))` lo copia en la
celda temporal `t(K)`. Un valor es una constante, una variable de Mini o una
temporal.

Si el operando derecho de una operación es una hoja, la instrucción lo
nombra directamente. Si no lo es, hay que calcularlo primero, guardarlo en
una temporal, calcular el izquierdo en el acumulador y operar con la
temporal:

<!-- ejemplo: capitulo-46/acumulador.pl predicado: generar_acumulador/2 codigo_acumulador//2 hoja/1 -->
```prolog
%!  generar_acumulador(+E, -Codigo:list) is det.
%
%   Codigo es el código de la máquina de acumulador que deja en el
%   acumulador el valor de la expresión E.
generar_acumulador(E, Codigo) :-
    phrase(codigo_acumulador(E, 0), Codigo).

%!  codigo_acumulador(+E, +K:integer)// is det.
%
%   El código de E, que usa las temporales desde t(K).
codigo_acumulador(E, _) -->
    { hoja(E) },
    !,
    [cargar(E)].
codigo_acumulador(bin(Op, A, B), K) -->
    (   { hoja(B) }
    ->  codigo_acumulador(A, K),
        [operar(Op, B)]
    ;   { K1 is K + 1 },
        codigo_acumulador(B, K),
        [guardar(t(K))],
        codigo_acumulador(A, K1),
        [operar(Op, t(K))]
    ).

%!  hoja(+E) is semidet.
%
%   E es una constante o una variable: la máquina la nombra en una
%   instrucción.
hoja(num(_)).
hoja(id(_)).
```

```prolog
?- analizar("escribir a - b * c", [escribir(E)]), generar_acumulador(E, C).
E = bin(-, id(a), bin(*, id(b), id(c))),
C = [cargar(id(b)), operar(*, id(c)), guardar(t(0)), cargar(id(a)), operar(-, t(0))].
```

El generador de Clocksin calcula primero el operando izquierdo y lo
guarda, y por eso sirve solo para las operaciones conmutativas; calcular
primero el derecho sirve también para la resta y la división, porque el
izquierdo queda en el acumulador, donde la operación lo espera. Tiene otra
ventaja: la temporal se usa apenas se guarda, y queda libre. El argumento
`K` es la primera temporal libre; el operando derecho se calcula con la
misma `K`, porque sus temporales ya se usaron cuando se guarda el
resultado. `a + (b + (c + d))`, que en el generador de Clocksin usa dos
temporales, aquí usa una sola, `t(0)`, dos veces; y una suma encadenada a
la izquierda, `a + b + c + d`, ninguna.

La máquina es, como la de pila, una relación entre estados. El estado es
`ac(Acumulador, Temporales)`, y el código, sin saltos, se ejecuta con
`foldl/4`:

<!-- ejemplo: capitulo-46/acumulador.pl predicado: ejecutar_acumulador/3 instruccion_acumulador/4 paso_acumulador/4 valor_acumulador/4 -->
```prolog
%!  ejecutar_acumulador(+Codigo:list, +Entorno:list, -V:integer) is det.
%
%   V es lo que queda en el acumulador después de ejecutar Codigo, con las
%   variables de Mini en Entorno, una lista de pares Nombre-Valor.
ejecutar_acumulador(Codigo, Entorno, V) :-
    empty_assoc(Temporales),
    foldl(instruccion_acumulador(Entorno), Codigo,
          ac(0, Temporales), ac(V, _)).

%!  instruccion_acumulador(+Entorno:list, +I, +Estado0, -Estado) is det.
%
%   paso_acumulador/4 con el entorno primero, para foldl/4.
instruccion_acumulador(Entorno, I, Estado0, Estado) :-
    paso_acumulador(I, Entorno, Estado0, Estado).

%!  paso_acumulador(+I, +Entorno:list, +Estado0, -Estado) is det.
%
%   Ejecutar la instrucción I lleva la máquina de Estado0 a Estado. El
%   estado es ac(Acumulador, Temporales).
paso_acumulador(cargar(X), E, ac(_, T), ac(V, T)) :-
    valor_acumulador(X, E, T, V).
paso_acumulador(operar(Op, X), E, ac(A0, T), ac(A, T)) :-
    valor_acumulador(X, E, T, V),
    operar(Op, A0, V, A).
paso_acumulador(guardar(t(K)), _, ac(A, T0), ac(A, T)) :-
    put_assoc(K, T0, A, T).

%!  valor_acumulador(+X, +Entorno:list, +Temporales, -V:integer) is det.
%
%   V es el valor que nombra X: una constante, una variable de Mini o una
%   temporal.
valor_acumulador(num(N), _, _, N).
valor_acumulador(id(X), E, _, V) :-
    valor(X, E, V).
valor_acumulador(t(K), _, T, V) :-
    get_assoc(K, T, V).
```

`instruccion_acumulador/4` solo cambia el orden de los argumentos:
`foldl/4` agrega los suyos al final, y `paso_acumulador/4` tiene la
instrucción primero para que la indexación elija la cláusula por ella. La
prueba `mismo_valor` compara el valor del acumulador con el de `evaluar/3`
del intérprete en nueve expresiones.

## 46.10 Una máquina de registros y la asignación de registros

La segunda máquina de Clocksin, como las de diseño de conjunto reducido de
instrucciones, opera solo entre registros, `r(0)`, `r(1)`, …:
`cargar(R, V)` pone en `r(R)` una constante o una variable, y
`operar(Op, R1, R2)` reemplaza `r(R1)` por `r(R1)` operado con `r(R2)`. El
generador de Clocksin evalúa el operando izquierdo en el registro de la
operación y el derecho en el siguiente:

<!-- ejemplo: capitulo-46/registros.pl predicado: generar_ingenuo/2 codigo_ingenuo//2 -->
```prolog
%!  generar_ingenuo(+E, -Codigo:list) is det.
%
%   Codigo deja el valor de E en r(0): cada operando izquierdo en el
%   registro de su operación, el derecho en el siguiente.
generar_ingenuo(E, Codigo) :-
    phrase(codigo_ingenuo(E, 0), Codigo).

%!  codigo_ingenuo(+E, +R:integer)// is det.
%
%   El código que deja el valor de E en r(R), usando los registros desde R.
codigo_ingenuo(bin(Op, A, B), R) -->
    !,
    { R1 is R + 1 },
    codigo_ingenuo(A, R),
    codigo_ingenuo(B, R1),
    [operar(Op, R, R1)].
codigo_ingenuo(E, R) -->
    [cargar(R, E)].
```

Clocksin observa que `1 + (2 + 3)` usa un registro más que `(1 + 2) + 3`, y
lo deja como pista. La pista es la **asignación de registros**: con pocos
registros, cada uno que se ahorra es un valor que no hay que guardar en la
memoria. Sethi y Ullman dieron en 1970 el algoritmo que usa la menor
cantidad posible. Cada nodo se etiqueta con los registros que necesita:
uno para una hoja; para una operación, el mayor de los de sus operandos si
son distintos, o uno más si son iguales. Si los dos operandos necesitan
los mismos registros, el primero que se calcula ocupa uno mientras se
calcula el segundo; si no, se calcula primero el que necesita más, y el
otro cabe en los que sobran:

<!-- ejemplo: capitulo-46/registros.pl predicado: registros_necesarios/2 -->
```prolog
%!  registros_necesarios(+E, -N:integer) is det.
%
%   N es la cantidad de registros que necesita E: uno para una hoja; para
%   una operación, la mayor de las de sus operandos si son distintas, o
%   una más si son iguales.
registros_necesarios(bin(_, A, B), N) :-
    !,
    registros_necesarios(A, NA),
    registros_necesarios(B, NB),
    (   NA =:= NB
    ->  N is NA + 1
    ;   N is max(NA, NB)
    ).
registros_necesarios(_, 1).
```

`codigo_registros//2` recibe la lista de registros libres y deja el
resultado en el primero. Cuando el operando que necesita más registros es
el derecho, lo calcula en el segundo registro libre, con el primero entre
los que puede usar, y después calcula el izquierdo en el primero: así la
operación encuentra sus operandos en el orden correcto, también en la resta
y la división, sin mover valores entre registros.

<!-- ejemplo: capitulo-46/registros.pl predicado: generar_registros/2 codigo_registros//2 -->
```prolog
%!  generar_registros(+E, -Codigo:list) is det.
%
%   Codigo deja el valor de E en r(0) y usa los registros r(0) a r(N-1),
%   donde N es registros_necesarios(E, N).
generar_registros(E, Codigo) :-
    registros_necesarios(E, N),
    Ultimo is N - 1,
    numlist(0, Ultimo, Libres),
    phrase(codigo_registros(E, Libres), Codigo).

%!  codigo_registros(+E, +Libres:list(integer))// is det.
%
%   El código que deja el valor de E en el primer registro de Libres, y
%   usa solo registros de Libres. El operando que necesita más registros
%   se evalúa primero; si es el derecho, se evalúa en el segundo registro
%   libre, para que el resultado quede en el primero.
codigo_registros(bin(Op, A, B), [R|Rs]) -->
    !,
    { registros_necesarios(A, NA),
      registros_necesarios(B, NB) },
    (   { NA >= NB }
    ->  { Rs = [R2|_] },
        codigo_registros(A, [R|Rs]),
        codigo_registros(B, Rs)
    ;   { Rs = [R2|Resto] },
        codigo_registros(B, [R2, R|Resto]),
        codigo_registros(A, [R|Resto])
    ),
    [operar(Op, R, R2)].
codigo_registros(E, [R|_]) -->
    [cargar(R, E)].
```

```prolog
?- generar_ingenuo(bin(-, id(a), bin(*, id(b), id(c))), C).
C = [cargar(0, id(a)), cargar(1, id(b)), cargar(2, id(c)), operar(*, 1, 2), operar(-, 0, 1)].

?- generar_registros(bin(-, id(a), bin(*, id(b), id(c))), C).
C = [cargar(1, id(b)), cargar(0, id(c)), operar(*, 1, 0), cargar(0, id(a)), operar(-, 0, 1)].
```

El generador ingenuo usa tres registros; el de Sethi y Ullman, dos, porque
calcula `b * c` antes de cargar `a`. El reordenamiento de la
[sección 46.6](optimizacion.md#466-optimizacion) no puede hacer lo mismo en la
máquina de pila, porque la resta no es conmutativa y la pila exige los
operandos en orden; los registros tienen nombre, y el orden de cálculo se
separa del orden de los operandos. La cantidad de registros del generador
ingenuo es la misma que la pila que usa `generar/2`, y la del algoritmo de
Sethi y Ullman no la supera nunca: lo verifican las pruebas
`usa_los_necesarios` y `nunca_mas_que_el_ingenuo` sobre nueve expresiones.
La máquina, `ejecutar_registros/3`, es un `foldl/4` sobre un árbol AVL de
registros, como la de acumulador.

Con menos registros que los que la expresión necesita, `codigo_registros//2`
falla. Un compilador completo guarda entonces un resultado intermedio en la
memoria —la técnica que la máquina de acumulador usa siempre— y sigue con
los registros que quedan libres; Sethi y Ullman también tratan ese caso,
que esta sección no implementa.

## 46.11 La lectura de datos

Mini escribe pero no lee. El lenguaje PL de Sterling y Shapiro tiene una
sentencia `read X`, que el compilador traduce a una sola instrucción `read`
con la dirección de `X`. `leer.pl` agrega a Mini `leer x`, que toma el
siguiente número de la entrada y lo asigna a `x`, con una cláusula para
cada etapa, que se agrega a un predicado `multifile` sin modificar el
archivo que lo define: es el [Patrón 57](../patrones.md#57-extension-por-clausulas-multifile) del
[capítulo 45](../capitulo-45-proyecto-aventura-de-texto/index.md), aplicado a
las etapas de un compilador:

<!-- ejemplo: capitulo-46/leer.pl fragmento: reservada(leer). .. put_assoc(entrada, M0, Vs, M) }. -->
```prolog
reservada(leer).

sentencia(leer(X)) -->
    [leer, id(X)].

% En el intérprete: leer x asigna a x el primer número de la entrada, que
% queda sin él.
ejecutar_sentencia(leer(X), E0, E) -->
    { valor('<entrada>', E0, [V|Vs]),
      actualizar('<entrada>', Vs, E0, E1),
      actualizar(X, V, E1, E) }.

nombre(leer(X), X).

% En la máquina: leer apila el primer número de la entrada.
codigo_sentencia(leer(X)) -->
    [leer, guardar(X)].

clase(leer, fija).

paso(leer, s(PC, P, M0), s(PC1, [V|P], M)) -->
    { PC1 is PC + 1,
      get_assoc(entrada, M0, [V|Vs]),
      put_assoc(entrada, M0, Vs, M) }.
```

La entrada es una lista de números y es parte del estado, como pide Triska:
un intérprete es una relación entre estados, y lo que lee el programa es
algo que cambia en cada paso. En el intérprete, el estado es el entorno, y
la entrada es un par más, con un nombre, `'<entrada>'`, que ningún
identificador de Mini puede tener: `valor/3` y `actualizar/4` la leen y la
cambian como a cualquier variable. En la máquina, la entrada está en la
memoria, bajo la clave `entrada`, que tampoco es el número de ninguna
celda; `leer` la apila, y el `guardar(X)` que sigue la asigna. Así la
máquina de pila no necesita una instrucción que nombre una celda.

<!-- ejemplo: capitulo-46/leer.pl predicado: interpretar_con_entrada/3 maquina_con_entrada/3 -->
```prolog
%!  interpretar_con_entrada(+Programa, +Entrada, -Salida) is semidet.
%
%   Como interpretar/2, con Entrada como los números que lee Programa.
interpretar_con_entrada(Programa, Entrada, Salida) :-
    entorno_inicial(Programa, Entorno),
    once(phrase(ejecutar_bloque(Programa, ['<entrada>'-Entrada|Entorno], _),
                Salida)).

%!  maquina_con_entrada(+Objeto, +Entrada, -Salida) is semidet.
%
%   Como maquina/2, con Entrada en la memoria, bajo la clave entrada.
%   Falla si el código lee más números de los que tiene Entrada.
maquina_con_entrada(Objeto, Entrada, Salida) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    list_to_assoc([entrada-Entrada], Memoria),
    phrase(ciclo(Codigo, s(0, [], Memoria)), Salida).
```

```prolog
?- ejecutar_con_entrada("leer x; escribir x * x", [7], S).
S = [49].

?- suma_leida(T), correr_con_entrada(T, [3, 10, 20, 30], S).
T = "leer n; s := 0;\nmientras n > 0 hacer\n  leer x; s := s + x; n := n - 1\nfin;\nescribir s",
S = [60].
```

Un programa que lee más números de los que tiene la entrada no tiene
salida: `valor/3` no encuentra una lista con un primer elemento y la
ejecución falla, en el intérprete y en la máquina. Los programas de ejemplo,
que no leen, escriben lo mismo con la entrada vacía.

## 46.12 Funciones y marcos de pila

El lenguaje de Triska tiene funciones recursivas, y su máquina de pila, las
instrucciones `call` y `ret`. `funciones.pl` agrega a Mini definiciones de
funciones antes del programa, llamadas en las expresiones y la sentencia
`devolver`:

<!-- ejemplo: capitulo-46/funciones.pl fragmento: fuente_f(factorial, [ "funcion fac(n)", .. "escribir fac(5)" ]). -->
```prolog
fuente_f(factorial, [ "funcion fac(n)",
                      "  si n <= 1 entonces devolver 1 fin;",
                      "  devolver n * fac(n - 1)",
                      "fin;",
                      "escribir fac(5)" ]).
```

La gramática de las definiciones es nueva, y la de las sentencias y los
factores recibe una cláusula cada una; la coma es un símbolo nuevo del
análisis léxico:

<!-- ejemplo: capitulo-46/funciones.pl predicado: programa_con_funciones//2 definicion//1 -->
```prolog
%!  programa_con_funciones(?Fs:list, ?Ss:list)// is nondet.
%
%   Las definiciones Fs, cada una seguida de punto y coma, y después el
%   bloque Ss del programa principal.
programa_con_funciones([F|Fs], Ss) -->
    definicion(F),
    [;],
    programa_con_funciones(Fs, Ss).
programa_con_funciones([], Ss) -->
    bloque(Ss).

%!  definicion(?F)// is nondet.
%
%   Una definición funcion(Nombre, Parametros, Cuerpo).
definicion(funcion(F, Ps, Cuerpo)) -->
    [funcion, id(F), '('],
    parametros(Ps),
    [')'],
    bloque(Cuerpo),
    [fin].
```

```prolog
?- analizar_funciones("funcion doble(x) devolver 2 * x fin; escribir doble(4)", P).
P = programa([funcion(doble, [x], [devolver(bin(*, num(2), id(x)))])], [escribir(llamada(doble, [num(4)]))]).
```

Las variables de una función son **locales**: sus parámetros, en orden, y
las demás variables de su cuerpo. Cada llamada necesita sus propios
valores, porque una función recursiva tiene varias llamadas activas a la
vez; la máquina los guarda en un **marco** por llamada, con la dirección a
la que vuelve, y los marcos forman una pila aparte de la de los valores.
Triska guarda los marcos en la misma pila de valores y los recorre con un
desplazamiento; aquí son una lista de términos `marco(Locales, Retorno)`,
el del tope primero, y el estado de la máquina es `f(S, Marcos)`, con `S`
el estado de la máquina de pila. Las cuatro instrucciones nuevas cambian
los marcos; las demás se delegan en `paso//3`, sin tocarlos:

<!-- ejemplo: capitulo-46/funciones.pl predicado: paso_funciones//3 -->
```prolog
%!  paso_funciones(+I, +Estado0, -Estado)// is semidet.
%
%   Ejecutar la instrucción I lleva la máquina de Estado0 a Estado. Las
%   instrucciones de la máquina de pila no tocan los marcos. Un marco es
%   marco(Locales, Retorno): un árbol AVL del número de cada variable local
%   a su valor, y la dirección a la que vuelve la llamada.
paso_funciones(llamar(D, N), f(s(PC, P0, M), Ms),
               f(s(D, P, M), [marco(Locales, Retorno)|Ms])) -->
    !,
    { length(Invertidos, N),
      append(Invertidos, P, P0),
      reverse(Invertidos, Args),
      findall(I-A, nth0(I, Args, A), Pares),
      list_to_assoc(Pares, Locales),
      Retorno is PC + 1 }.
paso_funciones(volver, f(s(_, [V|P], M), [marco(_, Retorno)|Ms]),
               f(s(Retorno, [V|P], M), Ms)) -->
    !.
paso_funciones(cargar_local(I), f(s(PC, P, M), [marco(L, R)|Ms]),
               f(s(PC1, [V|P], M), [marco(L, R)|Ms])) -->
    !,
    { PC1 is PC + 1,
      (   get_assoc(I, L, V0)
      ->  V = V0
      ;   V = 0
      ) }.
paso_funciones(guardar_local(I), f(s(PC, [V|P], M), [marco(L0, R)|Ms]),
               f(s(PC1, P, M), [marco(L, R)|Ms])) -->
    !,
    { PC1 is PC + 1,
      put_assoc(I, L0, V, L) }.
paso_funciones(I, f(S0, Ms), f(S, Ms)) -->
    paso(I, S0, S).
```

`llamar(D, N)` quita de la pila los `N` argumentos, que están invertidos
porque el último se apiló último, y los guarda como las locales 0 a
`N - 1` de un marco nuevo, que vuelve a la instrucción siguiente. `volver`
deja el valor del tope donde está, quita el marco y salta a su dirección
de retorno: como cada sentencia deja la pila como la encontró, debajo del
valor devuelto queda la pila de quien llamó. Una local que nunca se asignó
vale 0, como una celda de la memoria.

El compilador genera cada cuerpo con `generar/2`, igual que el programa
principal, y después cambia las instrucciones que nombran variables:
`localizar/3` reemplaza `cargar(X)` y `guardar(X)` por
`cargar_local(I)` y `guardar_local(I)`, con `I` el lugar de `X` entre las
locales. Las llamadas se generan con el nombre de la función, y
`resolver_llamadas/3` lo cambia por la etiqueta de su primera instrucción,
que es una variable, como las de los saltos: el ensamblador la liga por
unificación. El programa principal termina con un salto al final, para no
seguir con el código de las funciones, y cada función termina con
`apilar(0), volver`, para la que termina sin `devolver`:

<!-- ejemplo: capitulo-46/funciones.pl predicado: compilar_funciones/2 codigo_funcion/3 locales/3 localizar/3 -->
```prolog
%!  compilar_funciones(+Texto, -Objeto:list) is semidet.
%
%   Objeto es el código ensamblado del programa con funciones de Texto: el
%   programa principal, un salto al final, y el código de cada función.
%   Falla si Texto no es un programa, o si llama a una función que no
%   está definida o con otra cantidad de argumentos.
compilar_funciones(Texto, Objeto) :-
    analizar_funciones(Texto, programa(Fs, Ss)),
    maplist(entrada_funcion, Fs, Tabla),
    generar(Ss, Principal0),
    resolver_llamadas(Tabla, Principal0, Principal),
    maplist(codigo_funcion(Tabla), Fs, Codigos),
    append([Principal, [saltar(Fin)] | Codigos], Simbolico0),
    append(Simbolico0, [etiqueta(Fin)], Simbolico),
    ensamblar(Simbolico, Objeto, _).

%!  codigo_funcion(+Tabla:list, +F, -Codigo:list) is semidet.
%
%   Codigo es el código simbólico de la definición F: la marca de su
%   etiqueta, el cuerpo con las variables locales, y devolver 0.
codigo_funcion(Tabla, funcion(F, Ps, Cuerpo), Codigo) :-
    memberchk(F-Etiqueta-_, Tabla),
    generar(Cuerpo, Codigo0),
    locales(Ps, Cuerpo, Locales),
    maplist(localizar(Locales), Codigo0, Codigo1),
    resolver_llamadas(Tabla, Codigo1, Codigo2),
    append([[etiqueta(Etiqueta)], Codigo2, [apilar(0), volver]], Codigo).

%!  locales(+Ps:list, +Cuerpo:list, -Locales:list) is det.
%
%   Locales son las variables locales de una función: los parámetros Ps,
%   en su orden, y después las demás variables de Cuerpo.
locales(Ps, Cuerpo, Locales) :-
    variables(Cuerpo, Vs),
    subtract(Vs, Ps, Otras),
    append(Ps, Otras, Locales).

%!  localizar(+Locales:list, +I0, -I) is det.
%
%   I es la instrucción I0 con la variable que nombra reemplazada por su
%   número entre Locales.
localizar(Locales, I0, I) :-
    (   I0 = cargar(X)
    ->  once(nth0(N, Locales, X)),
        I = cargar_local(N)
    ;   I0 = guardar(X)
    ->  once(nth0(N, Locales, X)),
        I = guardar_local(N)
    ;   I = I0
    ).
```

```prolog
?- compilar_funciones("funcion doble(x) devolver 2 * x fin; escribir doble(4)", O).
O = [apilar(4), llamar(4, 1), escribir, saltar(10), apilar(2), cargar_local(0), multiplicar, volver, apilar(0), volver].

?- fuente_funciones(fibonacci, T), correr_funciones(T, S).
T = 'funcion fib(n)\n  si n < 2 entonces devolver n fin;\n  devolver fib(n - 1) + fib(n - 2)\nfin;\ni := 0;\nmientras i < 8 hacer escribir fib(i); i := i + 1 fin',
S = [0, 1, 1, 2, 3, 5, 8, 13].
```

Las pruebas de `funciones.plt` ejecutan el factorial recursivo y el
iterativo de Triska —cuya variable `n` local no cambia la `n` del programa
principal—, la sucesión de Fibonacci, dos funciones mutuamente recursivas
y un máximo común divisor de dos parámetros; un llamado a una función que
no existe, o con otra cantidad de argumentos, hace fallar la compilación, y
los programas sin funciones escriben lo mismo que con el intérprete. Una
función no ve las variables del programa principal: la única forma de
pasarle un valor es un argumento.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; el paso entre la sintaxis abstracta y las expresiones de Prolog son dos predicados, `a_termino/2` y `de_termino/2`, uno por dirección, porque la conversión de vuelta necesita probar tipos y así cada uno es determinista |
    | C2 | la sintaxis abstracta es una representación limpia: el intérprete, el generador, las optimizaciones y el especializador eligen la cláusula por el functor del nodo |
    | C4 | el análisis, la generación, el ensamblado, la máquina y las optimizaciones no dejan alternativas pendientes; donde la forma del intérprete las deja, `interpretar/2` las descarta con `once/1`, y el texto dice por qué |
    | C6 | ninguna etapa escribe ni guarda estado: la salida de un programa es una lista, y el único estado global es el módulo temporal de `correr_especializado/2`, que se borra al terminar |
    | C7 | 227 pruebas en doce archivos; las cuatro formas de ejecutar se comparan con el intérprete en todos los ejemplos, y el error de las etiquetas unificadas está probado: `mirilla_ingenua/2` une las etiquetas y el ensamblado falla; en las secciones 46.8 a 46.12, la reducción de fuerza y las máquinas de acumulador y de registros se comparan con el intérprete, la asignación de registros con la cuenta de Sethi y Ullman, y la lectura y las funciones con los programas de ejemplo |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

13. **(2)** El generador de la máquina de acumulador usa una temporal para
    `a + b * c`, aunque la suma es conmutativa y `a` es una hoja. Escribir
    `generar_acumulador_conmutativo/2`, que en ese caso calcula primero el
    operando derecho y opera después con la hoja, sin temporal, como
    propone Sterling y Shapiro para las operaciones conmutativas.
    Comprobar que `a + (b + (c + d))` no usa ninguna temporal.
14. **(1)** Predecir cuántos registros necesitan, según Sethi y Ullman, y
    cuántos usa el generador ingenuo, `a + b`, `(a + b) * (c + d)`,
    `a - (b - (c - d))` y `((a + b) + (c + d)) * ((a - b) - (c - d))`, y
    comprobarlo con `registros_necesarios/2` y `registros_usados/2`.
15. **(2)** Escribir `correr_con_profundidad(+Texto, -Salida, -Max)`, como
    `correr_funciones/2`, donde `Max` es la mayor cantidad de marcos que
    tuvo la pila de marcos durante la ejecución. Predecir el valor para el
    factorial recursivo, el iterativo y la sucesión de Fibonacci de
    `fuente_funciones/2`.

## Resumen

| | |
|---|---|
| **Mini** | el lenguaje del capítulo: asignaciones, `si`, `mientras` y `escribir`, sobre enteros |
| **componente léxico** | la unidad del texto: un número, un identificador, una palabra reservada o un símbolo |
| **sintaxis abstracta** | el árbol del programa, con un functor por clase de nodo: `asignar(X, E)`, `si(C, Si, No)`, `mientras(C, Cuerpo)`, `escribir(E)`, `rel(Op, A, B)`, `num(N)`, `id(X)`, `bin(Op, A, B)` |
| **entorno** | la lista de pares `Nombre-Valor` que el intérprete relaciona antes y después de cada sentencia |
| **máquina de pila** | toma los operandos del tope de la pila y deja allí el resultado |
| **código simbólico** | instrucciones con nombres de variables y etiquetas; una etiqueta es una variable de Prolog |
| **ensamblador** | liga cada etiqueta a su dirección por unificación, en una pasada, y da a cada variable su celda |
| **plegado de constantes** | calcular al compilar las operaciones entre constantes |
| **optimizador de mirilla** | reemplaza secuencias cortas de instrucciones por otras equivalentes, hasta que ninguna se aplica |
| **intérprete especializado** | el residuo de evaluar parcialmente el intérprete respecto de un programa: un compilador de Mini a Prolog |
| `lexico/2`, `analizar/2`, `programa//1` | el análisis léxico y sintáctico |
| `interpretar/2`, `ejecutar/2` | el intérprete |
| `generar/2`, `ensamblar/3`, `compilar/2`, `listar_objeto/1` | la generación de código y el ensamblado |
| `maquina/2`, `paso//3`, `correr/2` | la máquina de pila |
| `optimizar/2`, `plegar_expresion/2`, `reordenar_expresion/2`, `mirilla/2` | las optimizaciones |
| `especializar_programa/2`, `control_mini/3`, `correr_especializado/2` | el intérprete especializado |
| `in_temporary_module/3` | ejecuta una meta en un módulo nuevo, que se borra al terminar |
| **reducción de fuerza** | reemplazar una operación por otra más barata con el mismo resultado; la división entera no se reduce a un desplazamiento |
| **máquina de acumulador** | un solo registro; las operaciones lo combinan con un valor de la memoria, y los resultados intermedios van a temporales |
| **asignación de registros** | el algoritmo de Sethi y Ullman: cada nodo necesita uno más que sus operandos si necesitan lo mismo, o el mayor; se calcula primero el que más necesita |
| **marco de pila** | las variables locales de una llamada y su dirección de retorno; una pila aparte de la de los valores |
| `fuerza.pl`, `acumulador.pl`, `registros.pl`, `leer.pl`, `funciones.pl` | la reducción de fuerza, las otras dos máquinas, la lectura y las funciones |
| **[Patrón 59](../patrones.md#59-etiquetas-como-variables-logicas)** | etiquetas como variables lógicas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Subexpresiones comunes con un diccionario incompleto: un grafo en lugar de un árbol | [capítulo 51](../capitulo-51-proyecto-fft-simbolica/index.md) |
| Un intérprete de un lenguaje funcional | [capítulo 58](../capitulo-58-proyecto-interprete-funcional/index.md) |
| El análisis estático de los programas Mini, con tablas | [capítulo 59](../capitulo-59-proyecto-interpretacion-abstracta/index.md) |
| La compilación de Prolog a una máquina abstracta | [capítulo 62](../capitulo-62-proyecto-maquina-prolog/index.md) |

## Referencias

- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — «A Compiler».
  1.ª edición (1986) en [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
  Esta página toma la sentencia de lectura de la
  [sección 46.11](#4611-la-lectura-de-datos) y, en la
  [sección 46.9](#469-una-maquina-de-acumulador), su máquina de acumulador.
- William F. Clocksin, *Clause and Effect: Prolog Programming for the
  Working Programmer*, Springer, 1997 — «Case Study: A Compiler for Three
  Model Computers». Esta página toma, en las secciones
  [46.8](#468-la-reduccion-de-fuerza) a
  [46.10](#4610-una-maquina-de-registros-y-la-asignacion-de-registros), la
  reducción de fuerza y las máquinas de acumulador y de registros.
- Markus Triska, *The Power of Prolog* — «Thinking in States».
  [Edición en línea](https://www.metalevel.at/tist/). Esta página toma, en
  la [sección 46.12](#4612-funciones-y-marcos-de-pila), las funciones
  recursivas con instrucciones de llamada y retorno.
- Alfred V. Aho y Jeffrey D. Ullman, *Principles of Compiler Design*,
  Addison-Wesley, 1977. Clocksin lo remite para las técnicas clásicas de
  compilación; de esa tradición viene la asignación de registros de la
  [sección 46.10](#4610-una-maquina-de-registros-y-la-asignacion-de-registros).
- Ravi Sethi y Jeffrey D. Ullman, «The generation of optimal code for
  arithmetic expressions», *Journal of the ACM* 17(4), 1970, pp. 715–728.
  [Página de la editorial](https://doi.org/10.1145/321607.321620). Esta
  página toma el algoritmo de la
  [sección 46.10](#4610-una-maquina-de-registros-y-la-asignacion-de-registros):
  la cantidad de registros que necesita cada nodo y el orden de cálculo de
  sus operandos.

El lenguaje Mini, sus programas y el código del capítulo son propios,
escritos para el curso: las fuentes aportan ideas y técnicas, no código
copiado ni adaptado.
