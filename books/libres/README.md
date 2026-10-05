# Libros de Prolog descargados de freecomputerbooks.com

Lista derivada de <https://freecomputerbooks.com/langPrologBooks.html> (20 entradas).
Para cada entrada se visitó la página de aterrizaje en freecomputerbooks.com, se siguió el
enlace al sitio que realmente hospeda el archivo y se descargó lo que ese sitio sirve
directamente (`curl -L --max-time 180`). No se sorteó ningún muro de pago, registro ni DRM.

En una **segunda pasada** se rastrearon las seis entradas que habían quedado sin descargar,
buscando esta vez más allá del enlace de freecomputerbooks: sitio propio del autor, página
oficial del proyecto, repositorio de fuentes, editorial, repositorio institucional del autor y,
como último recurso para una fuente caída, su instantánea en el Wayback Machine. Aparecieron así
tres libros que el primer rastreo no vio: *Learn Prolog Now!* (PDF compilado, en el repositorio
oficial de las fuentes LaTeX), *Artificial Intelligence through Prolog* (28 PDF por capítulo, en
el repositorio institucional de la universidad del autor) y *Prolog Techniques* (edición gratuita
de Bookboon, ya retirada, recuperada del archivo web del espejo que la lista original apuntaba).

Las tres entradas restantes **no son faltantes**: su autor publicó el libro como sitio web, y esa
es la forma en que el libro existe. Van marcadas «Solo HTML (se lee en línea)» y la columna de
origen lleva el enlace con el que se leen, que es el libro mismo. No se armaron PDF juntando
capítulos HTML, no se convirtieron sitios web a PDF, no se concatenaron los 28 capítulos de Rowe
y no se usaron muros de pago, registros, DRM ni sitios que exijan «desbloquear» la descarga.

**Los PDF no están versionados.** `books/**/*.pdf` está en `.gitignore` porque son decenas de MB
de material de terceros; este `README.md` sí se versiona, para poder rehacer las descargas y
revisar su procedencia.

**La columna «Licencia / base de disponibilidad» está sin auditar**: reproduce lo que dice la
fuente (o «sin declaración de licencia» cuando no dice nada). Revisar caso por caso antes de
citar, enlazar o reutilizar cualquier contenido en el libro del curso, que es MIT.

| # | Título | Autor | Estado | URL de origen | Licencia / base de disponibilidad | Archivo local |
|---|--------|-------|--------|---------------|-----------------------------------|---------------|
| 1 | Adventure in Prolog | Dennis Merritt | **Solo HTML (se lee en línea)** | **<https://www.amzi.com/AdventureInProlog/>** ← el libro | Sitio de Amzi! inc. (empresa del autor): «Copyright © 1995-2016 Amzi! inc. All Rights Reserved». freecomputerbooks afirma «CC BY 3.0», sin respaldo en el sitio del autor | — (sin archivo local). El autor publica el libro como sitio web, capítulo por capítulo, y **ese enlace es el libro**: está completo y se lee en línea. No hay PDF y no hace falta buscarlo: el sitio de Amzi! solo ofrece además las ediciones Kindle e impresa, de pago, y la edición de Springer-Verlag (1990, DOI 10.1007/978-1-4612-3426-5) está tras muro de pago. El segundo enlace de freecomputerbooks (`athena.ecs.csus.edu/~mei/logicp/Programming_in_Prolog.pdf`) está mal rotulado: es *Programming in Prolog* de Clocksin & Mellish, 5.ª ed., ya presente en `books/` |
| 2 | The Power of Prolog | Markus Triska | **Solo HTML (se lee en línea)** | **<https://www.metalevel.at/prolog>** ← el libro | Sitio personal del autor, libro completo en HTML, «always work in progress»; sin declaración de licencia | — (sin archivo local). El autor publica el libro como sitio web y **ese enlace es el libro**, siempre en su última versión. Para leerlo sin conexión, el repositorio oficial (<https://codeberg.org/triska/the-power-of-prolog>, espejo en GitHub) trae las fuentes HTML y un servidor HTTP propio («This book is *self-hosting*»); no hay PDF ni objetivo de compilación a PDF. El otro enlace listado, vdoc.pub, corresponde a otro libro, *Prolog++* |
| 3 | Learn Prolog Now! | P. Blackburn, J. Bos, K. Striegnitz | **Descargado** | <https://raw.githubusercontent.com/LearnPrologNow/lpn/master/text/lpn.pdf> (repositorio oficial <https://github.com/LearnPrologNow/lpn>, enlazado desde <https://lpn.swi-prolog.org/>) | Repositorio oficial de las fuentes LaTeX del libro, de los propios autores. Su `COPYING` dice: «The Learn Prolog Now! sources are available under the Creative Commons Attribution-ShareAlike license», CC BY-SA 4.0 | `blackburn-learn-prolog-now.pdf` (279 pp., 0,96 MB; PDF compilado por `scripts/_run` a partir de las fuentes LaTeX, con capa de texto). Los sitios web del libro (cs.union.edu, let.rug.nl/bos, lpn.swi-prolog.org) solo ofrecen HTML: el PDF está únicamente en el repositorio |
| 4 | The Art of Prolog, 2nd ed. | L. Sterling, E. Shapiro | Omitido a propósito | <https://freecomputerbooks.com/The-Art-of-Prolog.html> | MIT Press Open Access, según la página | — (ya está en `books/the-art-of-prolog*.pdf`) |
| 5 | Prolog for Programmers | F. Kluźniak, S. Szpakowicz | **Descargado** | <https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf> | Sitio universitario del coautor (uOttawa); freecomputerbooks indica «CC BY 3.0» (verificar en el propio PDF) | `kluzniak-prolog-for-programmers.pdf` (317 pp., 3,3 MB) |
| 6 | Prolog Programming in Depth | Michael A. Covington | **Descargado** | <https://www.covingtoninnovations.com/books/PPID.pdf> | Sitio propio del autor (Covington Innovations), que publica sus libros descatalogados; sin declaración de licencia explícita en el PDF | `covington-prolog-programming-in-depth.pdf` (529 pp., 13 MB; escaneado, texto no extraíble) |
| 7 | Logic, Programming and Prolog, 2nd ed. | U. Nilsson, J. Małuszyński | **Descargado** | <https://www.ida.liu.se/~ulfni53/lpp/bok/bok.pdf> | Página del autor (Linköping). Aviso propio: «may be downloaded and printed for personal use only … It is not allowed to distribute the book electronically» → **no redistribuir** | `nilsson-logic-programming-and-prolog.pdf` (294 pp., 2,0 MB) |
| 8 | An Introduction to Logic Programming Through Prolog | J. M. Spivey | **Descargado** | <https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf> | Página del autor (Oxford): «I freely grant permission to make copies of the whole work for any purpose except direct commercial gain» | `spivey-introduction-to-logic-programming.pdf` (258 pp., 1,4 MB) |
| 9 | Prolog Programming: A First Course | Paul Brna | **Descargado** | <https://www.csee.umbc.edu/courses/771/papers/brna.pdf.gz> | Apuntes de curso alojados por UMBC (copia de terceros); sin declaración de licencia. El enlace principal listado (courses.cs.washington.edu) ahora exige inicio de sesión institucional | `brna-prolog-programming-a-first-course.pdf` (197 pp., 0,65 MB; descomprimido del `.gz`) |
| 10 | Prolog Experiments in Discrete Mathematics, Logic, and Computability | James L. Hein | **Descargado** | <https://samples.jbpub.com/9780763772062/PrologLabBook09.pdf> | Servidor de muestras de la editorial Jones & Bartlett (material complementario del libro de texto). El PDF dice «Copyright © 2009 by James L. Hein. All rights reserved» | `hein-prolog-experiments.pdf` (158 pp., 1,4 MB) |
| 11 | Prolog Programming for Artificial Intelligence | Ivan Bratko | **Descargado** | <https://github.com/vhr1975/eBooks/> (ruta `AI/…/PROLOG PROGRAMMING FOR ARTIFICIAL INTELLIGENCE - lvan Bratko.pdf`) | **Copia de terceros en GitHub, sin declaración de licencia.** Libro comercial (Pearson/Addison-Wesley); el PDF dice «© 1986 Addison-Wesley … All rights reserved». Revisar antes de usar | `bratko-prolog-for-ai.pdf` (442 pp., 33 MB; es la 1.ª ed. de 1986, no la 4.ª que anuncia la página) |
| 12 | Artificial Intelligence through Prolog | Neil C. Rowe | **Descargado** (28 archivos) | <https://hdl.handle.net/10945/36984> (repositorio Calhoun de la NPS) · sitio del autor: <https://faculty.nps.edu/ncrowe/book/book.html> | Repositorio institucional Calhoun de la Naval Postgraduate School, la universidad del propio autor. Base de disponibilidad declarada en el registro: **«Approved for public release; distribution is unlimited»**. Libro original: Prentice-Hall, 1988, ISBN 0-13-048679-5 | `rowe-ai-through-prolog/` — **28 archivos separados, no un PDF único**, porque así los publica el repositorio: `rowe-title`, `rowe-toc`, `rowe-preface`, `rowe-ch01`…`rowe-ch15`, `rowe-appa`…`rowe-appg`, `rowe-figures`, `rowe-instructors-manual`, `rowe-errata` (10,1 MB en total). Se respetó la estructura por capítulos del editor y **no se concatenaron**. Ojo al usarlos: cada archivo es una impresión a PDF de la página HTML correspondiente del sitio del autor, hecha por la biblioteca de la NPS en 2013, así que la página 1 es una portada añadida por Calhoun y el texto lleva los encabezados y pies del navegador (fecha, `Page 1 of 3`, URL de origen); no es la composición tipográfica de Prentice-Hall. Para relistar los 28: `curl -s "https://calhoun.nps.edu/server/api/pid/find?id=hdl:10945/36984"` → `…/core/items/<uuid>/bundles` → bundle `ORIGINAL` |
| 13 | Expert Systems in Prolog (*Building Expert Systems in Prolog*) | Dennis Merritt | **Descargado** | <https://www.inf.fu-berlin.de/lehre/SS09/KI/folien/merritt.pdf> | PDF alojado por la FU Berlin como material de cátedra (copia de terceros); sin declaración de licencia. El sitio del autor (<https://www.amzi.com/ExpertSystemsInProlog/>) ofrece el mismo texto en HTML con «All Rights Reserved» | `merritt-expert-systems-in-prolog.pdf` (308 pp., 4,2 MB) |
| 14 | AI Algorithms, Data Structures, and Idioms in Prolog, Lisp, and Java | G. F. Luger, W. A. Stubblefield | **Descargado** | <http://www.cse.sc.edu/~mgv/csce580sp15/Luger_0136070477_1.pdf> | PDF único alojado por la Univ. de South Carolina (copia de terceros); sin declaración de licencia. El autor publica los mismos capítulos sueltos en <http://www.cs.unm.edu/~luger/> (Prolog: `ai-final2/*.pdf`) | `luger-ai-algorithms-prolog-lisp-java.pdf` (463 pp., 2,6 MB) |
| 15 | Simply Logical: Intelligent Reasoning by Example | Peter Flach | **Descargado** | <http://people.cs.bris.ac.uk/~flach/SL/SL.pdf> | Página del autor (Univ. of Bristol): «This PDF copy is made available free of charge». Uso no comercial; en el curso se cita y enlaza, no se copia | `flach-simply-logical.pdf` (247 pp., 4,0 MB) |
| 16 | Natural Language Processing for Prolog Programmers | Michael A. Covington | **Descargado** | <https://www.covingtoninnovations.com/books/NLPPP.pdf> | Sitio propio del autor: «You are welcome to make copies of this book, printed or electronic, for your own use» | `covington-nlp-for-prolog-programmers.pdf` (361 pp., 32 MB; escaneado, texto no extraíble) |
| 17 | Prolog and Natural-Language Analysis | F. C. N. Pereira, S. M. Shieber | **Descargado** | <http://www.mtome.com/Publications/PNLA/prolog-digital.pdf> | Edición digital («Millennial reissue», 2002) de los propios autores vía Microtome Publishing: «distributed at no charge for noncommercial use» | `pereira-prolog-and-natural-language-analysis.pdf` (204 pp., 1,2 MB) |
| 18 | Natural Language Processing Techniques in Prolog | P. Blackburn, K. Striegnitz | **Solo HTML (se lee en línea)** | **<https://cs.union.edu/~striegnk/courses/nlp-with-prolog/html/>** ← los apuntes | Apuntes de cátedra (versión 1.2.4, 2002) en el sitio de la coautora (Union College); sin declaración de licencia | — (sin archivo local). Las autoras los publican como sitio web (salida de `latex2html`, un `nodeNN.html` por sección) y **ese enlace es el texto completo**. No hay PDF ni PostScript junto a `html/` (todas las rutas probables dan 404 y el listado del directorio está prohibido), el sitio de Blackburn (<http://www.patrickblackburn.org/>) no los enlaza y no existe repositorio público con las fuentes LaTeX |
| 19 | Prolog Techniques | Attila Csenki | **Descargado** | <https://web.archive.org/web/20180324182504id_/http://library.ku.ac.ke/wp-content/downloads/2011/08/Bookboon/IT,Programming%20and%20Web/prolog-techniques-applications-of-prolog.pdf> | Edición gratuita de Bookboon/Ventus, «© 2009 Attila Csenki & Ventus Publishing ApS», ISBN 978-87-7681-476-2. **Sin declaración de licencia; retirado del catálogo de Bookboon.** Revisar antes de citar o reutilizar | `csenki-prolog-techniques.pdf` (186 pp., 1,8 MB). Procedencia: instantánea de 2018 en el Wayback Machine del **mismo espejo que lista freecomputerbooks** (Kenyatta University), que hoy devuelve 404. Se recurrió al archivo porque la fuente original ya no lo sirve: la ficha en Bookboon (<https://bookboon.com/en/prolog-techniques-applications-of-prolog-ebook>) devuelve 404, su página de autor declara «Number of Titles: 0» y el catálogo actual exige suscripción. El otro enlace que freecomputerbooks da como «espejo» (`gprolog.org/manual/gprolog.pdf`) es el manual de GNU Prolog, no este libro |
| 20 | Applications of Prolog | Attila Csenki | **Descargado** | <https://www.barcodebookshop.com/books/pvyw82ctws.pdf> | Edición gratuita de Bookboon («Download free eBooks at bookboon.com»), «© 2014 Attila Csenki & bookboon.com», servida por un tercero; el espejo principal listado (Kenyatta University) devuelve 404. PDF con restricciones de permisos embebidas | `csenki-applications-of-prolog.pdf` (203 pp., 3,1 MB) |

## Material aportado por el autor del curso

Estos archivos no salen del rastreo de freecomputerbooks: los agregó el autor del curso
(2026-09-27). Son libros y artículos con derechos reservados, en su mayoría sin edición abierta.
Como todo lo de este directorio, **no se versionan ni se redistribuyen** (`.gitignore` excluye
`books/**/*.pdf`, `*.djvu` y `*.epub`): se usan solo para leer, y el curso los cita y reescribe
sus ideas, sin copiar texto ni programas. Los nombres originales de la mayoría tenían el formato
de libgen (`libgen.li`, o el de sus copias de artículos de revistas), que no es una fuente
autorizada; se los renombró el 2026-09-27 con la convención de este directorio
(`autor-titulo-corto`, y `autor-año-titulo-corto` para los artículos).

### Libros

| Título | Autor | Archivo local | Conversión a Markdown | Notas |
|---|---|---|---|---|
| Programming in Prolog: Using the ISO Standard, 5.ª ed. (Springer, 2003) | W. F. Clocksin, C. S. Mellish | `clocksin-mellish-programming-in-prolog.pdf` | `books/programming-in-prolog/` (una página por capítulo) | © Springer |
| Clause and Effect: Prolog Programming for the Working Programmer (Springer, 1997) | W. F. Clocksin | `clocksin-clause-and-effect.pdf` (148 pp., capa de texto OCR, código en Helvetica) | `books/clocksin-clause-and-effect/` (un solo archivo: el PDF no tiene marcadores) | © Springer; vías legales: SpringerLink (DOI 10.1007/978-3-642-58274-5) y el préstamo del Internet Archive. Revisado para las partes II y III |
| Programming in Tabled Prolog (borrador, 1999) | David S. Warren | `warren-programming-in-tabled-prolog.epub` | `books/warren-programming-in-tabled-prolog/` (una página por capítulo; convertido con pandoc; las figuras eran GIF y quedan solo sus leyendas; 202 bloques de código) | Tabulación en XSB: fuente para el capítulo 39 |
| The Implementation of Prolog (Princeton University Press, 1993) | P. Boizumault (trad. A. M. Djamboulian, J. Fattouh) | `boizumault-implementation-of-prolog.pdf` (313 pp.) | — | La máquina abstracta y la compilación: fuente para el capítulo 35 |
| Prolog and its Applications: A Japanese Perspective (Springer, 1991) | F. Mizoguchi (ed.) | `mizoguchi-prolog-and-its-applications.djvu` | — | Aplicaciones de Prolog |
| The Craft of Prolog (MIT Press, 1990): **solo las páginas preliminares** (14 pp.: tapas, página legal, índice, prólogo de la serie, prefacio y comienzo de la introducción) | R. A. O'Keefe | `okeefe-craft-of-prolog-front-matter.pdf` (escaneo sin capa de texto, 3,5 MB) | — | © MIT Press; escaneo publicado por la biblioteca del Istituto per la Matematica Applicata del CNR (Génova), `http://geca.area.ge.cnr.it/files/15802.pdf` (descargado el 2026-09-28; el servidor no responde por HTTPS). El índice sirve para ubicar temas; el libro completo no está disponible en forma abierta |
| Prolog Programming and Applications (Macmillan Computer Science Series, Macmillan Education UK, 1985; doi 10.1007/978-1-349-07962-9) | W. D. Burnham, A. R. Hall | `burnham-hall-prolog-programming-and-applications.pdf` (126 pp., con capa de texto y marcadores) | `books/burnham-hall-prolog-programming-and-applications/` (un archivo por capítulo, 2026-09-28) | © Macmillan / Springer; vía legal: SpringerLink (el DOI). Descargado por el autor el 2026-09-28 con nombre de libgen, renombrado ese día. Capítulos: 1–7 el lenguaje, depuración; 8 «Case Studies»; apéndices sobre Prolog-1 y Quintus Prolog |
| The Art of Prolog: Advanced Programming Techniques, 2.ª ed. (MIT Press, 1994; reimpresión de 2018) | L. Sterling, E. Shapiro | `sterling-shapiro-art-of-prolog.pdf` (553 pp., generado con calibre) | — (la conversión `books/the-art-of-prolog/` sale de otra copia) | Agregado el 2026-10-04. Su capa de texto es más ruidosa que la de la conversión existente (espacios dentro de los identificadores, `:-` perdido, `\|` leído como `I`), pero los dígitos salen bien donde la otra lee `0` como `O`: sirve para cotejar un pasaje dudoso |
| The Practice of Prolog (MIT Press, 1990) | L. Sterling (ed.) | `sterling-practice-of-prolog.pdf` (331 pp.) | — | Aplicaciones de Prolog, un capítulo por sistema |
| Building Expert Systems in Prolog (Springer, 1989; doi 10.1007/978-1-4613-8911-8) | D. Merritt | `merritt-building-expert-systems-in-prolog.pdf` (360 pp.) | — | La edición original de Springer; `merritt-expert-systems-in-prolog.pdf` (308 pp.) es la copia de la FU Berlin |
| PROLOG for Computer Science (Springer, 1994; doi 10.1007/978-1-4471-2031-5) | M. S. Dawe, C. M. Dawe | `dawe-prolog-for-computer-science.pdf` (189 pp.) | — | © Springer |
| Artificial Intelligence Techniques in Prolog (Morgan Kaufmann / Elsevier, 1994) | Y. Shoham | `shoham-ai-techniques-in-prolog.pdf` (332 pp.) | — | Búsqueda (con minimax), metaintérpretes, encadenamiento hacia adelante, mantenimiento de la verdad, restricciones, incertidumbre, planificación y razonamiento temporal, aprendizaje, lenguaje natural (según el prefacio) |
| Warren's Abstract Machine: A Tutorial Reconstruction (MIT Press, 1991; reimpresión del autor, 1999) | H. Aït-Kaci | `aitkaci-warrens-abstract-machine.pdf` (144 pp.) | — | La máquina abstracta de Warren, explicada paso a paso |
| The Implementation of Prolog, segundo escaneo | P. Boizumault | `boizumault-implementation-of-prolog-escaneo-2.pdf` (312 pp.) | — | Otro escaneo del mismo libro, con una página menos; se conserva por si una página es ilegible en el primero |
| The Annotated Turing: A Guided Tour through Alan Turing's Historic Paper on Computability and the Turing Machine (Wiley, 2008; ISBN 978-0-470-22905-7) | C. Petzold | `petzold-annotated-turing.pdf` (386 pp., escaneo con OCR, sin marcadores) | `books/petzold-annotated-turing/` (un solo archivo con tabla «Contents by line») | © Wiley. Agregado el 2026-10-05 con nombre de libgen, renombrado ese día. El artículo de Turing de 1936 comentado línea por línea, con las tablas de la máquina universal: fuente para el capítulo 52 |
| The Essential Turing: Seminal Writings in Computing, Logic, Philosophy, Artificial Intelligence, and Artificial Life plus The Secrets of Enigma (Clarendon Press / Oxford University Press, 2004; ISBN 0-19-825080-0) | B. J. Copeland (ed.) | `copeland-essential-turing.pdf` (622 pp., con capa de texto y marcadores) | `books/copeland-essential-turing/` (un archivo por capítulo) | © Oxford University Press. Agregado el 2026-10-05 con nombre de libgen, renombrado ese día. Incluye el artículo de 1936, la corrección de 1938, la crítica de Post (1947) y «Corrections to Turing's Universal Computing Machine» de D. W. Davies: fuente para el capítulo 52 |

### Artículos y reseñas

| Referencia | Archivo local | Notas |
|---|---|---|
| P. Brna, H. Pain, B. du Boulay, «Teaching, Learning and Using Prolog: Understanding Prolog», *Instructional Science* 19 (4-5), 1990, pp. 247–256 | `brna-1990-understanding-prolog.pdf` (10 pp.) | Número especial sobre la enseñanza de Prolog |
| M. W. van Someren, «Understanding students' errors with Prolog unification», *Instructional Science* 19 (4-5), 1990 | `vansomeren-1990-students-errors-prolog-unification.pdf` (17 pp.) | Mismo número especial: errores de los estudiantes con la unificación (capítulo 4) |
| M. W. van Someren, «What's wrong? Understanding beginners' problems with Prolog», *Instructional Science* 19 (4-5), 1990 | `vansomeren-1990-beginners-problems-with-prolog.pdf` (27 pp.) | Mismo número especial: los problemas de los principiantes (parte I) |
| P. Brna, M. Brayshaw, A. Bundy, M. Elsom-Cook, P. Fung, T. Dodd, «An overview of Prolog debugging tools», *Instructional Science* 20 (2-3), 1991 | `brna-1991-prolog-debugging-tools.pdf` (23 pp.) | Herramientas de depuración (capítulos 26 y 33) |
| P. Brna, A. Bundy, T. Dodd, M. Eisenstadt, C. K. Looi, H. Pain, D. Robertson, B. Smith, M. van Someren, «Prolog programming techniques», *Instructional Science* 20 (2-3), 1991 | `brna-1991-prolog-programming-techniques.pdf` (24 pp.; convertido en `books/brna-1991-prolog-programming-techniques/`) | Técnicas de programación con nombre: antecedente de los patrones de la parte II |
| A. Bowles, D. Robertson, W. Vasconcelos, M. Vargas-Vera et al., «Applying Prolog programming techniques», *International Journal of Human-Computer Studies* 41 (3), 1994 | `bowles-1994-applying-prolog-programming-techniques.pdf` (22 pp., escaneo sin capa de texto) | Continuación del anterior |
| M. A. Covington et al., «Coding guidelines for Prolog», *Theory and Practice of Logic Programming*, 2012 (doi 10.1017/S1471068411000391) | `covington-2012-coding-guidelines-for-prolog.pdf` (39 pp.) | Las pautas de estilo que cita el capítulo 14. Antes `plcoding.pdf` |
| A. Serebrenik, T. Schrijvers, B. Demoen, «Improving Prolog programs: Refactoring for Prolog», *Theory and Practice of Logic Programming* 8 (2), 2008 | `serebrenik-2008-refactoring-for-prolog.pdf` (16 pp.) | Refactorización (capítulos 14 y 35) |
| G. A. Narboni, «From Prolog III to Prolog IV: The Logic of Constraint Programming Revisited», *Constraints* 4 (4), 1999 | `narboni-1999-from-prolog-iii-to-prolog-iv.pdf` (23 pp.) | Programación con restricciones (capítulo 23) |
| D. Cabrol, «Applications of Prolog to represent physical and chemical objects — a tutorial introduction», *Computer Physics Communications* 61 (1-2), 1990 | `cabrol-1990-prolog-physical-and-chemical-objects.pdf` (24 pp.) | Aplicación |
| M. Okada et al., «Prolog-Based System for Nursing Staff Scheduling Implemented on a Personal Computer», *Computers and Biomedical Research* 21 (1), 1988 | `okada-1988-prolog-nursing-staff-scheduling.pdf` (11 pp.) | Aplicación: asignación de turnos |
| Reseña de P. Smith, *Expert Systems Development in Prolog and Turbo-Prolog* (Sigma Press), *European Journal of Operational Research* 41 (2), 1989 | `review-1989-smith-expert-systems-prolog-turbo-prolog-ejor.pdf` (2 pp.) | Reseña |
| R. Lai, reseña del mismo libro, *The Knowledge Engineering Review* 4 (1), 1989 | `review-1989-smith-expert-systems-prolog-turbo-prolog-ker.pdf` (4 pp.) | Reseña |
| Reseña de C. Marcus, *Prolog Programming: Applications for Database Systems, Expert Systems and Natural Language Systems*, *International Journal of Adaptive Control and Signal Processing* 2 (1), 1988 | `review-1988-marcus-prolog-programming.pdf` (2 pp.) | Reseña |
| M. Spivey, reseña de T. Dodd, *Prolog: A Logical Approach*; C. J. Hogger, *Essentials of Logic Programming*; y R. A. O'Keefe, *The Craft of Prolog*, *Science of Computer Programming* 17 (1-3), 1991, p. 254 | `review-1991-spivey-okeefe-dodd-hogger-scp.pdf` (3 pp.) | Reseña; renombrado el 2026-09-28 desde el nombre de libgen |
| D. H. D. Warren, «An Abstract Prolog Instruction Set», Technical Note 309, SRI International, 1983 | `warren-1983-abstract-prolog-instruction-set.pdf` (34 pp., escaneo sin capa de texto) | La definición original de la WAM; agregado el 2026-10-04 (antes `641.pdf`) |
| D. Gardner, M. Rizack, «A Prolog knowledge base for drug interactions», *Computers and Biomedical Research* 23 (2), 1990, pp. 139–152 | `gardner-1990-prolog-knowledge-base-drug-interactions.pdf` (14 pp.) | Aplicación: base de conocimiento |
| B. A. Nadel, «Constraint satisfaction in Prolog: Complexity and theory-based heuristics», *Information Sciences* 83 (3-4), 1995, pp. 113–131 | `nadel-1995-constraint-satisfaction-in-prolog.pdf` (19 pp.) | Restricciones (capítulo 23) |
| Z. Brezočnik, B. Horvat, «Formal hardware specification and verification using Prolog», *Microprocessing and Microprogramming* 27 (1-5), 1989, pp. 163–170 | `brezocnik-1989-hardware-specification-verification-prolog.pdf` (8 pp.) | Aplicación: verificación de circuitos |

**Renombrados el 2026-10-04:** los once archivos nuevos de las dos tablas (siete libros y cuatro
artículos) llegaron con el nombre de libgen o sin un nombre descriptivo (`641.pdf`), y
se renombraron con la misma convención.

**Duplicados eliminados (2026-09-27):** una segunda copia, idéntica byte a byte (mismo MD5), del
artículo de Okada et al.; y la copia de JSTOR (11 pp., con portada) del artículo de Brna, Pain y
du Boulay, del que se conserva la versión de la editorial. El 2026-10-04, una segunda copia de
*The Implementation of Prolog*, idéntica byte a byte a `boizumault-implementation-of-prolog.pdf`.

## Resumen

- **16 libros con archivo local, 43 PDF, 110,5 MB en total**: 15 PDF sueltos en este directorio
  (100,4 MB) más los 28 PDF por capítulo de Rowe en `rowe-ai-through-prolog/` (10,1 MB).
- **3 entradas se leen en línea, y ahí está el libro completo** — no son faltantes, su autor lo
  publicó como sitio web: Adventure in Prolog (<https://www.amzi.com/AdventureInProlog/>), The
  Power of Prolog (<https://www.metalevel.at/prolog>) y Natural Language Processing Techniques in
  Prolog (<https://cs.union.edu/~striegnk/courses/nlp-with-prolog/html/>).
- **1 omitida a propósito**: The Art of Prolog, ya en `books/`.
- Calidad del texto, para `tools/pdf2md.py`: los dos libros de Covington son escaneos sin capa de
  texto útil y necesitan OCR previo; los 28 archivos de Rowe son impresiones a PDF de páginas web
  y arrastran encabezados y pies del navegador que habrá que limpiar. El resto tiene capa de
  texto limpia.
- Los enlaces a `vdoc.pub` que aparecen en casi todas las entradas no sirven el archivo: devuelven
  HTML y exigen interacción en la página, así que no se usaron.
