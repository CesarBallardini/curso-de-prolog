# Capítulo 31 - La imagen del servicio de Inscripciones.
#
# Desde ejemplos/capitulo-31, que tiene el programa y sus archivos de datos:
#
#     docker build -t inscripciones -f inscripciones/Dockerfile .
#     docker run --rm -p 8080:8080 inscripciones
#
# Parte de la imagen oficial de SWI-Prolog, en la misma versión del curso,
# copia el programa y lo ejecuta como servicio en el puerto 8080, abierto a
# cualquier interfaz: dentro del contenedor, localhost no se alcanza desde
# afuera. Los archivos de datos quedan en /archivos, junto a /app, donde el
# módulo intercambio los busca.

FROM swipl:9.2.9

WORKDIR /app
COPY inscripciones/*.pl ./
COPY archivos/ /archivos/

EXPOSE 8080
CMD ["swipl", "servicio.pl", "--puerto=8080", "--publico"]
