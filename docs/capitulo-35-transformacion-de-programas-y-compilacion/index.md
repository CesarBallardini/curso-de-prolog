# Capítulo 35 — Transformación de programas y compilación

Un programa Prolog es un conjunto de términos, y un programa que recibe
términos y produce términos puede recibir un programa y producir otro. El
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) leyó las cláusulas de un programa para **ejecutarlas** con un
intérprete propio; este capítulo las lee para **transformarlas** antes de la
ejecución, mientras el archivo se carga o con un programa aparte. En los dos
casos, el trabajo que no depende de los datos de una consulta se hace una
sola vez, antes de todas las consultas.

Cada sección presenta un programa que repite trabajo en cada ejecución, la
transformación que lo evita y la medición con `time/1`; la última compila
las reglas del sistema experto del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md). El capítulo cumple cinco anuncios: el efecto
de `library(apply_macros)`, de la
[sección 16.9](../capitulo-16-rendimiento/index.md#169-libraryapply_macros); la compilación y la
expansión de términos, del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md); las cláusulas transformadas
al cargar, del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md); el intérprete especializado para un
programa, del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md); y el traductor de las gramáticas, del
[capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md). SWISH admite que un programa defina sus propias expansiones,
y `expansion.pl`, `gramatica.pl`, `desplegar.pl` y `parcial.pl` corren
también allí; los demás cargan otros archivos, cambian banderas del sistema
o escriben en el disco, y corren solo en `swipl`.

El despliegue, el plegado y la evaluación parcial con un control siguen el
capítulo «Program Transformation» de *The Art of Prolog* de Leon Sterling y
Ehud Shapiro; la compilación por evaluación parcial de un intérprete, el
apartado «Partial Execution and Compilers» de *Prolog and Natural-Language
Analysis* de Fernando Pereira y Stuart Shieber; y el traductor de las
gramáticas, el apéndice «Code to Support DCGs» de *Programming in Prolog* de
William Clocksin y Christopher Mellish. Las demás fuentes, con sus enlaces,
están en las [referencias](#referencias) del final.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- transformar las cláusulas y los objetivos de un programa al cargarlo con
  `term_expansion/2` y `goal_expansion/2`, conocer el orden en que se
  aplican y evitar una expansión que no termina;
- escribir el traductor de las gramáticas y compararlo con el de SWI-Prolog;
- desplegar un objetivo y plegar una parte de un cuerpo, y saber cuándo el
  plegado cambia lo que el programa prueba;
- evaluar parcialmente un intérprete respecto de un programa, y obtener así
  un compilador;
- usar las expansiones de `library(apply_macros)` y medir su efecto;
- compilar un archivo a `.qlf` con `qcompile/1`, y decidir cuándo conviene.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:26 h**.
    Resolver los 6 ejercicios marcados con ★: **1:36 h**.
    Resolver los 15 ejercicios del final: **4:16 h**.

## 35.1 `term_expansion/2` y `goal_expansion/2` en SWI-Prolog

Al cargar un archivo, Prolog pasa cada término leído por `expand_term/2`
antes de compilarlo. Si el programa define `term_expansion/2` y el término
lo satisface, se compila lo que ese predicado devuelve: otro término, una
lista de términos o la lista vacía, que hace desaparecer el término.
`expansion.pl` escribe la familia con todos los hijos de cada padre en un
término, y la carga como los hechos `padre/2` de siempre:

<!-- ejemplo: capitulo-35/expansion.pl fragmento: %!  term_expansion(+Termino, -Clausulas:list) is semidet. .. padres(luis, [eva]). consulta: padre(P, luis). -->
```prolog
%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Un término padres(P, Hijos) se reemplaza, al cargarlo, por un hecho
%   padre(P, H) por cada H de Hijos. Falla con cualquier otro término, que
%   se carga sin cambios.
term_expansion(padres(P, Hijos), Hechos) :-
    findall(padre(P, H), member(H, Hijos), Hechos).

% padres(P, Hijos): P es el padre de cada uno de los Hijos; se carga como
% un hecho padre/2 por hijo.
padres(juan, [ana, pedro]).
padres(ana, [luis]).
padres(luis, [eva]).
```

```prolog
?- expand_term(padres(juan, [ana, pedro]), C).
C = [padre(juan, ana), padre(juan, pedro)].
```

`expand_term/2` y `expand_goal/2`, que muestran lo que la carga haría con un
término, se consultan solo en `swipl`: SWISH no permite llamarlos.
`padres/2` no existe en el programa cargado: los tres términos se
reemplazaron por cuatro hechos, que Prolog indexa por cualquiera de sus
argumentos. La expansión se aplica **una vez** a cada término: lo que
devuelve no vuelve a pasar por `term_expansion/2`, pero sí por los pasos
siguientes de `expand_term/2`, que son, en orden, la compilación condicional
(los términos entre un `:- if(Condicion).` que no se cumple y su
`:- endif.` se reemplazan por la lista vacía); `term_expansion/2`, primero
la del módulo que se compila, después la de `user` y por último la de
`system`, cada una sobre el resultado de la anterior; la traducción de las
reglas `-->` ([sección 35.2](#352-como-se-traduce-una-gramatica)); y `goal_expansion/2` sobre cada
objetivo de los cuerpos resultantes.

El gancho es un predicado más: existe desde que su cláusula se carga, y solo
expande lo que se lee **después**. Definido en `user`, alcanza a todos los
archivos que se carguen a continuación; definido en un módulo, solo a ese
módulo. Las bibliotecas heredan de `system`, y un gancho de `user` no las
transforma.

`goal_expansion/2` trabaja sobre los objetivos de los cuerpos. `x_de/2` da la
abscisa de un punto `punto(X, Y)`: un predicado de acceso, que evita que el
programa dependa de la forma del término a costa de una llamada en cada uso.
La expansión reemplaza la llamada por la unificación que el predicado hace:

<!-- ejemplo: capitulo-35/expansion.pl fragmento: %!  goal_expansion(+Meta, -Expandida) is semidet. .. S is S0 + X. consulta: puntos(3, Ps), suma_x(Ps, S). -->
```prolog
%!  goal_expansion(+Meta, -Expandida) is semidet.
%
%   Una llamada x_de(P, X) en el cuerpo de una cláusula se reemplaza por la
%   unificación de P con punto(X, _).
goal_expansion(x_de(P, X), P = punto(X, _)).

%!  suma_x(+Puntos:list, -S:number) is det.
%
%   La misma relación que suma_llamando/2, escrita después de
%   goal_expansion/2: la llamada a x_de/2 se carga como una unificación.
suma_x([], 0).
suma_x([P|Ps], S) :-
    x_de(P, X),
    suma_x(Ps, S0),
    S is S0 + X.
```

```prolog
?- expand_goal(x_de(P, X), G).
G = (P=punto(X, _)).
```

`suma_llamando/2`, en el mismo archivo, tiene el mismo cuerpo que
`suma_x/2`, pero está escrita **antes** del gancho y conserva la llamada.
La diferencia es una inferencia por punto:

```text
?- puntos(100000, Ps), time(suma_llamando(Ps, _)).
% 300,000 inferences, 0.047 CPU in 0.078 seconds (60% CPU, 6400000 Lips)

?- puntos(100000, Ps), time(suma_x(Ps, _)).
% 200,000 inferences, 0.062 CPU in 0.072 seconds (87% CPU, 3200000 Lips)
```

`x_de/2` sigue definido para las llamadas que se construyen al ejecutar,
como `G = x_de(P, X), call(G)`, que ninguna expansión alcanza.
SWI-Prolog usa el mismo mecanismo en `library(debug)`: con `swipl -O`, las
llamadas a `debug/3` y a `assertion/1` de la
[sección 26.5](../capitulo-26-pruebas-y-depuracion/index.md#265-debug3-y-assertion1) se expanden a `true` y desaparecen del programa.

A diferencia de `term_expansion/2`, `goal_expansion/2` se aplica **hasta que
el objetivo deja de cambiar**, porque el resultado puede contener otros
objetivos expandibles. Si el resultado contiene el objetivo original sin
cambios, SWI-Prolog lo detecta y se detiene; pero una expansión que cambia un
argumento y conserva el predicado, como
`goal_expansion(escribir(X), escribir(texto(X)))`, no termina:

```text
?- catch(call_with_time_limit(2, expand_goal(escribir(a), G)), E, true).
E = time_limit_exceeded.
```

`escribir(a)` se expande a `escribir(texto(a))`, y este a
`escribir(texto(texto(a)))`, sin fin: cargar una cláusula que llame a
`escribir/1` no termina. Las defensas son expandir a una llamada a otro
predicado, como `escribir_texto/1`, o exigir una condición que el resultado
no cumpla.

!!! question "Actividad"
    Mover la cláusula de `goal_expansion/2` de `expansion.pl` al comienzo del
    archivo y predecir cuántas inferencias usan `suma_llamando/2` y
    `suma_x/2` con 100 000 puntos. Comprobarlo, y examinar las dos cláusulas
    con `clause/2`.

!!! example "Patrón 49 — Expandir al cargar"
    **Problema.** Un trabajo cuyo resultado se conoce al escribir el programa
    se repite en cada ejecución: una llamada a un predicado de acceso, datos
    escritos en una forma cómoda de leer pero distinta de la que conviene
    consultar.

    **Versión ingenua.** Hacer ese trabajo en cada llamada; o escribir de
    manera explícita la forma expandida en todos los lugares donde se usa.

    **Patrón.** Escribir la forma cómoda y un gancho, `term_expansion/2`
    para los términos del programa o `goal_expansion/2` para los objetivos
    de los cuerpos, que la reemplaza al cargar. El gancho se define antes que
    lo que expande, y el predicado original se conserva para las llamadas
    construidas durante la ejecución.

    **Cuándo no usarlo.** Cuando la ganancia no se midió; cuando el gancho
    de `user` alcanzaría términos ajenos, porque se aplica a todo lo que se
    carga después; y cuando lo que se expande cambia durante la ejecución.
    Una `goal_expansion/2` cuyo resultado vuelve a coincidir con ella misma,
    con otro argumento, no termina.

## 35.2 Cómo se traduce una gramática

La [sección 21.1](../capitulo-21-gramaticas-dcg/index.md#211-una-gramatica-es-un-conjunto-de-clausulas) mostró que cada regla de una gramática se carga como
una cláusula con dos argumentos más, y la
[sección 34.5](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#345-las-gramaticas-como-listas-diferencia), que esos argumentos son una lista diferencia. La
lectura directa de una regla, sin listas diferencia, usa `append/3`: «una
lista de aes y bes es una lista de aes seguida de una lista de bes».
`a_b_append/1`, en `gramatica.pl`, la escribe así, con `append(As, Bs,
Lista)`, que genera las particiones de la lista de la más corta a la más
larga. Con n aes y n bes, la correcta es la número n + 1, y cada una de las
anteriores recorre sus aes antes de fallar: del orden de n² pasos; con 500
aes y 500 bes, 127 253 inferencias, y con el doble, cuatro veces más. La
gramática `a_b//0` describe la misma lista en una sola pasada, porque cada no
terminal entrega lo que sobra al siguiente:

```text
?- aes_bes(1000, L), time(a_b_append(L)).
% 504,502 inferences, 0.047 CPU in 0.056 seconds (84% CPU, 10762709 Lips)

?- aes_bes(1000, L), time(phrase(a_b, L)).
% 3,009 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
```

La traducción es un programa que recibe una regla y produce una cláusula.
`traducir/2` agrega los dos argumentos a la cabeza con `no_terminal/4`, y
`cuerpo/4` recorre el cuerpo con S0, la lista que llega, y S, lo que debe
quedar:

<!-- ejemplo: capitulo-35/gramatica.pl predicado: traducir/2 cuerpo/4 -->
```prolog
%!  traducir(+Regla, -Clausula) is det.
%
%   Clausula es la traducción de la regla de gramática Regla, Cabeza -->
%   Cuerpo, con dos argumentos más: la lista y lo que queda de ella.
traducir((Cabeza --> Cuerpo), (Cabeza1 :- Cuerpo1)) :-
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S, Cuerpo1).

%!  cuerpo(+Cuerpo, ?S0, ?S, -Meta) is det.
%
%   Meta reconoce con Cuerpo la parte de S0 anterior a S.
cuerpo(Var, S0, S, phrase(Var, S0, S)) :-
    var(Var),
    !.
cuerpo((A, B), S0, S, (A1, B1)) :-
    !,
    cuerpo(A, S0, S1, A1),
    cuerpo(B, S1, S, B1).
cuerpo((A ; B), S0, S, (A1 ; B1)) :-
    !,
    cuerpo(A, S0, S, A1),
    cuerpo(B, S0, S, B1).
cuerpo(\+ A, S0, S, (\+ A1, S = S0)) :-
    !,
    cuerpo(A, S0, _, A1).
cuerpo({G}, S0, S, (G, S = S0)) :-
    !.
cuerpo(!, S0, S, (!, S = S0)) :-
    !.
cuerpo([], S0, S, S0 = S) :-
    !.
cuerpo([X|Xs], S0, S, S0 = Lista) :-
    !,
    append([X|Xs], S, Lista).
cuerpo(NoTerminal, S0, S, Meta) :-
    no_terminal(NoTerminal, S0, S, Meta).
```

Una secuencia pasa el resto de la primera parte, S1, a la segunda; una
disyunción da a sus dos ramas la misma entrada y la misma salida. Una lista
de terminales liga la entrada a esos elementos seguidos de la salida: la
concatenación en un paso de la
[sección 34.2](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#342-de-append3-a-la-lista-diferencia). Las llaves, el corte y `\+` no consumen
nada: la salida se unifica con la entrada **después** del objetivo, que se
ejecuta antes de examinar la lista, en el orden en que la regla está
escrita. Una variable, que solo se conoce al ejecutar, se llama con
`phrase/3`, y lo demás es un no terminal.

```prolog
?- traducir((saludo --> [hola], nombre), C).
C = (saludo(_A, _B):-_A=[hola|_C], nombre(_C, _B)).

?- traducir((digito(D) --> [D], { code_type(D, digit) }), C).
C = (digito(D, _A, _B):-_A=[D|_C], code_type(D, digit), _B=_C).
```

SWI-Prolog traduce con `dcg_translate_rule/2`, y produce las mismas
cláusulas con otros nombres de variables: la prueba `como_el_sistema` de
`gramatica.plt` lo verifica con `=@=` sobre doce reglas, una por
construcción.

Con `term_expansion/2`, el traductor del capítulo reemplaza al del sistema:
una regla leída después de este gancho llega convertida en cláusula al paso
de las gramáticas, que ya no la reconoce. Así se cargan `a_b//0`, `aes//0` y
`bes//0`:

<!-- ejemplo: capitulo-35/gramatica.pl fragmento: %!  term_expansion(+Regla, -Clausula) is semidet. .. traducir(Regla, Clausula). -->
```prolog
%!  term_expansion(+Regla, -Clausula) is semidet.
%
%   Las reglas de gramática que siguen se cargan con la traducción de
%   traducir/2.
term_expansion(Regla, Clausula) :-
    Regla = (_ --> _),
    traducir(Regla, Clausula).
```

`listing(aes//0)` muestra la traducción, con una particularidad: la
unificación con que empieza el cuerpo aparece dentro de la cabeza, como
`aes([a|A], B)`, porque SWI-Prolog la compila junto con la cabeza salvo que
la bandera `optimise_unify` tenga el valor `false`.

!!! question "Actividad"
    Predecir la traducción de `cierre --> [fin], !.` y de
    `vocal --> [a] ; [e].` con `traducir/2`, y compararlas con
    `dcg_translate_rule/2`.

## 35.3 Desplegar y plegar

Dos transformaciones cambian la forma de un programa sin cambiar lo que
prueba. **Desplegar** un objetivo de un cuerpo es reemplazarlo por el cuerpo
de cada cláusula cuya cabeza unifica con él, y obtener una cláusula nueva,
una **resolvente**, por cada una: es el paso de resolución que da Prolog al
ejecutar, hecho sobre el programa. **Plegar** es lo inverso: una parte de un
cuerpo que es una instancia del cuerpo de una definición se reemplaza por la
cabeza de la definición.

`desplegar.pl` representa un programa como una lista de cláusulas, con el
cuerpo como lista de objetivos: son datos, y el archivo corre también en
SWISH. El ejemplo es `consecutivos/3`, definido con `append/3`:

<!-- ejemplo: capitulo-35/desplegar.pl fragmento: % programa_append(P): P son las cláusulas de append/3 como datos. .. definicion((consecutivos(X, Y, L) :- [append(_, [X, Y|_], L)])). consulta: desplegada(Cs). -->
```prolog
% programa_append(P): P son las cláusulas de append/3 como datos.
programa_append([ (append([], L, L) :- []),
                  (append([X|Xs], Ys, [X|Zs]) :- [append(Xs, Ys, Zs)]) ]).

% definicion(D): X e Y están seguidos en la lista L.
definicion((consecutivos(X, Y, L) :- [append(_, [X, Y|_], L)])).
```

`desplegar/4` unifica el objetivo N del cuerpo con una copia de la cabeza de
cada cláusula del programa, y lo reemplaza por la copia de su cuerpo;
`mostrar/1`, en el mismo archivo, escribe una cláusula por línea:

<!-- ejemplo: capitulo-35/desplegar.pl predicado: desplegar/4 consulta: desplegada(Cs). -->
```prolog
%!  desplegar(+Clausula, +N:integer, +Programa:list, -Clausulas:list) is det.
%
%   Clausulas son las resolventes de Clausula con las cláusulas de Programa
%   en el objetivo N de su cuerpo, contando desde 1.
desplegar((Cabeza :- Cuerpo), N, Programa, Clausulas) :-
    N1 is N - 1,
    length(Antes, N1),
    append(Antes, [Objetivo|Despues], Cuerpo),
    findall((Cabeza :- Cuerpo1),
            ( member(Clausula, Programa),
              copy_term(Clausula, (Objetivo :- CuerpoObjetivo)),
              append([Antes, CuerpoObjetivo, Despues], Cuerpo1) ),
            Clausulas).
```

```prolog
?- forall(desplegada(Cs), mostrar(Cs)).
consecutivos(A, B, [A, B|_]):-[]
consecutivos(A, B, [_|C]):-[append(_, [A, B|_], C)]
true.
```

La primera resolvente es un hecho: X e Y están seguidos si la lista empieza
con ellos. La segunda conserva `append/3` sobre el resto de la lista, y ese
cuerpo es una instancia del de la definición: plegarlo lo reemplaza por
`consecutivos(A, B, C)`.

<!-- ejemplo: capitulo-35/desplegar.pl predicado: plegar/4 consulta: derivar(Cs). -->
```prolog
%!  plegar(+Clausula, +N:integer, +Definicion, -Plegada) is semidet.
%
%   Plegada es Clausula con los objetivos desde la posición N, si son una
%   instancia del cuerpo de Definicion, reemplazados por su cabeza.
plegar((Cabeza :- Cuerpo), N, Definicion, (Cabeza :- Cuerpo1)) :-
    copy_term(Definicion, (CabezaDef :- CuerpoDef)),
    length(CuerpoDef, K),
    N1 is N - 1,
    length(Antes, N1),
    length(Medio, K),
    append(Antes, Resto, Cuerpo),
    append(Medio, Despues, Resto),
    subsumes_term(CuerpoDef, Medio),
    CuerpoDef = Medio,
    append(Antes, [CabezaDef|Despues], Cuerpo1).
```

`subsumes_term(General, Especifico)` se cumple si Especifico es una instancia
de General, sin ligar variables de Especifico: la parte del cuerpo debe
**tener** la forma de la definición, no poder tomarla. `derivar/1` encadena
los dos pasos:

```prolog
?- forall(derivar(Cs), mostrar(Cs)).
consecutivos(A, B, [A, B|_]):-[]
consecutivos(A, B, [_|C]):-[consecutivos(A, B, C)]
true.
```

Son las cláusulas de `consecutivos/3` del archivo. Hacen las mismas
inferencias que `consecutivos_append/3`, pero no construyen la lista de los
elementos anteriores a X, que `append/3` arma para descartarla:

```text
?- numlist(1, 300000, L), time(consecutivos_append(299999, Y, L)).
% 299,998 inferences, 0.078 CPU in 0.078 seconds (100% CPU, 3839974 Lips)

?- numlist(1, 300000, L), time(consecutivos(299999, Y, L)).
% 299,996 inferences, 0.031 CPU in 0.032 seconds (99% CPU, 9599872 Lips)
```

El tiempo baja a menos de la mitad, y la pila, en 7,2 MB: 24 bytes por
elemento de la lista descartada.

Desplegar conserva lo que el programa prueba: cada resolvente es consecuencia
del programa, y juntas cubren todas las pruebas que pasaban por el objetivo.
Plegar, no siempre. Plegar la definición con ella misma da una cláusula
verdadera e inútil:

```prolog
?- forall((definicion(D), plegar(D, 1, D, C)), mostrar([C])).
consecutivos(A, B, C):-[consecutivos(A, B, C)]
true.
```

Si reemplaza a la definición, `consecutivos/3` se llama a sí misma sin
avanzar: la consulta no termina, y el programa ya no prueba ningún par. El
plegado es seguro cuando la cláusula plegada proviene de al menos un
despliegue, como en `derivar/1`: la llamada recursiva trabaja entonces sobre
una parte más pequeña. El [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) enuncia qué conservan estas
transformaciones en términos del modelo del programa.

## 35.4 Evaluación parcial

Un intérprete recorre el cuerpo de cada cláusula en cada consulta, aunque el
cuerpo no cambie. El de la [sección 33.4](../capitulo-33-introspeccion-y-metainterpretes/index.md#334-arboles-de-prueba), que construye el árbol de
prueba con `pruebas//1`, decide en cada llamada si el cuerpo es `true`, una
conjunción, un predefinido o un objetivo del programa. Con `longitud/2`
sobre 100 000 elementos, usa diez veces las inferencias de la ejecución
directa:

```text
?- numlist(1, 100000, L), time(resolver(longitud(L, _), _)).
% 2,000,021 inferences, 0.422 CPU in 0.441 seconds (96% CPU, 4740791 Lips)
```

Esas decisiones dependen solo del programa. Tomarlas una vez es **evaluar
parcialmente** el intérprete: ejecutar de antemano lo que no depende de los
datos, y dejar el resto como un **residuo**. `parcial/3` recorre un objetivo
como un intérprete, pero lo reemplaza por su residuo. Un predicado de
**control**, que recibe como argumento, decide qué hacer con cada llamada:
desplegarla con sus cláusulas, o dejarla, tal cual o reemplazada por otra.

<!-- ejemplo: capitulo-35/parcial.pl predicado: parcial/3 accion/4 consulta: parcial(potencia(s(s(s(cero))), X, Y), control_potencia, R). -->
```prolog
%!  parcial(+Meta, :Control, -Residuo) is nondet.
%
%   Residuo es Meta con las unificaciones hechas y cada llamada G tratada
%   según call(Control, G, Accion): desplegar, o dejar(R). Una respuesta por
%   cada combinación de cláusulas desplegadas.
parcial(true, _, true) :-
    !.
parcial((A, B), Control, Residuo) :-
    !,
    parcial(A, Control, RA),
    parcial(B, Control, RB),
    conjuncion(RA, RB, Residuo).
parcial(X = Y, _, true) :-
    !,
    X = Y.
parcial(Meta, Control, Residuo) :-
    call(Control, Meta, Accion),
    !,
    accion(Accion, Meta, Control, Residuo).
parcial(Meta, _, Meta).

%!  accion(+Accion, +Meta, :Control, -Residuo) is nondet.
%
%   Residuo es lo que queda de Meta según Accion: desplegar, o dejar(R).
accion(desplegar, Meta, Control, Residuo) :-
    clause(Meta, Cuerpo),
    parcial(Cuerpo, Control, Residuo).
accion(dejar(Residuo), _, _, Residuo).
```

Las unificaciones se hacen al especializar; lo que el control no reconoce,
como un `is/2`, queda para la ejecución. En el mismo archivo, `potencia/3`
eleva X a N, con N en números de Peano, y `control_potencia/2` despliega
cada llamada cuyo exponente se conoce:

```prolog
?- parcial(potencia(s(s(s(cero))), X, Y), control_potencia, R).
R = (_A is X*1, _B is X*_A, Y is X*_B).

?- parcial(potencia(N, X, Y), control_potencia, R).
R = potencia(N, X, Y).
```

Con el exponente 3, el residuo calcula el cubo sin llamar a `potencia/3`;
sin el exponente, no hay nada que desplegar. El control es también lo que
hace terminar la evaluación: si desplegara toda llamada, la segunda consulta
desplegaría la recursión sin fin.

`especializar.pl` contiene el intérprete de la [sección 33.4](../capitulo-33-introspeccion-y-metainterpretes/index.md#334-arboles-de-prueba) y el
programa que interpreta. `especializar/2` evalúa parcialmente `pruebas//1`
sobre el cuerpo de una cláusula, en la representación limpia de
`limpiar/2`, y agrega a la cabeza un argumento para la prueba:

<!-- ejemplo: capitulo-35/especializar.pl predicado: especializar/2 control/2 consulta: especializar((antepasado(A, D) :- padre(A, H), antepasado(H, D)), C). -->
```prolog
%!  especializar(+Clausula, -Especializada) is nondet.
%
%   Especializada es Clausula con la prueba como último argumento de la
%   cabeza, y como cuerpo el residuo de pruebas//1 sobre su cuerpo.
especializar((Cabeza :- Cuerpo0), (Cabeza1 :- Residuo)) :-
    limpiar(Cuerpo0, Cuerpo),
    con_prueba(Cabeza, prueba(Cabeza, Hijos), Cabeza1),
    parcial(pruebas(Cuerpo, Hijos, []), control, Residuo).

%!  control(+Meta, -Accion) is semidet.
%
%   Se despliegan pruebas//1 y ejecutar/1; la prueba de un objetivo del
%   programa queda como llamada a su versión especializada.
control(pruebas(prog(G), S0, S), dejar(Llamada)) :-
    S0 = [Prueba|S],
    con_prueba(G, Prueba, Llamada).
control(pruebas(Cuerpo, _, _), desplegar) :-
    Cuerpo \= prog(_).
control(ejecutar(_), desplegar).
```

`pruebas//1` se despliega sobre `true`, las conjunciones y los predefinidos,
y `ejecutar/1`, hasta quedar reducido al predefinido que ejecuta. La
evaluación se detiene en `prog(G)`: las cláusulas de G se conocerán al
especializar su propio predicado, y queda la llamada a la versión
especializada de G, con la prueba como último argumento. `instalar/1`
especializa los predicados indicados y los agrega al módulo `esp`; el
archivo lo hace al cargarse, con todo el programa:

```prolog
?- listing(esp:antepasado/3).
:- dynamic antepasado/3.

antepasado(A, B, prueba(antepasado(A, B), [C])) :-
    padre(A, B, C).
antepasado(A, B, prueba(antepasado(A, B), [C, D])) :-
    padre(A, E, C),
    antepasado(E, B, D).

true.
```

Son las cláusulas que se escribirían a mano para construir el árbol sin
intérprete, dinámicas porque `instalar/1` las agrega con `assertz/1`. Los
árboles son los del intérprete, en el mismo orden, y el costo es el de la
ejecución directa:

```prolog
?- esp:mayor_que(juan, pedro, P).
P = prueba(mayor_que(juan, pedro), [prueba(edad(juan, 68), []), prueba(edad(pedro, 37), []), sis(68>37)]).
```

```text
?- numlist(1, 100000, L), time(esp:longitud(L, _, _)).
% 200,000 inferences, 0.094 CPU in 0.105 seconds (89% CPU, 2133333 Lips)
```

De 2 000 021 inferencias a 200 000, las de `longitud/2` sin intérprete, y
de 0,44 a 0,10 segundos. Especializar un intérprete respecto de un programa
es la **primera proyección de Futamura**, descrita por Yoshihiko Futamura en
1971: el resultado es el programa compilado, y el evaluador parcial, junto
con el intérprete, hace el trabajo de un compilador. Pereira y Shieber
(*Prolog and Natural-Language Analysis*, apartado «Compiling by Partial
Execution») construyen así un compilador de gramáticas.

El evaluador trata solo programas puros: desplegar adelanta al momento de
especializar unificaciones que el intérprete hacía después, y ese cambio de
orden no altera las respuestas mientras lo desplegado no tenga cortes ni
efectos laterales. Por eso el control despliega `pruebas//1` y
`ejecutar/1`, y no `limpiar/2`, que tiene cortes.

!!! question "Actividad"
    Predecir el residuo de
    `parcial(potencia(s(s(cero)), 2, Y), control_potencia, R)` y el valor
    de Y después de `call(R)`.

!!! example "Patrón 50 — Especializar el intérprete"
    **Problema.** Un intérprete —[Patrón 45](../patrones.md#45-interprete-que-absorbe),
    [Patrón 46](../patrones.md#46-extender-el-interprete-no-el-programa)— paga en cada consulta el recorrido
    de una estructura que no cambia: los cuerpos de las cláusulas, las
    condiciones de las reglas.

    **Versión ingenua.** Interpretar siempre; o escribir aparte un compilador
    propio, que hay que mantener de acuerdo con el intérprete.

    **Patrón.** Evaluar parcialmente el intérprete respecto del programa: un
    evaluador parcial despliega las llamadas del intérprete cuyo argumento de
    control se conoce y deja como residuo las que dependen de los datos. El
    resultado son cláusulas comunes que hacen lo que el intérprete haría. Un
    predicado de control decide qué se despliega y dónde se detiene la
    evaluación; con `term_expansion/2`, la especialización ocurre al cargar.

    **Cuándo no usarlo.** Cuando el programa interpretado cambia durante la
    ejecución: una regla agregada con `assertz/1` a un predicado dinámico la
    ve el intérprete y no la versión especializada. Cuando lo que se
    despliega tiene cortes o efectos laterales. Y cuando el costo del
    intérprete no se midió o no pesa.

## 35.5 Macros de la biblioteca

La [sección 16.9](../capitulo-16-rendimiento/index.md#169-libraryapply_macros) presentó `library(apply_macros)`, que reescribe
`maplist/2..7`, `forall/2`, `once/1`, `ignore/1` y `phrase/2,3` como
recursiones o construcciones de control comunes. Es una `goal_expansion/2`
del módulo `system`, y en SWI-Prolog 9.2.9 no alcanza con cargarla: expande
solo si la bandera `optimise_apply` tiene el valor `true`, o `default` —su
valor inicial— y `swipl` se inició con `-O`. `macros.pl` fija la bandera
antes de cargar la biblioteca:

<!-- ejemplo: capitulo-35/macros.pl fragmento: :- set_prolog_flag(optimise_apply, true). .. maplist(doble, Xs, Ys). consulta: dobles_lambda([1, 2, 3], D). -->
```prolog
:- set_prolog_flag(optimise_apply, true).
:- use_module(library(apply_macros)).
:- use_module(library(yall)).

%!  doble(+X:number, -Y:number) is det.
%
%   Y es el doble de X.
doble(X, Y) :-
    Y is 2 * X.

%!  dobles(+Xs:list(number), -Ys:list(number)) is det.
%
%   Ys tiene el doble de cada número de Xs.
dobles(Xs, Ys) :-
    maplist(doble, Xs, Ys).
```

```prolog
?- expand_goal(maplist(doble, L, D), G).
G = '__aux_maplist/3_doble+0'(L, D).

?- expand_goal(forall(member(X, L), X > 0), G).
G = (\+ (member(X, L), \+X>0)).
```

`maplist/3` se reemplaza por un predicado auxiliar que la biblioteca genera
al cargar con `compile_aux_clauses/1`: una recursión sobre las dos listas
que llama directamente a `doble/2`, como muestra `listing/1`. `forall/2` se
reemplaza por su definición, la doble negación de la
[sección 17.6](../capitulo-17-todas-las-soluciones/index.md#176-forall2). Con un predicado con nombre, la expansión no cambia las
inferencias, como observó la [sección 18.7](../capitulo-18-orden-superior/index.md#187-cuando-no-usar-el-orden-superior): hay una llamada por
elemento en los dos casos. Con una lambda, en cambio, la expansión la
convierte en otro predicado auxiliar, y evita copiarla en cada elemento.
`dobles_lambda/2` escribe la lambda en el cuerpo;
`dobles_en_ejecucion/2` construye la misma llamada al ejecutarse, y esa no
se expande:

```text
?- numlist(1, 100000, L), time(dobles_lambda(L, _)).
% 300,001 inferences, 0.031 CPU in 0.030 seconds (103% CPU, 9600032 Lips)

?- numlist(1, 100000, L), time(dobles_en_ejecucion(L, _)).
% 1,301,594 inferences, 0.297 CPU in 0.309 seconds (96% CPU, 4384317 Lips)
```

La biblioteca no expande las llamadas construidas al ejecutar ni las
consultas del intérprete interactivo, y conviene, como toda expansión,
después de medir ([Patrón 10](../patrones.md#10-medir-antes-de-cambiar)).

## 35.6 Archivos `.qlf`

La [sección 31.7](../capitulo-31-ejecutables-y-distribucion/index.md#317-archivos-qlf-en-una-nota) presentó los archivos `.qlf` en una nota. Al cargar un
fuente, Prolog lee cada término, lo expande con los pasos de la
[sección 35.1](#351-term_expansion2-y-goal_expansion2-en-swi-prolog) y compila el resultado a instrucciones de su máquina
virtual; un `.qlf` guarda esas instrucciones, y cargarlo evita leer, expandir
y compilar. `precompilar.pl` escribe con `generar_cuadrados/2` un archivo de
hechos `cuadrado(I, C)`, y lo compila con `precompilar/1`, que llama a
`qcompile/1`. Con 200 000 hechos, generados en un directorio temporal:

```text
?- time(precompilar('cuadrados.pl')).
% 15,401,025 inferences, 4.422 CPU in 4.509 seconds (98% CPU, 3482917 Lips)
```

`qcompile/1` compila el fuente, lo carga y escribe `cuadrados.qlf` junto a
él: 4,8 MB, frente a los 6,1 MB del fuente. En una sesión nueva, cada uno
se carga así:

```text
?- time(consult('cuadrados.pl')).
% 15,000,842 inferences, 3.797 CPU in 3.847 seconds (99% CPU, 3950839 Lips)

?- time(consult('cuadrados.qlf')).
% 565 inferences, 0.094 CPU in 0.098 seconds (96% CPU, 6027 Lips)
```

Casi cuatro segundos contra una décima. `consult(cuadrados)`, sin extensión,
elige el `.qlf` si es más reciente que el fuente; si el fuente cambió
después, lo recompila al cargar y lo informa con el mensaje
`recompiling QLF file (out of date)`.

Un `.qlf` guarda las cláusulas **ya expandidas**: al cargarlo,
`term_expansion/2` no se ejecuta y el fuente no hace falta. La prueba
`expandido` de `precompilar.plt` compila un archivo con la expansión de
`padres/2`, borra el fuente, carga el `.qlf` y encuentra los hechos
`padre/2`. Las directivas, en cambio, se guardan como tales y se ejecutan al
cargar el `.qlf`. De ahí una advertencia del manual: una expansión que
agrega cláusulas con `assertz/1`, además de devolverlas, funciona al
consultar el fuente pero no al compilarlo, porque lo agregado no queda en el
`.qlf`; para eso está `compile_aux_clauses/1`, la que usa
`library(apply_macros)`.

Las instrucciones de un `.qlf` son las de la máquina virtual de la versión
que lo compiló. La bandera `abi_version` informa las versiones de los
formatos de los que depende:

```prolog
?- current_prolog_flag(abi_version, V).
V = abi{built_in:1938831497, foreign_interface:2, qlf:69, qlf_min_load:68, record:3, vmi:1082916852}.
```

`qlf` es la versión del formato, `qlf_min_load` la más antigua que se puede
cargar y `vmi`, el conjunto de instrucciones. Un `.qlf` es, como el programa
guardado del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), un producto de la compilación que no reemplaza
al fuente: se regenera al cambiar de versión. Conviene para archivos grandes,
sobre todo de datos, que se cargan muchas veces sin cambiar.

## 35.7 Las reglas compiladas

El sistema experto de la [sección 33.7](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica) interpreta sus reglas con
`demostrar/4` en cada consulta, aunque las reglas no cambien entre consultas.
`experto.pl` las compila al cargarlas: `term_expansion/2` agrega, por cada
término `regla/2`, una cláusula de `concluir/4`, que es `demostrar/4`
evaluado parcialmente con `parcial/3` de la [sección 35.4](#354-evaluacion-parcial) sobre las
condiciones de esa regla. [La página de las reglas compiladas](experto.md)
muestra la expansión y su control, una regla compilada, la medición —algo más
de la mitad de las inferencias del intérprete— y qué cambia cuando se agrega
una regla durante la ejecución.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado de los transformadores declara sus modos: `traducir/2` y `desplegar/4` son `det`, `plegar/4` es `semidet`, `parcial/3` es `nondet`, una respuesta por combinación de cláusulas desplegadas; los ganchos `term_expansion/2` y `goal_expansion/2` son `semidet`, porque fallan con lo que no expanden |
    | C4 | `traducir/2`, `desplegar/4` y `plegar/4` no dejan alternativas: sus pruebas no declaran `nondet` |
    | C7 | 73 pruebas en los ocho archivos del capítulo; cada transformación se compara con el original: la traducción con `dcg_translate_rule/2` en doce reglas (`como_el_sistema`), la derivación con las cláusulas cargadas (`derivar`), la versión especializada y la compilada con el intérprete, árbol por árbol (`como_el_interprete`, `arboles`), el `.qlf` con el fuente (`qlf`) |
    | C2, C3 del programa transformado | se conservan: la versión especializada y las reglas compiladas dan las mismas respuestas y los mismos árboles, en el mismo orden, que el intérprete |
    | lo que se pierde | la posibilidad de cambiar el programa durante la ejecución: una regla agregada con `assertz/1` no se compila; el corte y los efectos laterales en lo que se despliega, porque el evaluador parcial trata programas puros; y la lectura directa del código, que `listing/1` muestra ya transformado |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta y comprobarla, con
   `expansion.pl` o `gramatica.pl`: `expand_term(padres(ana, []), C).` ·
   `expand_goal(x_de(punto(1, 2), X), G).` ·
   `traducir((a --> b, [c]), C).` · `traducir((a --> []), C).`
2. **(1)** Con `expansion.pl` cargado, determinar si la llamada a `x_de/2`
   se expande en la consulta `x_de(punto(3, 4), X).` y en las cláusulas
   `abscisa(P, X) :- call(x_de, P, X).` y
   `abscisa2(P, X) :- G = x_de(P, X), call(G).`, cargadas después del
   gancho. Comprobarlo con `listing/1`.
3. ★ **(2)** Escribir una expansión que cargue un término
   `tabla(Nombre, Pares)`, con Pares una lista de `Clave-Valor`, como un
   hecho `Nombre(Clave, Valor)` por par:
   `tabla(capital, [chile-santiago, peru-lima])` se carga como
   `capital(chile, santiago)` y `capital(peru, lima)`.
4. ★ **(2)** Corregir la expansión de `escribir/1` de la
   [sección 35.1](#351-term_expansion2-y-goal_expansion2-en-swi-prolog) de dos maneras: con una llamada a otro predicado, y
   con una condición que el resultado no cumpla.
5. **(2)** Agregar a `traducir/2` los terminales escritos como cadena, como
   `saludo --> "hola".`, que SWI-Prolog traduce con los códigos de sus
   caracteres, y comparar el resultado con `dcg_translate_rule/2`.
6. **(2)** Agregar a `traducir/2` el pushback de la
   [sección 21.9](../capitulo-21-gramaticas-dcg/index.md#219-pushback), `Cabeza, Terminales --> Cuerpo`, y comparar la
   traducción de `siguiente(C), [C] --> [C].` con la del sistema.
7. ★ **(2)** Con `desplegar/4` y `plegar/4`, derivar una definición
   recursiva de `ultimo(X, L)` a partir de
   `ultimo(X, L) :- [append(_, [X], L)]`, y comprobar que da las mismas
   respuestas que la definición.
8. **(3)** `suma_largo(L, S, N)` se define como `suma(L, S)` seguido de
   `largo(L, N)`, y recorre la lista dos veces. Desplegar los dos objetivos,
   reordenar a mano el cuerpo de la cláusula recursiva para que las dos
   llamadas sobre el resto queden juntas, y plegarlas con la definición.
   Medir las dos versiones con una lista de 100 000 números.
9. ★ **(2)** Evaluar parcialmente `resolver_cuerpo/1`, el intérprete de la
   [sección 33.2](../capitulo-33-introspeccion-y-metainterpretes/index.md#332-el-interprete-vainilla) con representación limpia, sobre las cláusulas de
   `antepasado/2` y `mayor_que/2`, con un control que se detenga en
   `prog(G)` y deje la llamada a G. Comparar el resultado con el programa
   original.
10. **(2)** `pertenece/2` es `member/2` escrito en el programa. Evaluar
    parcialmente `pertenece(X, [a, b, c])` con un control que despliegue
    `pertenece/2` cuando su lista se conoce, y construir con los residuos
    las cláusulas de `es_letra/1`. ¿Cuántos residuos hay, y por qué?
11. **(1)** Con `macros.pl` cargado, mostrar con `expand_goal/2` en qué se
    expanden `once(p(X))` e `ignore(p(X))`, y explicar la diferencia.
12. **(1)** Con `datos.pl` y `datos.qlf` en un directorio, se edita
    `datos.pl` y se ejecuta `consult(datos)`: decir qué se carga y qué
    ocurre con `datos.qlf`, y comprobarlo.
13. ★ **(2)** Agregar a `experto.pl` la regla
    `regla(r13, si mamifero y vuela entonces murcielago)` y la hipótesis
    `murcielago`. Mostrar su cláusula compilada y comprobar con un caso que
    `identificar/2` e `identificar_compilado/2` la usan. ¿Qué ocurre si una
    regla se agrega con `assertz/1` después de cargar el archivo, con
    `regla/2` estática y con `regla/2` dinámica?
14. **(3)** Escribir la expansión de las reglas de `experto.pl` sin el
    evaluador parcial: `compilar_condicion/5` traduce las condiciones de una
    regla directamente al cuerpo de `concluir/4`. Comprobar que produce las
    mismas cláusulas que `experto.pl`, y explicar qué relación tiene con el
    control de [la página de las reglas compiladas](experto.md).
15. **(2)** En la representación de `desplegar.pl`, la rotación de una lista
    diferencia, que pasa el primer elemento al final, se define con
    `concatenar_dif/3` de la
    [sección 34.2](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#342-de-append3-a-la-lista-diferencia):
    `(rotar_dif([X|Xs]-F, R) :- [concatenar_dif(Xs-F, [X|G]-G, R)])`.
    Desplegarla con `desplegar/4` y el programa
    `[(concatenar_dif(L-M, M-F, L-F) :- [])]`, y explicar la cláusula que se
    obtiene. Con esa cláusula, predecir la respuesta de
    `rotar_dif([a, b]-[], R).` y el resultado de rotar dos veces
    `[1, 2, 3|Q]-Q`.

## Resumen

| | |
|---|---|
| `term_expansion/2` | gancho que reemplaza, al cargar, un término leído por otro, por una lista de términos o por ninguno; se aplica una vez, a lo que se lee después de su definición |
| `goal_expansion/2` | gancho que reemplaza, al cargar, un objetivo de un cuerpo; se aplica hasta que el objetivo no cambia |
| `expand_term/2` | los pasos de la carga de un término: compilación condicional, `term_expansion/2`, gramáticas, `goal_expansion/2` |
| `expand_goal/2` | la expansión de un objetivo, como la hace la carga |
| `dcg_translate_rule/2` | la traducción de una regla de gramática que hace SWI-Prolog |
| `subsumes_term/2` | el segundo término es una instancia del primero, sin ligar sus variables |
| `compile_aux_clauses/1` | compilar, desde una expansión, cláusulas auxiliares que se guardan también en un `.qlf` |
| `qcompile/1` | compilar un fuente a `.qlf`: las cláusulas ya expandidas, en instrucciones de la máquina virtual de esa versión |
| bandera `optimise_apply` | `true` activa las expansiones de `library(apply_macros)`; con `default`, las activa `swipl -O` |
| bandera `abi_version` | las versiones de los formatos de los que dependen los `.qlf` |
| desplegar y plegar | reemplazar un objetivo por los cuerpos de sus cláusulas, y una parte de un cuerpo por la cabeza de una definición; plegar sin haber desplegado puede crear una recursión que no avanza |
| evaluación parcial | ejecutar de antemano lo que no depende de los datos; un control decide qué se despliega y dónde se detiene |
| `findnsols/4` | como `findall/3`, hasta una cantidad de soluciones; en las pruebas |
| `unload_file/1` | descarga las cláusulas de un archivo; en las pruebas |
| **Patrones 49, 50** | expandir al cargar; especializar el intérprete |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Qué conservan el despliegue y el plegado: el modelo mínimo del programa | [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) |
| Una directiva que cambia al cargar cómo se ejecuta un predicado: `:- table` | [capítulo 39](../capitulo-39-tabulacion/index.md) |
| La reescritura de expresiones en un programa que resuelve ecuaciones | [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) |
| El intérprete de un lenguaje evaluado parcialmente, comparado con su compilador | [capítulo 45](../capitulo-45-proyecto-compilador/index.md) |

## Referencias

- Leon Sterling y Ehud Shapiro, *The Art of Prolog*, 2.ª edición, MIT
  Press, 1994 — capítulo «Program Transformation», apartados «Unfold/Fold
  Transformations» y «Partial Reduction».
  [Edición en línea](https://archive.org/details/artofprologadvan00ster).
  El capítulo toma el despliegue y el plegado como pasos de resolución entre
  cláusulas, y el evaluador parcial gobernado por declaraciones del usuario,
  que aquí es el predicado de control.
- Fernando Pereira y Stuart Shieber, *Prolog and Natural-Language
  Analysis*, CSLI, 1987 — apartado «Partial Execution and Compilers».
  [Edición digital de Microtome](http://www.mtome.com/Publications/PNLA/pnla-digital.html).
  El capítulo toma la compilación por evaluación parcial de un intérprete.
- William Clocksin y Christopher Mellish, *Programming in Prolog*, 5.ª
  edición, Springer, 2003 — apéndice «Code to Support DCGs»; y Ulf Nilsson y
  Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª edición, Wiley,
  1995 — apartado «Compilation of DCGs into Prolog»
  ([edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/)).
  El capítulo toma de ambos la traducción de una regla de gramática.
- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — capítulo «Program transformation».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  El capítulo toma el ejemplo de los elementos consecutivos, derivado por
  despliegue y plegado, y la justificación del plegado en el modelo mínimo.
- Attila Csenki, *Prolog Techniques*, Ventus Publishing (Bookboon), 2009 —
  apartados «Program Transformations» y «Case Study: Automated Unfolding».
  [Página de la editorial, copia de archivo](https://web.archive.org/web/20220123025207/https://bookboon.com/en/prolog-techniques-applications-of-prolog-ebook?mediaType=ebook).
  El capítulo toma el despliegue hecho por un programa sobre cláusulas
  representadas como datos.
- Markus Triska, *The Power of Prolog* — «Prolog Macros».
  [Edición en línea](https://www.metalevel.at/prolog/macros). El capítulo
  toma las preguntas que cada sistema responde a su manera (si una expansión
  se vuelve a expandir, si se expanden las consultas), respondidas aquí para
  SWI-Prolog.
- Yoshihiko Futamura, «Partial evaluation of computation process — an
  approach to a compiler-compiler», 1971; reeditado en *Higher-Order and
  Symbolic Computation* 12(4), 1999
  ([página de la editorial](https://doi.org/10.1023/A:1010095604496)).
- El manual de SWI-Prolog: «Conditional compilation and program
  transformation»
  ([en línea](https://www.swi-prolog.org/pldoc/man?section=progtransform)),
  «Quick load files» ([en línea](https://www.swi-prolog.org/pldoc/man?section=qlf))
  y `library(apply_macros)`
  ([en línea](https://www.swi-prolog.org/pldoc/doc/_SWI_/library/apply_macros.pl)).

El código del capítulo es propio, escrito para el curso: las fuentes
aportan técnicas y definiciones, no código copiado ni adaptado.
