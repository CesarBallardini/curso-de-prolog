# Interlingua lógica y trato

Esta página contiene las secciones
[54.8](index.md#548-version-6-una-interlingua-con-cuantificadores) y
[54.9](index.md#549-version-7-tu-y-usted) del [capítulo 54](index.md): la
versión 6, `cuantificadores.pl`, que traduce por una interlingua de
fórmulas lógicas con cuantificadores, como el traductor inglés–latín de
Covington, y la versión 7, `tratamiento.pl`, que agrega al traductor de
transferencia el trato de tú y de usted.

## Una interlingua con cuantificadores

El traductor del capítulo transfiere árboles: cada lengua tiene el suyo, y
`transferir/2` relaciona uno con el otro. Covington traduce de otra
manera: sus dos gramáticas relacionan una oración con una **fórmula
lógica**, y la fórmula es la interlingua. «Every dog barked» es
`all(X, dog(X), barked(X))`, y la gramática latina genera desde esa
fórmula la oración latina. `cuantificadores.pl` hace lo mismo con el
castellano y el inglés, y con dos cuantificadores:

```text
todo(X, Restriccion, Alcance)        alguno(X, Restriccion, Alcance)
```

Los predicados se nombran con los lemas castellanos: `alumno(X)`,
`leer(X, Y)`. La técnica es la de Covington: cada palabra aporta un
término con variables, y la unificación los compone. El nombre aporta
`X^alumno(X)`, la restricción; el determinante recibe la restricción y el
alcance y devuelve la fórmula cuantificada; el verbo transitivo aporta
`Y^X^leer(X, Y)`, y el sintagma nominal del objeto cuantifica sobre su
primera variable:

<!-- ejemplo: capitulo-54/cuantificadores.pl predicado: oracion_es_q//1 sn_es_q//1 sv_es_q//1 det_es//2 -->
```prolog
%!  oracion_es_q(?F)// is nondet.
%
%   Una oración castellana con la fórmula F de su orden de palabras.
oracion_es_q(F) -->
    sn_es_q((X^Alcance)^F),
    sv_es_q(X^Alcance).

%!  sn_es_q(?Sem)// is nondet.
%
%   Un sintagma nominal: el determinante concuerda con el nombre en género.
sn_es_q(Sem) -->
    det_es((X^Restriccion)^Sem, G),
    nom_es(X^Restriccion, G).

%!  sv_es_q(?Sem)// is nondet.
%
%   Un sintagma verbal: un verbo intransitivo, o uno transitivo con su
%   objeto, que cuantifica sobre la segunda variable del verbo.
sv_es_q(X^Alcance) -->
    verbo_es_q(X^Alcance).
sv_es_q(X^Pred) -->
    verbo_es_q(Y^X^Alcance),
    sn_es_q((Y^Alcance)^Pred).

% det_es(Sem, G): las formas de los determinantes.
det_es((X^R)^(X^A)^todo(X, R, A), m) --> ["todo"].
det_es((X^R)^(X^A)^todo(X, R, A), f) --> ["toda"].
det_es((X^R)^(X^A)^alguno(X, R, A), m) --> ["un"].
det_es((X^R)^(X^A)^alguno(X, R, A), f) --> ["una"].
```

La gramática compone los cuantificadores en el orden de las palabras: el
del sujeto contiene al del objeto. Pero «todo alumno lee un libro» tiene
dos lecturas: que cada alumno lee algún libro, quizá distinto, o que hay
un libro que todos los alumnos leen. Es una **ambigüedad de alcance**, y
no se ve en el árbol de la oración: las dos lecturas tienen las mismas
palabras en el mismo orden. `alcance/2` da la segunda lectura invirtiendo
el orden de dos cuantificadores anidados:

<!-- ejemplo: capitulo-54/cuantificadores.pl predicado: alcance/2 -->
```prolog
%!  alcance(+S, ?F) is nondet.
%
%   F es una lectura de la fórmula S: S misma, o, si S tiene dos
%   cuantificadores anidados, la que los pone en el orden inverso.
alcance(S, S).
alcance(S, F) :-
    S =.. [Q1, X, R1, B1],
    cuantificador(Q1),
    B1 =.. [Q2, Y, R2, P],
    cuantificador(Q2),
    B2 =.. [Q1, X, R1, P],
    F =.. [Q2, Y, R2, B2].
```

```prolog
?- findall(F, phrase(oracion_logica_es(F), ["todo", "alumno", "lee", "un", "libro"]), Fs).
Fs = [todo(_A, alumno(_A), alguno(_B, libro(_B), leer(_A, _B))), alguno(_C, libro(_C), todo(_D, alumno(_D), leer(_D, _C)))].
```

Las dos fórmulas no dicen lo mismo. En un modelo con dos alumnos, Ana y
Beto, que leen libros distintos, la primera es verdadera y la segunda es
falsa. `lecturas/2` evalúa cada lectura en ese modelo con `verdadera/1`,
que prueba `todo` comprobando que ningún objeto cumple la restricción sin
cumplir el alcance, con la negación como falla del
[capítulo 10](../capitulo-10-negacion-como-falla/index.md):

```prolog
?- lecturas(["todo", "alumno", "lee", "un", "libro"], Ls).
Ls = [todo(_A, alumno(_A), alguno(_B, libro(_B), leer(_A, _B)))-verdadera, alguno(_C, libro(_C), todo(_D, alumno(_D), leer(_D, _C)))-falsa].
```

Para traducir, se analiza la oración en una de sus lecturas y se genera
la oración de la otra lengua que tiene esa misma lectura. Generar desde
una fórmula ligada exige una precaución: si la gramática unificara la
fórmula pedida con la de cada oración, podría unir dos variables
cuantificadas distintas. `misma_formula/2` exige que las dos sean
variantes, con `=@=`:

<!-- ejemplo: capitulo-54/cuantificadores.pl predicado: misma_formula/2 es_en_logica/2 -->
```prolog
%!  misma_formula(+F0, ?F) is semidet.
%
%   F es la fórmula F0, con sus variables. Si F llega ligada, tiene que
%   ser una variante de F0: unificarlas sin más podría unir dos variables
%   cuantificadas distintas, y «un libro lee todo alumno» pasaría por una
%   lectura de «todo alumno lee un libro».
misma_formula(F0, F) :-
    (   var(F)
    ->  F = F0
    ;   F0 =@= F,
        F = F0
    ).

%!  es_en_logica(+Es:list(string), ?En:list(string)) is nondet.
%
%   En traduce Es por la interlingua: una fórmula de Es, en alguna de sus
%   lecturas, generada en inglés.
es_en_logica(Es, En) :-
    phrase(oracion_logica_es(F), Es),
    phrase(oracion_logica_en(F), En).
```

```prolog
?- traducciones_logicas(["todo", "alumno", "lee", "un", "libro"], Ts).
Ts = [["every", "student", "reads", "a", "book"]].

?- traducciones_logicas(["every", "cat", "sees", "a", "house"], Ts).
Ts = [["todo", "gato", "ve", "una", "casa"]].
```

Las dos lecturas dan la misma oración inglesa, porque el inglés tiene la
misma ambigüedad: «every student reads a book» también admite las dos. La
traducción la conserva sin resolverla, que es lo que corresponde cuando
el texto no dice cuál de las dos es la intención. En la otra dirección, la
interlingua no tiene género: «toda» y «una» salen de la gramática
castellana, que hace concordar el determinante con «casa».

La interlingua tiene un costo que la transferencia no tiene: lo que la
fórmula no representa se pierde. Las fórmulas de esta versión no tienen
artículo definido ni número, así que el vocabulario se reduce a «todo» y
«un» en singular. Covington lo señala al traducir al latín, cuya gramática
tiene dos maneras de decir «some».

## Tú y usted

Covington pone entre las dificultades de la traducción que las lenguas
expresan distinta cantidad de información, y da como ejemplo el trato:
el castellano distingue el de confianza, tú, del de respeto, usted, y el
inglés tiene una sola forma, *you*. Del castellano al inglés no hay
problema: las dos formas dan *you*. Del inglés al castellano hay que
elegir, y la oración no dice cuál; lo dice el contexto.

`tratamiento.pl` agrega las dos formas al traductor de transferencia, con
cláusulas de los predicados multifile de las gramáticas, como las
soluciones de los ejercicios. «Tú» lleva el verbo en segunda persona, que
en el vocabulario del capítulo es la tercera más una s: «come», «comes»;
el número `tu` la marca, y la cláusula del sujeto omitido de
`castellano.pl` sirve también para él: «comes manzanas». «Usted» lleva el
verbo en tercera persona. *You* lleva el verbo inglés en plural:

<!-- ejemplo: capitulo-54/tratamiento.pl predicado: sujeto_es//2 numero_verbo/4 pronombre_en/3 sujeto/2 -->
```prolog
% tú y usted como sujetos castellanos; tú también puede omitirse, con la
% cláusula de tacito/1 de castellano.pl y el número tu.
sujeto_es(pron(tu), tu) -->
    ["tú"].
sujeto_es(pron(usted), sg) -->
    ["usted"].

% La segunda persona del singular: la tercera más una s.
numero_verbo(tu, Singular, _, Forma) :-
    string_concat(Singular, "s", Forma).

% you, con el verbo en plural.
pronombre_en(you, pl, "you").

% Los dos tratos, y el sujeto omitido de la segunda persona, son you.
sujeto(tacito(tu), pron(you)).
sujeto(pron(tu), pron(you)).
sujeto(pron(usted), pron(you)).
```

Del inglés al castellano, `traducciones/2` da las tres: el sujeto
omitido, «tú» y «usted». `traducir_con_trato/3` recibe el trato como un
dato del contexto y descarta, en el árbol castellano, los sujetos que no
le corresponden:

<!-- ejemplo: capitulo-54/tratamiento.pl predicado: traducir_con_trato/3 trato/2 -->
```prolog
%!  traducir_con_trato(+Trato, -Es:string, +En:string) is nondet.
%
%   Es traduce al castellano el texto inglés En con el Trato, tu o usted,
%   cuando la oración se dirige a alguien; las demás oraciones se
%   traducen como con traducir/2.
traducir_con_trato(Trato, Es, En) :-
    palabras(En, PalabrasEn),
    phrase(oracion_en(ArbolEn), PalabrasEn),
    transferir(ArbolEs, ArbolEn),
    arg(1, ArbolEs, Sujeto),
    trato(Sujeto, Trato),
    phrase(oracion_es(ArbolEs), PalabrasEs),
    texto(PalabrasEs, Es).

%!  trato(+Sujeto, ?Trato) is semidet.
%
%   El Sujeto castellano corresponde al Trato: tú, omitido o no, al de
%   confianza, usted al de respeto. Cualquier otro sujeto admite los dos.
trato(Sujeto, Trato) :-
    (   trato_de(Sujeto, T)
    ->  Trato = T
    ;   true
    ).
```

```prolog
?- traducciones("You read a book.", Ts).
Ts = ["Lees un libro.", "Tú lees un libro.", "Usted lee un libro."].

?- findall(Es, traducir_con_trato(usted, Es, "You read a book."), L).
L = ["Usted lee un libro."].
```

El trato no puede deducirse de la oración: es información que el inglés
no codifica. El traductor la recibe como parámetro, del mismo modo que un
traductor humano la deduce de quién habla con quién.

!!! example "Patrón 62 — Información de contexto como parámetro"
    **Problema.** La salida de una relación depende de algo que la
    entrada no dice: el inglés *you* no indica si se trata al
    destinatario de tú o de usted, y el castellano tiene que elegir. La
    relación da varias respuestas correctas, y solo el contexto decide
    cuál corresponde.

    **Versión ingenua.** Dejar que el traductor dé todas las respuestas,
    como `traducciones/2`, que para «You read a book.» da tres, y que
    quien lo usa elija. O guardar el trato en un hecho dinámico, o en una
    opción global, que la gramática consulta: la traducción depende
    entonces de un estado que no aparece en la consulta, dos
    traducciones con tratos distintos no pueden convivir, y cada prueba
    tiene que fijarlo antes y restablecerlo después.

    **Patrón.** El dato del contexto es un argumento más del predicado de
    entrada, `traducir_con_trato/3`, que lo pasa a un solo predicado,
    `trato/2`. Ese predicado examina el árbol castellano después de la
    transferencia y descarta los sujetos que no corresponden al trato:
    con `usted`, «You read a book.» da una sola traducción, y con `tu`,
    las dos que tutean. Las oraciones cuyo sujeto no fija el trato
    admiten los dos, y las gramáticas y la transferencia no cambian. El
    parámetro no cambia cómo se calcula, como la conducta del
    [Patrón 60](../patrones.md#60-interprete-con-conducta-como-parametro)
    o el criterio del
    [Patrón 64](../patrones.md#64-superioridad-como-parametro), ni sobre
    qué datos se razona, como el mundo del
    [Patrón 69](../patrones.md#69-descripcion-del-mundo-como-parametro):
    elige, entre las respuestas que la relación ya da, las que el
    contexto admite.

    **Cuándo no usarlo.** Cuando la entrada ya trae la información: del
    castellano al inglés, «tú» y «usted» dan *you*, y el parámetro no
    tendría nada que decidir. Cuando el contexto se manifiesta en un
    lugar que el filtro no examina: `trato/2` mira solo el árbol
    castellano, y el ejercicio 14 muestra que, con el sujeto omitido en
    tercera persona, acepta «Come manzanas.» para *you* con el trato de
    tú; el filtro tiene que examinar también el sujeto inglés. Y cuando
    el contexto cambia muchas decisiones repartidas en la derivación:
    filtrar el resultado genera primero todas las variantes, y conviene
    pasar el dato a los no terminales que deciden.
