# El intérprete especializado

Esta página contiene la sección [45.7](index.md#457-el-interprete-especializado) del
[capítulo 45](index.md): el intérprete de Mini evaluado parcialmente con
`parcial/3` del [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md), que resulta un compilador de Mini a Prolog,
y la comparación de las cuatro formas de ejecutar un programa. El código
está en `especializar.pl`, en `ejemplos/capitulo-45/`, con sus pruebas en
`especializar.plt`.

## El intérprete especializado

La [sección 35.4](../capitulo-35-transformacion-de-programas-y-compilacion/index.md#354-evaluacion-parcial) evaluó parcialmente un intérprete respecto de un
programa, y el [Patrón 50](../patrones.md#50-especializar-el-interprete) lo resume: el intérprete especializado hace
el trabajo de un compilador. `especializar.pl` aplica `parcial/3` del
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) al intérprete de la [sección 45.3](index.md#453-el-interprete). Lo único que
agrega es el control, que decide qué hacer con cada llamada:

<!-- ejemplo: capitulo-45/especializar.pl predicado: control_mini/3 -->
```prolog
%!  control_mini(+Tabla:list, +Meta, -Accion) is semidet.
%
%   Accion es lo que parcial/3 hace con Meta al especializar el intérprete
%   de Mini: desplegar, o dejar(Residuo). Cuando no hay respuesta, Meta
%   queda como está. parcial/3 usa solo la primera respuesta.
control_mini(Tabla, ejecutar_sentencia(K, E0, E, S0, S), dejar(Llamada)) :-
    memberchk(K-Nombre, Tabla),
    findall(X-_, member(X-_, E0), E),
    llamada(Nombre, E0, E, S0, S, Llamada).
control_mini(_, ejecutar_sentencia(_, _, _, _, _), desplegar).
control_mini(_, ejecutar_bloque(_, _, _, _, _), desplegar).
control_mini(_, evaluar(_, _, _), desplegar).
control_mini(_, operar(_, _, _, _), desplegar).
control_mini(_, cierta(_, _), desplegar).
control_mini(_, falsa(_, _), desplegar).
control_mini(_, contraria(_, _), desplegar).
control_mini(_, comparar(_, _, _), desplegar).
control_mini(_, valor(X, E, V), dejar(true)) :-
    valor(X, E, V).
control_mini(_, actualizar(X, V, E0, E), dejar(true)) :-
    actualizar(X, V, E0, E).
control_mini(_, X is Exp, dejar(true)) :-
    ground(Exp),
    catch(X is Exp, _, fail).
control_mini(_, Comparacion, dejar(true)) :-
    comparacion(Comparacion),
    ground(Comparacion),
    call(Comparacion).
```

Las cláusulas del intérprete se despliegan, porque el árbol que recorren se
conoce. `valor/3` y `actualizar/4` se ejecutan durante la especialización:
los nombres del entorno se conocen aunque sus valores no, y cada variable
de Mini pasa a ser una variable de Prolog. Una operación sin variables se
calcula; con variables, queda en el residuo. Y cada `si` y cada `mientras`
pasa a ser un predicado nuevo, cuyos argumentos son los valores de las
variables antes y después, y las dos puntas de la salida: desplegar un
`mientras` no terminaría, porque la cantidad de iteraciones depende de los
valores. `especializar_programa/2` produce la cláusula principal y, con
`definicion/5`, una definición por construcción. `listar_ejemplo/1` escribe
el resultado para un programa de ejemplo; para el factorial, escribe:

```prolog
principal(A, B) :-
    mientras_1(1, 5, C, _, A, [C|B]).
mientras_1(A, B, C, D, E, F) :-
    B>0,
    G is A*B,
    H is B-1,
    mientras_1(G, H, C, D, E, F).
mientras_1(A, B, A, B, C, C) :-
    B=<0.
```

Y `listar_ejemplo(mcd)`, donde el `si` del cuerpo del bucle es otro predicado:

```prolog
principal(A, B) :-
    mientras_1(84, 36, C, _, A, [C|B]).
mientras_1(A, B, C, D, E, F) :-
    A=\=B,
    si_2(A, B, G, H, E, I),
    mientras_1(G, H, C, D, I, F).
mientras_1(A, B, A, B, C, C) :-
    A=:=B.
si_2(A, B, C, B, D, D) :-
    A>B,
    C is A-B.
si_2(A, B, A, C, D, D) :-
    A=<B,
    C is B-A.
```

En el factorial, los argumentos de `mientras_1/6` son `f` y `n` antes del
bucle, `f` y `n` después, y la salida. Las asignaciones anteriores al bucle
se ejecutaron durante la especialización: la llamada recibe 1 y 5. Lo que
el programa escribe al final, `f`, ya está en la salida: `[C|B]`. El
residuo no tiene entornos, ni nombres de variables, ni árbol: son cláusulas
de Prolog, que el compilador de Prolog compila. Como un programa Mini no
lee datos, un programa sin bucles se calcula entero al especializarlo:

```prolog
?- analizar("x := 2 * 3; escribir x; y := x + z; escribir y", P), especializar_programa(P, Cs).
P = [asignar(x, bin(*, num(2), num(3))), escribir(id(x)), asignar(y, bin(+, id(x), id(z))), escribir(id(y))],
Cs = [(principal([6, 6|_A], _A):-true)].
```

`correr_especializado/2` carga el residuo en un módulo temporal, con
`in_temporary_module/3` de `library(modules)`, y lo ejecuta. Con `suma`,
las cuatro formas de ejecutar el programa cuestan:

| Forma | Inferencias |
|---|---|
| `interpretar/2` | 36 203 |
| `maquina/2`, con el código de `compilar/2` | 76 063 |
| `maquina/2`, con el código de `compilar_optimizado/2` | 76 063 |
| `correr_especializado/2`, especialización incluida | 3 949 |

El código optimizado no gana nada en `suma`, que no tiene constantes que
plegar ni saltos que acortar. La versión especializada usa la novena parte
de las inferencias del intérprete, incluido el costo de especializarlo, y
es el único de los dos compiladores que no hubo que escribir: salió del
intérprete y de `control_mini/3`. El compilador de las secciones
[45.4](index.md#454-la-generacion-de-codigo-y-el-ensamblador) a [45.6](index.md#456-optimizacion) sigue teniendo su lugar: produce código para una máquina que no es
Prolog, decide cómo se usan la pila y la memoria, y puede optimizar lo que
el especializador no ve.
