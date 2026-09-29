# Soluciones del capítulo 51 — Proyecto: autómatas y expresiones regulares

Las soluciones de los ejercicios 2 a 9 están en
`ejemplos/capitulo-51/soluciones.pl`, que carga los módulos del proyecto
(`lexico.pl` y `secuencial.pl`, que reexportan los demás, entre ellos
`transductores.pl`) y agrega
autómatas, construcciones, un operador de las expresiones y dos clases de
componentes léxicos con cláusulas `multifile`; las de los ejercicios 10 y
11, en `soluciones_maquinas.pl`, que carga `maquinas.pl`. Cada archivo tiene
sus pruebas en el `.plt` del mismo nombre.

## Ejercicio 1

Con `automatas.pl` y `construcciones.pl` cargados:

<!-- ejemplo: capitulo-51/construcciones.pl predicado: vacio/1 -->
```prolog
%!  vacio(+M) is semidet.
%
%   M no acepta ninguna palabra: ningún estado alcanzable es final.
vacio(M) :-
    \+ ( alcanzable(M, Q),
         final(M, Q) ).
```

```prolog
?- acepta(termina_ab, []).
false.

?- reconoce(termina_ab, [X, b]).
X = a ;
false.

?- estados(det(multiplo3), Ds).
Ds = [[r0], [r1], [r2]].

?- palabras(complemento(multiplo3), 2, Ws).
Ws = [[0, 1], [1, 0]].

?- incluido(det(termina_ab), termina_ab).
true.
```

- La palabra vacía no termina en ab: el estado inicial, q0, no es final.
  `acepta/2` es `semidet`, y falla sin alternativas.
- `reconoce/2` genera: la única letra que, seguida de b, forma una palabra
  que termina en ab es a. Queda una alternativa pendiente, que no produce
  otra respuesta.
- El determinista de un autómata determinista y completo tiene los mismos
  estados, cada uno como un conjunto de un elemento; `multiplo3` es
  completo, y no aparece el sumidero.
- De las cuatro palabras de dos bits, 00 y 11 son 0 y 3, múltiplos de 3; el
  complemento acepta 01 y 10.
- La construcción de subconjuntos da un autómata equivalente, y la
  inclusión en un sentido es parte de la equivalencia.

## Ejercicio 2

El estado es el par de restos módulo 2 de las a y de las b; cada letra
cambia su componente:

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:alfabeto(par_par, [a, b]). .. automatas:delta(par_par, A-1, b, A-0) :- member(A, [0, 1]). -->
```prolog
automatas:alfabeto(par_par, [a, b]).
automatas:inicial(par_par, 0-0).
automatas:final(par_par, 0-0).
automatas:delta(par_par, 0-B, a, 1-B) :- member(B, [0, 1]).
automatas:delta(par_par, 1-B, a, 0-B) :- member(B, [0, 1]).
automatas:delta(par_par, A-0, b, A-1) :- member(A, [0, 1]).
automatas:delta(par_par, A-1, b, A-0) :- member(A, [0, 1]).
```

`a_par` y `b_par`, en el mismo archivo, cuentan una sola letra, con dos
estados cada uno. Su intersección es, por construcción, el producto de los
dos, y tiene los mismos cuatro estados:

```prolog
?- palabras(par_par, 4, Ws), length(Ws, N).
Ws = [[a, a, a, a], [a, a, b, b], [a, b, a, b], [a, b, b, a], [b, a, a, b], [b, a, b|...], [b, b|...], [b|...]],
N = 8.

?- equivalentes(par_par, interseccion(a_par, b_par)).
true.
```

Las ocho palabras son las que tienen cuatro a, cuatro b, o dos de cada una:
1 + 1 + 6.

## Ejercicio 3

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:alfabeto(sin_epsilon(M), Sigma) :- .. clausura(M, Q3, Q1). -->
```prolog
automatas:alfabeto(sin_epsilon(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(sin_epsilon(M), Q0) :-
    inicial(M, Q0).
automatas:final(sin_epsilon(M), Q) :-
    alcanzable(sin_epsilon(M), Q),
    once(( clausura(M, Q, Q1),
           final(M, Q1) )).
automatas:delta(sin_epsilon(M), Q, S, Q1) :-
    clausura(M, Q, Q2),
    delta(M, Q2, S, Q3),
    clausura(M, Q3, Q1).
```

Una transición de `sin_epsilon(M)` recorre en M una clausura, un símbolo y
otra clausura; un estado es final si su clausura contiene un final de M.
Como no hay cláusulas de `epsilon/3` para `sin_epsilon(_)`, el autómata no
tiene transiciones ε, y la consulta falla:

```prolog
?- epsilon(sin_epsilon(ciclo), Q, Q1).
false.

?- equivalentes(ciclo, sin_epsilon(ciclo)).
true.

?- equivalentes(er("(a|b)*abb"), sin_epsilon(er("(a|b)*abb"))).
true.
```

La definición de Warren toma como finales dos clases de estados: aquellos
desde los que se llega con ε a un final, que son los de esta solución, y
aquellos a los que se llega con ε **desde** un final. La segunda clase
acepta palabras de más. `contra`, en el mismo archivo, acepta solo b; el
estado x se alcanza leyendo a, y también con una transición ε desde el
final f:

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:alfabeto(contra, [a, b]). .. automatas:epsilon(contra, f, x). -->
```prolog
automatas:alfabeto(contra, [a, b]).
automatas:inicial(contra, q0).
automatas:final(contra, f).
automatas:delta(contra, q0, a, x).
automatas:delta(contra, q0, b, f).
automatas:epsilon(contra, f, x).
```

```prolog
?- palabras(sin_epsilon(contra), 1, Ws).
Ws = [[b]].
```

Con x entre los finales, el autómata sin transiciones ε aceptaría también
a. En el ejemplo de Warren, m0s1s2s, los estados a los que se llega con ε
desde el final no existen, y la diferencia no aparece.

## Ejercicio 4

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:alfabeto(diferencia(M1, M2), Sigma) :- .. mover(M2, S, D2, E2). -->
```prolog
automatas:alfabeto(diferencia(M1, M2), Sigma) :-
    alfabeto(M1, Sigma1),
    alfabeto(M2, Sigma2),
    ord_union(Sigma1, Sigma2, Sigma).
automatas:inicial(diferencia(M1, M2), D1-D2) :-
    inicial(det(M1), D1),
    inicial(det(M2), D2).
automatas:final(diferencia(M1, M2), D1-D2) :-
    alcanzable(diferencia(M1, M2), D1-D2),
    contiene_final(M1, D1),
    \+ contiene_final(M2, D2).
automatas:delta(diferencia(M1, M2), D1-D2, S, E1-E2) :-
    alfabeto(diferencia(M1, M2), Sigma),
    member(S, Sigma),
    mover(M1, S, D1, E1),
    mover(M2, S, D2, E2).
```

Es la intersección con otra condición para los pares finales: el
componente de M1 contiene un final, y el de M2 no. Como los dos
componentes son estados de deterministas completos, «no contiene un final»
es lo mismo que «M2 rechaza la palabra»; con los estados de un autómata no
determinista no lo sería.

```prolog
?- palabras(diferencia(er("a*b*"), er("(ab)*")), 3, Ws).
Ws = [[a, a, a], [a, a, b], [a, b, b], [b, b, b]].

?- vacio(diferencia(termina_ab, termina_ab)).
true.
```

Las palabras de longitud 3 de a\*b\* son cuatro, y ninguna es de (ab)\*,
que solo tiene palabras de longitud par. Las pruebas verifican
`diferencia(M, M)` vacía para `termina_ab`, `multiplo3` y `er("a?b+")`.

## Ejercicio 5

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:alfabeto(enesima(_), [a, b]). .. I1 is I + 1. -->
```prolog
automatas:alfabeto(enesima(_), [a, b]).
automatas:inicial(enesima(_), 0).
automatas:final(enesima(N), N).
automatas:delta(enesima(_), 0, S, 0) :-
    member(S, [a, b]).
automatas:delta(enesima(_), 0, a, 1).
automatas:delta(enesima(N), I, S, I1) :-
    between(1, N, I),
    I < N,
    member(S, [a, b]),
    I1 is I + 1.
```

<!-- ejemplo: capitulo-51/soluciones.pl predicado: explosion/2 -->
```prolog
%!  explosion(+N:integer, -Filas:list) is det.
%
%   Filas tiene un término K-Det-Min por cada K de 1 a N: la cantidad de
%   estados de det(enesima(K)) y de min(enesima(K)).
explosion(N, Filas) :-
    findall(K-D-M,
            ( between(1, N, K),
              numero_estados(det(enesima(K)), D),
              numero_estados(min(enesima(K)), M) ),
            Filas).
```

```prolog
?- explosion(6, Filas).
Filas = [1-2-2, 2-4-4, 3-8-8, 4-16-16, 5-32-32, 6-64-64].
```

El no determinista tiene n + 1 estados, y el determinista, 2ⁿ: cada
estado del determinista recuerda cuáles de las últimas n letras fueron a,
porque cualquiera de ellas puede ser la n-ésima desde el final cuando la
palabra termine. El mínimo tiene los mismos 2ⁿ, así que el crecimiento no
es un defecto de la construcción: dos sucesiones distintas de n letras se
distinguen agregando letras hasta que la posición en que difieren quede
n-ésima desde el final. La construcción de subconjuntos solo construye los
estados alcanzables, pero en este lenguaje lo son todos.

## Ejercicio 6

`sufijos//2` es `multifile`, y `{` y `}` son caracteres especiales en
`expresiones.pl`: la nueva cláusula se escribe sin la notación de las
gramáticas, con los dos argumentos de la lista explícitos, porque está en
otro archivo y pertenece al módulo `expresiones`:

<!-- ejemplo: capitulo-51/soluciones.pl predicado: repetir/3 -->
```prolog
%!  repetir(+N:integer, +E, -R) is det.
%
%   R es la concatenación de N copias de E; con N = 0, la palabra vacía.
repetir(0, _, vacia) :-
    !.
repetir(1, E, E) :-
    !.
repetir(N, E, cat(E, R)) :-
    N1 is N - 1,
    repetir(N1, E, R).
```

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: expresiones:sufijos(E0, E, ['{', D, '}'|S0], S) :- .. expresiones:sufijos(R, E, S0, S). -->
```prolog
expresiones:sufijos(E0, E, ['{', D, '}'|S0], S) :-
    char_type(D, digit(N)),
    repetir(N, E0, R),
    expresiones:sufijos(R, E, S0, S).
```

```prolog
?- equivalentes(er("a{3}"), er("aaa")).
true.

?- acepta(er("(ab){2}c"), [a, b, a, b, c]).
true.

?- expresion("x{0}y", E).
E = cat(vacia, sim(y)).
```

El operador produce términos que ya existen, `cat/2` y `vacia`, y por eso
`arco/8` y todo lo que viene después funcionan sin cambios. La cláusula
nueva queda después de `sufijos(E, E) --> []`: la gramática prueba primero
dejar el factor sin sufijos, y como `{` es especial, eso no lleva a un
análisis completo, y el retroceso llega a la cláusula nueva.

## Ejercicio 7

Sin clases negadas en la notación, «cualquier carácter menos el fin de
línea» es el rango de los imprimibles, del espacio a `~`, y «menos la
comilla» son dos rangos que la saltean:

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: lexico:regla(comentario, .. atom_chars(A, Caracteres). -->
```prolog
lexico:regla(comentario, "#[ -~]*").
lexico:regla(cadena, "\"[ !#-~]*\"").

lexico:componente(comentario, _, Cs, Cs).
lexico:componente(cadena, Lexema, [cadena(A)|Cs], Cs) :-
    once(append(['"'|Caracteres], ['"'], Lexema)),
    atom_chars(A, Caracteres).
```

```prolog
?- componentes("x := 1 # uno\ny := \"hola\"", Cs).
Cs = [id(x), :=, num(1), id(y), :=, cadena(hola)].
```

Las reglas nuevas quedan al final de la tabla; como `#` y `"` no empiezan
ningún otro componente, el orden no decide nada. `once/1` descarta la
alternativa que `append/3` deja al separar las comillas.

## Ejercicio 8

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: automatas:inicial(complemento2, copia). .. automatas:delta(complemento2, invierte, [1]:[0], invierte). -->
```prolog
automatas:inicial(complemento2, copia).
automatas:final(complemento2, copia).
automatas:final(complemento2, invierte).
automatas:delta(complemento2, copia, [0]:[0], copia).
automatas:delta(complemento2, copia, [1]:[1], invierte).
automatas:delta(complemento2, invierte, [0]:[1], invierte).
automatas:delta(complemento2, invierte, [1]:[0], invierte).
```

```prolog
?- transducir(complemento2, [0, 1, 1, 0], S).
S = [0, 1, 0, 1].
```

6 da 10 = 16 − 6. Las pruebas lo verifican para los dieciséis números de
cuatro bits, en los dos sentidos. Los dos sentidos dan lo mismo porque el
complemento a dos es su propia inversa —(16 − (16 − N)) mod 16 = N—, y
también la máquina: la relación que define es simétrica. Se ve en las
transiciones: al intercambiar entrada y salida, cada una es otra transición
de la máquina, o ella misma.

## Ejercicio 9

<!-- ejemplo: capitulo-51/soluciones.pl fragmento: secuenciales:secuencial(par2, par2_c, 2). .. circuitos:componente(par2_c, x1, xor, [b1, b0], [n1]). -->
```prolog
secuenciales:secuencial(par2, par2_c, 2).
circuitos:circuito(par2_c, [b0, b1], [n0, n0, n1]).
circuitos:componente(par2_c, i1, inv, [b0], [n0]).
circuitos:componente(par2_c, x1, xor, [b1, b0], [n1]).
```

La parte combinacional incrementa el estado, con el bit menos
significativo primero, y la salida es el mismo cable que el nuevo bit
menos significativo, n0, que vale 1 cuando b0 es 0: cuando el contador vale
0 o 2.

```prolog
?- numero_estados(circuito(par2, [0, 0]), N).
N = 4.

?- estados(min(circuito(par2, [0, 0])), Cs).
Cs = [[[]], [[[0, 0]], [[0, 1]]], [[[1, 0]], [[1, 1]]]].
```

El mínimo tiene tres estados: el sumidero y dos clases, los estados con b0
en 0 y los estados con b0 en 1. El bit b1 no influye en ninguna salida
futura, y la minimización lo elimina: un circuito con un solo bit de
estado, que se invierte en cada pulso, tiene la misma salida. Es el
divisor por dos del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/secuenciales.md#circuitos-secuenciales) con la salida negada.

## Ejercicio 10

<!-- ejemplo: capitulo-51/soluciones_maquinas.pl fragmento: inicial(iguales, q). .. pila(iguales, q, [], z, [z], fin). -->
```prolog
inicial(iguales, q).
final(iguales, fin).
fondo(iguales, z).

pila(iguales, q, [S], z, [S, z], q) :-
    member(S, [a, b]).
pila(iguales, q, [S], S, [S, S], q) :-
    member(S, [a, b]).
pila(iguales, q, [S], T, [], q) :-
    member(S-T, [a-b, b-a]).
pila(iguales, q, [], z, [z], fin).
```

La pila guarda el excedente: solo a o solo b, nunca las dos. Una letra
igual al tope, o sobre el fondo, se apila; una distinta desapila la que la
compensa. La palabra está equilibrada cuando en el tope queda el fondo.

```prolog
?- acepta_pila(iguales, [a, b, b, a, b, a]).
true ;
false.
```

`maquinas.pl` declara `multifile` las relaciones de las máquinas, y
`soluciones_maquinas.pl` las declara igual: sin eso, las cláusulas nuevas
reemplazarían las del archivo cargado. Las pruebas comparan la aceptación
con la cuenta de letras para las 511 palabras de longitud hasta 8.

## Ejercicio 11

<!-- ejemplo: capitulo-51/soluciones_maquinas.pl fragmento: inicial(palindromo_mt, q0). .. turing(palindromo_mt, volver, blanco, blanco, der, q0). -->
```prolog
inicial(palindromo_mt, q0).
final(palindromo_mt, acepta).

turing(palindromo_mt, q0, a, blanco, der, qa).
turing(palindromo_mt, q0, b, blanco, der, qb).
turing(palindromo_mt, q0, blanco, blanco, der, acepta).
turing(palindromo_mt, qa, S, S, der, qa) :-
    member(S, [a, b]).
turing(palindromo_mt, qa, blanco, blanco, izq, qa_fin).
turing(palindromo_mt, qb, S, S, der, qb) :-
    member(S, [a, b]).
turing(palindromo_mt, qb, blanco, blanco, izq, qb_fin).
turing(palindromo_mt, qa_fin, a, blanco, izq, volver).
turing(palindromo_mt, qa_fin, blanco, blanco, der, acepta).
turing(palindromo_mt, qb_fin, b, blanco, izq, volver).
turing(palindromo_mt, qb_fin, blanco, blanco, der, acepta).
turing(palindromo_mt, volver, S, S, izq, volver) :-
    member(S, [a, b]).
turing(palindromo_mt, volver, blanco, blanco, der, q0).
```

La máquina recuerda el símbolo borrado en su estado, qa o qb, y el estado
de llegada al último símbolo, qa_fin o qb_fin, compara. Si al llegar al
extremo derecho encuentra un blanco, la palabra tenía un solo símbolo, o
ninguno, en esa vuelta, y acepta.

```prolog
?- turing(palindromo_mt, [a, b, a], 1000, R).
R = acepta([]).

?- turing(palindromo_mt, [a, b], 1000, R).
R = rechaza([b]).
```

<!-- ejemplo: capitulo-51/soluciones_maquinas.pl predicado: pasos/3 -->
```prolog
%!  pasos(+M, +W:list, -N:integer) is semidet.
%
%   N es la menor cantidad de pasos con la que la máquina de Turing M se
%   detiene con la entrada W, buscada entre 0 y 10 000.
pasos(M, W, N) :-
    between(0, 10000, N),
    turing(M, W, N, R),
    R \= limite(_, _),
    !.
```

Con palabras de n letras a, la máquina da 1, 3, 6, 15, 45 y 153 pasos para
n = 0, 1, 2, 4, 8 y 16: (n + 1)(n + 2)/2, porque cada vuelta recorre la
palabra que queda, dos letras más corta que la anterior, dos veces. El
autómata de pila reconoce los palíndromos de longitud par en una sola
pasada; la máquina de Turing determinista necesita un tiempo cuadrático en
la longitud de la palabra.
