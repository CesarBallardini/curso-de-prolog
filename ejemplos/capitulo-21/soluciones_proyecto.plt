:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

% Ejercicio 14
test(vacantes, true(R == vacantes(0))) :-
    ejecutar("vacantes de logica", R).

test(vacantes_despues_de_inscribir, [ setup(estado(E)), cleanup(restaurar(E)),
                                      true(R == vacantes(19)) ]) :-
    ejecutar("inscribir a 104 en sintaxis", _),
    ejecutar("vacantes de sintaxis", R).

% Ejercicio 15: el texto generado se vuelve a analizar como el mismo comando.
test(texto_de, true(T == 'dar de baja a 105 en analisis_1')) :-
    texto_de(baja(105, am1), T).

test(ida_y_vuelta, all(C == [listar(am1), listar(alg), listar(log),
                             listar(am2), listar(pp), listar(ssl),
                             listar(bd)])) :-
    materia(M, _, _),
    texto_de(listar(M), T),
    atom_codes(T, Cs),
    phrase(palabras(Ps), Cs),
    phrase(comando(C), Ps).

% Ejercicio 16
test(uso, true(R == uso('inscribir a 101 en analisis_1'))) :-
    ejecutar("inscribir 104", R).

test(no_entendido, true(R == no_entendido)) :-
    ejecutar("hola", R).

:- end_tests(soluciones_proyecto).
