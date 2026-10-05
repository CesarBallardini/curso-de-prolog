# Firmas

Esta página contiene las secciones
[82.6](index.md#826-version-4-rsa-con-enteros) y
[82.7](index.md#827-version-5-la-entrega-firmada) del
[capítulo 82](index.md): RSA escrito con enteros, y las firmas de
`library(crypto)` aplicadas a la entrega del pack del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md). Los
ejemplos están en `rsa.pl` y `firmas.pl`, en `ejemplos/capitulo-82/`,
con sus pruebas.

## Firmas, versión 4: RSA con enteros

En un esquema de **clave pública** cada participante tiene dos claves: la
**privada**, que guarda, y la **pública**, que publica. Lo que firma la
privada lo verifica la pública, y lo que cifra la pública lo descifra la
privada. RSA, el esquema de Rivest, Shamir y Adleman de 1978, construye
las dos claves con dos primos grandes P y Q:

| Paso | Cálculo |
|---|---|
| módulo | N = P·Q |
| exponente público | E, sin divisores comunes con (P−1)·(Q−1); casi siempre 65537 |
| exponente privado | D, el inverso de E módulo (P−1)·(Q−1): E·D mod (P−1)·(Q−1) = 1 |
| cifrar M, con 0 ≤ M < N | C = M^E mod N |
| descifrar C | M = C^D mod N |
| firmar M | S = M^D mod N |
| verificar S | S^E mod N = M |

Descifrar recupera M porque elevar a E y después a D es elevar a E·D, que
es 1 más un múltiplo de (P−1)·(Q−1), y por el teorema de Euler esa
potencia deja todo número igual módulo N. La seguridad se apoya en que,
conocidos N y E, calcular D exige conocer (P−1)·(Q−1), es decir,
factorizar N, y no se conoce un método eficiente para factorizar el
producto de dos primos de mil bits.

**El inverso modular.** El algoritmo de Euclides extendido calcula, junto
al máximo común divisor G de A y B, dos enteros X e Y con A·X + B·Y = G.
Si G es 1, X es el inverso de A módulo B:

<!-- ejemplo: capitulo-82/rsa.pl predicado: euclides/5 inverso/3 -->
```prolog
%!  euclides(+A:integer, +B:integer, -G:integer, -X:integer, -Y:integer)
%!      is det.
%
%   G es el máximo común divisor de A y B, y A*X + B*Y = G.
euclides(A, B, G, X, Y) :-
    B =:= 0,
    !,
    G = A,
    X = 1,
    Y = 0.
euclides(A, B, G, X, Y) :-
    Q is A // B,
    R is A mod B,
    euclides(B, R, G, X1, Y1),
    X = Y1,
    Y is X1 - Q * Y1.

%!  inverso(+A:integer, +M:integer, -X:integer) is semidet.
%
%   X, entre 0 y M-1, es el inverso de A módulo M: A*X mod M = 1. Falla si
%   A y M tienen un divisor común.
inverso(A, M, X) :-
    euclides(A, M, G, X0, _),
    G =:= 1,
    X is X0 mod M.
```

```prolog
?- euclides(17, 3120, G, X, Y).
G = 1,
X = -367,
Y = 2.

?- inverso(17, 3120, D).
D = 2753.

?- inverso(6, 3120, D).
false.
```

La primera cláusula compara con `B =:= 0` y liga G, X e Y después del
corte. La primera versión escrita para el capítulo tenía la cabeza
`euclides(A, 0, A, 1, 0)`, y una prueba con G ya ligado a 1 la refutó: con
A distinto de 1 la cabeza no unificaba, la segunda cláusula dividía por
cero y la consulta terminaba con un error en lugar de fallar.

**Los primos.** El pequeño teorema de Fermat dice que, si N es primo,
B^(N−1) mod N es 1 para todo B entre 1 y N−1. Un número que no lo cumple
es compuesto, pero hay compuestos que lo cumplen para casi todo B, los
**números de Carmichael**:

```prolog
?- X is powm(2, 560, 561).
X = 1.
```

561 es 3·11·17. La prueba de **Miller y Rabin** refina la de Fermat:
escribe N−1 como 2^S·D con D impar y examina, además de B^D, sus S
cuadrados sucesivos; un primo da 1 o N−1 en algún punto de esa sucesión,
y un compuesto lo da para a lo sumo un cuarto de las bases. Con las doce
primeras bases primas, la prueba no se equivoca con ningún número menor
que 3,3·10^24.

<!-- ejemplo: capitulo-82/rsa.pl predicado: base/1 primo/1 descomponer/3 testigo_no/4 cuadrados/3 primo_desde/2 -->
```prolog
% base(B): las bases de la prueba de Miller-Rabin, los doce primeros
% primos. Con ellas la prueba es exacta para N menor que 3,3 * 10^24, y
% para N mayor la probabilidad de aceptar un compuesto es despreciable.
base(2).
base(3).
base(5).
base(7).
base(11).
base(13).
base(17).
base(19).
base(23).
base(29).
base(31).
base(37).

%!  primo(+N:integer) is semidet.
%
%   N es primo según la prueba de Miller-Rabin con las bases de base/1.
primo(N) :-
    N >= 2,
    (   base(N)
    ->  true
    ;   \+ ( base(B), N mod B =:= 0 ),
        descomponer(N, S, D),
        forall(base(B), testigo_no(B, N, S, D))
    ).

%!  descomponer(+N:integer, -S:integer, -D:integer) is det.
%
%   N - 1 = 2^S * D, con D impar.
descomponer(N, S, D) :-
    N1 is N - 1,
    S is lsb(N1),
    D is N1 >> S.

%!  testigo_no(+B:integer, +N:integer, +S:integer, +D:integer) is semidet.
%
%   La base B no prueba que N es compuesto: B^D mod N es 1, o alguno de
%   los S cuadrados sucesivos de B^D es N - 1.
testigo_no(B, N, S, D) :-
    X is powm(B, D, N),
    N1 is N - 1,
    (   ( X =:= 1 ; X =:= N1 )
    ->  true
    ;   cuadrados(S, X, N)
    ).

%!  cuadrados(+S:integer, +X:integer, +N:integer) is semidet.
%
%   Alguno de los S - 1 cuadrados sucesivos de X módulo N es N - 1.
cuadrados(S, X, N) :-
    S > 1,
    Y is X * X mod N,
    (   Y =:= N - 1
    ->  true
    ;   S1 is S - 1,
        cuadrados(S1, Y, N)
    ).

%!  primo_desde(+N:integer, -P:integer) is det.
%
%   P es el menor primo mayor o igual que N.
primo_desde(N, P) :-
    (   primo(N)
    ->  P = N
    ;   N1 is N + 1,
        primo_desde(N1, P)
    ).
```

`lsb(N1)` es la posición del bit 1 más bajo de N−1, es decir, S, y
`N1 >> S` es D.

```prolog
?- primo(561).
false.

?- primo_desde(1000000, P).
P = 1000003.

?- N is 2^127-1, primo(N).
N = 170141183460469231731687303715884105727.
```

Las pruebas comparan `primo/1` con la división por tentativa en todos los
números hasta 2000, y lo prueban con ocho números de Carmichael y con los
números de Mersenne 2^127−1, primo, y 2^67−1, compuesto.

**Las claves.** `claves/5` arma un par a partir de dos primos y un
exponente público; `claves_aleatorias/3` elige los primos al azar con
`primo_aleatorio/2`, y `clave_de_ejemplo/2` fija dos primos de 20 cifras
para que las consultas se puedan leer:

<!-- ejemplo: capitulo-82/rsa.pl predicado: primo_aleatorio/2 claves/5 claves_aleatorias/3 clave_de_ejemplo/2 cifrar/3 descifrar/3 firmar/3 verificar/3 -->
```prolog
%!  primo_aleatorio(+Bits:integer, -P:integer) is det.
%
%   P es un primo de Bits bits: el primero desde un número aleatorio cuyos
%   dos bits más altos son 1, para que el producto de dos de ellos tenga
%   el doble de bits. El generador de números aleatorios no es
%   criptográfico; las claves reales usan crypto_generate_prime/3.
primo_aleatorio(Bits, P) :-
    Min is 3 << (Bits - 2),
    Max is (1 << Bits) - 1,
    repeat,
    random_between(Min, Max, N0),
    primo_desde(N0, P),
    P =< Max,
    !.

%!  claves(+P:integer, +Q:integer, +E:integer, -Publica, -Privada)
%!      is semidet.
%
%   Publica es publica(N, E) y Privada es privada(N, D), con N = P*Q y D
%   el inverso de E módulo (P-1)*(Q-1). Falla si E tiene un divisor común
%   con (P-1)*(Q-1).
claves(P, Q, E, publica(N, E), privada(N, D)) :-
    N is P * Q,
    Fi is (P - 1) * (Q - 1),
    inverso(E, Fi, D).

%!  claves_aleatorias(+Bits:integer, -Publica, -Privada) is det.
%
%   Un par de claves con un N de Bits bits y E = 65537, el exponente que
%   usan casi todas las claves RSA.
claves_aleatorias(Bits, Publica, Privada) :-
    Mitad is Bits // 2,
    repeat,
    primo_aleatorio(Mitad, P),
    primo_aleatorio(Mitad, Q),
    P =\= Q,
    claves(P, Q, 65537, Publica, Privada),
    !.

%!  clave_de_ejemplo(-Publica, -Privada) is det.
%
%   Un par de claves fijo, con primos de 20 dígitos: demasiado pequeño
%   para proteger nada, pero de un tamaño que se lee en una consulta.
clave_de_ejemplo(Publica, Privada) :-
    primo_desde(10000000000000000000, P),
    primo_desde(30000000000000000000, Q),
    claves(P, Q, 65537, Publica, Privada).

%!  cifrar(+M:integer, +Publica, -C:integer) is det.
%
%   C es M^E mod N. M debe estar entre 0 y N-1.
cifrar(M, publica(N, E), C) :-
    C is powm(M, E, N).

%!  descifrar(+C:integer, +Privada, -M:integer) is det.
%
%   M es C^D mod N.
descifrar(C, privada(N, D), M) :-
    M is powm(C, D, N).

%!  firmar(+M:integer, +Privada, -S:integer) is det.
%
%   S es la firma de M: M^D mod N.
firmar(M, privada(N, D), S) :-
    S is powm(M, D, N).

%!  verificar(+M:integer, +S:integer, +Publica) is semidet.
%
%   S es una firma válida de M para Publica: S^E mod N es M.
verificar(M, S, publica(N, E)) :-
    M =:= powm(S, E, N).
```

`random_between/3` usa el generador de
[`library(random)`](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#229-libraryrandom),
que no es criptográfico: quien conoce algunas de sus salidas puede
predecir las siguientes. Para claves reales, la versión 5 toma los primos
de `crypto_generate_prime/3`. El ejemplo de la Wikipedia, con P = 61,
Q = 53 y E = 17:

```prolog
?- claves(61, 53, 17, Pub, Priv), cifrar(65, Pub, C), descifrar(C, Priv, M).
Pub = publica(3233, 17),
Priv = privada(3233, 2753),
C = 2790,
M = 65.
```

**Textos como enteros.** RSA cifra enteros menores que N. Un texto se
convierte en un entero leyendo sus bytes en UTF-8 como las cifras de un
número en base 256:

<!-- ejemplo: capitulo-82/rsa.pl predicado: texto_entero/2 digito256/3 entero_texto/2 bytes/3 -->
```prolog
%!  texto_entero(+Texto, -N:integer) is det.
%
%   N es el entero cuyos dígitos en base 256 son los bytes de Texto en
%   UTF-8, el primero el más significativo.
texto_entero(Texto, N) :-
    atom_codes(Texto, Codigos),
    phrase(utf8_codes(Codigos), Bytes),
    foldl(digito256, Bytes, 0, N).

%!  digito256(+B:integer, +N0:integer, -N:integer) is det.
%
%   N agrega el dígito B a la derecha de N0, en base 256.
digito256(B, N0, N) :-
    N is N0 * 256 + B.

%!  entero_texto(+N:integer, -Texto:string) is det.
%
%   Texto es el texto cuyos bytes en UTF-8 son los dígitos de N en base
%   256: la conversión inversa de texto_entero/2.
entero_texto(N, Texto) :-
    bytes(N, [], Bytes),
    phrase(utf8_codes(Codigos), Bytes),
    string_codes(Texto, Codigos).

%!  bytes(+N:integer, +Bs0:list, -Bs:list) is det.
%
%   Bs son los dígitos de N en base 256 seguidos de Bs0.
bytes(0, Bs, Bs) :-
    !.
bytes(N, Bs0, Bs) :-
    B is N /\ 255,
    N1 is N >> 8,
    bytes(N1, [B|Bs0], Bs).
```

```prolog
?- texto_entero("Hola", N), entero_texto(N, T).
N = 1215261793,
T = "Hola".
```

**Primera debilidad: el cifrado es determinista.** El mismo mensaje con
la misma clave da siempre el mismo cifrado. Si los mensajes posibles son
pocos —un voto, una respuesta sí o no—, quien intercepta el cifrado
cifra cada posibilidad con la clave pública, que es de todos, y compara:

<!-- ejemplo: capitulo-82/rsa.pl predicado: adivinar/4 -->
```prolog
%!  adivinar(+C:integer, +Publica, +Opciones:list, -Texto) is semidet.
%
%   Texto es la opción de Opciones cuyo cifrado es C. Cifrar con RSA sin
%   relleno es determinista: quien conoce las opciones posibles las cifra
%   con la clave pública y compara, sin la clave privada.
adivinar(C, Publica, Opciones, Texto) :-
    member(Texto, Opciones),
    texto_entero(Texto, M),
    cifrar(M, Publica, C),
    !.
```

```prolog
?- clave_de_ejemplo(Pub, _), texto_entero(no, M), cifrar(M, Pub, C).
Pub = publica(300000000000000001940000000000000002091, 65537),
M = 28271,
C = 220100195717817993788210431670481763232.

?- clave_de_ejemplo(Pub, _), adivinar(220100195717817993788210431670481763232, Pub, [si, no, abstencion], V).
Pub = publica(300000000000000001940000000000000002091, 65537),
V = no.
```

**Segunda debilidad: las firmas se multiplican.** Como
(M1^D)·(M2^D) = (M1·M2)^D, el producto de dos firmas módulo N es la firma
del producto de los mensajes, un mensaje que el dueño de la clave nunca
firmó:

<!-- ejemplo: capitulo-82/rsa.pl predicado: falsificar/4 -->
```prolog
%!  falsificar(+S1:integer, +S2:integer, +Publica, -S:integer) is det.
%
%   S es S1*S2 mod N. Si S1 firma M1 y S2 firma M2, S firma M1*M2 mod N,
%   un mensaje que el dueño de la clave nunca firmó.
falsificar(S1, S2, publica(N, _), S) :-
    S is S1 * S2 mod N.
```

```prolog
?- clave_de_ejemplo(Pub, Priv), firmar(2, Priv, S2), firmar(3, Priv, S3), falsificar(S2, S3, Pub, S6), firmar(6, Priv, S).
Pub = publica(300000000000000001940000000000000002091, 65537),
Priv = privada(300000000000000001940000000000000002091, 264862596701100143582036101744052979473),
S2 = 22169998281075300447363312005126467851,
S3 = 76424830650369510035432892005492921847,
S6 = S, S = 200947600777671790850696343616848969034.
```

La firma fabricada con las de 2 y de 3 es exactamente la que el dueño de
la clave habría producido para 6. Las dos debilidades vienen de usar la
operación matemática sobre el mensaje tal cual; la versión 5 la usa sobre
un bloque con un formato fijo.

!!! question "Actividad"
    Predecir el cifrado de 0 y de 1 con cualquier clave, y por qué
    `adivinar/4` con las opciones `[si, no]` no necesitaría la clave si los
    votos se codificaran como 0 y 1. Comprobarlo con `clave_de_ejemplo/2`.

## Firmas, versión 5: la entrega firmada

Los dos defectos de la versión 4 se corrigen del mismo modo: no se firma
el mensaje, sino un bloque del tamaño del módulo construido con un
formato fijo a partir del resumen del mensaje. `rsa_sign/4` de
`library(crypto)` lo hace con el formato de PKCS #1 v1.5, y `rsa_verify/4`
lo comprueba. La biblioteca espera las claves como términos con ocho
números en hexadecimal, que habitualmente se leen de un archivo con
`load_private_key/3`; `clave_desde_primos/4` los arma a partir de dos
primos, con el inverso de `rsa.pl`, y `clave_rsa/3` toma los primos de
`crypto_generate_prime/3`, que usa el generador aleatorio criptográfico de
OpenSSL:

<!-- ejemplo: capitulo-82/firmas.pl predicado: clave_rsa/3 clave_desde_primos/4 hexadecimal/2 -->
```prolog
%!  clave_rsa(+Bits:integer, -Privada, -Publica) is det.
%
%   Privada y Publica son un par de claves RSA nuevo, con un módulo de
%   Bits bits, hecho con dos primos de crypto_generate_prime/3.
clave_rsa(Bits, Privada, Publica) :-
    Mitad is Bits // 2,
    repeat,
    crypto_generate_prime(Mitad, P, []),
    crypto_generate_prime(Mitad, Q, []),
    P =\= Q,
    clave_desde_primos(P, Q, Privada, Publica),
    !.

%!  clave_desde_primos(+P:integer, +Q:integer, -Privada, -Publica)
%!      is semidet.
%
%   Privada es private_key(rsa(N, E, D, P, Q, DP, DQ, QI)), con los ocho
%   números en hexadecimal como los espera library(crypto): el módulo, los
%   dos exponentes, los dos primos y tres valores que aceleran el cálculo.
%   Publica es la clave pública que le corresponde. E es 65537; falla si
%   no tiene inverso módulo (P-1)*(Q-1).
clave_desde_primos(P, Q, private_key(rsa(HN, HE, HD, HP, HQ, HDP, HDQ, HQI)),
                   public_key(rsa(HN, HE, -, -, -, -, -, -))) :-
    E = 65537,
    N is P * Q,
    Fi is (P - 1) * (Q - 1),
    inverso(E, Fi, D),
    DP is D mod (P - 1),
    DQ is D mod (Q - 1),
    inverso(Q, P, QI),
    maplist(hexadecimal, [N, E, D, P, Q, DP, DQ, QI],
            [HN, HE, HD, HP, HQ, HDP, HDQ, HQI]).

%!  hexadecimal(+N:integer, -Hex:atom) is det.
%
%   Hex son los dígitos hexadecimales de N.
hexadecimal(N, Hex) :-
    format(atom(Hex), "~16r", [N]).
```

`D mod (P - 1)`, `D mod (Q - 1)` y el inverso de `Q` módulo `P` permiten
a OpenSSL calcular la potencia módulo `P` y módulo `Q` por separado, con
números de la mitad de tamaño, y combinarlas: el resultado es el mismo
que el de `powm(M, D, N)`, en una fracción del tiempo.

**El llavero.** Las claves se guardan con un nombre. El autor genera su
par; quien verifica guarda solo la clave pública que el autor le entrega,
con `importar/2`, o con `compartir/2`, que hace las dos cosas, y sin la
privada no puede firmar:

<!-- ejemplo: capitulo-82/firmas.pl predicado: generar/2 exportar/2 importar/2 compartir/2 privada/2 huella/2 grupos/2 -->
```prolog
%!  generar(+Nombre, +Bits:integer) is det.
%
%   Guarda en el llavero, con Nombre, un par de claves nuevo de Bits bits.
%   Reemplaza el que hubiera con ese nombre.
generar(Nombre, Bits) :-
    clave_rsa(Bits, Privada, Publica),
    retractall(clave(Nombre, _, _)),
    assertz(clave(Nombre, Privada, Publica)).

%!  exportar(+Nombre, -Publica) is semidet.
%
%   Publica es la clave pública guardada con Nombre: lo único que el autor
%   entrega a quien verifica.
exportar(Nombre, Publica) :-
    clave(Nombre, _, Publica).

%!  importar(+Nombre, +Publica) is det.
%
%   Guarda con Nombre la clave pública de otro, sin clave privada.
%   Reemplaza la que hubiera con ese nombre.
importar(Nombre, Publica) :-
    retractall(clave(Nombre, _, _)),
    assertz(clave(Nombre, ninguna, Publica)).

%!  compartir(+Autor, +Otro) is semidet.
%
%   Guarda con el nombre Otro la clave pública de Autor, como la guarda
%   quien la recibe: sin la clave privada.
compartir(Autor, Otro) :-
    exportar(Autor, Publica),
    importar(Otro, Publica).

%!  privada(+Nombre, -Privada) is semidet.
%
%   Privada es la clave privada guardada con Nombre; falla si el llavero
%   solo tiene la pública.
privada(Nombre, Privada) :-
    clave(Nombre, Privada, _),
    Privada \== ninguna.

%!  huella(+Nombre, -Huella:atom) is semidet.
%
%   Huella son los primeros 16 dígitos del resumen de N y E de la clave
%   pública guardada con Nombre, en grupos de cuatro: lo que se dicta o se
%   compara a simple vista para comprobar, por otro canal, que una clave
%   pública es la que se espera.
huella(Nombre, Huella) :-
    exportar(Nombre, public_key(rsa(HN, HE, _, _, _, _, _, _))),
    format(atom(Datos), "~w:~w", [HN, HE]),
    resumen(Datos, Hex),
    sub_atom(Hex, 0, 16, _, Corto),
    atom_codes(Corto, Cs),
    grupos(Cs, Gs),
    atomic_list_concat(Gs, ':', Huella).

%!  grupos(+Codigos:list, -Grupos:list(atom)) is det.
%
%   Grupos son los Codigos de a cuatro, cada grupo un átomo.
grupos([], []).
grupos([A, B, C, D|Cs], [G|Gs]) :-
    atom_codes(G, [A, B, C, D]),
    grupos(Cs, Gs).
```

```prolog
?- generar(autor, 1024), huella(autor, H).
H = '8f3f:0bab:cf95:a4e0'.

?- generar(autor, 1024), compartir(autor, alumno), huella(autor, H1), huella(alumno, H2).
H1 = H2, H2 = '708c:e049:868f:f8a9'.

?- generar(autor, 1024), compartir(autor, alumno), firmar_texto(alumno, abc, F).
false.
```

Cada consulta empieza por generar el par del autor, para que se pueda
ejecutar sola, y por eso las claves y las huellas cambian de una consulta
a otra. La **huella** resuelve
el último eslabón: la clave pública llega por un canal que el atacante
también podría alterar, y quien la recibe la compara con la que el autor
publica por otro medio —su página, una conversación— leyendo 16 dígitos
en lugar de 256. El capítulo usa claves de 1024 bits para que las
consultas sean breves; las claves reales tienen al menos 2048, y
`generar(autor, 2048)` tarda unas dos décimas de segundo.

**Firmar y verificar.** `firmar_texto/3` firma el resumen SHA-256 del
texto, y `verificar_texto/3` comprueba la firma con la clave pública:

<!-- ejemplo: capitulo-82/firmas.pl predicado: firmar_texto/3 verificar_texto/3 -->
```prolog
%!  firmar_texto(+Nombre, +Texto, -Firma:atom) is semidet.
%
%   Firma es la firma RSA de Texto con la clave privada de Nombre, en
%   hexadecimal: la del resumen SHA-256 de Texto, con el relleno de
%   PKCS #1 v1.5. Falla si el llavero no tiene la clave privada.
firmar_texto(Nombre, Texto, Firma) :-
    privada(Nombre, Privada),
    resumen(Texto, Hex),
    rsa_sign(Privada, Hex, F, [type(sha256)]),
    atom_string(Firma, F).

%!  verificar_texto(+Nombre, +Texto, +Firma) is semidet.
%
%   Firma es una firma válida de Texto hecha con la clave privada que
%   corresponde a la clave pública guardada con Nombre.
verificar_texto(Nombre, Texto, Firma) :-
    exportar(Nombre, Publica),
    resumen(Texto, Hex),
    rsa_verify(Publica, Hex, Firma, [type(sha256)]).
```

**Lo que firma la biblioteca.** Una firma de `rsa_sign/4` sigue siendo
RSA: elevada al exponente público módulo `N`, como hace `verificar/3` de
`rsa.pl`, da el bloque que se firmó. `bloque_firmado/3` lo calcula, y
`relleno_pkcs1/2` lo lee con una gramática:

<!-- ejemplo: capitulo-82/firmas.pl predicado: bloque_firmado/3 relleno_pkcs1/2 relleno//1 unos//1 -->
```prolog
%!  bloque_firmado(+Nombre, +Firma, -Bloque:atom) is semidet.
%
%   Bloque es lo que la firma cifra: Firma^E mod N, con la clave pública
%   de Nombre, como hace verificar/3 de rsa.pl, escrito en hexadecimal con
%   el ancho del módulo.
bloque_firmado(Nombre, Firma, Bloque) :-
    exportar(Nombre, Publica),
    publica(Publica, publica(N, E)),
    hex_numero(Firma, S),
    M is powm(S, E, N),
    Ancho is (msb(N) + 8) // 8 * 2,
    format(atom(Bloque), "~`0t~16r~*|", [M, Ancho]).

%!  relleno_pkcs1(+Bloque:atom, -Hex:atom) is semidet.
%
%   Bloque tiene el formato de una firma SHA-256 de PKCS #1 v1.5: 0001,
%   bytes ff, un byte 00, el identificador de SHA-256 y el resumen Hex.
relleno_pkcs1(Bloque, Hex) :-
    atom_concat('0001', Resto, Bloque),
    atom_codes(Resto, Cs),
    phrase(relleno(Hex), Cs).

%!  relleno(-Hex:atom)// is semidet.
%
%   Los bytes ff, al menos ocho, el separador 00, el identificador de
%   SHA-256 y los 64 dígitos del resumen.
relleno(Hex) -->
    unos(K),
    { K >= 8 },
    "00",
    "3031300d060960864801650304020105000420",
    resto(Cs),
    { length(Cs, 64), atom_codes(Hex, Cs) }.

%!  unos(-K:integer)// is det.
%
%   K bytes ff seguidos: todos los que hay.
unos(K) -->
    "ff",
    !,
    unos(K0),
    { K is K0 + 1 }.
unos(0) -->
    [].
```

```prolog
?- generar(autor, 1024), firmar_texto(autor, abc, F), bloque_firmado(autor, F, B), relleno_pkcs1(B, H).
F = '9F4C7FD7EC41D846D3B44B06FCD3CC10C668C341DEEDD291381823C0F121F05742D5B8DDC736AF7407A40F0A00AC23EA29411D9CDCDE08E83DCF3CBB28770D22B64AD95167C52FEF4A5373B30ECB9EBB87858204EAD273A5D410E61A89C5C4DBAFFFDF02B4B45C53D9F35F1707B86FD706CA962BE7F688ABAF51320C2CFEE144',
B = '0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff003031300d060960864801650304020105000420ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
H = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad.
```

El bloque empieza con `0001`, sigue con bytes `ff` hasta completar el
tamaño del módulo, un `00`, 19 bytes que identifican el algoritmo SHA-256
y, al final, el resumen de `abc`. Las dos debilidades de la versión 4
desaparecen: el bloque no es el mensaje sino una función de su resumen, y
el producto de dos firmas da un bloque que no tiene este formato, que
`rsa_verify/4` rechaza. Que la firma sea determinista no es un problema:
lo que se protege con una firma es la autenticidad, no el secreto.

**La entrega.** `publicar/3` escribe el manifiesto del pack y su firma en
un directorio; `comprobar_entrega/4` lee los dos archivos, verifica la
firma con la clave guardada con el nombre del autor, y solo si es válida
compara el pack con el manifiesto:

<!-- ejemplo: capitulo-82/firmas.pl predicado: publicar/3 escribir/2 comprobar_entrega/4 igual/1 -->
```prolog
%!  publicar(+Dir, +Nombre, +Destino) is semidet.
%
%   Escribe en el directorio Destino, una ruta o un alias como
%   entregas(fechas), el manifiesto de Dir, SHA256SUMS, y su firma con la
%   clave privada de Nombre, SHA256SUMS.firma; crea Destino si no existe.
%   Falla sin escribir nada si el llavero no tiene la clave privada.
publicar(Dir, Nombre, Destino0) :-
    manifiesto(Dir, Entradas),
    manifiesto_texto(Entradas, Texto),
    firmar_texto(Nombre, Texto, Firma),
    absolute_file_name(Destino0, Destino),
    make_directory_path(Destino),
    directory_file_path(Destino, 'SHA256SUMS', Sumas),
    directory_file_path(Destino, 'SHA256SUMS.firma', ArchivoFirma),
    escribir(Sumas, Texto),
    escribir(ArchivoFirma, Firma).

%!  escribir(+Archivo, +Texto) is det.
%
%   Archivo contiene Texto, en UTF-8 y con fines de línea LF.
escribir(Archivo, Texto) :-
    setup_call_cleanup(
        open(Archivo, write, S, [encoding(utf8), newline(posix)]),
        write(S, Texto),
        close(S)).

%!  comprobar_entrega(+Dir, +Destino, +Nombre, -Resultado) is det.
%
%   Resultado juzga el directorio Dir contra SHA256SUMS y SHA256SUMS.firma
%   de Destino: firma_invalida si la firma no corresponde al manifiesto con
%   la clave pública de Nombre; si corresponde, intacta o
%   alterada(Cambios), con Cambios el informe de verificar/3 sin los
%   archivos iguales.
comprobar_entrega(Dir, Destino0, Nombre, Resultado) :-
    absolute_file_name(Destino0, Destino, [file_type(directory)]),
    directory_file_path(Destino, 'SHA256SUMS', Sumas),
    directory_file_path(Destino, 'SHA256SUMS.firma', ArchivoFirma),
    read_file_to_string(Sumas, Texto, [encoding(utf8)]),
    read_file_to_string(ArchivoFirma, Firma0, []),
    split_string(Firma0, "", " \n", [Firma]),
    (   verificar_texto(Nombre, Texto, Firma),
        texto_manifiesto(Texto, Entradas)
    ->  verificar(Dir, Entradas, Informe),
        exclude(igual, Informe, Cambios),
        (   Cambios == []
        ->  Resultado = intacta
        ;   Resultado = alterada(Cambios)
        )
    ;   Resultado = firma_invalida
    ).

%!  igual(+Estado) is semidet.
%
%   Estado es igual(_), un archivo sin cambios.
igual(igual(_)).
```

El alias `entregas` nombra un directorio dentro del directorio temporal
del sistema. El autor publica, y quien instala comprueba con la clave
importada; un tercero que genera su propio par no puede hacer pasar la
entrega por la del autor:

```prolog
?- generar(autor, 1024), compartir(autor, alumno), publicar(paquete31(fechas_castellano), autor, entregas(fechas)), comprobar_entrega(paquete31(fechas_castellano), entregas(fechas), alumno, R).
R = intacta.

?- generar(autor, 1024), publicar(paquete31(fechas_castellano), autor, entregas(fechas)), generar(intruso, 1024), comprobar_entrega(paquete31(fechas_castellano), entregas(fechas), intruso, R).
R = firma_invalida.
```

Las pruebas de `firmas.plt` cubren los otros dos casos: con un archivo del
pack modificado, `R = alterada([distinto('pack.pl')])`; con una línea
agregada al manifiesto, `R = firma_invalida`.

!!! example "Patrón 89 — Comprobar antes de usar"
    **Problema.** Unos datos llegan de afuera con un código de
    autenticación o una firma. Todo lo que el programa hace con ellos
    antes de comprobarlos, interpretarlos, descifrarlos o actuar según lo
    que dicen, lo hace con datos que cualquiera pudo fabricar o alterar.

    **Versión ingenua.** Interpretar primero y comprobar después, o no
    comprobar: `abrir_sin_mac/3`, de la
    [versión 6](canal.md#canal-version-6-un-secreto-acordado-y-un-canal-cifrado),
    descifra sin mirar el código, y un cambio de un dígito hexadecimal en
    el cifrado hace leer «Pagar 900 pesos a Ana» donde se envió «Pagar 100
    pesos a Ana».

    **Patrón.** La comprobación es la primera meta y decide si se ejecuta
    el resto. `comprobar_entrega/4` pasa a `verificar_texto/3` el
    manifiesto tal como se leyó del archivo, y solo si la firma vale lo
    analiza con `texto_manifiesto/2` y compara el pack con `verificar/3`;
    si no, responde `firma_invalida` sin abrir ningún archivo del pack.
    `abrir/3`, en la versión 6, compara el código con `iguales/2` antes
    de descifrar. Para que eso sea posible, el código se calcula sobre
    los bytes que viajan, el texto del manifiesto o el cifrado, y no
    sobre lo que resulta de interpretarlos. Complementa el
    [Patrón 31](../patrones.md#31-validar-al-entrar): un manifiesto bien
    formado pero escrito por otro pasa cualquier validación de tipos, y
    analizarlo ya es procesar datos no autenticados, de modo que la
    autenticidad se comprueba antes que la forma.

    **Cuándo no usarlo.** Cuando los datos no llevan código porque vienen
    del mismo programa o de un canal en el que ya se confía: no hay nada
    que comprobar. Cuando el mensaje es demasiado largo para retenerlo
    entero antes de usarlo, como un flujo continuo, el código del mensaje
    completo se conoce recién al final, y el formato tiene que autenticar
    por bloques, cada uno con su código; el patrón se aplica entonces a
    cada bloque. Y la separación mínima que ubica el código dentro de los
    datos, como la de `atomic_list_concat/3` en `validar/4`, precede
    necesariamente a la comprobación.

!!! question "Actividad"
    Predecir qué responde `comprobar_entrega/4` si el atacante reemplaza
    el pack, el manifiesto y la firma por los suyos, firmados con su
    propia clave, y quien instala usa la clave del autor. Explicar qué
    papel cumple la huella en ese caso.
