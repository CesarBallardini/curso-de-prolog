# Capítulo 1 — La primera hora

!!! warning "En preparación"
    Este capítulo todavía no está escrito.

    Lo que sigue es un ejemplo suelto, puesto acá para probar que la maquinaria
    del libro funciona de punta a punta: el archivo de `ejemplos/`, sus pruebas,
    el bloque sincronizado y el enlace a SWISH.

## Qué vas a poder hacer

## Hechos y reglas

Un programa Prolog es una base de conocimiento: se le cuentan hechos, se le dan
reglas, y después se le pregunta.

<!-- ejemplo: capitulo-01/familia.pl predicado: padre/2 -->
```prolog
% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(pedro, eva).
```

La regla dice cuándo alguien es abuelo de alguien:

<!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 -->
```prolog
% abuelo(A, N): A es abuelo de N cuando es el padre de alguno de sus padres.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
```

## Resumen
