# Soluciones del capítulo 82 — Proyecto: criptografía

El código de esta página está en `ejemplos/capitulo-82/soluciones.pl`,
con sus pruebas en `soluciones.plt`. El archivo carga los módulos del
capítulo sin modificarlos —`resumenes.pl`, `claves.pl`, `fichas.pl`,
`rsa.pl`, `firmas.pl` y `acuerdo.pl`—; importa `rsa.pl` sin su `verificar/3`, porque
`resumenes.pl` exporta otro predicado con el mismo nombre. Es
`% solo-local`, porque carga módulos que leen archivos.

## 1

La primera consulta da el resumen de `abc`. La segunda da un error de
dominio: `crypto_data_hash/3` convierte el resumen que recibe en bytes
con `hex_bytes/2` para compararlo, y esa conversión, con los dos
argumentos instanciados y distintos, da un error en lugar de fallar. La
tercera, en cambio, falla, porque `resumen/2` calcula en una variable
nueva y compara después; es la diferencia que el encabezado de
`resumen/2` documenta. La cuarta falla: `validar/4` separa tres campos,
pero `a` no es un número y `atom_number/2` falla.

<!-- contexto: capitulo-82/soluciones.pl -->
```prolog
?- crypto_data_hash(abc, H, [algorithm(sha256)]).
H = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad.

?- resumen(abc, R), resumen(abd, R).
false.

?- validar(secreto, 'a.b.c', 0, L).
false.
```

La consulta con el error no se reproduce aquí: termina con
`domain_error(hex_encoding, …)` y el resumen de `abd`.

## 2

<!-- ejemplo: capitulo-82/soluciones.pl predicado: media_avalancha/1 distintos_consecutivos/2 -->
```prolog
%!  media_avalancha(-Media:float) is det.
%
%   Media es el promedio de los bits distintos entre los resúmenes de "0"
%   y "1", de "1" y "2", …, de "8" y "9".
media_avalancha(Media) :-
    numlist(0, 8, Is),
    maplist(distintos_consecutivos, Is, Ns),
    sum_list(Ns, Total),
    length(Ns, K),
    Media is Total / K.

%!  distintos_consecutivos(+I:integer, -N:integer) is det.
%
%   N son los bits distintos entre los resúmenes de I y de I + 1, escritos
%   como texto.
distintos_consecutivos(I, N) :-
    J is I + 1,
    number_string(I, A),
    number_string(J, B),
    resumen(A, HA),
    resumen(B, HB),
    bits_distintos(HA, HB, N).
```

```prolog
?- maplist(distintos_consecutivos, [0, 1, 2, 3, 4, 5, 6, 7, 8], Ns).
Ns = [125, 129, 130, 137, 133, 117, 124, 131, 123].

?- media_avalancha(M).
M = 127.66666666666667.
```

Si cada bit del resumen se comporta como una moneda independiente de la
entrada, dos resúmenes coinciden en cada bit con probabilidad 1/2, y la
cantidad de bits distintos sigue una distribución binomial de 256
intentos con probabilidad 1/2: su media es 128 y su desviación, 8. Los
nueve valores están todos a menos de dos desviaciones de la media.

## 3

<!-- ejemplo: capitulo-82/soluciones.pl predicado: entregas_distintas/3 comparar/4 -->
```prolog
%!  entregas_distintas(+Dir1, +Dir2, -Informe:list) is det.
%
%   Informe compara Dir2 con Dir1 con los términos de verificar/3: falta
%   para lo que está solo en Dir1, sobra para lo que está solo en Dir2.
%   Cada directorio se lee una sola vez, para calcular su manifiesto.
entregas_distintas(Dir1, Dir2, Informe) :-
    manifiesto(Dir1, M1),
    manifiesto(Dir2, M2),
    pairs_keys(M1, R1),
    pairs_keys(M2, R2),
    ord_union(R1, R2, Todas),
    maplist(comparar(M1, M2), Todas, Informe).

%!  comparar(+M1:list, +M2:list, +Ruta:atom, -Estado) is det.
%
%   Estado compara la Ruta en los dos manifiestos.
comparar(M1, M2, Ruta, Estado) :-
    (   memberchk(Ruta-H1, M1)
    ->  (   memberchk(Ruta-H2, M2)
        ->  (   H1 == H2
            ->  Estado = igual(Ruta)
            ;   Estado = distinto(Ruta)
            )
        ;   Estado = falta(Ruta)
        )
    ;   Estado = sobra(Ruta)
    ).
```

```prolog
?- entregas_distintas(paquete31(fechas_castellano), paquete31(fechas_castellano), I).
I = [igual('pack.pl'), igual('prolog/fechas_castellano.pl'), igual('prolog/fechas_castellano.plt')].
```

Cada directorio se lee una vez, en `manifiesto/2`; la comparación trabaja
sobre los dos manifiestos. La prueba `entregas_distintas` borra `pack.pl`
de una copia y obtiene `falta('pack.pl')`.

## 4

<!-- ejemplo: capitulo-82/soluciones.pl predicado: fuerza_bruta_registro/3 -->
```prolog
%!  fuerza_bruta_registro(+Registro, +Largo:integer, -Clave:atom)
%!      is semidet.
%
%   Clave es la primera palabra de Largo minúsculas que comprobar/2 acepta
%   para Registro.
fuerza_bruta_registro(Registro, Largo, Clave) :-
    once(( clave_corta(Largo, Clave),
           comprobar(Clave, Registro) )).
```

```prolog
?- registrar(ok, 4, R), time(fuerza_bruta_registro(R, 2, C)).
% 175,556 inferences, 0.047 CPU in 0.041 seconds (113% CPU, 3745195 Lips)
R = '$pbkdf2-sha512$t=16$epRMwOrfy0Aucf8XObzpoA$dp5JHX852yV/ydhvc1w27U/7KOM+ej9RiSk166MPwlMHF94m9C8vu0h+JVX7rGvr9Gf63gabwnp3F+P7r1kbvw',
C = ok.
```

`ok` es la palabra 375 en el orden de `clave_corta/2`, así que cada
intento costó unos 0,11 milisegundos. Multiplicar por 2^13, la diferencia
entre el costo 4 y el 17, da 0,9 segundos por intento, más que los 0,2
segundos medidos en la [sección 82.4](index.md#824-version-2-las-contrasenas):
con costo 4, lo que domina no son las 16 iteraciones sino el trabajo fijo
de cada llamada, y la extrapolación lo multiplica también. Con la medición
directa, las 17 576 palabras de tres letras cuestan unos 56 minutos con
costo 17.

## 5

<!-- ejemplo: capitulo-82/soluciones.pl predicado: emitir_con_alcance/5 validar_con_alcance/5 -->
```prolog
%!  emitir_con_alcance(+Secreto, +Legajo:integer, +Alcance, +Vence:integer,
%!                     -Ficha:atom) is det.
%
%   Ficha es Legajo.Alcance.Vence.Mac, con Mac el HMAC de los tres campos.
emitir_con_alcance(Secreto, Legajo, Alcance, Vence, Ficha) :-
    must_be(oneof([lectura, inscripcion]), Alcance),
    format(atom(Datos), "~d.~w.~d", [Legajo, Alcance, Vence]),
    mac(Secreto, Datos, Mac),
    atomic_list_concat([Datos, Mac], '.', Ficha).

%!  validar_con_alcance(+Secreto, +Ficha, +Ahora:number, -Legajo:integer,
%!                      -Alcance) is semidet.
%
%   Ficha es válida en Ahora, y autoriza a Legajo con Alcance.
validar_con_alcance(Secreto, Ficha, Ahora, Legajo, Alcance) :-
    atomic_list_concat([L, A, V, Mac], '.', Ficha),
    memberchk(A, [lectura, inscripcion]),
    atom_number(L, Legajo0),
    integer(Legajo0),
    atom_number(V, Vence),
    integer(Vence),
    atomic_list_concat([L, A, V], '.', Datos),
    mac(Secreto, Datos, Esperado),
    iguales(Mac, Esperado),
    Ahora < Vence,
    Legajo = Legajo0,
    Alcance = A.
```

```prolog
?- emitir_con_alcance(s, 101, lectura, 1800000000, F), validar_con_alcance(s, F, 1700000000, L, A).
F = '101.lectura.1800000000.88a84a2dc5a74b1b7d899b208d547499a61fc77c0d6482d89522dfe3992ad141',
L = 101,
A = lectura.
```

El alcance está dentro de los datos del código de autenticación: cambiar
`lectura` por `inscripcion` exige recalcular el código, y la prueba
`alcance_cambiado` lo confirma. Un alcance desconocido al emitir es un
error de tipo, no una ficha que después falle.

## 6

<!-- ejemplo: capitulo-82/soluciones.pl predicado: inverso_lineal/3 fi_de_bits/2 -->
```prolog
%!  inverso_lineal(+A:integer, +M:integer, -X:integer) is semidet.
%
%   X es el inverso de A módulo M, buscado entre 1 y M - 1.
inverso_lineal(A, M, X) :-
    M1 is M - 1,
    between(1, M1, X),
    A * X mod M =:= 1,
    !.

%!  fi_de_bits(+Bits:integer, -Fi:integer) is det.
%
%   Fi es (P-1)*(Q-1) para los primos P y Q siguientes a 2^(Bits/2) y a
%   2^(Bits/2) + 1000, que no son divisibles por 65537.
fi_de_bits(Bits, Fi) :-
    Mitad is Bits // 2,
    A is 1 << Mitad,
    B is A + 1000,
    primo_desde(A, P),
    primo_desde(B, Q),
    Fi is (P - 1) * (Q - 1).
```

```prolog
?- fi_de_bits(16, F), time(inverso_lineal(65537, F, D1)), time(inverso(65537, F, D2)).
% 456,705 inferences, 0.062 CPU in 0.068 seconds (91% CPU, 7307280 Lips)
% 68 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
F = 322048,
D1 = D2, D2 = 228353.

?- fi_de_bits(24, F), time(inverso_lineal(65537, F, D1)).
% 9,235,569 inferences, 1.266 CPU in 1.281 seconds (99% CPU, 7297240 Lips)
F = 20891604,
D1 = 4617785.
```

La búsqueda prueba tantos valores como el inverso, unos 3,6 millones por
segundo; Euclides hace una cantidad de pasos proporcional a la cantidad
de cifras. Con 20 bits el inverso resultó pequeño, 25 473, y la búsqueda
tardó 7 milisegundos: su costo depende del valor, no del tamaño. Con un
Fi de 2048 bits, el inverso es del orden de 2^2047, y a ese ritmo la
búsqueda tardaría unos 10^602 años; Euclides tarda menos de un
milisegundo.

## 7

<!-- ejemplo: capitulo-82/soluciones.pl predicado: privada_crt/4 descifrar_crt/3 comparar_crt/2 -->
```prolog
%!  privada_crt(+P:integer, +Q:integer, +D:integer, -Clave) is semidet.
%
%   Clave es crt(P, Q, DP, DQ, QI): los primos, D módulo P-1 y Q-1, y el
%   inverso de Q módulo P, calculados una vez para todos los descifrados.
privada_crt(P, Q, D, crt(P, Q, DP, DQ, QI)) :-
    DP is D mod (P - 1),
    DQ is D mod (Q - 1),
    inverso(Q, P, QI).

%!  descifrar_crt(+C:integer, +Clave, -M:integer) is det.
%
%   M es C^D mod P*Q, calculado con dos potencias módulo P y módulo Q y
%   combinado con el teorema chino del resto (la fórmula de Garner).
descifrar_crt(C, crt(P, Q, DP, DQ, QI), M) :-
    M1 is powm(C, DP, P),
    M2 is powm(C, DQ, Q),
    H is QI * (M1 - M2) mod P,
    M is M2 + H * Q.

%!  comparar_crt(+Bits:integer, +Veces:integer) is det.
%
%   Descifra Veces veces un mensaje con claves de Bits bits de las dos
%   maneras, y muestra el tiempo de cada una.
comparar_crt(Bits, Veces) :-
    Mitad is Bits // 2,
    primo_aleatorio(Mitad, P),
    primo_aleatorio(Mitad, Q),
    claves(P, Q, 65537, Pub, privada(N, D)),
    privada_crt(P, Q, D, Clave),
    cifrar(123456789, Pub, C),
    time(forall(between(1, Veces, _), descifrar(C, privada(N, D), _))),
    time(forall(between(1, Veces, _), descifrar_crt(C, Clave, _))).
```

```prolog
?- comparar_crt(1024, 1000).
% 3,000 inferences, 0.625 CPU in 0.625 seconds (100% CPU, 4800 Lips)
% 5,999 inferences, 0.187 CPU in 0.193 seconds (97% CPU, 31995 Lips)
true.
```

M1 y M2 son M módulo P y módulo Q; la fórmula de Garner busca el único M
menor que P·Q que tiene esos dos restos. Cada potencia trabaja con
números y exponentes de la mitad de bits, y el costo de una potencia
modular crece como el cubo de los bits: dos potencias de la mitad cuestan
la cuarta parte. La medición da un factor de 3,3, algo menos de 4 por el
trabajo fijo de cada llamada.

## 8

<!-- ejemplo: capitulo-82/soluciones.pl predicado: clave_debil/4 wiener/2 raiz_entera/2 newton/3 fraccion_continua/3 reducidas/2 reducidas/6 -->
```prolog
%!  clave_debil(+Bits:integer, +BitsD:integer, -Publica, -D:integer) is det.
%
%   Publica es una clave con primos de Bits bits cuyo exponente privado D
%   tiene BitsD bits; E es el inverso de D.
clave_debil(Bits, BitsD, publica(N, E), D) :-
    repeat,
    primo_aleatorio(Bits, P),
    primo_aleatorio(Bits, Q),
    P =\= Q,
    N is P * Q,
    Fi is (P - 1) * (Q - 1),
    Min is 1 << (BitsD - 1),
    Max is (1 << BitsD) - 1,
    random_between(Min, Max, D),
    inverso(D, Fi, E),
    !.

%!  wiener(+Publica, -D:integer) is semidet.
%
%   D es el exponente privado de Publica, hallado entre los denominadores
%   de las reducidas de E/N: el ataque de Wiener, que funciona si D es
%   menor que N^(1/4)/3.
wiener(publica(N, E), D) :-
    fraccion_continua(E, N, Cocientes),
    reducidas(Cocientes, Reducidas),
    member(K-D, Reducidas),
    K > 0,
    (E * D - 1) mod K =:= 0,
    Fi is (E * D - 1) // K,
    S is N - Fi + 1,
    Disc is S * S - 4 * N,
    Disc >= 0,
    raiz_entera(Disc, R),
    R * R =:= Disc,
    !.

%!  raiz_entera(+N:integer, -R:integer) is det.
%
%   R es la parte entera de la raíz cuadrada de N, por el método de
%   Newton con enteros: exacta para enteros de cualquier tamaño, que la
%   raíz de punto flotante redondea.
raiz_entera(0, 0) :-
    !.
raiz_entera(N, R) :-
    X0 is 1 << ((msb(N) + 2) // 2),
    newton(N, X0, R).

%!  newton(+N:integer, +X:integer, -R:integer) is det.
%
%   R es la raíz entera de N, desde X, una cota superior.
newton(N, X, R) :-
    Y is (X + N // X) // 2,
    (   Y >= X
    ->  R = X
    ;   newton(N, Y, R)
    ).

%!  fraccion_continua(+A:integer, +B:integer, -Cocientes:list) is det.
%
%   Cocientes son los cocientes de la fracción continua de A/B.
fraccion_continua(_, 0, []) :-
    !.
fraccion_continua(A, B, [Q|Qs]) :-
    Q is A // B,
    R is A mod B,
    fraccion_continua(B, R, Qs).

%!  reducidas(+Cocientes:list, -Reducidas:list) is det.
%
%   Reducidas son las fracciones K-D de cada prefijo de Cocientes, por la
%   recurrencia h(i) = q(i)*h(i-1) + h(i-2).
reducidas(Cocientes, Reducidas) :-
    reducidas(Cocientes, 1, 0, 0, 1, Reducidas).

%!  reducidas(+Cocientes, +H1, +H2, +K1, +K2, -Reducidas) is det.
%
%   H1/K1 y H2/K2 son las dos reducidas anteriores.
reducidas([], _, _, _, _, []).
reducidas([Q|Qs], H1, H2, K1, K2, [H-K|Rs]) :-
    H is Q * H1 + H2,
    K is Q * K1 + K2,
    reducidas(Qs, H, H1, K, K1, Rs).
```

La prueba `wiener` construye con `clave_debil/4` una clave con primos de
256 bits y un exponente privado de 60 bits, y `wiener/2` lo recupera a
partir de la clave pública sola, en alrededor de un milisegundo. E·D = 1 + K·Fi, y
como Fi es casi N, E/N es casi K/D: si D es pequeño, la aproximación es
tan buena que K/D aparece entre las reducidas de la fracción continua de
E/N. Para cada reducida se calcula el Fi que implicaría y se comprueba si
x² − (N − Fi + 1)·x + N tiene raíces enteras, que serían P y Q. La raíz
entera se calcula con el método de Newton sobre enteros, porque la raíz
de punto flotante redondea un número de 512 bits.

`claves_aleatorias/3` fija E = 65537 y calcula D como su inverso: D es
entonces un número del tamaño de Fi, y la probabilidad de que sea menor
que N^(1/4)/3 es despreciable. La prueba `wiener_falla` lo confirma con
una clave de 512 bits.

## 9

<!-- ejemplo: capitulo-82/soluciones.pl predicado: firmar_archivo/3 verificar_archivo/3 -->
```prolog
%!  firmar_archivo(+Nombre, +Archivo, -Firma:atom) is semidet.
%
%   Firma es la firma del resumen de los bytes de Archivo, con la clave
%   privada de Nombre.
firmar_archivo(Nombre, Archivo, Firma) :-
    privada(Nombre, Privada),
    resumen_archivo(Archivo, Hex),
    rsa_sign(Privada, Hex, F, [type(sha256)]),
    atom_string(Firma, F).

%!  verificar_archivo(+Nombre, +Archivo, +Firma) is semidet.
%
%   Firma es una firma válida de Archivo para la clave pública de Nombre.
verificar_archivo(Nombre, Archivo, Firma) :-
    exportar(Nombre, Publica),
    resumen_archivo(Archivo, Hex),
    rsa_verify(Publica, Hex, Firma, [type(sha256)]).
```

El resumen de los bytes del archivo y el del texto leído en UTF-8 son el
mismo resumen, de modo que las dos firmas coinciden; lo comprueba la
prueba `firmar_archivo`. Firmar el archivo tiene dos ventajas: no hace
falta leerlo entero en memoria, y no depende de la codificación con que
se lo lea. La opción `encoding(octet)` de `resumen_archivo/2` es la que
garantiza la segunda: sin ella, el resumen del archivo no coincidiría con
el de su contenido.

## 10

<!-- ejemplo: capitulo-82/soluciones.pl predicado: acordar_curva/2 escalar/2 -->
```prolog
%!  acordar_curva(-ClavesA, -ClavesB) is det.
%
%   El acuerdo de la versión 6 sobre la curva prime256v1: cada parte
%   multiplica el generador por su escalar secreto, y después el punto
%   del otro; las claves salen de la coordenada x del punto común.
acordar_curva(ClavesA, ClavesB) :-
    crypto_name_curve(prime256v1, Curva),
    crypto_curve_generator(Curva, G),
    crypto_curve_order(Curva, Orden),
    escalar(Orden, X),
    escalar(Orden, Y),
    crypto_curve_scalar_mult(Curva, X, G, A),
    crypto_curve_scalar_mult(Curva, Y, G, B),
    crypto_curve_scalar_mult(Curva, X, B, point(SA, _)),
    crypto_curve_scalar_mult(Curva, Y, A, point(SB, _)),
    claves_de_sesion(SA, ClavesA),
    claves_de_sesion(SB, ClavesB).

%!  escalar(+Orden:integer, -X:integer) is det.
%
%   X es un escalar aleatorio entre 1 y Orden - 1.
escalar(Orden, X) :-
    secreto_aleatorio(X0),
    X is X0 mod (Orden - 1) + 1.
```

```prolog
?- acordar_curva(A, B).
A = B, B = claves('26a699e9ade549ff9900dfdac1c085a09545c28daf3d8b579e4d709d83b7a7e4', '7fc992224149a5eec0d86047a97274616a9ac35ccd348bd9cef91d6388551ba1').
```

En la curva, el papel de G^X lo cumple X·G, el generador sumado X veces
consigo mismo, y despejar X de X·G es el logaritmo discreto de la curva.
Con 256 bits da una seguridad comparable a la del grupo de 3072 bits, y
los valores que se intercambian son mucho más cortos. Las claves cambian
en cada ejecución.

## 11

<!-- ejemplo: capitulo-82/soluciones.pl predicado: acordar_con_intermediario/4 reenviar/4 -->
```prolog
%!  acordar_con_intermediario(+Grupo, -ClavesA, -ClavesB, -ClavesI)
%!      is det.
%
%   El intermediario I recibe el valor público de A y el de B, y envía a
%   cada uno el suyo. ClavesA son las que A acuerda, sin saberlo, con I;
%   ClavesB, las que B acuerda con I; ClavesI es ia(KA, KB), las dos del
%   intermediario: KA es igual a ClavesA y KB a ClavesB.
acordar_con_intermediario(Grupo, ClavesA, ClavesB, ia(KA, KB)) :-
    secreto_aleatorio(X),
    secreto_aleatorio(Y),
    secreto_aleatorio(Z),
    publico(Grupo, X, A),
    publico(Grupo, Y, B),
    publico(Grupo, Z, I),
    compartido(Grupo, X, I, SA),
    compartido(Grupo, Y, I, SB),
    compartido(Grupo, Z, A, SIA),
    compartido(Grupo, Z, B, SIB),
    claves_de_sesion(SA, ClavesA),
    claves_de_sesion(SB, ClavesB),
    claves_de_sesion(SIA, KA),
    claves_de_sesion(SIB, KB).

%!  reenviar(+ClavesI, +Mensaje0, -Texto:string, -Mensaje) is semidet.
%
%   El intermediario abre con KA el Mensaje0 que A envió a B, lee su
%   Texto y lo sella de nuevo con KB: B recibe Mensaje y lo abre sin
%   detectar nada.
reenviar(ia(KA, KB), Mensaje0, Texto, Mensaje) :-
    abrir(KA, Mensaje0, Texto),
    sellar(KB, Texto, Mensaje).
```

La prueba `intermediario` sella un mensaje con las claves de A, lo hace
pasar por `reenviar/4` y lo abre con las de B: el intermediario lee el
texto, y B abre el mensaje reenviado sin detectar nada, porque cada uno acordó sus
claves con el intermediario creyendo que lo hacía con el otro. El
intercambio de Diffie y Hellman da confidencialidad respecto de quien
escucha, pero no autenticidad: nada prueba de quién viene el valor
público. La corrección es la de la versión 5: cada parte firma su valor
público con su clave privada de largo plazo, y la otra verifica la firma
con la clave pública que importó y cuya huella comprobó. El intermediario
puede reemplazar el valor, pero no firmarlo con la clave de A o de B.
