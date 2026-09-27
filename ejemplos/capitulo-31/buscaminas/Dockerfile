# Capítulo 31 - Solución del ejercicio 7: la imagen del Buscaminas como
# servicio.
#
# Desde ejemplos/capitulo-31/buscaminas:
#
#     docker build -t buscaminas .
#     docker run --rm -p 8080:8080 buscaminas
#
# El comando necesita --servicio, para ofrecer el juego por HTTP en lugar de
# jugarlo en la terminal; --puerto=8080, el puerto que se publica con -p; y
# --publico, porque dentro del contenedor localhost no se alcanza desde
# afuera.

FROM swipl:9.2.9

WORKDIR /app
COPY *.pl ./

EXPOSE 8080
CMD ["swipl", "buscaminas.pl", "--servicio", "--puerto=8080", "--publico"]
