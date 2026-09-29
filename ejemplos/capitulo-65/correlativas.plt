:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(correlativas).

test(aprobada, [true(R == definitivamente_si)]) :-
    respuesta([especificidad], cumple(101, am2, am1), R).

test(no_aprobada, [true(R == presumiblemente_no)]) :-
    respuesta([especificidad], cumple(102, am2, am1), R).

test(cursando, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], cumple(105, am2, am1), R).

test(autorizada, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], cumple(105, am2, alg), R).

test(condicional, [true(R == condicional([am1, alg]))]) :-
    inscripcion_rebatible(105, am2, R).

% El capítulo 31 rechaza por el primer requisito no aprobado; aquí, pp se
% está cursando, y el rechazo es por ssl.
test(otra_falta, [true(R-S == rechazada(falta(pp))-rechazada(falta(ssl)))]) :-
    inscripcion_posible(101, bd, R),
    inscripcion_rebatible(101, bd, S).

% Solo cambian las dos combinaciones anteriores.
test(solo_dos, [true(Ds == [101-bd, 105-am2])]) :-
    findall(L-M,
            ( alumno(L, _, _, _),
              materia(M, _, _),
              inscripcion_posible(L, M, R),
              inscripcion_rebatible(L, M, S),
              R \== S ),
            Ds).

test(sin_cambios, [true(R == rechazada(ya_aprobada))]) :-
    inscripcion_rebatible(101, am2, R).

% Bruno se inscribe de nuevo en álgebra, que desaprobó: el refutador socava
% la excepción de quien cursa, y las reglas no concluyen nada.
test(reinscripcion, [ setup(estado(E)),
                      cleanup(restaurar(E)),
                      true(R0-R == rechazada(falta(alg))-a_revisar(alg)) ]) :-
    inscripcion_rebatible(102, ssl, R0),
    inscribir(102, alg, aceptada),
    inscripcion_rebatible(102, ssl, R).

test(costo, [true(P < R)]) :-
    costo(posible, P),
    costo(rebatible, R).

test(version_desconocida, [error(type_error(_, _))]) :-
    costo(otra, _).

:- end_tests(correlativas).
