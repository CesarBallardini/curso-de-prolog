:- encoding(utf8).

% Pruebas del módulo comandos (capítulo 25): el lenguaje de comandos.

% Las pruebas cargan los módulos que usan además del que prueban.
:- use_module(datos).
:- use_module(informes).

:- begin_tests(comandos).

% --- Lenguaje de comandos --------------------------------------------------

test(palabras, true(P == [inscribir, a, 104, en, sintaxis])) :-
    phrase(palabras(P), `  inscribir a 104 en sintaxis `).

test(comando, true(C == inscribir(104, ssl))) :-
    phrase(comando(C), [inscribir, a, 104, en, sintaxis]).

% La misma gramática genera las palabras de un comando.
test(generar_comando, true(P == [dar, de, baja, a, 105, en, analisis_1])) :-
    phrase(comando(baja(105, am1)), P).

test(ejecutar_inscribir, [ setup(estado(E)), cleanup(restaurar(E)),
                           true(R-L == aceptada-[104]) ]) :-
    ejecutar("inscribir a 104 en sintaxis", R),
    inscriptos(ssl, L).

test(ejecutar_baja, [ setup(estado(E)), cleanup(restaurar(E)),
                      true(R == baja) ]) :-
    ejecutar("dar de baja a 105 en analisis_1", R).

test(ejecutar_baja_rechazada, true(R == rechazada(no_la_cursa))) :-
    ejecutar("dar de baja a 101 en logica", R).

test(ejecutar_listar, true(R == inscriptos([101, 102, 103, 105, 106]))) :-
    ejecutar("listar analisis_1", R).

test(ejecutar_promedio, true(R == promedio(8.5))) :-
    ejecutar("promedio de 101", R).

test(ejecutar_sin_notas, true(R == sin_notas)) :-
    ejecutar("promedio de 107", R).

test(no_entendido, true(R == no_entendido)) :-
    ejecutar("inscribir 104 sintaxis", R).

test(alumno_inexistente, true(R == no_entendido)) :-
    ejecutar("promedio de 999", R).

% --- Errores --------------------------------------------------------------

test(texto_no_es_texto, [error(type_error(text, 42))]) :-
    ejecutar(42, _).

:- end_tests(comandos).
