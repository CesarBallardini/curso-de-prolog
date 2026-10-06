# Soluciones del capítulo 83 — Proyecto: procesamiento de textos

El código de esta página está en `ejemplos/capitulo-83/soluciones.pl`,
con sus pruebas en `soluciones.plt`. El archivo carga `cribar.pl`, la
versión 1 del filtro; `paso/7` y `final/1` de `cribar_seguro.pl`; y
`curvas_programa.pl`, que carga `curvas.pl` y `cicloide.pl`; ninguno se
modifica. Como `cribar/4` es el nombre de las dos versiones del filtro,
la versión 2 se llama con el módulo delante, `cribar_seguro:cribar/4`. Es
`% solo-local`, porque carga otros archivos.

## 1

La versión 1 nunca falla ni avisa: copia una marca de fin sin inicio
como una línea más, y una marca de inicio sin fin se lleva lo que sigue.
La versión 2 convierte esos dos casos en errores. Las dos coinciden en
las secciones vacías, que son correctas, y en la sangría: `" INICIO"` no
empieza con `"INICIO"`, así que no es una marca, y entonces la línea
`"FIN"` es una marca de fin sin inicio.

```prolog
?- cribar(["FIN", "a"], "INICIO", "FIN", Q).
Q = ["FIN", "a"].

?- catch(cribar_seguro:cribar(["FIN", "a"], "INICIO", "FIN", Q), error(E, _), true).
E = marcas(fin_sin_inicio(1)).

?- catch(cribar_seguro:cribar(["a", "INICIO"], "INICIO", "FIN", Q), error(E, _), true).
E = marcas(inicio_sin_fin(2)).

?- cribar(["INICIO", "FIN", "INICIO", "FIN"], "INICIO", "FIN", Q).
Q = [].

?- catch(cribar_seguro:cribar([" INICIO", "a", "FIN"], "INICIO", "FIN", Q), error(E, _), true).
E = marcas(fin_sin_inicio(3)).
```

La versión 1 responde `["a"]` con `["a", "INICIO"]`, y
`[" INICIO", "a", "FIN"]` con la lista completa, sin cambios.

## 2

<!-- ejemplo: capitulo-83/soluciones.pl predicado: conservar/4 -->
```prolog
%!  conservar(+Lineas:list(string), +Inicio:string, +Fin:string,
%!            -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas que están dentro de las secciones, sin
%   las marcas. Lanza los errores de paso/7 y final/1.
conservar(Lineas, Inicio, Fin, Quedan) :-
    conservar(Lineas, 1, copiando, Inicio, Fin, Quedan).
```

`paso/7` dice en qué estado queda el recorrido después de cada línea. Una
línea está dentro de una sección exactamente cuando el recorrido está
salteando antes y después de leerla: la marca de inicio pasa de copiando
a salteando, la de fin de salteando a copiando, y las líneas de afuera
quedan en copiando. Lo que el paso escribe no hace falta; el estado
basta.

<!-- ejemplo: capitulo-83/soluciones.pl predicado: conservar/6 -->
```prolog
%!  conservar(+Lineas:list(string), +N:integer, +Estado, +Inicio:string,
%!            +Fin:string, -Quedan:list(string)) is det.
%
%   Como conservar/4, con la primera línea numerada N y el recorrido en
%   Estado. Una línea queda si el recorrido está salteando antes y después
%   de su paso: las marcas cambian el estado, y las líneas de afuera no
%   están salteando.
conservar([], _, Estado, _, _, []) :-
    final(Estado).
conservar([Linea|Lineas], N, Estado, Inicio, Fin, Quedan) :-
    paso(Estado, N, Linea, Inicio, Fin, Estado1, _),
    (   Estado = salteando(_),
        Estado1 = salteando(_)
    ->  Quedan = [Linea|Resto]
    ;   Quedan = Resto
    ),
    N1 is N + 1,
    conservar(Lineas, N1, Estado1, Inicio, Fin, Resto).
```

```prolog
?- conservar(["a", "INICIO", "b", "FIN", "c", "INICIO", "d", "e", "FIN"], "INICIO", "FIN", Q).
Q = ["b", "d", "e"].
```

Como usa `paso/7` y `final/1`, las marcas mal puestas siguen siendo
errores. Las pruebas verifican que `conservar/4` y `cribar/4` de la
versión 2 se reparten las líneas: las que una conserva y las que la otra
deja suman todas, menos las marcas.

## 3

No hace falta otro paso: `paso/7` decide sobre la línea sin la sangría, y
el recorrido escribe la línea original cuando el paso escribe algo.

<!-- ejemplo: capitulo-83/soluciones.pl predicado: cribar_sangria/4 cribar_sangria/6 sin_sangria/2 sin_blancos/2 -->
```prolog
%!  cribar_sangria(+Lineas:list(string), +Inicio:string, +Fin:string,
%!                 -Quedan:list(string)) is det.
%
%   Como cribar/4 de la versión 2, con las marcas reconocidas también
%   después de espacios y tabulaciones. Las líneas que quedan no cambian.
cribar_sangria(Lineas, Inicio, Fin, Quedan) :-
    cribar_sangria(Lineas, 1, copiando, Inicio, Fin, Quedan).

%!  cribar_sangria(+Lineas:list(string), +N:integer, +Estado,
%!                 +Inicio:string, +Fin:string,
%!                 -Quedan:list(string)) is det.
%
%   Como cribar_sangria/4, desde la línea N en Estado. El paso decide sobre
%   la línea sin la sangría, y se escribe la línea original.
cribar_sangria([], _, Estado, _, _, []) :-
    final(Estado).
cribar_sangria([Linea|Lineas], N, Estado, Inicio, Fin, Quedan) :-
    sin_sangria(Linea, Recortada),
    paso(Estado, N, Recortada, Inicio, Fin, Estado1, Salida),
    (   Salida == []
    ->  Quedan = Resto
    ;   Quedan = [Linea|Resto]
    ),
    N1 is N + 1,
    cribar_sangria(Lineas, N1, Estado1, Inicio, Fin, Resto).

%!  sin_sangria(+Linea:string, -Recortada:string) is det.
%
%   Recortada es Linea sin los espacios y las tabulaciones del principio.
sin_sangria(Linea, Recortada) :-
    string_codes(Linea, Codigos),
    sin_blancos(Codigos, Resto),
    string_codes(Recortada, Resto).

%!  sin_blancos(+Codigos:list, -Resto:list) is det.
%
%   Resto es Codigos sin los espacios y las tabulaciones del principio.
sin_blancos([C|Cs], Resto) :-
    memberchk(C, [0' , 0'\t]),
    !,
    sin_blancos(Cs, Resto).
sin_blancos(Codigos, Codigos).
```

```prolog
?- cribar_sangria(["a", "  INICIO", "b", "\tFIN", "  c"], "INICIO", "FIN", Q).
Q = ["a", "  c"].
```

`split_string/4` con la cadena vacía como separador quitaría los blancos
de los dos extremos; `sin_blancos/2` quita solo los del principio, que
son los que impiden reconocer la marca. La línea recortada solo se usa
para decidir: lo que se escribe es la línea original, con su sangría.

## 4

Una sección termina en el paso que va de `salteando(N0)` a `copiando`, y
el estado anterior ya tiene la línea de inicio:

<!-- ejemplo: capitulo-83/soluciones.pl predicado: secciones/4 secciones/6 -->
```prolog
%!  secciones(+Lineas:list(string), +Inicio:string, +Fin:string,
%!            -Rangos:list(pair)) is det.
%
%   Rangos son los pares Desde-Hasta, las líneas de la marca de inicio y de
%   la de fin de cada sección de Lineas, en orden. Lanza los errores de
%   paso/7 y final/1.
secciones(Lineas, Inicio, Fin, Rangos) :-
    secciones(Lineas, 1, copiando, Inicio, Fin, Rangos).

%!  secciones(+Lineas:list(string), +N:integer, +Estado, +Inicio:string,
%!            +Fin:string, -Rangos:list(pair)) is det.
%
%   Como secciones/4, desde la línea N en Estado. Una sección termina en
%   el paso que va de salteando(N0) a copiando.
secciones([], _, Estado, _, _, []) :-
    final(Estado).
secciones([Linea|Lineas], N, Estado, Inicio, Fin, Rangos) :-
    paso(Estado, N, Linea, Inicio, Fin, Estado1, _),
    (   Estado = salteando(N0),
        Estado1 == copiando
    ->  Rangos = [N0-N|Resto]
    ;   Rangos = Resto
    ),
    N1 is N + 1,
    secciones(Lineas, N1, Estado1, Inicio, Fin, Resto).
```

```prolog
?- secciones(["a", "INICIO", "b", "FIN", "c", "INICIO", "d", "e", "FIN"], "INICIO", "FIN", R).
R = [2-4, 6-9].
```

En `examen_soluciones.tex`, `secciones_archivo/4`, que lee el archivo y
lo divide en líneas, encuentra las dos soluciones, en las líneas 9 a 13
y 15 a 17. Un programa podría escribirlas en la salida de errores, como
un informe de lo que quitó.

## 5

El estado salteando recuerda ahora la marca de fin de la sección abierta,
porque cada par tiene la suya:

<!-- ejemplo: capitulo-83/soluciones.pl predicado: cribar_pares/3 cribar_pares/5 paso_par/6 final_par/1 -->
```prolog
%!  cribar_pares(+Lineas:list(string), +Pares:list(pair),
%!               -Quedan:list(string)) is det.
%
%   Quedan son las líneas de Lineas fuera de las secciones de cualquiera de
%   los pares Inicio-Fin de Pares. Lanza los errores de la versión 2:
%   error(marcas(Problema), _), con los mismos problemas.
cribar_pares(Lineas, Pares, Quedan) :-
    cribar_pares(Lineas, 1, copiando, Pares, Quedan).

%!  cribar_pares(+Lineas:list(string), +N:integer, +Estado,
%!               +Pares:list(pair), -Quedan:list(string)) is det.
%
%   Como cribar_pares/3, desde la línea N en Estado: copiando, o
%   salteando(Fin, N0), con Fin la marca que cierra la sección abierta en
%   la línea N0.
cribar_pares([], _, Estado, _, []) :-
    final_par(Estado).
cribar_pares([Linea|Lineas], N, Estado, Pares, Quedan) :-
    paso_par(Estado, N, Linea, Pares, Estado1, Salida),
    append(Salida, Resto, Quedan),
    N1 is N + 1,
    cribar_pares(Lineas, N1, Estado1, Pares, Resto).

%!  paso_par(+Estado, +N:integer, +Linea:string, +Pares:list(pair),
%!           -Estado1, -Salida:list(string)) is det.
%
%   El paso de cribar_pares/5: como paso/7, con la marca de fin de la
%   sección abierta en el estado. Dentro de una sección, la marca de fin
%   de otro par es una marca de fin sin su inicio.
paso_par(copiando, N, Linea, Pares, Estado1, Salida) :-
    (   member(Inicio-Fin, Pares),
        string_concat(Inicio, _, Linea)
    ->  Estado1 = salteando(Fin, N),
        Salida = []
    ;   member(_-Fin, Pares),
        string_concat(Fin, _, Linea)
    ->  throw(error(marcas(fin_sin_inicio(N)), _))
    ;   Estado1 = copiando,
        Salida = [Linea]
    ).
paso_par(salteando(Fin, N0), N, Linea, Pares, Estado1, []) :-
    (   string_concat(Fin, _, Linea)
    ->  Estado1 = copiando
    ;   member(Inicio-_, Pares),
        string_concat(Inicio, _, Linea)
    ->  throw(error(marcas(inicio_anidado(N, N0)), _))
    ;   member(_-Otro, Pares),
        string_concat(Otro, _, Linea)
    ->  throw(error(marcas(fin_sin_inicio(N)), _))
    ;   Estado1 = salteando(Fin, N0)
    ).

%!  final_par(+Estado) is det.
%
%   El texto puede terminar en Estado; si no, lanza el error de final/1.
final_par(copiando).
final_par(salteando(_, N0)) :-
    final(salteando(N0)).
```

```prolog
?- cribar_pares(["a", "SOL", "b", "/SOL", "c", "NOTA", "d", "/NOTA", "e"], ["SOL"-"/SOL", "NOTA"-"/NOTA"], Q).
Q = ["a", "c", "e"].

?- catch(cribar_pares(["a", "SOL", "/NOTA", "/SOL"], ["SOL"-"/SOL", "NOTA"-"/NOTA"], Q), error(E, _), true).
E = marcas(fin_sin_inicio(3)).
```

Dentro de una sección de `SOL`, la marca `/NOTA` es un error: una marca
de fin cuyo inicio no está abierto. Los errores tienen la misma forma que
los de la versión 2, así que los mensajes de `cribar_seguro.pl` los
escriben sin definir nada. Con un solo par, `cribar_pares/3` responde lo
mismo que `cribar/4` de la versión 2, y una prueba lo verifica.

## 6

`decimal//1` multiplica por 10 000, redondea al entero más cercano y
divide: `2.00005` da `2.0001`, `-0.00004` da `0.0000` (sin signo, porque
el redondeo da el entero 0), `1.0e10` da `10000000000.0000`, sin
notación exponencial, y el entero `12` da `12.0000`.

El primero merece una explicación. `2.00005` no tiene representación
exacta en binario, y el número guardado es un poco menor; `format/2` con
`~4f` lo redondea hacia abajo. Pero el producto por 10 000 se redondea a
su vez, y da exactamente 20000.5, que `round/1` lleva al entero mayor:

```prolog
?- X is 2.00005 * 10000.
X = 20000.5.

?- format("~4f ~4f~n", [2.00005, 20001/10000]).
2.0000 2.0001
true.
```

La diferencia está en la cuarta cifra decimal y solo en los casos de
empate, mucho menos que lo que se ve en un dibujo; lo que importa en el
programa es que el texto no dependa del signo de un error de redondeo.

## 7

<!-- ejemplo: capitulo-83/soluciones.pl fragmento: :- multifile curvas:punto/3. .. Y is sin(B * T). -->
```prolog
:- multifile curvas:punto/3.

% La curva de Lissajous: x = sin(A t + Delta), y = sin(B t).
curvas:punto(lissajous(A, B, Delta), T, X-Y) :-
    X is sin(A * T + Delta),
    Y is sin(B * T).
```

La declaración `multifile` se repite en el archivo que agrega la
cláusula, como en el [Patrón 79](../patrones.md#79-clausulas-para-un-modulo-cargado),
y la cabeza lleva el módulo delante. `curva/1` la reconoce, porque
examina las cláusulas de `punto/3` sin importar de qué archivo vienen:

```prolog
?- curva(lissajous(3, 2, 0.5)).
true.
```

## 8

La hipocicloide es otra cláusula de `punto/3`, en el mismo archivo:

<!-- ejemplo: capitulo-83/soluciones.pl fragmento: % La hipocicloide de un disco .. Y is (R - Rd) * sin(T) - D * sin(K * T). -->
```prolog
% La hipocicloide de un disco de radio Rd que rueda por dentro de una
% circunferencia de radio R, con el punto a distancia D de su centro.
curvas:punto(hipocicloide(R, Rd, D), T, X-Y) :-
    K is (R - Rd) / Rd,
    X is (R - Rd) * cos(T) + D * cos(K * T),
    Y is (R - Rd) * sin(T) - D * sin(K * T).
```

Con $R = 5$ y $r = 3$, el ángulo del disco avanza $\frac{2}{3}$ de lo que
avanza el centro, y la curva se cierra cuando los dos completan vueltas
enteras: tres vueltas del centro, $6\pi$. El archivo de especificaciones
es `archivos/hipocicloides.curvas`:

```prolog
% Hipocicloides: un disco de radio 3 rueda por dentro de una
% circunferencia de radio 5; tres vueltas alrededor cierran la curva.
% El punto en el borde del disco.
curva(borde, hipocicloide(5, 3, 3), 0, 6*pi, 180).
% El punto dentro del disco.
curva(adentro, hipocicloide(5, 3, 1), 0, 6*pi, 180).
% El punto fuera del disco.
curva(afuera, hipocicloide(5, 3, 5), 0, 6*pi, 180).
```

`swipl curvas_programa.pl` no lo acepta: ese programa no carga
`soluciones.pl`, y `hipocicloide/3` no es una curva que conozca. El
dibujo lo escribe `dibujar/2`, desde el toplevel con `soluciones.pl`
cargado, con `curvas/3` del programa:

<!-- ejemplo: capitulo-83/soluciones.pl predicado: dibujar/2 -->
```prolog
%!  dibujar(+Entrada, +Salida) is det.
%
%   Escribe en Salida el dibujo SVG de las especificaciones de Entrada,
%   con las clases de curva de este archivo; los dos nombres son relativos
%   al directorio de este programa.
dibujar(Entrada, Salida) :-
    source_file(user:dibujar(_, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, Entrada, RutaEntrada),
    directory_file_path(Directorio, Salida, RutaSalida),
    curvas(RutaEntrada, svg, Texto),
    setup_call_cleanup(open(RutaSalida, write, Out, [encoding(utf8)]),
                       write(Out, Texto),
                       close(Out)).
```

![Tres hipocicloides superpuestas con simetría de orden cinco: la del punto en el borde, en azul, una estrella de cinco puntas; la del punto adentro, en rojo, cinco lazos alrededor del centro; y la del punto afuera, en verde, una estrella de puntas redondeadas más grande](hipocicloides.svg)

Las hipocicloides de $R = 5$ y $r = 3$ con el punto en el borde del disco
(azul), adentro (rojo) y afuera (verde). Dibujo generado por `dibujar/2`;
una prueba de `soluciones.plt` verifica que el archivo es su salida.

## 9

La verificación examina en orden el término, el nombre, la curva, los
extremos y la cantidad de intervalos, y se detiene en el primer problema:

```text
ERROR: línea 1: el nombre c1 no es un átomo de letras
ERROR: línea 1: circulo(0,0,_116) no es una curva conocida
ERROR: línea 1: la cantidad de intervalos 8.0 no es un entero positivo
ERROR: línea 1: recta no es una curva conocida
```

Cada línea es la salida de un archivo que contiene solo esa
especificación. En la segunda, `R` es una variable de la especificación:
`curva/1` exige parámetros numéricos, y el mensaje la escribe con el
nombre interno que le dio `read_term/3`, un `_` seguido de un número que
cambia de una ejecución a otra. En la cuarta, `recta` es un átomo, no un
término compuesto, y no es una clase de curva. La tercera muestra que
`8.0` no es un entero, aunque tenga valor entero.

## 10

`datos//2` lleva un indicador de si ya hubo una curva, para escribir la
línea vacía antes de cada curva menos la primera:

<!-- ejemplo: capitulo-83/soluciones.pl predicado: datos/2 datos//2 dato//3 lineas_xy//1 -->
```prolog
%!  datos(+Partes:list, -Texto:string) is det.
%
%   Texto es Partes en el formato de datos de los programas de gráficos:
%   una línea X Y por punto, una línea vacía entre dos curvas, y cada
%   comentario en una línea que empieza con #.
datos(Partes, Texto) :-
    phrase(datos(Partes, primera), Codigos),
    string_codes(Texto, Codigos).

%!  datos(+Partes:list, +Antes)// is det.
%
%   Las líneas de Partes; Antes es primera hasta la primera curva, y
%   despues desde ella, para separar cada curva de la anterior.
datos([], _) -->
    [].
datos([Parte|Partes], Antes) -->
    dato(Parte, Antes, Despues),
    datos(Partes, Despues).

%!  dato(+Parte, +Antes, -Despues)// is det.
%
%   Las líneas de una parte.
dato(comentario(Texto), Antes, Antes) -->
    { string_codes(Texto, Codigos) },
    "# ", codigos(Codigos), "\n".
dato(curva(_, Puntos), Antes, despues) -->
    (   { Antes == despues }
    ->  "\n"
    ;   []
    ),
    lineas_xy(Puntos).

%!  lineas_xy(+Puntos:list(pair))// is det.
%
%   Una línea X Y por punto, con cuatro decimales.
lineas_xy([]) -->
    [].
lineas_xy([X-Y|Ps]) -->
    decimal(X), " ", decimal(Y), "\n",
    lineas_xy(Ps).
```

```prolog
?- datos([comentario("dos curvas"), curva(a, [0-1, 2-3]), curva(b, [1.5-(-1)])], T), write(T).
# dos curvas
0.0000 1.0000
2.0000 3.0000

1.5000 -1.0000
T = "# dos curvas\n0.0000 1.0000\n2.0000 3.0000\n\n1.5000 -1.0000\n".
```

Es un cuarto formato con las mismas partes que `documento/3`, escrito
fuera de `curvas.pl`: `decimal//1` y `codigos//1`, exportados por
`cicloide.pl`, son todo lo que necesita del programa. Con el formato
dentro de `documento//2`, bastaría una regla más y la opción `-t datos`.
