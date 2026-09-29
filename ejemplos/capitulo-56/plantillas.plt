:- encoding(utf8).

:- begin_tests(plantillas).

test(palabras, Ps == ["cuanto", "ocupa", "notas.txt"]) :-
    palabras("¿Cuánto ocupa notas.txt?", Ps).

test(palabras_punto_interior, Ps == ["borra", "los", "archivos", ".tmp"]) :-
    palabras("Borra los archivos .tmp.", Ps).

test(punto_solo_al_final, Ps == ["copia", "notas.txt", "de", "..", "a",
                                  "respaldo"]) :-
    palabras("Copia notas.txt de .. a respaldo.", Ps).

test(palabras_enie, Ps == ["que", "tamano", "tiene", "a.txt"]) :-
    palabras("¿Qué tamaño tiene a.txt?", Ps).

test(simplificar, Ss == ["lista", "de", "informes"]) :-
    simplificar(["muestrame", "los", "archivos", "de", "la", "carpeta",
                 "informes", "por", "favor"], Ss).

test(simplificar_regla_larga, Ss == ["lista", "de", "informes"]) :-
    simplificar(["que", "archivos", "hay", "en", "informes"], Ss).

test(listar, O == listar("informes", todos)) :-
    traducir("Muéstrame los archivos de la carpeta informes, por favor.", O).

test(listar_pregunta, O == listar("informes", todos)) :-
    traducir("¿Qué archivos hay en informes?", O).

test(contar, O == contar("informes", todos)) :-
    traducir("¿Cuántos archivos hay en la carpeta informes?", O).

test(copiar, O == copiar(archivo("notas.txt"), a("respaldo"))) :-
    traducir("Copia el archivo notas.txt a la carpeta respaldo.", O).

test(tamano, O == tamano(archivo("notas.txt"))) :-
    traducir("¿Cuánto ocupa notas.txt?", O).

test(salir, O == salir) :-
    traducir("Salir", O).

% La simplificación pierde el plural: la orden se entiende mal.
test(plural_perdido, O == borrar(archivo(".tmp"))) :-
    traducir("Borra los archivos .tmp", O).

% Una forma nueva de decir la misma orden necesita otra plantilla.
test(sin_plantilla, fail) :-
    traducir("Copia notas.txt de informes a respaldo", _).

:- end_tests(plantillas).
