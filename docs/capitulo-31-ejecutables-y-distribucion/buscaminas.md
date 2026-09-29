# Buscaminas completo — el código fuente

Esta página tiene el código completo del Buscaminas del curso, con sus
pruebas, tal como está en `ejemplos/capitulo-31/buscaminas/`. Reúne lo que
los capítulos anteriores construyeron por partes: la cuenta de minas vecinas
del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md), el recorrido que descubre una región del
[capítulo 18](../capitulo-18-orden-superior/index.md), el tablero como tabla de búsqueda del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md),
la deducción con restricciones del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md), el juego en la terminal del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) y el servicio del [capítulo 30](../capitulo-30-servicios-web-rest/index.md). La
[sección 31.9](index.md#319-buscaminas-completo) explica cómo se armó.

| Módulo | Hace | Usa |
|---|---|---|
| `vecinos` | las celdas vecinas y cuántas minas hay entre ellas | — |
| `tablero` | el tablero como assoc, con minas elegidas al azar con una semilla | `vecinos` |
| `descubrir` | descubrir una región | `tablero`, `vecinos` |
| `resolver` | deducir qué celdas ocultas son seguras | `vecinos` |
| `partida` | el estado de una partida y sus jugadas, con errores ISO | `tablero`, `descubrir`, `resolver` |
| `terminal` | el juego en la terminal | `partida` |
| `servicio` | el juego por HTTP | `partida` |
| `buscaminas.pl` | el programa: lee los argumentos y elige | `partida`, `terminal`, `servicio` |
| `cliente.py` | un cliente de Python del servicio | — |

Se juega en la terminal, se ofrece como servicio y se construye como
programa, con los comandos de la [sección 31.9](index.md#319-buscaminas-completo):

```text
$ swipl buscaminas.pl --semilla=7 9 9 10
$ swipl buscaminas.pl --servicio --puerto=8080
$ swipl ../construir.pl -- buscaminas.pl
```

## vecinos

<!-- ejemplo: capitulo-31/buscaminas/vecinos.pl -->
```prolog
:- module(vecinos,
          [ vecina/4,
            minas_vecinas/5
          ]).

:- use_module(library(ordsets)).

%!  vecina(+Filas:integer, +Columnas:integer, +Celda:pair, -Vecina:pair)
%!      is nondet.
%
%   Vecina es una de las celdas que rodean a Celda dentro de un tablero de
%   Filas por Columnas.
vecina(Filas, Columnas, F-C, VF-VC) :-
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  minas_vecinas(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -N:integer) is det.
%
%   N es la cantidad de vecinas de Celda que están en Minas, un conjunto
%   ordenado.
minas_vecinas(Filas, Columnas, Minas, Celda, N) :-
    aggregate_all(count,
                  ( vecina(Filas, Columnas, Celda, V),
                    ord_memberchk(V, Minas) ),
                  N).
```

<!-- ejemplo: capitulo-31/buscaminas/vecinos.plt -->
```prolog
:- begin_tests(vecinos).

test(esquina, true(N == 3)) :-
    aggregate_all(count, vecina(3, 3, 1-1, _), N).

test(centro, true(N == 8)) :-
    aggregate_all(count, vecina(3, 3, 2-2, _), N).

test(minas_vecinas, true(N == 2)) :-
    minas_vecinas(3, 3, [1-1, 3-3], 2-2, N).

:- end_tests(vecinos).
```

## tablero

<!-- ejemplo: capitulo-31/buscaminas/tablero.pl -->
```prolog
:- module(tablero,
          [ tablero/4,
            tablero_al_azar/5,
            valor/3,
            cantidad_de_minas/2
          ]).

:- use_module(library(assoc)).
:- use_module(library(ordsets)).
:- use_module(library(random)).
:- use_module(library(error)).
:- use_module(vecinos).

%!  tablero(+Filas:integer, +Columnas:integer, +Minas:list, -Tablero) is det.
%
%   Tablero es el tablero de Filas por Columnas con minas en las celdas de
%   Minas, pares Fila-Columna.
tablero(Filas, Columnas, Minas, tablero(Filas, Columnas, Celdas)) :-
    list_to_ord_set(Minas, ConjuntoDeMinas),
    findall(F-C, ( between(1, Filas, F), between(1, Columnas, C) ), Todas),
    maplist(valor_inicial(Filas, Columnas, ConjuntoDeMinas), Todas, Valores),
    pairs_keys_values(Pares, Todas, Valores),
    list_to_assoc(Pares, Celdas).

%!  valor_inicial(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -Valor) is det.
%
%   Valor es mina si Celda está en Minas, o la cantidad de minas vecinas.
valor_inicial(Filas, Columnas, Minas, Celda, Valor) :-
    (   ord_memberchk(Celda, Minas)
    ->  Valor = mina
    ;   minas_vecinas(Filas, Columnas, Minas, Celda, Valor)
    ).

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  +Semilla:integer, -Tablero) is det.
%
%   Tablero tiene Cantidad minas en celdas elegidas al azar con Semilla.
%
%   @error type_error(positive_integer, X) si una dimensión o la cantidad
%          no es un entero positivo.
%   @error domain_error(cantidad_de_minas, Cantidad) si las minas no dejan
%          ninguna celda libre.
tablero_al_azar(Filas, Columnas, Cantidad, Semilla, Tablero) :-
    maplist(must_be(positive_integer), [Filas, Columnas, Cantidad]),
    must_be(integer, Semilla),
    Total is Filas * Columnas,
    (   Cantidad < Total
    ->  true
    ;   domain_error(cantidad_de_minas, Cantidad)
    ),
    set_random(seed(Semilla)),
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Minas),
    tablero(Filas, Columnas, Minas, Tablero).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

%!  valor(+Tablero, +Celda:pair, -Valor) is semidet.
%
%   Valor es lo que hay en Celda. Falla si Celda está fuera del tablero.
valor(tablero(_, _, Celdas), Celda, Valor) :-
    get_assoc(Celda, Celdas, Valor).

%!  cantidad_de_minas(+Tablero, -N:integer) is det.
%
%   N es la cantidad de minas de Tablero.
cantidad_de_minas(tablero(_, _, Celdas), N) :-
    assoc_to_values(Celdas, Valores),
    include(==(mina), Valores, Minas),
    length(Minas, N).
```

<!-- ejemplo: capitulo-31/buscaminas/tablero.plt -->
```prolog
:- begin_tests(tablero).

test(valores, true(V1-V2-V3 == mina-1-0)) :-
    tablero(3, 3, [1-1], T),
    valor(T, 1-1, V1),
    valor(T, 2-2, V2),
    valor(T, 3-3, V3).

test(fuera, fail) :-
    tablero(3, 3, [1-1], T),
    valor(T, 4-1, _).

% Con la semilla 42, las minas de un 5 x 5 con 4 son las del capítulo 28.
test(semilla, true(Minas == [2-3, 3-2, 3-4, 5-1])) :-
    tablero_al_azar(5, 5, 4, 42, T),
    T = tablero(_, _, Celdas),
    assoc_to_list(Celdas, Pares),
    findall(C, member(C-mina, Pares), Minas).

test(cantidad, true(N == 10)) :-
    tablero_al_azar(9, 9, 10, 7, T),
    cantidad_de_minas(T, N).

test(demasiadas_minas, error(domain_error(cantidad_de_minas, 4))) :-
    tablero_al_azar(2, 2, 4, 1, _).

test(dimension_invalida, error(type_error(positive_integer, 0))) :-
    tablero_al_azar(0, 2, 1, 1, _).

:- end_tests(tablero).
```

## descubrir

<!-- ejemplo: capitulo-31/buscaminas/descubrir.pl -->
```prolog
:- module(descubrir,
          [ descubrir/4
          ]).

:- use_module(library(ordsets)).
:- use_module(tablero).
:- use_module(vecinos).

%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list)
%!      is det.
%
%   Descubiertas es el conjunto ordenado Vistas más las celdas que descubre
%   un clic en Celda, una celda sin mina: la celda, y si no tiene minas
%   vecinas, las que descubren sus vecinas.
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
```

<!-- ejemplo: capitulo-31/buscaminas/descubrir.plt -->
```prolog
:- use_module(tablero).

:- begin_tests(descubrir).

% Un 3 x 3 con una mina en una esquina: la esquina opuesta descubre las ocho
% celdas libres.
test(region, true(N == 8)) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 3-3, [], D),
    length(D, N).

test(numero, true(D == [1-2])) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 1-2, [], D).

test(ya_descubierta, true(D == [1-2])) :-
    tablero(3, 3, [1-1], T),
    descubrir(T, 1-2, [1-2], D).

:- end_tests(descubrir).
```

## resolver

<!-- ejemplo: capitulo-31/buscaminas/resolver.pl -->
```prolog
:- module(resolver,
          [ deducir/3
          ]).

:- use_module(library(clpfd)).
:- use_module(vecinos).

%!  deducir(+Lineas:list(string), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas ocultas que no tienen mina en ninguna solución, y
%   Minas las que la tienen en todas. Si el tablero no tiene solución, las
%   dos son la lista vacía.
deducir(Lineas, Seguras, Minas) :-
    (   modelo(Lineas, Ocultas)
    ->  clasificar(Ocultas, Seguras, Minas)
    ;   Seguras = [],
        Minas = []
    ).

%!  modelo(+Lineas:list(string), -Ocultas:list(pair)) is semidet.
%
%   Ocultas son pares Celda-B, uno por celda oculta, con B en 0..1 y
%   restringido por los números de las celdas descubiertas. Falla si algún
%   número no se puede cumplir.
modelo(Lineas, Ocultas) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Cs),
              nth1(C, Cs, X) ),
            Celdas),
    findall(Celda-_, ( member(Celda-X, Celdas), oculta(X) ), Ocultas),
    pairs_values(Ocultas, Bs),
    Bs ins 0..1,
    findall(Celda-N, ( member(Celda-X, Celdas), numero(X, N) ), Numeros),
    maplist(restringir(Filas, Columnas, Ocultas), Numeros).

%!  oculta(+Simbolo:atom) is semidet.
%
%   Simbolo es el de una celda oculta: sin marcar o marcada.
oculta('#').
oculta('M').

%!  numero(+Simbolo:atom, -N:integer) is semidet.
%
%   N es la cantidad de minas vecinas que muestra Simbolo; . es 0.
numero('.', 0) :-
    !.
numero(Simbolo, N) :-
    atom_number(Simbolo, N).

%!  restringir(+Filas, +Columnas, +Ocultas:list(pair), +Numero:pair)
%!      is semidet.
%
%   Numero es Celda-N: las celdas ocultas vecinas de Celda suman N minas.
restringir(Filas, Columnas, Ocultas, Celda-N) :-
    findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
    convlist(variable_de(Ocultas), Vecinas, Bs),
    sum(Bs, #=, N).

%!  variable_de(+Ocultas:list(pair), +Celda:pair, -B) is semidet.
%
%   B es la variable de Celda en Ocultas. Falla si Celda no está oculta.
variable_de(Ocultas, Celda, B) :-
    memberchk(Celda-B, Ocultas).

%!  clasificar(+Ocultas:list(pair), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas que no pueden tener mina, y Minas las que no
%   pueden no tenerla, según las restricciones de Ocultas.
clasificar(Ocultas, Seguras, Minas) :-
    pairs_values(Ocultas, Bs),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 1, label(Bs) ) ), Seguras),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 0, label(Bs) ) ), Minas).
```

<!-- ejemplo: capitulo-31/buscaminas/resolver.plt -->
```prolog
:- begin_tests(resolver).

test(una_segura, true(S-M == [3-2]-[])) :-
    deducir(["#1..", "#211", "####", "####"], S, M).

test(una_mina, true(S-M == []-[1-1])) :-
    deducir(["#1", "11"], S, M).

% Una celda marcada se trata como oculta.
test(marcada, true(M == [1-1])) :-
    deducir(["M1", "11"], _, M).

% Un tablero cuyos números no se pueden cumplir: nada se deduce.
test(inconsistente, true(S-M == []-[])) :-
    deducir(["##1#", "1211", "...."], S, M).

:- end_tests(resolver).
```

## partida

<!-- ejemplo: capitulo-31/buscaminas/partida.pl -->
```prolog
:- module(partida,
          [ nueva_partida/5,
            partida_con_minas/4,
            jugar/4,
            estado/2,
            dimensiones/3,
            minas_restantes/2,
            filas/3,
            sugerencia/2
          ]).

:- use_module(library(ordsets)).
:- use_module(library(error)).
:- use_module(tablero).
:- use_module(descubrir).
:- use_module(resolver).

%!  nueva_partida(+Filas:integer, +Columnas:integer, +Minas:integer,
%!                +Semilla:integer, -Partida) is det.
%
%   Partida empieza con Minas minas al azar, elegidas con Semilla.
%
%   @error los de tablero_al_azar/5.
nueva_partida(Filas, Columnas, Minas, Semilla,
              partida(Tablero, [], [], sigue)) :-
    tablero_al_azar(Filas, Columnas, Minas, Semilla, Tablero).

%!  partida_con_minas(+Filas:integer, +Columnas:integer, +Minas:list,
%!                    -Partida) is det.
%
%   Partida empieza con minas en las celdas de Minas: para las pruebas.
partida_con_minas(Filas, Columnas, Minas, partida(Tablero, [], [], sigue)) :-
    tablero(Filas, Columnas, Minas, Tablero).

%!  jugar(+Accion:atom, +Celda:pair, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de Accion, descubrir o marcar, en Celda.
%   Marcar una celda marcada le quita la marca.
%
%   @error domain_error(accion, Accion) si no es descubrir ni marcar.
%   @error domain_error(partida_en_curso, Estado) si la partida terminó.
%   @error domain_error(celda_del_tablero, Celda) si la celda no existe.
jugar(Accion, Celda, partida(T, D0, M0, Estado0), Partida) :-
    (   memberchk(Accion, [descubrir, marcar])
    ->  true
    ;   domain_error(accion, Accion)
    ),
    (   Estado0 == sigue
    ->  true
    ;   domain_error(partida_en_curso, Estado0)
    ),
    (   valor(T, Celda, Valor)
    ->  true
    ;   domain_error(celda_del_tablero, Celda)
    ),
    aplicar(Accion, Celda, Valor, partida(T, D0, M0, Estado0), Partida).

%!  aplicar(+Accion, +Celda, +Valor, +Partida0, -Partida) is det.
%
%   Aplica una jugada válida.
aplicar(descubrir, Celda, mina, partida(T, D0, M, _), partida(T, D, M, perdio)) :-
    !,
    ord_add_element(D0, Celda, D).
aplicar(descubrir, Celda, _, partida(T, D0, M, _), partida(T, D, M, Estado)) :-
    descubrir(T, Celda, D0, D),
    T = tablero(Filas, Columnas, _),
    cantidad_de_minas(T, Minas),
    length(D, Descubiertas),
    (   Descubiertas =:= Filas * Columnas - Minas
    ->  Estado = gano
    ;   Estado = sigue
    ).
aplicar(marcar, Celda, _, partida(T, D, M0, E), partida(T, D, M, E)) :-
    (   ord_memberchk(Celda, M0)
    ->  ord_del_element(M0, Celda, M)
    ;   ord_add_element(M0, Celda, M)
    ).

%!  estado(+Partida, -Estado:atom) is det.
%
%   Estado es sigue, gano o perdio.
estado(partida(_, _, _, Estado), Estado).

%!  dimensiones(+Partida, -Filas:integer, -Columnas:integer) is det.
%
%   Filas y Columnas son las dimensiones del tablero de Partida.
dimensiones(partida(tablero(Filas, Columnas, _), _, _, _), Filas, Columnas).

%!  minas_restantes(+Partida, -N:integer) is det.
%
%   N es la cantidad de minas menos la de celdas marcadas.
minas_restantes(partida(T, _, M, _), N) :-
    cantidad_de_minas(T, Minas),
    length(M, Marcadas),
    N is Minas - Marcadas.

%!  filas(+Partida, +Minas:boolean, -Filas:list(string)) is det.
%
%   Filas son las filas del tablero, un carácter por celda: el número de
%   minas vecinas en las descubiertas, . si es cero, M en las marcadas y #
%   en las demás. Con Minas en true, las minas se muestran con *.
filas(partida(tablero(Filas, Columnas, Celdas), D, M, _), Minas, Textos) :-
    findall(Texto,
            ( between(1, Filas, F),
              findall(S,
                      ( between(1, Columnas, C),
                        get_assoc(F-C, Celdas, V),
                        simbolo(F-C, V, D, M, Minas, S) ),
                      Simbolos),
              atomic_list_concat(Simbolos, Atomo),
              atom_string(Atomo, Texto) ),
            Textos).

%!  simbolo(+Celda, +Valor, +Descubiertas, +Marcadas, +Minas:boolean,
%!          -Simbolo) is det.
%
%   Simbolo es el carácter con que se muestra Celda.
simbolo(Celda, Valor, D, M, Minas, Simbolo) :-
    (   ord_memberchk(Celda, D)
    ->  visible(Valor, Simbolo)
    ;   Minas == true, Valor == mina
    ->  Simbolo = '*'
    ;   ord_memberchk(Celda, M)
    ->  Simbolo = 'M'
    ;   Simbolo = '#'
    ).

%!  visible(+Valor, -Simbolo) is det.
%
%   Simbolo muestra el Valor de una celda descubierta.
visible(mina, '*') :-
    !.
visible(0, '.') :-
    !.
visible(N, N).

%!  sugerencia(+Partida, -Celda:pair) is semidet.
%
%   Celda es una celda oculta sin marcar que, según lo que se ve del
%   tablero, no puede tener una mina. Falla si no hay ninguna segura.
sugerencia(Partida, Celda) :-
    filas(Partida, false, Filas),
    deducir(Filas, Seguras, _),
    Partida = partida(_, _, Marcadas, sigue),
    member(Celda, Seguras),
    \+ ord_memberchk(Celda, Marcadas),
    !.
```

<!-- ejemplo: capitulo-31/buscaminas/partida.plt -->
```prolog
:- begin_tests(partida).

test(ganar, true(E-F == gano-["*1.", "11.", "..."])) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 3-3, P0, P),
    estado(P, E),
    filas(P, true, F).

test(perder, true(E == perdio)) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 1-1, P0, P),
    estado(P, E).

test(marcar, true(F-N == ["M##", "###", "###"]-0)) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(marcar, 1-1, P0, P),
    filas(P, false, F),
    minas_restantes(P, N).

test(desmarcar, true(F == ["###", "###", "###"])) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(marcar, 1-1, P0, P1),
    jugar(marcar, 1-1, P1, P),
    filas(P, false, F).

test(fuera, error(domain_error(celda_del_tablero, 4-1))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 4-1, P0, _).

test(terminada, error(domain_error(partida_en_curso, perdio))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 1-1, P0, P1),
    jugar(descubrir, 2-2, P1, _).

test(accion, error(domain_error(accion, saltar))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(saltar, 1-1, P0, _).

test(sugerencia, true(S == 3-2)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P0),
    jugar(descubrir, 1-4, P0, P),
    sugerencia(P, S).

test(sin_sugerencia, fail) :-
    partida_con_minas(3, 3, [1-1], P),
    sugerencia(P, _).

:- end_tests(partida).
```

## terminal

<!-- ejemplo: capitulo-31/buscaminas/terminal.pl -->
```prolog
:- module(terminal,
          [ jugar_en_terminal/3,
            mostrar/2,
            jugada//1
          ]).

:- use_module(library(readutil)).
:- use_module(library(dcg/basics)).
:- use_module(partida).

%!  jugar_en_terminal(+In, +Partida0, -Estado:atom) is det.
%
%   Muestra Partida0, lee jugadas de In y las aplica hasta que la partida
%   termina. Estado es gano o perdio.
%
%   @error existence_error(jugada, fin_de_la_entrada) si In se termina antes.
jugar_en_terminal(In, Partida0, Estado) :-
    estado(Partida0, Estado0),
    (   Estado0 == sigue
    ->  mostrar(Partida0, false),
        leer_jugada(In, Jugada),
        responder(Jugada, Partida0, Partida),
        jugar_en_terminal(In, Partida, Estado)
    ;   mostrar(Partida0, true),
        mensaje_final(Estado0),
        Estado = Estado0
    ).

%!  leer_jugada(+In, -Jugada) is det.
%
%   Jugada es la jugada de la línea siguiente de In, o no_valida.
leer_jugada(In, Jugada) :-
    format("Jugada (d F C, m F C, ?): "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  existence_error(jugada, fin_de_la_entrada)
    ;   string_codes(Linea, Codigos),
        (   phrase(jugada(J), Codigos)
        ->  Jugada = J
        ;   Jugada = no_valida
        )
    ).

%!  jugada(-Jugada)// is semidet.
%
%   Una jugada: d F C, m F C o ?.
jugada(Jugada) -->
    blanks,
    orden(Accion),
    blanks,
    integer(F),
    blanks,
    integer(C),
    blanks,
    { Jugada = jugar(Accion, F-C) }.
jugada(sugerencia) -->
    blanks,
    "?",
    blanks.

%!  orden(-Accion:atom)// is semidet.
%
%   La letra de una acción.
orden(descubrir) --> "d".
orden(marcar) --> "m".

%!  responder(+Jugada, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de Jugada; una jugada imposible se informa
%   y deja la partida como estaba.
responder(no_valida, Partida, Partida) :-
    format("Jugada no válida.~n").
responder(sugerencia, Partida, Partida) :-
    (   sugerencia(Partida, F-C)
    ->  format("Sugerencia: d ~w ~w~n", [F, C])
    ;   format("No hay ninguna celda segura a la vista.~n")
    ).
responder(jugar(Accion, Celda), Partida0, Partida) :-
    catch(jugar(Accion, Celda, Partida0, Partida),
          error(domain_error(celda_del_tablero, _), _),
          ( format("La celda está fuera del tablero.~n"),
            Partida = Partida0 )).

%!  mensaje_final(+Estado:atom) is det.
%
%   Escribe el resultado de la partida.
mensaje_final(gano) :-
    format("Todas las celdas libres están descubiertas: partida ganada.~n").
mensaje_final(perdio) :-
    format("La celda tenía una mina: partida perdida.~n").

%!  mostrar(+Partida, +Minas:boolean) is det.
%
%   Escribe el tablero con los números de fila y de columna, y las minas que
%   quedan por marcar.
mostrar(Partida, Minas) :-
    dimensiones(Partida, _, Columnas),
    numlist(1, Columnas, Numeros),
    fila_de_texto('', Numeros, Encabezado),
    writeln(Encabezado),
    filas(Partida, Minas, Filas),
    forall(nth1(F, Filas, Fila),
           ( string_chars(Fila, Simbolos),
             fila_de_texto(F, Simbolos, Texto),
             writeln(Texto) )),
    minas_restantes(Partida, Restantes),
    format("Minas sin marcar: ~d~n", [Restantes]).

%!  fila_de_texto(+Rotulo, +Simbolos:list, -Fila:atom) is det.
%
%   Fila es Rotulo seguido de Simbolos, cada uno en tres columnas.
fila_de_texto(Rotulo, Simbolos, Fila) :-
    maplist([S, A]>>format(atom(A), "~t~w~3|", [S]), [Rotulo|Simbolos],
            Columnas),
    atomic_list_concat(Columnas, Fila).
```

<!-- ejemplo: capitulo-31/buscaminas/terminal.plt -->
```prolog
:- use_module(partida).

:- begin_tests(terminal).

%!  jugar_con(+Partida, +Jugadas:string, -Estado, -Lineas:list(string)) is det.
%
%   Juega Partida leyendo Jugadas; Lineas es lo que escribió.
jugar_con(Partida, Jugadas, Estado, Lineas) :-
    setup_call_cleanup(
        open_string(Jugadas, In),
        with_output_to(string(S), jugar_en_terminal(In, Partida, Estado)),
        close(In)),
    split_string(S, "\n", "", Lineas).

test(jugadas, true(J == [jugar(descubrir, 3-4), jugar(marcar, 10-2),
                         sugerencia])) :-
    maplist([T, X]>>( string_codes(T, Cs), once(phrase(jugada(X), Cs)) ),
            ["d 3 4", " m 10 2 ", "?"], J).

test(ganar, true(E == gano)) :-
    partida_con_minas(3, 3, [1-1], P),
    jugar_con(P, "d 3 3\n", E, _).

% Una jugada que no se entiende, una fuera del tablero y una sugerencia no
% terminan la partida.
test(perder, true(E == perdio)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P),
    jugar_con(P, "hola\nd 1 4\n?\nd 9 9\nd 1 1\n", E, Lineas),
    once(( member(L, Lineas), sub_string(L, _, _, _, "no válida") )),
    once(( member(L2, Lineas), sub_string(L2, _, _, _, "Sugerencia: d 3 2") )),
    once(( member(L3, Lineas), sub_string(L3, _, _, _, "fuera del tablero") )).

test(fin_de_la_entrada, error(existence_error(jugada, fin_de_la_entrada))) :-
    partida_con_minas(3, 3, [1-1], P),
    jugar_con(P, "", _, _).

:- end_tests(terminal).
```

## servicio

<!-- ejemplo: capitulo-31/buscaminas/servicio.pl -->
```prolog
:- module(servicio,
          [ iniciar_servicio/2,
            detener_servicio/1
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(partida).

:- meta_predicate responder(0).

:- dynamic partida_guardada/2, ultima_partida/1.

% ultima_partida(N): el número de la última partida creada.
ultima_partida(0).

:- http_handler(root(partidas), partidas, [prefix, methods([get, post])]).

%!  iniciar_servicio(?Puerto:integer, +Alcance:atom) is det.
%
%   Arranca el servicio en Puerto, o en uno libre. Con Alcance local, solo
%   acepta pedidos de la misma máquina; con publico, de cualquier interfaz.
iniciar_servicio(Puerto, local) :-
    http_server([port(localhost:Puerto)]).
iniciar_servicio(Puerto, publico) :-
    http_server([port(Puerto)]).

%!  detener_servicio(+Puerto:integer) is det.
%
%   Detiene el servicio de Puerto.
detener_servicio(Puerto) :-
    http_stop_server(Puerto, []).

%!  partidas(+Pedido) is det.
%
%   Atiende las rutas que empiezan con /partidas: elige por el método y por
%   las partes del resto de la dirección.
partidas(Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   memberchk(path_info(Resto), Pedido)
    ->  true
    ;   Resto = ''
    ),
    split_string(Resto, "/", "", Partes0),
    exclude(==(""), Partes0, Partes),
    responder(ruta(Metodo, Partes, Pedido)).

%!  ruta(+Metodo:atom, +Partes:list(string), +Pedido) is det.
%
%   Atiende un pedido ya separado en partes.
%
%   @error existence_error(ruta, Partes) si no es ninguna de las rutas.
ruta(post, [], Pedido) :-
    !,
    http_read_json_dict(Pedido, Datos),
    _{filas: F, columnas: C, minas: N, semilla: S} :< Datos,
    nueva_partida(F, C, N, S, Partida),
    with_mutex(partidas, guardar_nueva(Partida, Id)),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta, [status(201)]).
ruta(get, [Texto], _) :-
    !,
    partida_de(Texto, Id, Partida),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta).
ruta(get, [Texto, "sugerencia"], _) :-
    !,
    partida_de(Texto, _, Partida),
    (   sugerencia(Partida, F-C)
    ->  reply_json_dict(_{fila: F, columna: C})
    ;   existence_error(celda_segura, Texto)
    ).
ruta(post, [Texto, Nombre], Pedido) :-
    !,
    atom_string(Accion, Nombre),
    http_read_json_dict(Pedido, Datos),
    _{fila: F, columna: C} :< Datos,
    with_mutex(partidas, jugada(Texto, Accion, F-C, Id, Partida)),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta).
ruta(_, Partes, _) :-
    existence_error(ruta, Partes).

%!  guardar_nueva(+Partida, -Id:integer) is det.
%
%   Guarda Partida con un número nuevo, Id.
guardar_nueva(Partida, Id) :-
    retract(ultima_partida(Anterior)),
    Id is Anterior + 1,
    assertz(ultima_partida(Id)),
    assertz(partida_guardada(Id, Partida)).

%!  jugada(+Texto, +Accion:atom, +Celda:pair, -Id:integer, -Partida) is det.
%
%   Aplica la jugada a la partida de número Texto y guarda la siguiente.
jugada(Texto, Accion, Celda, Id, Partida) :-
    partida_de(Texto, Id, Partida0),
    jugar(Accion, Celda, Partida0, Partida),
    retract(partida_guardada(Id, _)),
    assertz(partida_guardada(Id, Partida)).

%!  partida_de(+Texto:string, -Id:integer, -Partida) is det.
%
%   Partida es la partida guardada con el número Texto.
%
%   @error existence_error(partida, Texto) si no existe.
partida_de(Texto, Id, Partida) :-
    (   number_string(Id, Texto),
        partida_guardada(Id, Partida)
    ->  true
    ;   existence_error(partida, Texto)
    ).

%!  respuesta(+Id:integer, +Partida, -Respuesta:dict) is det.
%
%   Respuesta tiene el número, las dimensiones, el estado, las minas sin
%   marcar y el tablero de Partida, con las minas a la vista si terminó.
respuesta(Id, Partida, _{id: Id, filas: F, columnas: C, estado: Estado,
                         minas_restantes: Restantes, tablero: Filas}) :-
    dimensiones(Partida, F, C),
    estado(Partida, Estado),
    minas_restantes(Partida, Restantes),
    (   Estado == sigue
    ->  Minas = false
    ;   Minas = true
    ),
    filas(Partida, Minas, Filas).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido. Un error de tipo o de dominio
%   responde 400, salvo una acción desconocida, que es una ruta inexistente;
%   uno de existencia, 404; si Objetivo falla, como cuando al cuerpo le
%   falta un campo, 400.
responder(Objetivo) :-
    catch(( Objetivo
          ->  true
          ;   reply_json_dict(_{error: "pedido incompleto"}, [status(400)])
          ),
          error(Formal, _),
          responder_error(Formal)).

%!  responder_error(+Formal) is det.
%
%   Responde el error Formal con su código de estado.
responder_error(Formal) :-
    codigo_de_error(Formal, Codigo),
    !,
    format(string(Texto), "~w", [Formal]),
    reply_json_dict(_{error: Texto}, [status(Codigo)]).
responder_error(Formal) :-
    throw(error(Formal, _)).

%!  codigo_de_error(+Formal, -Codigo:integer) is semidet.
%
%   Codigo es el código de estado de HTTP del error Formal.
codigo_de_error(domain_error(accion, _), 404) :-
    !.
codigo_de_error(type_error(_, _), 400).
codigo_de_error(domain_error(_, _), 400).
codigo_de_error(syntax_error(_), 400).
codigo_de_error(existence_error(_, _), 404).
```

<!-- ejemplo: capitulo-31/buscaminas/servicio.plt -->
```prolog
:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servicio en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_servicio(Puerto, local),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servicio de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_servicio(Puerto).

%!  url(+Ruta:atom, -Url:atom) is det.
%
%   Url es la dirección de Ruta en el servicio de las pruebas.
url(Ruta, Url) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]).

%!  enviar(+Ruta:atom, +Cuerpo:dict, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace POST a Ruta con Cuerpo como JSON.
enviar(Ruta, Cuerpo, Codigo, Respuesta) :-
    url(Ruta, Url),
    http_post(Url, json(Cuerpo), Respuesta,
              [ status_code(Codigo), json_object(dict),
                request_header('Accept'='application/json') ]).

%!  obtener(+Ruta:atom, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace GET a Ruta y lee la respuesta como JSON.
obtener(Ruta, Codigo, Respuesta) :-
    url(Ruta, Url),
    setup_call_cleanup(
        http_open(Url, Stream, [ status_code(Codigo),
                                 request_header('Accept'='application/json') ]),
        json_read_dict(Stream, Respuesta),
        close(Stream)).

%!  partida_nueva(+Datos:dict, -Ruta:atom) is det.
%
%   Crea una partida con Datos y da su ruta.
partida_nueva(Datos, Ruta) :-
    enviar('/partidas', Datos, 201, R),
    get_dict(id, R, Id),
    format(atom(Ruta), "/partidas/~w", [Id]).

:- begin_tests(servicio, [ setup(arrancar_para_pruebas),
                           cleanup(parar_despues_de_pruebas) ]).

% Con la semilla 42, las minas de un 5 x 5 con 4 son 2-3, 3-2, 3-4 y 5-1.
test(perder, true(E-T == "perdio"-["#####", "##*##", "#*#*#", "#####",
                                   "*####"])) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 2, columna: 3}, 200, R),
    get_dict(estado, R, E),
    get_dict(tablero, R, T).

test(consultar, true(C-N == 200-4)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    obtener(Ruta, C, R),
    get_dict(minas_restantes, R, N).

test(sin_sugerencia, true(C == 404)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/sugerencia', Sugerencia),
    obtener(Sugerencia, C, _).

test(accion_inexistente, true(C == 404)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/saltar', Saltar),
    enviar(Saltar, _{fila: 1, columna: 1}, C, _).

test(fuera_del_tablero, true(C == 400)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 9, columna: 9}, C, _).

test(partida_inexistente, true(C == 404)) :-
    obtener('/partidas/999', C, _).

test(demasiadas_minas, true(C == 400)) :-
    enviar('/partidas', _{filas: 2, columnas: 2, minas: 4, semilla: 1}, C, _).

:- end_tests(servicio).
```

## El programa

<!-- ejemplo: capitulo-31/buscaminas/buscaminas.pl -->
```prolog
:- use_module(library(main)).
:- use_module(partida).
:- use_module(terminal).
:- use_module(servicio).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(semilla,  semilla,  integer).
opt_type(servicio, servicio, boolean).
opt_type(puerto,   puerto,   nonneg).
opt_type(publico,  publico,  boolean).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(semilla,     "Semilla del azar: la misma semilla repite el tablero").
opt_help(servicio,    "Ofrece el juego por HTTP en lugar de jugar").
opt_help(puerto,      "Puerto del servicio; sin la opción, uno libre").
opt_help(publico,     "El servicio acepta pedidos de cualquier interfaz").
opt_help(help(usage), " [--semilla=N] filas columnas minas | --servicio").

%!  main(+Argv:list) is det.
%
%   Juega en la terminal o arranca el servicio, según los argumentos, y
%   termina con el código de salida del resultado: 0 si se gana, 1 si se
%   pierde, 2 ante un error.
main(Argv) :-
    argv_options(Argv, Posicionales, Opciones),
    catch(correr(Posicionales, Opciones, Codigo),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  correr(+Posicionales:list, +Opciones:list, -Codigo:integer) is det.
%
%   Hace lo que piden los argumentos.
%
%   @error uso(argumentos) si no son tres números ni --servicio.
correr(_, Opciones, 0) :-
    option(servicio(true), Opciones),
    !,
    option(puerto(Puerto), Opciones, _),
    (   option(publico(true), Opciones)
    ->  Alcance = publico
    ;   Alcance = local
    ),
    iniciar_servicio(Puerto, Alcance),
    format("Buscaminas en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
correr([F, C, M], Opciones, Codigo) :-
    !,
    maplist(numero, [F, C, M], [Filas, Columnas, Minas]),
    option(semilla(Semilla), Opciones, 0),
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    prompt(_, ''),
    jugar_en_terminal(user_input, Partida, Estado),
    (   Estado == gano
    ->  Codigo = 0
    ;   Codigo = 1
    ).
correr(_, _, _) :-
    throw(uso(argumentos)).

%!  numero(+Argumento:atom, -N:integer) is det.
%
%   N es el entero que escribe Argumento.
%
%   @error type_error(integer, Argumento) si no es un entero.
numero(Argumento, N) :-
    (   atom_number(Argumento, N),
        integer(N)
    ->  true
    ;   type_error(integer, Argumento)
    ).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El mensaje de uso.
prolog:message(uso(argumentos)) -->
    [ 'Uso: swipl buscaminas.pl [--semilla=N] filas columnas minas',
      nl, '     swipl buscaminas.pl --servicio [--puerto=P] [--publico]' ].
```

<!-- ejemplo: capitulo-31/buscaminas/buscaminas.plt -->
```prolog
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

:- begin_tests(buscaminas).

%!  jugar_programa(+Argumentos:list, +Jugadas:string, -Estado) is det.
%
%   Ejecuta buscaminas.pl con Argumentos y Jugadas como teclado; Estado es
%   exit(Codigo).
jugar_programa(Argumentos, Jugadas, Estado) :-
    source_file(user:correr(_, _, _), Programa),
    process_create(path(swipl), [Programa|Argumentos],
                   [ stdin(pipe(In)), stdout(null), stderr(null),
                     process(Pid) ]),
    format(In, "~s", [Jugadas]),
    close(In),
    process_wait(Pid, Estado).

% Con la semilla 42, la mina de un 2 x 2 con 1 está en 1-1.
test(ganar, true(E == exit(0))) :-
    jugar_programa(['--semilla=42', '2', '2', '1'], "d 1 2\nd 2 1\nd 2 2\n", E).

test(perder, true(E == exit(1))) :-
    jugar_programa(['--semilla=42', '2', '2', '1'], "d 1 1\n", E).

test(uso, true(E == exit(2))) :-
    jugar_programa(['2', '2'], "", E).

test(demasiadas_minas, true(E == exit(2))) :-
    jugar_programa(['2', '2', '9'], "", E).

% El programa como servicio: arranca, escribe su dirección, y responde.
test(servicio, true(C == 201)) :-
    source_file(user:correr(_, _, _), Programa),
    setup_call_cleanup(
        process_create(path(swipl), ['-q', Programa, '--servicio'],
                       [stdout(pipe(Out)), process(Pid)]),
        ( read_line_to_string(Out, Linea),
          split_string(Linea, " ", "/", Palabras),
          last(Palabras, Direccion),
          atom_concat(Direccion, '/partidas', Url),
          http_post(Url, json(_{filas: 3, columnas: 3, minas: 1, semilla: 1}),
                    _, [status_code(C)]) ),
        ( process_kill(Pid),
          process_wait(Pid, _),
          close(Out) )).

:- end_tests(buscaminas).
```

## El cliente de Python

<!-- ejemplo: capitulo-31/buscaminas/cliente.py -->
```python
"""Capítulo 31 - Buscaminas completo: un cliente de Python del servicio.

Juega contra buscaminas.pl --servicio con urllib, de la biblioteca estándar:
del lado de Python no hace falta SWI-Prolog. Es el adaptador HTTP del
capítulo 30, con la sugerencia que agrega el servicio completo.
"""

import json
import urllib.error
import urllib.request


def _pedir(url, datos=None):
    """Hace un pedido GET, o POST si hay datos; devuelve el código y el JSON."""
    cuerpo = None if datos is None else json.dumps(datos).encode('utf-8')
    pedido = urllib.request.Request(url, data=cuerpo, headers={'Content-Type': 'application/json'})  # noqa: S310
    try:
        with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
            return respuesta.status, json.load(respuesta)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


class Partida:
    """Una partida que vive en el servicio de la dirección base."""

    def __init__(self, base, filas, columnas, minas, semilla=0):
        """Crea la partida en el servicio."""
        datos = {'filas': filas, 'columnas': columnas, 'minas': minas, 'semilla': semilla}
        codigo, cuerpo = _pedir(f'{base}/partidas', datos)
        if codigo != 201:
            raise ValueError(cuerpo['error'])
        self._url = f'{base}/partidas/{cuerpo["id"]}'
        self._actualizar(cuerpo)

    def _actualizar(self, cuerpo):
        """Toma el estado, las minas sin marcar y el tablero de una respuesta."""
        self.estado = cuerpo['estado']
        self.minas_restantes = cuerpo['minas_restantes']
        self.tablero = cuerpo['tablero']

    def _jugar(self, accion, fila, columna):
        """Envía la jugada; una respuesta que no es 200 es un error."""
        codigo, cuerpo = _pedir(f'{self._url}/{accion}', {'fila': fila, 'columna': columna})
        if codigo != 200:
            raise ValueError(cuerpo['error'])
        self._actualizar(cuerpo)

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def sugerencia(self):
        """Devuelve una celda segura (fila, columna), o None si no hay ninguna a la vista."""
        codigo, cuerpo = _pedir(f'{self._url}/sugerencia')
        return (cuerpo['fila'], cuerpo['columna']) if codigo == 200 else None
```

<!-- ejemplo: capitulo-31/buscaminas/test_cliente.py -->
```python
"""Pruebas de cliente.py, contra buscaminas.pl --servicio ejecutado como programa."""

import re
import shutil
import subprocess
from pathlib import Path

import cliente
import pytest

AQUI = Path(__file__).parent


@pytest.fixture(scope='module')
def base():
    """Arranca el programa como servicio y devuelve su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'buscaminas.pl', '--servicio'], cwd=AQUI, stdout=subprocess.PIPE, text=True
    )
    try:
        puerto = re.search(r'localhost:(\d+)', proceso.stdout.readline()).group(1)
        yield f'http://127.0.0.1:{puerto}'
    finally:
        proceso.kill()
        proceso.wait()


# Con la semilla 42, las minas de un 5 x 5 con 4 son 2-3, 3-2, 3-4 y 5-1.
def test_perder(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    assert partida.tablero == ['#####'] * 5
    partida.descubrir(2, 3)
    assert partida.estado == 'perdio'
    assert partida.tablero == ['#####', '##*##', '#*#*#', '#####', '*####']


def test_ganar(base):
    # Con la semilla 42, la mina de un 2 x 2 con 1 está en 1-1.
    partida = cliente.Partida(base, 2, 2, 1, semilla=42)
    for fila, columna in [(1, 2), (2, 1), (2, 2)]:
        partida.descubrir(fila, columna)
    assert partida.estado == 'gano'


def test_marcar(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    partida.marcar(2, 3)
    assert partida.minas_restantes == 3
    assert partida.tablero[1] == '##M##'


def test_sin_sugerencia(base):
    assert cliente.Partida(base, 5, 5, 4, semilla=42).sugerencia() is None


def test_error(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    with pytest.raises(ValueError, match='celda_del_tablero'):
        partida.descubrir(9, 9)
    with pytest.raises(ValueError, match='cantidad_de_minas'):
        cliente.Partida(base, 2, 2, 4)
```
