# Un umbral aprendido

Esta página es parte del [capítulo 84](index.md): su versión 5, que
arma un perfil por cliente y por hora y aprende con el perceptrón del
[capítulo 69](../capitulo-69-proyecto-perceptron/index.md) el límite que
separa a los atacantes. La
[sección 84.7](index.md#847-version-5-un-umbral-aprendido) la resume. El
programa es `aprendido.pl`, en `ejemplos/capitulo-84/`, con sus pruebas.

## Versión 5: un umbral aprendido

El ataque lento del miércoles no se ve en ninguna versión anterior: los
umbrales ajustados con la mediana ponen el límite de los fallos en 14,4, y
esas horas tienen 10. Una métrica que suma a todos los clientes mezcla al
atacante con los alumnos. Denning propone también perfiles por sujeto: la
misma métrica, para cada cliente. El **perfil** de un cliente en una hora
es `perfil(Ip, H, N, F)`: hizo N pedidos, F de ellos inicios de sesión
rechazados.

<!-- ejemplo: capitulo-84/aprendido.pl predicado: perfiles/2 clave_fallo/2 perfil/2 -->
```prolog
%!  perfiles(+Pedidos:list, -Perfiles:list) is det.
%
%   Perfiles tiene un perfil(Ip, H, N, F) por cada cliente Ip y hora H en
%   la que el cliente hizo pedidos: N pedidos, F de ellos inicios de sesión
%   rechazados. Están ordenados por cliente y por hora.
perfiles(Pedidos, Perfiles) :-
    maplist(clave_fallo, Pedidos, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(perfil, Grupos, Perfiles).

% clave_fallo(Pedido, (Ip-H)-F): el cliente y la hora del Pedido, y F, 1 si
% es un inicio de sesión rechazado y 0 si no.
clave_fallo(pedido(Instante, Ip, M, R, C, _), (Ip-H)-F) :-
    hora(Instante, H),
    (   M == post,
        R == '/sesion',
        C =:= 401
    ->  F = 1
    ;   F = 0
    ).

% perfil(Grupo, Perfil): el perfil de un cliente en una hora.
perfil((Ip-H)-Fs, perfil(Ip, H, N, F)) :-
    length(Fs, N),
    sum_list(Fs, F).
```

Los incidentes de los días de referencia ya se investigaron, y sus
clientes están en hechos de `atacante/2`. Con ellos, cada perfil de esos
días es un ejemplo marcado, `ej([N, F], Clase)`, con la forma de los
ejemplos del
[capítulo 69](../capitulo-69-proyecto-perceptron/index.md#692-version-1-la-regla-del-perceptron):

<!-- ejemplo: capitulo-84/aprendido.pl predicado: atacante/2 ejemplos/2 ejemplo/3 ejemplos_de_referencia/1 -->
```prolog
% atacante(Archivo, Ip): en el registro Archivo, los pedidos del cliente Ip
% fueron un intento de adivinar contraseñas, ya investigado.
atacante(registros('2026-09-29.log'), ip(198, 51, 100, 23)).
atacante(registros('2026-09-30.log'), ip(198, 51, 100, 40)).

%!  ejemplos(+Archivo, -Ejemplos:list) is det.
%
%   Ejemplos son los perfiles del registro Archivo como ejemplos del
%   capítulo 69, ej([N, F], Clase): Clase es 1 si el cliente es un
%   atacante de ese día, y -1 si no.
ejemplos(Archivo, Ejemplos) :-
    leer_registro(Archivo, Pedidos),
    perfiles(Pedidos, Perfiles),
    maplist(ejemplo(Archivo), Perfiles, Ejemplos).

% ejemplo(Archivo, Perfil, Ejemplo): el Perfil como ejemplo marcado.
ejemplo(Archivo, perfil(Ip, _, N, F), ej([N, F], Clase)) :-
    (   atacante(Archivo, Ip)
    ->  Clase = 1
    ;   Clase = -1
    ).

%!  ejemplos_de_referencia(-Ejemplos:list) is det.
%
%   Ejemplos son los de todos los días de referencia.
ejemplos_de_referencia(Ejemplos) :-
    dias_de_referencia(Archivos),
    maplist(ejemplos, Archivos, Listas),
    append(Listas, Ejemplos).
```

Los 158 perfiles de referencia tienen tres de atacantes: `[25, 25]`,
`[5, 5]` y `[3, 3]`. ¿Alcanza un límite sobre los fallos solos? No: el
atacante que menos falló lo hizo 3 veces, y un alumno que olvidó su
contraseña falló 7 antes de entrar e hizo después 16 consultas:

<!-- ejemplo: capitulo-84/aprendido.pl predicado: separa_con_fallos/1 extremos_de_fallos/2 -->
```prolog
%!  separa_con_fallos(+Ejemplos:list) is semidet.
%
%   Algún límite sobre los fallos solos deja de un lado los ejemplos de
%   clase 1 y del otro los de clase -1: el menor fallo de un atacante es
%   mayor que el mayor fallo de los demás.
separa_con_fallos(Ejemplos) :-
    aggregate_all(min(F), member(ej([_, F], 1), Ejemplos), MinAtaque),
    aggregate_all(max(F), member(ej([_, F], -1), Ejemplos), MaxNormal),
    MinAtaque > MaxNormal.

%!  extremos_de_fallos(-MinAtaque:integer, -MaxNormal:integer) is det.
%
%   En los ejemplos de referencia, MinAtaque es la menor cantidad de fallos
%   de un perfil de atacante y MaxNormal la mayor de un perfil normal.
extremos_de_fallos(MinAtaque, MaxNormal) :-
    ejemplos_de_referencia(Ejemplos),
    aggregate_all(min(F), member(ej([_, F], 1), Ejemplos), MinAtaque),
    aggregate_all(max(F), member(ej([_, F], -1), Ejemplos), MaxNormal).
```

```prolog
?- extremos_de_fallos(A, B).
A = 3,
B = 7.
```

Lo que distingue al atacante no es cuántas veces falla, sino que no hace
otra cosa: sus pedidos son todos fallos. Es lo que Denning llama un
modelo multivariado, con más de una métrica a la vez. En el plano de los
pedidos y los fallos, los atacantes están sobre la diagonal y los alumnos
debajo, y una recta los separa. El perceptrón del
[capítulo 69](../capitulo-69-proyecto-perceptron/index.md#693-version-2-epocas-y-curva-de-aprendizaje)
busca esa recta; `aprendido.pl` carga `epocas.pl` sin copiarlo, y
entrena con tasa 1 desde pesos nulos:

<!-- ejemplo: capitulo-84/aprendido.pl predicado: pesos_aprendidos/1 aprendizaje/2 -->
```prolog
%!  pesos_aprendidos(-Pesos:list(integer)) is semidet.
%
%   Pesos son los del perceptrón entrenado con tasa 1, desde pesos nulos,
%   con los ejemplos de referencia. Falla si el entrenamiento no termina en
%   el máximo de épocas del capítulo 69.
pesos_aprendidos(Pesos) :-
    ejemplos_de_referencia(Ejemplos),
    entrenar(1, Ejemplos, [0, 0, 0], Pesos, _).

%!  aprendizaje(-Pesos:list(integer), -Curva:list(integer)) is semidet.
%
%   Pesos y Curva son los del entrenamiento de pesos_aprendidos/1: los
%   pesos finales y los errores de cada época.
aprendizaje(Pesos, Curva) :-
    ejemplos_de_referencia(Ejemplos),
    entrenar(1, Ejemplos, [0, 0, 0], Pesos, Curva).
```

```prolog
?- aprendizaje(Pesos, Curva).
Pesos = [-18, -56, 70],
Curva = [7, 1, 4, 2, 1, 1, 1, 0].
```

En ocho épocas, los pesos clasifican bien los 158 ejemplos. Leídos como
límite, dicen que un perfil es de atacante si −18 − 56·N + 70·F ≥ 0, es
decir, si F ≥ 0,8·N + 0,26: los fallos son al menos el 80 % de los
pedidos, y algo más con pocos pedidos. Un perfil `[6, 5]`, cinco fallos y
un inicio de sesión aceptado, queda del lado normal. Con esos pesos, el
miércoles y el jueves:

<!-- ejemplo: capitulo-84/aprendido.pl predicado: sospechosos/3 sospechoso/2 sospechosos_del_dia/3 -->
```prolog
%!  sospechosos(+Pesos:list, +Pedidos:list, -Sospechosos:list) is det.
%
%   Sospechosos son los perfiles de los Pedidos a los que el perceptrón con
%   Pesos da la clase 1.
sospechosos(Pesos, Pedidos, Sospechosos) :-
    perfiles(Pedidos, Perfiles),
    include(sospechoso(Pesos), Perfiles, Sospechosos).

% sospechoso(Pesos, Perfil): el perceptrón da al Perfil la clase 1.
sospechoso(Pesos, perfil(_, _, N, F)) :-
    salida(Pesos, [N, F], 1).

%!  sospechosos_del_dia(+Pesos:list, +Archivo, -Sospechosos:list) is det.
%
%   sospechosos/3 con los pedidos del registro Archivo.
sospechosos_del_dia(Pesos, Archivo, Sospechosos) :-
    leer_registro(Archivo, Pedidos),
    sospechosos(Pesos, Pedidos, Sospechosos).
```

```prolog
?- sospechosos_del_dia([-18, -56, 70], registros('2026-09-30.log'), S).
S = [perfil(ip(198, 51, 100, 40), 16, 5, 5), perfil(ip(198, 51, 100, 40), 17, 3, 3)].

?- sospechosos_del_dia([-18, -56, 70], registros('2026-10-01.log'), S).
S = [perfil(ip(198, 51, 100, 61), 14, 17, 17), perfil(ip(203, 0, 113, 7), 10, 60, 60)].
```

El miércoles aparece el atacante lento, en sus dos horas; el jueves, los
dos atacantes, y ningún alumno, aunque el jueves no estuvo entre los
datos del entrenamiento. Los pesos son un umbral ajustado con datos, como
los de la versión 4, pero sobre dos rasgos y con ejemplos marcados: lo
que la versión 4 aprende de lo habitual, la versión 5 lo aprende de lo
que ya se sabe anómalo. Lo que no puede aprender es un ataque distinto de
los que vio: un atacante que intercale consultas entre sus intentos
quedaría debajo de la recta.

!!! question "Actividad"
    Predecir si `sospechosos_del_dia/3`, con los pesos `[-18, -56, 70]`,
    encuentra al atacante del martes, cuyos perfiles estuvieron entre los
    ejemplos del entrenamiento, y en qué horas. Comprobarlo, y comparar
    con lo que encuentran los umbrales de la versión 4 ese día.
