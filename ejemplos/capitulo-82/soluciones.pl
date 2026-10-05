:- encoding(utf8).

% Capítulo 82 - Soluciones de los ejercicios que piden código.
%
% Carga los módulos del capítulo sin modificarlos: resumenes, claves,
% fichas, rsa, firmas y acuerdo.
%
% solo-local: carga otros módulos del capítulo, que leen archivos.
%
%?- media_avalancha(M).
%?- emitir_con_alcance(s, 101, lectura, 1800000000, F).

:- use_module(library(crypto)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(library(readutil)).
:- use_module(resumenes).
:- use_module(claves).
:- use_module(fichas).
:- use_module(rsa, except([verificar/3])).
:- use_module(firmas).
:- use_module(acuerdo).

% --- Ejercicio 2 -------------------------------------------------------------

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

% --- Ejercicio 3 -------------------------------------------------------------

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

% --- Ejercicio 4 -------------------------------------------------------------

%!  fuerza_bruta_registro(+Registro, +Largo:integer, -Clave:atom)
%!      is semidet.
%
%   Clave es la primera palabra de Largo minúsculas que comprobar/2 acepta
%   para Registro.
fuerza_bruta_registro(Registro, Largo, Clave) :-
    once(( clave_corta(Largo, Clave),
           comprobar(Clave, Registro) )).

% --- Ejercicio 5 -------------------------------------------------------------

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

% --- Ejercicio 6 -------------------------------------------------------------

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

% --- Ejercicio 7 -------------------------------------------------------------

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

% --- Ejercicio 8 -------------------------------------------------------------

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

% --- Ejercicio 9 -------------------------------------------------------------

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

% --- Ejercicio 10 ------------------------------------------------------------

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

% --- Ejercicio 11 ------------------------------------------------------------

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
