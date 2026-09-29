# Soluciones del capítulo 62 — Proyecto: un demostrador de teoremas

El código de esta página está en `ejemplos/capitulo-62/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `comparacion.pl`, que
carga todas las versiones del capítulo, el demostrador proposicional de
`resolucion.pl` y el verificador, y no modifica ninguno de ellos. Los
ejercicios 1, 3, 5 y 7 se resuelven con los archivos del capítulo: sus
consultas usan `leer_formula/2` de `lector.pl`, `clausulas_texto/2` de
`clausal.pl` y `clausulas_fo/2` y `clausulas_fo_texto/2` de
`primer_orden.pl`. Es `% solo-local`, porque carga otros archivos.

## 1

La precedencia, de la que liga más a la que liga menos, es ¬ y los
cuantificadores, ∧, ∨, →, ↔; → se asocia a la derecha:

```prolog
?- leer_formula("p → q ∨ r ∧ s", F).
F = si(at(p), o(at(q), y(at(r), at(s)))).

?- leer_formula("¬∀x p(x) ∧ q", F).
F = y(no(todo(_A, at(p(_A)))), at(q)).

?- leer_formula("(p → q) → r → s", F).
F = si(si(at(p), at(q)), si(at(r), at(s))).

?- leer_formula("∀x ∃y ama(x, y) ∧ ∃y ama(y, x)", F).
F = y(todo(_A, existe(_B, at(ama(_A, _B)))), existe(_C, at(ama(_C, x)))).
```

En la segunda, la negación alcanza solo a `∀x p(x)`, y el cuantificador
solo a `p(x)`. En la tercera, los paréntesis agrupan la primera
implicación y la asociación a la derecha, las otras dos. En la cuarta, el
∀x alcanza solo a `∃y ama(x, y)`, porque un cuantificador liga tanto como
la negación: el término tiene tres variables, `_A` de ∀x, `_B` del primer
∃y y `_C` del segundo, y la `x` de `ama(y, x)` está fuera del alcance de
∀x y se lee como la constante `x`. Para que la fórmula diga lo que
probablemente quiere decir, se escribe `∀x (∃y ama(x, y) ∧ ∃y ama(y, x))`.

## 2

Una contradicción es una fórmula cuya negación es una tautología, de modo
que `clasificar/2` pregunta dos veces a `tautologia/2`:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: clasificar/2 -->
```prolog
%!  clasificar(+Texto, -Clase) is det.
%
%   Clase es tautologia, contradiccion o contingente, según la fórmula
%   sin cuantificadores que Texto escribe: una contradicción es una
%   fórmula cuya negación es una tautología.
clasificar(Texto, Clase) :-
    leer_formula(Texto, F),
    (   tautologia(clpb, F)
    ->  Clase = tautologia
    ;   tautologia(clpb, no(F))
    ->  Clase = contradiccion
    ;   Clase = contingente
    ).
```

```prolog
?- clasificar("p ∨ ¬p", C1), clasificar("p ∧ ¬p", C2), clasificar("p → q", C3), clasificar("(p → q) ∨ (q → p)", C4).
C1 = C4, C4 = tautologia,
C2 = contradiccion,
C3 = contingente.
```

La cuarta es una tautología: si `q` es verdadera, `p → q` lo es; si es
falsa, `q → p` lo es.

## 3

```prolog
?- clausulas_texto("(p ∧ q) ∨ (r ∧ s)", Cs), length(Cs, N).
Cs = [[+p, +r], [+p, +s], [+q, +r], [+q, +s]],
N = 4.

?- clausulas_texto("¬((p ∨ q) → r)", Cs), length(Cs, N).
Cs = [[+p, +q], [-r]],
N = 2.

?- clausulas_texto("p ↔ q", Cs), length(Cs, N).
Cs = [[+p, -q], [+q, -p]],
N = 2.

?- clausulas_texto("(p ↔ q) ↔ r", Cs), length(Cs, N).
Cs = [[+p, +q, +r], [+p, -q, -r], [+q, -p, -r], [+r, -p, -q]],
N = 4.
```

La primera tiene 2 × 2 cláusulas, una por cada manera de elegir un átomo
de cada conjunción. La última es verdadera cuando una cantidad par de sus
tres átomos es falsa; cada cláusula excluye una de las cuatro asignaciones
con una cantidad impar de átomos falsos: una cláusula de tres literales
es falsa en exactamente una asignación de sus tres átomos.

## 4

`definir/5` da a cada conjunción y a cada disyunción un átomo `d(N)` y
las cláusulas que dicen que `d(N)` implica la subfórmula. Alcanza con la
implicación en un sentido porque, en forma normal negada, cada subfórmula
aparece sin negar: un modelo de las cláusulas da un modelo de la fórmula,
y un modelo de la fórmula se extiende a las cláusulas haciendo verdadero
cada `d(N)` cuya subfórmula es verdadera:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: clausulas_def/2 definir/5 -->
```prolog
%!  clausulas_def(+F, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal definicional de F, una fórmula sin
%   cuantificadores: satisfacible si y solo si F lo es. Cada conjunción y
%   cada disyunción de la forma normal negada recibe un átomo d(N) y las
%   cláusulas que dicen que d(N) implica la subfórmula.
clausulas_def(F, Clausulas) :-
    fnn(F, G),
    definir(G, 1, _, L, Cs),
    maplist(sort, [[L]|Cs], Clausulas).

%!  definir(+G, +N0:integer, -N:integer, -L, -Cs:list) is det.
%
%   L es el literal que representa a G, en forma normal negada, y Cs las
%   cláusulas que lo definen; N0 y N numeran los átomos nuevos.
definir(at(A), N, N, +A, []).
definir(no(at(A)), N, N, -A, []).
definir(y(A, B), N0, N, +d(N0), [[-d(N0), LA], [-d(N0), LB]|Cs]) :-
    N1 is N0 + 1,
    definir(A, N1, N2, LA, CA),
    definir(B, N2, N, LB, CB),
    append(CA, CB, Cs).
definir(o(A, B), N0, N, +d(N0), [[-d(N0), LA, LB]|Cs]) :-
    N1 is N0 + 1,
    definir(A, N1, N2, LA, CA),
    definir(B, N2, N, LB, CB),
    append(CA, CB, Cs).
```

```prolog
?- forall(between(1, 8, N), (comparar_def(N, D, E), format("~w ~w ~w~n", [N, D, E]))).
1 2 3
2 4 6
3 8 9
4 16 12
5 32 15
6 64 18
7 128 21
8 256 24
true.
```

La forma definicional tiene 3n cláusulas: la unitaria de la raíz, dos por
cada una de las n conjunciones y una por cada una de las n − 1
disyunciones. Desde n = 4 es más pequeña que la forma por distribución, que
tiene $2^n$. La refutación de `(p ∧ q) ∨ (p ∧ ¬q) → p` pasa de un paso a
cinco, porque los átomos nuevos se tienen que eliminar uno por uno:

```prolog
?- leer_formula("(p ∧ q) ∨ (p ∧ ¬q) → p", F), clausulas_def(no(F), Cs), refutar(Cs, 8, P), length(P, L).
F = si(o(y(at(p), at(q)), y(at(p), no(at(q)))), at(p)),
Cs = [[+d(1)], [+d(2), -d(1)], [-p, -d(1)], [+d(3), +d(4), -d(2)], [+p, -d(3)], [+q, -d(...)], [+p, - ...], [- ...|...]],
P = [r(2, 4, [+d(3), +d(4), -d(1)]), r(5, 9, [+p, +d(4), -d(1)]), r(7, 10, [+p, -d(1)]), r(3, 11, [-d(1)]), r(1, 12, [])],
L = 5.
```

## 5

El conjunto de Hein tiene dos pares de cláusulas que se resuelven en una
cláusula unitaria: `¬p ∨ q` con `p ∨ q` da `q`, y `p ∨ ¬q` con `¬p ∨ ¬q`
da `¬q`. Los dos resolventes se resuelven en □:

<!-- ejemplo: capitulo-62/verificador.pl predicado: verificar/1 -->
```prolog
%!  verificar(+Prueba) is semidet.
%
%   Prueba, de la forma prueba(Clausulas, Pasos), es una refutación
%   correcta de las Clausulas: cada paso es correcto y el último produce
%   la cláusula vacía.
verificar(prueba(Clausulas, Pasos)) :-
    verificar_pasos(Pasos, Clausulas, Ultima),
    Ultima == [].
```

```prolog
?- verificar(prueba([[-p, +q], [+p, +q], [+p, -q], [-p, -q]], [r(1, 2, [+q]), r(3, 4, [-q]), r(5, 6, [])])).
true.

?- verificar(prueba([[-p, +q], [+p, +q], [+p, -q], [-p, -q]], [r(1, 2, [+q]), r(2, 4, [-q]), r(5, 6, [])])).
false.
```

En la segunda, el paso 2 resuelve `p ∨ q` con `¬p ∨ ¬q`: el resolvente
es `q ∨ ¬q`, no `¬q`, y el verificador no puede rehacer el paso. El
[ejercicio 6](#6) dice cuál es el paso incorrecto.

## 6

`primer_error/2` recorre los pasos con `paso_correcto/3` del verificador,
sin cambiarlo, y se detiene en el primero que no puede rehacer:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: primer_error/2 primer_error/4 -->
```prolog
%!  primer_error(+Prueba, -K) is det.
%
%   K es el número del primer paso incorrecto de Prueba; ninguno si todos
%   son correctos y el último produce la cláusula vacía, e incompleta si
%   todos son correctos y ninguno la produce.
primer_error(prueba(Clausulas, Pasos), K) :-
    primer_error(Pasos, Clausulas, 1, K).

%!  primer_error(+Pasos:list, +Clausulas:list, +I:integer, -K) is det.
%
%   Como primer_error/2; I es el número del primer paso de Pasos.
primer_error([], Clausulas, _, K) :-
    (   last(Clausulas, [])
    ->  K = ninguno
    ;   K = incompleta
    ).
primer_error([Paso|Pasos], Clausulas, I, K) :-
    (   paso_correcto(Paso, Clausulas, C)
    ->  append(Clausulas, [C], Clausulas1),
        I1 is I + 1,
        primer_error(Pasos, Clausulas1, I1, K)
    ;   K = I
    ).
```

```prolog
?- primer_error(prueba([[-p, +q], [+p, +q], [+p, -q], [-p, -q]], [r(1, 2, [+q]), r(2, 4, [-q]), r(5, 6, [])]), K).
K = 2.
```

## 7

<!-- ejemplo: capitulo-62/resolucion_fo.pl predicado: demostrar_fo/3 -->
```prolog
%!  demostrar_fo(+Texto, +Max:integer, -Prueba) is semidet.
%
%   Prueba es la refutación más corta, de a lo sumo Max pasos, de la
%   negación de la fórmula cerrada que Texto escribe. Falla si no hay
%   ninguna de Max pasos o menos.
demostrar_fo(Texto, Max, prueba(Clausulas, Pasos)) :-
    leer_formula(Texto, F),
    clausulas_fo(no(F), Clausulas),
    refutar_fo(Clausulas, Max, Pasos).
```

```prolog
?- demostrar_fo("(∃y ∀x ama(x, y)) → ∀x ∃y ama(x, y)", 5, P), escribir_prueba(P).
  1.  ama(A, sk1)                     premisa
  2.  ¬ama(sk2(A), B)                 premisa
  3.  □                               resolvente de 1 y 2
P = prueba([[+ama(_A, sk1)], [-ama(sk2(_A), _)]], [r(1, 2, [])]).

?- clausulas_fo_texto("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", Cs).
Cs = [[+ama(_A, sk1(_A))], [-ama(sk2(_A, _B), _B)]].
```

En la implicación válida, el existencial ∃y está primero: la persona a
quien todos aman es una constante, `sk1`, y `ama(A, sk1)` unifica con
`ama(sk2(A'), B)` ligando `A` a `sk2(A')` y `B` a `sk1`. En la inversa,
cada existencial depende de un universal: el amado de `A` es `sk1(A)`, y
quien no ama a `B` es `sk2(…, B)`. Unificar `ama(A, sk1(A))` con
`ama(sk2(A', B), B)` exige `B = sk1(A)` y `A = sk2(A', B)`, es decir, que
`A` contenga a `A`: la comprobación de ocurrencia lo impide, y no hay
refutación.

## 8

`skolemizar_fnn/5` recorre la fórmula en forma normal negada llevando la
lista de las variables universales que rodean al punto actual, y cada
existencial se liga a un término de esas variables. Después, la forma
prenexa solo tiene universales, y la matriz pasa a cláusulas:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: clausulas_alcance/2 skolemizar_fnn/5 -->
```prolog
%!  clausulas_alcance(+F, -Clausulas:list) is det.
%
%   Como clausulas_fo/2, pero skolemiza antes de la forma prenexa: cada
%   término de Skolem depende solo de las variables universales cuyo
%   cuantificador rodea al existencial.
clausulas_alcance(F, Clausulas) :-
    fnn(F, G0),
    renombrar(G0, G),
    skolemizar_fnn(G, [], 1, _, H),
    prenexa(H, _, Matriz),
    fnc(Matriz, Clausulas).

%!  skolemizar_fnn(+G, +Us:list, +N0:integer, -N:integer, -H) is det.
%
%   H es G, en forma normal negada, sin cuantificadores existenciales:
%   cada variable existencial se liga a skN(Us…), donde Us son las
%   variables universales que la rodean.
skolemizar_fnn(at(A), _, N, N, at(A)).
skolemizar_fnn(no(A), _, N, N, no(A)).
skolemizar_fnn(y(A, B), Us, N0, N, y(HA, HB)) :-
    skolemizar_fnn(A, Us, N0, N1, HA),
    skolemizar_fnn(B, Us, N1, N, HB).
skolemizar_fnn(o(A, B), Us, N0, N, o(HA, HB)) :-
    skolemizar_fnn(A, Us, N0, N1, HA),
    skolemizar_fnn(B, Us, N1, N, HB).
skolemizar_fnn(todo(X, F), Us, N0, N, todo(X, H)) :-
    append(Us, [X], Us1),
    skolemizar_fnn(F, Us1, N0, N, H).
skolemizar_fnn(existe(X, F), Us, N0, N, H) :-
    skolemizar([existe(X)], Us, N0, N1),
    skolemizar_fnn(F, Us, N1, N, H).
```

```prolog
?- leer_formula("¬((∀x ∃y ama(x, y)) → ∃y ∀x ama(x, y))", F), clausulas_alcance(F, Cs).
F = no(si(todo(_A, existe(_B, at(ama(_A, _B)))), existe(_C, todo(_D, at(ama(_D, _C)))))),
Cs = [[+ama(_E, sk1(_E))], [-ama(sk2(_F), _F)]].
```

`sk2` tiene un argumento en lugar de dos: la variable existencial de la
segunda cláusula está en el alcance de un solo universal. La forma prenexa
de `clausulas_fo/2` la había puesto después de los dos.

## 9

`derivar_unitaria/2` es `derivar/2` de `resolucion.pl` con una condición
más: uno de los dos padres tiene un solo literal.

<!-- ejemplo: capitulo-62/soluciones.pl predicado: derivar_unitaria/2 -->
```prolog
%!  derivar_unitaria(?Pasos:list, +Clausulas:list) is nondet.
%
%   Como derivar/2 de resolucion.pl, con un padre unitario en cada paso.
derivar_unitaria([], Clausulas) :-
    memberchk([], Clausulas).
derivar_unitaria([r(I, J, R)|Pasos], Clausulas) :-
    nth1(J, Clausulas, C2),
    nth1(I, Clausulas, C1),
    I < J,
    (   C1 = [_]
    ;   C2 = [_]
    ),
    resolvente(C1, C2, R),
    \+ memberchk(R, Clausulas),
    append(Clausulas, [R], Clausulas1),
    derivar_unitaria(Pasos, Clausulas1).
```

```prolog
?- clausulas_texto("¬((a → b) ∧ (b → c) → (a → c))", Cs), refutar_unitaria(Cs, 5, P).
Cs = [[+a], [+b, -a], [+c, -b], [-c]],
P = [r(1, 2, [+b]), r(3, 4, [-b]), r(5, 6, [])].

?- refutar_unitaria([[-p, +q], [+p, +q], [+p, -q], [-p, -q]], 10, P).
false.
```

El conjunto de Hein no tiene ninguna cláusula unitaria, y la resolución
unitaria no puede dar el primer paso. La resolución unitaria es completa
para las cláusulas de Horn, porque en un conjunto insatisfacible de
cláusulas de Horn siempre hay un hecho, una cláusula unitaria positiva;
`p ∨ q` no es de Horn, y el conjunto de Hein necesita un paso entre dos
cláusulas de dos literales.

## 10

<!-- ejemplo: capitulo-62/soluciones.pl predicado: decidir/2 -->
```prolog
%!  decidir(+Texto, -Veredicto) is det.
%
%   Veredicto es teorema(Prueba), con una refutación de a lo sumo 10
%   pasos de la negación de la fórmula que Texto escribe, o
%   contraejemplo(A), con una asignación que la hace falsa. Si no hay
%   ninguna de las dos, la refutación necesita más de 10 pasos, y el
%   Veredicto es desconocido.
decidir(Texto, Veredicto) :-
    leer_formula(Texto, F),
    (   demostrar(Texto, 10, Prueba)
    ->  Veredicto = teorema(Prueba)
    ;   once(contraejemplo(F, A))
    ->  Veredicto = contraejemplo(A)
    ;   Veredicto = desconocido
    ).
```

```prolog
?- decidir("(p → q) → (q → p)", V).
V = contraejemplo([p-0, q-1]).

?- decidir("((p → q) → p) → p", V).
V = teorema(prueba([[+p], [+p, -q], [-p]], [r(1, 3, [])])).
```

El caso `desconocido` existe porque el máximo de 10 pasos puede ser
menor que la refutación más corta; con `library(clpb)` se podría decidir
primero si la fórmula es un teorema y buscar la prueba después, sin
máximo, porque la búsqueda termina cuando hay una. Las pruebas de
`soluciones.plt` verifican la prueba con `verificar/1` y el contraejemplo
con `valor_en/3`, que evalúa la fórmula con la asignación:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: valor_en/3 -->
```prolog
%!  valor_en(+F, +A:list, -V) is det.
%
%   V, 0 o 1, es el valor de F, sin cuantificadores, con la asignación A
%   de pares Átomo-Valor.
valor_en(at(P), A, V) :-
    memberchk(P-V, A).
valor_en(no(F), A, V) :-
    valor_en(F, A, W),
    V is 1 - W.
valor_en(y(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is min(VF, VG).
valor_en(o(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is max(VF, VG).
valor_en(si(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    V is max(1 - VF, VG).
valor_en(sii(F, G), A, V) :-
    valor_en(F, A, VF),
    valor_en(G, A, VG),
    (   VF =:= VG
    ->  V = 1
    ;   V = 0
    ).
```

## 11

`saturar/4` calcula en cada nivel todos los resolventes de dos cláusulas
que no están subsumidos por una anterior, los agrega, y repite:

<!-- ejemplo: capitulo-62/soluciones.pl predicado: saturar/4 subsumida/2 -->
```prolog
%!  saturar(+Clausulas:list, +N0:integer, -N:integer, -Resultado) is det.
%
%   Como saturar/3; N0 es la cantidad de niveles ya calculados.
saturar(Clausulas, N, N, refutada) :-
    memberchk([], Clausulas),
    !.
saturar(Clausulas, N0, N, Resultado) :-
    findall(R,
            ( append(_, [C1|Resto], Clausulas),
              member(C2, Resto),
              resolvente(C1, C2, R),
              \+ subsumida(R, Clausulas)
            ),
            Rs0),
    sort(Rs0, Rs),
    (   Rs == []
    ->  N = N0,
        Resultado = saturada
    ;   append(Clausulas, Rs, Clausulas1),
        N1 is N0 + 1,
        saturar(Clausulas1, N1, N, Resultado)
    ).

%!  subsumida(+R:list, +Clausulas:list) is semidet.
%
%   Alguna de las Clausulas, sin variables, está contenida en R.
subsumida(R, Clausulas) :-
    member(C, Clausulas),
    ord_subset(C, R),
    !.
```

```prolog
?- palomar(2, _F), clausulas_fo(no(_F), _Cs), time(saturar(_Cs, N, R)), time(refutar_fo(_Cs, 20, _)).
% 257,372 inferences, 0.016 CPU in 0.031 seconds (51% CPU, 16471808 Lips)
% 6,296,082 inferences, 1.422 CPU in 1.472 seconds (97% CPU, 4428014 Lips)
N = 4,
R = refutada.
```

Con 3 palomas, la saturación llega a □ en el cuarto nivel con 24 veces
menos inferencias que la profundización iterativa, que examina todas las
secuencias de pasos más cortas que la refutación de 11 pasos. La
saturación no da la prueba más corta, ni la prueba: para devolverla,
cada cláusula agregada tendría que guardar sus padres. Sin el filtro de
subsunción, con solo descartar las repetidas, la saturación usa 73 352
inferencias, como mide la página
[La lógica de predicados](primer-orden.md#la-subsuncion). Con 4 palomas,
la versión con subsunción no termina en 300 millones de inferencias, y la
versión sin ella, en ocho minutos.
