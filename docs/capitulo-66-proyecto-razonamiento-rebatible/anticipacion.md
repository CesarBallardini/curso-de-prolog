# Excepciones en las correlativas y la anticipación de los rivales

Esta página continúa la página
[Por qué sí y por qué no](explicaciones.md#665-version-4-por-que-si-y-por-que-no) del
[capítulo 66](index.md), con las secciones [66.6](#666-version-5-excepciones-en-las-correlativas) y [66.7](#667-version-6-la-anticipacion-de-los-rivales): la
quinta versión del intérprete, que admite excepciones en las correlativas
de *Inscripciones*, y la sexta, que agrega a `rival/4` la anticipación de
d-Prolog. Los ejemplos están en `correlativas.pl`, `rebatible.pl` y
`anticipacion.pl`, en `ejemplos/capitulo-66/`, con sus pruebas, y se
ejecutan en una instalación local.

## 66.6 Versión 5: excepciones en las correlativas

*Inscripciones* rechaza una inscripción si falta una correlativa: es el
primer motivo que encuentra `inscripcion_posible/3`, de la
[sección 16.10](../capitulo-16-control/index.md#1610-el-proyecto-las-validaciones-de-una-inscripcion), que el [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md) conserva en el módulo `reglas`.
Una facultad real admite excepciones: quien está cursando la correlativa
puede inscribirse de manera condicional, y el departamento puede autorizar
a un alumno a cursar sin un requisito. Y las excepciones tienen a su vez
excepciones: quien cursa de nuevo una materia que desaprobó podría no
estar en condiciones. `correlativas.pl` carga los dos módulos sin cambiarlos
y decide cada requisito con reglas rebatibles:

<!-- ejemplo: capitulo-66/correlativas.pl fragmento: autorizacion(105, am2, alg). .. neg cumple(L, M, R) :^ correlativa(M, R), cursa(L, R), desaprobada(L, R). -->
```prolog
autorizacion(105, am2, alg).

%!  cumple(?Legajo:integer, ?Materia:atom, ?Requisito:atom) is nondet.
%
%   El alumno Legajo cumple el Requisito de Materia en forma estricta:
%   lo aprobó.
cumple(Legajo, Materia, Requisito) :-
    correlativa(Materia, Requisito),
    aprobada(Legajo, Requisito, _).

%!  desaprobada(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo tiene una nota menor que la mínima en Materia.
desaprobada(Legajo, Materia) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota < Minima.

% Un requisito no aprobado normalmente no se cumple; sí, si el alumno lo
% está cursando o si está autorizado.
neg cumple(_L, M, R) :~ correlativa(M, R).
cumple(L, M, R) :~ correlativa(M, R), cursa(L, R).
cumple(L, M, R) :~ correlativa(M, R), autorizacion(L, M, R).

% Quien cursa de nuevo un requisito que desaprobó podría no cumplirlo.
neg cumple(L, M, R) :^ correlativa(M, R), cursa(L, R), desaprobada(L, R).
```

`correlativa/2`, `cursa/2` y `aprobada/3` vienen de los módulos del
[capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md). El intérprete llama a un predicado importado en la base
entera, y en una base `cuerpo(C)` lo acepta solo como uno de los literales
de C: si lo llamara, la especificidad dependería de los datos de un alumno
y no de las reglas. La regla de quien cursa es más específica que la
general, y lo mismo la de la autorización; el refutador es más específico
que la regla de quien cursa, y la socava.

La decisión sobre cada requisito es rebatible; la decisión sobre la
inscripción, en cambio, junta las respuestas de todos los requisitos, y
esa parte procedural queda en Prolog común, como aconseja Covington:

<!-- ejemplo: capitulo-66/correlativas.pl predicado: inscripcion_rebatible/3 por_requisitos/3 -->
```prolog
%!  inscripcion_rebatible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es el de inscripcion_posible/3, salvo cuando esta rechaza
%   por una correlativa: entonces es rechazada(falta(R)) con el primer
%   requisito que presumiblemente no se cumple, a_revisar(R) con el primero
%   del que las reglas no concluyen nada, rechazada(sin_vacantes), o
%   condicional(Rs), con los requisitos que se dan por cumplidos por una
%   excepción.
inscripcion_rebatible(Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado0),
    (   Resultado0 = rechazada(falta(_))
    ->  por_requisitos(Legajo, Materia, Resultado)
    ;   Resultado = Resultado0
    ).

%!  por_requisitos(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado decide la inscripción del alumno Legajo en Materia por la
%   respuesta de las reglas sobre cada correlativa.
por_requisitos(Legajo, Materia, Resultado) :-
    findall(R-V,
            ( correlativa(Materia, R),
              respuesta([especificidad], cumple(Legajo, Materia, R), V) ),
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
```

!!! question "Actividad"
    Elena, legajo 105, cursa Análisis I, no aprobó Álgebra y tiene una
    autorización para cursar Análisis II sin ella. Predecir la respuesta
    de `inscripcion_posible(105, am2, R)` y la de
    `inscripcion_rebatible(105, am2, R)`, y comprobarlas.

```prolog
?- respuesta([especificidad], cumple(102, am2, am1), R).
R = presumiblemente_no.

?- inscripcion_posible(105, am2, R).
R = rechazada(falta(am1)).

?- inscripcion_rebatible(105, am2, R).
R = condicional([am1, alg]).

?- inscripcion_posible(101, bd, R).
R = rechazada(falta(pp)).

?- inscripcion_rebatible(101, bd, R).
R = rechazada(falta(ssl)).
```

De las 49 combinaciones de un alumno y una materia, solo esas dos cambian.
Ana, legajo 101, está cursando Paradigmas, y la excepción la cubre; el
rechazo pasa al requisito que de verdad falta, Sintaxis. La no monotonía
se ve con una operación del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md): Bruno, legajo 102, desaprobó
Álgebra y se inscribe de nuevo en ella.

```prolog
?- costo(posible, P), costo(rebatible, R).
P = 1275,
R = 40656.

?- inscripcion_rebatible(102, ssl, R0), inscribir(102, alg, R1), inscripcion_rebatible(102, ssl, R).
R0 = rechazada(falta(alg)),
R1 = aceptada,
R = a_revisar(alg).
```

Antes de inscribirse, Bruno no cumplía Álgebra para cursar Sintaxis.
Después, la regla de quien cursa lo favorece, pero el refutador de quien
cursa de nuevo una materia desaprobada la socava; ninguna regla decide, y
la inscripción queda para que la decida una persona. Un dato nuevo no
agregó una conclusión: quitó una. `costo/2` mide las inferencias de
decidir las 49 combinaciones con cada versión, en una sesión recién
iniciada: la rebatible cuesta unas 32 veces más, y todo ese costo está en
las 21 combinaciones que el [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md) rechaza por una correlativa,
donde cada requisito se decide comparando reglas. Las cifras cambian un
poco si antes se ejecutaron otras consultas, que ya cargaron las
bibliotecas; la proporción, no.

## 66.7 Versión 6: la anticipación de los rivales

En las versiones anteriores, una regla derrota a otra aunque ella misma
esté derrotada. Con Folio, en la
[sección 66.4](index.md#664-version-3-refutadores-y-presunciones), eso es lo
deseable: la regla de los pingüinos, socavada, sigue impidiendo que se
concluya que vuela. Covington observa que en otros casos el requisito es
demasiado fuerte, y lo muestra con dos cadenas de reglas de la misma forma.
Aquí son dos cadenas sobre el pago de la matrícula:

<!-- ejemplo: capitulo-66/anticipacion.pl fragmento: % intercambio(X): X es un alumno de intercambio. .. neg paga(X) :~ becario(X). -->
```prolog
% intercambio(X): X es un alumno de intercambio.
intercambio(lucia).
intercambio(marcos).

% becario(X): X tiene una beca.
becario(lucia).

regular(X) :~ intercambio(X).
inscripto(X) :~ becario(X).
paga(X) :~ regular(X).
paga(X) :~ inscripto(X).
neg paga(X) :~ intercambio(X).
neg paga(X) :~ becario(X).
```

Cada regla que dice que el alumno no paga es más específica que la que
dice que paga en su propia cadena: un alumno de intercambio normalmente es
regular, y un becario normalmente está inscripto. Pero entre cadenas no hay
comparación posible. Lucía es de intercambio y becaria, y cada regla
negativa queda derrotada por la regla positiva de la otra cadena:

```prolog
?- respuesta([especificidad], paga(lucia), R).
R = sin_conclusion.

?- rival([especificidad], raiz, (neg paga(lucia) :~ intercambio(lucia)), Rv).
Rv = (paga(lucia):~inscripto(lucia)) ;
false.
```

El rival de la regla de los alumnos de intercambio es la regla de los
inscriptos, que a su vez está refutada por la de los becarios, superior a
ella. Una regla así, refutada por otra que la supera, es un rival débil:
su conclusión no se puede obtener. La **anticipación** (*preemption*, en
d-Prolog) lo deja de lado: un rival rebatible o un refutador no cuenta si
una regla que lo supera, con el cuerpo derivable, concluye lo contrario, o
si lo contrario se deriva de la parte estricta. `anticipado/3` lo
comprueba, y `rival/4` lo consulta en sus dos últimas cláusulas cuando el
criterio contiene `anticipacion`:

<!-- ejemplo: capitulo-66/rebatible.pl predicado: anticipado/3 -->
```prolog
%!  anticipado(+Criterio:list, +Base, +Rival) is semidet.
%
%   Con anticipacion en Criterio, Rival, una regla rebatible o un
%   refutador, queda anticipado: su cabeza contraria se deriva en forma
%   estricta, o la concluye una regla estricta cuyo cuerpo se deriva, o una
%   regla rebatible que supera a Rival y cuyo cuerpo se deriva.
anticipado(Cr, Base, Rival) :-
    memberchk(anticipacion, Cr),
    partes(Rival, Cabeza, _),
    contrario(Cabeza, Contrario),
    (   estricto(Base, Contrario)
    ;   regla_estricta(Contrario, Cuerpo),
        derivable(Cr, Base, Cuerpo)
    ;   regla_rebatible(Base, Contrario, Cuerpo),
        derivable(Cr, Base, Cuerpo),
        supera(Cr, (Contrario :~ Cuerpo), Rival)
    ),
    !.
```

La anticipación es un elemento más de la lista del criterio, como indica
el [Patrón 64](../patrones.md#64-superioridad-como-parametro): la base no cambia, y la misma consulta se hace con
los dos criterios. `medir/3` cuenta las inferencias de una respuesta, después
de una primera llamada que carga lo necesario:

<!-- ejemplo: capitulo-66/anticipacion.pl predicado: medir/3 -->
```prolog
%!  medir(+Criterio:list, +Meta, -Inferencias:integer) is det.
%
%   Inferencias son las que cuesta la respuesta sobre Meta con Criterio,
%   después de una primera llamada que carga lo que haga falta.
medir(Criterio, Meta, Inferencias) :-
    respuesta(Criterio, Meta, _),
    statistics(inferences, I0),
    respuesta(Criterio, Meta, _),
    statistics(inferences, I),
    Inferencias is I - I0.
```

```prolog
?- respuesta([anticipacion, especificidad], paga(lucia), R).
R = presumiblemente_no.

?- rival([anticipacion, especificidad], raiz, (neg paga(lucia) :~ intercambio(lucia)), Rv).
false.

?- medir([especificidad], paga(lucia), I).
I = 3908.

?- medir([anticipacion, especificidad], paga(lucia), I).
I = 5868.
```

Con anticipación, Lucía presumiblemente no paga: la regla de los regulares
queda anticipada por la de los alumnos de intercambio, y la de los
inscriptos por la de los becarios. La respuesta cuesta un 50 % más de
inferencias, porque cada rival se vuelve a examinar para ver si otra regla
lo anticipa; con Marcos, que solo es de intercambio, la respuesta es la
misma con los dos criterios, y el costo sube de 2 548 a 3 427 inferencias.
Las pruebas de `aves.pl` y de `refutadores.pl` comprueban que la
anticipación no cambia ninguna respuesta de las versiones anteriores. Con
Folio tampoco: la regla de los pingüinos está socavada por un refutador,
y un refutador no refuta, así que nada la anticipa.

La anticipación es menos cauta: concluye donde la versión sin ella se
abstiene. Por eso el capítulo no la activa por omisión, y la deja como una
opción que se pide en el criterio cuando el dominio la justifica.

El capítulo continúa en la página
[Tres lecturas de una regla con excepciones](comparacion.md#668-tres-lecturas-de-una-regla-con-excepciones), que
compara la derivación rebatible con la negación como falla y con la
semántica bien fundada.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

8. **(2)** Escribir el encabezado de PlDoc, con modos y determinación, y
   el código de `excepciones(Legajo, Materia, Rs)`: los requisitos de
   Materia que el alumno Legajo cumple solo por una excepción. Justificar
   el modo de cada argumento.
9. ★ **(2)** Agregar a *Inscripciones* una autorización para Bruno, legajo
    102, para cursar Sintaxis sin Álgebra, y una versión de
    `inscripcion_rebatible/3` que reciba el criterio. Declarar que la regla
    de la autorización prevalece sobre el refutador, y mostrar la decisión
    antes y después de que Bruno se inscriba de nuevo en Álgebra, con los
    dos criterios.

## Referencias

- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming
  in Depth*, Prentice Hall, 1997 — capítulo «Defeasible Prolog».
  [Edición en PDF de los autores](https://www.covingtoninnovations.com/books/PPID.pdf).
  Esta página toma la advertencia de que la parte procedural queda en
  Prolog común, y la anticipación de los rivales («Preemption of
  Defeaters»), que el capítulo agrega como un criterio más.
