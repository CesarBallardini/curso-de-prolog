:- encoding(utf8).

:- begin_tests(rastreo).

test(respuestas, all(N == [luis])) :-
    with_output_to(string(_), rastrear(abuelo(juan, N))).

% Hasta la primera respuesta, los puertos son los del depurador de SWI.
test(primera_respuesta,
     true(S == "Call: (1) abuelo(juan, A)\nCall: (2) padre(juan, A)\n\c
                Exit: (2) padre(juan, ana)\nCall: (2) padre(ana, A)\n\c
                Fail: (2) padre(ana, A)\nRedo: (2) padre(juan, ana)\n\c
                Exit: (2) padre(juan, pedro)\nCall: (2) padre(pedro, A)\n\c
                Exit: (2) padre(pedro, luis)\n\c
                Exit: (1) abuelo(juan, luis)\n")) :-
    with_output_to(string(S), once(rastrear(abuelo(juan, _)))).

% Al buscar otra respuesta, los objetivos se reintentan y fallan en orden
% inverso: el último Fail es el del objetivo inicial.
test(sin_mas_respuestas, true(Ultima == "Fail: (1) abuelo(juan, A)")) :-
    with_output_to(string(S), \+ ( rastrear(abuelo(juan, _)), fail )),
    split_string(S, "\n", "", Lineas),
    once(append(_, [Ultima, ""], Lineas)).

% Un objetivo sin prueba escribe su llamada y su falla, y falla.
test(sin_prueba,
     true(S == "Call: (1) padre(ana, A)\nFail: (1) padre(ana, A)\n")) :-
    with_output_to(string(S), \+ rastrear(padre(ana, _))).

% Escribir con nombres no liga las variables del objetivo.
test(no_liga, true(V == libre)) :-
    with_output_to(string(_), puerto('Call', f(X), 1)),
    (   var(X)
    ->  V = libre
    ;   V = ligada
    ).

:- end_tests(rastreo).
