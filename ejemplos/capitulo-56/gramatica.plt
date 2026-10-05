:- encoding(utf8).

:- begin_tests(gramatica).

test(copiar_conjunto,
     O == copiar(archivos("informes", patron("*.txt")), a("respaldo"))) :-
    entender("Copia los archivos .txt de informes a la carpeta respaldo", O).

test(listar_cortesia, O == listar("informes", todos)) :-
    entender("Muéstrame los archivos de la carpeta informes, por favor.", O).

test(listar_terminan, O == listar(".", patron("*.log"))) :-
    entender("Muestra todos los archivos que terminan en .log", O).

test(listar_contienen, O == listar(".", patron("*nota*"))) :-
    entender("Lista los archivos que contienen nota", O).

test(listar_empiezan, O == listar("informes", patron("acta*"))) :-
    entender("Lista los archivos que empiezan con acta de informes", O).

test(pregunta, O == listar("informes", todos)) :-
    entender("¿Qué archivos hay en informes?", O).

test(contar, O == contar("informes", patron("*.txt"))) :-
    entender("¿Cuántos archivos .txt hay en la carpeta informes?", O).

test(archivo_de_carpeta,
     O == copiar(archivo("informes/notas.txt"), a("respaldo"))) :-
    entender("Copia notas.txt de informes a respaldo", O).

test(borrar_plural, O == borrar(archivos(".", patron("*.tmp")))) :-
    entender("Borra los archivos .tmp", O).

test(borrar_sinonimo, O == borrar(archivo("viejo.log"))) :-
    entender("Elimina el archivo viejo.log", O).

test(tamano_singular, O == tamano(archivo("notas.txt"))) :-
    entender("¿Cuánto ocupa notas.txt?", O).

test(tamano_plural, O == tamano(archivos("informes", todos))) :-
    entender("¿Cuánto ocupan los archivos de informes?", O).

test(fecha, O == fecha(archivo("notas.txt"))) :-
    entender("¿Cuándo se modificó notas.txt?", O).

test(buscar, O == buscar(patron("*.pl"))) :-
    entender("Busca los archivos que terminan en .pl", O).

test(donde, O == buscar(patron("notas.txt"))) :-
    entender("¿Dónde está notas.txt?", O).

test(renombrar, O == mover(archivo("notas.txt"), a("apuntes.txt"))) :-
    entender("Renombra notas.txt como apuntes.txt", O).

test(ejecutar, O == ejecutar(archivo("hola.pl"))) :-
    entender("Ejecuta hola.pl", O).

test(salir, O == salir) :-
    entender("Adiós.", O).

test(genero, fail) :-
    entender("Borra la archivo x.txt", _).

test(todos_genero, fail) :-
    entender("Lista todas los archivos", _).

test(numero_verbo, fail) :-
    entender("¿Cuánto ocupa los archivos?", _).

test(numero_articulo, fail) :-
    entender("Borra el archivos .tmp", _).

test(ruta_extrana, O == copiar(archivo("../secreto.txt"), a("respaldo"))) :-
    entender("Copia ../secreto.txt a respaldo", O).

test(generar, Ps == ["borra", "el", "archivo", "viejo.log"]) :-
    once(phrase(orden(borrar(archivo("viejo.log"))), Ps)).

% Lo que la gramática genera, lo vuelve a analizar con el mismo significado.
test(ida_y_vuelta) :-
    forall(member(O, [ listar(".", todos),
                       contar("informes", patron("*.txt")),
                       copiar(archivos("informes", todos), a("respaldo")),
                       mover(archivo("a.txt"), a("b.txt")),
                       tamano(archivos(".", patron("*nota*"))),
                       fecha(archivo("a.txt")),
                       buscar(patron("*.pl")),
                       ejecutar(archivo("hola.pl")),
                       salir ]),
           ( once(phrase(orden(O), Ps)),
             once(phrase(orden(O2), Ps)),
             O2 == O )).

test(objeto_con_articulo, all(O-N == [archivo("notas.txt")-sg])) :-
    phrase(objeto(O, N), ["el", "archivo", "notas.txt"]).

test(objeto_de_carpeta, all(O == [archivo("informes/notas.txt")])) :-
    phrase(objeto(O, _), ["notas.txt", "de", "informes"]).

test(conjunto, all(C-F == ["informes"-patron("*.txt")])) :-
    phrase(conjunto(C, F), ["todos", "los", "archivos", ".txt", "de",
                            "informes"]).

test(conjunto_sin_concordancia, fail) :-
    phrase(conjunto(_, _), ["todas", "los", "archivos"]).

test(cuantificador, all(G == [f])) :-
    phrase(cuantificador(G), ["todas"]).

test(cuantificador_vacio, [nondet, true(var(G))]) :-
    phrase(cuantificador(G), []).

test(determinante, all(G-N == [f-pl])) :-
    phrase(determinante(G, N), ["las"]).

test(sustantivo, all(L-G-N == [carpeta-f-pl])) :-
    phrase(sustantivo(L, G, N), ["carpetas"]).

test(sustantivo_genera, all(Ps == [["archivos"]])) :-
    phrase(sustantivo(archivo, m, pl), Ps).

test(nombre, all(N == ["notas.txt"])) :-
    phrase(nombre(N), ["notas.txt"]).

test(nombre_reservado, fail) :-
    phrase(nombre(_), ["los"]).

test(nombre_con_asterisco, fail) :-
    phrase(nombre(_), ["a*b"]).

:- end_tests(gramatica).
