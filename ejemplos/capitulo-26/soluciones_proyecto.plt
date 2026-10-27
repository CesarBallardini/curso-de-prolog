:- encoding(utf8).

:- begin_tests(soluciones_proyecto,
               [ cleanup(retractall(user:error_registrado(_, _))) ]).

% Ejercicio 11
test(nota_invalida, [error(domain_error(nota, 11))]) :-
    registrar_nota(101, pp, 11).

test(no_la_cursa, [error(existence_error(cursada, 101-am1))]) :-
    registrar_nota(101, am1, 9).

test(tipo, [error(type_error(integer, nueve))]) :-
    registrar_nota(101, pp, nueve).

test(registrar, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(Estado == nota(9)) ]) :-
    registrar_nota(101, pp, 9),
    inscripcion(101, pp, Estado).

% Ejercicio 12
test(comando_con_error, true(R == error(domain_error(nota, 11)))) :-
    ejecutar_ampliado("nota de 101 en paradigmas 11", R).

test(comando_registrado, [ setup(estado(E)), cleanup(restaurar(E)),
                           true(R == registrada) ]) :-
    ejecutar_ampliado("nota de 101 en paradigmas 9", R).

test(comando_anterior, true(R == inscriptos([101, 102, 104, 106]))) :-
    ejecutar_ampliado("listar logica", R).

% Ejercicio 13
test(errores_registrados,
     [ setup(retractall(user:error_registrado(_, _))),
       true(L == ["nota de 101 en paradigmas 11"-domain_error(nota, 11),
                  "nota de 104 en logica 8"-
                      existence_error(cursada, 104-log)]) ]) :-
    ejecutar_ampliado("nota de 101 en paradigmas 11", _),
    ejecutar_ampliado("nota de 104 en logica 8", _),
    errores(L).

:- end_tests(soluciones_proyecto).
