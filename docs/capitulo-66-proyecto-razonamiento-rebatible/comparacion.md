# Tres lecturas de una regla con excepciones

Esta página continúa la página
[Excepciones en las correlativas y la anticipación de los rivales](anticipacion.md#667-version-6-la-anticipacion-de-los-rivales) del
[capítulo 66](index.md), con la sección [66.8](#668-tres-lecturas-de-una-regla-con-excepciones): la negación como falla, la semántica bien fundada y la
derivación rebatible sobre los mismos dos casos. El ejemplo está en
`comparacion.pl`, en `ejemplos/capitulo-66/`, con sus pruebas, y se ejecuta en
una instalación local.

## 66.8 Tres lecturas de una regla con excepciones

El curso tiene ahora tres maneras de leer una regla con excepciones: la
negación como falla de la [sección 66.1](index.md#661-el-problema-excepciones-con-negacion-como-falla), la semántica bien fundada de la
[sección 39.5](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#395-la-semantica-bien-fundada), que `tnot/1` calcula en la
[sección 40.4](../capitulo-40-tabulacion/subsuncion.md#404-negacion-tabulada), y la derivación rebatible. `comparacion.pl` pone
las tres sobre dos casos. El primero es el diamante de Drácula, con las
reglas de la [sección 66.1](index.md#661-el-problema-excepciones-con-negacion-como-falla) tabuladas:

<!-- ejemplo: capitulo-66/comparacion.pl predicado: vuela_tabulada/1 no_vuela_tabulada/1 -->
```prolog
%!  vuela_tabulada(?X) is nondet.
%
%   X vuela: es un murciélago y no se prueba que no vuele. Con Drácula, la
%   respuesta es indefinida.
vuela_tabulada(X) :-
    murcielago(X),
    tnot(no_vuela_tabulada(X)).

%!  no_vuela_tabulada(?X) is nondet.
%
%   X no vuela: está muerto y no se prueba que vuele.
no_vuela_tabulada(X) :-
    muerto(X),
    tnot(vuela_tabulada(X)).
```

El segundo es el de la [sección 39.7](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#397-las-reglas-del-sistema-experto): un ave con plumas que nada y
pesa 30 kilos, con la regla r13, «un ave que no es pingüino ni avestruz
vuela». El `experto.pl` del [capítulo 40](../capitulo-40-tabulacion/index.md), que el archivo carga, lo
resuelve con `tnot/1`. En la lectura rebatible, las reglas r11 y r12 no
necesitan la condición «no vuela»: concluyen el pingüino y el avestruz en
forma rebatible, y una regla estricta dice que ninguno de los dos vuela:

<!-- ejemplo: capitulo-66/comparacion.pl fragmento: % neg vuela: un pingüino o un avestruz no vuela. .. neg avestruz :~ true. -->
```prolog
% neg vuela: un pingüino o un avestruz no vuela.
neg vuela :-
    pinguino.
neg vuela :-
    avestruz.

% r13: un ave normalmente vuela. r11: un ave que nada normalmente es un
% pingüino. r12: un ave de más de 50 kilos normalmente es un avestruz.
vuela :~ ave.
pinguino :~ ave, nada.
avestruz :~ ave, peso(P), P > 50.

% Mundo cerrado para las dos hipótesis: ningún ave es un pingüino ni un
% avestruz, salvo que una regla lo concluya.
neg pinguino :~ true.
neg avestruz :~ true.
```

```prolog
?- valor(vuela_tabulada(dracula), V).
V = indefinido.

?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
R = resultado([], [pinguino]).

?- respuesta([especificidad], pinguino, R).
R = presumiblemente_si.

?- respuesta([especificidad], vuela, R).
R = presumiblemente_no.

?- respuesta([especificidad], avestruz, R).
R = presumiblemente_no.
```

| Caso | Negación como falla | Semántica bien fundada | Derivación rebatible |
|---|---|---|---|
| Drácula | no termina | indefinido | sin conclusión; con `superior/2`, presumiblemente no |
| El ave que nada, con r13 | no termina ([sección 39.7](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#397-las-reglas-del-sistema-experto)) | pingüino indefinido | pingüino, presumiblemente sí; vuela, presumiblemente no |
| Algo que no se sabe | falso | falso | sin conclusión, salvo una presunción negativa |

Las tres coinciden en un programa estratificado sin conflictos: la
semántica bien fundada da lo mismo que `\+`, y una regla rebatible sin
rivales se aplica como una estricta. Difieren en tres cosas. La negación
como falla y la semántica bien fundada suponen el mundo cerrado para todos
los predicados; la derivación rebatible, solo donde una presunción negativa
lo dice. Las dos primeras tratan «no vuela» como algo que se supone cuando
no se prueba lo contrario; la tercera, como algo que se concluye con una
regla, y por eso no forma un ciclo a través de la negación. Y ante un
conflicto real, la semántica bien fundada deja la respuesta indefinida sin
decir por qué; la derivación rebatible también se abstiene, pero puede
decir qué reglas se derrotaron, y un criterio de superioridad puede
decidir. El precio es el de la sección anterior: cada conclusión compara
reglas, y comparar reglas es derivar.

El capítulo continúa en la página
[Cuatro ampliaciones del intérprete](ampliaciones.md#669-conclusiones-incompatibles),
con cuatro temas que las fuentes tratan y las seis versiones dejan afuera.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

10. ★ **(2)** Escribir con `tnot/1` el diamante de Drácula con la superioridad
    de la regla de los muertos, y comparar el resultado y el programa con
    los de la [sección 66.8](#668-tres-lecturas-de-una-regla-con-excepciones). ¿Qué propiedad del programa cambia?

## Referencias

- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley & Sons, 1994 — apartados 8.1, «Default reasoning», y 8.2, «The
  semantics of incomplete information».
  [Edición en línea](https://book.simply-logical.space/src/text/3_part_iii/8.1.html).
  Esta página toma el ejemplo de Drácula.
