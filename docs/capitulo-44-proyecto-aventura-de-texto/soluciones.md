# Soluciones del capítulo 44 — Proyecto: una aventura de texto

El código de esta página está en `ejemplos/capitulo-44/`:
`soluciones_mundo.pl` para los ejercicios 2 y 3, un archivo de hechos que
agrega cláusulas a los módulos del capítulo; `soluciones.pl` para los
ejercicios 4, 5, 6, 7, 9, 11 y 12, un módulo que carga la versión 5; y
`soluciones_puro.pl` para el 10. Cada uno tiene sus pruebas y ninguno
modifica los archivos del capítulo. Los ejercicios 1 y 8 se resuelven con
los archivos del capítulo. Todos son `% solo-local`, como el capítulo.

## 1

Con `lenguaje.pl` cargado:

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: ejecutar/2 -->
```prolog
%!  ejecutar(+Texto:string, -Salida:string) is det.
%
%   Entiende la orden Texto, la ejecuta y da el texto de la respuesta.
ejecutar(Texto, Salida) :-
    entender(Texto, Orden),
    responder(Orden, Salida).
```

```prolog
?- iniciar, maplist(ejecutar, ["tomar el perchero", "ir al sótano", "biblioteca", "abrir el escritorio", "mirar en el escritorio", "subir a la cúpula", "poner el catálogo en el telescopio"], Ss).
Ss = ["No puedes llevarte el perchero.", "Desde aquí no puedes ir al sótano.", "Estás en la biblioteca. Estantes hasta el techo, casi todos vacíos. Ves un catálogo de estrellas y un escritorio. Desde aquí puedes ir a la cúpula y al vestíbulo.", "El escritorio ya está abierto.", "En el escritorio ves una llave de bronce.", "Estás en la cúpula. La cúpula de metal está abierta hacia el cielo. Ves un telescopio. Desde aquí puedes ir a la biblioteca.", "No llevas el catálogo de estrellas."].
```

Cada respuesta sale de la primera cláusula de `impedimento/2` que se cumple,
o del efecto si ninguna se cumple:

- el perchero es `fijo/1`: el impedimento `fijo`;
- el sótano no se conecta con el vestíbulo: `no_hay_paso`, antes de mirar
  si está oscuro, porque la orden no llega a ejecutarse;
- «biblioteca» es una sala sola, que `orden//1` lee como `ir(biblioteca)`;
- el escritorio es un recipiente, pero no está en `cerrada/1`: el impedimento
  `ya_abierto`. Para abrirse, una cosa tiene que ser una puerta o un
  recipiente, y estar cerrada;
- el escritorio está abierto, así que `examinar/1` muestra su contenido;
- la escalera une la biblioteca con la cúpula y no está cerrada;
- el catálogo se nombra con su primera palabra, «catálogo», y el impedimento
  es `no_lo_tiene`: `poner/2` necesita llevar el objeto antes de mirar el
  recipiente.

## 2

Solo hechos, calificados con el módulo al que pertenecen. Como los
predicados de datos de `mundo.pl` son `multifile`, las cláusulas se agregan a
las del capítulo en lugar de reemplazarlas:

<!-- ejemplo: capitulo-44/soluciones_mundo.pl fragmento: % Ejercicio 2 .. mundo:inicio(esta_en(regadera, jardin)). -->
```prolog
% Ejercicio 2

mundo:nombre(jardin, m, "jardín").
mundo:nombre(puerta_vidrio, f, "puerta de vidrio").
mundo:nombre(regadera, f, "regadera").

mundo:sala(jardin, "Un jardín descuidado, con canteros secos.").

mundo:puerta(puerta_vidrio, vestibulo, jardin).

mundo:inicio(cerrada(puerta_vidrio)).
mundo:inicio(esta_en(regadera, jardin)).
```

```prolog
?- iniciar, ejecutar("abrir la puerta", S1), ejecutar("ir al jardín", S2).
S1 = "Abres la puerta de vidrio.",
S2 = "Estás en el jardín. Un jardín descuidado, con canteros secos. Ves una regadera. Desde aquí puedes ir al vestíbulo.".
```

Ningún predicado cambió. `conecta/3` encuentra la puerta nueva, la gramática
reconoce «jardín», «puerta de vidrio» y «regadera» porque salen de
`nombre/3`, y la vista del vestíbulo agrega la salida «al jardín», con la
contracción que da el género. «abrir la puerta» tiene ahora tres lecturas en
el vestíbulo; `entender/2` elige la de vidrio, la única que ningún
impedimento bloquea al empezar. La prueba `datos_coherentes` de
`soluciones_mundo.plt` repite las verificaciones de `mundo.plt` con los
hechos agregados.

## 3

<!-- ejemplo: capitulo-44/soluciones_mundo.pl fragmento: % Ejercicio 3 .. lenguaje:forma(salir, [terminar]). -->
```prolog
% Ejercicio 3

lenguaje:forma(tomar, [recoger]).
lenguaje:forma(tomar, [levantar]).
lenguaje:forma(salir, [terminar]).
```

`orden//1` no nombra ningún verbo: pide a `verbo//1` una de las formas de
`forma/2`, y `forma/2` es `multifile`. Un sinónimo es un dato más, como un
objeto nuevo es un nombre más.

## 4

<!-- ejemplo: capitulo-44/soluciones.pl predicado: entender_con_origen/2 tomar_de//1 origen//1 -->
```prolog
%!  entender_con_origen(+Texto:string, -Orden) is det.
%
%   Como entender/2, pero una orden de tomar puede nombrar el recipiente
%   de donde sale el objeto: «sacar la lente del baúl». Esa lectura exige
%   que el objeto esté en el recipiente.
entender_con_origen(Texto, Orden) :-
    palabras(Texto, Palabras),
    (   phrase(tomar_de(O), Palabras)
    ->  Orden = tomar(O)
    ;   entender(Texto, Orden)
    ).

%!  tomar_de(?O)// is nondet.
%
%   Una orden de tomar O seguida del recipiente que lo contiene.
tomar_de(O) -->
    lenguaje:verbo(tomar),
    lenguaje:cosa(O),
    origen(R),
    { esta_en(O, R) }.

%!  origen(?R)// is nondet.
%
%   El recipiente R precedido de de o del.
origen(R) -->
    [del],
    lenguaje:nombrada(R),
    { nombre(R, m, _) }.
origen(R) -->
    [de],
    lenguaje:cosa(R).
```

La lectura con origen se prueba antes que las demás, porque tiene más
palabras que cualquier orden de `orden//1`; si no se aplica, la orden se
entiende como antes. La condición `esta_en(O, R)` va en la gramática, así que
una frase que nombra otro recipiente no tiene lectura:

```prolog
?- iniciar, restablecer([aqui(sotano), esta_en(linterna, jugador), encendido(linterna), esta_en(baul, sotano), esta_en(lente, baul)]), entender_con_origen("sacar la lente del baúl", O1), entender_con_origen("sacar la lente del escritorio", O2).
O1 = tomar(lente),
O2 = no_entendido.
```

Los no terminales `verbo//1`, `cosa//1` y `nombrada//1` no se exportan; la
solución los usa calificados con el módulo, `lenguaje:cosa(O)`. «del» va
seguido del nombre sin artículo y exige un nombre masculino; «de», de una
cosa con su artículo: «de la caja».

## 5

<!-- ejemplo: capitulo-44/soluciones.pl predicado: ejecutar_varias/2 segmentos/2 respuestas_en_orden/2 -->
```prolog
%!  ejecutar_varias(+Texto:string, -Salida:string) is det.
%
%   Ejecuta las órdenes de Texto separadas por y, en orden, hasta la
%   primera que no se entiende o que un impedimento bloquea; Salida son
%   las respuestas de las que se intentaron.
ejecutar_varias(Texto, Salida) :-
    palabras(Texto, Palabras),
    segmentos(Palabras, Segmentos),
    maplist(texto_de_palabras, Segmentos, Textos),
    respuestas_en_orden(Textos, Respuestas),
    atomic_list_concat(Respuestas, ' ', Atomo),
    atom_string(Atomo, Salida).

%!  segmentos(+Palabras:list, -Segmentos:list(list)) is det.
%
%   Segmentos son los tramos de Palabras separados por la palabra y.
segmentos(Palabras, [Segmento|Segmentos]) :-
    (   append(Segmento, [y|Resto], Palabras)
    ->  segmentos(Resto, Segmentos)
    ;   Segmento = Palabras,
        Segmentos = []
    ).

%!  respuestas_en_orden(+Textos:list(string), -Respuestas:list(string))
%!      is det.
%
%   Ejecuta las órdenes Textos hasta la primera bloqueada, incluida.
respuestas_en_orden([], []).
respuestas_en_orden([T|Ts], [R|Rs]) :-
    entender(T, Orden),
    (   (   Orden == no_entendido
        ;   impedimento(Orden, _)
        )
    ->  responder(Orden, R),
        Rs = []
    ;   responder(Orden, R),
        respuestas_en_orden(Ts, Rs)
    ).
```

`segmentos/2` corta la lista de palabras en cada «y» con `append/3`, y cada
tramo se vuelve a unir en un texto para `entender/2`, que elige su lectura en
el estado que dejó la orden anterior. El impedimento se consulta antes de
ejecutar: después, el estado ya cambió.

```prolog
?- iniciar, ejecutar_varias("biblioteca y tomar la llave y subir al sótano y mirar", S).
S = "Estás en la biblioteca. Estantes hasta el techo, casi todos vacíos. Ves un catálogo de estrellas y un escritorio. Desde aquí puedes ir a la cúpula y al vestíbulo. Tomas la llave de bronce. Desde aquí no puedes ir al sótano.".
```

La tercera orden está bloqueada: su respuesta aparece, y «mirar» no se
ejecuta. Ninguna palabra de los nombres del mundo es «y»; si lo fuera, el
corte tendría que hacerse con la gramática, probando cada «y» como separador.

## 6

<!-- ejemplo: capitulo-44/soluciones.pl predicado: partida_con_limite/2 partida_con_limite/3 -->
```prolog
%!  partida_con_limite(+In, +Maximo:integer) is det.
%
%   Como partida/1, pero termina con «Se terminó el tiempo.» después de
%   Maximo órdenes sin ganar.
partida_con_limite(In, Maximo) :-
    partida_con_limite(In, Maximo, 0).

%!  partida_con_limite(+In, +Maximo:integer, +Hechas:integer) is det.
%
%   Sigue la partida cuando ya se ejecutaron Hechas órdenes.
partida_con_limite(In, Maximo, Hechas) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   entender(Linea, Orden)
    ),
    responder(Orden, Texto),
    format("~w~n", [Texto]),
    Hechas1 is Hechas + 1,
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   Hechas1 >= Maximo
    ->  format("Se terminó el tiempo.~n")
    ;   partida_con_limite(In, Maximo, Hechas1)
    ).
```

La cuenta viaja en un argumento, como los mensajes de la versión 6: es
información del bucle, no del mundo, y no hace falta guardarla en la base.
La condición de victoria se mira antes que el límite, así que la orden que
gana cuenta como ganada aunque sea la última permitida.

## 7

<!-- ejemplo: capitulo-44/soluciones.pl predicado: ejecutar_con_todo/2 tomar_todo/1 tomable/1 -->
```prolog
%!  ejecutar_con_todo(+Texto:string, -Salida:string) is det.
%
%   Como ejecutar/2, y además entiende «tomar todo» con cualquier forma
%   del verbo tomar.
ejecutar_con_todo(Texto, Salida) :-
    palabras(Texto, Palabras),
    (   append(Verbo, [todo], Palabras),
        lenguaje:forma(tomar, Verbo)
    ->  tomar_todo(Salida)
    ;   ejecutar(Texto, Salida)
    ).

%!  tomar_todo(-Salida:string) is det.
%
%   Toma cada objeto que se puede tomar; Salida son las respuestas.
tomar_todo(Salida) :-
    findall(O, tomable(O), Os0),
    sort(Os0, Os),
    (   Os == []
    ->  Salida = "No hay nada para tomar."
    ;   maplist([O, T]>>responder(tomar(O), T), Os, Textos),
        atomic_list_concat(Textos, ' ', Atomo),
        atom_string(Atomo, Salida)
    ).

%!  tomable(?O) is nondet.
%
%   O es un objeto al alcance que se puede llevar y no está en el
%   inventario.
tomable(O) :-
    al_alcance(O),
    objeto(O),
    \+ fijo(O),
    \+ esta_en(O, jugador).
```

`tomable/1` reúne lo que se puede llevar, incluido lo que está dentro de un
recipiente abierto; cada objeto pasa después por `responder/2`, es decir, por
`realizar/2`, que vuelve a verificar los impedimentos. Por eso, a oscuras, la
respuesta es una oración «Está demasiado oscuro para eso.» por cada objeto
tomable. El `sort/2` quita las repeticiones, que aparecen cuando un objeto
tiene más de una demostración de `al_alcance/1`, y fija el orden de las
respuestas. «todo» se reconoce antes de la gramática, detrás de cualquier
forma de tomar: «agarrar todo» también vale.

## 8

```prolog
%!  al_alcance(?X) is nondet.
%!  al_alcance(+X) is semidet.
```

Con `X` instanciado hay a lo sumo una demostración, si el estado cumple dos
condiciones que el programa mantiene. Si `X` es una puerta, solo la primera
cláusula se aplica, porque ninguna puerta aparece en `esta_en/2`, y
`conecta(X, S, _)` se cumple una vez: la puerta está en un solo hecho
`puerta/3`, que une dos salas distintas. Si `X` es un objeto, la segunda
cláusula encuentra su único `esta_en(X, L)`, y `accesible(L)` tiene una
cláusula por tipo de lugar: el inventario, una sala o un recipiente, que
vuelve a llamar a `al_alcance/1` con el recipiente, un nivel más arriba en la
contención. Las dos condiciones son que cada objeto esté en un solo lugar y
que ningún objeto esté, directa o indirectamente, dentro de sí mismo:
`trasladar/2` las conserva, pero `restablecer/1` no las verifica, y un archivo
de partida con `esta_en(llave, jugador)` y `esta_en(llave, cupula)` daría dos
demostraciones. La determinación es la lógica, no la del intérprete: la
consulta con `X` instanciado deja una alternativa pendiente, porque
`conecta/3` tiene dos cláusulas.

## 9

<!-- ejemplo: capitulo-44/soluciones.pl predicado: guardar_con_formato/1 cargar_con_formato/1 -->
```prolog
%!  guardar_con_formato(+Archivo) is det.
%
%   Como guardar/1, con el hecho formato(aventura, 1) en la primera línea.
guardar_con_formato(Archivo) :-
    instantanea(Hechos),
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(H, [formato(aventura, 1)|Hechos]),
               portray_clause(Out, H)),
        close(Out)).

%!  cargar_con_formato(+Archivo) is det.
%
%   Como cargar/1, pero produce un error de dominio, sin cambiar el
%   estado, si Archivo no empieza con formato(aventura, 1).
cargar_con_formato(Archivo) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        partidas:leer_terminos(In, Terminos),
        close(In)),
    (   Terminos = [formato(aventura, 1)|Hechos]
    ->  restablecer(Hechos)
    ;   domain_error(partida_con_formato_1, Archivo)
    ).
```

El formato es el primer término del archivo, leído como los demás; un
archivo de la versión 3, que empieza con `aqui/1`, produce el error de
dominio sin llegar a `restablecer/1`. `leer_terminos/2` no se exporta desde
`partidas`, y la solución la llama calificada. Con el número de formato,
una versión futura del programa puede reconocer los archivos de las
anteriores y convertirlos en lugar de rechazarlos.

## 10

<!-- ejemplo: capitulo-44/soluciones_puro.pl predicado: paso/4 -->
```prolog
%!  paso(+Orden, +Estado0:list, -Estado:list, -Respuesta) is det.
%
%   Estado y Respuesta son el estado y la respuesta después de Orden, que
%   es mirar, ir(S), tomar(O) o dejar(O).
paso(Orden, Estado0, Estado, Respuesta) :-
    (   impedimento_en(Estado0, Orden, Motivo)
    ->  Estado = Estado0,
        Respuesta = no_puede(Motivo)
    ;   efecto_en(Orden, Estado0, Estado, Respuesta)
    ).
```

<!-- ejemplo: capitulo-44/soluciones_puro.pl predicado: impedimento_en/3 efecto_en/4 reemplazar/4 -->
```prolog
%!  impedimento_en(+E:list, +Orden, -Motivo) is nondet.
%
%   Motivo impide ejecutar Orden en el estado E.
impedimento_en(E, ir(S), ya_esta(S)) :-
    memberchk(aqui(S), E).
impedimento_en(E, ir(S), no_hay_paso(S)) :-
    memberchk(aqui(A), E),
    \+ conecta(_, A, S).
impedimento_en(E, ir(S), cerrado(P)) :-
    memberchk(aqui(A), E),
    conecta(P, A, S),
    memberchk(cerrada(P), E).
impedimento_en(E, tomar(_), oscuro) :-
    a_oscuras_en(E).
impedimento_en(E, dejar(O), no_lo_tiene(O)) :-
    \+ memberchk(esta_en(O, jugador), E).
impedimento_en(E, tomar(O), no_esta(O)) :-
    \+ al_alcance_en(E, O).
impedimento_en(E, tomar(O), ya_lo_tiene(O)) :-
    memberchk(esta_en(O, jugador), E).
impedimento_en(_, tomar(O), fijo(O)) :-
    (   fijo(O)
    ->  true
    ;   \+ objeto(O)
    ).

%!  efecto_en(+Orden, +E0:list, -E:list, -Respuesta) is det.
%
%   Aplica Orden, que ningún impedimento bloquea, al estado E0.
efecto_en(mirar, E, E, Respuesta) :-
    vista_en(E, Respuesta).
efecto_en(ir(S), E0, E, Respuesta) :-
    reemplazar(aqui(_), aqui(S), E0, E),
    vista_en(E, Respuesta).
efecto_en(tomar(O), E0, E, tomado(O)) :-
    reemplazar(esta_en(O, _), esta_en(O, jugador), E0, E).
efecto_en(dejar(O), E0, E, dejado(O, S)) :-
    memberchk(aqui(S), E0),
    reemplazar(esta_en(O, _), esta_en(O, S), E0, E).

%!  reemplazar(+Viejo, +Nuevo, +E0:list, -E:list) is det.
%
%   E es E0, ordenado, con el primer hecho que unifica con Viejo
%   reemplazado por Nuevo.
reemplazar(Viejo, Nuevo, E0, E) :-
    selectchk(Viejo, E0, E1),
    sort([Nuevo|E1], E).
```

Cada consulta a la base, `aqui(S)` o `esta_en(O, L)`, pasa a ser una
búsqueda en la lista, `memberchk(aqui(S), E)`; cada cambio, un reemplazo que
produce una lista nueva. `al_alcance_en/2`, `accesible_en/2`,
`a_oscuras_en/1` y `vista_en/2`, en el mismo archivo, repiten los de
`estado.pl` con el estado como primer argumento. La prueba `recorrido` de
`soluciones_puro.plt` aplica catorce órdenes, con impedimentos de todos los
tipos, con `pasos/4` y con `realizar/2`, y compara las respuestas y el estado
final con `instantanea/1`; otras dos pruebas hacen lo mismo en el sótano, con
la linterna apagada y encendida, y la última verifica que `paso/4` no toca la
base.

La versión en argumentos no necesita `iniciar/0` ni `restablecer/1`, las
pruebas no preparan ni restauran nada, y dos partidas pueden avanzar a la
vez. A cambio, cada predicado lleva el estado, y cada consulta recorre una
lista en lugar de usar la indexación de la base: con muchos objetos, la
búsqueda con `memberchk/2` es lineal. Merritt advierte, además, que la pila
crece con cada orden si el bucle no es recursivo por la cola.

## 11

<!-- ejemplo: capitulo-44/soluciones.pl predicado: menu_por_inicial/3 elegir_por_inicial/4 inicial/2 -->
```prolog
%!  menu_por_inicial(+In, +Opciones:list, -Valor) is det.
%
%   Como menu/3, pero se elige escribiendo la inicial de la opción.
%   Produce un error de dominio si dos opciones empiezan con la misma
%   letra: una de las dos no se podría elegir.
menu_por_inicial(In, Opciones, Valor) :-
    maplist(inicial, Opciones, Iniciales),
    (   sort(Iniciales, Distintas),
        same_length(Iniciales, Distintas)
    ->  elegir_por_inicial(In, Opciones, Iniciales, Valor)
    ;   domain_error(iniciales_distintas, Opciones)
    ).

%!  elegir_por_inicial(+In, +Opciones:list, +Iniciales:list, -Valor) is det.
%
%   Muestra Opciones y lee iniciales de In hasta que una es de ellas.
elegir_por_inicial(In, Opciones, Iniciales, Valor) :-
    forall(member(opcion(Texto, _), Opciones),
           format("~w~n", [Texto])),
    format("Elige una opción por su inicial: "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   normalize_space(string(Respuesta), Linea),
        inicial(opcion(Respuesta, _), I),
        nth1(N, Iniciales, I)
    ->  nth1(N, Opciones, opcion(_, Valor))
    ;   format("La respuesta no es una de las iniciales.~n"),
        elegir_por_inicial(In, Opciones, Iniciales, Valor)
    ).

%!  inicial(+Opcion, -I:atom) is semidet.
%
%   I es la primera letra del texto de Opcion, en minúscula. Falla si el
%   texto está vacío.
inicial(opcion(Texto, _), I) :-
    sub_atom(Texto, 0, 1, _, Letra),
    downcase_atom(Letra, I).
```

Si dos opciones empiezan con la misma letra, la segunda no se puede elegir
nunca. La solución lo detecta al empezar: `sort/2` quita las iniciales
repetidas, y `same_length/2`, de `library(lists)`, tiene éxito si dos
listas tienen la misma longitud. Si las longitudes difieren, la solución
produce un error de dominio en lugar de mostrar un menú que no funciona; otra
salida es marcar en cada
texto la letra que lo elige, como hacen muchos programas con «&Guardar». Las
opciones de inicio del capítulo, «Partida nueva», «Continuar la partida
guardada» y «Salir», tienen iniciales distintas.

## 12

<!-- ejemplo: capitulo-44/soluciones.pl predicado: partida_con_deshacer/2 turno/4 -->
```prolog
%!  partida_con_deshacer(+In, +Pila:list) is det.
%
%   Sigue la partida con Pila, las instantáneas anteriores a cada orden
%   que cambió el estado, la más reciente primero.
partida_con_deshacer(In, Pila0) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   palabras(Linea, [deshacer])
    ->  Orden = deshacer
    ;   entender(Linea, Orden)
    ),
    turno(Orden, Pila0, Pila, Texto),
    format("~w~n", [Texto]),
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   partida_con_deshacer(In, Pila)
    ).

%!  turno(+Orden, +Pila0:list, -Pila:list, -Texto:string) is det.
%
%   Ejecuta Orden y da su texto; Pila es Pila0 con la instantánea anterior
%   si Orden cambió el estado, o sin la última si Orden es deshacer.
turno(Orden, Pila0, Pila, Texto) :-
    (   Orden == deshacer
    ->  (   Pila0 = [Anterior|Pila]
        ->  restablecer(Anterior),
            responder(mirar, Vista),
            string_concat("Orden deshecha. ", Vista, Texto)
        ;   Pila = [],
            Texto = "No hay nada para deshacer."
        )
    ;   instantanea(Antes),
        responder(Orden, Texto),
        instantanea(Despues),
        (   Antes == Despues
        ->  Pila = Pila0
        ;   Pila = [Antes|Pila0]
        )
    ).
```

La pila guarda la instantánea anterior a cada orden que cambió el estado:
una orden bloqueada, `mirar` o `inventario` no agregan nada, y «deshacer»
vuelve a la última orden que sí lo cambió. Comparar las instantáneas antes y
después evita tener que saber qué órdenes cambian el estado. La pila está en
un argumento del bucle y no en la base, porque deshacer no es parte del
mundo: guardar la partida no guarda la historia, y después de cargarla la
pila sigue siendo la del bucle.
