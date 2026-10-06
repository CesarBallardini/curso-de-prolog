# Compuertas hechas con transistores

Esta página contiene la sección
[48.9](index.md#489-compuertas-hechas-con-transistores) del
[capítulo 48](index.md): los transistores CMOS descritos por sus estados
estables, el inversor, el cortocircuito y una compuerta XOR de seis
transistores. Los ejemplos están en `transistores.pl`, en
`ejemplos/capitulo-48/`, con sus pruebas.

## Compuertas hechas con transistores

Spivey, en el capítulo «Hardware simulation» de *An Introduction to Logic
Programming through Prolog*
([edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf)),
baja un nivel: las compuertas de tecnología CMOS se construyen con
transistores de dos clases, p y n. Cada transistor tiene tres terminales, la
fuente, la compuerta y el drenador. En el modelo simple que usa Spivey, un
transistor p conecta la fuente con el drenador cuando su compuerta está en 0
—entonces los dos tienen el mismo valor— y no los conecta cuando está en 1
—entonces cada uno puede tener cualquier valor—; el transistor n se comporta
al revés. Como las compuertas de la
[sección 48.1](index.md#481-compuertas-como-tablas-circuitos-como-reglas),
un transistor es la relación de sus estados estables, escrita con hechos, y
la alimentación y la tierra son dos cables con un valor fijo:

<!-- ejemplo: capitulo-48/transistores.pl fragmento: % pwr(X): el cable X .. ntran(_, 0, _). -->
```prolog
% pwr(X): el cable X está conectado a la alimentación, el 1 lógico.
pwr(1).

% gnd(X): el cable X está conectado a tierra, el 0 lógico.
gnd(0).

% ptran(F, G, D): estado estable de un transistor p con fuente F,
% compuerta G y drenador D.
ptran(X, 0, X).
ptran(_, 1, _).

% ntran(F, G, D): estado estable de un transistor n con fuente F,
% compuerta G y drenador D.
ntran(X, 1, X).
ntran(_, 0, _).
```

Un circuito es la conjunción de sus transistores, con una variable por
cable. El inversor tiene un transistor p entre la alimentación y la salida y
uno n entre la salida y la tierra; con la entrada en 0 conduce el p, y con la
entrada en 1, el n:

<!-- ejemplo: capitulo-48/transistores.pl predicado: inversor_cmos/2 cortocircuito/1 -->
```prolog
%!  inversor_cmos(?A, ?Z) is nondet.
%
%   Z es la salida del inversor CMOS con entrada A: un transistor p entre
%   la alimentación y la salida, y uno n entre la salida y tierra.
inversor_cmos(A, Z) :-
    pwr(P),
    gnd(T),
    ptran(P, A, Z),
    ntran(Z, A, T).

%!  cortocircuito(?X) is semidet.
%
%   El cable X está conectado a la alimentación y a tierra a la vez. No
%   tiene estados estables, y la consulta falla siempre.
cortocircuito(X) :-
    pwr(X),
    gnd(X).
```

```prolog
?- inversor_cmos(A, Z).
A = 0,
Z = 1 ;
A = 1,
Z = 0.

?- inversor_cmos(X, X).
false.

?- cortocircuito(X).
false.
```

Las respuestas son los estados estables, y un circuito que no tiene ninguno
no tiene respuestas. El inversor conectado a sí mismo no tiene un estado
estable, como el `inv(X, X)` de la
[sección 48.1](index.md#481-compuertas-como-tablas-circuitos-como-reglas):
con la entrada en 0 el transistor p lleva la salida a 1, y con la entrada en
1 el n la lleva a 0. En un circuito real, ese inversor oscila o queda en un
valor intermedio entre 0 y 1, y ninguno de los dos casos está en el modelo.
El cortocircuito es el ejemplo más simple de Spivey: un cable conectado a la
alimentación y a la tierra a la vez. El modelo no da ningún estado; el
circuito real conduce una corriente que lo puede dañar.

### Una compuerta XOR de seis transistores

El ejercicio 12.2 de Spivey propone simular una compuerta XOR de seis
transistores. La disposición habitual usa un inversor para obtener la
negación de A, NA, y dos pares de transistores. El primer par, un n y un p
en paralelo entre B y la salida, conecta B con la salida cuando A es 0. El
segundo par es un inversor de B alimentado por A y por NA en lugar de la
alimentación y la tierra: cuando A es 1, lleva la salida a la negación de B;
cuando A es 0, sus dos transistores solo pueden llevar la salida al mismo
valor que B, el que ya impone el primer par.

<!-- ejemplo: capitulo-48/transistores.pl predicado: xor_cmos/3 -->
```prolog
%!  xor_cmos(?A, ?B, ?Z) is nondet.
%
%   Z es la salida de una compuerta XOR de seis transistores con entradas
%   A y B. Un inversor da NA, la negación de A. El par en paralelo, un
%   transistor n y uno p, conecta B con la salida cuando A es 0. Los otros
%   dos forman un inversor de B alimentado por A y por NA, que solo puede
%   llevar la salida a un valor distinto del de B cuando A es 1.
xor_cmos(A, B, Z) :-
    inversor_cmos(A, NA),
    ntran(B, NA, Z),
    ptran(B, A, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).
```

```prolog
?- xor_cmos(A, B, Z).
A = B, B = Z, Z = 0 ;
A = 0,
B = Z, Z = 1 ;
A = Z, Z = 1,
B = 0 ;
A = B, B = 1,
Z = 0.
```

Con las tres variables libres, las respuestas son exactamente las cuatro
filas de la tabla de `xor/3`: para cada combinación de entradas hay un solo
estado estable, y la prueba `xor_tabla` de `transistores.plt` lo verifica.
El modelo comprueba la lógica del circuito, no su comportamiento eléctrico:
Spivey advierte que los dos transistores del par en paralelo hacen falta por
efectos que la simulación no representa, y el
[ejercicio 14](index.md#ejercicios) muestra que el modelo no los distingue.
Como en la [sección 48.1](index.md#481-compuertas-como-tablas-circuitos-como-reglas),
la relación responde también en sentido inverso, aunque un transistor real
no lleve su compuerta a un valor desde el drenador: el modelo es más
permisivo que el circuito, y por eso solo puede mostrar que un diseño está
mal, no que funciona.

!!! question "Actividad"
    Predecir cuántas respuestas tiene `xor_cmos(A, B, 1)` y cuáles son, y
    comprobarlo. Después, cambiar en una copia de `transistores.pl` el
    `ntran(NA, B, Z)` por `ntran(A, B, Z)` y explicar las respuestas de la
    misma consulta.
