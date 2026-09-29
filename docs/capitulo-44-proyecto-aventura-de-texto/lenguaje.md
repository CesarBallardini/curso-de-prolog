# Órdenes y respuestas en castellano

Esta página contiene la sección [44.5](index.md#445-version-4-ordenes-y-respuestas-en-castellano)
del [capítulo 44](index.md): la versión 4 de la aventura, `lenguaje.pl`, con
la gramática que entiende las órdenes y la que redacta las respuestas. El
archivo está en `ejemplos/capitulo-44/`, con sus pruebas, y carga las
versiones anteriores.

## Órdenes y respuestas en castellano

La versión 4 agrega las dos gramáticas del juego: una que entiende órdenes y
otra que redacta respuestas. El análisis tiene, como en la
[sección 21.10](../capitulo-21-gramaticas-dcg/index.md#2110-el-proyecto-un-lenguaje-de-comandos), dos etapas. `palabras/2` pasa el texto a minúsculas,
quita las tildes y separa las palabras; así «Bajar al SÓTANO.» y «bajar al
sotano» son la misma orden:

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: palabras/2 -->
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

<!-- ejemplo: capitulo-44/lenguaje.pl fragmento: forma(tomar, [tomar]). .. forma(poner, [meter]). -->
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

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: cosa//1 nombrada//1 -->
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

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: orden//1 -->
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

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: entender/2 -->
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
[sección 34.5](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#345-las-gramaticas-como-listas-diferencia): cada parte de la frase agrega su tramo al final sin
`append/3`. Las respuestas se dirigen al jugador en segunda persona, con
«tú»: «Estás en…», «Tomas…», «No puedes…». Tres no terminales resuelven lo que el castellano exige: `el//1`
y `un//1` eligen el artículo por el género, `al//1` escribe «al» o «a la», y
`terminacion//1` da la «o» o la «a» de un adjetivo. Una enumeración separa
con comas y pone «y» antes del último elemento:

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: enumeracion//2 resto_de_enumeracion//2 el//1 -->
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
