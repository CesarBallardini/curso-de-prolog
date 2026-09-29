:- encoding(utf8).

:- begin_tests(soluciones_diagnostico).

% Ejercicio 11
test(responde_mal, true(Ys == [c])) :-
    invertir_mal([a, b, c], Ys).

test(oraculo, [true]) :-
    pretendido(invertir_mal([c], [b, a], [c, b, a])).

test(programa,
     all(C == [(invertir_mal([c], [b], [c]) :- invertir_mal([], [c], [c]))])) :-
    respuesta_incorrecta(programa, invertir_mal([a, b, c], _), C).

% Con un solo elemento el acumulado vacío no se pierde: no hay error.
test(programa_sin_error, [fail]) :-
    respuesta_incorrecta(programa, invertir_mal([a], _), _).

% Ejercicio 12
test(usuario,
     [ cleanup(retractall(user:juicio(_, _))),
       true(C-S == (invertir_mal([c], [b], [c]) :- invertir_mal([], [c], [c]))-
                   "¿Es correcto invertir_mal([a,b,c],[c])? ¿Es correcto \c
                    invertir_mal([a,b,c],[],[c])? ¿Es correcto \c
                    invertir_mal([b,c],[a],[c])? ¿Es correcto \c
                    invertir_mal([c],[b],[c])? ¿Es correcto \c
                    invertir_mal([],[c],[c])? ") ]) :-
    con_entrada("no. no. no. no. si.",
                with_output_to(string(S),
                               respuesta_incorrecta(usuario,
                                                    invertir_mal([a, b, c], _),
                                                    C))).

% Las respuestas quedan registradas: la segunda vez no se pregunta nada.
test(usuario_sin_repetir,
     [ cleanup(retractall(user:juicio(_, _))),
       true(S == "") ]) :-
    con_entrada("no. no. no. no. si.",
                with_output_to(string(_),
                               respuesta_incorrecta(usuario,
                                                    invertir_mal([a, b, c], _),
                                                    _))),
    with_output_to(string(S),
                   respuesta_incorrecta(usuario, invertir_mal([a, b, c], _),
                                        _)).

:- end_tests(soluciones_diagnostico).

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
