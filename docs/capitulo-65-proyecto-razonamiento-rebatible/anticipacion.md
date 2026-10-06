# La anticipación de los rivales

Esta página contiene la sección [65.7](index.md#657-version-6-la-anticipacion-de-los-rivales) del
[capítulo 65](index.md): la sexta versión del intérprete, que agrega a
`rival/4` la anticipación de d-Prolog. Los ejemplos están en `rebatible.pl` y
`anticipacion.pl`, en `ejemplos/capitulo-65/`, con sus pruebas, y se ejecutan
en una instalación local.

## La anticipación de los rivales

En las versiones anteriores, una regla derrota a otra aunque ella misma
esté derrotada. Con Folio, en la
[sección 65.4](index.md#654-version-3-refutadores-y-presunciones), eso es lo
deseable: la regla de los pingüinos, socavada, sigue impidiendo que se
concluya que vuela. Covington observa que en otros casos el requisito es
demasiado fuerte, y lo muestra con dos cadenas de reglas de la misma forma.
Aquí son dos cadenas sobre el pago de la matrícula:

<!-- ejemplo: capitulo-65/anticipacion.pl fragmento: % intercambio(X): X es un alumno de intercambio. .. neg paga(X) :~ becario(X). -->
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

<!-- ejemplo: capitulo-65/rebatible.pl predicado: anticipado/3 -->
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

<!-- ejemplo: capitulo-65/anticipacion.pl predicado: medir/3 -->
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
