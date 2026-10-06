# Soluciones del capítulo 85 — Proyecto: un motor Datalog

El código de esta página está en `ejemplos/capitulo-85/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga el motor completo,
`datalog.pl`, y además `tablas.pl`, `wumpus.pl` y `retrogrado.pl`, sin
modificarlos. Es `% solo-local`, porque carga otros archivos. Los
predicados del motor que las consultas usan están en `seguro.pl`
(`problemas/2`), `estratos.pl` (`componentes/2`, `ciclos_negativos/2` y
`evaluar/3`), `magia.pl` (`magico/3`, `respuestas/4` y
`respuestas_magicas/4`), `incremental.pl` y `semantica38.pl`
(`clausulas/2`).

## 1

El programa tiene tres problemas: dos términos compuestos, las listas
`[+|Y]` y `[id|Y]`, y un hecho con variables, cuya cabeza ningún literal
liga.

<!-- ejemplo: capitulo-85/soluciones.pl predicado: expresion/1 -->
```prolog
%!  expresion(-Clausulas:list) is det.
%
%   El programa del ejercicio 15.1 de Nilsson y Małuszyński, como datos.
expresion([ (expr(X, Z) :- expr(X, [+|Y]), expr(Y, Z)),
            (expr([id|Y], Y) :- true) ]).
```

<!-- contexto: capitulo-85/soluciones.pl -->
```prolog
?- expresion(Cs), problemas(Cs, Ps).
Cs = [(expr(_A, _B):-expr(_A, [+|_C]), expr(_C, _B)), (expr([id|_C], _C):-true)],
Ps = [funcion([+|_]), funcion([id|_]), cabeza_libre(expr([id|_C], _C))].
```

De abajo hacia arriba, el hecho `expr([id|Y], Y)` vale para toda lista
Y: el primer paso tendría que agregar infinitos átomos, y con la regla,
listas cada vez más largas. Las funciones hacen infinita la base de
Herbrand, que en Datalog es finita. Prolog tampoco responde: con la regla
primero, `expr([id, +, id], X)` llama a `expr([id, +, id], [+|Y])`, que
vuelve a llamar a la regla con la misma lista, sin fin. Nilsson y
Małuszyński piden transformar el programa y evaluarlo con plantillas
mágicas, que son átomos con variables; el motor del capítulo guarda solo
átomos sin variables, y no puede hacerlo.

<!-- ejemplo: capitulo-85/soluciones.pl predicado: expr/2 -->
```prolog
%!  expr(?X, ?Z) is nondet.
%
%   El mismo programa como cláusulas de Prolog: Z es lo que queda de la
%   lista X después de una expresión. La recursión a la izquierda no
%   termina.
expr(X, Z) :-
    expr(X, [+|Y]),
    expr(Y, Z).
expr([id|Y], Y).
```

```prolog
?- call_with_inference_limit(expr([id, +, id], X), 100000, R).
R = inference_limit_exceeded.
```

## 2

`b` depende de `c`, `c` de `d` negado, y `d` y `e` forman un ciclo
positivo: la primera componente es `[d/0, e/0]`, y después `c`, `b` y `a`,
en ese orden. `f` usa negado a sí mismo: es su propia componente, con un
arco negativo dentro, y el programa no es estratificado.

```prolog
?- componentes([(a :- \+ b), (b :- c), (c :- \+ d), (d :- e), (e :- d), (f :- a, \+ f)], Ks), ciclos_negativos([(a :- \+ b), (b :- c), (c :- \+ d), (d :- e), (e :- d), (f :- a, \+ f)], Ps).
Ks = [[d/0, e/0], [c/0], [b/0], [a/0], [f/0]],
Ps = [f/0-f/0].
```

Sin `f`, el programa es estratificado. `d` y `e` son falsos, porque su
ciclo positivo no tiene un hecho del que partir; entonces `c` es
verdadero, `b` también, y `a` es falso:

```prolog
?- evaluar([(a :- \+ b), (b :- c), (c :- \+ d), (d :- e), (e :- d)], M, C).
M = [b, c],
C = costo(4, 2).
```

## 3

<!-- ejemplo: capitulo-85/soluciones.pl predicado: casados/1 -->
```prolog
%!  casados(-Clausulas:list) is det.
%
%   El programa con el que Nilsson y Małuszyński abren su capítulo.
casados([ (married(X, Y) :- married(Y, X)),
          (married(adam, anne) :- true) ]).
```

```prolog
?- casados(Cs), evaluar(Cs, M, C).
Cs = [(married(_A, _B):-married(_B, _A)), (married(adam, anne):-true)],
M = [married(adam, anne), married(anne, adam)],
C = costo(2, 2).

?- casados(Cs), respuestas_magicas(Cs, married(anne, X), Rs, C).
Cs = [(married(_A, _B):-married(_B, _A)), (married(adam, anne):-true)],
Rs = [married(anne, adam)],
C = costo(5, 5).
```

Dos pasos: el primero deriva `married(anne, adam)`, y el segundo, otra vez
`married(adam, anne)`, que ya estaba. Con la consulta `married(anne, X)`,
el predicado tiene una regla, así que el hecho `married(adam, anne)`
también se transforma: vale como `married_bf` si `married(adam, X)` fue
llamado. La regla mágica dice que llamar a `married(anne, X)` llama a
`married(X, anne)`, con el adorno `fb`, y esa a `married(anne, X)`, `bf`:
los dos adornos se alimentan uno al otro, y el hecho entra por el
segundo. Prolog, con la regla primero, llama a `married(X, anne)`, que
llama a `married(anne, X)`, y así sin fin: el árbol SLD es infinito por su
primera rama, y el hecho nunca se alcanza.

## 4

<!-- ejemplo: capitulo-85/soluciones.pl predicado: suplementario/3 encadenar/8 conjuncion/3 aparece_en/2 suplementarios/2 -->
```prolog
%!  suplementario(+Clausula, +K:integer, -Clausulas:list) is det.
%
%   Clausulas reemplazan a Clausula, A0 :- A1, ..., An, por la cadena de
%   predicados suplementarios de Nilsson y Małuszyński: S1 :- A1,
%   Si :- S(i-1), Ai, y A0 :- S(n-1), An. Cada Si tiene las variables de
%   A1, ..., Ai que todavía hacen falta: las de la cabeza y las de los
%   literales siguientes. Los nombres son sup_Nombre_K_i, con Nombre el de
%   la cabeza. Una cláusula de un literal o menos queda igual.
suplementario(Cabeza :- Cuerpo, K, Clausulas) :-
    literales(Cuerpo, Ls),
    length(Ls, N),
    (   N =< 1
    ->  Clausulas = [Cabeza :- Cuerpo]
    ;   functor(Cabeza, Nombre, _),
        Ls = [L|Resto],
        encadenar(Resto, L, 1, Cabeza, Nombre, K, true, Clausulas)
    ).

%!  encadenar(+Resto:list, +L, +I:integer, +Cabeza, +Nombre, +K, +Previo,
%!            -Clausulas:list) is det.
%
%   Clausulas son las del I-ésimo literal L y de los literales Resto que
%   lo siguen; Previo es el suplementario anterior, o true antes del
%   primero.
encadenar([], L, _, Cabeza, _, _, Previo, [Cabeza :- Cuerpo]) :-
    conjuncion(Previo, L, Cuerpo).
encadenar([L2|Ls], L, I, Cabeza, Nombre, K, Previo, [(S :- Cuerpo)|Cs]) :-
    term_variables(Previo-L, Antes),
    term_variables(Cabeza-[L2|Ls], Despues),
    include(aparece_en(Despues), Antes, Vs),
    atomic_list_concat([sup, Nombre, K, I], '_', F),
    S =.. [F|Vs],
    conjuncion(Previo, L, Cuerpo),
    I1 is I + 1,
    encadenar(Ls, L2, I1, Cabeza, Nombre, K, S, Cs).

%!  conjuncion(+Previo, +L, -Cuerpo) is det.
%
%   Cuerpo es L si Previo es true, y (Previo, L) si no.
conjuncion(Previo, L, Cuerpo) :-
    (   Previo == true
    ->  Cuerpo = L
    ;   Cuerpo = (Previo, L)
    ).

%!  aparece_en(+Vs:list, +V) is semidet.
%
%   La variable V es una de Vs.
aparece_en(Vs, V) :-
    member(W, Vs),
    W == V,
    !.

%!  suplementarios(+Clausulas:list, -Transformadas:list) is det.
%
%   Transformadas aplica suplementario/3 a cada cláusula de Clausulas,
%   con su posición como K.
suplementarios(Clausulas, Transformadas) :-
    length(Clausulas, N),
    numlist(1, N, Ks),
    maplist(suplementario, Clausulas, Ks, Partes),
    append(Partes, Transformadas).
```

```prolog
?- suplementario((p(X, Y) :- a(X, Z), b(Z, W), c(W, Y)), 1, Cs).
Cs = [(sup_p_1_1(X, Z):-a(X, Z)), (sup_p_1_2(X, W):-sup_p_1_1(X, Z), b(Z, W)), (p(X, Y):-sup_p_1_2(X, W), c(W, Y))].
```

Cada suplementario guarda solo lo que hace falta después: `sup_p_1_1`
lleva `X`, que la cabeza necesita, y `Z`, que necesita `b/2`; `sup_p_1_2`
ya no lleva `Z`. Las cláusulas tienen a lo sumo dos literales, como la
forma normal de Chomsky que Nilsson y Małuszyński mencionan. Un
suplementario que deja afuera una variable es una **proyección**: dos
combinaciones de los literales anteriores que solo difieren en esa
variable dan el mismo átomo, y lo que sigue se une una sola vez con él.

En `sd/2` la transformación no gana nada: 159 derivaciones contra 49, y
unas 24 900 inferencias contra 13 900, porque cada suplementario copia
casi todas las variables y no hay nada que proyectar. El programa de
Warren sobre los alumnos de una facultad es el caso contrario. Cada
alumno está inscripto en las cinco materias de su año, y cada materia se
dicta en 50 franjas horarias; la pregunta es en qué franjas cursa algún
alumno de cada año:

<!-- ejemplo: capitulo-85/soluciones.pl predicado: franjas/1 -->
```prolog
%!  franjas(-Clausulas:list) is det.
%
%   El programa de Warren sobre los alumnos de una facultad, con datos
%   generados: 1000 alumnos, el alumno A en el año A mod 4 + 1; cada uno
%   inscripto en las 5 materias de su año, 10 * Anio + K; cada materia con
%   50 franjas horarias. franja_del_anio(Anio, F): algún alumno de Anio
%   cursa en la franja F.
franjas(Clausulas) :-
    findall((alumno(A, Anio) :- true),
            ( between(1, 1000, A), Anio is A mod 4 + 1 ),
            Alumnos),
    findall((inscripto(A, M) :- true),
            ( between(1, 1000, A), Anio is A mod 4 + 1,
              between(1, 5, K), M is 10 * Anio + K ),
            Inscripciones),
    findall((horario(M, F) :- true),
            ( between(1, 4, Anio), between(1, 5, K), M is 10 * Anio + K,
              between(1, 50, J), F is 100 * M + J ),
            Horarios),
    append([Alumnos, Inscripciones, Horarios,
            [ (franja_del_anio(Anio, F) :-
                  alumno(A, Anio), inscripto(A, M), horario(M, F)) ]],
           Clausulas).
```

```text
?- franjas(Cs), suplementarios(Cs, Ss), respuestas(Cs, franja_del_anio(_, _), Rs, C), respuestas(Ss, franja_del_anio(_, _), Rs, C1), length(Rs, N).
C = costo(1, 250000),
C1 = costo(3, 7000),
N = 1000.
```

La regla original deriva una cabeza por cada alumno, cada materia suya y
cada franja: 1 000 × 5 × 50 = 250 000, para 1 000 respuestas distintas.
Con los suplementarios, `sup_franja_del_anio_7001_2(Anio, M)` deja afuera
al alumno: tiene solo los 20 pares de año y materia, y cada uno se une
con sus 50 franjas una vez. Son 1 000 + 5 000 + 1 000 = 7 000
derivaciones, y las inferencias bajan de unas 2 315 000 a 1 587 000; la
mayor parte de lo que queda es cargar los 7 000 hechos en la base, que
las dos formas pagan igual. La transformación conviene cuando un prefijo
del cuerpo tiene muchas soluciones que el resto no distingue: es el caso
de `suppl_table` de Warren, un predicado intermedio para una unión
seguida de una proyección. Las pruebas `soluciones:suplementarios_sd` y
`soluciones:suplementarios_franjas` verifican las derivaciones con su
valor exacto, y las inferencias dentro de un 10 %.

## 5

<!-- ejemplo: capitulo-85/soluciones.pl predicado: misma_profundidad/1 -->
```prolog
%!  misma_profundidad(-Clausulas:list) is det.
%
%   sd/2 de Nilsson y Małuszyński sobre los diez hechos child/2 de su
%   ejercicio 15.2, con nodo/1 para que sd(X, X) sea segura.
misma_profundidad(Clausulas) :-
    Hijos = [b-a, c-a, d-b, e-b, f-c, g-d, h-d, i-e, j-f, k-f],
    findall((child(X, Y) :- true), member(X-Y, Hijos), Cs),
    findall((nodo(N) :- true),
            ( member(X-Y, Hijos), ( N = X ; N = Y ) ),
            Ns0),
    sort(Ns0, Ns),
    append([Cs, Ns,
            [ (sd(X, X) :- nodo(X)),
              (sd(X, Y) :- child(X, Z), child(Y, W), sd(Z, W)) ]],
           Clausulas).
```

`sd(X, X)` necesita un literal que ligue X: `nodo/1`, con cada nodo del
árbol, la hace segura.

```prolog
?- misma_profundidad(Cs), respuestas(Cs, sd(d, X), Rs, C), respuestas_magicas(Cs, sd(d, X), Rs2, C2).
Cs = [(child(b, a):-true), (child(c, a):-true), (child(d, b):-true), (child(e, b):-true), (child(f, c):-true), (child(g, d):-true), (child(h, d):-true), (child(..., ...):-true), (... :- ...)|...],
Rs = Rs2, Rs2 = [sd(d, d), sd(d, e), sd(d, f)],
C = costo(5, 49),
C2 = costo(7, 23).
```

`d`, `e` y `f` están en la tercera generación. El modelo entero tiene 39
pares; la magia deriva 23 átomos. El programa transformado muestra lo que
Nilsson y Małuszyński dicen del paso de información:

```text
m_sd_bb(A, B) :-
    m_sd_bf(C),
    child(C, A),
    child(_, B).
```

El segundo `child(Y, W)` no tiene ninguna variable ligada, porque Y es el
argumento libre de la consulta: la regla mágica llama a `sd_bb` con el
padre de `d` y con **todos** los nodos que tienen hijos. Un orden mejor
resolvería primero el padre de `d` y después recorrería los nodos de la
misma generación, pero eso necesita un paso de información distinto del
de izquierda a derecha.

## 6

<!-- ejemplo: capitulo-85/soluciones.pl predicado: debe_camino/2 evita_camino/2 programa_camino/1 -->
```prolog
%!  debe_camino(?X, ?Y) is nondet.
%
%   En el camino de 100 personas, X le debe dinero a Y: cada una a la
%   siguiente, y la 100 a nadie.
debe_camino(X, Y) :-
    between(1, 99, X),
    Y is X + 1.

%!  evita_camino(?X, ?Y) is nondet.
%
%   X evita a Y en el camino, con la recursión a la izquierda, tabulada.
evita_camino(X, Y) :-
    debe_camino(X, Y).
evita_camino(X, Y) :-
    evita_camino(X, Z),
    debe_camino(Z, Y).

%!  programa_camino(-Clausulas:list) is det.
%
%   El mismo programa como datos.
programa_camino(Clausulas) :-
    findall((debe(X, Y) :- true), debe_camino(X, Y), Hechos),
    append(Hechos,
           [ (evita(X, Y) :- debe(X, Y)),
             (evita(X, Y) :- evita(X, Z), debe(Z, Y)) ],
           Clausulas).
```

```prolog
?- tablas(evita_camino(1, _), T1, R1), tablas(evita_camino(50, _), T2, R2).
T1 = T2, T2 = 1,
R1 = 99,
R2 = 50.

?- programa_camino(Cs), magia(Cs, evita(1, _), M1, A1), magia(Cs, evita(50, _), M2, A2).
Cs = [(debe(1, 2):-true), (debe(2, 3):-true), (debe(3, 4):-true), (debe(4, 5):-true), (debe(5, 6):-true), (debe(6, 7):-true), (debe(7, 8):-true), (debe(..., ...):-true), (... :- ...)|...],
M1 = M2, M2 = 1,
A1 = 99,
A2 = 50.
```

Con la recursión a la izquierda hay una sola tabla y un solo hecho
mágico en los dos casos; las respuestas son las personas que siguen en el
camino: 99 desde la 1 y 50 desde la 50. Sin el ciclo, la cantidad de
respuestas depende del punto de partida, y las dos medidas siguen
coincidiendo.

## 7

<!-- ejemplo: capitulo-85/soluciones.pl predicado: reducciones/1 -->
```prolog
%!  reducciones(-Clausulas:list) is det.
%
%   El ejemplo de negación estratificada de Warren, con sus doce hechos
%   reduce/2.
reducciones(Clausulas) :-
    Pares = [a-b, b-c, c-d, d-e, e-c, a-f, f-g, g-f, g-k, f-h, h-i, i-h],
    findall((reduce(X, Y) :- true), member(X-Y, Pares), Hechos),
    append(Hechos,
           [ (reachable(X, Y) :- reduce(X, Y)),
             (reachable(X, Y) :- reachable(X, Z), reduce(Z, Y)),
             (reducible(X) :- reachable(X, Y), \+ reachable(Y, X)),
             (fully_reduce(X, Y) :- reachable(X, Y), \+ reducible(Y)) ],
           Clausulas).
```

```prolog
?- reducciones(Cs), componentes(Cs, Ks), respuestas(Cs, fully_reduce(a, Y), Rs, C).
Cs = [(reduce(a, b):-true), (reduce(b, c):-true), (reduce(c, d):-true), (reduce(d, e):-true), (reduce(e, c):-true), (reduce(a, f):-true), (reduce(f, g):-true), (reduce(..., ...):-true), (... :- ...)|...],
Ks = [[reachable/2], [reducible/1], [fully_reduce/2]],
Rs = [fully_reduce(a, c), fully_reduce(a, d), fully_reduce(a, e), fully_reduce(a, h), fully_reduce(a, i), fully_reduce(a, k)],
C = costo(7, 96).
```

Son los tres estratos de Warren, y las seis respuestas de su texto:
`c`, `d` y `e` forman una componente final del grafo de `reduce/2`,
`h` e `i` otra, y `k` no tiene sucesores. `f` y `g` no están: forman un
ciclo, pero desde `g` se llega a `k`, que no vuelve.

## 8

<!-- ejemplo: capitulo-85/soluciones.pl predicado: quitar_hechos/4 hecho_de/2 volver_a_agregar/3 -->
```prolog
%!  quitar_hechos(+Clausulas:list, +Hechos:list, -Modelo:list, -Costo)
%!      is det.
%
%   Modelo es el de Clausulas sin los Hechos, calculado desde cero con
%   evaluar/3; Costo, el de ese cálculo.
quitar_hechos(Clausulas, Hechos, Modelo, Costo) :-
    exclude(hecho_de(Hechos), Clausulas, Quedan),
    evaluar(Quedan, Modelo, Costo).

%!  hecho_de(+Hechos:list, +Clausula) is semidet.
%
%   Clausula es el hecho H :- true de uno de los Hechos.
hecho_de(Hechos, H :- true) :-
    memberchk(H, Hechos).

%!  volver_a_agregar(+Clausulas:list, +Hechos:list, -Costo) is det.
%
%   Costo es el de agregar los Hechos, con agregar_hechos/4, al modelo de
%   Clausulas sin ellos.
volver_a_agregar(Clausulas, Hechos, Costo) :-
    exclude(hecho_de(Hechos), Clausulas, Quedan),
    iniciar(Quedan, Estado, _),
    agregar_hechos(Hechos, Estado, _, Costo).
```

```prolog
?- clausulas(cadena(40), Cs), quitar_hechos(Cs, [arco(20, 21)], M, C), length(M, N).
Cs = [(arco(0, 1):-true), (arco(1, 2):-true), (arco(2, 3):-true), (arco(3, 4):-true), (arco(4, 5):-true), (arco(5, 6):-true), (arco(6, 7):-true), (arco(..., ...):-true), (... :- ...)|...],
M = [arco(0, 1), arco(1, 2), arco(2, 3), arco(3, 4), arco(4, 5), arco(5, 6), arco(6, 7), arco(7, 8), arco(..., ...)|...],
C = costo(21, 400),
N = 439.

?- clausulas(cadena(40), Cs), volver_a_agregar(Cs, [arco(20, 21)], C).
Cs = [(arco(0, 1):-true), (arco(1, 2):-true), (arco(2, 3):-true), (arco(3, 4):-true), (arco(4, 5):-true), (arco(5, 6):-true), (arco(6, 7):-true), (arco(..., ...):-true), (... :- ...)|...],
C = costo(21, 420).
```

Sin el arco quedan dos filas de 20 arcos, con 210 caminos cada una: 39
arcos y 400 caminos. Recalcular cuesta 400 derivaciones, una por camino.
Volver a agregar el arco cuesta 420: los 21 × 20 caminos que lo cruzan,
de cada nodo de la primera fila a cada nodo de la segunda. Recalcular
desde cero el modelo de 40 arcos costaría 820. Agregar es barato porque
el paso semi-ingenuo solo produce lo nuevo; quitar no tiene un paso
equivalente, porque un camino que usaba el arco quitado podría tener otra
derivación, y saberlo exige la técnica de DRed.

## 9

<!-- ejemplo: capitulo-85/soluciones.pl predicado: segura_magica/4 -->
```prolog
%!  segura_magica(+K, +Celda, -Respuestas:list, -Costo) is det.
%
%   Respuestas son las de segura(N), con N el número de Celda, en el
%   programa del Wumpus con el conocimiento K transformado para esa
%   consulta.
segura_magica(K, X-Y, Respuestas, Costo) :-
    N is 10 * X + Y,
    programa_wumpus(K, Clausulas),
    respuestas_magicas(Clausulas, segura(N), Respuestas, Costo).
```

```prolog
?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), segura_magica(K, 2-2, Rs, C), programa_wumpus(K, Cs), evaluar(Cs, _, C0).
K = c(4, 1-2, [1-1-[], 2-1-[brisa], 1-2-[hedor]], no, si, vivo([]), []),
Rs = [segura(22)],
C = costo(11, 87),
Cs = [(celda(11):-true), (celda(12):-true), (celda(13):-true), (celda(14):-true), (celda(21):-true), (celda(22):-true), (celda(23):-true), (celda(...):-true), (... :- ...)|...],
C0 = costo(6, 104).
```

La celda es segura, con 87 derivaciones en lugar de 104. La diferencia
es pequeña porque las reglas usan negados a `sin_wumpus_vecina/1` y a
`otro_wumpus/2`, que se evalúan completos, y `sin_wumpus/1` necesita
saber dónde está el wumpus, `wumpus(W)` con W libre, que también se
calcula entero. Lo único que la consulta restringe es `sin_pozo/1` y la
última regla.

## 10

<!-- ejemplo: capitulo-85/soluciones.pl predicado: restar_con/3 -->
```prolog
%!  restar_con(+Sacar:list(integer), +N:integer, -Jugadas:list) is det.
%
%   Jugadas son las del juego de restar con N fichas, en el que cada
%   jugador saca una de las cantidades de Sacar.
restar_con(Sacar, N, Jugadas) :-
    findall(X-Y,
            ( between(1, N, X),
              member(M, Sacar),
              Y is X - M,
              Y >= 0 ),
            Jugadas).
```

Pierde el que mueve en 0; en 1, 3 y 4 gana sacando todo; en 2 solo puede
sacar 1 y deja 1, y pierde. Desde 5 y 6 se deja 2; desde 7 todas las
jugadas dejan 6, 4 o 3, que ganan. El patrón se repite cada 7: pierden
las posiciones que dan resto 0 o 2 al dividirlas por 7.

```prolog
?- restar_con([1, 3, 4], 20, Js), retrogrado(Js, T, N), findall(P, member(P-pierde(_), T), Ps).
Js = [1-0, 2-1, 3-2, 3-0, 4-3, 4-1, 4-0, 5-4, ... - ...|...],
T = [0-pierde(0), 1-gana(1), 2-pierde(2), 3-gana(1), 4-gana(1), 5-gana(3), 6-gana(3), 7-pierde(...), ... - ...|...],
N = 55,
Ps = [0, 2, 7, 9, 14, 16].

?- restar_con([1, 3, 4], 1000, Js), rondas(Js, T1, N1), retrogrado(Js, T2, N2), T1 == T2.
Js = [1-0, 2-1, 3-2, 3-0, 4-3, 4-1, 4-0, 5-4, ... - ...|...],
T1 = T2, T2 = [0-pierde(0), 1-gana(1), 2-pierde(2), 3-gana(1), 4-gana(1), 5-gana(3), 6-gana(3), 7-pierde(...), ... - ...|...],
N1 = 857564,
N2 = 2995.
```

`retrogrado/3` recorre cada una de las 2 995 jugadas una vez; `rondas/3`,
857 564 arcos.

## 11

<!-- ejemplo: capitulo-85/soluciones.pl predicado: evaluar_ingenuo/3 ingenua_componente/4 cabeza_en/2 -->
```prolog
%!  evaluar_ingenuo(+Clausulas:list, -Modelo:list, -Costo) is det.
%
%   El modelo de evaluar/3, con la evaluación ingenua en cada componente:
%   cada paso aplica todas las reglas de la componente a la base entera,
%   hasta que no aparece nada nuevo.
evaluar_ingenuo(Clausulas, Modelo, Costo) :-
    separar(Clausulas, Hechos, Reglas),
    componentes(Clausulas, Componentes),
    base(Hechos, Base0),
    foldl(ingenua_componente(Reglas), Componentes,
          Base0-costo(0, 0), Base-Costo),
    atomos(Base, Modelo).

%!  ingenua_componente(+Reglas:list, +Componente:list, +Estado0,
%!                     -Estado) is det.
%
%   Estado0 es Base0-Costo0; Estado agrega lo que derivan las reglas de
%   Componente, aplicadas a la base entera hasta el punto fijo.
ingenua_componente(Reglas, Componente, Base0-costo(P0, D0), Base-Costo) :-
    include(cabeza_en(Componente), Reglas, DeLaComponente),
    findall(H, ( member(r(H, Ls), DeLaComponente), cumplir(Ls, Base0) ),
            Hs),
    length(Hs, D),
    P is P0 + 1,
    D1 is D0 + D,
    agregar(Hs, Base0, Base1, Nuevos),
    (   Nuevos == []
    ->  Base = Base1,
        Costo = costo(P, D1)
    ;   ingenua_componente(Reglas, Componente, Base1-costo(P, D1),
                           Base-Costo)
    ).

%!  cabeza_en(+Componente:list, +Regla) is semidet.
%
%   La cabeza de Regla es de un predicado de Componente.
cabeza_en(Componente, r(H, _)) :-
    functor(H, Nombre, Aridad),
    memberchk(Nombre/Aridad, Componente).
```

```prolog
?- clausulas(cadena(40), Cs), evaluar_ingenuo(Cs, M, C), evaluar(Cs, M, C2).
Cs = [(arco(0, 1):-true), (arco(1, 2):-true), (arco(2, 3):-true), (arco(3, 4):-true), (arco(4, 5):-true), (arco(5, 6):-true), (arco(6, 7):-true), (arco(..., ...):-true), (... :- ...)|...],
M = [arco(0, 1), arco(1, 2), arco(2, 3), arco(3, 4), arco(4, 5), arco(5, 6), arco(6, 7), arco(7, 8), arco(..., ...)|...],
C = costo(41, 22960),
C2 = costo(41, 820).

?- clausulas(grafo, Cs), evaluar_ingenuo(Cs, M, C), evaluar(Cs, M, C2).
Cs = [(arco(a, b):-true), (arco(b, c):-true), (arco(c, a):-true), (arco(c, d):-true), (nodo(a):-true), (nodo(b):-true), (nodo(c):-true), (nodo(...):-true), (... :- ...)|...],
M = [nodo(a), nodo(b), nodo(c), nodo(d), arco(a, b), arco(b, c), arco(c, a), arco(c, d), camino(..., ...)|...],
C = costo(6, 48),
C2 = costo(5, 20).
```

Los modelos son iguales, porque la segunda consulta unifica el modelo de
`evaluar/3` con el de `evaluar_ingenuo/3`. En la fila, la evaluación
ingenua deriva 22 960 cabezas, la suma de los caminos conocidos en cada
paso, contra 820; en `grafo`, el ciclo hace que `camino/2` necesite cuatro
pasos que repiten lo anterior. El número de pasos es el mismo en la fila:
la semi-ingenua no acorta la sucesión, solo deja de repetir lo ya
derivado en cada paso.
