# Soluciones del capítulo 66 — Proyecto: evidencia y árboles de decisión

Las soluciones de los ejercicios 2 a 12 están en
`ejemplos/capitulo-66/soluciones.pl`, que carga las versiones del proyecto
(`cotas.pl` y `compilado.pl`, que cargan las demás) y agrega dos métodos de
combinación con cláusulas `multifile` de `evidencia`. Sus pruebas están en
`soluciones.plt`. La del ejercicio 13 está en `soluciones_certeza.pl`, que
carga `certeza.pl`, y la del 14, en `soluciones_id3.pl`, que carga
`id3.pl`; cada una tiene sus pruebas en el `.plt` del mismo nombre.

## Ejercicio 1

Con `proyecto.pl` cargado; `grado/4` está en `evidencia.pl`, `colapsada/2`
en `colapsar.pl` y `consulta/4` en `arbol.pl`:

<!-- ejemplo: capitulo-66/proyecto.pl archivo -->
```prolog
:- use_module(cotas).
:- use_module(compilado).
```

```prolog
?- member(M, [independiente, conservador, liberal]), grado(ave, [tiene_plumas-0.5, vuela-0.8, pone_huevos-0.8], M, P).
M = independiente,
P = 0.724 ;
M = conservador,
P = 0.5 ;
M = liberal,
P = 1.0.
```

Ave tiene dos reglas. Con la independencia, r3 aporta
$1{,}0 \cdot 0{,}5 = 0{,}5$ y r4 aporta $0{,}7 \cdot 0{,}8 \cdot 0{,}8 =
0{,}448$; la disyunción da $1 - 0{,}5 \cdot 0{,}552 = 0{,}724$. Con el
método conservador, r3 aporta $\max(0, 1 + 0{,}5 - 1) = 0{,}5$ y r4
$\max(0, 0{,}7 + 0{,}8 + 0{,}8 - 2) = 0{,}3$; la disyunción se queda con el
mayor, 0,5. Con el liberal, r3 aporta 0,5 y r4 el mínimo, 0,7; la suma
pasa de 1 y queda en 1,0.

```prolog
?- colapsada(pinguino, Ps).
Ps = [tiene_plumas, no_vuela, nada] ;
Ps = [vuela, pone_huevos, no_vuela, nada] ;
false.

?- consulta(frecuente, [tiene_plumas, no_vuela, nada], H, Ps).
H = pinguino,
Ps = [tiene_pelo, da_leche, no_vuela, tiene_plumas, nada].
```

La segunda regla colapsada del pingüino pide `vuela` y `no_vuela` a la
vez: la base de reglas no declara que se excluyen, y el colapso lo deja a la
vista (el ejercicio 7 lo aprovecha). El árbol `frecuente` pregunta primero
`tiene_pelo` y `da_leche`: están en cuatro reglas cada una, empatadas con
otras preguntas, y aparecen primero. Con dos respuestas negativas quedan
las cuatro reglas de aves, y `no_vuela`, que está en las cuatro, va antes
que `tiene_plumas`, que está en dos.

## Ejercicio 2

<!-- ejemplo: capitulo-66/soluciones.pl predicado: atenuacion/2 con_grado/3 -->
```prolog
%!  atenuacion(+G:float, -Filas:list) is det.
%
%   Filas tiene, para mamifero, carnivoro y guepardo, un término
%   Meta-[I, C, L]: su grado con los métodos independiente, conservador y
%   liberal cuando las cuatro observaciones del caso 1 tienen grado G.
atenuacion(G, Filas) :-
    caso(1, Os),
    maplist(con_grado(G), Os, Gs),
    findall(Meta-Ps,
            ( member(Meta, [mamifero, carnivoro, guepardo]),
              findall(P, ( member(M, [independiente, conservador,
                                      liberal]),
                           grado(Meta, Gs, M, P) ),
                      Ps) ),
            Filas).

%!  con_grado(+G:float, ?Hecho, ?Par) is det.
%
%   Par es Hecho con grado G.
con_grado(G, Hecho, Hecho-G).
```

```prolog
?- atenuacion(1.0, F).
F = [mamifero-[0.9, 0.9, 0.9], carnivoro-[0.72, 0.7, 0.8], guepardo-[0.612, 0.55, 0.8]].

?- atenuacion(0.9, F).
F = [mamifero-[0.81, 0.8, 0.9], carnivoro-[0.5832, 0.5, 0.8], guepardo-[0.4015, 0.15, 0.8]].

?- atenuacion(0.7, F).
F = [mamifero-[0.63, 0.6, 0.7], carnivoro-[0.3528, 0.1, 0.7], guepardo-[0.1469, 0.0, 0.7]].
```

| G | independiente | conservador | liberal |
|---|---|---|---|
| 1,0 | 0,9; 0,72; 0,612 | 0,9; 0,7; 0,55 | 0,9; 0,8; 0,8 |
| 0,9 | 0,81; 0,5832; 0,4015 | 0,8; 0,5; 0,15 | 0,9; 0,8; 0,8 |
| 0,7 | 0,63; 0,3528; 0,1469 | 0,6; 0,1; 0,0 | 0,7; 0,7; 0,7 |

Cada fila da mamífero, carnívoro y guepardo, un nivel más arriba cada uno.
La conjunción independiente multiplica: guepardo es el producto de tres
fuerzas y de cuatro grados, $0{,}612\,G^4$, así que la cadena lo reduce aun
con $G = 1$. La conservadora suma los grados y resta uno por cada
conjunción: cada condición de grado $G$ quita $1 - G$ y cada fuerza $f$
quita $1 - f$; con $G = 0{,}7$ la suma de lo que se quita pasa de 1 en la
tercera regla. La liberal es el mínimo de todos los números de la cadena:
no depende de su longitud, y con $G = 1$ es la menor fuerza, 0,8 de r5.

## Ejercicio 3

<!-- ejemplo: capitulo-66/soluciones.pl fragmento: evidencia:metodo(mycin). .. evidencia:o(conservador, P1, P2, P). -->
```prolog
evidencia:metodo(mycin).
evidencia:metodo(conman).

% MYCIN, según Merritt, y CONMAN, según Covington: y toma el mínimo; o
% acumula como la independencia en MYCIN y toma el máximo en CONMAN.
evidencia:y(mycin, P1, P2, P) :-
    evidencia:y(liberal, P1, P2, P).
evidencia:y(conman, P1, P2, P) :-
    evidencia:y(liberal, P1, P2, P).
evidencia:o(mycin, P1, P2, P) :-
    evidencia:o(independiente, P1, P2, P).
evidencia:o(conman, P1, P2, P) :-
    evidencia:o(conservador, P1, P2, P).
```

```prolog
?- member(M, [mycin, conman]), grado(mamifero, [tiene_pelo-0.6, da_leche-0.6], M, P).
M = mycin,
P = 0.84 ;
M = conman,
P = 0.6.
```

Con el mínimo, cada regla aporta el menor entre su fuerza y el grado de su
condición: 0,6 las dos, porque las fuerzas son mayores. MYCIN las acumula como la independencia,
$1 - 0{,}4 \cdot 0{,}4 = 0{,}84$; CONMAN se queda con la mejor, 0,6. Los
dos quedan entre 0,55 y 1,0, las cotas de la
[sección 66.3](index.md#663-version-2-cotas-conservadora-y-liberal): cada
uno combina una conjunción y una disyunción que están entre las
conservadoras y las liberales, y la composición conserva el orden. La
prueba `shells_entre_cotas` lo verifica para guepardo con tres grados.

## Ejercicio 4

<!-- ejemplo: capitulo-66/soluciones.pl predicado: y_no/4 -->
```prolog
%!  y_no(+Metodo, +PA:float, +PB:float, -P:float) is det.
%
%   P es el grado de «A y no B» cuando A tiene grado PA y B grado PB: el
%   grado de no B es 1 - PB. P tiene cuatro decimales.
y_no(Metodo, PA, PB, P) :-
    PNoB is 1 - PB,
    y(Metodo, PA, PNoB, P0),
    P is round(P0 * 10000) / 10000.0.
```

```prolog
?- member(M, [independiente, conservador, liberal]), y_no(M, 0.9, 0.2, P).
M = independiente,
P = 0.72 ;
M = conservador,
P = 0.7 ;
M = liberal,
P = 0.8.
```

Con `\+ b`, una evidencia de B de 0,2 hace que `b` se pruebe, la
negación falle y la regla no aporte nada: el grado de «A y no B» sería 0,
igual que si B fuera seguro. Con el complemento, la evidencia débil de B
resta poco. Rowe agrega una advertencia: un hecho con grado 0,0 en la
lista no es lo mismo que un hecho ausente para `\+`, que solo mira si
unifica.

## Ejercicio 5

<!-- ejemplo: capitulo-66/soluciones.pl predicado: dos_reglas/2 -->
```prolog
%!  dos_reglas(+Metodo, -P:float) is det.
%
%   P es el grado de a con las reglas a(P) :- b(P2), P is P2 * 0.6 y
%   a(P) :- c(P), con b seguro y c de grado 0.8; con cuatro decimales.
dos_reglas(Metodo, P) :-
    y(Metodo, 0.6, 1.0, PB),
    combinar(o, Metodo, [PB, 0.8], P0),
    P is round(P0 * 10000) / 10000.0.
```

```prolog
?- member(M, [independiente, conservador, liberal]), dos_reglas(M, P).
M = independiente,
P = 0.92 ;
M = conservador,
P = 0.8 ;
M = liberal,
P = 1.0.
```

La primera regla aporta 0,6 con los tres métodos (su condición es
segura); la segunda, 0,8. La independencia da $0{,}6 + 0{,}8 - 0{,}48 =
0{,}92$; la conservadora, el máximo, 0,8; la liberal, la suma limitada a 1.

## Ejercicio 6

<!-- ejemplo: capitulo-66/soluciones.pl predicado: mas_probable/3 -->
```prolog
%!  mas_probable(+Observaciones:list, +Metodo, -Hipotesis) is semidet.
%
%   Hipotesis es la de mayor grado con Metodo; entre las empatadas, la
%   primera de hipotesis/1. Falla si ninguna tiene grado mayor que 0.
mas_probable(Observaciones, Metodo, Hipotesis) :-
    findall(P-H,
            ( hipotesis(H),
              grado(H, Observaciones, Metodo, P),
              P > 0 ),
            Pares),
    Pares \== [],
    pairs_keys(Pares, Ps),
    max_list(Ps, Maximo),
    once(member(Maximo-Hipotesis, Pares)).
```

```prolog
?- mas_probable([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3], independiente, H).
H = guepardo.

?- mas_probable([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3], conservador, H).
false.
```

Las observaciones y el método llegan instanciados: sin ellos no se puede
calcular ningún grado. La hipótesis es de salida. El predicado es
`semidet`: da una sola respuesta, porque un empate se resuelve por el
orden de `hipotesis/1` con `once/1`, y falla cuando ninguna hipótesis
tiene grado mayor que 0, como en la segunda consulta, donde el método
conservador lleva todas a 0. Fallar es más claro que inventar una
hipótesis `ninguna`, que el llamador podría tomar por un animal.

## Ejercicio 7

<!-- ejemplo: capitulo-66/soluciones.pl predicado: excluyentes/2 arbol_excluyentes/2 construir_excl/4 con_alguna/2 -->
```prolog
% excluyentes(A, B): las preguntas A y B no pueden tener las dos un sí.
excluyentes(vuela, no_vuela).
excluyentes(no_vuela, vuela).

%!  arbol_excluyentes(+Estrategia, -Arbol) is det.
%
%   Arbol es el árbol de Estrategia construido sabiendo qué preguntas se
%   excluyen: un sí a una descarta las reglas que tienen la otra.
arbol_excluyentes(Estrategia, Arbol) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    construir_excl(Estrategia, Reglas, Prototipos, Arbol).

%!  construir_excl(+Estrategia, +Reglas:list, +Prototipos:list,
%!                 -Arbol) is det.
%
%   Como construir/4 de arbol.pl, con la rama del sí sin las reglas que
%   tienen una pregunta excluida por la respondida.
construir_excl(Estrategia, Reglas, Prototipos, Arbol) :-
    (   Reglas == []
    ->  Arbol = hoja(ninguna)
    ;   memberchk(H-[], Reglas)
    ->  Arbol = hoja(H)
    ;   arbol:elegir(Estrategia, Reglas, Prototipos, P),
        Arbol = pregunta(P, Si, No),
        findall(Q, excluyentes(P, Q), Excluidas),
        exclude(con_alguna(Excluidas), Reglas, Compatibles),
        maplist(arbol:sin_pregunta(P), Compatibles, ReglasSi),
        exclude(arbol:con_pregunta(P), Reglas, ReglasNo),
        partition(arbol:prototipo_si(P), Prototipos, PSi, PNo),
        construir_excl(Estrategia, ReglasSi, PSi, Si),
        construir_excl(Estrategia, ReglasNo, PNo, No)
    ).

%!  con_alguna(+Preguntas:list, +Regla) is semidet.
%
%   Regla tiene alguna de Preguntas.
con_alguna(Preguntas, Regla) :-
    once(( member(Q, Preguntas),
           arbol:con_pregunta(Q, Regla) )).
```

| Árbol `orden` | Preguntas del árbol | Hojas | Máximo | Media, prototipos | Media, todos |
|---|---|---|---|---|---|
| sin excluyentes | 165 | 166 | 14 | 5,67 | 6,05 |
| con excluyentes | 105 | 106 | 12 | 5,08 | 5,73 |

Después de un sí a `vuela`, las reglas que piden `no_vuela` salen del
árbol, y viceversa: el árbol pierde sesenta preguntas y el promedio de los
prototipos baja de 5,67 a 5,08. Los prototipos de la segunda regla del
pingüino y de la del avestruz piden `vuela` y `no_vuela` a la vez, así que
ahora terminan en `ninguna` sin preguntar lo que falta. La prueba
`excluyentes_correcto` compara el árbol con el sistema del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md)
sobre los animales que no tienen las dos observaciones; para los que las
tienen, el árbol responde según la exclusión y el sistema original no.

## Ejercicio 8

<!-- ejemplo: capitulo-66/soluciones.pl predicado: costo_minimo/1 costo/3 -->
```prolog
%!  costo_minimo(-C:integer) is det.
%
%   C es la menor suma de preguntas, sobre los prototipos, que alcanza un
%   árbol para las reglas colapsadas.
costo_minimo(C) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    costo(Reglas, Prototipos, C).

%!  costo(+Reglas:list, +Prototipos:list, -C:integer) is det.
%
%   C es la menor suma de preguntas para llevar Prototipos a su hoja en
%   un árbol de Reglas: cada pregunta del nodo cuenta una vez por cada
%   prototipo que llega a él.
costo(Reglas, Prototipos, C) :-
    (   (   Prototipos == []
        ;   Reglas == []
        ;   memberchk(_-[], Reglas)
        )
    ->  C = 0
    ;   foldl(agregar_preguntas, Reglas, [], Candidatas),
        length(Prototipos, N),
        findall(C1,
                ( member(P, Candidatas),
                  maplist(arbol:sin_pregunta(P), Reglas, ReglasSi),
                  exclude(arbol:con_pregunta(P), Reglas, ReglasNo),
                  partition(arbol:prototipo_si(P), Prototipos, PSi, PNo),
                  costo(ReglasSi, PSi, CSi),
                  costo(ReglasNo, PNo, CNo),
                  C1 is N + CSi + CNo ),
                Cs),
        min_list(Cs, C)
    ).
```

```prolog
?- costo_minimo(C).
C = 68.
```

El mínimo es 68 preguntas para los doce prototipos, 5,67 por animal: lo
que alcanzan las estrategias `orden` e `informacion`. `frecuente` hace 74.
La tabla guarda el costo de cada par de reglas y prototipos, que se
repite cuando dos órdenes de preguntas llegan al mismo nodo; aun así la
búsqueda tarda unos segundos, y crece en forma exponencial con la cantidad
de preguntas. Es un punto de referencia para medir las estrategias, no
una manera de construir árboles grandes.

## Ejercicio 9

<!-- ejemplo: capitulo-66/soluciones.pl predicado: frecuencia/2 promedio_ponderado/2 sumar_pesado/3 -->
```prolog
% frecuencia(H, F): de cada 100 animales que se consultan, F son H.
frecuencia(guepardo, 10).
frecuencia(tigre, 10).
frecuencia(jirafa, 5).
frecuencia(cebra, 15).
frecuencia(pinguino, 40).
frecuencia(avestruz, 20).

%!  promedio_ponderado(+Arbol, -Promedio:float) is det.
%
%   Promedio es la cantidad media de preguntas de Arbol sobre los
%   prototipos, pesado cada uno por la frecuencia de su hipótesis
%   repartida entre sus reglas colapsadas; con dos decimales.
promedio_ponderado(Arbol, Promedio) :-
    findall(W-N,
            ( prototipo(H, Os),
              frecuencia(H, F),
              aggregate_all(count, colapsada(H, _), K),
              W is F / K,
              consultar(Arbol, lista(Os), _, Ps),
              length(Ps, N) ),
            Pares),
    foldl(sumar_pesado, Pares, 0-0, Pesos-Suma),
    Promedio is round(100 * Suma / Pesos) / 100.0.

%!  sumar_pesado(+Par, +Acumulado, -Acumulado1) is det.
%
%   Suma el peso W y el producto W * N del Par W-N al Acumulado.
sumar_pesado(W-N, W0-S0, W1-S1) :-
    W1 is W0 + W,
    S1 is S0 + W * N.
```

Con cada árbol construido por `arbol/2`, `promedio_ponderado/2` da 5,9 para `orden`,
6,2 para `frecuente` y 5,9 para `informacion`, como verifica la prueba
`ponderado`. Con cuatro de cada diez animales pingüinos, conviene que las
preguntas de aves vayan antes, pero ninguna de las tres estrategias mira
las frecuencias: `orden` y `informacion` empatan. Una estrategia que
pesara cada prototipo por su frecuencia en la ganancia de información la
tendría en cuenta.

## Ejercicio 10

<!-- ejemplo: capitulo-66/soluciones.pl predicado: escribir_arbol/1 escribir_clausulas/0 -->
```prolog
%!  escribir_arbol(+Archivo) is det.
%
%   Escribe en Archivo las cláusulas de nodo/3 y un responde/2 que busca
%   la pregunta entre las observaciones: un programa que no necesita ni
%   las reglas ni el árbol.
escribir_arbol(Archivo) :-
    setup_call_cleanup(
        open(Archivo, write, S, [encoding(utf8)]),
        with_output_to(S, escribir_clausulas),
        close(S)).

%!  escribir_clausulas is det.
%
%   Escribe en la salida actual los operadores, nodo/3 y responde/2.
escribir_clausulas :-
    format(":- op(780, xfy, y).~n~n"),
    forall(clause(compilado:nodo(N, F, H), Cuerpo),
           portray_clause((nodo(N, F, H) :- Cuerpo))),
    portray_clause((responde(lista(Os), P) :-
                        (   P = (O y C)
                        ->  memberchk(O, Os),
                            call(C)
                        ;   memberchk(P, Os)
                        ))).
```

La prueba `escribir_arbol` escribe el archivo, lo carga en un módulo
`suelto` que no tiene nada más, y consulta `nodo(1, lista([da_leche,
tiene_cascos, rayas_negras]), H)`, que da `H = cebra`. El archivo declara
el operador `y`, porque la pregunta del peso lo usa, y define un
`responde/2` de dos líneas en lugar de `demostrar/4`: el programa
compilado ya no necesita ni las reglas, ni el intérprete, ni el
constructor del árbol.

## Ejercicio 11

<!-- ejemplo: capitulo-66/soluciones.pl predicado: consultar_con_grado/5 supera/2 -->
```prolog
%!  consultar_con_grado(+Arbol, +Observaciones:list, +Umbral:float,
%!                      -Hipotesis, -P:float) is det.
%
%   Recorre Arbol respondiendo que sí a una pregunta cuya observación
%   tiene grado de al menos Umbral; P es el grado de la Hipotesis de la
%   hoja con el método independiente, o 0.0 si es ninguna.
consultar_con_grado(Arbol, Observaciones, Umbral, Hipotesis, P) :-
    include(supera(Umbral), Observaciones, Seguras),
    pairs_keys(Seguras, Hechos),
    consultar(Arbol, lista(Hechos), Hipotesis, _),
    (   Hipotesis == ninguna
    ->  P = 0.0
    ;   grado(Hipotesis, Observaciones, independiente, P)
    ).

%!  supera(+Umbral:float, +Par) is semidet.
%
%   El grado del Par Hecho-Grado es al menos Umbral.
supera(Umbral, _-G) :-
    G >= Umbral.
```

Con el árbol `orden` y el animal del atardecer,
`[tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6,
rayas_negras-0.3]`, el resultado es `guepardo` con 0,1851 para el umbral
0,5, y `ninguna` con 0,0 para 0,7, como verifica la prueba `con_grado`. Con 0,7 las manchas, de grado 0,6, cuentan como
ausentes, y ninguna regla se cumple. El umbral convierte los grados en
respuestas antes de consultar, y el árbol pierde la información que la
evidencia combinada conserva: el grado de la hoja, 0,1851, dice cuánto se
puede confiar en la respuesta del árbol con el umbral 0,5.

## Ejercicio 12

<!-- ejemplo: capitulo-66/soluciones.pl predicado: fuerza_estimada/4 -->
```prolog
%!  fuerza_estimada(+Exitos:integer, +Total:integer, -F:float,
%!                  -Error:float) is det.
%
%   F es la fracción Exitos / Total, que estima la fuerza de una regla, y
%   Error su error estándar, la raíz de F (1 - F) / Total; los dos con
%   tres decimales.
fuerza_estimada(Exitos, Total, F, Error) :-
    F0 is Exitos / Total,
    E0 is sqrt(F0 * (1 - F0) / Total),
    F is round(1000 * F0) / 1000.0,
    Error is round(1000 * E0) / 1000.0.
```

```prolog
?- member(X-N, [200-500, 7-20, 2-2000]), fuerza_estimada(X, N, F, E).
X = 200,
N = 500,
F = 0.4,
E = 0.022 ;
X = 7,
N = 20,
F = 0.35,
E = 0.107 ;
X = 2,
N = 2000,
F = E, E = 0.001.
```

Con 500 casos el error es 0,022, pequeño frente a 0,4: la estimación es
confiable. Con 20 casos, 0,107 frente a 0,35: el mismo ejemplo de Rowe,
que la acepta con reservas. Con 2 casos en 2000 el error es igual a la
estimación, 0,001: el suceso es tan raro que la muestra no alcanza, y la
fuerza no se debe tomar de estos datos.

## Ejercicio 13

<!-- ejemplo: capitulo-66/soluciones_certeza.pl fragmento: % umbral_regla(Regla, U): .. umbral_regla(r7, 0.5). -->
```prolog
% umbral_regla(Regla, U): la Regla se aplica solo si su premisa llega a U.
umbral_regla(c1, 0.4).
umbral_regla(r7, 0.5).
```

<!-- ejemplo: capitulo-66/soluciones_certeza.pl predicado: umbral_de/3 factor_con_umbrales/4 aporte_con_umbral/4 -->
```prolog
%!  umbral_de(+Regla, +General:float, -U:float) is det.
%
%   U es el umbral de la Regla: el propio, si lo tiene, o el General.
umbral_de(Regla, General, U) :-
    (   umbral_regla(Regla, U0)
    ->  U = U0
    ;   U = General
    ).

%!  factor_con_umbrales(+Meta, +Observaciones:list, +General:float,
%!                      -F:float) is det.
%
%   F es el factor de certeza de Meta como en factor/4, con el umbral de
%   cada regla dado por umbral_de/3. Las conclusiones intermedias se
%   evalúan con el umbral General.
factor_con_umbrales(Meta, Observaciones, General, F) :-
    findall(A, aporte_con_umbral(Meta, Observaciones, General, A), As),
    foldl(cf_combinar, As, 0.0, F0),
    F is round(F0 * 10000) / 10000.0.

%!  aporte_con_umbral(+Meta, +Observaciones:list, +General:float, -A:float)
%!      is nondet.
%
%   A es como en aporte/4, con el umbral propio de cada regla.
aporte_con_umbral(Meta, Observaciones, _, A) :-
    observable(Meta),
    member(Meta-A, Observaciones).
aporte_con_umbral(Meta, Observaciones, General, A) :-
    regla(Regla, si Condiciones entonces Meta),
    premisa(Condiciones, Observaciones, General, P),
    umbral_de(Regla, General, U),
    P >= U,
    fuerza(Regla, F),
    A is F * P.
aporte_con_umbral(Meta, Observaciones, General, A) :-
    en_contra(Regla, Condicion, Meta, F),
    premisa(Condicion, Observaciones, General, P),
    umbral_de(Regla, General, U),
    P >= U,
    A is -F * P.
```

```prolog
?- atardecer(Os), factor_con_umbrales(guepardo, Os, 0.2, F).
Os = [tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3],
F = 0.476.

?- factor_con_umbrales(guepardo, [tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.5], 0.2, F).
F = 0.0473.
```

Con el animal del atardecer, las rayas de grado 0,3 no llegan al umbral
de 0,4 de la regla c1, y la evidencia en contra no cuenta: queda solo el
aporte de r7, cuya premisa vale 0,56 y supera su umbral de 0,5. Con rayas
de grado 0,5, c1 se aplica con $-0{,}9 \cdot 0{,}5 = -0{,}45$, y la
combinación de signos distintos da
$(0{,}476 - 0{,}45) / (1 - 0{,}45) = 0{,}0473$, lo mismo que `factor/4`
con el umbral general. Un umbral propio permite exigir más a una regla
cuya condición se observa mal, como las rayas vistas con poca luz, sin
cambiar las demás. Las conclusiones intermedias, como el carnívoro de la
premisa de r7, se siguen evaluando con el umbral general.

## Ejercicio 14

`valores/2` es `multifile` en `id3.pl`, y la solución agrega el día:

<!-- ejemplo: capitulo-66/soluciones_id3.pl predicado: valores/2 con_dia/1 -->
```prolog
% valores(dia, Ds): el día es el número del ejemplo, de 1 a 14.
valores(dia, Ds) :-
    numlist(1, 14, Ds).

%!  con_dia(-Ejemplos:list) is det.
%
%   Ejemplos son los de ejemplos/1 con el par dia=N agregado al objeto
%   del ejemplo N.
con_dia(Ejemplos) :-
    findall([dia=N, cielo=C, temperatura=T, humedad=H, viento=V]-K,
            sabado(N, C, T, H, V, K),
            Ejemplos).
```

```prolog
?- comparar_dia(Filas).
Filas = [dia-0.94-0.247, cielo-0.247-0.156, temperatura-0.029-0.019, humedad-0.152-0.152, viento-0.048-0.049].

?- arboles_con_dia(G, R).
G = R, R = dia.

?- clasifica_dia_nuevo(C).
false.
```

El día separa los catorce ejemplos en catorce grupos de uno, todos puros,
y gana toda la información: 0,94 bits, el máximo. Su valor intrínseco es
$\log_2 14 \approx 3{,}81$, y la razón de ganancia lo reduce a 0,247; pero
el cielo queda en 0,156, y la razón también elige el día. La corrección
de Quinlan reduce el sesgo hacia los atributos con muchos valores, y
alcanza cuando la ganancia de los otros es comparable; no alcanza cuando
el atributo identifica cada ejemplo. El árbol resultante tiene una hoja
por ejemplo y no generaliza: un sábado nuevo, el 15, no tiene rama, y
`clasificar/3` falla. La solución es no ofrecer como atributo lo que
identifica a los ejemplos.
