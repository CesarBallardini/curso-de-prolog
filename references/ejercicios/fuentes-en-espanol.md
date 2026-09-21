# Banco de ejercicios de Prolog: fuentes en español

Ejercicios de Prolog tomados de material universitario y en línea en español.
Cada entrada resume el enunciado en 1 a 3 oraciones y enlaza al original para el texto
completo. No se copian pasajes largos.

El banco está dividido en varios archivos por institución:

| Archivo | Contenido | Entradas |
|---|---|---|
| [fuentes-en-espanol-utn.md](fuentes-en-espanol-utn.md) | UTN FRBA, Paradigmas de Programación: guías 2008, guías Mumuki, repositorios Prolog-Uqbar, parcial y TP 2025 | 83 |
| [fuentes-en-espanol-us.md](fuentes-en-espanol-us.md) | Universidad de Sevilla, José A. Alonso: documento de 2006 y repositorio de 2022 | 72 |
| [fuentes-en-espanol-otras.md](fuentes-en-espanol-otras.md) | UNS, UBA, UHU, UVa, Oviedo, UJI, UCO, UAL, UAM (México), UNAL y U. de Pamplona (Colombia) | 60 |

Total: 215 entradas. Varias entradas agrupan ejercicios muy cortos del mismo documento
(por ejemplo, "primero, resto y cons"), así que el número de ejercicios individuales es
mayor.

## Etiquetas de tema (programa del curso)

0 Entorno · 1 Hechos, consultas, variables · 2 Reglas y conjunciones · 3 Términos y
unificación · 4 Búsqueda, resolución, backtracking · 5 Recursión · 6 Listas ·
7 Aritmética · 8 Corte y negación · 9 Todas las soluciones y orden superior (findall,
forall, not) · 10 Base de datos dinámica · 11 Prolog y SQL · A DCG/gramáticas ·
X Avanzado/fuera de alcance.

Dificultad: 1 (directo) · 2 (requiere pensar) · 3 (desafío).

## Formato de cada entrada

```
### ES-<institución>-<n> — <título corto>
- **Fuente:** institución/autor, documento, sección, URL exacta
- **Tema:** números del programa
- **Dificultad:** 1 / 2 / 3
- **Solución:** dónde hay una / "no" / solución breve verificada
- **SWISH:** sí / no (motivo)
- **Enunciado:** resumen en español; código mínimo
- **Notas:** (opcional)
```

"Verificada" significa que la solución (del documento o propia) se ejecutó en
SWI-Prolog 9.2.9 local y dio la respuesta esperada por el enunciado.

## Resumen

Entradas por institución:

| Institución | Prefijo | Entradas |
|---|---|---|
| UTN FRBA (Paradigmas de Programación) | ES-UTN | 83 |
| Universidad de Sevilla (J. A. Alonso) | ES-US | 72 |
| Universitat Jaume I (Toledo, Pacheco, Escrig) | ES-UJI | 14 |
| Universidad de Buenos Aires (PLP) | ES-UBA | 10 |
| Universidad Nacional del Sur | ES-UNS | 9 |
| Universidad de Huelva | ES-UHU | 9 |
| Universidad de Oviedo (J. E. Labra) | ES-UNIOVI | 5 |
| Universidad de Valladolid | ES-UVA | 4 |
| UAM Azcapotzalco (tutorial de Á. Fernández Pineda) | ES-UAM | 3 |
| Universidad de Almería | ES-UAL | 2 |
| Universidad Nacional de Colombia | ES-UNAL | 2 |
| Universidad de Córdoba | ES-UCO | 1 |
| Universidad de Pamplona | ES-UPAMPLONA | 1 |

Entradas por tema (una entrada puede tener varios temas):

| Tema | Entradas |
|---|---|
| 0 Entorno | 2 |
| 1 Hechos, consultas, variables | 23 |
| 2 Reglas y conjunciones | 35 |
| 3 Términos y unificación | 55 |
| 4 Búsqueda, backtracking | 51 |
| 5 Recursión | 79 |
| 6 Listas | 102 |
| 7 Aritmética | 93 |
| 8 Corte y negación | 76 |
| 9 findall, forall, not | 72 |
| 10 Base de datos dinámica | 7 |
| 11 Prolog y SQL | 2 |
| A DCG/gramáticas | 3 |
| X Avanzado | 10 |

Por dificultad: 77 de nivel 1, 111 de nivel 2 y 27 de nivel 3. Por solución: 30
verificadas en SWI-Prolog 9.2.9, 111 con solución publicada sin verificar y 74 sin
solución.

Huecos: hay muy poco material en español para los temas 0 (entorno), 10 (base de datos
dinámica), 11 (Prolog y SQL; lo único sólido es el capítulo 5 del libro de la UJI,
ES-UJI-9) y A (DCG; en español predominan las gramáticas escritas con `append/3`, no con
`-->`).

## Advertencias que afectan a varias fuentes

- **Codificación en Windows.** SWI-Prolog 9.2.9 en Windows lee los `.pl` con la
  codificación del sistema (flag `encoding` = `text`), no en UTF-8. Los archivos con
  tildes en los nombres de predicado o en los átomos (`último/2`, `azúcar`) dan errores
  de sintaxis o, peor, se leen como variables. Solución: `:- encoding(utf8).` al
  principio del archivo. SWISH no tiene este problema. Verificado con los archivos de
  Alonso (7 de 8 fallan sin la directiva y cargan con ella).
- **Strings.** Los materiales anteriores a SWI-Prolog 7 asumen que `"hola"` es una lista
  de códigos. Hoy es un objeto string: hay que usar `string_codes/2`, `atom_chars/2` o
  `set_prolog_flag(double_quotes, codes)`.
- **`not` prefijo.** Los textos para ECLiPSe escriben `not objetivo`, que en SWI es un
  error de sintaxis: se escribe `not(objetivo)` o `\+ objetivo`.
- **Formato de respuestas.** Los documentos viejos muestran `Yes`/`No`; SWI 9 responde
  `true`/`false`.

## Fuentes y licencias

| Id | Documento | URL | Licencia / términos |
|---|---|---|---|
| UTN-G08 | PdeP UTN FRBA, "Paradigma Lógico – Guías 2008" (prácticas 1 a 6 y extra) | https://pdep-utn.github.io/viejogooglesite/material/guas-de-ejercicios.html | Sin licencia explícita. Material de cátedra publicado en abierto ("Powered by Google Sites"). Citar y enlazar; no redistribuir el PDF. |
| UTN-MUM | Guías Mumuki de la cátedra PdeP (organización GitHub `pdep-utn`, repositorios `mumuki-guia-logico-*` y `mumuki-guia-prolog-*`) | https://github.com/pdep-utn | CC BY-SA 4.0 (archivo LICENSE de cada repositorio; COPYRIGHT dice "Pendiente and contributors"). |
| UTN-UQB | Organización GitHub "Prolog-Uqbar" (ejercicios integradores y ejemplos de clase, con solución `.pl`) | https://github.com/Prolog-Uqbar | Sin licencia declarada en ningún repositorio (todos los derechos reservados por defecto). Citar y enlazar; no copiar las soluciones. |
| UTN-PAR | Parcial "Sueldos" (2025) y TP "Cocinando con Chichito de Erquiaga" (2025), curso miércoles noche | https://github.com/pdep-utn/enunciados-miercoles-noche/blob/master/pages/resumen-clases/clases-2025.md | Google Docs públicos enlazados desde un repositorio sin licencia. Citar y enlazar. |
| US-EJ | José A. Alonso Jiménez (Univ. de Sevilla), *Ejercicios de programación declarativa con Prolog*, 2006 (110 ejercicios resueltos) | https://www.cs.us.es/~jalonso/publicaciones/2006-ej_prog_declarativa.pdf | CC BY-NC-SA 2.5 España (declarada en la página 2 del PDF). |
| US-GH | José A. Alonso Jiménez, repositorio *Ejercicios de programación lógica con Prolog* (2022), con copias en SWISH | https://github.com/jaalonso/Ejercicios-Prolog | GPL-3.0 (archivo LICENSE). |
| UNS | UNS, "Conceptos de Inteligencia Artificial – Introducción al Lenguaje Prolog – Ejercicios" | http://cs.uns.edu.ar/~grs/Conceptos/EjerciciosProlog.pdf | No declarada. |
| UBA | UBA, PLP, "Práctica 7 – Programación lógica" (Verano 2018), copia en el repositorio de un estudiante | https://github.com/pmontepagano/plp/blob/master/practicas_enunciados/p7_logica.pdf | No declarada (enunciado de la cátedra en un repositorio sin licencia). |
| UHU | Carpio, Aranda y Marco, *Programación Declarativa*, Materiales para la docencia [95], Univ. de Huelva, 2010 | https://www.uhu.es/jose.carpio/N_95.pdf | © Universidad de Huelva y los autores. |
| UVA | UVa, "Práctica I. Prolog I: Elementos básicos de Prolog" | https://www.infor.uva.es/~calonso/Ingenieria%20Conocimiento-Grado%20Informatica/Practicas/Practica%20I%20Prolog.pdf | No declarada. |
| UNIOVI | J. E. Labra, *Programación Práctica en Prolog*, Univ. de Oviedo, 1998 (copia en la Univ. de Pamplona) | https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/06052011/practica1_prolog.pdf | No declarada. |
| UJI | Toledo, Pacheco y Escrig, *El Lenguaje de Programación PROLOG*, Universitat Jaume I, 2000 (copia de terceros) | http://mural.uv.es/mijuanlo/PracticasPROLOG.pdf | © de los autores; no se encontró copia oficial ni licencia. |
| UCO | UCO, Programación Declarativa, "Tema 8. Introducción al lenguaje Prolog" (2019-2020) | http://www.uco.es/users/ma1fegan/2019-2020/pd/temas/Tema-8/PD-Tema-8.-Introduccion-al-lenguaje-Prolog.pdf | No declarada. |
| UAL | UAL (indalog), "Transparencias de Programación Lógica y Funcional" (2005) | http://indalog.ual.es/WWW/prolog2005.pdf | No declarada. |
| UAM | Á. Fernández Pineda, "Tutorial básico de programación en Prolog" (alojado por la UAM Azcapotzalco) | https://academicos.azc.uam.mx/cbr/Cursos/UEA_12p_Log/TutorialdePrologEspa.pdf | Todos los derechos reservados; prohíbe expresamente incluir la obra, total o parcialmente, en otra obra. Solo se describen los ejercicios. |
| UNAL | UNAL, sitio "Paradigmas de Programación – Programación lógica" y cuaderno SWISH "Paradigma Programacion Logica" | https://ferestrepoca.github.io/paradigmas-de-programacion/proglogica/logica_teoria/lenguaje.html | Repositorio sin licencia declarada. |
| UPAMPLONA | Univ. de Pamplona, "Práctica No. 6. Ejercicios en Prolog" | https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/28062012/practicaprologup_familiarespl.pdf | No declarada. |

Fuentes buscadas sin resultado: el tutorial de Prolog de la UNR no apareció en las
búsquedas; para la UPM y la UCM solo aparecieron programas de asignatura, no guías; no
se buscó a fondo en UNLP, UNC, UNQ, UPV, UGR ni UMA (quedan como pendientes); el PDF de ejercicios de la BUAP (México),
`https://www.cs.buap.mx/~zacarias/FZF/EjerciciosProlog.pdf`, devuelve 404; los apuntes
de Studocu, Scribd, Course Hero y Slideshare se descartaron por ser copias sin autoría
verificable.
