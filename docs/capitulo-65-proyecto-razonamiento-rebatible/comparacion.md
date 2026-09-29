# Tres lecturas de una regla con excepciones

Esta página contiene la sección [65.8](index.md#658-tres-lecturas-de-una-regla-con-excepciones) del
[capítulo 65](index.md): la negación como falla, la semántica bien fundada y la
derivación rebatible sobre los mismos dos casos. El ejemplo está en
`comparacion.pl`, en `ejemplos/capitulo-65/`, con sus pruebas, y se ejecuta en
una instalación local.

## Tres lecturas de una regla con excepciones

El curso tiene ahora tres maneras de leer una regla con excepciones: la
negación como falla de la [sección 65.1](index.md#651-el-problema-excepciones-con-negacion-como-falla), la semántica bien fundada de la
[sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada), que `tnot/1` calcula en la
[sección 39.4](../capitulo-39-tabulacion/index.md#394-negacion-tabulada), y la derivación rebatible. `comparacion.pl` pone
las tres sobre dos casos. El primero es el diamante de Drácula, con las
reglas de la [sección 65.1](index.md#651-el-problema-excepciones-con-negacion-como-falla) tabuladas:

<!-- ejemplo: capitulo-65/comparacion.pl predicado: vuela_tabulada/1 no_vuela_tabulada/1 -->
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

El segundo es el de la [sección 38.7](../capitulo-38-semantica-de-los-programas-logicos/index.md#387-las-reglas-del-sistema-experto): un ave con plumas que nada y
pesa 30 kilos, con la regla r13, «un ave que no es pingüino ni avestruz
vuela». El `experto.pl` del [capítulo 39](../capitulo-39-tabulacion/index.md), que el archivo carga, lo
resuelve con `tnot/1`. En la lectura rebatible, las reglas r11 y r12 no
necesitan la condición «no vuela»: concluyen el pingüino y el avestruz en
forma rebatible, y una regla estricta dice que ninguno de los dos vuela:

<!-- ejemplo: capitulo-65/comparacion.pl fragmento: % neg vuela: un pingüino o un avestruz no vuela. .. neg avestruz :~ true. -->
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
| El ave que nada, con r13 | no termina ([sección 38.7](../capitulo-38-semantica-de-los-programas-logicos/index.md#387-las-reglas-del-sistema-experto)) | pingüino indefinido | pingüino, presumiblemente sí; vuela, presumiblemente no |
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
