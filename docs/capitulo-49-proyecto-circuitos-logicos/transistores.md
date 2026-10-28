# Compuertas hechas con transistores

Esta página continúa la página
[Los productos como vectores de signos y los retardos en cascada](vectores.md#498-retardos-en-cascada)
del [capítulo 49](index.md), con la sección
[49.9](#499-compuertas-hechas-con-transistores): las compuertas de las
secciones anteriores son tablas, y aquí se construyen con los transistores
CMOS descritos por sus estados estables: el inversor, el cortocircuito y una
compuerta XOR de seis transistores. Los ejemplos están en `transistores.pl`, en
`ejemplos/capitulo-49/`, con sus pruebas.

## 49.9 Compuertas hechas con transistores

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
[sección 49.1](index.md#491-compuertas-como-tablas-circuitos-como-reglas),
un transistor es la relación de sus estados estables, escrita con hechos, y
la alimentación y la tierra son dos cables con un valor fijo:

<!-- ejemplo: capitulo-49/transistores.pl fragmento: % pwr(X): el cable X .. ntran(_, 0, _). -->
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

<!-- ejemplo: capitulo-49/transistores.pl predicado: inversor_cmos/2 cortocircuito/1 -->
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
[sección 49.1](index.md#491-compuertas-como-tablas-circuitos-como-reglas):
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

<!-- ejemplo: capitulo-49/transistores.pl predicado: xor_cmos/3 -->
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
[ejercicio 14](#ejercicios) muestra que el modelo no los distingue.
Como en la [sección 49.1](index.md#491-compuertas-como-tablas-circuitos-como-reglas),
la relación responde también en sentido inverso, aunque un transistor real
no lleve su compuerta a un valor desde el drenador: el modelo es más
permisivo que el circuito, y por eso solo puede mostrar que un diseño está
mal, no que funciona.

!!! question "Actividad"
    Predecir cuántas respuestas tiene `xor_cmos(A, B, 1)` y cuáles son, y
    comprobarlo. Después, cambiar en una copia de `transistores.pl` el
    `ntran(NA, B, Z)` por `ntran(A, B, Z)` y explicar las respuestas de la
    misma consulta.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; la simulación es `nondet` porque la relación, con entradas libres, tiene varias respuestas, aunque con las entradas ligadas tenga una |
    | C3 | los circuitos son relaciones: `simular/3`, `sumar_bits/4` y `ejecutar/4` se consultan también en sentido inverso, y las pruebas lo verifican |
    | C6 | la descripción de un circuito es solo datos, y el intérprete, `simular/4`, no depende de ninguno: cambia el significado de las compuertas con la conducta, sin tocar la descripción ni el intérprete |
    | C7 | 152 pruebas en diez archivos; cada versión se compara con la anterior (la descripción del sumador con `sumador/5`, la fórmula con la simulación, el sumador de tres bits con la suma aritmética), y la recursión sin tabla se prueba con `call_with_inference_limit/3` |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y el [capítulo 50](../capitulo-50-proyecto-diagnostico-abduccion/index.md) los da por hechos.

13. **(2)** Con `ptran/3` y `ntran/3` de la
    [sección 49.9](#499-compuertas-hechas-con-transistores), escribir la
    compuerta NAND de la tecnología CMOS, con dos transistores p en paralelo
    entre el 1 y la salida y dos n en serie entre la salida y el 0, y
    verificar que tiene la tabla de `nand/3`. Explicar por qué el modelo de
    Spivey admite también la consulta inversa, con la salida dada, aunque un
    transistor real no puede llevar su compuerta a un valor.
14. **(2)** Spivey señala que los dos transistores del par en paralelo de
    la XOR son necesarios por efectos eléctricos que el modelo no
    representa. Escribir las dos variantes de cinco transistores, sin el
    transistor p y sin el n del par, y verificar que el modelo les da la
    misma tabla que a `xor_cmos/3`. Explicar qué dice ese resultado sobre lo
    que el modelo de estados estables puede verificar.

## Resumen

| | |
|---|---|
| **compuerta como tabla** | un hecho por fila de la tabla de verdad, con las entradas antes de la salida |
| **circuito como conjunción** | una meta por compuerta y una variable por cable; los cables internos no aparecen en la cabeza |
| **estado estable** | una solución de la conjunción: ninguna en un inversor realimentado, dos en un biestable |
| **circuito como dato** | `circuito(Nombre, Entradas, Salidas)` y `componente(Circuito, Id, Tipo, Entradas, Salidas)`, con cables nombrados y jerarquía |
| **conducta** | el significado de cada compuerta, argumento de `simular/4`: su tabla, su fórmula o una restricción booleana |
| **ruta** | la lista de identificadores de componentes que lleva a una compuerta desde el circuito exterior |
| **suma de productos** | una disyunción de conjunciones de literales; se obtiene con la forma normal negativa y la distribución, y se simplifica con la absorción |
| **equivalencia** | con `library(clpb)`, `taut/2` sobre las restricciones de los dos circuitos; `sat/1` y `labeling/1` dan una entrada que los distingue |
| **circuito secuencial** | una parte combinacional y un registro de estado; ejecutarlo es un `foldl/6` sobre los pulsos del reloj |
| **estados alcanzables** | la clausura tabulada del grafo de estados; sobre ella, una propiedad se verifica para toda entrada |
| `simular/3`, `simular/4`, `tabla_de_verdad/2`, `compuerta_en/3` | el intérprete de la descripción y las preguntas sobre la estructura |
| `formula/3`, `fnn/2`, `suma_de_productos/2`, `como_formula/2` | la fórmula de una salida y su suma de productos |
| `equivalentes/2`, `diferencia/3`, `cuantas/4` | la verificación con `library(clpb)` |
| `secuencial/3`, `paso/5`, `ejecutar/4` | los circuitos secuenciales |
| `alcanzable/3`, `grafo/3`, `siempre/3` | el grafo de estados, tabulado, y las propiedades sobre él |
| **vector de signos** | un producto como un signo por variable: `+`, `-` o `0`; la absorción y la combinación se deciden posición por posición |
| **implicante primo** | un producto que implica la función y que no se puede combinar con otro; se obtiene combinando vectores que difieren en un signo |
| `vector/3`, `cubre/2`, `combinar/3`, `unos/3`, `implicantes_primos/2` | los productos como vectores y el primer paso de Quine y McCluskey |
| `retardo/4`, `retardar/3` | N retardos unitarios en cascada, con N la longitud de la lista de estados |
| **transistor** | la relación de sus estados estables: el p conduce con la compuerta en 0, el n con la compuerta en 1 |
| `ptran/3`, `ntran/3`, `inversor_cmos/2`, `xor_cmos/3`, `cortocircuito/1` | las compuertas CMOS y un circuito sin estados estables |
| **[Patrón 60](../patrones.md#60-interprete-con-conducta-como-parametro)** | intérprete con conducta como parámetro |
| `acyclic_term/1` | se cumple si el término no es cíclico: un circuito sin realimentación |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Fallas de compuertas y diagnóstico por abducción sobre el módulo `circuitos` | [capítulo 50](../capitulo-50-proyecto-diagnostico-abduccion/index.md) |
| Autómatas finitos, de los que un circuito secuencial es un caso | [capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md) |

## Referencias

- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall International, 1996 — «Hardware simulation».
  [Edición en línea](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  Esta página toma, para la
  [sección 49.9](#499-compuertas-hechas-con-transistores), el modelo de los
  transistores p y n, el inversor CMOS, el cortocircuito y la compuerta XOR
  de seis transistores de su ejercicio 12.2.

El código del capítulo es propio, escrito para el curso: los programas de
Clocksin y de Spivey se reescribieron con la representación de este
capítulo, y la verificación con `library(clpb)` no tiene equivalente en esos
libros.
