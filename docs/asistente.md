# Preguntar al curso

El botón «Preguntar al curso», abajo a la derecha de cada página, abre un panel donde se escribe una
pregunta sobre el curso. La respuesta indica dónde leerlo: hasta cinco secciones del curso, cada una
con su enlace, y los fragmentos que más se acercan a la pregunta, con sus palabras resaltadas. Las
secciones y los fragmentos aparecen en el orden del curso, del primer capítulo al último.

El botón «Quitar» de cada pregunta la borra de la conversación, y «Borrar la conversación» las borra
todas.

## Cómo busca

La búsqueda compara las palabras de la pregunta con las del texto de cada sección, con su título y con
una lista de palabras y preguntas que una persona que recién empieza usaría para encontrarla, escrita
de antemano. Se ignoran las tildes y las terminaciones de las palabras, y los nombres de predicados con
su aridad (`findall/3`) y los operadores (`\+`) se buscan tal cual. Una expresión que es el título
de una sección, como «árbol de derivación» o «variable anónima», lleva a esa sección, y las secciones
que solo la mencionan de paso quedan fuera de la lista.

Las páginas de soluciones no forman parte de la búsqueda: el panel no cita ni enlaza ninguna solución.
Cuando el curso no parece tratar la pregunta, el panel lo indica y muestra de todos modos las secciones
más cercanas.

## Respuesta escrita

En Chrome de escritorio, cuando el modelo de lenguaje que Chrome trae integrado ya está instalado en el
equipo, el panel agrega una respuesta escrita a partir de los fragmentos hallados. Cada afirmación lleva
entre corchetes el número del fragmento en que se apoya, con un enlace a su sección. El sitio nunca
inicia la descarga de ese modelo. En los demás navegadores el panel muestra los fragmentos y los
enlaces, sin respuesta escrita.

## Límites

- Una respuesta escrita puede equivocarse: la sección enlazada es la fuente.
- Una pregunta formulada con palabras muy distintas de las del curso puede no encontrar la sección
  que la responde; reformularla con otras palabras suele bastar.
- El panel no resuelve ejercicios: indica las secciones donde se explica lo necesario.

## Privacidad

Todo ocurre en el navegador. El panel descarga del sitio un único archivo con el texto del curso la
primera vez que se abre, y la pregunta no se envía a ningún servidor: ni la búsqueda ni la respuesta
escrita la sacan del equipo.
