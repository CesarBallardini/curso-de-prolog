# Por qué sí y por qué no

Esta página contiene la sección [65.5](index.md#655-version-4-por-que-si-y-por-que-no) del
[capítulo 65](index.md): la cuarta versión del intérprete, que explica sus
conclusiones y sus silencios, y su relación con la abducción del
[capítulo 49](../capitulo-49-proyecto-diagnostico-abduccion/index.md). Los ejemplos están en `explicaciones.pl` y `explicar.pl`, en
`ejemplos/capitulo-65/`, con sus pruebas, y se ejecutan en una instalación
local.

## Por qué sí y por qué no

`respuesta/3` dice qué se concluye, no por qué. `explicaciones.pl` agrega
lo que el sistema experto de la
[sección 33.7](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica) sabía responder: «¿cómo?» y «¿por qué no?». La
primera pregunta la responde el intérprete con un argumento más, el árbol
de la derivación, como los árboles de prueba de la
[sección 33.4](../capitulo-33-introspeccion-y-metainterpretes/index.md#334-arboles-de-prueba):

<!-- ejemplo: capitulo-65/explicaciones.pl predicado: arbol/3 arboles/3 -->
```prolog
%!  arbol(+Criterio:list, +Meta, -Arbol) is nondet.
%
%   Arbol deriva Meta, un literal, en la raíz de la base.
arbol(_, Meta, predefinido(Meta)) :-
    predefinido(Meta),
    !,
    call(user:Meta).
arbol(_, Meta, estricta(Meta)) :-
    estricto(Meta).
arbol(Cr, Meta, regla((Meta :- Cuerpo), Arboles)) :-
    regla_estricta(Meta, Cuerpo),
    arboles(Cr, Cuerpo, Arboles),
    \+ rival(Cr, raiz, (Meta :- Cuerpo), _).
arbol(Cr, Meta, regla((Meta :~ Cuerpo), Arboles)) :-
    regla_rebatible(raiz, Meta, Cuerpo),
    arboles(Cr, Cuerpo, Arboles),
    \+ rival(Cr, raiz, (Meta :~ Cuerpo), _).

%!  arboles(+Criterio:list, +Cuerpo, -Arboles:list) is nondet.
%
%   Arboles son las derivaciones de los literales de Cuerpo, en orden; el
%   cuerpo true no necesita ninguna.
arboles(_, true, []) :-
    !.
arboles(Cr, (A, B), [Arbol|Arboles]) :-
    !,
    arbol(Cr, A, Arbol),
    arboles(Cr, B, Arboles).
arboles(Cr, Meta, [Arbol]) :-
    arbol(Cr, Meta, Arbol).
```

Es el [Patrón 46](../patrones.md#46-extender-el-interprete-no-el-programa): el intérprete crece, y la base no cambia. Cada nodo
`regla(Regla, Arboles)` guarda la regla usada. Las reglas rebatibles y las
presunciones de un árbol son lo que la conclusión **da por supuesto**, y
`supuestos/2` las junta con una gramática que recorre el árbol, como las
de la [sección 21.1](../capitulo-21-gramaticas-dcg/index.md#211-una-gramatica-es-un-conjunto-de-clausulas); `list_to_set/2` quita los repetidos y conserva el
orden de la primera aparición de cada regla:

<!-- ejemplo: capitulo-65/explicaciones.pl predicado: supuestos/2 rebatibles//1 lista_rebatibles//1 -->
```prolog
%!  supuestos(+Arbol, -Reglas:list) is det.
%
%   Reglas son las reglas rebatibles y las presunciones que usa Arbol, en
%   el orden en que aparecen y sin repetidos.
supuestos(Arbol, Reglas) :-
    phrase(rebatibles(Arbol), Todas),
    list_to_set(Todas, Reglas).

%!  rebatibles(+Arbol)// is det.
%
%   Las reglas rebatibles de Arbol, de la raíz a las hojas.
rebatibles(predefinido(_)) -->
    [].
rebatibles(estricta(_)) -->
    [].
rebatibles(regla(Regla, Arboles)) -->
    (   { Regla = (_ :~ _) }
    ->  [Regla]
    ;   []
    ),
    lista_rebatibles(Arboles).

%!  lista_rebatibles(+Arboles:list)// is det.
%
%   Las reglas rebatibles de cada árbol de Arboles.
lista_rebatibles([]) -->
    [].
lista_rebatibles([Arbol|Arboles]) -->
    rebatibles(Arbol),
    lista_rebatibles(Arboles).
```

La segunda pregunta la responde `por_que_no/3`:
para cada regla de la meta cuyo cuerpo se deriva, los rivales que la
derrotan. `explicar.pl` carga el módulo y la base de la tercera versión:

<!-- ejemplo: capitulo-65/explicar.pl archivo -->
```prolog
:- use_module(explicaciones).
:- ensure_loaded(refutadores).
```

```prolog
?- derivacion([especificidad], vuela(tweety), A).
A = regla((vuela(tweety):~ave(tweety)), [estricta(ave(tweety))]) ;
false.

?- por_que_no([especificidad], vuela(opus), M).
M = [derrotada((vuela(opus):~ave(opus)), [(neg vuela(opus):~pinguino(opus))])].

?- por_que_no([especificidad], vuela(coco), M).
M = [derrotada((vuela(coco):~ave(coco)), [(neg vuela(coco):^ave(coco), enferma(coco))])].

?- por_que_no([especificidad], vuela(nadie), M).
M = [].
```

La última respuesta distingue otro silencio: de `nadie` ninguna regla
tiene el cuerpo derivable, y no hay nada que derrotar. Son los tres casos
del predicado `whynot/1` de d-Prolog, que Covington presenta en el apartado
«A Special Explanatory Facility»: la meta se deriva, ninguna regla tiene el
cuerpo satisfecho, o una regla satisfecha tiene un rival que la derrota.
Sobre el automóvil que no arranca, las dos preguntas juntas dan lo que la abducción necesita:

```prolog
?- derivacion([especificidad], arranca(auto1), A), supuestos(A, S).
A = regla((arranca(auto1):-bien(auto1, bateria), bien(auto1, arranque), bien(auto1, combustible)), [regla((bien(auto1, bateria):~true), []), regla((bien(auto1, arranque):~true), []), regla((bien(auto1, combustible):~true), [])]),
S = [(bien(auto1, bateria):~true), (bien(auto1, arranque):~true), (bien(auto1, combustible):~true)] ;
false.

?- por_que_no([especificidad], arranca(auto2), M).
M = [derrotada((arranca(auto2):-bien(auto2, bateria), bien(auto2, arranque), bien(auto2, combustible)), [estricto(neg arranca(auto2))])].
```

La predicción de que un automóvil arranca descansa en tres presunciones.
Cuando la observación la refuta, alguna de las tres es falsa, y las tres
son los candidatos. El [capítulo 49](../capitulo-49-proyecto-diagnostico-abduccion/index.md) resuelve exactamente ese problema en
un circuito: cada compuerta se supone en el estado `ok`, que es una
presunción, y la abducción busca los estados que, en lugar de esas
presunciones, explican lo observado. El razonamiento por defecto va de las
presunciones a las predicciones; la abducción, de las predicciones
fallidas a las presunciones que hay que retirar. Flach escribe el
razonamiento por defecto de ese modo, como un intérprete que agrega un
supuesto a la explicación cuando no contradice las reglas, igual que el
intérprete abductivo de la
[sección 49.3](../capitulo-49-proyecto-diagnostico-abduccion/index.md#493-version-2-el-interprete-abductivo); el ejercicio 10 lo escribe y lo compara con este.
