# Soluciones del capítulo 36 — Interfaces de usuario

El código de esta página está en `ejemplos/capitulo-36/`, repartido como el
del capítulo: `texto/soluciones_pantalla.pl`, `texto/soluciones_buscaminas.pl`
y `texto/soluciones_menu.pl` para la pantalla completa,
`ventanas/soluciones_xpce.pl` para las ventanas y `web/soluciones_web.pl`
para las páginas. Cada archivo pasa sus pruebas; las de las ventanas
necesitan XPCE y corren con `swipl-win` (`make windows`).

## 1

<!-- ejemplo: capitulo-36/texto/pantalla.pl predicado: caja/3 -->
```prolog
%!  caja(+Titulo:string, +Lineas:list(string), -Caja:list(string)) is det.
%
%   Caja son las líneas de un recuadro con Titulo en el borde superior y
%   Lineas adentro, alineadas a la izquierda.
caja(Titulo, Lineas, [Arriba|Medio]) :-
    string_length(Titulo, LargoTitulo),
    maplist(string_length, Lineas, Largos),
    Minimo is LargoTitulo + 1,
    max_list([Minimo|Largos], Ancho),
    borde_superior(Titulo, LargoTitulo, Ancho, Arriba),
    maplist(interior(Ancho), Lineas, Interiores),
    Relleno is Ancho + 2,
    repetir("─", Relleno, Raya),
    string_concat("└", Raya, Abajo0),
    string_concat(Abajo0, "┘", Abajo),
    append(Interiores, [Abajo], Medio).
```

```prolog
?- caja("", ["ab"], L).
L = ["┌────┐", "│ ab │", "└────┘"].

?- with_output_to(string(S), dibujar(["a", "b"])).
S = "\u001B[2J\u001B[H\u001B[1;1Ha\u001B[2;1Hb".
```

```text
?- open_string("\r \e[C", In), leer_tecla(get_code(In), T1), leer_tecla(get_code(In), T2), leer_tecla(get_code(In), T3).
In = <stream>(0x60b5ed2bef00),
T1 = enter,
T2 = espacio,
T3 = derecha.
```

Sin título, el borde superior es una raya entera, y el ancho es el de la
línea más larga. `dibujar/1` escribe primero el borrado y el regreso al
origen, y después cada línea precedida de la secuencia que ubica el cursor
en su fila. La tercera consulta lee un código para Enter, uno para el
espacio y tres para la flecha; el número del stream cambia en cada
ejecución.

## 2

`caja/3` mide cada línea con `string_length/2`, y `interior/3` la completa
con la columna de `format/2`. Los dos cuentan caracteres, no lo que se ve:
`"\e[31m*\e[0m"` tiene 10 caracteres y muestra uno. La caja resulta con el
ancho de diez, y la línea de color, que no se completa porque ya los tiene,
queda nueve columnas más angosta en la pantalla:

```prolog
?- caja("M", ["\e[31m*\e[0m", "abc"], C).
C = ["┌─ M ────────┐", "│ \u001B[31m*\u001B[0m │", "│ abc        │", "└────────────┘"].
```

`largo_visible/2` recorre los códigos con una gramática que salta las
secuencias `\e[…m`, y la nueva `caja/3` completa cada línea con los blancos
que le faltan según ese largo:

<!-- ejemplo: capitulo-36/texto/soluciones_pantalla.pl predicado: largo_visible/2 visibles//1 hasta_la_m//0 interior/3 -->
```prolog
%!  largo_visible(+Texto:string, -N:integer) is det.
%
%   N es la cantidad de caracteres de Texto que se ven: no cuenta las
%   secuencias de escape de atributos, \e[ ... m.
largo_visible(Texto, N) :-
    string_codes(Texto, Codigos),
    phrase(visibles(Visibles), Codigos),
    length(Visibles, N).

%!  visibles(-Codigos:list)// is det.
%
%   Codigos son los códigos de la entrada fuera de las secuencias \e[ ... m.
visibles(Codigos) -->
    [27, 0'[],
    !,
    hasta_la_m,
    visibles(Codigos).
visibles([C|Codigos]) -->
    [C],
    !,
    visibles(Codigos).
visibles([]) -->
    [].

%!  hasta_la_m// is semidet.
%
%   Consume los códigos de una secuencia de atributos hasta la m final.
hasta_la_m -->
    [0'm],
    !.
hasta_la_m -->
    [_],
    hasta_la_m.

%!  interior(+Ancho:integer, +Texto:string, -Linea:string) is det.
%
%   Linea es Texto entre bordes, con blancos hasta Ancho caracteres
%   visibles.
interior(Ancho, Texto, Linea) :-
    largo_visible(Texto, Largo),
    Faltan is Ancho - Largo,
    repetir(" ", Faltan, Blancos),
    atomics_to_string(["│ ", Texto, Blancos, " │"], Linea).
```

`caja/3` cambia solo en la línea que mide: `maplist(largo_visible, Lineas,
Largos)` en lugar de `string_length/2`. `atomics_to_string/2` une en una
cadena los átomos, cadenas y números de una lista, en orden y sin separador.

## 3

Inicio y Fin son secuencias de tres códigos, como las flechas. Suprimir,
`\e[3~`, tiene cuatro: después del `[` llega un dígito, y la tilde. La
decisión de pedir un código más se toma con el segundo código: si es un
dígito, la secuencia sigue. La tecla Fin se llama `final`, porque `fin` ya
es el fin de la entrada:

<!-- ejemplo: capitulo-36/texto/soluciones_pantalla.pl predicado: tecla/3 secuencia/4 escape/3 con_tilde/2 -->
```prolog
%!  tecla(+Codigo:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la que empieza con Codigo. Una secuencia de escape pide dos
%   códigos más a Siguiente; si el segundo es un dígito, como en \e[3~,
%   pide uno más.
tecla(27, Siguiente, Tecla) :-
    !,
    call(Siguiente, C1),
    call(Siguiente, C2),
    secuencia(C1, C2, Siguiente, Tecla).
tecla(13, _, enter) :-
    !.
tecla(10, _, enter) :-
    !.
tecla(32, _, espacio) :-
    !.
tecla(127, _, borrar) :-
    !.
tecla(8, _, borrar) :-
    !.
tecla(-1, _, fin) :-
    !.
tecla(Codigo, _, letra(L)) :-
    code_type(Codigo, graph),
    !,
    char_code(L, Codigo).
tecla(_, _, otra).

%!  secuencia(+C1:integer, +C2:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la de la secuencia ESC C1 C2, que puede seguir con ~.
secuencia(0'[, C2, Siguiente, Tecla) :-
    code_type(C2, digit),
    !,
    call(Siguiente, C3),
    (   C3 == 0'~,
        con_tilde(C2, T)
    ->  Tecla = T
    ;   Tecla = otra
    ).
secuencia(C1, C2, _, Tecla) :-
    (   escape(C1, C2, T)
    ->  Tecla = T
    ;   Tecla = otra
    ).

% escape(C1, C2, Tecla): la secuencia ESC C1 C2 es Tecla.
escape(0'[, 0'A, arriba).
escape(0'[, 0'B, abajo).
escape(0'[, 0'C, derecha).
escape(0'[, 0'D, izquierda).
escape(0'[, 0'H, inicio).
escape(0'[, 0'F, final).

% con_tilde(C, Tecla): la secuencia ESC [ C ~ es Tecla.
con_tilde(0'3, suprimir).
```

```prolog
test(teclas_nuevas, true(T == [inicio, letra(a), final, letra(b), suprimir,
                               letra(c), borrar, arriba])) :-
    teclas("\e[Ha\e[Fb\e[3~c\x7F\\e[A", T).
```

La letra después de cada secuencia comprueba que la lectura no consumió
un código de más ni dejó uno sin leer. La tecla de borrar, código 127 u 8,
la usa el ejercicio 6.

## 4

<!-- ejemplo: capitulo-36/texto/soluciones_pantalla.pl predicado: lado_a_lado/3 completar/3 -->
```prolog
%!  lado_a_lado(+Caja1:list(string), +Caja2:list(string),
%!              -Lineas:list(string)) is det.
%
%   Lineas pone Caja2 a la derecha de Caja1, separadas por dos espacios. La
%   caja más corta se completa con líneas en blanco de su ancho. Las dos
%   cajas tienen al menos una línea.
lado_a_lado(Caja1, Caja2, Lineas) :-
    length(Caja1, N1),
    length(Caja2, N2),
    N is max(N1, N2),
    completar(Caja1, N, Completa1),
    completar(Caja2, N, Completa2),
    maplist([A, B, L]>>atomics_to_string([A, "  ", B], L),
            Completa1, Completa2, Lineas).

%!  completar(+Caja:list(string), +N:integer, -Completa:list(string)) is det.
%
%   Completa es Caja con líneas en blanco al final hasta tener N líneas.
completar([Primera|Resto], N, Completa) :-
    string_length(Primera, Ancho),
    length([Primera|Resto], M),
    Faltan is N - M,
    repetir(" ", Ancho, Blanco),
    length(Blancos, Faltan),
    maplist(=(Blanco), Blancos),
    append([Primera|Resto], Blancos, Completa).
```

`pantalla_al_lado/2` reutiliza el modelo del capítulo: separa las líneas de
`pantalla/2` en la caja del tablero, que termina en la primera línea que
empieza con `└`, la del estado y la ayuda, y las vuelve a juntar:

<!-- ejemplo: capitulo-36/texto/soluciones_buscaminas.pl predicado: pantalla_al_lado/2 -->
```prolog
%!  pantalla_al_lado(+Juego, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de pantalla/2 con la caja del estado a la
%   derecha de la del tablero, y la ayuda debajo.
pantalla_al_lado(Juego, Lineas) :-
    pantalla(Juego, Todas),
    append(Arriba, [Abajo|Resto], Todas),
    sub_string(Abajo, 0, 1, _, "└"),
    !,
    append(Arriba, [Abajo], Tablero),
    once(append(Estado, [Ayuda], Resto)),
    lado_a_lado(Tablero, Estado, Juntas),
    append(Juntas, [Ayuda], Lineas).
```

```text
┌─ Buscaminas ┐  ┌─ Estado ────────────┐
│  #  #  #    │  │ Minas sin marcar: 1 │
│  # [#] #    │  │ En juego            │
│  #  #  #    │  └─────────────────────┘
└─────────────┘
Flechas: mover  Espacio: descubrir  m: marcar  q: salir
```

`once/1` alrededor del último `append/3` evita la alternativa que deja al
separar el último elemento de una lista; sin él, la prueba informa un punto
de elección.

## 5

<!-- ejemplo: capitulo-36/texto/soluciones_buscaminas.pl predicado: paso_con_sugerencia/3 -->
```prolog
%!  paso_con_sugerencia(+Tecla, +Juego0, -Juego) is det.
%
%   Como paso/3, y además la tecla ? lleva el cursor a la celda que da
%   sugerencia/2; si no hay ninguna segura, el juego no cambia.
paso_con_sugerencia(letra(?), juego(P, Cursor0, Pedido),
                    juego(P, Cursor, Pedido)) :-
    !,
    (   sugerencia(P, Celda)
    ->  Cursor = Celda
    ;   Cursor = Cursor0
    ).
paso_con_sugerencia(Tecla, Juego0, Juego) :-
    paso(Tecla, Juego0, Juego).
```

En el archivo del capítulo, la primera cláusula se agrega al principio de
`paso/3`; la solución la escribe en un predicado aparte que delega en
`paso/3`, para no modificar el ejemplo. Las pruebas cubren los tres casos:

```prolog
test(sugerencia, true(C == 3-2)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P0),
    jugar(descubrir, 1-4, P0, P),
    paso_con_sugerencia(letra(?), juego(P, 1-1, jugar), juego(_, C, _)).

test(sin_sugerencia, true(C == 2-2)) :-
    partida_con_minas(3, 3, [1-1], P),
    paso_con_sugerencia(letra(?), juego(P, 2-2, jugar), juego(_, C, _)).

test(otras_teclas, true(C == 1-2)) :-
    partida_con_minas(3, 3, [1-1], P),
    paso_con_sugerencia(derecha, juego(P, 1-1, jugar), juego(_, C, _)).
```

## 6

El estado gana un tercer argumento, el aviso, y la vista
`formulario(Legajo)`, con el legajo escrito hasta el momento. Las vistas
del capítulo no cambian: la transición y el modelo nuevos atienden el
formulario y dejan lo demás a `paso_menu/3` y `pantalla_menu/2`:

<!-- ejemplo: capitulo-36/texto/soluciones_menu.pl predicado: paso_formulario/3 en_el_formulario/5 -->
```prolog
%!  paso_formulario(+Tecla, +Menu0, -Menu) is det.
%
%   Menu es Menu0 después de Tecla. En los inscriptos, i abre el
%   formulario. En el formulario, los dígitos se agregan al legajo, borrar
%   quita el último, q vuelve sin inscribir y Enter inscribe con
%   inscribir/3 y vuelve a los inscriptos con el resultado como aviso. Las
%   demás vistas responden como en paso_menu/3.
paso_formulario(fin, menu(N, _, A), menu(N, salir, A)) :-
    !.
paso_formulario(Tecla, menu(N, formulario(Legajo), A), Menu) :-
    !,
    en_el_formulario(Tecla, N, Legajo, A, Menu).
paso_formulario(letra(i), menu(N, inscriptos, _),
                menu(N, formulario(""), "")) :-
    !.
paso_formulario(Tecla, menu(N0, Vista0, A), menu(N, Vista, A)) :-
    paso_menu(Tecla, menu(N0, Vista0), menu(N, Vista)).

%!  en_el_formulario(+Tecla, +N:integer, +Legajo:string, +Aviso:string,
%!                   -Menu) is det.
%
%   Menu resulta de Tecla en el formulario de la materia N.
en_el_formulario(letra(D), N, Legajo0, A, menu(N, formulario(Legajo), A)) :-
    char_type(D, digit(_)),
    !,
    string_concat(Legajo0, D, Legajo).
en_el_formulario(borrar, N, Legajo0, A, menu(N, formulario(Legajo), A)) :-
    !,
    (   sub_string(Legajo0, 0, _, 1, Legajo)
    ->  true
    ;   Legajo = Legajo0
    ).
en_el_formulario(letra(q), N, _, A, menu(N, inscriptos, A)) :-
    !.
en_el_formulario(enter, N, Legajo, _, menu(N, inscriptos, Aviso)) :-
    !,
    materia_numero(N, Materia),
    atom_string(Texto, Legajo),
    mensaje_de_inscripcion(Texto, Materia, Aviso).
en_el_formulario(_, N, Legajo, A, menu(N, formulario(Legajo), A)).
```

<!-- ejemplo: capitulo-36/texto/soluciones_menu.pl predicado: pantalla_formulario/2 pantalla_de_vista/3 -->
```prolog
%!  pantalla_formulario(+Menu, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Menu: la del menú, o, en el formulario, la de
%   los inscriptos sin su ayuda y la caja del formulario; debajo, el
%   aviso, si hay uno.
pantalla_formulario(menu(N, Vista, Aviso), Lineas) :-
    pantalla_de_vista(Vista, N, Lineas0),
    (   Aviso == ""
    ->  Lineas = Lineas0
    ;   append(Lineas0, [Aviso], Lineas)
    ).

%!  pantalla_de_vista(+Vista, +N:integer, -Lineas:list(string)) is det.
%
%   Lineas son las líneas de Vista, sin el aviso.
pantalla_de_vista(formulario(Legajo), N, Lineas) :-
    !,
    pantalla_menu(menu(N, inscriptos), Inscriptos),
    once(append(SinAyuda, [_], Inscriptos)),
    materia_numero(N, Codigo),
    materia(Codigo, Nombre, _),
    format(string(Titulo), "Inscribir en ~w", [Nombre]),
    format(string(Campo), "Legajo: ~w_", [Legajo]),
    caja(Titulo, [Campo], Caja),
    append([SinAyuda, Caja, ["Dígitos: legajo  Enter: inscribir  \c
                               q: cancelar"]], Lineas).
pantalla_de_vista(Vista, N, Lineas) :-
    pantalla_menu(menu(N, Vista), Lineas).
```

La transición sigue siendo una relación entre estados; su único efecto es
la inscripción, que hace `inscribir/3` a través de
`mensaje_de_inscripcion/3`, el mismo predicado que usa la ventana de XPCE.
Las pruebas que inscriben restauran los datos. Con el legajo 104 en
sintaxis, la pantalla del formulario es:

```text
┌─ Inscriptos en sintaxis ┐
│ Sin inscriptos          │
│                         │
│ Promedio: sin notas     │
└─────────────────────────┘
┌─ Inscribir en sintaxis ┐
│ Legajo: 104_           │
└────────────────────────┘
Dígitos: legajo  Enter: inscribir  q: cancelar
```

Y después de Enter, la de los inscriptos, con la línea
`│ 104 diego     cursando  │` y el aviso
`Inscripción aceptada: 104 en ssl` debajo de la ayuda. La prueba del bucle
recorre la secuencia completa con las teclas en una cadena:

```prolog
test(bucle, true(A == "Inscripción aceptada: 104 en ssl")) :-
    sin_cambios(
        setup_call_cleanup(
            open_string("\e[B\e[B\e[B\e[B\e[B\ri104\r", In),
            with_output_to(string(_),
                           bucle_formulario(get_code(In),
                                            menu(1, materias, ""),
                                            menu(_, salir, A))),
            close(In))).
```

## 7

| Predicado | Capa | Puro | Se prueba en la integración continua |
|---|---|---|---|
| `paso/3` | interfaz (transición) | sí; llama a `jugar/4`, que es puro | sí |
| `pantalla/2` | interfaz (modelo) | sí | sí |
| `bucle/3` | interfaz (borde) | no: lee y escribe | sí, con teclas en una cadena y la salida capturada |
| `leer_tecla/2` | interfaz (borde) | no: lee de la fuente que recibe | sí, con `open_string/2` |
| `clic/4` | interfaz, sobre el núcleo | sí | sí |
| `pulsar/3` | interfaz (callback) | no: lee y cambia la ventana y `partida_de/2` | no: solo en `swipl-win` |
| `mostrar/2` | interfaz (borde) | no: cambia la ventana | no: solo en `swipl-win` |
| `cuerpo_materia/2` | interfaz (modelo de la página) | sí; consulta los datos | sí |
| `pagina_materia/2` | interfaz (borde) | no: responde el pedido | sí, con pedidos HTTP |
| `mensaje_de_inscripcion/3` | interfaz, sobre el núcleo | no: inscribe | sí, restaurando los datos |

Ninguno es del núcleo: el núcleo son los módulos del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), que no cambiaron. Lo que la integración continua no
prueba es lo que depende de XPCE.

## 8

<!-- ejemplo: capitulo-36/ventanas/soluciones_xpce.pl predicado: texto_de_sugerencia/2 ventana_con_sugerencia/2 sugerir/1 -->
```prolog
%!  texto_de_sugerencia(+Partida, -Texto:string) is det.
%
%   Texto dice la celda segura que da sugerencia/2, o que no hay ninguna.
texto_de_sugerencia(Partida, Texto) :-
    (   sugerencia(Partida, F-C)
    ->  format(string(Texto), "Celda segura: fila ~d, columna ~d", [F, C])
    ;   Texto = "No hay ninguna celda segura a la vista"
    ).

%!  ventana_con_sugerencia(+Partida, -Ventana) is det.
%
%   Ventana es la del Buscaminas con el ítem sugerencia en el menú Juego.
ventana_con_sugerencia(Partida, Ventana) :-
    ventana_con_partida(Partida, Ventana),
    get(Ventana, member, controles, Controles),
    get(Controles, member, menu_bar, Barra),
    get(Barra, member, juego, Juego),
    send(Juego, append,
         menu_item(sugerencia, message(@(prolog), sugerir, Ventana))).

%!  sugerir(+Ventana) is det.
%
%   Responde al ítem sugerencia: escribe en el rótulo el texto de
%   texto_de_sugerencia/2 para la partida de Ventana.
sugerir(Ventana) :-
    partida_de(Ventana, Partida),
    texto_de_sugerencia(Partida, Texto),
    atom_string(Atomo, Texto),
    get(Ventana, member, controles, Controles),
    get(Controles, member, estado, Rotulo),
    send(Rotulo, selection, Atomo).
```

`sugerir/1` necesita la partida de la ventana: `buscaminas_xpce.pl` exporta
`partida_de/2` para eso. La prueba del texto corre en cualquier Prolog; la
de la ventana ejecuta el mensaje del ítem, como lo haría un clic en el menú:

```prolog
    get(Juego, member, sugerencia, Item),
    get(Item, message, Mensaje),
    send(Mensaje, execute),
    get(Controles, member, estado, Rotulo),
    get(Rotulo, selection, R).
```

Con minas en 1-1 y 3-3 y la celda 1-4 descubierta, el rótulo dice
`Celda segura: fila 3, columna 2`.

## 9

<!-- ejemplo: capitulo-36/ventanas/soluciones_xpce.pl predicado: lineas_de_inscriptos/2 ventana_con_inscriptos/1 mostrar_inscriptos/1 inscribir_y_mostrar/1 -->
```prolog
%!  lineas_de_inscriptos(+Materia:atom, -Lineas:list(string)) is det.
%
%   Lineas son los inscriptos en Materia, con el legajo y el nombre.
lineas_de_inscriptos(Materia, Lineas) :-
    inscriptos(Materia, Legajos),
    findall(Linea,
            ( member(Legajo, Legajos),
              alumno(Legajo, Nombre, _, _),
              format(string(Linea), "~d  ~w", [Legajo, Nombre]) ),
            Lineas).

%!  ventana_con_inscriptos(-Ventana) is det.
%
%   Ventana es la de Inscripciones con una lista más, inscriptos, que
%   muestra los inscriptos de la materia elegida. El menú de materias y el
%   botón Inscribir la actualizan.
ventana_con_inscriptos(Ventana) :-
    ventana_inscripciones(Ventana),
    get(Ventana, member, dialog, D),
    get(Ventana, member, ranking, Ranking),
    send(new(Lista, browser), right, Ranking),
    send(Lista, name, inscriptos),
    get(D, member, materia, Menu),
    send(Menu, message, message(@(prolog), mostrar_inscriptos, Ventana)),
    get(D, member, inscribir, Boton),
    send(Boton, message, message(@(prolog), inscribir_y_mostrar, Ventana)),
    mostrar_inscriptos(Ventana).

%!  mostrar_inscriptos(+Ventana) is det.
%
%   Llena la lista inscriptos con los de la materia elegida en el menú.
mostrar_inscriptos(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    get(Ventana, member, inscriptos, Lista),
    send(Lista, clear),
    lineas_de_inscriptos(Materia, Lineas),
    forall(member(Linea, Lineas),
           ( atom_string(Atomo, Linea),
             send(Lista, append, Atomo) )).

%!  inscribir_y_mostrar(+Ventana) is det.
%
%   Responde al botón Inscribir como la ventana original, y después
%   actualiza la lista de inscriptos.
inscribir_y_mostrar(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, legajo, Campo),
    get(Campo, selection, Legajo),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    mensaje_de_inscripcion(Legajo, Materia, Mensaje),
    atom_string(Atomo, Mensaje),
    get(D, member, resultado, Rotulo),
    send(Rotulo, selection, Atomo),
    mostrar_inscriptos(Ventana).
```

Un `menu` ejecuta su mensaje cuando la persona elige una opción, con la
opción como argumento. Cambiar la selección con `send(Menu, selection, log)`
no lo ejecuta; por eso la prueba reenvía el mensaje con
`send(Mensaje, forward, log)`, que es lo que hace XPCE con el clic. La lista
tiene 5 inscriptos en `am1`, la primera materia, 4 en `log`, ninguno en
`ssl`, y 1 después de inscribir al 104.

## 10

<!-- ejemplo: capitulo-36/ventanas/soluciones_xpce.plt fragmento: test(rechazo_en_la_ventana, .. get(Rotulo, selection, R). -->
```prolog
test(rechazo_en_la_ventana,
     [ condition(hay_xpce),
       cleanup(send(V, destroy)),
       true(R == 'Inscripción rechazada: 103 en ssl, falta(log)') ]) :-
    ventana_inscripciones(V),
    elemento(V, legajo, Campo),
    send(Campo, selection, '103'),
    elemento(V, materia, Menu),
    send(Menu, selection, ssl),
    elemento(V, inscribir, Boton),
    sin_cambios(send(Boton, execute)),
    elemento(V, resultado, Rotulo),
    get(Rotulo, selection, R).
```

`sin_cambios/1` restaura los datos aunque la inscripción se rechace, porque
`inscribir/3` cuenta la operación en los dos casos. En `swipl`, la
condición `hay_xpce` falla y plunit omite la prueba en silencio: el archivo
corre las tres pruebas de los predicados puros, y `swipl-win` las seis.

## 11

<!-- ejemplo: capitulo-36/web/soluciones_web.pl predicado: pagina_alumno/2 cuerpo_alumno/2 texto_de_estado/2 -->
```prolog
%!  pagina_alumno(+Texto:atom, +Pedido) is det.
%
%   GET /pagina/alumnos/Texto: la página del alumno, o 404 si Texto no es
%   el legajo de un alumno.
pagina_alumno(Texto, Pedido) :-
    (   atom_number(Texto, Legajo),
        integer(Legajo),
        cuerpo_alumno(Legajo, Cuerpo)
    ->  reply_html_page(title(Texto), Cuerpo)
    ;   http_404([], Pedido)
    ).

%!  cuerpo_alumno(+Legajo:integer, -Cuerpo) is semidet.
%
%   Cuerpo es la página del alumno Legajo: nombre, carrera, materias con su
%   estado y promedio. Falla si el alumno no existe.
cuerpo_alumno(Legajo, [ h1([Legajo, ' ', Nombre]),
                        p(['Carrera: ', Carrera]),
                        ul(Items),
                        p(Promedio)
                      ]) :-
    alumno(Legajo, Nombre, Carrera, _),
    indice_por_alumno(Indice),
    materias_de(Indice, Legajo, Materias),
    findall(li([Materia, ': ', Texto]),
            ( member(Materia-Estado, Materias),
              texto_de_estado(Estado, Texto) ),
            Items),
    (   promedio_de_alumno(Legajo, P)
    ->  format(atom(Promedio), "Promedio: ~2f", [P])
    ;   Promedio = 'Promedio: sin notas'
    ).

%!  texto_de_estado(+Estado, -Texto:atom) is det.
%
%   Texto describe el estado de una inscripción.
texto_de_estado(nota(N), Texto) :-
    !,
    format(atom(Texto), "nota ~d", [N]).
texto_de_estado(Estado, Estado).
```

La ruta se declara con
`:- http_handler(root(pagina/alumnos/Legajo), pagina_alumno(Legajo), [method(get)]).`
El legajo llega como átomo; uno que no es un número y uno que no existe
responden 404. Las pruebas piden `/pagina/alumnos/101` y buscan
`<li>pp: cursando</li>`, y piden `/pagina/alumnos/999` y
`/pagina/alumnos/abc`.

## 12

<!-- ejemplo: capitulo-36/web/soluciones_web.pl predicado: inscribir_y_volver/1 materia_con_mensaje/2 -->
```prolog
%!  inscribir_y_volver(+Pedido) is det.
%
%   POST /pagina/inscribir: inscribe y responde 303 a la página de la
%   materia, con el resultado en el parámetro mensaje.
inscribir_y_volver(Pedido) :-
    http_parameters(Pedido, [ legajo(Legajo, [integer]),
                              materia(Materia, [atom]) ]),
    inscribir(Legajo, Materia, Resultado),
    texto_del_resultado(Legajo, Materia-Resultado, Texto),
    uri_query_components(Consulta, [mensaje=Texto]),
    format(atom(Destino), "/pagina/materias/~w?~w", [Materia, Consulta]),
    http_redirect(see_other, Destino, Pedido).

%!  materia_con_mensaje(+Codigo:atom, +Pedido) is det.
%
%   GET /pagina/materias/Codigo, con el parámetro opcional mensaje debajo
%   del título; 404 si la materia no existe.
materia_con_mensaje(Codigo, Pedido) :-
    http_parameters(Pedido, [mensaje(Mensaje, [optional(true)])]),
    (   cuerpo_materia(Codigo, [Titulo|Resto])
    ->  (   var(Mensaje)
        ->  Cuerpo = [Titulo|Resto]
        ;   Cuerpo = [Titulo, p(Mensaje)|Resto]
        ),
        reply_html_page(title(Codigo), Cuerpo)
    ;   http_404([], Pedido)
    ).
```

`uri_query_components/2` escribe el mensaje con los caracteres que una
dirección no admite codificados. Con la redirección, lo último que pidió el
navegador es la página de la materia con GET: recargarla vuelve a pedir esa
página, y no reenvía el formulario. Sin ella, la página del resultado es la
respuesta de un POST, y recargarla repite la inscripción; el navegador
advierte antes de reenviar los datos. La solución reemplaza las dos rutas
del capítulo con `priority(1)`; en el archivo del capítulo, bastaría con
cambiar sus manejadores.

## 13

<!-- ejemplo: capitulo-36/web/soluciones_web.pl predicado: pagina_sugerencia/2 leer_json/3 cuerpo_con_sugerencia/4 -->
```prolog
%!  pagina_sugerencia(+Id:atom, +Pedido) is det.
%
%   GET /juego/Id/sugerencia: el tablero con la celda segura que da el
%   servicio, o con el aviso de que no hay ninguna.
pagina_sugerencia(Id, _Pedido) :-
    servicio(Base),
    format(atom(Tablero), "~w/partidas/~w", [Base, Id]),
    format(atom(Pregunta), "~w/partidas/~w/sugerencia", [Base, Id]),
    leer_json(Tablero, _, Respuesta),
    leer_json(Pregunta, Codigo, Celda),
    (   Codigo == 200
    ->  format(atom(Mensaje), "Celda segura: fila ~w, columna ~w",
               [Celda.fila, Celda.columna])
    ;   Mensaje = 'No hay ninguna celda segura a la vista'
    ),
    cuerpo_con_sugerencia(Id, Respuesta, Mensaje, Cuerpo),
    reply_html_page(title('Buscaminas'), Cuerpo).

%!  leer_json(+Url:atom, -Codigo:integer, -Dict:dict) is det.
%
%   Pide Url con GET; Codigo es el código de estado y Dict el JSON de la
%   respuesta.
leer_json(Url, Codigo, Dict) :-
    setup_call_cleanup(http_open(Url, S, [status_code(Codigo)]),
                       json_read_dict(S, Dict),
                       close(S)).

%!  cuerpo_con_sugerencia(+Id, +Respuesta:dict, +Mensaje:atom, -Cuerpo)
%!      is det.
%
%   Cuerpo es la página del tablero de cuerpo_tablero/3, con el botón
%   Sugerencia, un formulario que se envía con GET, y el Mensaje debajo.
cuerpo_con_sugerencia(Id, Respuesta, Mensaje, Cuerpo) :-
    cuerpo_tablero(Id, Respuesta, Tablero),
    format(atom(Accion), "/juego/~w/sugerencia", [Id]),
    append(Tablero,
           [ form([action(Accion), method(get)],
                  input([type(submit), value('Sugerencia')])),
             p(Mensaje)
           ],
           Cuerpo).
```

El servicio responde 404 cuando no hay una celda segura, y `http_open/3`
con la opción `status_code/1` entrega ese código en lugar de producir un
error. El botón es un formulario que se envía con GET: pedir una
sugerencia no cambia la partida. La prueba juega la partida de semilla 7
con el servicio y compara la página con lo que `sugerencia/2` responde
sobre la misma partida: después de descubrir la celda 1-1, la celda
segura es la 3-4.

## 14

| Interfaz | Entrada de las pruebas | Cómo leen el resultado |
|---|---|---|
| Línea de comandos ([capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md)) | las jugadas en una cadena, abierta con `open_string/2` | el estado final y el texto capturado con `with_output_to/2` |
| Pantalla completa | listas de teclas para `paso/3` con `foldl/4`, o los códigos en una cadena para `bucle/3` | las líneas del modelo, el estado final y la salida capturada, cortada en pantallas por `\e[2J` |
| Ventanas | la ventana creada sin abrir; `send/3` llena los campos y `send(Boton, execute)` hace el clic | `get/3` de etiquetas, rótulos, listas y posiciones |
| Web | pedidos HTTP a un servidor en un puerto libre | el código de estado y el HTML de la respuesta; los cuerpos, como términos |
