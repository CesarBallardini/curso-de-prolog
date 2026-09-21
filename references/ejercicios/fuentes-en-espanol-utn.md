# Fuentes en español: UTN FRBA, Paradigmas de Programación

Parte del banco [fuentes-en-espanol.md](fuentes-en-espanol.md). Licencias en la tabla de
fuentes de ese archivo.

Vocabulario de la cátedra que aparece en los enunciados: "inversible" (el predicado
funciona con argumentos sin ligar y genera respuestas), "universo cerrado" (lo que no
está en la base es falso), "functor" (término compuesto), "polimorfismo" (varias
cláusulas que tratan distintos functores de forma uniforme). La cátedra usa `not/1`,
`forall/2` y `findall/3` en casi todos los ejercicios integradores.

## Guías 2008 (PDF)

Base de las URL: `https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/`.
Varios ejercicios reaparecen, a veces con datos cambiados, en las guías Mumuki de la
cátedra; eso se indica en **Notas**.

### ES-UTN-1 — Candidatos para sectores de una empresa (puedeAndar)
- **Fuente:** PdeP UTN FRBA, "Paradigma Lógico – Guías 2008", Práctica 1 (descripciones, unificación), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 1, 2, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un programa con `puedeAndar/2`, `profesional/1`, `ambicioso/1` y hechos sobre Roque, Ana, Lucía y Cecilia, indicar qué predicados están definidos por extensión o por comprensión, predecir si Prolog responde sí o no a seis consultas, y mostrar que `puedeAndar/2` es totalmente inversible. Después agregar los sectores "proyectos" y "logística" y postulantes que cumplan condiciones dadas.
  ```prolog
  puedeAndar(comercioExterior,P):- habla(ingles,P), habla(frances,P), profesional(P).
  habla(roque,frances).
  ```
- **Notas:** El programa trae a propósito `habla(ingles,P)` con los argumentos al revés que los hechos `habla(roque,frances)`: la consulta falla siempre. Sirve para enseñar a leer la aridad y el orden de los argumentos. Versión Mumuki: `mumuki-guia-logico-practica-primeros-pasos` (00001, 00010, 00020).

### ES-UTN-2 — Nómina de una empresa y quién da órdenes
- **Fuente:** Guías 2008, Práctica 1, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar los departamentos de ventas, compras y administración con sus empleados y cadetes, y definir consultas para saber quién trabaja en un departamento, si dos personas trabajan en el mismo departamento y si A puede darle órdenes a B (mismo departamento y cargo superior).
- **Notas:** Versión Mumuki con `empleado/3`: `mumuki-guia-logico-practica-primeros-pasos/00002_trabajaEn` y `mumuki-guia-logico-practica-negacion-cuantificacion/00040_daOrdenes`.

### ES-UTN-3 — Rivales en un mundial
- **Fuente:** Guías 2008, Práctica 1, ejercicio 3. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** verificada:
  ```prolog
  rival(X,Y) :- grupo(G,X), grupo(G,Y), X \= Y.
  % ?- rival(argentina,R).  R = nigeria ; R = japon ; R = escocia.
  ```
- **SWISH:** sí
- **Enunciado:** Con los grupos A (Colombia, Camerún, Jamaica, Italia) y B (Argentina, Nigeria, Japón, Escocia), definir los rivales de una selección: los demás equipos de su grupo, nunca ella misma.
- **Notas:** Buen primer uso de `\=`: si se pone antes de los generadores, el predicado deja de ser inversible. Versión Mumuki: `mumuki-guia-logico-practica-negacion-cuantificacion/00003_rival`.

### ES-UTN-4 — Agencia matrimonial: parejas compatibles y personas deseables
- **Fuente:** Guías 2008, Práctica 1, ejercicio 4. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 1, 2, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Las mujeres melancólicas son compatibles con los varones serenos, las decididas con los reflexivos y las soñadoras con los decididos; con los datos de Juan, María, Úrsula, Juana, Pedro y José, decidir qué parejas (mujer, varón) son compatibles. Luego agregar que cualquier pareja decidido–melancólico es compatible, y definir "deseable" (compatible con al menos dos personas distintas).
- **Notas:** "Al menos dos distintas" se resuelve con dos generadores y `\=`, sin listas. Versión Mumuki: `mumuki-guia-logico-practica-primeros-pasos/00004_esCompatible`.

### ES-UTN-5 — Unificación cláusula por cláusula (gustaDe)
- **Fuente:** Guías 2008, Práctica 1, ejercicio 5. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 3, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un programa numerado de 11 cláusulas (`gustaDe/2`, `compiten/2`, `debeDinero/2`), indicar para cada consulta (`gustaDe(juan,A)`, `gustaDe(A,zulema)`, `gustaDe(A,B)`, etc.) con qué cláusulas unifica y qué variables se ligan. Describir en castellano qué relaciona `compiten/2`.
  ```prolog
  gustaDe(X,zulema):- gustaDe(X,ana).
  gustaDe(X,Y):- gustaDe(X,ana).
  compiten(X,Y):- gustaDe(X,Z), gustaDe(Y,Z).
  ```
- **Notas:** Ejercicio de papel y lápiz sobre unificación de cabezas. Ojo: la cláusula 7 genera respuestas con `Y` sin ligar; `compiten(X,X)` es verdadero, porque no hay `X \= Y`. Versión Mumuki (reescrita como enunciado en castellano): `mumuki-guia-logico-practica-primeros-pasos/00005_gustaDe`.

### ES-UTN-6 — ¿Quién puede ir a la fiesta de la cátedra?
- **Fuente:** Guías 2008, Práctica 1, ejercicio 6. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 2, 5
- **Dificultad:** 2
- **Solución:** verificada:
  ```prolog
  puedeIr(nico). puedeIr(daniel).
  puedeIr(A) :- alumnoDe(A,P), puedeIr(P).
  puedeIr(C) :- carilindo(C).
  % setof: [alvaro,ana,brad,daniel,diana,johnny,juan,leo,luisa,nahuel,nico,tamara]
  ```
- **SWISH:** sí
- **Enunciado:** Con los datos de quién es alumno de quién y de quiénes son carilindos o simpáticos, pueden ir a la fiesta Nico, Daniel, los alumnos de alguien que puede ir y los carilindos. Armar el programa para preguntar quiénes pueden ir.
- **Notas:** Primera regla recursiva de la guía, sin listas. Álvaro aparece dos veces (alumno de José y de Luisa, pero solo por Luisa llega a Daniel). La versión Mumuki (`mumuki-guia-logico-practica-negacion-cuantificacion/00006_fiestaDeCatedra`) cambia la regla a "alumnos de Daniel que no tengan alumnos", o sea usa negación en vez de recursión.

### ES-UTN-7 — Colores que atraen a cada persona y reuniones iluminadas
- **Fuente:** Guías 2008, Práctica 1, ejercicio 7. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-1.pdf
- **Tema:** 1, 2
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** A partir de reglas en lenguaje natural ("a todas las mujeres y a Pablo les atrae el azul", "el rosa, el celeste y el lila son pastel"…), definir qué colores atraen a cada persona. Luego, una reunión puede iluminarse con un color si entre sus asistentes hay una pareja de distinto sexo a quienes les atrae ese color.
- **Notas:** El enunciado no dice explícitamente quiénes son mujeres o varones; la versión Mumuki (`mumuki-guia-logico-practica-primeros-pasos/00007_colores` y `…negacion-cuantificacion/00070_Reunión Colorida`) lo agrega.

### ES-UTN-8 — Precio de venta de bebidas
- **Fuente:** Guías 2008, Práctica 2 (aritmética, negación), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-2.pdf
- **Tema:** 2, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Una casa de bebidas vende a comerciantes y a particulares con recargos distintos según el tipo de bebida (agua, gaseosa, vino nacional o importado, whisky); por ejemplo, a los vinos importados para comerciantes se les recarga el máximo entre 20 % y 3 pesos. Con los productos y clientes dados, calcular el precio de venta.
- **Notas:** Usa `is/2` y `max/2`. Versión Mumuki simplificada: `mumuki-guia-logico-practica-aritmetica-y-negacion/00001_calcularPrecio` y `00010_esAlcoholica`.

### ES-UTN-9 — Competencia de habilidades: puntajes por prueba y total
- **Fuente:** Guías 2008, Práctica 2, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-2.pdf
- **Tema:** 2, 7, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Hay tres pruebas (lanzamiento de precisión, martillo, escoba) con reglas de puntaje por tramos; el puntaje total es 0 si ninguno de los tres llega a 5 y, si no, la suma. Representar los resultados de cada competidor y calcular su puntaje total.
- **Notas:** Los tramos del PDF se solapan en los bordes ("entre 9 y 11", "entre 7 y 9"); hay que decidir qué pasa en 9. La versión Mumuki corrige los tramos y cambia la condición a "si alguno no llega a 5" (`mumuki-guia-logico-practica-aritmetica-y-negacion/00002`, `00050`, `00060`, `00070`).

### ES-UTN-10 — ¿Quién mató a la tía Agatha?
- **Fuente:** Guías 2008, Práctica 2, ejercicio 3. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-2.pdf
- **Tema:** 2, 8
- **Dificultad:** 2
- **Solución:** verificada (una sola respuesta, `A = agatha`):
  ```prolog
  viveEnMansion(agatha). viveEnMansion(carnicero). viveEnMansion(charles).
  odia(agatha, P)    :- viveEnMansion(P), P \= carnicero.
  odia(charles, P)   :- viveEnMansion(P), \+ odia(agatha, P).
  odia(carnicero, P) :- odia(agatha, P).
  masRicoQue(P, agatha) :- viveEnMansion(P), \+ odia(carnicero, P).
  asesino(V, A) :- viveEnMansion(A), odia(A, V), \+ masRicoQue(A, V).
  ```
- **SWISH:** sí
- **Enunciado:** Traducir a Prolog el acertijo de la mansión Dreadbury (un asesino odia a su víctima y no es más rico que ella; Agatha odia a todos menos al carnicero; etc.) y preguntar quién mató a Agatha, obteniendo una sola respuesta.
- **Notas:** Clásico de negación por falla: `\+` debe aplicarse con las variables ya ligadas. Versión Mumuki: `mumuki-guia-logico-practica-aritmetica-y-negacion/00003_asesinato`.

### ES-UTN-11 — Competencia de saltos (nth1, sumlist)
- **Fuente:** Guías 2008, Práctica 3 (listas y functores), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-3-1.2.pdf
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `puntajes/2` (competidor y lista de puntajes de sus saltos), consultar el puntaje de un salto dado, si un competidor está descalificado (más de 5 saltos) y si clasifica a la final (suma de al menos 28 o dos saltos de 8 o más).
  ```prolog
  puntajes(hernan,[3,5,8,6,9]).
  puntajes(julio,[9,7,3,9,10,2]).
  ```
- **Notas:** Pide investigar `nth1/3` y `nth0/3`. "Dos saltos de 8 o más" se puede resolver con dos `nth1` de posiciones distintas. Versión Mumuki: `mumuki-guia-logico-practica-listas` (00001, 00005, 00006).

### ES-UTN-12 — Ingresos mensuales y familiares
- **Fuente:** Guías 2008, Práctica 3, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-3-1.2.pdf
- **Tema:** 2, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `ingreso(Persona, Mes, Monto)` y `padre(Hijo, Padre)`, definir `buenPasar/1` (varias condiciones alternativas), `mesFilial/2` (en ese mes algún hijo ganó más que la persona), `ingresoTotal/2` e `ingresoFamiliar/2` (total propio más el de los hijos).
- **Notas:** `ingresoTotal/2` requiere `findall/3` + `sum_list/2`; el enunciado pide verificar que `mesFilial/2` es totalmente inversible. Versión Mumuki: `mumuki-guia-logico-practica-listas` (00002, 00007, 00008, 00009).

### ES-UTN-13 — Red de subtes: líneas, distancias y combinaciones
- **Fuente:** Guías 2008, Práctica 3, ejercicio 3. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-3-1.2.pdf
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `linea(Nombre, ListaDeEstaciones)` y `combinacion(ListaDeEstaciones)`, definir `estaEn/2`, `distancia/3` entre estaciones de la misma línea, `mismaAltura/2` (misma posición en líneas distintas) y `viajeFacil/2` (misma línea o una sola combinación).
  ```prolog
  linea(a,[plazaMayo,peru,lima,congreso,miserere,rioJaneiro,primeraJunta,nazca]).
  combinacion([lima,avMayo]).
  ```
- **Notas:** Se apoya en `member/2` y `nth1/3`; la distancia es la diferencia absoluta de posiciones (`abs/1`). La guía 4 (ejercicio 8) trae otra variante con `combinacion/2`, cabeceras y línea "universal". Versión Mumuki: `mumuki-guia-logico-practica-listas/00003_subtes`.

### ES-UTN-14 — Vuelos con escalas y tramos
- **Fuente:** Guías 2008, Práctica 3, ejercicio 4. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-3-1.2.pdf
- **Tema:** 3, 6, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Cada vuelo es `vuelo(Codigo, Capacidad, Destinos)`, donde los destinos alternan functores `escala(Ciudad, Espera)` y `tramo(Horas)`. Definir el tiempo total, las escalas aburridas (más de 3 h de espera), si es vuelo largo (10 h o más en el aire), vuelos conectados, `bandaDeTres/3`, distancia en escalas y vuelo lento.
- **Notas:** En el PDF los códigos van en mayúscula (`ARG845`), así que Prolog los lee como variables. La versión Mumuki (`mumuki-guia-logico-practica-listas/00004_viajes`) los pasa a minúscula. Buen ejemplo de ese error.

### ES-UTN-15 — Servidores y eventos (functores como eventos)
- **Fuente:** Guías 2008, Práctica 4 (functores, generación), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 3, 2
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Hay servidores con fila y criticidad y eventos modelados como functores (corte de luz en una fila, rebooteo de un server, cuelgue de aplicación). Definir `requiereAtencionNormal/2` y `requiereAtencionInmediata/2` de modo que, dado un evento, se pueda consultar qué servidores requieren atención.
- **Notas:** Igual que en ES-UTN-14, el PDF usa nombres de servidor en mayúscula (`PS1`), que Prolog lee como variables. La versión Mumuki (`mumuki-guia-logico-practica-functores/00100_servidores` y `00501_Mes complicado`) corrige eso y agrega "mes complicado" con `forall/2`.

### ES-UTN-16 — Parejas estables (matrimonio estable)
- **Fuente:** Guías 2008, Práctica 4, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 6, 8, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con tres mujeres, tres varones y el orden de preferencia de cada uno, definir `parejas/3` (arma los conjuntos posibles de parejas), `insatisfecho/2` (la persona quiere dejar a su pareja en ese conjunto) y `estable/1` (ninguna persona insatisfecha), garantizando inversibilidad.
- **Notas:** Generar y testear con `permutation/2` y `\+`/`forall/2`. La versión Mumuki `00502_Se ha formado una pareja` es otra variante, con `preferencia/3`.

### ES-UTN-17 — Búsqueda del tesoro: destinos, idiomas y niveles
- **Fuente:** Guías 2008, Práctica 4, ejercicio 3. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 3, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `tarea(Nivel, buscar(Cosa, Ciudad))`, `nivelActual/2`, `idioma/2`, `habla/2` y `capital/2`, definir destino posible, idioma útil, excelente compañero (habla todos los idiomas de los destinos del otro), nivel interesante, participante complicado, nivel homogéneo y políglota.
- **Notas:** Ejercicio central de `forall/2` e inversibilidad ("asegurar que el predicado sea inversible"). Versión Mumuki: `mumuki-guia-logico-practica-functores/00300_busquedaDelTesoro`; variante `…negacion-cuantificacion/00075_Gran compañero de viaje`.

### ES-UTN-18 — Tareas de un proyecto: anterior, riesgo, puedoHacer
- **Fuente:** Guías 2008, Práctica 4, ejercicio 4. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 5, 9, 3
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `tarea(Nombre, Horas, Rol)`, `precede/2` y `realizada/1`, definir `anterior/2` (precedencia directa o indirecta), `simple/1`, `riesgo/1`, `meFaltanPara/2` (lista de tareas previas no realizadas), `puedoHacer/1` usando `forall`, y `muchoTesting/1` cuando las tareas pasan a tener una lista de `trabajo(Horas, Rol)`.
  ```prolog
  precede(cacheDistribuida, pruebasPerformance).
  precede(pruebasPerformance, tuning).
  ```
- **Notas:** `anterior/2` es el clásico cierre transitivo (como `ancestro`). Versión Mumuki: `mumuki-guia-logico-practica-aritmetica-y-negacion/00075_tareas`, `00076_tareaRiesgosa`, y `…practica-listas/00010_Tareas múltiples`.

### ES-UTN-19 — Dominó: quién cede el turno
- **Fuente:** Guías 2008, Práctica 4, ejercicio 5. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 3, 6, 8
- **Dificultad:** 2
- **Solución:** verificada (da `juan` y `miguel`):
  ```prolog
  jugador(J) :- tieneFicha(J,_).
  extremo(I) :- estado([ficha(I,_)|_]).
  extremo(D) :- estado(L), last(L, ficha(_,D)).
  puedeJugar(J) :- tieneFicha(J,ficha(A,B)), (extremo(A) ; extremo(B)).
  cedeTurno(J) :- jugador(J), \+ puedeJugar(J).
  ```
- **SWISH:** sí
- **Enunciado:** Con `tieneFicha(Jugador, ficha(A,B))` y `estado(ListaDeFichas)` (la cadena en la mesa), definir `cedeTurno/1`, inversible, para los jugadores que no pueden agregar ninguna ficha en ninguno de los dos extremos.
- **Notas:** El generador `jugador/1` hace falta antes de `\+` para que el predicado sea inversible. Versión Mumuki: `mumuki-guia-logico-practica-functores/00500_domino`.

### ES-UTN-20 — Liga de fútbol: rivales, goles, puntos y tabla
- **Fuente:** Guías 2008, Práctica 4, ejercicio 6. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 3, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con hechos `fecha(Nro, partido(Local, GL, Visitante, GV))`, definir entre otros `rival/3`, goles por fecha, `jugaron/2`, `faltaQueJueguen/2`, `gano/2`, `perdio/2`, `empataron/2`, puntos, equipo imprevisible, invicto, `masCapoQue/2`, campeón y la tabla de posiciones ordenada.
- **Notas:** Catorce ítems graduados: sirve como práctica larga. Sugiere `setof/3` para la tabla. En SWI se ordena con `sort/4` o con `setof` sobre pares `Puntos-Equipo`.

### ES-UTN-21 — TEG: continentes, jugadores y objetivos
- **Fuente:** Guías 2008, Práctica 4, ejercicio 7. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-4-1-5.pdf
- **Tema:** 6, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `paisContinente/2`, `limitrofes([P1,P2])`, `ocupa(Pais, Color, Ejercitos)` y `objetivo(Color, Objetivo)`, definir diez predicados inversibles: está en continente, cantidad de países, ocupa continente, le falta mucho, limítrofes, es groso, está en el horno, continente caótico, capo cannoniere y ganador.
- **Notas:** El PDF mezcla `españa` y `espana`: en SWI-Prolog `españa` es un átomo válido, pero no unifica con `espana`. Variantes Mumuki: `mumuki-guia-logico-practica-negacion-cuantificacion/00072_TEG`, `00073_TEG 2`, `00074_TEG, La Revancha`.

### ES-UTN-22 — Grafo dirigido: ¿hay camino?
- **Fuente:** Guías 2008, Práctica 5 (recursividad), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-5.pdf
- **Tema:** 5, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Describir un grafo dirigido (la figura no sale en el texto extraído) y definir un predicado que diga si hay camino de un nodo a otro, sin tener en cuenta ciclos. Verificar que es inversible en todos sus argumentos.
- **Notas:** Hay que inventar las aristas. Con un ciclo en los datos, la versión simple no termina: buen disparador para hablar de profundidad y listas de visitados.

### ES-UTN-23 — Fibonacci
- **Fuente:** Guías 2008, Práctica 5, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-5.pdf
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** verificada (`fib(10,F)` da `F = 55`):
  ```prolog
  fib(1,1). fib(2,1).
  fib(N,F) :- N > 2, N1 is N-1, N2 is N-2, fib(N1,F1), fib(N2,F2), F is F1+F2.
  ```
- **SWISH:** sí
- **Enunciado:** Escribir un programa que calcule el n-ésimo número de Fibonacci con fib(1) = fib(2) = 1.
- **Notas:** Sin la guarda `N > 2`, al pedir otra solución con `;` la recursión baja a números negativos y no termina. No es inversible en `N`.

### ES-UTN-24 — Central telefónica: internos y derivaciones
- **Fuente:** Guías 2008, Práctica 5, ejercicio 3. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-5.pdf
- **Tema:** 2, 6, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con empleados, jefes, áreas, gerentes, asistentes e internos, definir `internoDe/2` (si no tiene interno, el de su jefe), `quienAtiende/2`, `dependeDe/2`, `puedeTransferir/2` y dos predicados sobre listas: filtrar los números que son internos y mapear personas a internos.
- **Notas:** Falta un punto al final de `area(marcelo, administracion)` en el PDF. "Si no tiene interno" requiere `\+`.

### ES-UTN-25 — Recursión con listas: suma, encolar, máximo, elementoEn
- **Fuente:** Guías 2008, Práctica 5, ejercicio 4. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-5.pdf
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** verificada:
  ```prolog
  suma([],0).
  suma([X|Xs],S) :- suma(Xs,S0), S is S0+X.
  encolar([],E,[E]).
  encolar([X|Xs],E,[X|Ys]) :- encolar(Xs,E,Ys).
  maximo([X],X).
  maximo([X|Xs],M) :- Xs \= [], maximo(Xs,M0), M is max(X,M0).
  elementoEn([X|_],1,X).
  elementoEn([_|Xs],P,E) :- elementoEn(Xs,P0,E), P is P0+1.
  ```
- **SWISH:** sí
- **Enunciado:** Definir `suma/2`, `encolar/3` (agregar al final), `maximo/2` (la lista vacía no tiene máximo) y `elementoEn/3` (posición desde 1; falla si la lista es más corta).
- **Notas:** El enunciado dice `encolar(E,L,LconE)`, pero los ejemplos usan el orden `encolar([1,3,5],7,[1,3,5,7])`; la solución sigue los ejemplos. `elementoEn` así escrito también sirve para buscar la posición de un elemento.

### ES-UTN-26 — Registro civil: edades, años felices y seguidillas
- **Fuente:** Guías 2008, Práctica 6 (integración), ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-6.pdf
- **Tema:** 7, 8, 9, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `nacio/2`, `seCasaron/3`, `murio/3` y `anioActual/1`, definir `edad/2`, `especial/1` (se casó antes de los 18 o después de los 50, tres o más veces, o tiene más de 100 años), `anioConRegistro/1`, `anioFeliz/1` (hubo eventos, pero no muertes) y `haySeguidilla(Inicio, Duracion)` de años consecutivos con eventos.
- **Notas:** Las respuestas esperadas dependen de `anioActual(2006)`. `haySeguidilla/2` es recursivo sobre números.

### ES-UTN-27 — Construya su cañería
- **Fuente:** Guías 2008, Práctica 6, ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-6.pdf
- **Tema:** 3, 5, 6, 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Hay piezas (codos, caños y canillas) modeladas como functores con color y otros datos. Definir el precio de una cañería (lista de piezas), `puedoEnchufar/2` según colores (azul antes que rojo, rojo antes que negro), extenderlo a cañerías ya armadas y a extremos, y `canieriaBienArmada/1`. Los ítems finales (cañerías anidadas, generar todas las legales) son desafíos.
- **Notas:** Polimorfismo sobre functores y recursión sobre listas en el mismo ejercicio.

### ES-UTN-28 — Mensajes de texto con el teclado del teléfono
- **Fuente:** PdeP, "Paradigma Lógico – Práctica extra", ejercicio 1. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-x.pdf
- **Tema:** 6, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no del todo (depende de la representación de strings)
- **Enunciado:** Con `tel(Tecla, Letras)`, definir `nrosPara/2` inversible, que relacione una frase con la lista de teclas que la escriben, y `nroGratis/2` (formato 0800). Después rehacerlo con un hecho por letra y `atom_chars/2`.
- **Notas:** Asume que `"hola"` es una lista de códigos. En SWI-Prolog 7 y posteriores las comillas dobles crean un objeto string, así que la parte (a) no funciona tal cual: hay que usar `string_codes/2` o `set_prolog_flag(double_quotes, codes)`. `string_to_list/2` todavía existe en 9.2.9, pero es obsoleto (conviene `string_codes/2`). La parte (c), con `atom_chars/2`, sí funciona.

### ES-UTN-29 — Cuadrados aritméticos 3×3
- **Fuente:** PdeP, "Paradigma Lógico – Práctica extra", ejercicio 2. https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios/guia-logico-2008-x.pdf
- **Tema:** 4, 5, 6, 7
- **Dificultad:** 3
- **Solución:** verificada (hay 16 cuadrados):
  ```prolog
  operacion(A,B,C) :- between(1,10,A), between(1,10,B),
      (C is A+B ; C is A-B), between(1,10,C).
  fila([A,B,C]) :- operacion(A,B,C).
  primerColumna([],[],[]).
  primerColumna([[X|Xs]|Fs],[X|Col],[Xs|R]) :- primerColumna(Fs,Col,R).
  transpuesta([[]|_],[]) :- !.
  transpuesta(M,[C|Cs]) :- primerColumna(M,C,R), transpuesta(R,Cs).
  cuadrado([F1,F2,F3]) :- fila(F1), fila(F2), fila(F3),
      transpuesta([F1,F2,F3],T), maplist(fila,T),
      append([F1,F2,F3],L), sort(L,S), length(S,9).
  % ?- aggregate_all(count, cuadrado(_), N).  N = 16.
  ```
- **SWISH:** sí
- **Enunciado:** Una matriz 3×3 con números del 1 al 10 es un "cuadrado aritmético" si en cada fila y cada columna el tercero es la suma o la resta de los dos primeros, y no se repiten números. Construir top-down `cumpleOperaciones/1`, `transpuesta/2` (vía `primerColumna/3`), `cumpleUnicidad/1` y `cuadrado_aritmetico/1` generador, y contar cuántos hay.
- **Notas:** Ejemplo muy bueno de "generar y testear". El orden de los objetivos cambia mucho el tiempo de búsqueda.

## Guías Mumuki de la cátedra (CC BY-SA 4.0)

Cada guía es un repositorio de la organización `pdep-utn` en GitHub. Cada ejercicio es
una carpeta `NNNNN_Nombre` con `description.md` y `test.pl` (pruebas PlUnit que corren
en la plataforma Mumuki). Los repositorios no traen `solution.pl`, así que no hay
solución publicada; los tests muestran el comportamiento esperado. Aquí solo se listan
los ejercicios que no duplican las guías 2008 y que tratan de Prolog (se omiten los de
repaso de Haskell).

### ES-UTN-30 — Primeros hechos: personajes, países, pokémon
- **Fuente:** PdeP UTN, guía Mumuki "Hechos y reglas", ejercicios 00001, 00002 y 00008. https://github.com/pdep-utn/mumuki-guia-logico-hechos-y-reglas
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** no (tests en `test.pl`)
- **SWISH:** sí
- **Enunciado:** Agregar hechos a una base: Frodo y Harry Potter son personajes de ficción; Argentina y Uruguay son países, Santa Cruz es una provincia, Canelones un departamento; Pikachu y Raichu son de tipo eléctrico, Bulbasaur de tipo hierba, Charmander y Charizard de tipo fuego.
- **Notas:** Sirven para practicar que los átomos van en minúscula y sin espacios (`lukeSkywalker`).

### ES-UTN-31 — Universo cerrado: lo que no se dice es falso
- **Fuente:** Guía Mumuki "Hechos y reglas", ejercicio 00004_Universo cerrado. https://github.com/pdep-utn/mumuki-guia-logico-hechos-y-reglas
- **Tema:** 1, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir la base "Ramiro come carne, Ana come verduras, Nina no come pastas, Ana no come carne".
- **Notas:** La idea es que las afirmaciones negativas no se escriben como hechos, porque bajo universo cerrado ya son falsas.

### ES-UTN-32 — Silogismo de Aristóteles y acontecimientos
- **Fuente:** Guía Mumuki "Hechos y reglas", ejercicios 00009_Aristóteles y sus amigos y 00010_Acontecimiento. https://github.com/pdep-utn/mumuki-guia-logico-hechos-y-reglas
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `mortal/1` a partir de "todos los hombres son mortales" y de que Aristóteles, Hipatia, Platón y Sócrates son humanos. Definir `acontecimiento/2`, que relaciona hechos históricos (caída de Constantinopla, nacimiento de Ada Lovelace…) con su año.

### ES-UTN-33 — El barrio de Flores (viveEn, leDicen)
- **Fuente:** Guía Mumuki "Hechos y reglas", ejercicios 00011 y 00012. https://github.com/pdep-utn/mumuki-guia-logico-hechos-y-reglas
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar a Jorge (poeta), Manuel (polígrafo), Bernardo (tahúr de apodo "ruso") y el Diablo, con sus barrios. Definir `leDicen/2`: a todos se los llama por su nombre, a los tahúres también por su apodo, y al diablo le dicen belcebú o asmodeo.
- **Notas:** Varias cláusulas de un mismo predicado equivalen a un "o".

### ES-UTN-34 — Personajes surrealistas (reglas con varias cláusulas)
- **Fuente:** Guía Mumuki "Hechos y reglas", ejercicio 00013_Clausulas. https://github.com/pdep-utn/mumuki-guia-logico-hechos-y-reglas
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `personajeSurrealista/1`: un personaje es surrealista si aparece en una pintura surrealista o en un cuento surrealista.

### ES-UTN-35 — Familia Simpson: padre, tío, hermano, abuelo baboso
- **Fuente:** PdeP UTN, guía Mumuki "Inversibilidad", ejercicios 00001, 00002 y 00004. https://github.com/pdep-utn/mumuki-guia-logico-inversibilidad
- **Tema:** 1, 2, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con Homero padre de Bart, Lisa y Maggie, y Abraham padre de Homero y Herbert, definir `padre/2`, `tio/2`, `hermano/2` (nadie es hermano de sí mismo), `abuelo/2` y `baboso/2` (abuelo de un nieto menor de dos años, usando `edad/2`).
- **Notas:** Los ejercicios 00011 y 00012 de la misma guía muestran que `hermano` con `Uno \= Otro` al principio no es inversible: `X \= 5` falla cuando `X` está libre.

### ES-UTN-36 — Nafta del viaje y buenaNota inversible
- **Fuente:** Guía Mumuki "Inversibilidad", ejercicios 00005_Algunas cuentas y 00013_Mas generadores. https://github.com/pdep-utn/mumuki-guia-logico-inversibilidad
- **Tema:** 7, 4
- **Dificultad:** 1
- **Solución:** verificada para `buenaNota/1` (genera 4, 5, …, 10):
  ```prolog
  buenaNota(N) :- between(4, 10, N).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `cuantaNaftaConsume/2` (40 litros cada 600 km) y un `buenaNota/1` totalmente inversible para notas de 4 en adelante.
- **Notas:** `N >= 4` solo no genera valores; hace falta un generador como `between/3`. Muestra que el segundo argumento de `is/2` no es inversible.

### ES-UTN-37 — Aritmética: cuadrado, máximo, área, mitad, triple
- **Fuente:** Guías Mumuki "Aritmética" (00008_Cuadrado, 00009_Máximo) y "Práctica aritmética y negación" (00020_area, 00030_mitad, 00040_triple). https://github.com/pdep-utn/mumuki-guia-logico-aritmetica y https://github.com/pdep-utn/mumuki-guia-logico-practica-aritmetica-y-negacion
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `cuadrado/2`, `maximo/3`, `area/3` de un rectángulo, `mitad/2` y `triple/2`.
- **Notas:** La misma guía (00004 a 00007) muestra que `4 \= 4 + 0` es verdadero, porque `4+0` es un término y no se evalúa. Útil para explicar `=`, `is` y `=:=`.

### ES-UTN-38 — Game of Thrones: tuplas, functores y polimorfismo
- **Fuente:** PdeP UTN, guía Mumuki "Functores", ejercicios 00200 a 01000. https://github.com/pdep-utn/mumuki-guia-logico-functores
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `personaje(Nombre, stark(Edad, Sexo))` y `lannister(...)`, definir `esStarkAdulto/1`, `personajeAdulto/1` (delegando en `esAdulto/1`), `esPeligroso/1` (lannister con 300 o más de oro, cualquier stark, nightwatch con lobo) y `cuantoSabe/2`, tratando los distintos functores de forma polimórfica.
  ```prolog
  personaje(arya, stark(18, lobo(nymeria))).
  personaje(joffrey, lannister(310)).
  ```
- **Notas:** Aclara dos trampas: no puede haber espacio entre el nombre del functor y el paréntesis, y el nombre del functor no puede ser una variable en un patrón (`_(_, mujer)` es un error de sintaxis).

### ES-UTN-39 — ¿Quién llega fácil? (existencia y variables libres)
- **Fuente:** PdeP UTN, guía Mumuki "Cuantificación", ejercicios 00001 a 00010. https://github.com/pdep-utn/mumuki-guia-logico-cuantificacion
- **Tema:** 1, 2, 8
- **Dificultad:** 1
- **Solución:** verificada para `loLleva/2` (única respuesta `fede-mariano` con los datos de la guía):
  ```prolog
  sonVecinos(A,B) :- viveEn(A,Z), viveEn(B,Z), A \= B.
  loLleva(A,B) :- sonVecinos(A,B), tieneAuto(A), \+ tieneAuto(B).
  ```
- **SWISH:** sí
- **Enunciado:** Con `viveEn/2` y `quedaEn/2` (destinos y zonas), definir `tieneAuto/1` y `llegaFacil/2` (tiene auto, es Batman o vive en la zona del destino), `sonVecinos/2` y `loLleva/2` (son vecinos, el primero tiene auto y el segundo no).
- **Notas:** El texto explica la cuantificación existencial implícita de las variables que solo aparecen en el cuerpo (`Zona`).

### ES-UTN-40 — bienUbicado, dificilDeEstacionar, zonaDesierta (forall)
- **Fuente:** Guía Mumuki "Cuantificación", ejercicios 00011, 00014, 00015, 00017, 00018 y 00019. https://github.com/pdep-utn/mumuki-guia-logico-cuantificacion
- **Tema:** 9, 8
- **Dificultad:** 2
- **Solución:** verificada:
  ```prolog
  bienUbicado(P) :- viveEn(P,Z), forall(quiereIr(P,D), quedaEn(D,Z)).
  zonaHabitada(Z) :- viveEn(_,Z).
  dificilDeEstacionar(Z) :- zonaHabitada(Z), forall(viveEn(H,Z), tieneAuto(H)).
  % bienUbicado(P): mariano, fede, rodrigo.   dificilDeEstacionar(Z): nuniez.
  ```
- **SWISH:** sí
- **Enunciado:** Una persona está bien ubicada si todos los destinos a los que quiere ir quedan en su zona; una zona habitada es difícil de estacionar si todos sus habitantes tienen auto; una zona está desierta si no tiene habitantes y nadie quiere ir a ninguno de sus destinos.
- **Notas:** Con los datos de la guía, Mariano y Rodrigo salen "bien ubicados" sin querer ir a ningún lado, porque `forall/2` sobre un conjunto vacío es verdadero. El ejercicio 00015 muestra el error clásico: nombrar `Habitante` fuera del `forall` lo liga y cambia el significado.

### ES-UTN-41 — findall: orden de soluciones, cuantoFalta, herramientas
- **Fuente:** PdeP UTN, guía Mumuki "Findall", ejercicios 00001 y 00004 a 00009. https://github.com/pdep-utn/mumuki-guia-logico-findall
- **Tema:** 9, 6
- **Dificultad:** 2
- **Solución:** verificada para `cuantoFalta/1` (da 3):
  ```prolog
  cuantoFalta(N) :- findall(H, necesita(_,H), Hs), sort(Hs, S), length(S, N).
  ```
- **SWISH:** sí
- **Enunciado:** Con `necesita(Persona, Herramienta)`, definir `empleadosNecesitados/1`, `herramientasDemandadas/1`, `cuantoFalta/1` (cantidad de herramientas distintas), `costoTotalDeHerramientasDemandadas/1`, `herramientasDemandadasPor/2` inversible y `noLaNecesitaNadie/1` sin `findall`.
- **Notas:** El último ejercicio pide reemplazar `findall` + `length(L, 0)` por `\+`: un buen ejemplo de no usar findall cuando alcanza con la negación. `herramientasDemandadasPor/2` necesita ligar a la persona antes del findall.

### ES-UTN-42 — Juego en equipos: alHorno, equipoCipayo, abandono
- **Fuente:** Guía Mumuki "Práctica aritmética y negación", ejercicios 00072, 00073 y 00074. https://github.com/pdep-utn/mumuki-guia-logico-practica-aritmetica-y-negacion
- **Tema:** 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `perteneceA/2`, `nivelDeEnergia/2` y `fueraDeJuego/1`: un equipo con al menos un miembro está al horno si todos sus miembros están débiles (menos de 10) o fuera de juego; es cipayo si al menos dos miembros juegan también para otro equipo; abandonó si no tiene integrantes.

### ES-UTN-43 — Medicamentos, drogas y farmacias
- **Fuente:** PdeP UTN, guía Mumuki "Práctica medicamentos", ejercicios 00001 a 00008. https://github.com/pdep-utn/mumuki-guia-logico-practica-medicamentos
- **Tema:** 3, 5, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `incluye(Medicamento, Droga)`, `efecto(Droga, cura(E) | potencia(E))`, `vende/3`, `estaEnfermo/2`, `padre/2` y `actividad(Persona, fecha(D,M,A), compro(...) | preguntoPor(...))`, definir medicamento útil, medicamento milagroso, droga simpática, tipo suicida, tipo ahorrativo, activo en un mes, día productivo, `zafoDe/2` (un ancestro tiene la enfermedad y la persona no) y gasto total.
- **Notas:** Práctica integral de `forall`, `\+`, `findall` + `sum_list`, más una recursión (ancestro).

### ES-UTN-44 — Pulp Fiction: personajes peligrosos y encargos
- **Fuente:** PdeP UTN, guía Mumuki "Práctica Pulp Fiction", ejercicios 00010 a 00080. https://github.com/pdep-utn/mumuki-guia-logico-practica-pulp-fiction-pdep-utn
- **Tema:** 3, 6, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `personaje(Nombre, ladron(Lista) | mafioso(Tipo) | actriz(Pelis) | boxeador)`, `trabajaPara/2`, `amigo/2`, `pareja/2` y `encargo(Solicitante, Encargado, cuidar(_) | ayudar(_) | buscar(_,_))`, definir `esPeligroso/1`, `duoTemible/2`, `estaEnProblemas/1`, `sanCayetano/1`, `elMasAtareado/1`, `personajesRespetables/1`, `hartoDe/2` y `duoDiferenciable/2`.
- **Notas:** `amigo/2` y `pareja/2` se piden simétricos: hay que definir un predicado auxiliar y no duplicar los hechos, para no generar recursión infinita.

### ES-UTN-45 — Comidas del bar y los gustos de Andrea
- **Fuente:** PdeP UTN, guía Mumuki "Práctica paradigma lógico", ejercicios 00001 a 00003. https://github.com/pdep-utn/mumuki-guia-prolog-practica-paradigma-logico-pdep-utn
- **Tema:** 2, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `precio/2` y `tieneCarne/1`, definir `leGusta/2` para seis amigos con reglas distintas (a Celeste le gusta todo lo del bar, a Carolina nada, etc.). Extenderlo para Andrea (le gusta lo que le gusta a Luis salvo lo que le gusta a José, y las achuras). Definir `masBarata/2` y `comidaPopular/1` (le gusta a todos o es la más barata).
- **Notas:** "A Carolina no le gusta nada" no se escribe: universo cerrado. "La más barata" se resuelve con `\+` (no existe una más barata), sin listas.

### ES-UTN-46 — Lecturas densas y lectores intensos
- **Fuente:** Guía Mumuki "Práctica paradigma lógico", ejercicios 00004 y 00005. https://github.com/pdep-utn/mumuki-guia-prolog-practica-paradigma-logico-pdep-utn
- **Tema:** 3, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con functores `libro(Nombre, Editorial, Paginas)`, `paper(Titulo, Hojas, Visitas)` y `saga(Nombre, CantLibros)`, definir `lecturaDensa/1` con un criterio por tipo. Luego, `lectorIntenso/1`: leyó más de un material y todo lo que leyó es denso.

### ES-UTN-47 — Votaciones: votos totales y provincia decidida
- **Fuente:** Guía Mumuki "Práctica paradigma lógico", ejercicios 00006 y 00007. https://github.com/pdep-utn/mumuki-guia-prolog-practica-paradigma-logico-pdep-utn
- **Tema:** 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `votos(Partido, Provincia, Votos)` y `padron/2`, definir `votosTotales/2`, completamente inversible, y `decidida/1`: un único partido sacó más del 30 % del padrón de la provincia.
- **Notas:** "Un único" se expresa como "existe uno y no existe otro distinto", con `\+`.

### ES-UTN-48 — EscaPdeP: salas de escape (simulacro de parcial 2022)
- **Fuente:** PdeP UTN, guía Mumuki "EscaPdeP – parcial de lógico simulacro 2022". https://github.com/pdep-utn/mumuki-guia-prolog-esca-pde-p-parcial-de-logico-simulacro-2022
- **Tema:** 3, 6, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `persona(Apodo, Edad, Peculiaridades)`, `esSalaDe/2` y `sala(Nombre, terrorifica(Sustos, EdadMin) | familiar(Tema, Habitaciones) | enigmatica(Candados))`, definir (totalmente inversibles) la dificultad de cada sala, `puedeSalir/2`, `tieneSuerte/2`, `esMacabra/1` y `empresaCopada/1` (promedio de dificultad menor a 4), y agregar nuevas empresas a la base.
- **Notas:** El último punto obliga a decidir qué no se modela (una sala sin cantidad de habitaciones conocida, una empresa sin salas): universo cerrado. Examen completo en Google Docs, enlazado desde la guía.

### ES-UTN-49 — Boliches (simulacro de parcial 2022)
- **Fuente:** PdeP UTN, guía Mumuki "PdePePePePe – parcial de lógico simulacro 2022". https://github.com/pdep-utn/mumuki-guia-prolog-pde-pe-pe-pe-pe-parcial-de-logico-simulacro-2022
- **Tema:** 3, 6, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `quedaEn/2`, `entran/2`, `sirveComida/1` y `esDeTipo(Boliche, tematico(_) | cachengue(Canciones) | electronico(Dj, Desde, Hasta))`, definir `esPiola/1`, `soloParaBailar/1`, `podemosIrConEsa/1`, `puntaje/2`, `elMasGrande/2`, `puedeAbastecer/2` (la cantidad no es inversible) y cargar tres boliches nuevos.

### ES-UTN-50 — TP Lógico: elecciones, candidatos y promesas
- **Fuente:** PdeP UTN, guía Mumuki "TP Lógico", ejercicios 00001 a 00007. https://github.com/pdep-utn/mumuki-guia-prolog-tp-logico
- **Tema:** 1, 3, 6, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar candidatos, partidos, provincias y habitantes (justificando lo que no se modela, como "Peter no es candidato del partido Amarillo"). Definir `esPicante/1`, `elGranCandidato/1` (su partido gana en todas sus provincias y es el más joven del partido), `ajusteConsultora/3` y `promete/2` con functores `inflacion/2`, `construir(ListaDeObras)` y `nuevosPuestosDeTrabajo/1`, y la influencia de cada promesa en la intención de voto.
- **Notas:** La tabla de habitantes es una imagen (`assets/tabla_*.JPG`). Una de las edades viene como año de nacimiento: hay que calcularla.

## Repositorios Prolog-Uqbar (ejemplos de clase e integradores)

Organización GitHub https://github.com/Prolog-Uqbar, usada por los cursos de PdeP. Cada
repositorio trae el enunciado en `README.md` y una solución `.pl` de la cátedra. Ningún
repositorio declara licencia. "Carga en SWI 9.2.9" significa que el archivo `.pl` se
cargó sin errores (puede haber avisos de cláusulas no contiguas); cuando el repositorio
trae tests PlUnit, se indica si pasan.

### ES-UTN-51 — Películas: primera base de conocimiento
- **Fuente:** Prolog-Uqbar, "peliculas-prolog" (clase introductoria). https://github.com/Prolog-Uqbar/peliculas-prolog
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** sí, `peliculas.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Modelar actores y películas para consultar si Di Caprio actuó en "Once upon a time in Hollywood", en qué películas actuó, quiénes actuaron en ella y si Lorraine Bracco hizo alguna película. Después definir `suertude/1`: actuó en una película que ganó un Oscar.
- **Notas:** Primer ejercicio del curso: consultas con constantes, con variables y existenciales (`_`).

### ES-UTN-52 — ¿Es una bruja? (Monty Python)
- **Fuente:** Prolog-Uqbar, "Ejemplo-es-una-bruja". https://github.com/Prolog-Uqbar/Ejemplo-es-una-bruja
- **Tema:** 2, 4
- **Dificultad:** 1
- **Solución:** sí, `bruja.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con hechos sobre verrugas, sombreros, narices y pesos, encadenar reglas: parece bruja si tiene verruga, o nariz de bruja y sombrero; es bruja si parece, si convirtió a alguien en algo o si es de madera (flota, o sea pesa lo mismo que un ganso).
- **Notas:** Sin enunciado formal (el README solo lo nombra): es un ejemplo para seguir el encadenamiento de reglas y el backtracking.

### ES-UTN-53 — Universidades: reglas "y" / "o" e inversibilidad
- **Fuente:** Prolog-Uqbar, "inversibilidadUniversidades". https://github.com/Prolog-Uqbar/inversibilidadUniversidades
- **Tema:** 1, 2, 8
- **Dificultad:** 1
- **Solución:** sí, `universidad.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con universidades públicas, `trabaja(Persona, Lugar, Sueldo)` y `empleo(Lugar, publico|privado)`, definir `universidadPrivada/1` (con `not`), `universitario/1`, `docenteEn/2`, `esPublico/1` y `trabajadorEstatal/1`, y probar su inversibilidad.
- **Notas:** Ejemplo de clase comentado, no un enunciado: sirve como material de lectura guiada.

### ES-UTN-54 — Gustos por país: esTipico y esExclusivo (forall vs. not)
- **Fuente:** Prolog-Uqbar, "Ejemplo-para-todo-Gustos". https://github.com/Prolog-Uqbar/Ejemplo-para-todo-Gustos
- **Tema:** 8, 9
- **Dificultad:** 2
- **Solución:** sí, `ejemploParaTodo.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `nacionalidad/2` y `leGusta/2`, una comida es típica de un país si les gusta a todas las personas de ese país, y exclusiva si solo les gusta a personas de ese país. Resolver cada una con `forall/2` y con doble negación `not((... , not(...)))`.
- **Notas:** Muestra la equivalencia ∀x P(x) → Q(x) ≡ ¬∃x (P(x) ∧ ¬Q(x)) y por qué hace falta un generador antes del `forall` para que sea inversible.

### ES-UTN-55 — Harry Potter: hechizos olvidados y usados (not y forall)
- **Fuente:** Prolog-Uqbar, "cuantificadoresHarryPotter". https://github.com/Prolog-Uqbar/cuantificadoresHarryPotter
- **Tema:** 8, 9
- **Dificultad:** 1
- **Solución:** sí, `harrypotter.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `mago/1`, `hechizo/2`, `pocion/3` y `usa(Mago, Cosa, Veces)`, definir qué magos usan hechizos, qué hechizos se usaron y cuáles nadie usó, y otros predicados con cuantificación universal.
- **Notas:** Solo código, sin enunciado en el README.

### ES-UTN-56 — Aprobación con margen (Harry Potter)
- **Fuente:** Prolog-Uqbar, "Ejemplo-nota-aprobacion". https://github.com/Prolog-Uqbar/Ejemplo-nota-aprobacion
- **Tema:** 7, 4
- **Dificultad:** 1
- **Solución:** sí, `aprobacion.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `nota(Alumno, Materia, Nota)` y `notaMinimaAprobacion/2`, definir `aproboConMargen/3`: el margen es la nota menos la mínima y debe ser mayor o igual a 0.
- **Notas:** El archivo comenta por qué `esNotaDeAprobacion(Nota) :- Nota > 5.` no es inversible y lo compara con listar los hechos.

### ES-UTN-57 — Personalidades históricas (functores de fecha y acciones)
- **Fuente:** Prolog-Uqbar, "functoresPersonalidades". https://github.com/Prolog-Uqbar/functoresPersonalidades
- **Tema:** 3, 7, 9
- **Dificultad:** 2
- **Solución:** sí, `personalidades.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `murio(Persona, Fecha)` y la fecha actual, calcular años desde la muerte, quién murió antes (por año o por fecha exacta), aniversarios en agosto y quién murió hace más tiempo. Con `realiza(Persona, milagro(_) | gol(_,_) | medida(_,_,_), Fecha)`, definir divino, nac&pop, aclamado y acción antigua.

### ES-UTN-58 — Familia con functores heterogéneos
- **Fuente:** Prolog-Uqbar, "Ejemplo-ListasFunctores-Familia". https://github.com/Prolog-Uqbar/Ejemplo-ListasFunctores-Familia
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** sí, `familia.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** El tercer argumento de `hijo/3` es un dato de forma variable (`fecha(A,D)`, `dia(D,M,A)`, un átomo, una lista); definir `esMayorDeEdad/1` con un predicado `esDelSiglo20/1` que tenga una cláusula por cada forma.
- **Notas:** Ejemplo de clase sin enunciado: muestra polimorfismo por unificación con distintos functores y con listas.

### ES-UTN-59 — Autómata finito no determinístico
- **Fuente:** Prolog-Uqbar, "automatas-nondet-prolog". https://github.com/Prolog-Uqbar/automatas-nondet-prolog
- **Tema:** 4, 5, 6
- **Dificultad:** 2
- **Solución:** sí, `automatas.pl`; los 7 tests PlUnit de `test_automatas.pl` pasan en SWI 9.2.9
- **SWISH:** sí
- **Enunciado:** Representar el AFN M = ({1,2,3,4}, {a,b}, δ, 1, {2}) con hechos `transicion(Origen, Token, Destino)` y definir `esValida/1`, que decide si una palabra (lista de tokens) es aceptada.
  ```prolog
  parsear([], Estado) :- estadoFinal(Estado).
  parsear([T|Ts], E) :- transicion(E, T, E2), parsear(Ts, E2).
  ```
- **Notas:** El no determinismo del autómata lo resuelve el backtracking de Prolog. Tiene video de explicación enlazado en el README.

### ES-UTN-60 — Mochileros en la montaña (listas y caminos)
- **Fuente:** Prolog-Uqbar, "ListasEnLaMontania". https://github.com/Prolog-Uqbar/ListasEnLaMontania
- **Tema:** 5, 6, 7, 9
- **Dificultad:** 2
- **Solución:** sí, `montanias.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `tieneRefugio/3`, `quierenIr(Montania, ListaDeAmigos)` y `equipaje(Persona, Pesos)`, definir cuántos quieren ir juntos, `quiereIr/2`, compañeros en más de una montaña, `puedeLlegar/2` (altura ≤ 50 × peso total) y quién lleva más cosas. Con `tramo(Desde, Hasta, Tiempo)`, averiguar si se puede ascender de un refugio a otro, en cuánto tiempo y por qué refugios pasa cada camino.
- **Notas:** Marca como difíciles `montaniaRepetida/1` y la lista de refugios del camino (acumulador).

### ES-UTN-61 — Escoba de 15
- **Fuente:** Prolog-Uqbar, "integradorEscoba15". https://github.com/Prolog-Uqbar/integradorEscoba15
- **Tema:** 3, 5, 6, 7, 9
- **Dificultad:** 3
- **Solución:** sí, `carta.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con las cartas de la mesa y de la mano de cada jugador (`carta(Valor, Palo)`; sota 8, caballo 9, rey 10), deducir la mejor jugada: escoba si puede sumar 15 con toda la mesa; si no, levantar la mayor cantidad de cartas que sumen 15 con una de la mano; si no, tirar cualquiera.
- **Notas:** Requiere generar subconjuntos de una lista (recursión) y elegir el máximo.

### ES-UTN-62 — Clave secreta (generar y testear)
- **Fuente:** Prolog-Uqbar, "integradorClaves". https://github.com/Prolog-Uqbar/integradorClaves
- **Tema:** 4, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `claves.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Una clave es una vocal minúscula seguida de dos dígitos distintos que no forman secuencia ascendente ni descendente. Generar todas las claves, las posibles para usuarios con preferencias (Tita, Toto, Tato y una propia), y responder si las pistas identifican una sola clave, si algún usuario no puede tener clave y qué últimos dígitos permiten descartar usuarios.
- **Notas:** Buen ejemplo de consultas de orden superior sobre un espacio generado (`findall` + `length`, `forall`, `\+`).

### ES-UTN-63 — 24: la clave de Cloe O'Brian
- **Fuente:** Prolog-Uqbar, "combinatoriaClaves24". https://github.com/Prolog-Uqbar/combinatoriaClaves24
- **Tema:** 4, 7, 9
- **Dificultad:** 1
- **Solución:** sí, `programa.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** La clave es una vocal minúscula seguida de tres dígitos distintos sin 0 ni 7. Listar las claves posibles y calcular cuántos capítulos (de 3600 s) harían falta para probarlas todas a un segundo por intento.

### ES-UTN-64 — Eclipse en Argentina
- **Fuente:** Prolog-Uqbar, "integradorEclipse". https://github.com/Prolog-Uqbar/integradorEclipse
- **Tema:** 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `eclipse.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con una tabla de ciudades (provincia, horario, altura del sol, duración) y los servicios de cada una, obtener los lugares con altura mayor a 10º o que empiezan después de las 17:42, los lugares sin servicios, las provincias con una sola ciudad, el lugar donde más dura y la duración promedio (en el país, por provincia y en ciudades con telescopio). Analizar la inversibilidad.
- **Notas:** Hay que elegir una representación para horas y duraciones (functores o segundos).

### ES-UTN-65 — Entrando a boxes (repuestos de autos)
- **Fuente:** Prolog-Uqbar, "integradorSimpleAutos". https://github.com/Prolog-Uqbar/integradorSimpleAutos
- **Tema:** 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `repuestos.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con autos (combustible, capacidad, seguridad), repuestos (descripción, magnitud) y registros de colocación por día, decidir qué repuestos conviene colocar a cada auto según tres reglas, qué autos tienen más de uno, exactamente uno o ningún componente, y qué repuestos convendría colocar en todos los autos.

### ES-UTN-66 — Camboya: lugar más visitado y recaudación
- **Fuente:** Prolog-Uqbar, "ParaTodo-Camboya". https://github.com/Prolog-Uqbar/ParaTodo-Camboya
- **Tema:** 3, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `camboya.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Modelar lugares de Camboya (templos, ríos, ciudades…) con visitantes y costo de entrada. Encontrar el lugar más visitado de cada tipo. Con impuestos porcentuales, fijos o por rango según el tipo de lugar, calcular el costo final y la recaudación de cada lugar.
- **Notas:** "El más visitado" sin listas: existe uno y no existe otro del mismo tipo con más visitas.

### ES-UTN-67 — Super liga: grupos válidos y clubes populares
- **Fuente:** Prolog-Uqbar, "Integrador-super-liga". https://github.com/Prolog-Uqbar/Integrador-super-liga
- **Tema:** 2, 4, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `solucion.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `club(Nombre, Ubicacion, Hinchas)`, `tienePlata/1` y `clasico/2`, armar grupos válidos de cuatro equipos (un grande como cabeza, uno del AMBA no grande, uno del interior y un cuarto que no sea grande ni clásico de los anteriores). Encontrar los clubes populares y las ciudades futbolísticamente importantes.
  ```prolog
  club(boca,amba,100). club(nob,rosario,50). clasico(central,nob).
  ```
- **Notas:** El README aclara que se resuelve sin listas ni functores.

### ES-UTN-68 — Presidentes argentinos: calificación de gestiones
- **Fuente:** Prolog-Uqbar, "Integrador-Presidentes" y su variante "ParaTodo-Presidentes". https://github.com/Prolog-Uqbar/Integrador-Presidentes y https://github.com/Prolog-Uqbar/ParaTodo-Presidentes
- **Tema:** 3, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `presidentes.pl` en cada repositorio (cargan en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con períodos presidenciales y acciones de gobierno (fecha, lugar, beneficiados; buena si beneficia a más de 10 000), averiguar quién fue presidente más de una vez, quién gobernaba en una fecha, si un presidente hizo algo bueno, y calificarlo como insulso, malo, regular, bueno o muy bueno.
- **Notas:** La variante "ParaTodo" usa solo años, lo que simplifica comparar fechas. Las cinco categorías son un buen ejercicio de combinar `forall` y `\+` con cuidado.

### ES-UTN-69 — Lista de compras: ¿es caro un negocio?
- **Fuente:** Prolog-Uqbar, "listasCompras". https://github.com/Prolog-Uqbar/listasCompras
- **Tema:** 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `ejemploListas.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `precio(Negocio, Producto, Precio)`, formalizar ocho definiciones distintas de "negocio caro": vende algo más caro que otro negocio, vende todo por encima de 1000, la mayoría por encima de 1000, más de un producto por encima de 1000, todo más caro que otro negocio, etc.
- **Notas:** Excelente para contrastar existencial, universal (`forall`), conteo (`findall` + `length`) y promedio.

### ES-UTN-70 — El asadito
- **Fuente:** Prolog-Uqbar, "integradorAsadito". https://github.com/Prolog-Uqbar/integradorAsadito
- **Tema:** 3, 6, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `solucion.pl` (carga con avisos de cláusulas no contiguas)
- **SWISH:** sí
- **Enunciado:** Con `asado/2`, `alimento/2` y `asistio(Asado, Persona, Accion)` (acciones como `hizoChistes(N)`, `toca(Instr, Calidad)`, `contoAnecdotaDe(Lista)`), modelar gustos y un amigo nuevo; definir asado exitoso, aceptable, fracasado y `buenaOnda/2`.
- **Notas:** El README pide justificar universo cerrado ("la pareja de Carlos no asistió") e inversibilidad. El README tiene un paréntesis sin cerrar en `contoAnecdotaDe([marina,pablo])`.

### ES-UTN-71 — El mundo de la música: managers y ventas
- **Fuente:** Prolog-Uqbar, "Integrador-Mundo-de-la-musica". https://github.com/Prolog-Uqbar/Integrador-Mundo-de-la-musica
- **Tema:** 3, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `musica.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `disco(Artista, Nombre, Copias, Anio)` y `manager(Artista, normal(Porc) | buenaOnda(Nombre, Lugar) | estafador)`, definir `clasico/1`, `totalVentas/2`, `gananciaArtista/2` (10 centavos por venta menos la parte del manager) y `namberuan/2` (artista sin manager con el disco más vendido del año).
- **Notas:** "Para pensar": cómo se expresa que un artista no tiene manager (universo cerrado) y qué hay que tocar si aparece un nuevo tipo de manager (polimorfismo).

### ES-UTN-72 — Centro de estudiantes: elecciones y fraude
- **Fuente:** Prolog-Uqbar, "integradorCentrosDeEstudiantes". https://github.com/Prolog-Uqbar/integradorCentrosDeEstudiantes
- **Tema:** 3, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `centroEstudiantes.pl` y `variante1.pl` (cargan en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con `elecciones/1`, `estudiante(Depto, Anio, Nombre)` y `votos(Agrupacion, Votos, Anio)`, averiguar quién ganó cada elección, si siempre gana el mismo, si hubo fraude (más votos que padrón) y en qué años. Con `realizoAccion(Agrupacion, lucha(_) | gestionIndividual(_,_,_) | obra(_))`, clasificar agrupaciones como demagógica, burócrata o transparente.
- **Notas:** El README enlaza dos variantes del enunciado en Google Docs.

### ES-UTN-73 — ¡Llegó el previaje!
- **Fuente:** Prolog-Uqbar, "integradorPreViaje". https://github.com/Prolog-Uqbar/integradorPreViaje
- **Tema:** 3, 6, 7, 8, 9
- **Dificultad:** 3
- **Solución:** sí, `previaje.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con comercios adheridos, `factura(Persona, hotel(_,_) | excursion(_,_,_) | vuelo(_,_))` y `registroVuelo/5`, calcular el monto a devolver a cada persona (por tipo de factura, adicional por ciudad, penalidad si hay facturas truchas, tope de 100 000), los destinos solo de trabajo y los estafadores; inventar un comercio nuevo sin reescribir predicados.

### ES-UTN-74 — Trabajadores estresades
- **Fuente:** Prolog-Uqbar, "Integrador-Trabajadores-estresados". https://github.com/Prolog-Uqbar/Integrador-Trabajadores-estresados
- **Tema:** 3, 5, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `trabajadores.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con tareas modeladas como functores (tomar examen, discurso, gol), fechas, lugar de nacimiento y una jerarquía `quedaEn(Lugar, LugarMayor)`, definir quién nunca salió de casa, qué tareas son estresantes (en territorio argentino, a cualquier nivel de `quedaEn`), trabajadores zen, locos y sabios, y quién hizo más tareas estresantes.
- **Notas:** "Queda en Argentina" es un cierre transitivo recursivo sobre `quedaEn/2`.

### ES-UTN-75 — Sueños y personajes
- **Fuente:** Prolog-Uqbar, "Integrador-Suenios". https://github.com/Prolog-Uqbar/Integrador-Suenios
- **Tema:** 3, 5, 7, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `suenios.pl` y variantes sin functores (cargan en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con quién cree en qué personaje y sueños modelados como functores (cantante con discos, futbolista en un equipo, lotería con números), definir persona ambiciosa (suma de dificultades mayor a 20), química entre personaje y persona (sin `findall`) y si un personaje puede alegrar a una persona, considerando amigos de backup a cualquier nivel.
- **Notas:** "Diego no cree en nadie" y "Macarena no quiere ganar la lotería" no se modelan (universo cerrado). La amistad indirecta es recursiva.

### ES-UTN-76 — Piratas del Caribe
- **Fuente:** Prolog-Uqbar, "integradorPiratasCaribe". https://github.com/Prolog-Uqbar/integradorPiratasCaribe
- **Tema:** 3, 5, 7, 8, 9
- **Dificultad:** 3
- **Solución:** sí, `piratas.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Con puertos, rutas, viajes y embarcaciones (galeón, carabela, galera), definir si un capitán puede abordar una embarcación (poderío mayor que resistencia, calculada según el tipo), su botín al bloquear un puerto, capitanes decadentes, terror del puerto y excéntricos, y si puede ir de un puerto a otro por rutas cuya distancia sea menor a su poderío.
- **Notas:** Pide inventar hechos para que ciertos piratas cumplan cada caracterización: obliga a pensar los datos al revés.

### ES-UTN-77 — Parque de atracciones
- **Fuente:** Prolog-Uqbar, "Integrador-parqueAtracciones". https://github.com/Prolog-Uqbar/Integrador-parqueAtracciones
- **Tema:** 3, 6, 8, 9
- **Dificultad:** 2
- **Solución:** sí, `parquesAtracciones.pl`, pero **no carga limpio**: error de sintaxis en la línea 120 ("Full stop in clause-body?") en SWI 9.2.9
- **SWISH:** sí
- **Enunciado:** Modelar personas (edad, altura) y atracciones con requisitos; definir `puedeSubir/2`, `esParaElle/2` y `malaIdea/2` (grupo etario sin ningún juego común). Luego programas (lista ordenada de atracciones de un parque): `programaLogico/1` y `hastaAca/3`. Por último, pasaportes básico, flex y premium.

### ES-UTN-78 — Caminante del cielo (Star Wars)
- **Fuente:** Prolog-Uqbar, "IntegradorCaminanteDelCielo". https://github.com/Prolog-Uqbar/IntegradorCaminanteDelCielo
- **Tema:** 3, 5, 6, 8, 9
- **Dificultad:** 3
- **Solución:** sí, `caminanteDelCielo.pl` (carga con avisos de cláusulas no contiguas)
- **SWISH:** sí
- **Enunciado:** Con `apareceEn(Personaje, Episodio, Lado)`, `maestro/1`, `caracterizacion/2`, `elementosPresentes(Episodio, Lista)` y `precedeA/2`, definir `nuevoEpisodio(Heroe, Villano, Extra, Dispositivo)` con cinco condiciones (héroe jedi que nunca pasó al lado oscuro, villano ambiguo en episodios posteriores, extra exótico siempre junto al héroe o al villano, dispositivo en 3 o más episodios), verificarlo y generar todas las conformaciones.
- **Notas:** En el README falta un paréntesis en `caracterizacion(yoda,ser(desconocido,5).`. "Episodio posterior" requiere el cierre transitivo de `precedeA/2`.

### ES-UTN-79 — Amistades y química (predicados dinámicos)
- **Fuente:** Prolog-Uqbar, "predicados-dinamicos-prolog". https://github.com/Prolog-Uqbar/predicados-dinamicos-prolog
- **Tema:** 10, 9
- **Dificultad:** 2
- **Solución:** sí, `amistad.pl`; los 3 tests PlUnit de `testAmistad.pl` pasan en SWI 9.2.9
- **SWISH:** sí
- **Enunciado:** Con `hayQuimica/2` y `quiereViajar/2` declarados `dynamic`, definir `seLlevanBien/2` y `puedenPlanificarViaje/2` (forall), y modificar la base con `assert`/`retract` para ver cómo cambian las respuestas.
- **Notas:** El README enlaza un video explicativo.

### ES-UTN-80 — Llegamos: contador con assert/retract
- **Fuente:** Prolog-Uqbar, "Ejemplo-assert-Llegamos". https://github.com/Prolog-Uqbar/Ejemplo-assert-Llegamos
- **Tema:** 10, 4
- **Dificultad:** 3
- **Solución:** sí, `insistencia.pl` (carga en SWI 9.2.9)
- **SWISH:** sí
- **Enunciado:** Implementar `llegamos/0`, que responde "no" una cantidad aleatoria de veces y después "sí", guardando el estado en hechos dinámicos que se modifican con `assert`, `retractall` y el patrón de falla forzada (`fail`).
- **Notas:** Muestra efectos laterales, que en general conviene evitar: útil como contraejemplo.

### ES-UTN-81 — Predicados que no terminan y tabling
- **Fuente:** Prolog-Uqbar, "performance-prolog". https://github.com/Prolog-Uqbar/performance-prolog
- **Tema:** 4, 5, 8, X
- **Dificultad:** 3
- **Solución:** sí, `predicadosQueNoTerminan.pl`, `mayor.pl`, `divisiblesPor3.pl`; los 2 tests de tabling pasan en SWI 9.2.9
- **SWISH:** sí
- **Enunciado:** Estudiar por qué `numero(N) :- numero(A), N is A+1, N < 10.` y una `amistad/2` simétrica por regla no terminan, y cómo `:- table` lo resuelve. Comparar varias definiciones de "el mayor de una lista" y de "los divisibles por 3", con y sin backtracking innecesario (corte).
- **Notas:** Material avanzado, con video enlazado. El tabling es específico de SWI-Prolog (y de XSB), no es ISO.

## Parciales y TP enlazados desde el curso "miércoles noche" (2025)

### ES-UTN-82 — Sueldos (parcial de lógico 2025, temas 1 y 2)
- **Fuente:** PdeP UTN FRBA, curso miércoles noche, "Sueldos – Tema 1 / Tema 2" (Google Docs). https://docs.google.com/document/d/1Y_7iQV_-4zegEvECU7HZrxQrujf5A-EM-yEcA6W9MRo/edit
- **Tema:** 3, 6, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar quién trabaja en cada departamento y cuánto gana cada persona según su tipo (asalariado con horas, jefe con lista de subordinados, independiente con oficio). Definir departamento paganini (todos ganan bien; tema 2: feliz), departamento en problemas (nadie quiere o nadie está satisfecho) y los equipos posibles de al menos 2 personas dentro de un presupuesto.
- **Notas:** El último punto es combinatorio (subconjuntos de una lista con suma acotada). Enlazado desde https://github.com/pdep-utn/enunciados-miercoles-noche/blob/master/pages/resumen-clases/clases-2025.md

### ES-UTN-83 — Cocinando con Chichito de Erquiaga (TP lógico 2025)
- **Fuente:** PdeP UTN FRBA, curso miércoles noche, "TP Lógico 2025" (Google Docs). https://docs.google.com/document/d/10prIWrMAoWqXwJuDz9Ktdm4TnH9WFY56Y_YoAyq8flQ/edit
- **Tema:** 1, 3, 6, 7, 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar cocineros, cocinas y técnicas (Emma no participa; Carla "no sabe nada de fermentación"), y definir `cocineroExperto/1`, `cocinaPopular/1`, `tecnicaUniversal/1` y `cocinaDestacada/1`. Luego modelar platos como functores (parrilla, ensalada, pasta, sushi, ramen) y definir `mejorPlato/2`, `platoGana/2`, `atiendeVegetarianos/1` y los predicados combinatorios `platosPosibles/3`, `platosACocinar/3` y `concurso/2`.
- **Notas:** Todos los predicados se piden inversibles. Los tres últimos generan sublistas (con `subtract`/recursión o `sublista/2` propia).
