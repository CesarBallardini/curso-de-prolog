# Soluciones del capítulo 87 — Proyecto: preguntas en castellano

El código de esta página está en `ejemplos/capitulo-87/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga el programa completo,
`preguntas.pl`, sin modificarlo, y agrega el vocabulario de los
ejercicios 4 y 11 como cláusulas de los predicados `multifile` de los
módulos del capítulo, con el
[Patrón 79](../patrones.md#79-clausulas-para-un-modulo-cargado). Es
`% solo-local`, porque carga otros archivos. Los predicados del programa
que las consultas usan están en `gramatica.pl` (`analizar/2` y
`lecturas/2`), `evaluar.pl` (`evaluar/2` y `pasos/3`) y `claves.pl`
(`responder_claves/2`).

## 1

«¿Quiénes cursan análisis 2?» es una pregunta por el sujeto con
«quiénes», plural, y su forma lógica es la de «quién» con el verbo en
plural. «¿Cuántas materias cursa carla?» pregunta por el objeto: el
sujeto, carla, va después del verbo, y concuerda con «cursa». Carla está
inscripta en análisis 1, álgebra y análisis 2.

<!-- contexto: capitulo-87/soluciones.pl -->
```prolog
?- analizar("¿Quiénes cursan análisis 2?", F), evaluar(F, R).
F = cual(_A, y(alumno(_A), cursar(_A, am2))),
R = lista([101, 103]).

?- analizar("¿Cuántas materias cursa carla?", F), evaluar(F, R).
F = cuantos(_A, y(materia(_A), cursar(103, _A))),
R = numero(3).
```

## 2

La versión 1 no lee el «no»: encuentra la clase de respuesta, el verbo
*cursar* y la materia lógica, y responde con los que la cursan. La
versión 5 responde con los alumnos para los que `cursar(X, log)` no se
prueba:

```prolog
?- responder_claves("¿Quién no cursa lógica?", R).
R = lista(["ana", "bruno", "diego", "facundo"]).

?- preguntar("¿Quién no cursa lógica?").
carla, elena y gabriela
  carla: ningún hecho prueba cursar(103, log)
  elena: ningún hecho prueba cursar(105, log)
  gabriela: ningún hecho prueba cursar(107, log)
true.
```

La versión 5 aplica el supuesto de mundo cerrado de la
[sección 10.1](../capitulo-10-negacion-como-falla/index.md#101-el-supuesto-de-mundo-cerrado):
una inscripción que no está en la base no existe. Gabriela no tiene
ninguna inscripción, y para la base no cursa ninguna materia; la
respuesta es correcta mientras la tabla `inscripciones` esté completa.

## 3

Tres preguntas, cada una sin la regla que necesita:

```prolog
?- lecturas("¿Qué nota tiene ana en lógica?", Fs).
Fs = [].

?- lecturas("¿Aprobó ana lógica?", Fs).
Fs = [].

?- lecturas("¿Cuántas materias de primer año aprobó ana?", Fs).
Fs = [].
```

La primera usa el verbo *tener*, que no está en el léxico, y pide un
valor, la nota, que no es ni un alumno ni una materia: hace falta una
clase de pregunta nueva, como la del horario. La segunda pone el verbo
antes del sujeto en una pregunta de sí o no, y `oracion//1` solo tiene el
orden sujeto, verbo, objeto. La tercera modifica «materias» con «de primer
año», y `nucleo//4` solo admite «de» con una carrera, después de un nombre
de alumnos.

## 4

El verbo se agrega en cuatro lugares, uno por módulo: el léxico del
[capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md), con
la clase `o_ue` como *aprobar*; sus tipos, en la gramática; los hechos que
lo prueban, en la evaluación; y su tabla, en la traducción a SQL.

<!-- ejemplo: capitulo-87/soluciones.pl fragmento: lexico:verbo("desaprobar", o_ue). .. "nota < 6"). -->
```prolog
lexico:verbo("desaprobar", o_ue).

gramatica:verbo_tipos(desaprobar, alumno, materia).

evaluar:definicion(desaprobar(L, M), [inscripcion(L, M, N), N < 6]) :-
    inscripcion(L, M, N),
    integer(N),
    N < 6.

sql:sql_atomo(desaprobar(L, M), inscripciones, [legajo-L, materia-M],
              "nota < 6").
```

```prolog
?- preguntar("¿Quién desaprobó álgebra?").
bruno y carla
  bruno: inscripcion(102, alg, 2), 2 < 6
  carla: inscripcion(103, alg, 5), 5 < 6
true.

?- sql("¿Quién desaprobó álgebra?").
SELECT DISTINCT t1.legajo, t1.nombre
FROM alumnos t1, inscripciones t2
WHERE t2.legajo = t1.legajo
  AND t2.materia = 'alg'
  AND t2.nota < 6
ORDER BY t1.legajo
true.
```

SQLite responde lo mismo: 102 bruno y 103 carla. Una inscripción sin nota
no entra en ninguno de los dos lados, por motivos distintos: en Prolog,
`integer(N)` falla con `null`; en SQL, `NULL < 6` es desconocido, y
`WHERE` descarta la fila.

## 5

`alumno(X)` y `carrera(X, sistemas)` son dos predicados de la forma
lógica, y la traducción da una tabla por predicado. `carrera(X, C)` ya
dice que X es un alumno, porque se prueba con una fila de `alumnos`:

<!-- ejemplo: capitulo-87/soluciones.pl predicado: simplificar/2 -->
```prolog
%!  simplificar(+Forma, -Simple) is det.
%
%   Simple es Forma con cada y(alumno(X), carrera(X, C)) reemplazado por
%   carrera(X, C): la carrera ya dice que X es un alumno.
simplificar(cual(X, F), cual(X, S)) :-
    !,
    simplificar(F, S).
simplificar(cuantos(X, F), cuantos(X, S)) :-
    !,
    simplificar(F, S).
simplificar(si_no(F), si_no(S)) :-
    !,
    simplificar(F, S).
simplificar(y(alumno(X), carrera(Y, C)), carrera(X, C)) :-
    X == Y,
    !.
simplificar(y(A, B), y(SA, SB)) :-
    !,
    simplificar(A, SA),
    simplificar(B, SB).
simplificar(todo(X, R, A), todo(X, SR, SA)) :-
    !,
    simplificar(R, SR),
    simplificar(A, SA).
simplificar(alguno(X, R, A), alguno(X, SR, SA)) :-
    !,
    simplificar(R, SR),
    simplificar(A, SA).
simplificar(no(A), no(SA)) :-
    !,
    simplificar(A, SA).
simplificar(Atomo, Atomo).
```

```prolog
?- analizar("¿Qué alumnos de sistemas cursan paradigmas?", F), simplificar(F, S).
F = cual(_A, y(y(alumno(_A), carrera(_A, sistemas)), cursar(_A, pp))),
S = cual(_A, y(carrera(_A, sistemas), cursar(_A, pp))).
```

La sentencia de la forma simplificada tiene una tabla `alumnos`, y la
condición de la carrera sobre ella:

```text
SELECT DISTINCT t1.legajo, t1.nombre
FROM alumnos t1, inscripciones t2
WHERE t1.carrera = 'sistemas'
  AND t2.legajo = t1.legajo
  AND t2.materia = 'pp'
ORDER BY t1.legajo
```

Las dos formas dan `lista([101, 104])` en Prolog, y las dos sentencias
dan ana y diego en SQLite. La simplificación compara las variables con
`==/2`: `y(alumno(X), carrera(Y, C))` con X e Y distintas habla de dos
alumnos, y no se simplifica.

## 6

La pregunta se analiza, la variable de la respuesta se liga a la entidad
que el nombre designa, y si la condición no se prueba, `por_que_no/2` la
explica:

<!-- ejemplo: capitulo-87/soluciones.pl predicado: por_que_no_esta/3 -->
```prolog
%!  por_que_no_esta(+Texto, +Nombre, -Motivo) is semidet.
%
%   Motivo explica por qué la entidad que se llama Nombre no está en la
%   respuesta de Texto, una pregunta con cual/2 o cuantos/2. Falla si la
%   pregunta no se analiza, si Nombre no nombra nada o si la entidad está
%   en la respuesta.
por_que_no_esta(Texto, Nombre, Motivo) :-
    analizar(Texto, Forma),
    (   Forma = cual(X, F)
    ;   Forma = cuantos(X, F)
    ),
    !,
    palabras(Nombre, Palabras),
    once(phrase(nombre_propio(_, X), Palabras)),
    \+ probar(F, _),
    por_que_no(F, Motivo).
```

```prolog
?- por_que_no_esta("¿Quién aprobó análisis 1?", "elena", M).
M = sin_nota(inscripcion(105, am1, null)).

?- por_que_no_esta("¿Quién no aprobó lógica?", "ana", M).
M = se_prueba(prueba(aprobar(101, log), [inscripcion(101, log, 10), 10>=6])).
```

Elena está inscripta en análisis 1, pero todavía sin nota. Ana no está
entre los que no aprobaron lógica porque la aprobó, y el motivo es la
prueba de lo que la negación niega. El nombre se busca con
`nombre_propio//2`, como en las preguntas, y no con `nombre_de/2`, que
solo va de la entidad al nombre.

## 7

<!-- ejemplo: capitulo-87/soluciones.pl predicado: pasos_sin_tabla/3 -->
```prolog
%!  pasos_sin_tabla(+Materia, ?Requisito, ?N:integer) is nondet.
%
%   La definición de pasos/3 sin la tabla. No termina: la segunda cláusula
%   se llama a sí misma antes de consumir una correlativa.
pasos_sin_tabla(M, R, 1) :-
    correlativa(M, R).
pasos_sin_tabla(M, R, N) :-
    pasos_sin_tabla(M, I, N0),
    correlativa(I, R),
    N is N0 + 1.
```

```prolog
?- call_with_inference_limit(findall(Q-N, pasos_sin_tabla(bd, Q, N), _), 1000000, R).
R = inference_limit_exceeded.
```

La segunda cláusula llama a `pasos_sin_tabla(bd, I, N0)` antes de leer
ninguna correlativa. Después de las respuestas de la primera cláusula, la
llamada vuelve a la segunda cláusula con los mismos argumentos, y así sin
fin: es la recursión a la izquierda de la
[sección 21.7](../capitulo-21-gramaticas-dcg/index.md#217-recursion-a-izquierda).
Con la tabla, la llamada repetida espera las respuestas de la primera, y
con un ciclo en el plan de estudios también termina:

```prolog
?- snapshot((assertz(base:correlativa(log, bd)), abolish_all_tables, setof(Q-N, pasos(bd, Q, N), Ps))), abolish_all_tables.
Ps = [alg-2, bd-3, log-2, pp-1, ssl-1].
```

Con el ciclo, bases de datos es requisito de sí misma, a tres pasos:
bd, pp, log, bd. La subsunción `min` guarda un solo valor por par, el
menor, y la tabla deja de crecer. Las tablas no siguen los cambios de la
base: hay que vaciarlas con `abolish_all_tables/0` después del
`assertz/1`, o `pasos/3` responde con las respuestas viejas; y otra vez
después de `snapshot/1`, que deshace el cambio de la base pero no el de
las tablas.

## 8

<!-- ejemplo: capitulo-87/soluciones.pl predicado: responder_lecturas/2 -->
```prolog
%!  responder_lecturas(+Texto, -Respuestas:list) is det.
%
%   Respuestas tiene un par Forma-Respuesta por cada lectura de Texto.
responder_lecturas(Texto, Respuestas) :-
    lecturas(Texto, Formas),
    findall(F-R, ( member(F, Formas), evaluar(F, R) ), Respuestas).
```

```prolog
?- responder_lecturas("¿Qué necesita lógica?", Ps).
Ps = [cual(_A, y(materia(_A), necesitar(log, _A)))-lista([]), cual(_B, y(materia(_B), necesitar(_B, log)))-lista([bd, pp, ssl])].
```

Con «lógica», la lectura que la gramática prueba primero, la de lógica
como sujeto, da una lista vacía, porque lógica no tiene correlativas; la
otra lectura da las materias que necesitan lógica. Una interfaz puede
responder con las lecturas que no son vacías, o preguntar cuál se quiso
decir.

## 9

<!-- ejemplo: capitulo-87/soluciones.pl predicado: conversar_por_que/2 conversar_por_que/3 -->
```prolog
%!  conversar_por_que(+Entrada, +Salida) is det.
%
%   Como conversar/2, pero escribe solo la respuesta; si la línea
%   siguiente es «¿por qué?», escribe la explicación de la última
%   pregunta.
conversar_por_que(Entrada, Salida) :-
    conversar_por_que(Entrada, Salida, ninguna).

%!  conversar_por_que(+Entrada, +Salida, +Ultima) is det.
%
%   Ultima es la explicación de la última pregunta, o ninguna.
conversar_por_que(Entrada, Salida, Ultima) :-
    format(Salida, "> ", []),
    read_line_to_string(Entrada, Linea),
    (   ( Linea == end_of_file ; Linea == "" )
    ->  true
    ;   Linea == "¿por qué?"
    ->  (   Ultima == ninguna
        ->  format(Salida, "No hay una pregunta anterior.~n", [])
        ;   with_output_to(Salida,
                           preguntas:escribir_explicacion(Ultima))
        ),
        conversar_por_que(Entrada, Salida, Ultima)
    ;   responder(Linea, Respuesta, Explicacion),
        with_output_to(Salida, preguntas:escribir_respuesta(Respuesta)),
        conversar_por_que(Entrada, Salida, Explicacion)
    ).
```

```text
?- conversar_por_que(user_input, user_output).
> ¿Ana aprobó lógica?
Sí
> ¿por qué?
  inscripcion(101, log, 10), 10 >= 6
>
true.
```

El estado del bucle, la explicación de la última pregunta, es un
argumento de la recursión: no hace falta guardarlo en la base. Antes de
la primera pregunta vale `ninguna`.

## 10

<!-- ejemplo: capitulo-87/soluciones.pl predicado: sql_presuposicion/2 -->
```prolog
%!  sql_presuposicion(+Forma, -SQL:string) is semidet.
%
%   SQL es como la sentencia de sql/2, salvo para una pregunta de sí o no
%   con «todos»: da NULL si la restricción no tiene casos, y si los tiene,
%   1 o 0.
sql_presuposicion(si_no(todo(X, R, A)), SQL) :-
    !,
    sql(si_no(R), Hay),
    sql(si_no(todo(X, R, A)), Todos),
    format(string(SQL),
           "SELECT CASE WHEN (~s) = 0 THEN NULL ELSE (~s) END",
           [Hay, Todos]).
sql_presuposicion(Forma, SQL) :-
    sql(Forma, SQL).
```

La sentencia de la pregunta 14 queda:

```text
SELECT CASE WHEN (SELECT EXISTS (SELECT 1 FROM alumnos t1, inscripciones t2 WHERE t2.legajo = t1.legajo AND t2.materia = 'bd')) = 0 THEN NULL ELSE (SELECT EXISTS (SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM alumnos t1, inscripciones t2 WHERE t2.legajo = t1.legajo AND t2.materia = 'bd' AND NOT EXISTS (SELECT 1 FROM inscripciones t3 WHERE t3.legajo = t1.legajo AND t3.materia = 'log' AND t3.nota >= 6)))) END
```

En SQLite 3.50, sobre la base del capítulo, las preguntas 10, 14 y 16
dan 1, `NULL` y 0: sí, la presuposición no se cumple, y no. Las dos
subconsultas usan los mismos alias, `t1` y `t2`, sin conflicto, porque
cada una es una consulta aparte.

## 11

<!-- ejemplo: capitulo-87/soluciones.pl fragmento: gramatica:sn(plural, Tipo, (X^P)^y(P1, P2)) .. X1 = E. -->
```prolog
gramatica:sn(plural, Tipo, (X^P)^y(P1, P2)) -->
    nombre_propio(Tipo, E1),
    gramatica:palabra("y"),
    nombre_propio(Tipo, E2),
    { Tipo \== carrera,
      nonvar(P),
      aplicar(X^P, E1, P1),
      aplicar(X^P, E2, P2) }.

%!  aplicar_mal(+Propiedad, +E, -F) is det.
%
%   La aplicación con copy_term/2 sobre la propiedad entera: renombra
%   también las variables de la pregunta. Es el error del ejercicio.
aplicar_mal(X^P, E, F) :-
    copy_term(X^P, E^F).

%!  aplicar(+Propiedad, +E, -F) is det.
%
%   F es la Propiedad X^P aplicada a E: una copia de P con E en lugar de
%   X. Solo X se renombra; las demás variables de P siguen compartidas,
%   porque son las de la pregunta.
aplicar(X^P, E, F) :-
    term_variables(P, Vs0),
    exclude(==(X), Vs0, Libres),
    copy_term(t(Libres, X, P), t(Libres1, X1, F)),
    Libres1 = Libres,
    X1 = E.
```

```prolog
?- preguntar("¿Quién cursa lógica y álgebra?").
ana, bruno y diego
  ana: inscripcion(101, log, 10), inscripcion(101, alg, 9)
  bruno: inscripcion(102, log, 6), inscripcion(102, alg, 2)
  diego: inscripcion(104, log, 9), inscripcion(104, alg, 7)
true.

?- preguntar("¿Qué materias cursan ana y diego?").
álgebra, lógica y paradigmas
  álgebra: inscripcion(101, alg, 9), inscripcion(104, alg, 7)
  lógica: inscripcion(101, log, 10), inscripcion(104, log, 9)
  paradigmas: inscripcion(101, pp, null), inscripcion(104, pp, 8)
true.
```

La propiedad que recibe el sintagma coordinado se aplica dos veces, una a
cada nombre. La unificación aplica una función una sola vez, porque liga
la variable; hace falta una copia por nombre. `copy_term/2` sobre la
propiedad entera copia también las variables que no son la del
sintagma: en «¿qué materias cursan ana y diego?» la propiedad es
`Y^cursar(Y, M)`, y M es la variable de la pregunta.

```prolog
?- aplicar_mal(Y^cursar(Y, M), 101, F).
F = cursar(101, _).

?- aplicar(Y^cursar(Y, M), 101, F).
F = cursar(101, M).
```

Con la copia completa, cada mitad habla de una materia propia, y la
pregunta responde con todas las materias, porque ana y diego cursan
alguna. `aplicar/3` copia solo Y: las demás variables de la propiedad se
copian y se vuelven a unir con las originales.

La regla vale después del verbo, en el objeto o en el sujeto pospuesto,
porque `sv//3` y `resto_interrogativo//3` construyen el átomo del verbo
antes de analizar ese sintagma. Antes del verbo, en «¿Ana y diego cursan
lógica?», la propiedad todavía es una variable cuando se analiza el
sujeto, y la regla no se aplica (`nonvar(P)`): la pregunta no se analiza,
en lugar de responderse mal. Aplicar la propiedad después, cuando el
verbo la construye, pide un término que la represente, como los árboles
de cuantificadores del apartado 4.1.6 de Pereira y Shieber.
