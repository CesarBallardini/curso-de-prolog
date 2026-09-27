# Soluciones del capítulo 28 — Programas de línea de comandos

El código de esta página está en `ejemplos/capitulo-28/`: `soluciones.pl`,
`soluciones_contar.pl`, `eco.pl`, `soluciones_proyecto.pl` y
`soluciones_buscaminas.pl`, con sus archivos de pruebas, y pasa sus pruebas.
Las pruebas de los programas los ejecutan en otro proceso, con sus argumentos,
y verifican la salida y el código de salida.

## 1

<!-- ejemplo: capitulo-28/soluciones_contar.pl predicado: columnas/3 contar_texto/4 consulta: contar_texto("uno dos\ntrés\n", Lineas, Palabras, Caracteres). -->
```prolog
%!  columnas(+Opciones:list, +Cuentas, -Numeros:list(integer)) is det.
%
%   Numeros son las cantidades de Cuentas, Lineas-Palabras-Caracteres, que
%   piden Opciones, o las tres si no piden ninguna.
columnas(Opciones, Lineas-Palabras-Caracteres, Numeros) :-
    (   option(lineas(true), Opciones)
    ->  Numeros = [Lineas]
    ;   option(palabras(true), Opciones)
    ->  Numeros = [Palabras]
    ;   option(caracteres(true), Opciones)
    ->  Numeros = [Caracteres]
    ;   Numeros = [Lineas, Palabras, Caracteres]
    ).

%!  contar_texto(+Texto:string, -Lineas:integer, -Palabras:integer,
%!               -Caracteres:integer) is det.
%
%   Como contar_texto/3 de contar.pl, y Caracteres es la cantidad de
%   caracteres de Texto: una letra con tilde cuenta una vez.
contar_texto(Texto, Lineas, Palabras, Caracteres) :-
    aggregate_all(count, sub_string(Texto, _, _, _, "\n"), Lineas),
    split_string(Texto, " \t\r\n", " \t\r\n", Partes),
    exclude(==(""), Partes, Todas),
    length(Todas, Palabras),
    string_length(Texto, Caracteres).
```

`soluciones_contar.pl` es `contar.pl` con tres cambios: dos declaraciones
`opt_type/3`, `caracteres` y `c`, con su `opt_help/2`; una tercera cantidad en
`contar_texto/4`; y una tercera columna en `columnas/3`. `main/1` no cambia.

```text
$ swipl soluciones_contar.pl -c archivos/texto.txt
      34  archivos/texto.txt
```

`string_length/2` cuenta caracteres, no bytes: `"trés"` tiene cuatro
caracteres, aunque la `é` ocupe dos bytes en UTF-8.

## 2

```text
$ swipl contar.pl --lineas=3 archivos/texto.txt
ERROR: Option --lineas=3 requires an argument of type boolean (found 3)
$ echo $?
1
$ swipl contar.pl -l archivos/texto.txt no.txt
       4  archivos/texto.txt
ERROR: source_sink `'no.txt'' does not exist
$ echo $?
2
```

El primer error lo detecta `argv_options/3`, antes de llegar a `main/1`: una
opción `boolean` no lleva valor. El segundo llega a `main/1`: el primer
archivo se cuenta y se escribe, y el error del segundo se captura, se escribe
como mensaje y da el código 2. `maplist/2` se detiene en el error, y un tercer
archivo no se contaría.

## 3

<!-- ejemplo: capitulo-28/eco.pl predicado: main/1 invertir/2 consulta: invertir([uno, dos, tres], L). -->
```prolog
%!  main(+Argumentos:list) is det.
%
%   Escribe Argumentos en orden inverso y termina con el código 0; sin
%   argumentos, termina con el código 1.
main(Argumentos) :-
    (   Argumentos == []
    ->  print_message(error, eco(sin_argumentos)),
        Codigo = 1
    ;   invertir(Argumentos, Inversos),
        forall(member(A, Inversos), writeln(A)),
        Codigo = 0
    ),
    halt(Codigo).

%!  invertir(+Lista:list, -Inversa:list) is det.
%
%   Inversa es Lista en orden inverso.
invertir(Lista, Inversa) :-
    reverse(Lista, Inversa).
```

```text
$ swipl eco.pl uno dos tres
tres
dos
uno
$ swipl eco.pl
ERROR: Uso: swipl eco.pl argumento...
$ echo $?
1
```

Un solo `halt/1`, al final: las dos ramas eligen el código, y `main/1`
termina en un solo lugar.

## 4

<!-- ejemplo: capitulo-28/soluciones.pl predicado: preguntar_opcion/4 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  preguntar_opcion(+In, +Pregunta:string, +Opciones:list, -Elegida) is det.
%
%   Escribe Pregunta y las Opciones numeradas desde 1, y lee de In el número
%   de una; Elegida es esa opción.
preguntar_opcion(In, Pregunta, Opciones, Elegida) :-
    format("~w~n", [Pregunta]),
    forall(nth1(N, Opciones, Opcion),
           format("  ~d. ~w~n", [N, Opcion])),
    length(Opciones, Cantidad),
    preguntar_numero(In, "Opción", 1, Cantidad, N),
    nth1(N, Opciones, Elegida).
```

```text
¿Materia?
  1. logica
  2. algebra
Opción (1 a 2) 3
Se espera un entero entre 1 y 2.
Opción (1 a 2) 2
```

La validación es la de `preguntar_numero/5`, con el rango que da la cantidad
de opciones: la solución solo agrega la lista numerada.

## 5

<!-- ejemplo: capitulo-28/soluciones.pl predicado: identificar/2 probar/2 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  identificar(+In, -Animal) is det.
%
%   Animal es la primera hipótesis que se prueba preguntando a la persona,
%   por In, los datos que ninguna regla concluye; desconocido si no se
%   prueba ninguna. Cada dato se pregunta una sola vez.
identificar(In, Animal) :-
    retractall(respondido(_, _)),
    (   hipotesis(H),
        probar(In, H)
    ->  Animal = H
    ;   Animal = desconocido
    ).

%!  probar(+In, +Meta) is nondet.
%
%   Meta se prueba con las reglas, o con la respuesta de la persona si
%   ninguna regla la concluye.
probar(In, A y B) :-
    !,
    probar(In, A),
    probar(In, B).
probar(_, Meta) :-
    respondido(Meta, Respuesta),
    !,
    Respuesta == si.
probar(In, Meta) :-
    regla(_, si _ entonces Meta),
    !,
    regla(_, si Condiciones entonces Meta),
    probar(In, Condiciones).
probar(In, Meta) :-
    atomic_list_concat(Palabras, '_', Meta),
    atomic_list_concat(Palabras, ' ', Texto),
    format(string(Pregunta), "¿~w?", [Texto]),
    preguntar_si_no(In, Pregunta, Respuesta),
    assertz(respondido(Meta, Respuesta)),
    Respuesta == si.
```

Una sesión que identifica un tigre:

```text
¿tiene pelo? (s/n) s
¿come carne? (s/n) s
¿color leonado? (s/n) s
¿manchas oscuras? (s/n) n
¿da leche? (s/n) n
¿rayas negras? (s/n) s
```

Las reglas son las del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md); lo nuevo es la última cláusula de
`probar/2`: un dato que ninguna regla concluye se pregunta, y la respuesta se
guarda con `assertz/1` para no preguntarlo otra vez. La tercera cláusula
decide entre las dos: si alguna regla concluye la meta, no se pregunta.

La pregunta por la leche aparece aunque `tiene_pelo` ya permitió concluir
`mamifero`: al fallar `manchas_oscuras`, el backtracking busca otra forma de
probar `mamifero`, con la regla r2. La respuesta sigue siendo
correcta; evitar la pregunta exige recordar también las conclusiones
probadas, no solo los datos respondidos.

## 6

<!-- ejemplo: capitulo-28/soluciones.pl predicado: primera_linea_de/3 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  primera_linea_de(+Programa:atom, +Argumentos:list, -Linea:string) is det.
%
%   Linea es la primera línea que escribe Programa con Argumentos.
primera_linea_de(Programa, Argumentos, Linea) :-
    salida_de(Programa, Argumentos, Salida, _),
    split_string(Salida, "\n", "\r", [Linea|_]).
```

`primera_linea_de(swipl, ['--version'], L)` da `"SWI-Prolog version 9.2.9
for x64-win64"` en la máquina del curso; la plataforma cambia en Linux.

## 7

<!-- ejemplo: capitulo-28/soluciones.pl predicado: codigo_de/3 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  codigo_de(+Archivo, +Argumentos:list, -Codigo:integer) is det.
%
%   Codigo es el código de salida de swipl Archivo Argumentos. La salida
%   del programa se descarta.
codigo_de(Archivo, Argumentos, Codigo) :-
    process_create(path(swipl), [Archivo|Argumentos],
                   [stdout(null), stderr(null), process(Pid)]),
    process_wait(Pid, exit(Codigo)).
```

```prolog
test(eco_sin_argumentos, true(C == 1)) :-
    eco(Eco),
    codigo_de(Eco, [], C).
```

`stdout(null)` y `stderr(null)` descartan lo que el programa escribe: la
prueba solo mira el código. `eco/1`, en `soluciones.plt`, arma la ruta de
`eco.pl` a partir del directorio de `soluciones.pl`, para que la prueba no
dependa del directorio desde el que se ejecuta.

## 8

<!-- ejemplo: capitulo-28/soluciones.pl predicado: edad_en/3 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  edad_en(+Nacimiento, +Fecha, -Edad:integer) is det.
%
%   Edad son los años cumplidos en Fecha por una persona nacida en
%   Nacimiento; las dos son términos date/3.
edad_en(date(A1, M1, D1), date(A2, M2, D2), Edad) :-
    Anios is A2 - A1,
    (   M2-D2 @< M1-D1
    ->  Edad is Anios - 1
    ;   Edad = Anios
    ).
```

```prolog
?- edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad).
Edad = 20.
```

La edad es la diferencia de años, menos uno si en la segunda fecha todavía no
llegó el cumpleaños. Los pares `Mes-Dia` se comparan con el orden estándar de
la [sección 22.2](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#222-el-orden-estandar): primero el mes, después el día. La cuenta no
necesita timestamps.

## 9

<!-- ejemplo: capitulo-28/soluciones.pl predicado: proximo_habil/2 consulta: edad_en(date(2005, 10, 3), date(2026, 9, 25), Edad). -->
```prolog
%!  proximo_habil(+Fecha, -Habil) is det.
%
%   Habil es el primer día después de Fecha que no es sábado ni domingo.
proximo_habil(Fecha, Habil) :-
    sumar_dias(Fecha, 1, Siguiente),
    day_of_the_week(Siguiente, N),
    (   N =< 5
    ->  Habil = Siguiente
    ;   proximo_habil(Siguiente, Habil)
    ).
```

```prolog
?- proximo_habil(date(2026, 9, 25), H).
H = date(2026, 9, 28).
```

El 25 de septiembre de 2026 es viernes: el sábado y el domingo se saltean.
`day_of_the_week/2` numera los días desde el lunes, 1, hasta el domingo, 7.

## 10

<!-- ejemplo: capitulo-28/soluciones.pl predicado: fecha_corta/2 consulta: fecha_corta(date(2026, 9, 25), Texto). -->
```prolog
%!  fecha_corta(+Fecha, -Texto:string) is det.
%
%   Texto es Fecha como "vie 25/09": las tres primeras letras del día, y el
%   día y el mes con dos cifras.
fecha_corta(date(Anio, Mes, Dia), Texto) :-
    dia_de_la_semana(date(Anio, Mes, Dia), Nombre),
    sub_atom(Nombre, 0, 3, _, Corto),
    format(string(Texto), "~w ~|~`0t~d~2+/~|~`0t~d~2+", [Corto, Dia, Mes]).
```

```prolog
?- fecha_corta(date(2026, 9, 25), Texto).
Texto = "vie 25/09".
```

`~|~`0t~d~2+` escribe un número en dos columnas, rellenando con ceros a la
izquierda: `~|` marca dónde empieza la columna, y `` ~`0t `` pide el relleno
con `0` en lugar de espacios.

## 11

<!-- ejemplo: capitulo-28/soluciones.pl predicado: directorio_de_datos/2 consulta: fecha_corta(date(2026, 9, 25), Texto). -->
```prolog
%!  directorio_de_datos(+Programa:atom, -Directorio:atom) is det.
%
%   Directorio es donde Programa guarda sus datos: dentro de %APPDATA% en
%   Windows, dentro de ~/.local/share en los demás sistemas. La ruta de
%   Windows se convierte a la forma de Prolog, con /.
directorio_de_datos(Programa, Directorio) :-
    (   current_prolog_flag(windows, true)
    ->  getenv('APPDATA', RutaDelSistema),
        prolog_to_os_filename(Base, RutaDelSistema)
    ;   getenv('HOME', Casa),
        directory_file_path(Casa, '.local/share', Base)
    ),
    directory_file_path(Base, Programa, Directorio).
```

En Windows, `APPDATA` es una ruta con `\`; `prolog_to_os_filename/2` la
convierte a la forma de Prolog, con `/`, para que `directory_file_path/3` no
mezcle los dos separadores. La comparación con `current_prolog_flag/2` está en
un solo predicado, como aconseja la [sección 28.8](index.md#288-windows-y-linux).

## 12

<!-- ejemplo: capitulo-28/soluciones_proyecto.pl predicado: responder_en/3 consulta: open_string("listar logica\nsalir\n", In), bucle_contando(In, 0, N). -->
```prolog
%!  responder_en(+Opciones:list, +Orden, -Respuesta) is det.
%
%   Ejecuta Orden con responder/2. Con la opción salida(Archivo), lo que
%   responder/2 escribe va al archivo, que se reemplaza; sin ella, a la
%   salida actual. Los mensajes de error siguen yendo a la terminal.
responder_en(Opciones, Orden, Respuesta) :-
    (   option(salida(Archivo), Opciones)
    ->  with_output_to(string(Texto), responder(Orden, Respuesta)),
        setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                           write(Stream, Texto),
                           close(Stream))
    ;   responder(Orden, Respuesta)
    ).
```

```text
$ swipl soluciones_proyecto.pl --salida=inscriptos.txt listar logica
$ cat inscriptos.txt
Inscriptos: 101, 102, 104, 106.
```

`with_output_to/2` captura lo que `responder/2` escribe, y el texto se escribe
en el archivo. La salida capturada no es una terminal, y `ansi_format/3` no
agrega códigos de color. Los errores van por `print_message/2` a la salida de
errores, y siguen apareciendo en la terminal.

## 13

<!-- ejemplo: capitulo-28/soluciones_proyecto.pl predicado: bucle_contando/3 consulta: open_string("listar logica\nsalir\n", In), bucle_contando(In, 0, N). -->
```prolog
%!  bucle_contando(+In, +Hasta:integer, -N:integer) is det.
%
%   Como bucle/1, y N es Hasta más la cantidad de órdenes que ejecutó; las
%   líneas vacías y salir no cuentan. La cantidad pasa de una llamada a la
%   siguiente como argumento, sin la base dinámica.
bucle_contando(In, Hasta, N) :-
    format("inscripciones> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl,
        N = Hasta
    ;   normalize_space(string(Orden), Linea),
        (   Orden == "salir"
        ->  N = Hasta
        ;   Orden == ""
        ->  bucle_contando(In, Hasta, N)
        ;   responder(Orden, _),
            Siguiente is Hasta + 1,
            bucle_contando(In, Siguiente, N)
        )
    ).
```

La cantidad es un acumulador, como los del [capítulo 7](../capitulo-07-listas/index.md): pasa de una llamada
a la siguiente, y al terminar se unifica con el resultado. Un contador en la
base dinámica, como el del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#204-contadores-y-estado-global), también funcionaría, pero
habría que reiniciarlo en cada ejecución y en cada prueba.

## 14

La solución completa está en `soluciones_buscaminas.pl`; el tablero y
`vecina/4` son los del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2211-buscaminas-el-tablero-como-tabla-de-busqueda). Descubrir es el recorrido
del [capítulo 18](../capitulo-18-orden-superior/index.md), con el tablero como argumento y las celdas descubiertas
como un conjunto ordenado:

<!-- ejemplo: capitulo-28/soluciones_buscaminas.pl predicado: descubrir/4 aplicar/4 consulta: tablero(3, 3, [1-1], T), descubrir(T, 3-3, [], D), length(D, N). -->
```prolog
%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list)
%!      is det.
%
%   Descubiertas es el conjunto ordenado Vistas más las celdas que descubre
%   un clic en Celda, sin mina: la celda, y si no tiene minas vecinas, las
%   que descubren sus vecinas.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    (   ord_memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   ord_add_element(Vistas, Celda, Vistas1),
        (   valor(Tablero, Celda, 0)
        ->  Tablero = tablero(Filas, Columnas, _),
            findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
            foldl(descubrir(Tablero), Vecinas, Vistas1, Descubiertas)
        ;   Descubiertas = Vistas1
        )
    ).

%!  aplicar(+Jugada, +Juego0, -Juego, -Estado) is semidet.
%
%   Juego es Juego0, juego(Tablero, Descubiertas, Marcadas), después de
%   Jugada, descubrir(Celda) o marcar(Celda). Estado es sigue, gano o
%   perdio. Falla si la celda está fuera del tablero.
aplicar(descubrir(Celda), juego(T, D0, M), juego(T, D, M), Estado) :-
    valor(T, Celda, Valor),
    (   Valor == mina
    ->  ord_add_element(D0, Celda, D),
        Estado = perdio
    ;   descubrir(T, Celda, D0, D),
        (   todas_descubiertas(T, D)
        ->  Estado = gano
        ;   Estado = sigue
        )
    ).
aplicar(marcar(Celda), juego(T, D, M0), juego(T, D, M), sigue) :-
    valor(T, Celda, _),
    (   ord_memberchk(Celda, M0)
    ->  ord_del_element(M0, Celda, M)
    ;   ord_add_element(M0, Celda, M)
    ).
```

Las jugadas se leen con una gramática, y la partida es un bucle que lee,
aplica y sigue hasta que termina:

<!-- ejemplo: capitulo-28/soluciones_buscaminas.pl predicado: jugada//1 orden//1 jugar/3 seguir/4 consulta: tablero(3, 3, [1-1], T), descubrir(T, 3-3, [], D), length(D, N). -->
```prolog
%!  jugada(-Jugada)// is semidet.
%
%   Una jugada escrita como d F C (descubrir) o m F C (marcar).
jugada(Jugada) -->
    blanks,
    orden(Orden),
    blanks,
    integer(F),
    blanks,
    integer(C),
    blanks,
    { Jugada =..

%!  orden(-Orden)// is semidet.
%
%   La letra de una jugada.
orden(descubrir) --> "d".
orden(marcar) --> "m".

%!  jugar(+In, +Juego, -Resultado) is det.
%
%   Muestra Juego, lee jugadas de In y las aplica hasta que la partida
%   termina. Resultado es gano o perdio.
jugar(In, Juego0, Resultado) :-
    mostrar(Juego0, false),
    preguntar(In, "Jugada (d F C descubre, m F C marca):", Texto),
    string_codes(Texto, Codigos),
    (   phrase(jugada(Jugada), Codigos)
    ->  (   aplicar(Jugada, Juego0, Juego, Estado)
        ->  seguir(Estado, In, Juego, Resultado)
        ;   format("La celda está fuera del tablero.~n"),
            jugar(In, Juego0, Resultado)
        )
    ;   format("Jugada no válida.~n"),
        jugar(In, Juego0, Resultado)
    ).

%!  seguir(+Estado, +In, +Juego, -Resultado) is det.
%
%   Sigue la partida si Estado es sigue; si terminó, muestra el tablero
%   completo y el resultado.
seguir(sigue, In, Juego, Resultado) :-
    jugar(In, Juego, Resultado).
seguir(gano, _, Juego, gano) :-
    mostrar(Juego, true),
    format("Todas las celdas libres están descubiertas: partida ganada.~n").
seguir(perdio, _, Juego, perdio) :-
    mostrar(Juego, true),
    format("La celda tenía una mina: partida perdida.~n").
```

Una partida de 5 × 5 con 4 minas y la semilla 42, que se pierde en la
segunda jugada:

```text
$ swipl soluciones_buscaminas.pl --semilla=42 5 5 4
     1  2  3  4  5
  1  #  #  #  #  #
  2  #  #  #  #  #
  3  #  #  #  #  #
  4  #  #  #  #  #
  5  #  #  #  #  #
Jugada (d F C descubre, m F C marca): d 3 3
     1  2  3  4  5
  1  #  #  #  #  #
  2  #  #  #  #  #
  3  #  #  3  #  #
  4  #  #  #  #  #
  5  #  #  #  #  #
Jugada (d F C descubre, m F C marca): d 2 3
     1  2  3  4  5
  1  #  #  #  #  #
  2  #  #  *  #  #
  3  #  *  3  *  #
  4  #  #  #  #  #
  5  *  #  #  #  #
La celda tenía una mina: partida perdida.
$ echo $?
1
```

`main/1` sigue el [Patrón 38](../patrones.md#38-programa-de-linea-de-comandos): valida los tres argumentos, fija la semilla si se
pide, juega, y convierte el resultado en el código de salida. `jugar/3` lee de
un stream, y las pruebas juegan partidas enteras con las jugadas en una
cadena; con `--semilla`, el programa completo se prueba en otro proceso con un
tablero conocido. El [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) retoma este programa en el Buscaminas
completo.
