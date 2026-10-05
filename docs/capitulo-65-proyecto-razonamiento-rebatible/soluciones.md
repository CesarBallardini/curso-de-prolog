# Soluciones del capítulo 65 — Proyecto: razonamiento rebatible

Las soluciones de los ejercicios 2, 3, 6, 7, 9 y 10 están en
`ejemplos/capitulo-65/soluciones.pl`, una base con varios dominios que no
comparten predicados y que carga el módulo `explicaciones`
(`explicaciones.pl`, que reexporta el intérprete de `rebatible.pl`); la del
ejercicio 5, en `soluciones_pato.pl`; la del 8, en `soluciones_cadena.pl`;
las de los ejercicios 4 y 11, en `soluciones_inscripciones.pl`, que carga
`correlativas.pl`; la del 12, en `soluciones_yale.pl`; y la del 13, en
`soluciones_complecion.pl`, que carga `complecion.pl`. Cada archivo tiene sus pruebas en el `.plt` del mismo
nombre.

## Ejercicio 1

Con `aves.pl` cargado:

```prolog
?- respuesta([], vuela(rufo), R).
R = sin_conclusion.

?- respuesta([declarada], vuela(rufo), R).
R = sin_conclusion.

?- respuesta([declarada], vuela(dracula), R).
R = presumiblemente_no.

?- respuesta([especificidad], adulto(juana), R).
R = presumiblemente_si.
```

Sin la especificidad, la regla de los murciélagos y la de los mamíferos se
derrotan entre sí, y sobre Rufo no hay conclusión; la superioridad
declarada no cambia nada, porque no habla de esas dos reglas. Sobre
Drácula, en cambio, la declaración basta: la regla de los muertos supera a
la de los murciélagos y no queda derrotada por ella, y la de los mamíferos
concluye lo mismo que la de los muertos, así que no la refuta. Que Juana
es adulta no tiene competidor: ninguna regla concluye `neg adulto(juana)`.

## Ejercicio 2

<!-- ejemplo: capitulo-65/soluciones.pl fragmento: % habla_pensilvania(X): X habla .. neg nacio_en(X, eeuu) :~ habla_dialecto_aleman(X). -->
```prolog
% habla_pensilvania(X): X habla el dialecto alemán de Pensilvania.
habla_pensilvania(hans).

%!  habla_dialecto_aleman(?X) is nondet.
%
%   X habla un dialecto del alemán: quien habla el de Pensilvania.
habla_dialecto_aleman(X) :-
    habla_pensilvania(X).

%!  nacio_en(?X, ?Lugar) is nondet.
%
%   X nació en Lugar en forma estricta: quien nació en Pensilvania nació
%   en los Estados Unidos.
nacio_en(X, eeuu) :-
    nacio_en(X, pensilvania).

nacio_en(X, pensilvania) :~ habla_pensilvania(X).
neg nacio_en(X, eeuu) :~ habla_dialecto_aleman(X).
```

```prolog
?- respuesta([especificidad], nacio_en(hans, eeuu), R).
R = presumiblemente_si.

?- por_que_no([especificidad], neg nacio_en(hans, eeuu), M).
M = [derrotada((neg nacio_en(hans, eeuu):~habla_dialecto_aleman(hans)), [(nacio_en(hans, eeuu):-nacio_en(hans, pensilvania))])].
```

Que Hans habla un dialecto del alemán es definitivo; que nació en
Pensilvania, presumible. La regla estricta «quien nació en Pensilvania
nació en los Estados Unidos» tiene entonces un cuerpo solo presumible, y
la regla rebatible contraria, un cuerpo definitivo. Gana la estricta: la
segunda cláusula de `rival/4` deja que una regla estricta con cuerpo
derivable refute cualquier regla, y ninguna cláusula deja que una
rebatible refute una estricta. La razón es que la regla estricta no tiene
excepciones: si su cuerpo vale, su cabeza también. La duda está en el
cuerpo, y la conclusión hereda esa duda: es presumible, no definitiva.

## Ejercicio 3

<!-- ejemplo: capitulo-65/soluciones.pl fragmento: % estudiante(X): X es estudiante universitario. .. neg se_mantiene(X) :~ estudiante(X). -->
```prolog
% estudiante(X): X es estudiante universitario.
estudiante(ines).

% empleado(X): X tiene un empleo.
empleado(ines).

adulto(X) :~ estudiante(X).
empleado(X) :~ adulto(X).
se_mantiene(X) :~ empleado(X).
neg se_mantiene(X) :~ estudiante(X).
```

```prolog
?- respuesta([especificidad], se_mantiene(ines), R).
R = presumiblemente_no.
```

Sin el eslabón «los estudiantes normalmente no tienen empleo», en la base
`cuerpo(estudiante(ines))` se deriva `adulto(ines)` y de ahí
`empleado(ines)`, sin rivales. El cuerpo de la regla de los empleados se
deriva del de la regla de los estudiantes, y no a la inversa: la regla de
los estudiantes es más específica, y prevalece.

## Ejercicio 4

<!-- ejemplo: capitulo-65/soluciones_inscripciones.pl predicado: excepciones/3 -->
```prolog
%!  excepciones(+Legajo:integer, +Materia:atom, -Requisitos:list) is det.
%
%   Requisitos son las correlativas de Materia que el alumno Legajo cumple
%   solo por una excepción: presumiblemente, y no en forma estricta.
excepciones(Legajo, Materia, Requisitos) :-
    findall(R,
            ( correlativa(Materia, R),
              respuesta([especificidad], cumple(Legajo, Materia, R),
                        presumiblemente_si) ),
            Requisitos).
```

```prolog
?- excepciones(105, am2, Rs).
Rs = [am1, alg].

?- excepciones(101, bd, Rs).
Rs = [pp].
```

`Legajo` y `Materia` son `+`: `respuesta/3` exige una meta sin variables,
y con cualquiera de los dos libre produce un error de instanciación en
lugar de enumerar. `Requisitos` es `-` y el predicado es `det`, porque
`findall/3` da siempre una lista, vacía si no hay excepciones.

## Ejercicio 5

<!-- ejemplo: capitulo-65/soluciones_pato.pl fragmento: % tiene_plumas(X): X tiene plumas. .. pinguino(X) :~ ave(X), nada(X). -->
```prolog
% tiene_plumas(X): X tiene plumas.
tiene_plumas(pato).
tiene_plumas(pingu).

% nada(X): X nada.
nada(pato).
nada(pingu).

% vuela(X): se observó que X vuela.
vuela(pato).

%!  ave(?X) is nondet.
%
%   X es un ave: tiene plumas.
ave(X) :-
    tiene_plumas(X).

% Un pingüino no vuela, y lo que vuela no es un pingüino.
neg vuela(X) :-
    pinguino(X).
neg pinguino(X) :-
    vuela(X).

vuela(X) :~ ave(X).
pinguino(X) :~ ave(X), nada(X).
```

```prolog
?- respuesta([especificidad], pinguino(pato), R).
R = definitivamente_no.
```

```text
?- respuesta([especificidad], pinguino(pingu), R).
ERROR: Stack limit (1.0Gb) exceeded
```

Con el pato, la parte estricta decide: se observó que vuela, y la
contrapuesta concluye en forma estricta que no es un pingüino. Con Pingu,
la regla rebatible de los pingüinos tiene un rival posible, la
contrapuesta, cuyo cuerpo es `vuela(pingu)`; para saber si ese cuerpo se
deriva hay que ver si la regla de las aves tiene rivales, y su rival es
`neg vuela(pingu) :- pinguino(pingu)`, cuyo cuerpo es la meta del
principio. Covington describe el mismo ciclo con una persona que es a la
vez capitalista y marxista: para mostrar que una regla no está refutada
hay que mostrar que la regla contraria no se aplica, y viceversa. Su
solución es no escribir las contrapuestas y declarar en cambio qué
literales son incompatibles, con un predicado que el intérprete usa sin
volver a derivar.

## Ejercicio 6

<!-- ejemplo: capitulo-65/soluciones.pl predicado: sospechosas/2 literal/2 -->
```prolog
%!  sospechosas(+Auto, -Piezas:list) is det.
%
%   Piezas son las piezas cuyas presunciones sostienen la regla de
%   arranca(Auto), que una observación derrotó; la lista está vacía si
%   ninguna regla de arranca(Auto) está derrotada.
sospechosas(Auto, Piezas) :-
    por_que_no([especificidad], arranca(Auto), Motivos),
    findall(Pieza,
            ( member(derrotada((_ :- Cuerpo), _), Motivos),
              literal(bien(Auto, Pieza), Cuerpo),
              once(derivacion([especificidad], bien(Auto, Pieza), Arbol)),
              supuestos(Arbol, [_|_]) ),
            Piezas).

%!  literal(?Literal, +Conjuncion) is nondet.
%
%   Literal es uno de los literales de Conjuncion.
literal(Literal, (A, B)) :-
    !,
    (   literal(Literal, A)
    ;   literal(Literal, B)
    ).
literal(Literal, Literal).
```

```prolog
?- sospechosas(auto2, Ps).
Ps = [bateria, arranque, combustible].

?- sospechosas(auto3, Ps).
Ps = [arranque, combustible].

?- sospechosas(auto1, Ps).
Ps = [].
```

Los automóviles 2 y 3 no arrancan; del 3, además, se observó que las luces
encienden, y una regla estricta concluye de eso que su batería está bien.
Esa pieza ya no se sostiene en una presunción, y sale de las sospechosas.
El automóvil 1 no tiene ninguna predicción refutada. Es el paso previo a la
abducción del [capítulo 49](../capitulo-49-proyecto-diagnostico-abduccion/index.md): las sospechosas son las presunciones que
un diagnóstico puede retirar, y cada observación nueva que se deriva en
forma estricta reduce el conjunto.

## Ejercicio 7

<!-- ejemplo: capitulo-65/soluciones.pl predicado: escribir_derivacion/1 escribir_derivacion/2 -->
```prolog
%!  escribir_derivacion(+Arbol) is det.
%
%   Escribe Arbol, un árbol de derivacion/3, con una línea por nodo.
escribir_derivacion(Arbol) :-
    escribir_derivacion(Arbol, 0).

%!  escribir_derivacion(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol con Sangria espacios antes de su raíz.
escribir_derivacion(predefinido(Meta), S) :-
    format("~t~*|~q, predefinido~n", [S, Meta]).
escribir_derivacion(estricta(Meta), S) :-
    format("~t~*|~q, en forma estricta~n", [S, Meta]).
escribir_derivacion(regla(Regla, Arboles), S) :-
    partes(Regla, Cabeza, _),
    format("~t~*|~q, por ~q~n", [S, Cabeza, Regla]),
    S1 is S + 2,
    forall(member(A, Arboles), escribir_derivacion(A, S1)).
```

```prolog
?- derivacion([especificidad], arranca(auto1), A), escribir_derivacion(A).
arranca(auto1), por arranca(auto1):-bien(auto1,bateria),bien(auto1,arranque),bien(auto1,combustible)
  bien(auto1,bateria), por bien(auto1,bateria):~true
  bien(auto1,arranque), por bien(auto1,arranque):~true
  bien(auto1,combustible), por bien(auto1,combustible):~true
A = regla((arranca(auto1):-bien(auto1, bateria), bien(auto1, arranque), bien(auto1, combustible)), [regla((bien(auto1, bateria):~true), []), regla((bien(auto1, arranque):~true), []), regla((bien(auto1, combustible):~true), [])]) ;
false.
```

`~t~*|` completa con espacios hasta la columna que da el argumento, que es
la sangría. `partes/3`, que exporta el módulo `rebatible`, separa la
cabeza de cualquier clase de regla.

## Ejercicio 8

<!-- ejemplo: capitulo-65/soluciones_cadena.pl predicado: cadena/1 medir/3 -->
```prolog
%!  cadena(+N:integer) is det.
%
%   Reemplaza la base por una cadena de N+1 clases, de la 0 a la N, con el
%   individuo a en la clase N.
cadena(N) :-
    must_be(nonneg, N),
    retractall(clase(_, _)),
    retractall(tiene(_) :~ _),
    retractall(neg tiene(_) :~ _),
    forall(between(1, N, J),
           ( I is J - 1,
             assertz((clase(I, X) :- clase(J, X))) )),
    assertz(clase(N, a)),
    forall(between(0, N, I),
           (   I mod 2 =:= 0
           ->  assertz((tiene(X) :~ clase(I, X)))
           ;   assertz((neg tiene(X) :~ clase(I, X)))
           )).

%!  medir(+N:integer, -Respuesta, -Inferencias:integer) is det.
%
%   Respuesta es lo que la cadena de N+1 clases dice de tiene(a), e
%   Inferencias lo que cuesta obtenerlo.
medir(N, Respuesta, Inferencias) :-
    cadena(N),
    statistics(inferences, I0),
    respuesta([especificidad], tiene(a), Respuesta),
    statistics(inferences, I),
    Inferencias is I - I0.
```

```prolog
?- medir(2, R, I).
R = presumiblemente_si,
I = 2775.

?- medir(8, R, I).
R = presumiblemente_si,
I = 276374.

?- medir(16, R, I).
R = presumiblemente_si,
I = 8120138.
```

La respuesta es siempre la de la última clase, la más específica. Las
inferencias crecen mucho más rápido que la cadena: de 8 a 16 clases se
multiplican por 29, cerca de la quinta potencia de la cantidad de clases.
Cada una de las N reglas tiene como rivales a las de paridad contraria;
cada comparación deriva el cuerpo de una regla desde el de otra, recorriendo
la cadena estricta, y cada derivación rebatible vuelve a buscar rivales
para las reglas que usa. Covington advierte que su intérprete prioriza la
claridad sobre la eficiencia; tabular las comparaciones, como en el
[capítulo 39](../capitulo-39-tabulacion/index.md), evitaría repetirlas.

## Ejercicio 9

<!-- ejemplo: capitulo-65/soluciones.pl predicado: vuela_t/1 no_vuela_t/1 -->
```prolog
%!  vuela_t(?X) is nondet.
%
%   X vuela: es un murciélago del que no se prueba que no vuela.
vuela_t(X) :-
    murcielago(X),
    tnot(no_vuela_t(X)).

%!  no_vuela_t(?X) is nondet.
%
%   X no vuela: está muerto. La regla de los muertos, superior, ya no
%   tiene la excepción.
no_vuela_t(X) :-
    muerto(X).
```

```prolog
?- vuela_t(dracula).
false.

?- no_vuela_t(dracula).
true.

?- vuela_t(rufo).
true.
```

Con `tnot/1`, la superioridad se escribe quitando la excepción de la regla
superior: los muertos no vuelan, sin condiciones. El programa deja de tener
un ciclo a través de la negación, pasa a ser estratificado, y la respuesta
sobre Drácula es falsa, no indefinida. La derivación rebatible llega a lo
mismo sin tocar las reglas, con un hecho `superior/2`, y sigue
distinguiendo «presumiblemente no» de «no se sabe»: `vuela_t(nadie)` es
falso, igual que `vuela_t(dracula)`.

## Ejercicio 10

<!-- ejemplo: capitulo-65/soluciones.pl predicado: explicar_por_defecto/2 explicar_f/3 probar_f/1 contradice/1 -->
```prolog
%!  explicar_por_defecto(+Meta, -Supuestos:list) is nondet.
%
%   Supuestos son los nombres de los supuestos por defecto con los que
%   Meta se prueba sin contradecir las reglas.
explicar_por_defecto(Meta, Supuestos) :-
    explicar_f(Meta, [], Supuestos).

%!  explicar_f(+Meta, +S0:list, -S:list) is nondet.
%
%   Meta se prueba con las reglas y con supuestos por defecto; S son los
%   supuestos de S0 más los que la prueba agrega.
explicar_f(true, S, S).
explicar_f((A, B), S0, S) :-
    explicar_f(A, S0, S1),
    explicar_f(B, S1, S).
explicar_f(Meta, S, S) :-
    Meta \= true,
    Meta \= (_, _),
    probar_f(Meta).
explicar_f(Meta, S0, [Nombre|S]) :-
    por_defecto(Nombre, Meta, Cuerpo),
    explicar_f(Cuerpo, S0, S),
    \+ contradice(Meta).

%!  probar_f(+Meta) is nondet.
%
%   Meta se prueba solo con las reglas.
probar_f(true).
probar_f(Meta) :-
    Meta \= true,
    regla_f(Meta, Cuerpo),
    probar_f(Cuerpo).

%!  contradice(+Meta) is semidet.
%
%   Las reglas prueban lo contrario de Meta.
contradice(no(A)) :-
    !,
    probar_f(A).
contradice(A) :-
    probar_f(no(A)).
```

```prolog
?- explicar_por_defecto(vuela(dracula), E).
E = [murcielagos_vuelan(dracula)] ;
false.

?- explicar_por_defecto(no(vuela(dracula)), E).
E = [mamiferos_no_vuelan(dracula)] ;
E = [muertos_no_vuelan(dracula)] ;
false.

?- explicar_por_defecto(vuela(rufo), E).
E = [murcielagos_vuelan(rufo)] ;
false.

?- explicar_por_defecto(no(vuela(rufo)), E).
E = [mamiferos_no_vuelan(rufo)] ;
false.
```

El intérprete es el abductivo de la
[sección 49.3](../capitulo-49-proyecto-diagnostico-abduccion/index.md#493-version-2-el-interprete-abductivo) con otra condición: el supuesto se agrega si
su conclusión no contradice lo que prueban las reglas. Como ninguna regla
sin excepciones concluye nada sobre el vuelo, ningún supuesto se descarta,
y tanto Drácula como Rufo tienen explicaciones para volar y para no volar.
Flach lo resuelve dando nombre a los supuestos y escribiendo reglas que
cancelan uno por su nombre, como «los murciélagos son mamíferos que
vuelan»; cada conflicto se resuelve a mano. La derivación rebatible
resuelve el de Rufo sola, por la especificidad, y deja el de Drácula sin
conclusión hasta que una declaración de superioridad lo decide.

## Ejercicio 11

<!-- ejemplo: capitulo-65/soluciones_inscripciones.pl predicado: inscripcion_con_criterio/4 con_criterio/4 decisiones/2 las_dos/1 -->
```prolog
%!  inscripcion_con_criterio(+Criterio:list, +Legajo:integer,
%!      +Materia:atom, -Resultado) is det.
%
%   Resultado es el de inscripcion_rebatible/3, con Criterio para
%   comparar las reglas de cada requisito.
inscripcion_con_criterio(Criterio, Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado0),
    (   Resultado0 = rechazada(falta(_))
    ->  con_criterio(Criterio, Legajo, Materia, Resultado)
    ;   Resultado = Resultado0
    ).

%!  con_criterio(+Criterio:list, +Legajo:integer, +Materia:atom,
%!      -Resultado) is det.
%
%   por_requisitos/3 con Criterio.
con_criterio(Criterio, Legajo, Materia, Resultado) :-
    findall(R-V,
            ( correlativa(Materia, R),
              respuesta(Criterio, cumple(Legajo, Materia, R), V) ),
            Vs),
    (   member(R-presumiblemente_no, Vs)
    ->  Resultado = rechazada(falta(R))
    ;   member(R-sin_conclusion, Vs)
    ->  Resultado = a_revisar(R)
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   findall(R, member(R-presumiblemente_si, Vs), Rs),
        Resultado = condicional(Rs)
    ).

%!  decisiones(-Antes:list, -Despues:list) is det.
%
%   Con una autorización para que Bruno curse Sintaxis sin Álgebra, Antes
%   y Despues son las decisiones sobre su inscripción en Sintaxis con los
%   dos criterios, antes y después de que se inscriba de nuevo en Álgebra.
%   Deja los datos como estaban.
decisiones(Antes, Despues) :-
    estado(E),
    setup_call_cleanup(
        assertz(autorizacion(102, ssl, alg)),
        ( las_dos(Antes),
          inscribir(102, alg, aceptada),
          las_dos(Despues) ),
        ( retract(autorizacion(102, ssl, alg)),
          restaurar(E) )).

%!  las_dos(-Decisiones:list) is det.
%
%   Decisiones son las de Bruno en Sintaxis con cada criterio.
las_dos(Decisiones) :-
    findall(C-R,
            ( member(C, [[especificidad], [declarada, especificidad]]),
              inscripcion_con_criterio(C, 102, ssl, R) ),
            Decisiones).
```

La base agrega la superioridad:

<!-- ejemplo: capitulo-65/soluciones_inscripciones.pl fragmento: % La autorización prevalece sobre el refutador. .. desaprobada(L, R))). -->
```prolog
% La autorización prevalece sobre el refutador.
superior((cumple(L, M, R) :~ correlativa(M, R), autorizacion(L, M, R)),
         (neg cumple(L, M, R) :^ correlativa(M, R), cursa(L, R),
                                 desaprobada(L, R))).
```

```prolog
?- decisiones(Antes, Despues).
Antes = [[especificidad]-condicional([alg]), [declarada, especificidad]-condicional([alg])],
Despues = [[especificidad]-a_revisar(alg), [declarada, especificidad]-condicional([alg])].
```

Antes de inscribirse de nuevo, la autorización basta con los dos
criterios. Después, el refutador de quien cursa una materia desaprobada es
más específico que la regla de quien cursa, pero no que la de la
autorización, cuyo cuerpo no dice nada de cursar: con la especificidad sola,
la socava igual, porque la autorización no lo supera, y la inscripción
queda pendiente, `a_revisar(alg)`. Con la superioridad declarada, la autorización prevalece y
la inscripción sigue siendo condicional. `decisiones/2` agrega la
autorización con `assertz/1`, porque `autorizacion/3` es dinámico, y deja
los datos como estaban con `estado/1` y `restaurar/1` del módulo `datos`.

## Ejercicio 12

La base repite la de `yale.pl` y agrega la regla de la descarga:

<!-- ejemplo: capitulo-65/soluciones_yale.pl fragmento: % Después de una descarga, .. neg vale(cargada, result(descarga, S)) :~ vale(cargada, S). -->
```prolog
% Después de una descarga, el arma normalmente no está cargada.
neg vale(cargada, result(descarga, S)) :~ vale(cargada, S).
```

`historia/3` es la de `yale.pl` con los fluentes `cargada` y `vivo`:

```prolog
?- historia([especificidad], [descarga, espera, disparo], H).
H = [inicio-definitivamente_si-definitivamente_si, descarga-sin_conclusion-presumiblemente_si, espera-sin_conclusion-presumiblemente_si, disparo-sin_conclusion-presumiblemente_si].
```

Después de la descarga compiten dos reglas sobre `vale(cargada, S)`: la
persistencia, con el cuerpo `vale(cargada, s0)`, y la regla de la
descarga, con el mismo cuerpo. Cada cuerpo se deriva del otro, así que
ninguna es más específica, y las dos se derrotan. Que el arma esté
cargada queda sin conclusión, la regla causal del disparo no se aplica, y
Johnnie sobrevive. En la regla del disparo, la condición `vale(vivo, S)`
hacía la diferencia; aquí la condición de la regla causal, `vale(cargada,
S)`, es la misma que la de la persistencia, y no hay condición que
agregar. La superioridad declarada decide:

<!-- ejemplo: capitulo-65/soluciones_yale.pl fragmento: % La regla de la descarga prevalece .. (vale(F, result(_, S)) :~ vale(F, S))). -->
```prolog
% La regla de la descarga prevalece sobre la persistencia.
superior((neg vale(cargada, result(descarga, S)) :~ vale(cargada, S)),
         (vale(F, result(_, S)) :~ vale(F, S))).
```

Pero con ella sola, el arma vuelve a quedar sin conclusión después de la
espera: la persistencia solo lleva hacia adelante lo que vale, y
`neg vale(cargada, …)` no es un `vale/2`. Falta la persistencia de lo que
no vale:

<!-- ejemplo: capitulo-65/soluciones_yale.pl fragmento: % Lo que no vale normalmente .. neg vale(F, result(_, S)) :~ neg vale(F, S). -->
```prolog
% Lo que no vale normalmente sigue sin valer: sin esta regla, la descarga
% no persiste.
neg vale(F, result(_, S)) :~ neg vale(F, S).
```

```prolog
?- historia([declarada], [descarga, espera, disparo], H).
H = [inicio-definitivamente_si-definitivamente_si, descarga-presumiblemente_no-presumiblemente_si, espera-presumiblemente_no-presumiblemente_si, disparo-presumiblemente_no-presumiblemente_si].
```

Con las dos reglas, el arma presumiblemente no está cargada desde la
descarga, y Johnnie presumiblemente sigue vivo después del disparo.

## Ejercicio 13

`soluciones_complecion.pl` agrega los tres programas con `generado/2`:

<!-- ejemplo: capitulo-65/soluciones_complecion.pl fragmento: % generado(Nombre, Clausulas): .. generado(tautologia, [ (p :- p) ]). -->
```prolog
% generado(Nombre, Clausulas): los programas del ejercicio.
generado(amistoso, [ (amistoso(pedro) :- \+ amistoso(pedro)) ]).
generado(antepasados,
    [ (progenitor(ana, luis) :- true),
      (progenitor(luis, eva) :- true),
      (antepasado(X, Y) :- progenitor(X, Y)),
      (antepasado(X, Y) :- progenitor(X, Z), antepasado(Z, Y))
    ]).
generado(tautologia, [ (p :- p) ]).
```

El encabezado es `completo(+Nombre, -Modelo) is semidet`: el nombre del
programa tiene que llegar instanciado, porque `clausulas/2` del
[capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md)
lo exige, y el predicado falla cuando la compleción tiene cero modelos o
más de uno. `modelo_unico/2` da además qué ocurre en esos casos:

<!-- ejemplo: capitulo-65/soluciones_complecion.pl predicado: completo/2 modelo_unico/2 -->
```prolog
%!  completo(+Nombre, -Modelo:list) is semidet.
%
%   La compleción del programa Nombre tiene un único modelo, Modelo.
completo(Nombre, Modelo) :-
    modelos(Nombre, [Modelo]).

%!  modelo_unico(+Nombre, -Respuesta) is det.
%
%   Respuesta es el único modelo de la compleción del programa Nombre, o
%   ninguno, o varios(N) si tiene N modelos.
modelo_unico(Nombre, Respuesta) :-
    modelos(Nombre, Ms),
    length(Ms, N),
    (   N =:= 1
    ->  Ms = [Respuesta]
    ;   N =:= 0
    ->  Respuesta = ninguno
    ;   Respuesta = varios(N)
    ).
```

```prolog
?- findall(N-M, ( member(N, [amistoso, tautologia, gusta]), modelo_unico(N, M) ), L).
L = [amistoso-ninguno, tautologia-varios(2), gusta-[alumno_de(pablo, pedro), gusta(pedro, pablo)]].

?- escribir_complecion(amistoso).
sii(amistoso(A),(A=pedro,\+amistoso(pedro)))
true.

?- escribir_complecion(antepasados).
sii(progenitor(A,B),(A=ana,B=luis;A=luis,B=eva))
sii(antepasado(A,B),(progenitor(A,B);existe([C],(progenitor(A,C),antepasado(C,B)))))
true.

?- completo(antepasados, M), modelo_minimo(antepasados, Min), M == Min.
M = Min, Min = [antepasado(ana, eva), antepasado(ana, luis), antepasado(luis, eva), progenitor(ana, luis), progenitor(luis, eva)].
```

La compleción de `amistoso(pedro) :- \+ amistoso(pedro)` dice que Pedro es
amistoso si y solo si no lo es, y no tiene modelos, aunque la cláusula
equivale en lógica clásica al hecho `amistoso(pedro)`: es el caso más
simple de recursión a través de la negación, como `r :- \+ r` en la
[sección 38.3](../capitulo-38-semantica-de-los-programas-logicos/index.md#383-negacion-como-falla-la-complecion-de-clark-y-sldnf).
La de `p :- p` es `p` si y solo si `p`, que vale en las dos
interpretaciones: la compleción no siempre es completa, y una recursión
sin negación ni hechos que la funden deja el átomo sin decidir, mientras
que el modelo mínimo lo hace falso. En `antepasado/2`, la variable del
medio pasa a estar cuantificada existencialmente, y el programa, definido,
tiene un único modelo, que coincide con el modelo mínimo. La búsqueda
recorre las $2^{18}$ interpretaciones de una base de 18 átomos, y tarda en
este caso un segundo y medio: `modelos/2` sirve para comprobar programas
pequeños, no para calcular el modelo de uno real.
