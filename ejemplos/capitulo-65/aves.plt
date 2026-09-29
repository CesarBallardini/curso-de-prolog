:- encoding(utf8).

:- begin_tests(aves).

test(tweety, [true(R == presumiblemente_si)]) :-
    respuesta([], vuela(tweety), R).

test(ave_estricta, [true(R == definitivamente_si)]) :-
    respuesta([], ave(opus), R).

% Sin comparar las reglas, las del triángulo se derrotan entre sí.
test(opus_sin_criterio, [true(R == sin_conclusion)]) :-
    respuesta([], vuela(opus), R).

test(opus_especificidad, [true(R == presumiblemente_no)]) :-
    respuesta([especificidad], vuela(opus), R).

test(rufo, [true(R-S == sin_conclusion-presumiblemente_si)]) :-
    respuesta([], vuela(rufo), R),
    respuesta([especificidad], vuela(rufo), S).

% El diamante: la especificidad no decide; la superioridad declarada sí.
test(dracula, [true(R-S == sin_conclusion-presumiblemente_no)]) :-
    respuesta([especificidad], vuela(dracula), R),
    respuesta([declarada, especificidad], vuela(dracula), S).

test(dracula_solo_declarada, [true(R == presumiblemente_no)]) :-
    respuesta([declarada], vuela(dracula), R).

% La cadena de Juana está derrotada: ninguna regla es más específica.
test(juana, [true(R == sin_conclusion)]) :-
    respuesta([declarada, especificidad], se_mantiene(juana), R).

test(adulta, [true(R == presumiblemente_si)]) :-
    respuesta([especificidad], adulto(juana), R).

test(quienes_vuelan, [true(Xs == [tweety, rufo])]) :-
    findall(X, derivable([especificidad], vuela(X)), Xs).

test(quienes_no_vuelan, [true(Xs-Ys == [opus]-[opus, dracula])]) :-
    findall(X, derivable([especificidad], neg vuela(X)), Xs),
    findall(Y, derivable([declarada, especificidad], neg vuela(Y)), Ys).

% La anticipación no cambia ninguna respuesta de las aves.
test(anticipacion_neutra, [true(As == Bs)]) :-
    Ms = [vuela(tweety), vuela(opus), vuela(rufo), vuela(dracula),
          se_mantiene(juana)],
    findall(A, ( member(M, Ms),
                 respuesta([declarada, especificidad], M, A) ), As),
    findall(B, ( member(M, Ms),
                 respuesta([anticipacion, declarada, especificidad], M, B) ),
            Bs).

:- end_tests(aves).
