# Soluciones del capítulo 35 — Transformación de programas y compilación

El código de esta página está en `ejemplos/capitulo-35/soluciones.pl`,
`soluciones_parcial.pl` y `soluciones_experto.pl`, en el mismo directorio, y
pasa sus pruebas. `soluciones.pl` repite `traducir/2` de `gramatica.pl` y
`desplegar/4` y `plegar/4` de `desplegar.pl`, para cargarse solo;
`soluciones_parcial.pl` carga `parcial.pl`, y `soluciones_experto.pl` es
`experto.pl` con los cambios de los ejercicios 13 y 14.

## 1

```prolog
?- expand_term(padres(ana, []), C).
C = [].

?- expand_goal(x_de(punto(1, 2), X), G).
G = (punto(1, 2)=punto(X, _)).

?- traducir((a --> b, [c]), C).
C = (a(_A, _B):-b(_A, _C), _C=[c|_B]).

?- traducir((a --> []), C).
C = (a(_A, _B):-_A=_B).
```

Un padre sin hijos se expande a la lista vacía: el término desaparece del
programa, sin dejar ningún hecho. `expand_goal/2` no ejecuta la unificación
que produce, `punto(1, 2) = punto(X, _)`: la escribe en el cuerpo, y X se
liga al ejecutarlo. En la primera regla, el terminal que sigue a `b` liga la
salida de `b`, `_C`, a `[c|_B]`; en la segunda, la regla vacía unifica la
entrada con la salida.

## 2

Las tres llamadas dan `X = 3`, pero por mecanismos distintos. La consulta
escrita en el intérprete interactivo **se expande**: el intérprete pasa cada
consulta por `expand_goal/2` antes de ejecutarla. `call(x_de, P, X)` también
se expande: `call/3` declara su primer argumento como meta-argumento, y
SWI-Prolog reemplaza la clausura por un predicado auxiliar que ya contiene la
unificación. Solo la meta construida al ejecutar escapa a la expansión:

```text
?- listing(abscisa/2), listing(abscisa2/2).
abscisa(P, X) :-
    call('__aux_wrapper_d52295dbca25aafedfaa3839990dde123c32fe19',
         P,
         X).

abscisa2(P, X) :-
    G=x_de(P, X),
    call(G).

true.
```

Por eso `expansion.pl` conserva la definición de `x_de/2`: `abscisa2/2` la
llama.

## 3

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: %!  term_expansion(+Termino, -Hechos:list) is semidet. .. tabla(capital, [chile-santiago, peru-lima]). consulta: capital(peru, C). -->
```prolog
%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   Un término tabla(Nombre, Pares) se carga como un hecho
%   Nombre(Clave, Valor) por cada par Clave-Valor de Pares.
term_expansion(tabla(Nombre, Pares), Hechos) :-
    findall(Hecho,
            ( member(Clave-Valor, Pares),
              Hecho =.. [Nombre, Clave, Valor] ),
            Hechos).

% tabla(Nombre, Pares): se carga como hechos capital/2.
tabla(capital, [chile-santiago, peru-lima]).
```

```prolog
?- capital(P, C).
P = chile,
C = santiago ;
P = peru,
C = lima.
```

`=..`, de la [sección 32.3](../capitulo-32-inspeccion-de-terminos/index.md#323-y-compound_name_arguments3), construye cada hecho con el nombre que
indica la tabla. Como en `padres/2`, el término `tabla/2` no queda en el
programa.

## 4

`escribir(hola)` se expande a `escribir(texto(hola))`, que vuelve a ser una
llamada a `escribir/1` y se expande a `escribir(texto(texto(hola)))`, y así
sin fin: `goal_expansion/2` se aplica hasta que el objetivo no cambia, y este
cambia siempre. La primera corrección expande a otro predicado, que ninguna
cláusula de `goal_expansion/2` reconoce; la segunda exige que el argumento no
sea ya `texto(_)`, y su propio resultado no cumple esa condición:

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: %!  goal_expansion(+Meta, -Expandida) is semidet. .. anotar(hola). consulta: saludar. -->
```prolog
%!  goal_expansion(+Meta, -Expandida) is semidet.
%
%   escribir(X) se expande a una llamada a otro predicado, que ninguna
%   cláusula de goal_expansion/2 vuelve a expandir. anotar(X) se expande a
%   anotar(texto(X)) solo si X no es ya texto(_): el resultado no cumple la
%   condición, y la expansión se detiene.
goal_expansion(escribir(X), escribir_texto(texto(X))).
goal_expansion(anotar(X), anotar(texto(X))) :-
    X \= texto(_).

%!  escribir_texto(+T) is det.
%
%   Escribe T en una línea.
escribir_texto(T) :-
    format("~w~n", [T]).

%!  anotar(+T) is det.
%
%   Escribe T en una línea.
anotar(T) :-
    format("~w~n", [T]).

%!  saludar is det.
%
%   Escribe texto(hola) dos veces: sus dos llamadas se expandieron al
%   cargar.
saludar :-
    escribir(hola),
    anotar(hola).
```

```text
?- listing(saludar/0).
saludar :-
    escribir_texto(texto(hola)),
    anotar(texto(hola)).

true.
```

La condición usa `\=`, que no liga ninguna variable: una expansión no debe
ligar las variables de la cláusula, porque cambiaría su significado. Con una
variable como argumento, `anotar(V)` no se expande, porque V unifica con
`texto(_)`.

## 5

La cadena se convierte en la lista de sus códigos, que se trata como una
lista de terminales. La cláusula va antes de la del no terminal, porque una
cadena no es una lista:

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: cuerpo(Cadena, S0, S, S0 = Lista) :- .. append(Codigos, S, Lista). -->
```prolog
cuerpo(Cadena, S0, S, S0 = Lista) :-
    string(Cadena),
    !,
    string_codes(Cadena, Codigos),
    append(Codigos, S, Lista).
```

```prolog
?- traducir((saludo --> "hola"), R).
R = (saludo(_A, _B):-_A=[104, 111, 108, 97|_B]).
```

`dcg_translate_rule/2` da la misma cláusula; la prueba `como_el_sistema` de
`soluciones.plt` lo verifica, también con una cadena entre terminales.

## 6

Los terminales del pushback se agregan delante de lo que queda después del
cuerpo: el cuerpo se traduce con una salida intermedia, S1, y al final la
salida de la regla se liga a los terminales seguidos de S1. La cláusula va
primero, porque `Cabeza, Terminales` también unifica con la cabeza de la
cláusula general:

<!-- ejemplo: capitulo-35/soluciones.pl predicado: traducir/2 -->
```prolog
%!  traducir(+Regla, -Clausula) is det.
%
%   Clausula es la traducción de Regla. Admite el pushback,
%   Cabeza, Terminales --> Cuerpo, y los terminales escritos como cadena.
traducir((Cabeza, Empuje --> Cuerpo), (Cabeza1 :- (Cuerpo1, S = Lista))) :-
    !,
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S1, Cuerpo1),
    append(Empuje, S1, Lista).
traducir((Cabeza --> Cuerpo), (Cabeza1 :- Cuerpo1)) :-
    no_terminal(Cabeza, S0, S, Cabeza1),
    cuerpo(Cuerpo, S0, S, Cuerpo1).
```

```prolog
?- traducir((siguiente(C), [C] --> [C]), R).
R = (siguiente(C, _A, _B):-_A=[C|_C], _B=[C|_C]).

?- dcg_translate_rule((siguiente(C), [C] --> [C]), R).
R = (siguiente(C, _A, _B):-_A=[C|_C], _B=[C|_C]).
```

## 7

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: % definicion_ultimo(D): X es el último elemento de L. .. plegar(C2a, 1, D, C2). consulta: derivar_ultimo(Cs). -->
```prolog
% definicion_ultimo(D): X es el último elemento de L.
definicion_ultimo((ultimo(X, L) :- [append(_, [X], L)])).

%!  derivar_ultimo(-Clausulas:list) is det.
%
%   Clausulas es la definición recursiva de ultimo/2: la definición
%   desplegada con append/3, con la segunda resolvente plegada.
derivar_ultimo([C1, C2]) :-
    definicion_ultimo(D),
    programa_append(P),
    desplegar(D, 1, P, [C1, C2a]),
    plegar(C2a, 1, D, C2).
```

```prolog
?- forall(derivar_ultimo(Cs), mostrar(Cs)).
ultimo(A, [A]):-[]
ultimo(A, [_|B]):-[ultimo(A, B)]
true.

?- ultimo(X, [a, b, c]).
X = c ;
false.
```

Desplegar con `append([], L, L)` da el caso de la lista de un elemento;
desplegar con la segunda cláusula de `append/3` deja la llamada sobre el
resto, que es una instancia de la definición y se pliega. La prueba
`ultimo_como_append` compara las respuestas con las de `append/3`.

## 8

Desplegar `suma(L, S)` da dos cláusulas; en la primera, desplegar
`largo([], N)` da el hecho `suma_largo([], 0, 0)`. En la segunda, desplegar
`largo([X|Xs], N)`, el tercer objetivo, deja el cuerpo
`suma(Xs, S0), S is S0 + X, largo(Xs, N0), N is N0 + 1`. Las dos llamadas
sobre `Xs` no están juntas, y el plegado exige que lo estén: `reordenar/3`
pone el tercer objetivo en el segundo lugar. El cambio de orden es válido
porque `S is S0 + X` solo necesita que `suma/2` haya terminado, y sigue
después de ella:

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: %!  reordenar(+Clausula, +Orden:list(integer), -Reordenada) is det. .. plegar(B3, 1, D, C2). consulta: derivar_suma_largo(Cs). -->
```prolog
%!  reordenar(+Clausula, +Orden:list(integer), -Reordenada) is det.
%
%   Reordenada tiene los objetivos del cuerpo de Clausula en el Orden
%   dado por sus posiciones, contando desde 1.
reordenar((Cabeza :- Cuerpo), Orden, (Cabeza :- Cuerpo1)) :-
    maplist(objetivo(Cuerpo), Orden, Cuerpo1).

%!  objetivo(+Cuerpo:list, +I:integer, -G) is det.
%
%   G es el objetivo I de Cuerpo, contando desde 1.
objetivo(Cuerpo, I, G) :-
    nth1(I, Cuerpo, G).

%!  derivar_suma_largo(-Clausulas:list) is det.
%
%   Clausulas es suma_largo/3 en una sola pasada: los dos objetivos
%   desplegados, el cuerpo reordenado y las dos llamadas plegadas.
derivar_suma_largo([C1, C2]) :-
    definicion_suma_largo(D),
    programa_suma_largo(P),
    desplegar(D, 1, P, [A1, A2]),
    desplegar(A1, 1, P, [C1]),
    desplegar(A2, 3, P, [B2]),
    reordenar(B2, [1, 3, 2, 4], B3),
    plegar(B3, 1, D, C2).
```

```prolog
?- forall(derivar_suma_largo(Cs), mostrar(Cs)).
suma_largo([], 0, 0):-[]
suma_largo([A|B], C, D):-[suma_largo(B, E, F), C is E+A, D is F+1]
true.
```

```text
?- numlist(1, 100000, L), time(suma_largo_dos(L, S, N)).
% 400,002 inferences, 0.078 CPU in 0.081 seconds (97% CPU, 5120026 Lips)

?- numlist(1, 100000, L), time(suma_largo(L, S, N)).
% 300,000 inferences, 0.063 CPU in 0.076 seconds (82% CPU, 4800000 Lips)
```

La versión de una pasada ahorra una llamada por elemento: la de `largo/2`
sobre el resto, que ahora hace la misma llamada recursiva.

## 9

<!-- ejemplo: capitulo-35/soluciones_parcial.pl predicado: especializar_vainilla/2 control_vainilla/2 consulta: especializar_vainilla((abuelo(A, N) :- padre(A, P), padre(P, N)), C). -->
```prolog
%!  especializar_vainilla(+Clausula, -Especializada) is nondet.
%
%   Especializada es Clausula con el cuerpo reemplazado por el residuo de
%   resolver_cuerpo/1 sobre él.
especializar_vainilla((Cabeza :- Cuerpo0), (Cabeza :- Residuo)) :-
    limpiar(Cuerpo0, Cuerpo),
    parcial(resolver_cuerpo(Cuerpo), control_vainilla, Residuo).

%!  control_vainilla(+Meta, -Accion) is semidet.
%
%   Se despliegan resolver_cuerpo/1 y ejecutar/1; un objetivo del programa
%   queda como la llamada misma.
control_vainilla(resolver_cuerpo(prog(G)), dejar(G)).
control_vainilla(resolver_cuerpo(Cuerpo), desplegar) :-
    Cuerpo \= prog(_).
control_vainilla(ejecutar(_), desplegar).
```

```prolog
?- especializar_vainilla((antepasado(A, D) :- padre(A, H), antepasado(H, D)), C).
C = (antepasado(A, D):-padre(A, H), antepasado(H, D)).

?- especializar_vainilla((mayor_que(A, B) :- edad(A, EA), edad(B, EB), EA > EB), C).
C = (mayor_que(A, B):-edad(A, EA), edad(B, EB), EA>EB).
```

El resultado es el programa original, cláusula por cláusula: el intérprete
vainilla no agrega nada a la ejecución, y lo que queda después de quitarle
su propio trabajo es el programa que interpretaba. Por eso el costo del
intérprete de la [sección 33.2](../capitulo-33-introspeccion-y-metainterpretes/index.md#332-el-interprete-vainilla) desaparece por completo al
especializarlo. El intérprete con árboles, en cambio, deja en el residuo la
construcción del árbol, que es lo que agregaba.

## 10

<!-- ejemplo: capitulo-35/soluciones_parcial.pl predicado: pertenece/2 control_pertenece/2 es_letra/2 consulta: es_letra([a, b, c], Cs). -->
```prolog
%!  pertenece(?X, ?L:list) is nondet.
%
%   X es un elemento de L.
pertenece(X, [X|_]).
pertenece(X, [_|Ys]) :-
    pertenece(X, Ys).

%!  control_pertenece(+Meta, -Accion) is semidet.
%
%   pertenece/2 se despliega si su lista es conocida.
control_pertenece(pertenece(_, L), desplegar) :-
    nonvar(L).

%!  es_letra(+Letras:list, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas de es_letra/1 para las Letras: una por cada
%   residuo de pertenece(X, Letras).
es_letra(Letras, Clausulas) :-
    findall((es_letra(X) :- Residuo),
            parcial(pertenece(X, Letras), control_pertenece, Residuo),
            Clausulas).
```

```prolog
?- es_letra([a, b, c], Cs).
Cs = [(es_letra(a):-true), (es_letra(b):-true), (es_letra(c):-true)].
```

Hay tres residuos, uno por elemento. Cada despliegue de `pertenece/2` tiene
dos cláusulas: la primera liga X a la cabeza de la lista y termina, la segunda
sigue con el resto. Al llegar a `[]`, ninguna cláusula de `pertenece/2`
unifica, y esa rama desaparece sin residuo: la evaluación parcial convierte
la búsqueda en la lista en tres hechos.

## 11

```prolog
?- expand_goal(once(p(X)), G).
G = (p(X)->true).

?- expand_goal(ignore(p(X)), G).
G = (p(X)->true;true).
```

`once(G)` es un condicional sin rama «si no»: si G falla, el condicional
falla. `ignore(G)` agrega la rama `true`, que se cumple cuando G falla: por
eso `ignore/1` siempre se cumple. Las dos expansiones evitan la llamada a
`once/1` o `ignore/1`, que ejecutan la meta como argumento, y dejan el
condicional escrito en el cuerpo.

## 12

`consult(datos)` busca primero `datos.qlf`, y lo compara con `datos.pl`. Como
el fuente es más reciente, SWI-Prolog lo compila de nuevo, escribe un
`datos.qlf` nuevo en lugar del anterior, y carga el resultado. El mensaje
`% datos: recompiling QLF file (out of date)` lo informa. Con el fuente sin
cambios, carga el `.qlf` directamente. El comportamiento se comprobó con un
archivo pequeño, tocando el fuente después de compilarlo.

## 13

<!-- ejemplo: capitulo-35/soluciones_experto.pl fragmento: regla(r13, si mamifero y vuela entonces murcielago). .. regla(r13, si mamifero y vuela entonces murcielago). consulta: caso(6, Obs), identificar_compilado(Obs, Animal). -->
```prolog
regla(r13, si mamifero y vuela entonces murcielago).
```

La regla se agrega a las demás, `hipotesis(murcielago)` a las hipótesis y
`caso(6, [tiene_pelo, vuela])` a los casos. Al cargar, la expansión produce:

```text
concluir(murcielago, A, B, deducido(murcielago, r13, C y observado(vuela))) :-
    concluir(mamifero, A, [r13-murcielago|B], C),
    observar(A, vuela, [r13-murcielago|B]).
```

```prolog
?- caso(6, Obs), identificar_compilado(Obs, Animal).
Obs = [tiene_pelo, vuela],
Animal = murcielago.
```

Con `regla/2` estática, como en `experto.pl`, `assertz/1` produce un error
de permiso: `No permission to modify static procedure regla/2`.
`soluciones_experto.pl` declara `regla/2` e `hipotesis/1` dinámicas. Una
regla agregada así la usa el intérprete, que busca las reglas en cada
consulta, y no la versión compilada, cuyas cláusulas se generaron al cargar
el archivo:

```prolog
?- assertz(regla(r14, si ave y nada entonces pato)), assertz(hipotesis(pato)), identificar([tiene_plumas, nada], A).
A = pato.

?- assertz(regla(r14, si ave y nada entonces pato)), assertz(hipotesis(pato)), identificar_compilado([tiene_plumas, nada], A).
false.
```

La prueba `regla_agregada` de `soluciones_experto.plt` hace las dos
comparaciones.

## 14

<!-- ejemplo: capitulo-35/soluciones_experto.pl predicado: compilar_regla/2 compilar_condicion/5 consulta: regla(r7, R), compilar_regla(regla(r7, R), C). -->
```prolog
%!  compilar_regla(+Regla, -Clausula) is det.
%
%   Clausula es la cláusula de concluir/4 para Regla, traducida
%   directamente, sin evaluar parcialmente el intérprete.
compilar_regla(regla(R, si Condiciones entonces Meta),
               (concluir(Meta, Fuente, Pila, deducido(Meta, R, Arbol)) :-
                    Cuerpo)) :-
    compilar_condicion(Condiciones, Fuente, [R-Meta|Pila], Arbol, Cuerpo).

%!  compilar_condicion(+Condicion, ?Fuente, ?Pila, -Arbol, -Cuerpo) is det.
%
%   Cuerpo prueba Condicion con las observaciones de Fuente, y Arbol es su
%   prueba. Una cláusula por cada cláusula de demostrar/4 que el control
%   de la expansión conserva.
compilar_condicion(A y B, Fuente, Pila, ArbolA y ArbolB, (CuerpoA, CuerpoB)) :-
    !,
    compilar_condicion(A, Fuente, Pila, ArbolA, CuerpoA),
    compilar_condicion(B, Fuente, Pila, ArbolB, CuerpoB).
compilar_condicion(X > Y, _, _, X > Y, X > Y) :-
    !.
compilar_condicion(X < Y, _, _, X < Y, X < Y) :-
    !.
compilar_condicion(C, Fuente, Pila, observado(C), observar(Fuente, C, Pila)) :-
    observable(C),
    !.
compilar_condicion(C, Fuente, Pila, Arbol, concluir(C, Fuente, Pila, Arbol)).
```

Cada cláusula de `compilar_condicion/5` es una cláusula de `demostrar/4`
que el control de [las reglas compiladas](experto.md) conserva, ya desplegada: la
conjunción, las dos comparaciones, la observación y, para lo demás, la
llamada a `concluir/4` en la que el control se detiene. La prueba
`sin_evaluador` compara, regla por regla, la cláusula de `compilar_regla/2`
con la que cargó la expansión, y son iguales. El evaluador parcial y el
control producen el compilador; escribirlo a mano da el mismo resultado,
pero hay que mantenerlo de acuerdo con el intérprete cada vez que este
cambia. Es la versión ingenua del
[Patrón 50](../patrones.md#50-especializar-el-interprete).

## 15

<!-- ejemplo: capitulo-35/soluciones.pl fragmento: % programa_concatenar(P): concatenar_dif/3 como datos. .. rotar_dif([X|Xs]-[X|F], Xs-F). consulta: derivar_rotar(Cs). -->
```prolog
% programa_concatenar(P): concatenar_dif/3 como datos.
programa_concatenar([ (concatenar_dif(L-M, M-F, L-F) :- []) ]).

% definicion_rotar(D): R es la lista diferencia [X|Xs]-F con X al final.
definicion_rotar((rotar_dif([X|Xs]-F, R) :-
                      [concatenar_dif(Xs-F, [X|G]-G, R)])).

%!  derivar_rotar(-Clausulas:list) is det.
%
%   Clausulas es la definición de rotar_dif/2 desplegada con
%   concatenar_dif/3: un hecho.
derivar_rotar(Clausulas) :-
    definicion_rotar(D),
    programa_concatenar(P),
    desplegar(D, 1, P, Clausulas).

% rotar_dif(D, R): la lista diferencia R es D con su primer elemento al
% final; el hecho que obtiene derivar_rotar/1.
rotar_dif([X|Xs]-[X|F], Xs-F).
```

```prolog
?- forall(derivar_rotar(Cs), mostrar(Cs)).
rotar_dif([A|B]-[A|C], B-C):-[]
true.
```

El despliegue unifica `concatenar_dif(Xs-F, [X|G]-G, R)` con una copia de
la cabeza `concatenar_dif(L-M, M-F1, L-F1)`. `L` queda ligada a `Xs`, y `M` a
`F` y a `[X|G]` a la vez: el final de la lista de entrada es `[X|G]`. `F1` es
`G`, y `R` queda ligada a `Xs-G`. El cuerpo de la cláusula de
`concatenar_dif/3` es vacío, y la resolvente es un hecho:
`rotar_dif([A|B]-[A|C], B-C)`. Se lee así: el primer elemento, A, se escribe
en el lugar libre del final de la lista, y el nuevo final es C. La rotación
no recorre la lista: cuesta una unificación.

```prolog
?- rotar_dif([a, b]-[], R).
false.

?- rotar_dif([1, 2, 3|Q]-Q, R1), rotar_dif(R1, R2), R2 = L-[].
Q = [1, 2],
R1 = [2, 3, 1, 2]-[2],
R2 = [3, 1, 2]-[],
L = [3, 1, 2].
```

`[a, b]-[]` tiene el final cerrado: el hecho exige que el final unifique con
`[a|C]`, y `[]` no unifica. La definición con `concatenar_dif/3` falla por la
misma razón. Con el final abierto, la primera rotación liga Q a `[1|C1]`, y la
segunda liga C1 a `[2|C2]`; cerrar C2 con `[]` da `[3, 1, 2]`. Al final, Q
queda ligada a `[1, 2]`, los dos elementos que pasaron por el final, y R1 se muestra
como `[2, 3, 1, 2]-[2]`, que sigue representando `[2, 3, 1]`: los elementos
de la lista menos los de su final.

El hecho es `concatenar_dif/3` desplegado en el lugar de la llamada. Es lo
que hace el código con listas diferencia de la
[sección 34.2](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#342-de-append3-a-la-lista-diferencia), como `inorden_dif/2`: no llama a
`concatenar_dif/3`, sino que escribe en los argumentos lo que esa llamada
haría por unificación: la lista del subárbol izquierdo termina en `[X|M]`, y
M es el comienzo de la del derecho.
