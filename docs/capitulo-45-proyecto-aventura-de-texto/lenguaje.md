# Órdenes en castellano, el bucle del juego y la pantalla completa

Esta página continúa el [capítulo 45](index.md) después de la
[sección 45.4](index.md#454-version-3-guardar-y-cargar-una-partida), con las
secciones [45.5](#455-version-4-ordenes-y-respuestas-en-castellano) a
[45.7](#457-version-6-pantalla-completa): la versión 4 de la aventura,
`lenguaje.pl`, con la gramática que entiende las órdenes y la que redacta
las respuestas; la versión 5, `juego.pl`, con el bucle del juego y el menú
de inicio; y la versión 6, `aventura.pl`, con la pantalla completa. Los
archivos están en `ejemplos/capitulo-45/`, con sus pruebas, y cada uno carga
las versiones anteriores.

## 45.5 Versión 4: órdenes y respuestas en castellano

La versión 4 agrega las dos gramáticas del juego: una que entiende órdenes y
otra que redacta respuestas. El análisis tiene, como en la
[sección 22.10](../capitulo-22-gramaticas-dcg/index.md#2210-el-proyecto-un-lenguaje-de-comandos), dos etapas. `palabras/2` pasa el texto a minúsculas,
quita las tildes y separa las palabras; así «Bajar al SÓTANO.» y «bajar al
sotano» son la misma orden:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: palabras/2 -->
```prolog
%!  palabras(+Texto:string, -Palabras:list(atom)) is det.
%
%   Palabras son las palabras de Texto en minúsculas y sin tildes; los
%   signos de puntuación y los blancos las separan.
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    string_codes(Minusculas, Codigos0),
    maplist(sin_tilde, Codigos0, Codigos),
    phrase(lista_de_palabras(Palabras), Codigos).
```

```prolog
?- palabras("Abrir la PUERTA del taller.", P).
P = [abrir, la, puerta, del, taller].
```

La segunda etapa, `orden//1`, relaciona las palabras con un término de
`realizar/2`. Los verbos son datos: `forma(Verbo, Palabras)` dice de qué
maneras se dice cada uno, y agregar un sinónimo es agregar un hecho:

<!-- ejemplo: capitulo-45/lenguaje.pl fragmento: forma(tomar, [tomar]). .. forma(poner, [meter]). -->
```prolog
forma(tomar, [tomar]).
forma(tomar, [agarrar]).
forma(tomar, [sacar]).
forma(dejar, [dejar]).
forma(dejar, [soltar]).
forma(poner, [poner]).
forma(poner, [dejar]).
forma(poner, [meter]).
```

Los sustantivos tampoco están en la gramática: salen de `nombre/3`, pasados por
la misma `palabras/2`. Una cosa se nombra con su nombre completo o con su
primera palabra, «llave de bronce» o «llave», y el artículo, si lo hay, tiene
que concordar con el género:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: cosa//1 nombrada//1 -->
```prolog
%!  cosa(?X)// is nondet.
%
%   El nombre de un objeto o de una puerta, con o sin artículo; el
%   artículo concuerda con el género del nombre.
cosa(X) -->
    articulo(G),
    nombrada(X),
    { nombre(X, G, _),
      \+ sala(X, _) }.

%!  nombrada(?X)// is nondet.
%
%   El nombre completo de X, o su primera palabra si el nombre tiene más
%   de una: «llave de bronce» o «llave».
nombrada(X) -->
    { nombre(X, _, Texto),
      palabras(Texto, Ps) },
    (   Ps
    ;   { Ps = [Nucleo, _|_] },
        [Nucleo]
    ).
```

`orden//1` combina verbos y complementos, y exige el tipo de complemento que
cada verbo admite: `ir` necesita una sala, y `tomar`, una cosa que no lo sea.
Una sala sola, «biblioteca», también es una orden de ir, y el destino admite
la contracción «al» y varias preposiciones: «bajar al sótano», «entrar en
la biblioteca»:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: orden//1 -->
```prolog
%!  orden(?Orden)// is nondet.
%
%   Las palabras de Orden. Orden es un término de realizar/2 o una orden
%   del juego: ayuda, salir, guardar(Partida) o cargar(Partida).
orden(Verbo) -->
    { sin_argumentos(Verbo) },
    verbo(Verbo).
orden(ir(S)) -->
    verbo(ir),
    destino(S).
orden(ir(S)) -->
    articulo(G),
    sala(S),
    { nombre(S, G, _) }.
orden(Orden) -->
    { con_un_argumento(Verbo),
      Orden =.. [Verbo, X] },
    verbo(Verbo),
    cosa(X).
orden(poner(O, R)) -->
    verbo(poner),
    cosa(O),
    [en],
    cosa(R).
orden(Orden) -->
    { partida(Verbo),
      Orden =.. [Verbo, P] },
    verbo(Verbo),
    nombre_de_partida(P).
```

```prolog
?- phrase(orden(O), [bajar, al, sotano]).
O = ir(sotano) ;
false.

?- phrase(orden(O), [abrir, la, puerta]).
O = abrir(puerta_biblioteca) ;
O = abrir(puerta_taller) ;
false.
```

**La lectura según la situación.** «abrir la puerta» tiene dos lecturas, una
por cada puerta. `entender/2` las reúne todas y elige la primera que ningún
impedimento bloquea; si todas tienen uno, la primera. Con la llave en el
inventario, en el vestíbulo, la lectura elegida es la puerta del taller,
porque la de la biblioteca ya está abierta. Es la idea de Merritt para «turn
on the light», que el libro resuelve con una regla especial para la palabra
*light*, llevada a todas las órdenes:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: entender/2 -->
```prolog
%!  entender(+Texto:string, -Orden) is det.
%
%   Orden es la lectura de Texto que se va a ejecutar: la primera que
%   ningún impedimento bloquea, o la primera de todas si todas tienen uno.
%   Es no_entendido si Texto no es una orden.
entender(Texto, Orden) :-
    palabras(Texto, Palabras),
    findall(O, phrase(orden(O), Palabras), Os0),
    list_to_set(Os0, Os),
    (   Os == []
    ->  Orden = no_entendido
    ;   member(O, Os),
        \+ impedimento(O, _)
    ->  Orden = O
    ;   Os = [Orden|_]
    ).
```

**Las respuestas.** `respuesta//1` genera el texto de cada respuesta. Es una
gramática que construye una lista de códigos, como las de la
[sección 35.5](../capitulo-35-estructuras-incompletas-y-listas-diferencia/index.md#355-las-gramaticas-como-listas-diferencia): cada parte de la frase agrega su tramo al final sin
`append/3`. Las respuestas se dirigen al jugador en segunda persona, con
«tú»: «Estás en…», «Tomas…», «No puedes…». Tres no terminales resuelven lo que el castellano exige: `el//1`
y `un//1` eligen el artículo por el género, `al//1` escribe «al» o «a la», y
`terminacion//1` da la «o» o la «a» de un adjetivo. Una enumeración separa
con comas y pone «y» antes del último elemento:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: enumeracion//2 resto_de_enumeracion//2 el//1 -->
```prolog
%!  enumeracion(:Nombrar, +Xs:list)// is det.
%
%   Los elementos de Xs, cada uno nombrado por el no terminal Nombrar,
%   separados por comas y con y antes del último. Xs no es vacía.
enumeracion(Nombrar, [X|Xs]) -->
    call(Nombrar, X),
    resto_de_enumeracion(Xs, Nombrar).

%!  resto_de_enumeracion(+Xs:list, :Nombrar)// is det.
%
%   Los elementos de Xs, cada uno precedido por una coma, o por y si es
%   el último.
resto_de_enumeracion([], _) -->
    [].
resto_de_enumeracion([X|Xs], Nombrar) -->
    (   { Xs == [] }
    ->  " y "
    ;   ", "
    ),
    call(Nombrar, X),
    resto_de_enumeracion(Xs, Nombrar).

%!  el(+X)// is det.
%
%   El nombre de X con el artículo definido.
el(X) -->
    { nombre(X, G, Texto) },
    (   { G == m }
    ->  "el "
    ;   "la "
    ),
    texto(Texto).
```

Cada respuesta es una cláusula corta, por ejemplo
`motivo(ya_abierto(X)) --> el(X), " ya está abiert", terminacion(X), ".".`,
que da «La trampilla ya está abierta.» y «El baúl ya está abierto.»:

```prolog
?- phrase(respuesta(contenido(baul, [lente, linterna, llave])), Cs), string_codes(S, Cs).
Cs = [101, 110, 32, 101, 108, 32, 98, 97, 250|...],
S = "en el baúl ves una lente, una linterna y una llave de bronce.".
```

`oracion//1` pone la mayúscula inicial, y `ejecutar/2` une las dos
gramáticas: entiende el texto, ejecuta la orden con `realizar/2` —o con
`guardar/1` y `cargar/1`, que la versión 4 atiende con un archivo
`Nombre.partida`— y redacta las respuestas:

<!-- ejemplo: capitulo-45/lenguaje.pl predicado: ejecutar/2 -->
```prolog
%!  ejecutar(+Texto:string, -Salida:string) is det.
%
%   Entiende la orden Texto, la ejecuta y da el texto de la respuesta.
ejecutar(Texto, Salida) :-
    entender(Texto, Orden),
    responder(Orden, Salida).
```

```prolog
?- iniciar, ejecutar("ir al taller", S).
S = "La puerta del taller está cerrada.".
```

La orden que gana la partida agrega a su respuesta el texto de `final/1`, un
hecho del mundo.

!!! question "Actividad"
    Predecir qué orden elige `entender/2` para «abrir la puerta» en el
    vestíbulo al empezar la partida, y después de tomar la llave; y para
    «dejar la lente» y «dejar la lente en el telescopio». Comprobarlo con
    `findall/3` sobre `phrase(orden(O), Palabras)` y con `entender/2`.

**Lo que falta.** Cada orden es una consulta en el intérprete de Prolog. Un
juego necesita un bucle que lea una orden tras otra hasta que la partida
termine.

## 45.6 Versión 5: el bucle del juego y el menú de inicio

`partida/1` lee una línea, la entiende, escribe la respuesta y sigue, hasta que
la orden es `salir`, la partida está ganada o la entrada se termina. El
stream de entrada es un argumento: `jugar/0` le pasa el teclado, y las pruebas,
un stream sobre una cadena abierto con `open_string/2`, como en la
[sección 37.2](../capitulo-37-interfaces-de-usuario/index.md#372-pantalla-completa-en-la-terminal):

<!-- ejemplo: capitulo-45/juego.pl predicado: partida/1 -->
```prolog
%!  partida(+In) is det.
%
%   Lee órdenes de In, una por línea, y escribe sus respuestas, hasta que
%   la orden es salir, la partida está ganada o In se termina.
partida(In) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   entender(Linea, Orden)
    ),
    responder(Orden, Texto),
    format("~w~n", [Texto]),
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   partida(In)
    ).
```

El bucle es recursivo, y la llamada recursiva es la última: la pila no crece
con la cantidad de órdenes. Merritt escribe su primer bucle con `repeat/0` y
una falla al final ([Patrón 7](../patrones.md#7-bucle-por-falla)); aquí la recursión no cambia nada, porque
el estado está en la base de datos, pero deja abierta la posibilidad de pasar
algo de una orden a la siguiente, como pide el ejercicio 12.

El menú de inicio es el de Covington: `menu/3` recibe una lista de
`opcion(Texto, Valor)`, las muestra numeradas y lee el número de una. Si la
respuesta no es un número de la lista, lo dice y vuelve a preguntar; si la
entrada se termina, elige la última opción, que es salir:

<!-- ejemplo: capitulo-45/juego.pl predicado: menu/3 -->
```prolog
%!  menu(+In, +Opciones:list, -Valor) is det.
%
%   Muestra Opciones, una lista de opcion(Texto, Valor) numeradas desde 1,
%   y lee de In el número de una. Valor es el de la opción elegida; si la
%   respuesta no es un número de la lista, vuelve a preguntar. Si In se
%   termina, Valor es el de la última opción.
menu(In, Opciones, Valor) :-
    forall(nth1(I, Opciones, opcion(Texto, _)),
           format("~d. ~w~n", [I, Texto])),
    length(Opciones, Cantidad),
    format("Elige una opción, de 1 a ~d: ", [Cantidad]),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   normalize_space(atom(Respuesta), Linea),
        atom_number(Respuesta, N),
        integer(N),
        nth1(N, Opciones, opcion(_, V))
    ->  Valor = V
    ;   format("La respuesta no es una de las opciones.~n"),
        menu(In, Opciones, Valor)
    ).
```

Covington lee una sola tecla y la compara con los códigos de los dígitos; aquí
se lee una línea, porque el resto del juego también lee líneas y porque así el
menú se prueba con la misma cadena que la partida. `jugar/1` une las dos
cosas: el menú, `preparar/2` para la partida nueva o la guardada, y
`partida/1`. Una prueba de `juego.plt` juega con la entrada `"1\nsalir\n"` y
compara las líneas escritas con las esperadas.

**Lo que falta.** Las respuestas se escriben una debajo de otra y se desplazan:
para saber dónde se está o qué se lleva hay que volver a preguntarlo.

## 45.7 Versión 6: pantalla completa

La versión 6 aplica el [Patrón 51](../patrones.md#51-modelo-de-pantalla) con el módulo `pantalla` del
[capítulo 37](../capitulo-37-interfaces-de-usuario/index.md), que carga con `use_module('../capitulo-37/texto/pantalla')`.
El modelo, `pantalla/2`, da las líneas de tres recuadros: el lugar y el
inventario, redactados por la gramática de respuestas, y los últimos mensajes.
No escribe nada, y por eso la prueba `pantalla_inicial` lo compara línea por
línea con la pantalla esperada:

<!-- ejemplo: capitulo-45/aventura.pl predicado: pantalla/2 -->
```prolog
%!  pantalla(+Mensajes:list(string), -Lineas:list(string)) is det.
%
%   Lineas es la pantalla: el lugar y el inventario, con los textos de
%   mirar e inventario, y Mensajes, cada uno en su recuadro.
pantalla(Mensajes, Lineas) :-
    ancho(Ancho),
    responder(mirar, Lugar),
    partir(Lugar, Ancho, Lineas1),
    responder(inventario, Inventario),
    partir(Inventario, Ancho, Lineas2),
    maplist(recuadro(Ancho),
            ["Lugar", "Inventario", "Mensajes"],
            [Lineas1, Lineas2, Mensajes],
            Cajas),
    append(Cajas, Lineas).
```

`responder(mirar, …)` ejecuta una orden, pero `mirar` e `inventario` no tienen
impedimentos ni cambian el estado: el modelo solo consulta. `partir/3` reparte
las palabras de un texto en líneas de sesenta columnas, y `recuadro/4`
completa cada línea con blancos para que los tres recuadros tengan el mismo
ancho.

A diferencia del Buscaminas del [capítulo 37](../capitulo-37-interfaces-de-usuario/index.md), que responde a cada tecla,
aquí las órdenes se escriben enteras y se terminan con Enter: el bucle dibuja,
lleva el cursor a la fila de abajo de los recuadros, escribe `> ` y lee una
línea. Los mensajes son la única información que pasa de una vuelta a la
siguiente, y viajan en un argumento; `agregar_mensajes/4` agrega el eco de la
orden y la respuesta partida en líneas, y conserva las ocho últimas:

<!-- ejemplo: capitulo-45/aventura.pl predicado: bucle/2 -->
```prolog
%!  bucle(+In, +Mensajes:list(string)) is det.
%
%   Dibuja la pantalla con Mensajes, lee una orden de In, la ejecuta y
%   sigue, hasta que la orden es salir, la partida está ganada o In se
%   termina.
bucle(In, Mensajes0) :-
    pantalla(Mensajes0, Lineas),
    dibujar(Lineas),
    length(Lineas, N),
    Fila is N + 1,
    ir_a(Fila, 1),
    format("> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir,
        Eco = "salir"
    ;   entender(Linea, Orden),
        Eco = Linea
    ),
    responder(Orden, Texto),
    agregar_mensajes(Mensajes0, Eco, Texto, Mensajes),
    (   (   Orden == salir
        ;   ganado
        )
    ->  pantalla(Mensajes, Final),
        dibujar(Final),
        nl
    ;   bucle(In, Mensajes)
    ).
```

Las pruebas de `aventura.plt` hacen correr el bucle con las dieciséis órdenes
de la partida en una cadena, capturan lo que escribe con `with_output_to/2`,
separan las pantallas por la secuencia de borrado `\e[2J` y buscan en la
última la orden ganadora y su respuesta. Lo que la terminal muestra al
recibir esas secuencias no lo verifica ninguna prueba; como en el
[capítulo 37](../capitulo-37-interfaces-de-usuario/index.md), en Windows las secuencias de posición del cursor no se dan por
verificadas.

El capítulo continúa en la página
[Más elementos de Colossal Cave](colossal-cave.md#458-el-puntaje-y-los-turnos),
con cuatro elementos de los juegos fuente que las seis versiones no tienen:
el puntaje, los personajes que se mueven solos, el laberinto y los menús de
una tecla.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden el programa: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

4. ★ **(1)** Predecir el texto que responde `ejecutar/2`, desde una partida
   nueva, a cada orden de esta secuencia, y comprobarlo: «tomar el
   perchero» · «ir al sótano» · «biblioteca» · «abrir el escritorio» ·
   «mirar en el escritorio» · «subir a la cúpula» · «poner el catálogo en el
   telescopio».
5. ★ **(2)** Agregar al mundo un jardín, al que se sale desde el vestíbulo
   por una puerta de vidrio cerrada que no necesita llave, con una regadera
   que se puede llevar. Escribir solo hechos, en un archivo aparte, con
   cláusulas `mundo:…`, y comprobar con `ejecutar/2` que el jardín se
   recorre y la regadera se toma sin cambiar ningún predicado.
6. **(1)** Agregar los sinónimos «recoger» y «levantar» para tomar, y
   «terminar» para salir, en un archivo aparte. ¿Por qué no hace falta
   tocar `orden//1`?
7. **(2)** Hacer que «sacar la lente del baúl» se entienda: una orden de
   tomar puede nombrar, después del objeto, el recipiente de donde sale, con
   «de» o «del». La orden se entiende solo si el objeto está en ese
   recipiente.
8. ★ **(2)** Órdenes compuestas: «tomar la llave y abrir la puerta del
   taller» ejecuta las dos órdenes, en ese orden, y responde con las dos
   respuestas. Si una orden de la secuencia está bloqueada, las siguientes
   no se ejecutan.
9. **(2)** Limitar la partida a una cantidad de órdenes: escribir
   `partida_con_limite(+In, +Maximo)`, un bucle como `partida/1` que lleva
   la cuenta en un argumento y, al llegar a `Maximo` sin ganar, termina con
   el texto «Se terminó el tiempo.».
10. ★ **(2)** Escribir la orden «tomar todo», que toma, en una sola orden,
    cada objeto al alcance que se puede llevar y no está en el inventario, y
    responde con una oración por objeto; si no hay ninguno, responde «No hay
    nada para tomar.».
11. **(2)** Escribir `menu_por_inicial(+In, +Opciones, -Valor)`, un menú en
    el que se elige escribiendo la inicial de la opción, como propone el
    ejercicio 5.5.3 de Covington. ¿Qué hace si dos opciones empiezan con la
    misma letra?
12. **(3)** Agregar la orden «deshacer», que vuelve al estado anterior a la
    última orden que lo cambió. Escribir un bucle
    `partida_con_deshacer(+In)` que lleva en un argumento la pila de
    instantáneas.

## Referencias

- Dennis Merritt, *Adventure in Prolog*, Springer-Verlag, 1990 — «Control
  Structures» y «Natural Language».
  [Edición en línea](https://www.amzi.com/AdventureInProlog/), de Amzi!.
  Esta página toma de allí el bucle de órdenes y la interfaz en lenguaje
  natural con verbos tipados, sinónimos, sustantivos de varias palabras y
  lectura según la situación.
- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — apartados 2.13 y 5.5, «Constructing menus».
  [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf).
  Esta página toma el menú generado a partir de una lista de opciones, que
  vuelve a preguntar ante una respuesta inválida, y el ejercicio sobre la
  elección por inicial.
