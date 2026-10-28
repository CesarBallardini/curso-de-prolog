# Guiones: una historia y el guion DOCTOR

Esta página continúa la página [ANALOGY](analogia.md#567-analogy-analogias-geometricas) del
[capítulo 56](index.md), con las secciones [56.8](#568-guiones-completar-una-historia) y
[56.9](#569-el-guion-doctor-de-weizenbaum): el aplicador de guiones al estilo de McSAM,
`guiones.pl`, que no es un módulo ni carga otros archivos y corre en SWISH,
y el guion DOCTOR de Weizenbaum, la manera en que el artículo de 1966
escribe las reglas de ELIZA.

## 56.8 Guiones: completar una historia

«Juan fue a Leones, comió una hamburguesa y se fue.» Quien lee la historia
entiende que Juan fue a un restaurante, se sentó, pidió, le trajeron la
comida y pagó, aunque nada de eso está escrito: conoce el guion de un
restaurante. SAM, el aplicador de guiones de Roger Schank y su grupo de Yale,
y su versión para la enseñanza, McSAM, hacían esa inferencia: la historia se
empareja con un guion, en orden, y los pasos que la historia omite se
completan con los del guion. `guiones.pl` es la versión de Sterling y
Shapiro con estructuras en lugar de listas, como propone uno de sus
ejercicios, y con una gramática que cuenta la historia entendida:

<!-- ejemplo: capitulo-56/guiones.pl predicado: contar/2 -->
```prolog
%!  contar(+Sucesos:list, -Texto:string) is det.
%
%   Texto cuenta los Sucesos en castellano, una oración por suceso.
contar(Sucesos, Texto) :-
    phrase(oraciones(Sucesos), Codigos),
    string_codes(Texto, Codigos).
```

```prolog
?- historia(leones, H), entender(H, Guion, E), contar(E, T).
H = [ir(juan, casa, leones), comer(juan, hamburguesa), ir(juan, leones, otro_lugar)],
Guion = restaurante,
E = [ir(juan, casa, leones), sentarse(juan, mesa), pedir(juan, hamburguesa, mozo), traer(mozo, hamburguesa, juan), comer(juan, hamburguesa), pagar(juan, cuenta, mozo), ir(juan, leones, otro_lugar)],
T = "Juan fue de su casa a Leones. Juan se sentó a una mesa. Juan le pidió una hamburguesa al mozo. El mozo le trajo una hamburguesa a Juan. Juan comió una hamburguesa. Juan le pagó la cuenta al mozo. Juan fue de Leones a otro lugar." ;
false.
```

Un guion describe una situación conocida como una sucesión de sucesos: en un
restaurante, el cliente llega, se sienta, pide, le traen la comida, come,
paga y se va. McSAM, en la versión de Sterling y Shapiro, representa cada
suceso con una lista cuyo primer elemento es una primitiva de la teoría de
dependencia conceptual de Schank (`ptrans` para un traslado, `ingest` para
comer); un ejercicio del libro propone reescribirlo con estructuras. Aquí
cada suceso es un término con un verbo como functor: `ir(Quien, Desde,
Hacia)`, `comer(Quien, Comida)`. Los papeles del guion son variables, y
cada una tiene un valor por omisión:

<!-- ejemplo: capitulo-56/guiones.pl predicado: guion/3 -->
```prolog
%!  guion(?Nombre, -Sucesos:list, -Papeles:list) is nondet.
%
%   Sucesos son los sucesos del guion Nombre, en orden, y Papeles los
%   pares Papel-Omision, donde Papel es una variable de los sucesos y
%   Omision el valor que toma si la historia no lo nombra.
guion(restaurante,
      [ ir(Cliente, Antes, Local),
        sentarse(Cliente, Mesa),
        pedir(Cliente, Comida, Mozo),
        traer(Mozo, Comida, Cliente),
        comer(Cliente, Comida),
        pagar(Cliente, Cuenta, Mozo),
        ir(Cliente, Local, Despues)
      ],
      [ Cliente-cliente, Antes-casa, Local-restaurante, Mesa-mesa,
        Comida-comida, Mozo-mozo, Cuenta-cuenta, Despues-otro_lugar ]).
guion(colectivo,
      [ ir(Pasajero, Antes, Parada),
        subir(Pasajero, Colectivo, Parada),
        pagar(Pasajero, Boleto, Chofer),
        viajar(Pasajero, Colectivo, Destino),
        bajar(Pasajero, Colectivo, Destino)
      ],
      [ Pasajero-pasajero, Antes-casa, Parada-parada,
        Colectivo-colectivo, Boleto-boleto, Chofer-chofer,
        Destino-destino ]).
```

Una historia es una lista de sucesos con variables donde el texto no dice
nada. «Juan fue a Leones, comió una hamburguesa y se fue» es:

<!-- ejemplo: capitulo-56/guiones.pl fragmento: historia(leones, [ ir(juan, _, leones), .. ir(_, _, _) ]). -->
```prolog
historia(leones, [ ir(juan, _, leones),
                   comer(_, hamburguesa),
                   ir(_, _, _) ]).
```

**Entender una historia** tiene tres pasos, los de McSAM. Primero, una
palabra de la historia activa un guion: `leones` activa el del restaurante,
por el hecho `activa(leones, restaurante)`. Después, los sucesos de la
historia se emparejan en orden con algunos de los sucesos del guion; la
unificación liga los papeles (`Cliente = juan`, `Local = leones`) y las
variables de la historia (el que come es el cliente). Por último, los
papeles que ningún suceso nombró toman su valor por omisión:

<!-- ejemplo: capitulo-56/guiones.pl predicado: entender/3 subsucesion/2 por_omision/1 -->
```prolog
%!  entender(+Historia:list, -Nombre, -Entendida:list) is nondet.
%
%   Entendida son los sucesos del guion Nombre, activado por una palabra
%   de Historia, con los sucesos de Historia emparejados en orden y los
%   papeles que Historia no nombra completados con su valor por omisión.
entender(Historia, Nombre, Entendida) :-
    palabra_de(Historia, Palabra),
    activa(Palabra, Nombre),
    guion(Nombre, Entendida, Papeles),
    subsucesion(Historia, Entendida),
    maplist(por_omision, Papeles).

%!  subsucesion(?Historia:list, ?Guion:list) is nondet.
%
%   Los sucesos de Historia unifican, en el mismo orden, con algunos de los
%   sucesos de Guion.
subsucesion([], _).
subsucesion([S|Ss], [S|Gs]) :-
    subsucesion(Ss, Gs).
subsucesion([S|Ss], [_|Gs]) :-
    subsucesion([S|Ss], Gs).

%!  por_omision(+Par) is det.
%
%   Si el papel de Par = Papel-Omision sigue libre, queda ligado a Omision.
por_omision(Papel-Omision) :-
    (   var(Papel)
    ->  Papel = Omision
    ;   true
    ).
```

`subsucesion/2` tiene tres cláusulas: la historia vacía termina; el primer
suceso de la historia unifica con el primero del guion; o el primero del
guion se saltea. El orden de las dos últimas decide qué emparejamiento se
prueba primero: el que usa el suceso del guion antes que el que lo saltea. En
la historia de Leones, el primer `ir/3` de la historia unifica con el primero
del guion, y el último, `ir(_, _, _)`, que no nombra a nadie, con el último:
entre ellos está `comer/2`, y el orden no deja otra posibilidad.

```prolog
?- historia(colectivo, H), entender(H, G, E).
H = [subir(ana, colectivo, parada), bajar(ana, colectivo, plaza)],
G = colectivo,
E = [ir(ana, casa, parada), subir(ana, colectivo, parada), pagar(ana, boleto, chofer), viajar(ana, colectivo, plaza), bajar(ana, colectivo, plaza)] ;
false.

?- historia(sin_guion, H), entender(H, G, E).
false.
```

Una historia sin ninguna palabra que active un guion no se entiende. Una
historia que activa un guion pero no sigue su orden tampoco:
`subsucesion/2` falla, y `entender/3` prueba con otra palabra de la
historia.

**Contar la historia entendida.** `contar/2` la redacta con una gramática,
una oración por suceso, en pasado. Los nombres propios se escriben con
mayúscula, y los sustantivos comunes llevan el artículo que les corresponde
por género y número, con las contracciones «al» y «del»:

<!-- ejemplo: capitulo-56/guiones.pl predicado: oracion//1 -->
```prolog
%!  oracion(+Suceso)// is det.
%
%   La oración que cuenta Suceso, en pasado.
oracion(ir(Q, D, H)) -->
    sujeto(Q), " fue ", desde(D), " ", hacia(H), ".".
oracion(sentarse(Q, M)) -->
    sujeto(Q), " se sentó a ", un(M), ".".
oracion(pedir(Q, C, M)) -->
    sujeto(Q), " le pidió ", un(C), " ", al(M), ".".
oracion(traer(M, C, Q)) -->
    sujeto(M), " le trajo ", un(C), " ", al(Q), ".".
oracion(comer(Q, C)) -->
    sujeto(Q), " comió ", un(C), ".".
oracion(pagar(Q, C, M)) -->
    sujeto(Q), " le pagó ", el(C), " ", al(M), ".".
oracion(subir(Q, C, P)) -->
    sujeto(Q), " subió ", al(C), " en ", lugar(P), ".".
oracion(viajar(Q, C, D)) -->
    sujeto(Q), " viajó en ", el(C), " hasta ", lugar(D), ".".
oracion(bajar(Q, C, P)) -->
    sujeto(Q), " bajó ", del(C), " en ", lugar(P), ".".
```

```prolog
?- historia(colectivo, H), entender(H, _, E), contar(E, T).
H = [subir(ana, colectivo, parada), bajar(ana, colectivo, plaza)],
E = [ir(ana, casa, parada), subir(ana, colectivo, parada), pagar(ana, boleto, chofer), viajar(ana, colectivo, plaza), bajar(ana, colectivo, plaza)],
T = "Ana fue de su casa a la parada. Ana subió al colectivo en la parada. Ana le pagó el boleto al chofer. Ana viajó en el colectivo hasta Plaza. Ana bajó del colectivo en Plaza." ;
false.
```

Los hechos `historia/2`, `activa/2`, `guion/3` y `sustantivo/4`, y las
reglas de `oracion//1`, están declarados `multifile`: un archivo aparte
puede agregar un guion con sus palabras y sus oraciones sin modificar
`guiones.pl`, como pide el ejercicio 11.

!!! question "Actividad"
    Predecir qué da `entender/3` con la historia
    `[traer(mozo, empanadas, luis), ir(luis, _, _)]`, y con
    `[ir(luis, _, _), traer(mozo, empanadas, luis)]`. Comprobarlo, y
    explicar con `subsucesion/2` a qué `ir/3` del guion se liga el suceso
    `ir/3` de cada historia.

## 56.9 El guion DOCTOR de Weizenbaum

La ELIZA de la versión 3 toma de Weizenbaum el rango, los turnos y la
memoria, pero no su manera de escribir las reglas. En el artículo de 1966,
ELIZA es un intérprete y DOCTOR es el **guion** que interpreta: una tabla
de palabras clave en la que cada clave tiene un rango y una lista de
**reglas de descomposición**, y cada regla de descomposición, una lista de
**reglas de reensamblado**. La descomposición `(0 YOU 0 ME)` reparte la
frase en cuatro partes —cualquier cantidad de palabras, «you», cualquier
cantidad, «me»—, y el reensamblado `(WHAT MAKES YOU THINK I 3 YOU)` arma la
respuesta con la tercera parte. Un número `n` distinto de cero en una
descomposición abarca exactamente `n` palabras. `doctor.pl` reconstruye ese
mecanismo con un guion propio en castellano, más chico que el original.

**El recorrido de la frase.** Weizenbaum recorre la frase una sola vez, de
izquierda a derecha. Cada palabra se sustituye según una tabla —el cambio
de persona: «mi» pasa a «tu», «estoy» a «estás»—, y cada palabra clave
entra en la **pila de claves**: arriba, si su rango supera al de la clave
que está arriba; abajo, si no. Al terminar, la clave de mayor rango está
arriba, y las reglas se escriben sobre el texto ya sustituido:

<!-- ejemplo: capitulo-56/doctor.pl predicado: explorar/3 explorar_palabra/4 -->
```prolog
%!  explorar(+Palabras:list(atom), -Texto:list, -Pila:list(atom)) is det.
%
%   Texto son las Palabras sustituidas y Pila las palabras clave de
%   Palabras, con la de mayor rango arriba.
explorar(Palabras, Texto, Pila) :-
    foldl(explorar_palabra, Palabras, Texto, [], Pila).

%!  explorar_palabra(+P:atom, -Q, +Pila0:list, -Pila:list) is det.
%
%   Q es P sustituida, y Pila es Pila0 con P arriba si P es una clave de
%   rango mayor que la de arriba, abajo si es una clave de rango menor o
%   igual, o sin cambios si P no es una clave.
explorar_palabra(P, Q, Pila0, Pila) :-
    (   sustituye(P, Q0)
    ->  Q = Q0
    ;   Q = P
    ),
    (   clave(P, Rango, _)
    ->  (   Pila0 = [Arriba|_],
            clave(Arriba, RangoArriba, _),
            Rango =< RangoArriba
        ->  append(Pila0, [P], Pila)
        ;   Pila = [P|Pila0]
        )
    ;   Pila = Pila0
    ).
```

```prolog
?- explorar([mi, padre, siempre, dice, que, eres, una, computadora], T, P).
T = ["tu", padre, siempre, dice, que, "soy", una, computadora],
P = [computadora, mi, siempre].
```

«mi» entra primero; «siempre», de rango 1, va abajo de «mi», de rango 2;
«computadora», de rango 50, va arriba. La palabra clave se reconoce por su
forma original y sus reglas miran la sustituida: la clave `mi` tiene reglas
que buscan `"tu"`.

**El guion.** Cada clave es un hecho `clave(Palabra, Rango, Reglas)`. Una
regla es `Descomposicion - Reensamblados`, o `ir_a(Clave)`, que usa las
reglas de otra clave —en DOCTOR, `(ALIKE 10 (=DIT))`: «iguales» y
«pareces» comparten las reglas de `parecido`, y también sus turnos—. En una
descomposición, `0` abarca cualquier cantidad de palabras, un entero `N`
exactamente `N`, `clase(C)` una palabra de la clase `C` —la marca `/FAMILY`
de DOCTOR— y `alguna(Ps)` una de las palabras de `Ps`. En un reensamblado,
cada número repite la parte de ese número:

<!-- ejemplo: capitulo-56/doctor.pl fragmento: clave(mi, 2, .. ["¿Por qué dices tu ", 3, "?"] ] ]). -->
```prolog
clave(mi, 2,
      [ [0, "tu", 0, clase(familia), 0]
        - [ ["Háblame más de tu familia."],
            ["¿Quién más en tu familia ", 5, "?"],
            ["Tu ", 4, "."],
            ["¿Qué más se te ocurre cuando piensas en tu ", 4, "?"] ],
        [0, "tu", 0]
        - [ ["Tu ", 3, "."],
            ["¿Por qué dices tu ", 3, "?"] ] ]).
```

<!-- ejemplo: capitulo-56/doctor.pl predicado: parte/4 -->
```prolog
%!  parte(+Elemento, +Texto:list, -Parte:list, -Resto:list) is nondet.
%
%   Parte es el comienzo de Texto que corresponde a Elemento, y Resto lo
%   que queda.
parte(0, Texto, Parte, Resto) :-
    !,
    append(Parte, Resto, Texto).
parte(N, Texto, Parte, Resto) :-
    integer(N),
    !,
    length(Parte, N),
    append(Parte, Resto, Texto).
parte(clase(C), [P|Resto], [P], Resto) :-
    !,
    etiqueta(P, C).
parte(alguna(Ps), [P|Resto], [P], Resto) :-
    !,
    memberchk(P, Ps).
parte(P, [P|Resto], [P], Resto).
```

```prolog
?- descomponer([0, "tu", 0, clase(familia), 0], ["tu", madre, "te", cuida], Ps).
Ps = [[], ["tu"], [], [madre], ["te", cuida]].
```

`descomponer/3` toma el primer reparto que encuentra, con las partes `0`
lo más cortas posible. `transformar/6` prueba las descomposiciones de la
clave en orden y, con la primera que coincide, toma el reensamblado al que
le toca el turno en esa regla. Dos reensamblados especiales cambian el
camino: `ir_a(Clave)` pasa a las reglas de otra clave, y `nueva_clave`
—`(NEWKEY)` en DOCTOR— abandona la clave y deja la frase a la siguiente de
la pila. La clave `porque` responde «¿Es esa la verdadera razón?» la
primera vez, y la segunda cede la frase:

<!-- ejemplo: capitulo-56/doctor.pl predicado: transformar/6 -->
```prolog
%!  transformar(+Reglas:list, +K, +Texto:list, +T0, -T, -Resultado)
%!      is semidet.
%
%   Resultado es Reensamblado-Partes, con Reensamblado el que le toca a la
%   primera regla de descomposición que coincide con Texto y Partes la
%   descomposición, o nueva_clave. ir_a(Clave) sigue con las reglas de
%   Clave. Falla si ninguna regla coincide.
transformar([Regla|Reglas], K, Texto, T0, T, Resultado) :-
    (   Regla = ir_a(K2)
    ->  clave(K2, _, Reglas2),
        transformar(Reglas2, K2, Texto, T0, T, Resultado)
    ;   Regla = Descomposicion-Reensamblados,
        descomponer(Descomposicion, Texto, Partes)
    ->  turno(K-Descomposicion, Reensamblados, T0, T1, R),
        (   R = ir_a(K2)
        ->  clave(K2, _, Reglas2),
            transformar(Reglas2, K2, Texto, T1, T, Resultado)
        ;   R == nueva_clave
        ->  T = T1,
            Resultado = nueva_clave
        ;   T = T1,
            Resultado = R-Partes
        )
    ;   transformar(Reglas, K, Texto, T0, T, Resultado)
    ).
```

**La memoria.** En DOCTOR, la clave `MY` tiene además cuatro
transformaciones de memoria: cuando es la clave principal de una frase, la
frase se reensambla con una de ellas y se guarda; cuando una frase no tiene
ninguna clave, la respuesta es el recuerdo más antiguo. Weizenbaum elige la
transformación con una función de dispersión sobre la última palabra;
`recordar_frase/5` usa el largo de esa palabra, módulo cuatro. Sin claves
ni recuerdos, responde la clave `ninguna`, el `NONE` de DOCTOR.

La conversación del artículo, en castellano, con `doctor/0`:

```text
¿Cómo estás? Cuéntame tu problema.
> Los hombres son todos iguales.
¿En qué sentido?
> Siempre nos molestan con algo.
¿Puedes pensar en un ejemplo concreto?
> Bueno, mi novio me hizo venir aquí.
Tu novio te hizo venir aquí.
> Dice que estoy deprimida la mayor parte del tiempo.
Lamento oír que estás deprimida.
> Es verdad. Soy infeliz.
¿Crees que venir aquí te ayudará a no ser infeliz?
> Necesito un poco de ayuda.
¿Qué significaría para ti conseguir un poco de ayuda?
> Quizás podría llevarme bien con mi madre.
Háblame más de tu familia.
> Mi madre me cuida.
¿Quién más en tu familia te cuida?
> Mi padre.
Tu padre.
> Te pareces a mi padre en algunas cosas.
¿Qué parecido ves?
> Bueno.
Hablemos más de por qué tu novio te hizo venir aquí.
```

«Mi madre me cuida» y «Mi padre» usan la misma descomposición, `(0 tu 0
(/familia) 0)`, y reciben sus reensamblados segundo y tercero; «Te pareces»
toma el segundo turno de `parecido`, que «iguales» ya usó; «Bueno.» no
tiene claves, y la respuesta sale de la memoria. La prueba `conversacion`
de `doctor.plt` compara las respuestas una por una.

| | Versión 3, `eliza.pl` | `doctor.pl` |
|---|---|---|
| patrón | variables de Prolog | `0`, `N`, `clase/1`, `alguna/1` y números en el reensamblado |
| elección | la regla de mayor rango que coincide | la pila de claves, en una sola pasada |
| cambio de persona | `persona//1`, con contexto | `sustituye/2`, palabra por palabra, en el recorrido |
| redirección | — | `ir_a/1` y `nueva_clave` |

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `responder/2`, `responder/4`, `reflejar/2` y las gramáticas de respuesta son `det`, `atender/4` es `semidet` porque falla con una frase que no es de la agenda, y `coincide/2` y `entender/3` son `nondet` |
    | C4 | las reglas de contexto de `persona//1` y la elección de regla cortan después de decidir, y las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C6 | ningún programa usa la base de datos dinámica: el estado de ELIZA y la agenda viajan en argumentos, y la lectura y la escritura están solo en `conversar/3`, que recibe el stream como argumento |
    | C7 | 136 pruebas en ocho archivos, y 46 más en las soluciones: los patrones con todas sus respuestas, el cambio de persona en los dos sentidos, la prioridad, los turnos y la memoria, cada forma de día y de hora, y dos conversaciones enteras leídas de una cadena |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

11. **(2)** Agregar un guion para una consulta médica (llegar, esperar,
    pasar al consultorio, ser revisado, recibir una receta, irse), con sus
    palabras que lo activan y sus oraciones, y una historia que lo use.
12. ★ **(3)** Escribir una gramática que lea una historia en castellano,
    como «Juan fue a Leones, comió una hamburguesa y se fue.», y dé la lista
    de sucesos de `entender/3`, con variables donde el texto no dice nada: el
    sujeto que falta es el de la oración anterior. Encadenar la gramática,
    `entender/3` y `contar/2` en `comprender(+Texto, -Relato)`.
13. **(2)** Agregar al guion DOCTOR, en un archivo aparte, la clave
    «recuerdo», de rango 5, que se sustituye por «recuerdas», con la regla
    `(0 recuerdas 0)` y dos reensamblados. Explicar por qué «Recuerdo mi
    barrio.» no deja un recuerdo en la memoria.

## Resumen

| | |
|---|---|
| **plantilla** | un patrón con variables de segmento y una respuesta con las mismas variables; `append/3` reparte la frase entre los segmentos |
| **cambio de persona** | pronombres, posesivos y verbos en una sola pasada; el contexto (determinante, pronombre ante verbo) lo decide una gramática, y la pasada única evita el ciclo yo–tú–yo |
| **forma escrita** | las palabras se comparan sin tildes y se devuelven con la escritura que tenían en la frase |
| **prioridad** | cada regla tiene un rango; gana la de mayor rango que coincide, y a igual rango la primera escrita |
| **turnos y memoria** | respuestas que se alternan y frases guardadas para volver sobre ellas, en un estado que viaja en argumentos |
| **bucle con el responder como argumento** | `conversar/3` con `meta_predicate`: el mismo bucle para ELIZA y para el diálogo completo |
| **agenda** | complementos en cualquier orden, días, fechas y horas; una lista de citas; respuestas redactadas con una gramática |
| **analogía** | diagramas como términos; la misma relación encuentra la operación y la aplica; la sucesión más corta primero |
| **guion DOCTOR** | claves con rango en una pila, descomposiciones con `0` y `N`, reensamblados por turnos, `ir_a/1`, `nueva_clave` y la memoria |
| **guion** | una historia emparejada en orden con un guion activado por una palabra; los papeles no nombrados toman su valor por omisión |
| `plantillas.pl`, `persona.pl`, `eliza.pl` | las plantillas, el cambio de persona y ELIZA |
| `agenda.pl`, `dialogo.pl` | la agenda y el programa terminado |
| `doctor.pl` | el guion DOCTOR de Weizenbaum |
| `analogia.pl`, `guiones.pl` | ANALOGY y los guiones; corren en SWISH |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Órdenes en castellano traducidas a operaciones con archivos y procesos | [capítulo 57](../capitulo-57-proyecto-ordenes-castellano/index.md) |
| Reglas de condición y acción sobre una base de datos | [capítulo 61](../capitulo-61-proyecto-interprete-dirigido-patrones/index.md) |
| Preguntas en castellano sobre una base de datos, traducidas a formas lógicas | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — apartado 14.3, «Artificial
  Intelligence Classics: ANALOGY, ELIZA, and McSAM». 1.ª edición (1986) en
  [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
  El capítulo toma el guion que se activa por una palabra y se empareja como una
  subsucesión, y el ejercicio que propone reescribir McSAM con estructuras; los
  programas del grupo de Roger Schank se conocen a través de esta
  reconstrucción.
- Joseph Weizenbaum, «ELIZA—a computer program for the study of natural language
  communication between man and machine», *Communications of the ACM* 9 (1),
  1966, pp. 36–45. [Edición en línea](https://doi.org/10.1145/365153.365168). Es
  la fuente que citan Covington y Sterling y Shapiro. El capítulo toma de este
  artículo, en la [sección 56.9](#569-el-guion-doctor-de-weizenbaum), el guion
  DOCTOR: la sustitución en el recorrido, la pila de claves por rango, las
  descomposiciones con `0` y `n`, los reensamblados por turnos, `=` y `NEWKEY`,
  y las transformaciones de memoria de la clave `MY`.
- Roger C. Schank y Christopher K. Riesbeck (eds.), *Inside Computer
  Understanding: Five Programs Plus Miniatures*, Lawrence Erlbaum, 1981, y Roger
  C. Schank y Robert P. Abelson, *Scripts, Plans, Goals, and Understanding*,
  Lawrence Erlbaum, 1977. Son las fuentes de SAM, McSAM y la dependencia
  conceptual que cita *The Art of Prolog*; de ellas vienen el guion como
  sucesión de sucesos con papeles y los nombres `ptrans` e `ingest` que usa la
  página [Guiones: una historia y el guion DOCTOR](#568-guiones-completar-una-historia).

El código del capítulo es propio, escrito para el curso: las reglas, los
textos en castellano y los programas son nuevos, y de las fuentes se toman
ideas, enunciados y representaciones, no código.
