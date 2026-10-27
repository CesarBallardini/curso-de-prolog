:- encoding(utf8).

:- begin_tests(plantillas).

test(segmentos, all(X-Y == [[yo]-[bien]])) :-
    coincide([X, estoy, Y], [yo, estoy, bien]).

test(segmento_vacio, [nondet, true(X-Y == []-[triste])]) :-
    coincide([X, estoy, Y], [estoy, triste]).

test(dos_lugares, all(X-Y == [[a]-[b, y, c], [a, y, b]-[c]])) :-
    coincide([X, y, Y], [a, y, b, y, c]).

test(no_coincide, fail) :-
    coincide([_, estoy, _], [soy, feliz]).

test(rellenar, true(T == "¿Por qué estás muy cansado?")) :-
    rellenar(["¿Por qué estás ", [muy, cansado], "?"], T).

test(responder, true(R == "¿Por qué estás muy cansado?")) :-
    responder("Hoy estoy muy cansado.", R).

test(persona_sin_cambiar, true(R == "¿Por qué estás triste por mi \c
                                     trabajo?")) :-
    responder("Estoy triste por mi trabajo", R).

test(familia, true(R == "Háblame más de tu familia.")) :-
    responder("Mi madre no me escucha", R).

test(ninguna, true(R == "Continúa, por favor.")) :-
    responder("No sé", R).

:- end_tests(plantillas).
