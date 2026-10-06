:- encoding(utf8).

:- use_module(estratos).
:- use_module(magia).

:- begin_tests(marcos).

% Las reglas de Rowe no terminan con Prolog.
test(rowe, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(findall(P, tiene_parte_rowe(auto, P), _),
                              1000000, R).

test(parte_de_rowe, [true(O == sistema_electrico)]) :-
    once(parte_de_rowe(bateria, O)).

test(reglas, [true(N == 11)]) :-
    reglas_marcos(Rs),
    length(Rs, N).

test(programa) :-
    programa_marcos(Cs),
    memberchk((anio_actual(1987) :- true), Cs),
    memberchk((hereda(edad, es_un) :- true), Cs).

test(componentes, [true(Cs == [[parte_de/2, tiene_parte/2], [propio/3],
                               [con_propio/2], [tiene_valor/3]])]) :-
    programa_marcos(P),
    componentes(P, Cs).

test(partes, [true(Rs == [tiene_parte(auto, sistema_electrico)])]) :-
    programa_marcos(Cs),
    respuestas(Cs, tiene_parte(auto, _), Rs, _).

% El valor propio reemplaza al heredado; la edad se calcula.
test(bateria, [true(Vs == [edad-11, propietario-juan])]) :-
    programa_marcos(Cs),
    findall(R-V, ( member(R, [edad, propietario, uso]),
                   respuestas(Cs, tiene_valor(bateria_de_juan_hoy, R, V),
                              [tiene_valor(_, _, V)], _) ),
            Vs).

test(como_capitulo81, [true(I == true)]) :-
    comparar_marcos(I).

test(magia, [true(Rs == Rs1)]) :-
    programa_marcos(Cs),
    respuestas(Cs, tiene_valor(rabbit_de_juan_hoy, _, _), Rs, _),
    respuestas_magicas(Cs, tiene_valor(rabbit_de_juan_hoy, _, _), Rs1, _).

test(consulta_marcos, [true(Rs-C == [tiene_parte(auto, sistema_electrico)]-costo(11, 147))]) :-
    consulta_marcos(tiene_parte(auto, _), Rs, C).

test(componentes_marcos, [true(N == 4)]) :-
    componentes_marcos(Ks),
    length(Ks, N).

:- end_tests(marcos).
