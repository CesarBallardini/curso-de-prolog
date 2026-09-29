:- encoding(utf8).

:- begin_tests(experto).

% El intérprete nuevo identifica lo mismo que prueba/3 del capítulo 19.
test(caso_1, all(A == [guepardo])) :-
    caso(1, Obs),
    identificar(Obs, A).

test(caso_2, all(A == [cebra])) :-
    caso(2, Obs),
    identificar(Obs, A).

test(caso_3, all(A == [avestruz])) :-
    caso(3, Obs),
    identificar(Obs, A).

test(caso_4, all(A == [pinguino])) :-
    caso(4, Obs),
    identificar(Obs, A).

test(caso_5, all(A == [])) :-
    caso(5, Obs),
    identificar(Obs, A).

% El árbol tiene la forma del de prueba/3.
test(arbol_de_la_cebra,
     true(T == deducido(cebra, r10,
                        deducido(ungulado, r6,
                                 deducido(mamifero, r2, observado(da_leche))
                                 y observado(tiene_cascos))
                        y observado(rayas_negras)))) :-
    caso(2, Obs),
    once(demostrar(cebra, lista(Obs), [], T)).

test(como_avestruz,
     true(S == "avestruz: por r12\n  ave: por r3\n    tiene_plumas: \c
                observado\n  no_vuela: observado\n  peso(90): observado\n  \c
                90 > 50: se cumple\n")) :-
    caso(3, Obs),
    with_output_to(string(S), como(Obs, avestruz)).

test(motivo,
     true(S == "tiene_pelo se pregunta para probar:\n  mamifero, con la \c
                regla r1\n  carnivoro, con la regla r5\n  guepardo, con \c
                la regla r7\n")) :-
    with_output_to(string(S),
                   motivo(tiene_pelo, [r1-mamifero, r5-carnivoro,
                                       r7-guepardo])).

test(no_se_prueba_observacion,
     true(E == no_probado(cebra, [r10-no_observado(rayas_negras)]))) :-
    caso(5, Obs),
    no_se_prueba(cebra, Obs, E).

test(no_se_prueba_comparacion,
     true(E == no_probado(avestruz, [r12-no_se_cumple(30 > 50)]))) :-
    caso(4, Obs),
    no_se_prueba(avestruz, Obs, E).

% Una rama por cada regla que concluye la condición.
test(no_se_prueba_dos_reglas,
     true(E == no_probado(mamifero, [r1-no_observado(tiene_pelo),
                                     r2-no_observado(da_leche)]))) :-
    caso(4, Obs),
    no_se_prueba(mamifero, Obs, E).

test(no_se_prueba_si_se_prueba, [fail]) :-
    caso(1, Obs),
    no_se_prueba(guepardo, Obs, _).

test(por_que_no_jirafa,
     true(S == "jirafa: no se prueba\n  por r9:\n    ungulado: no se \c
                prueba\n      por r6:\n        tiene_cascos: no \c
                observado\n")) :-
    caso(1, Obs),
    with_output_to(string(S), por_que_no(Obs, jirafa)).

% La consulta con el usuario: las respuestas llegan desde una cadena.
test(consultar,
     [ cleanup(retractall(user:respondida(_, _))),
       true(A-S == guepardo-"¿tiene_pelo? tiene_pelo se pregunta para \c
                  probar:\n  mamifero, con la regla r1\n  carnivoro, con \c
                  la regla r5\n  guepardo, con la regla r7\n¿tiene_pelo? \c
                  ¿come_carne? ¿color_leonado? ¿manchas_oscuras? \c
                  guepardo: por r7\n  carnivoro: por r5\n    mamifero: \c
                  por r1\n      tiene_pelo: observado\n    come_carne: \c
                  observado\n  color_leonado: observado\n  \c
                  manchas_oscuras: observado\n") ]) :-
    con_entrada("por_que. si. si. si. si.",
                with_output_to(string(S), once(consultar(A)))).

% Cada pregunta se hace una vez: las respuestas quedan en respondida/2, y
% las hipótesis siguientes las reutilizan.
test(consultar_sin_repetir,
     [ cleanup(retractall(user:respondida(_, _))),
       true(Ps == [tiene_pelo, da_leche, tiene_plumas, no_vuela, vuela]) ]) :-
    con_entrada("no. no. si. no. no.",
                with_output_to(string(_), \+ consultar(_))),
    findall(P, user:respondida(P, _), Ps).

% Una pregunta con variables se responde con el término completo.
test(consultar_con_valor,
     [ cleanup(retractall(user:respondida(_, _))),
       true(A == avestruz) ]) :-
    con_entrada("no. no. si. si. no. no. peso(90).",
                with_output_to(string(_), once(consultar(A)))).

:- end_tests(experto).

%!  con_entrada(+Texto:string, :G) is semidet.
%
%   Ejecuta G una vez leyendo la entrada de Texto.
con_entrada(Texto, G) :-
    setup_call_cleanup(open_string(Texto, Entrada),
                       with_input(Entrada, G),
                       close(Entrada)).

%!  with_input(+Entrada, :G) is semidet.
%
%   Ejecuta G una vez con Entrada como entrada actual.
with_input(Entrada, G) :-
    current_input(Antes),
    setup_call_cleanup(set_input(Entrada),
                       once(G),
                       set_input(Antes)).
